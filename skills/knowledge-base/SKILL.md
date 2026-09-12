---
name: knowledge-base
description: 'Maintains a persistent, human-readable and agent-parseable knowledge base of important technical nuances, gotchas, root-causes, and reusable learnings discovered while working. Use whenever a non-obvious technical insight is discovered (a debugging root-cause, a tricky config/API behavior, a decision with lasting consequences) that would save time in a future session or for another agent/human on this project.'
---

# Knowledge Base

Forces a running notes channel for the project so important nuances survive beyond the current conversation. Notes live **inside the project repo** (not just in this hub), so any human or agent working on that repo can read them.

## Storage Location
- `NOTES.md` at the project root for small projects, **or**
- `knowledge-base/<topic>.md` (one file per topic) once `NOTES.md` grows past ~150 lines, with `knowledge-base/README.md` as a one-line index of topics.
- Use the [NOTES template](./assets/NOTES.template.md) to start a new file.

## When to Record an Entry
Record a nuance when it meets at least one of these:
- It took real effort to figure out (debugging session, trial and error, reading source/docs deeply).
- It's not obvious from the code or official docs and would trip up the next person/agent.
- It's a reusable pattern or gotcha likely to recur in this or future projects.
- It's a decision with lasting consequences (why an approach was chosen/rejected).

Do **not** record: routine changes, self-explanatory code, or anything already obvious from reading the file/commit itself.

## Procedure
1. When such a nuance surfaces during work (mid-task or at task completion), stop and write an entry — don't defer it to "later."
2. Append using the template below, keeping it to a few concise bullet points, not prose paragraphs.
3. Prefer specific, greppable headers (exact error message, API name, tool name) so both humans skimming and agents grepping/chunking can find it fast.
4. If a new entry contradicts or supersedes an old one, update the old entry in place — don't leave stale/conflicting notes.

## Entry Format

```markdown
## <Short specific title, e.g. "flake.lock must be committed for git+file inputs">
- **Date**: YYYY-MM-DD
- **Context**: <what you were doing when this came up>
- **Nuance**: <the actual insight, in 1-3 bullet points>
- **Why it matters**: <consequence if ignored>
- **Refs**: <file(s)/link(s), optional>
```

## Example

```markdown
## Nix flakes with git+file:// inputs only see committed/staged content
- **Date**: 2026-09-12
- **Context**: `nix flake show` ignored a newly added devShell until staged.
- **Nuance**: Nix's git fetcher for local repos reads the git index, not the working tree — untracked/uncommitted changes are invisible to flake evaluation.
- **Why it matters**: Forgetting to `git add`/commit after editing flake.nix makes changes silently not apply for consumers.
- **Refs**: life-hub/flake.nix
```

## Agent Checklist (run at end of non-trivial tasks)
- [ ] Was there a debugging root-cause, gotcha, or non-obvious behavior found this task?
- [ ] If yes, is it already captured in `NOTES.md`/`knowledge-base/`? If not, add it now, before ending the turn.
