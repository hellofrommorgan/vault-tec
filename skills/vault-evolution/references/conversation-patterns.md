# Conversation Patterns

Effective interaction templates for vault evolution discussions. These patterns guide the conversational flow when working with users on architectural changes.

## Discovery Conversation

Use when the user reports friction but hasn't diagnosed the cause.

**Pattern: Funnel from Symptoms to Diagnosis**

```
1. OPEN: "What's not working? What feels off?"
   → Let the user describe symptoms in their own words

2. LOCATE: "Can you point to a specific moment where this was frustrating?"
   → Ground the discussion in concrete experience, not abstract complaints

3. PATTERN: "Has this happened before, or is this new?"
   → Distinguish chronic issues from acute ones

4. HYPOTHESIZE: "Based on what you're describing, this could be [X] or [Y]."
   → Present 2 possible diagnoses with different implications

5. VERIFY: "Let me check the data — running a health diagnostic now."
   → Validate hypothesis against objective metrics

6. PROPOSE: Present 2-3 ranked proposals using the evolution pattern template
```

**Key Principles**:
- Don't jump to solutions before understanding the problem
- Use the user's language, not system jargon
- Ground every proposal in both the user's experience AND research

## Coaching Conversation

Use when the diagnosis is behavioral (user not following existing architecture), not structural.

**Pattern: Align Without Blaming**

```
1. ACKNOWLEDGE: "The vault structure you have is actually well-suited for this."
   → Start by validating what exists

2. OBSERVE: "I notice that [behavior] is different from what the vault expects."
   → State observation without judgment

3. EXPLAIN: "The vault is set up this way because [research claim]."
   → Connect architecture to purpose

4. SUGGEST: "Want to try [specific behavioral change] for a week?"
   → Small, time-bounded experiment rather than permanent commitment

5. FOLLOW UP: "After a week, we can check if this helped or if the structure needs to change."
   → Leave the door open for structural change if coaching doesn't work
```

**Key Principles**:
- Never blame the user for not following the system
- The system exists to serve the user, not the other way around
- If the user consistently can't follow the architecture, the architecture is wrong

## Proposal Conversation

Use when presenting evolution proposals for user decision.

**Pattern: Options with Recommendation**

```
1. CONTEXT: "Here's what I found: [summary of diagnosis]"
   → Brief situational context

2. OPTIONS: Present 2-3 proposals in the standard template format
   → Each with clear trade-offs

3. RECOMMEND: "I'd recommend [Proposal N] because [reason]."
   → Give a clear recommendation, don't force the user to decide without guidance

4. INVITE: "What do you think? Any of these feel right?"
   → Let the user modify, combine, or reject proposals

5. CONFIRM: "To confirm: we're going with [specific plan]. I'll [list specific actions]."
   → Explicit confirmation before making changes
```

**Key Principles**:
- Always give a recommendation, but don't steamroll
- Explain trade-offs honestly (including doing nothing)
- Get explicit confirmation before implementing changes

## Emergency Conversation

Use when a vault is in critical state (health score < 60).

**Pattern: Stabilize Before Improving**

```
1. ASSESS: Run immediate health check. Identify the critical issues.

2. TRIAGE: Rank issues by impact:
   P1 — Data integrity (broken links, corrupted schema)
   P2 — Structural integrity (missing spaces, contamination)
   P3 — Process integrity (pipeline blockages, stale inbox)

3. STABILIZE: Fix P1 issues first with minimal changes.
   → Don't refactor during an emergency

4. REPORT: Show what was fixed and current health score.

5. PLAN: Schedule a full evolution review for a non-emergency time.
```

**Key Principles**:
- Fix what's broken, don't optimize
- Minimal changes during emergencies
- Save architectural discussions for stable times
