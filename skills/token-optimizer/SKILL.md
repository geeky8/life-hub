---
name: token-optimizer
description: 'Reduces token usage while preserving context fidelity: checks existing memory/notes before re-searching, prefers targeted reads (grep/line-ranges) over whole-file reads, compacts large tool outputs into their essential facts, and periodically summarizes conversation history into a short running summary. Use in long sessions, large codebases/files, or whenever context window pressure or repeated redundant lookups are a concern.'
---

# Token Optimizer

## When to Use
- Long-running sessions with many tool calls.
- Large files or large repositories where full reads are wasteful.
- Any time the same information is at risk of being fetched more than once.

## Procedure

### 1. Check before you search
Before running a search or reading a file, check whether the answer is already available:
- Earlier in the current conversation.
- In session/repo memory notes (`/memories/session/`, `/memories/repo/`) or the project's [knowledge-base](../knowledge-base/SKILL.md) notes.
If it's already known, reuse it — don't re-fetch.

### 2. Read narrow, not wide
- Use targeted `grep`/regex searches to find the relevant lines first, then read only the needed line range — not the whole file — unless the file is small or you genuinely need full context.
- When exploring an unfamiliar area, prefer one well-scoped search over several broad speculative ones.

### 3. Compact large outputs immediately
- After a large tool result (long file, verbose command output, big search result set), restate only the facts relevant to the task in your own words before acting on it.
- Don't quote large blocks back verbatim in your response unless the user needs to see the literal content (e.g. code to review, exact error text).

### 4. Batch independent work
- Combine independent read-only tool calls in parallel instead of sequential round-trips.
- Avoid re-reading a file you already have in context unless it may have changed.

### 5. Periodically compact conversation state
- On long sessions or after completing a major milestone, write a short running summary (goal, decisions made, current state, next step) to session memory rather than relying on the full transcript remaining in context.
- Keep the summary to key facts and decisions — not a transcript.

## Guardrail
Never trade away correctness for brevity — if compacting would drop a detail needed for the task (exact error message, precise line number, exact config value), keep that detail verbatim and compact only the surrounding narrative.
