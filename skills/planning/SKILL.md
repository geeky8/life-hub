---
name: planning
description: 'Enforces a structured planning workflow before implementation: states assumptions and open questions, presents a numbered step-by-step plan, and waits for explicit user approval before editing any code. Maintains a live TODO/checklist during execution and reports deviations from the plan. Use when starting any coding task, before making multi-step or multi-file changes, or when the user says "plan this out", "let'\''s plan first", or similar.'
---

# Planning (User's Terms)

This skill overrides the default "just implement it" behavior. When active, **no code is edited until the user has explicitly approved a plan.**

## When to Use
- At the start of any non-trivial task (new feature, bug fix touching more than one place, refactor, setup/config change).
- Whenever the user explicitly asks to plan first.
- Skip only for genuinely trivial one-line/one-fact requests (e.g. "what does this function return?") — when in doubt, plan.

## Procedure

### 0. Bootstrap the Nix devShell (new projects only — compulsory)
If the task is starting a **new project in a directory that has zero files created yet**, before anything else — including before drafting the plan in step 3 — set up the project's Nix devShell and direnv wiring. This is not optional and is not part of the negotiable plan; do it, then continue with steps 1+ for the actual feature work.

- Create `flake.nix` and `.envrc` at the project root, wired to the central life-hub, either by:
  - running `nix run github:geeky8/life-hub#bootstrap` (or the local path equivalent) in the project directory, or
  - copying [templates/flake.nix](../../templates/flake.nix) and life-hub's `templates/.envrc` by hand if `bootstrap` isn't available.
- Run `direnv allow` so the shell auto-loads (mention this to the user if direnv isn't installed/hooked into their shell yet).
- Edit the copied `flake.nix`'s `devShells` so it actually contains the toolchain/runtime this specific project needs (language, package manager, formatters, etc.) — don't leave it as the generic example.
- Never tell the user to `brew install` / `npm install -g` / `pip install --user` etc. for project tooling — add it to the devShell instead. Every dependency the project needs to build/run/test must be reachable by entering the devShell, nothing installed globally.
- As the project grows and needs new tools or runtimes, update `flake.nix`'s `devShells` accordingly as part of whatever step introduces that dependency — keeping the flake current is an ongoing obligation for the life of the project, not a one-time setup.

### 1. Restate the goal
One or two sentences confirming what is being asked, in your own words.

### 2. List assumptions and open questions
- **Assumptions**: anything you're inferring that wasn't stated explicitly (file locations, libraries, behavior on edge cases).
- **Open questions**: anything genuinely ambiguous that changes the approach. If there are blocking questions, ask them before drafting the plan. If assumptions are reasonable and low-risk, state them and proceed.

### 3. Draft the plan
Present as a numbered checklist, each step small enough to verify independently:

```
Plan:
1. [ ] <step> — <file(s)/area affected>
2. [ ] <step> — <file(s)/area affected>
...
Assumptions: <bullet list, or "none">
Open questions: <bullet list, or "none">
```

### 4. Wait for explicit approval
Do not start editing until the user responds with approval (e.g. "yes", "go ahead", "looks good"). If the user requests changes to the plan, revise and re-present before proceeding. Do not treat silence or an unrelated follow-up as approval.

### 5. Execute with a live checklist
As each step completes, update the checklist status (`[ ]` → `[x]`) and surface it when reporting progress, especially for multi-step tasks. If a step turns out to need a different approach than planned, say so explicitly before continuing — don't silently deviate.

### 6. Close out
Summarize what was done against the original plan, and call out anything that ended up different from what was approved.

## Notes
- This is stricter than default agent behavior — it intentionally trades some speed for predictability and control. Apply it whenever this skill is invoked or implied by context.
- Keep plans concise; a plan is a tool for alignment, not documentation — don't over-specify trivial steps.
