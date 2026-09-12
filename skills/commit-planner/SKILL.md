---
name: commit-planner
description: 'Plans and stages atomic git commits from accumulated working-tree/staged changes: groups changes into the smallest self-contained units where the project still builds/evaluates/runs after every single commit, orders commits so each step is buildable (iterative, dependency-aware), and specifies the exact files and hunks to stage per commit. Use when asked to "plan commits", "split these changes into commits", "clean up git history before pushing", "make these commits atomic", or when multiple unrelated changes have piled up staged/unstaged.'
---

# Commit Planner

## When to Use
- Multiple logically distinct changes have accumulated (staged or not) and need to become clean history.
- Before pushing, when the user wants reviewable, revertible, bisectable commits instead of one giant commit.
- User explicitly asks to "plan the commits" or "split this into atomic commits".

## Rules (non-negotiable)

1. **Atomic** — each commit does exactly one logical thing: one capability added, one bug fixed, one file/concern touched. Never bundle unrelated changes for convenience.
2. **Always leaves the project working** — after *every single commit* (not just the final one), the project must build/evaluate/run. If checked out in isolation at that commit, nothing should be broken or reference something that doesn't exist yet. This is the hard ordering constraint, not just a nice-to-have.
3. **Iterative & dependency-ordered** — sequence commits so each one is a small step that could stand alone, and later commits only ever build on capabilities already present from earlier commits in the plan.
4. **Developer stays in control** — always write the full plan out in chat (files + exact hunks per commit + commit message) *before* staging anything, and let the developer confirm or adjust before any `git add`/`git commit` runs.
5. **Clean history** — imperative, concise commit messages (`area: what changed`), no "wip"/"fix typo"/"oops" follow-ups. Get each commit right by planning first, not by amending after the fact.

## Procedure

### 1. Gather full context
```bash
git status
git diff --stat && git diff --cached --stat
git log --oneline -10          # match the existing message style/convention
```
Read the actual diffs (`git diff`, `git diff --cached`), not just filenames — grouping decisions depend on *what* changed, not which files changed.

### 2. Identify logical units
- Group by capability/concern, not by file. One file can span multiple commits (via hunks); one commit can span multiple files if they're only meaningful together.
- For each candidate unit, ask: "if I reverted only this commit, would it cleanly undo one specific thing?" If not, split further.

### 3. Order by dependency
Build a dependency graph of units (does unit B reference/require something unit A introduces?). Topologically sort so:
- New files/content that other changes reference come before those references.
- A consumer-facing change never lands before the capability it depends on exists.

### 4. Write the plan
Present in chat using the **Plan Output Format** below, in full, before touching git.

### 5. Get confirmation
Ask the developer to confirm or request changes to grouping/order/messages before staging anything.

### 6. Stage and commit one unit at a time
- Whole new/changed file → `git add <path>`.
- Only part of a file's changes → hunk-level staging (see below). Never `git add -A`/`git add .` when a file needs to be split across commits.
- Commit immediately: `git commit -m "<message>"`.
- Verify before moving on: `git status` + `git diff --cached` (should show only this unit) + a quick build/eval/test check when feasible (e.g. `nix flake show`, test suite, linter).

### 7. Repeat until the plan is fully applied.

## Plan Output Format

```
### Commit <n>: <imperative message>
**Files:** <path>[, <path>...]
**Hunks:** whole file(s) | specific hunk(s) — describe the exact lines/marker text if a file is split
**Why atomic:** <the one thing this commit does>
**Depends on:** commit <n-1> (or "none")
**Stage with:** <exact command(s)>
```

## Hunk-Level Staging Technique

When a single file must be split across commits:
- **Interactive (developer, in their own terminal):** `git add -p <file>` → for each printed hunk, `y` to stage / `n` to skip / `s` to split further if the hunk mixes unrelated changes / `e` to manually edit the hunk boundary. Identify which hunk belongs to which commit by matching the surrounding code/comments described in the plan.
- **Deterministic (scripted/agent execution, no TTY):** reconstruct the file's *intermediate* content for each commit (i.e., write the file as it should look at that point in history — base content + only that commit's addition), `git add <file>`, commit, then write the next intermediate version and repeat until the file matches its final state on the last commit touching it. This avoids interactive prompts entirely and is exactly reproducible.

## Anti-patterns
- Committing "everything so far" in one shot because splitting feels slower — defeats the entire purpose.
- A commit that only makes sense combined with a later one (project doesn't evaluate/build/pass tests at that point).
- Grouping by file instead of by concern when a file contains two unrelated additions.
- Skipping the confirmation step and staging/committing before the developer has seen the plan.
