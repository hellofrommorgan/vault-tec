// vault-tec Copilot CLI extension
// Bridges vault-tec's 7 bash hooks into Copilot CLI's JS hook API.
//
// Design: thin adapter that (a) pre-filters in JS to avoid subprocess spawns
// for irrelevant tool calls, (b) shells out to the canonical bash hook
// scripts for vault operations, (c) parses their `{additionalContext: ...}`
// JSON stdout protocol and maps to Copilot hook return objects.
//
// Council-reviewed. See README.md in this dir for the full design rationale.

import { joinSession } from "@github/copilot-sdk/extension";
import { spawn } from "node:child_process";
import { readFileSync, existsSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join, resolve as pathResolve } from "node:path";

// ─── Paths: resolve via import.meta.url so the extension works from any install location ───
const EXT_DIR = dirname(fileURLToPath(import.meta.url));
const SCRIPTS_DIR = join(EXT_DIR, "scripts");  // symlink to vault-tec/hooks/scripts
const CONFIG_PATH = join(process.env.HOME || "", ".vault-tec", "config.sh");

// ─── Config cache: source ~/.vault-tec/config.sh once at startup ───
// Returns {VAULT_PATH, VAULT_NAME, ...} as plain object. Skip-invokes bash.
function loadConfig() {
    const cfg = {};
    if (!existsSync(CONFIG_PATH)) return cfg;
    try {
        const txt = readFileSync(CONFIG_PATH, "utf-8");
        for (const raw of txt.split("\n")) {
            const line = raw.trim();
            if (!line || line.startsWith("#")) continue;
            // Match KEY=VALUE (unquoted) or KEY="VALUE" or KEY='VALUE'. Ignore `export`.
            const m = line.match(/^(?:export\s+)?([A-Z_][A-Z0-9_]*)=(?:"([^"]*)"|'([^']*)'|([^#\s]*))/);
            if (!m) continue;
            cfg[m[1]] = m[2] ?? m[3] ?? m[4] ?? "";
        }
    } catch { /* swallow — best-effort */ }
    return cfg;
}

const CONFIG = loadConfig();
const VAULT_PATH = CONFIG.VAULT_PATH || process.env.VAULT_PATH || "";
const VAULT_BASENAME = VAULT_PATH ? VAULT_PATH.split("/").filter(Boolean).pop() : "";

// ─── Hook timeout budgets (ms). Past budget → kill child, return void. ───
const TIMEOUTS = {
    pre:     2000,
    post:    3000,
    prompt:  2000,
    start:  15000,   // pipboy + rad-counter walk the vault
    end:     2000,
};

// ─── Child process tracker: cascade SIGTERM on extension shutdown ───
const liveChildren = new Set();
for (const sig of ["SIGTERM", "SIGINT", "beforeExit"]) {
    process.on(sig, () => {
        for (const c of liveChildren) { try { c.kill("SIGTERM"); } catch {} }
    });
}

// ─── Subprocess runner with timeout + env injection + cwd passthrough ───
function runHook(scriptName, stdinJson, { timeoutMs, cwd } = {}) {
    return new Promise((resolve) => {
        const scriptPath = join(SCRIPTS_DIR, scriptName);
        // Env: pre-load VAULT_PATH + all config so bash scripts can skip re-sourcing.
        const env = {
            ...process.env,
            ...CONFIG,
            VAULT_TEC_CONFIG_PRELOADED: "1",
        };
        const child = spawn("bash", [scriptPath], {
            env,
            cwd: cwd || process.cwd(),
            stdio: ["pipe", "pipe", "pipe"],
        });
        liveChildren.add(child);
        let out = "", err = "", done = false;
        const finish = (result) => {
            if (done) return;
            done = true;
            liveChildren.delete(child);
            resolve(result);
        };
        const killer = setTimeout(() => {
            try { child.kill("SIGTERM"); } catch {}
            setTimeout(() => { try { child.kill("SIGKILL"); } catch {} }, 500);
            finish({ code: -1, stdout: out, stderr: err, timedOut: true });
        }, timeoutMs ?? 3000);
        child.stdout.on("data", (d) => { out += d; });
        child.stderr.on("data", (d) => { err += d; });
        child.on("error", (e) => {
            clearTimeout(killer);
            finish({ code: -1, stdout: "", stderr: String(e), error: true });
        });
        child.on("close", (code) => {
            clearTimeout(killer);
            finish({ code: code ?? 0, stdout: out, stderr: err });
        });
        try {
            child.stdin.write(JSON.stringify(stdinJson));
            child.stdin.end();
        } catch (e) {
            clearTimeout(killer);
            finish({ code: -1, stdout: "", stderr: String(e), error: true });
        }
    });
}

// ─── stdout parser: bash hooks emit `{"additionalContext": "..."}` — extract field ───
function parseHookOutput(stdout) {
    const s = (stdout || "").trim();
    if (!s) return {};
    try {
        const parsed = JSON.parse(s);
        if (parsed && typeof parsed === "object") return parsed;
    } catch { /* not JSON — treat as plain text fallback */ }
    return { additionalContext: s };
}

// ─── Scope filter: is this tool call inside the vault's notes/ tree? ───
// Copilot tool-name enum vs Claude: edit/create/write all map to the writer ops
// that vault schema validation cares about. view/grep/bash are ignored.
const WRITER_TOOLS = new Set(["edit", "create", "write", "str_replace", "Write", "Edit"]);

function extractPath(toolArgs) {
    if (!toolArgs || typeof toolArgs !== "object") return "";
    return toolArgs.path || toolArgs.file_path || "";
}

function isVaultNote(path) {
    if (!path || !VAULT_PATH) return false;
    if (!path.endsWith(".md")) return false;
    // Match `<anything>/<vault-basename>/notes/<...>.md` OR absolute path inside VAULT_PATH/notes
    const notesDir = `${VAULT_PATH}/notes/`;
    if (path.startsWith(notesDir)) return true;
    // fallback: basename check (Claude hook pattern)
    if (VAULT_BASENAME && path.includes(`/${VAULT_BASENAME}/notes/`)) return true;
    return false;
}

// ─── Content synthesis for `edit` tool (no `content` field, just old_str/new_str) ───
// Reads file from disk + applies the patch in-memory so bash schema check sees full content.
function synthesizeEditContent(toolArgs) {
    if (!toolArgs || typeof toolArgs !== "object") return "";
    if (typeof toolArgs.content === "string") return toolArgs.content;
    const p = extractPath(toolArgs);
    if (!p || !existsSync(p)) return toolArgs.new_str || "";
    try {
        const cur = readFileSync(p, "utf-8");
        if (typeof toolArgs.old_str === "string" && typeof toolArgs.new_str === "string") {
            // Simulate the edit — single replace mirrors vault-tec's edit semantics
            return cur.split(toolArgs.old_str).join(toolArgs.new_str);
        }
        return cur;
    } catch { return ""; }
}

// ─── Build Claude-shape stdin from Copilot input ───
function toClaudeShape(input, { synthesizeContent = false } = {}) {
    const args = input.toolArgs || {};
    const path = extractPath(args);
    const content = synthesizeContent ? synthesizeEditContent(args) : (args.content ?? "");
    return {
        // Translate Copilot tool name → Claude's (legacy hook guards use `Write`/`Edit`)
        tool_name: translateToolName(input.toolName),
        tool_input: {
            file_path: path,
            content,
            command: args.command ?? "",
            old_str: args.old_str ?? "",
            new_str: args.new_str ?? "",
        },
        cwd: input.cwd,
    };
}

function translateToolName(name) {
    switch (name) {
        case "edit":        return "Edit";
        case "create":      return "Write";
        case "write":       return "Write";
        case "str_replace": return "Edit";
        case "view":        return "Read";
        case "bash":        return "Bash";
        case "grep":        return "Grep";
        case "glob":        return "Glob";
        default: return name;
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// Hook handlers
// ═══════════════════════════════════════════════════════════════════════════

async function handleSessionStart(input) {
    // Skip heavy scan on resume — state already in context.
    if (input?.source === "resume") return;
    if (!VAULT_PATH) return;
    const r = await runHook("vault-session-start.sh", {}, { timeoutMs: TIMEOUTS.start });
    if (r.timedOut || r.error) return;
    const parsed = parseHookOutput(r.stdout);
    if (parsed.additionalContext) return { additionalContext: parsed.additionalContext };
}

async function handleSessionEnd(input) {
    if (!VAULT_PATH) return;
    const r = await runHook(
        "vault-session-end.sh",
        { reason: input?.reason || "user_exit" },
        { timeoutMs: TIMEOUTS.end }
    );
    if (r.timedOut || r.error) return;
    // SessionEndHookOutput does not support additionalContext — surface as sessionSummary instead.
    const parsed = parseHookOutput(r.stdout);
    if (parsed.additionalContext) return { sessionSummary: parsed.additionalContext };
}

async function handleUserPromptSubmitted(input) {
    if (!VAULT_PATH) return;
    const r = await runHook(
        "vault-userpromptsubmit.sh",
        { prompt: input.prompt || "" },
        { timeoutMs: TIMEOUTS.prompt }
    );
    if (r.timedOut || r.error) return;
    const parsed = parseHookOutput(r.stdout);
    if (parsed.additionalContext) return { additionalContext: parsed.additionalContext };
}

async function handlePreToolUse(input) {
    // Gate: writers only + must be inside vault notes/.
    if (!WRITER_TOOLS.has(input.toolName)) return;
    const path = extractPath(input.toolArgs);
    if (!isVaultNote(path)) return;
    const stdin = toClaudeShape(input, { synthesizeContent: true });
    const r = await runHook("vault-pretooluse.sh", stdin, {
        timeoutMs: TIMEOUTS.pre,
        cwd: input.cwd,
    });
    if (r.timedOut || r.error) return;
    // Claude's exit 2 = deny. Current vault-pretooluse.sh exits 0 always (advisory).
    // Support both paths: exit 2 → deny, stdout JSON → additionalContext.
    if (r.code === 2) {
        const reason = r.stderr.trim() || r.stdout.trim() || "vault-tec schema violation";
        return { permissionDecision: "deny", permissionDecisionReason: reason };
    }
    const parsed = parseHookOutput(r.stdout);
    if (parsed.additionalContext) return { additionalContext: parsed.additionalContext };
}

async function handlePostToolUse(input) {
    // Route tool-execution failures through posttooluse (M2 — failure routing).
    // Still gate on writer + vault-note.
    if (!WRITER_TOOLS.has(input.toolName)) return;
    const path = extractPath(input.toolArgs);
    if (!isVaultNote(path)) return;
    const stdin = toClaudeShape(input);
    const r = await runHook("vault-posttooluse.sh", stdin, {
        timeoutMs: TIMEOUTS.post,
        cwd: input.cwd,
    });
    if (r.timedOut || r.error) return;
    const parsed = parseHookOutput(r.stdout);
    // If the tool itself failed, annotate.
    if (input.toolResult?.resultType === "failure") {
        const failMsg = `vault-tec: ${input.toolName} failed on ${path}`;
        return { additionalContext: [parsed.additionalContext, failMsg].filter(Boolean).join("\n\n") };
    }
    if (parsed.additionalContext) return { additionalContext: parsed.additionalContext };
}

async function handleErrorOccurred(input) {
    // Only surface system/model errors — tool_execution handled by onPostToolUse.
    if (input?.errorContext === "tool_execution") return;
    await session.log(`vault-tec: ${input.errorContext} error — ${input.error}`, { level: "error" });
}

// ═══════════════════════════════════════════════════════════════════════════
// PreCompact emulation — Copilot has no onPreCompact hook.
// Strategy (M3): register a `vault_tec_preserve_state` tool that invokes
// vault-precompact.sh, and inject a standing instruction via onSessionStart
// telling the agent to call it before compaction or at conversation wind-down.
// ═══════════════════════════════════════════════════════════════════════════

const PRESERVE_STATE_TOOL = {
    name: "vault_tec_preserve_state",
    description:
        "Snapshot vault working-memory, active patterns, and next-move before " +
        "context compaction or end of session. Call this proactively when you " +
        "sense the conversation is getting long, before running /compact, or at " +
        "any natural checkpoint where state would otherwise be lost.",
    parameters: {
        type: "object",
        properties: {
            trigger: {
                type: "string",
                description: "Why you're preserving state (e.g. 'pre-compact', 'checkpoint', 'wind-down')",
            },
        },
        required: [],
    },
    handler: async (args) => {
        if (!VAULT_PATH) return "vault-tec: no VAULT_PATH configured — skipped";
        const r = await runHook(
            "vault-precompact.sh",
            { trigger: args.trigger || "manual" },
            { timeoutMs: 10000 }
        );
        if (r.timedOut) return "vault-tec: preserve-state timed out";
        if (r.error) return `vault-tec: preserve-state error — ${r.stderr.trim()}`;
        const parsed = parseHookOutput(r.stdout);
        return parsed.additionalContext || "vault-tec: state snapshot complete";
    },
};

const STANDING_PRESERVE_INSTRUCTION =
    "vault-tec: When context approaches limits or before compaction, call the " +
    "`vault_tec_preserve_state` tool to snapshot working-memory before it's lost. " +
    "(Copilot CLI has no onPreCompact hook; this tool is the only preservation path.)";

// ═══════════════════════════════════════════════════════════════════════════
// Session wire-up
// ═══════════════════════════════════════════════════════════════════════════

// `session` is captured by the handlers above via this `let` binding (not const
// in joinSession arg-position) — hook handlers won't fire before joinSession
// resolves, so the TDZ is always cleared by the time they run.
let session;

session = await joinSession({
    tools: VAULT_PATH ? [PRESERVE_STATE_TOOL] : [],
    hooks: {
        onSessionStart: async (input, invocation) => {
            const base = await handleSessionStart(input);
            const ctx = [
                base?.additionalContext,
                VAULT_PATH ? STANDING_PRESERVE_INSTRUCTION : null,
            ].filter(Boolean).join("\n\n");
            return ctx ? { additionalContext: ctx } : base;
        },
        onSessionEnd: handleSessionEnd,
        onUserPromptSubmitted: handleUserPromptSubmitted,
        onPreToolUse: handlePreToolUse,
        onPostToolUse: handlePostToolUse,
        onErrorOccurred: handleErrorOccurred,
    },
});

if (VAULT_PATH) {
    await session.log(`vault-tec: loaded (vault: ${VAULT_PATH})`, { ephemeral: true });
} else {
    await session.log("vault-tec: no VAULT_PATH configured — hooks idle. Run /vault-tec:setup.", {
        level: "warning",
        ephemeral: true,
    });
}
