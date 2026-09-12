---
name: code-review
description: 'Perform a structured code review covering correctness, security (OWASP Top 10), style/consistency, performance, and test coverage. Use when the user asks to "review this code", "review my PR/diff", check a file/change before committing, or requests a security or quality pass over recent edits.'
---

# Code Review

## When to Use
- User asks for a review of a file, diff, PR, or recent changes.
- Before committing/pushing non-trivial changes, if the user requests a sanity pass.
- User asks specifically about security, performance, or style issues in code.

## Procedure

1. **Scope the review** — identify exactly which files/diff/PR are in scope. If unclear, ask rather than reviewing the whole repo.
2. **Read before judging** — read the full surrounding context of each changed function/file, not just the diff hunk, so feedback isn't based on a partial view.
3. **Check in this order**:
   - **Correctness**: logic errors, edge cases, off-by-one, null/undefined handling, incorrect assumptions about inputs.
   - **Security (OWASP Top 10)**: injection (SQL/command/template), broken auth/access control, sensitive data exposure, insecure deserialization, missing input validation/output encoding, hardcoded secrets, SSRF, unsafe dependency usage.
   - **Error handling**: only flag missing handling for scenarios that can actually occur — don't ask for defensive code around impossible cases.
   - **Style/consistency**: matches existing repo conventions (naming, formatting, patterns already in use nearby).
   - **Performance**: obvious inefficiencies (N+1 queries, unnecessary loops/copies, blocking calls in hot paths) — do not micro-optimize speculatively.
   - **Test coverage**: are the changed behaviors covered? Flag missing tests for new logic/bug fixes, not for unrelated code.
4. **Classify each finding** by severity: `blocker` (must fix — bug/security), `should-fix` (real issue, not urgent), `nit` (style/preference, optional).
5. **Report concisely** using the output format below. Do not rewrite the whole file unless asked — propose specific fixes for blockers/should-fix items only.

## Output Format

```
### Review Summary
<1-2 sentence overall assessment>

### Blockers
- [file:line] <issue> — <why it matters> — <suggested fix>

### Should Fix
- [file:line] <issue> — <suggested fix>

### Nits
- [file:line] <issue>

### Test Coverage
<gaps found, or "adequate">
```

If there are no blockers/should-fix items, say so explicitly instead of inventing nits to fill the section.

## Anti-patterns to Avoid
- Don't flag style preferences as blockers.
- Don't request speculative error handling, extra abstractions, or refactors beyond the reviewed scope.
- Don't approve silently — always state what was checked, even if the answer is "looks good."
