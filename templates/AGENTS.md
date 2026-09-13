# Agent Instructions

This project's coding-agent skills are synced from the central
[life-hub](https://github.com/geeky8/life-hub) repo into
`.github/skills/<name>/SKILL.md` (kept current with `nix run .#sync-skills`
after `nix flake update life-hub`).

## Before starting any task
Check `.github/skills/*/SKILL.md` frontmatter (`name` + `description`) for a
skill whose "Use when..." trigger matches the current request, and follow its
procedure — don't wait to be asked by name.

## Available skills (life-hub-sourced)
| Skill | Use when |
|---|---|
| `planning` | Starting any non-trivial task — state assumptions, draft a numbered plan, wait for approval before editing code |
| `code-review` | Reviewing a file/diff/PR, or before committing non-trivial changes |
| `commit-planner` | Splitting accumulated staged/unstaged changes into atomic, always-buildable commits |
| `knowledge-base` | A non-obvious technical nuance, gotcha, or root-cause is discovered that's worth recording for later |
| `token-optimizer` | Long sessions, large files/repos, or context-window pressure |

Project-local skills, if any, can live alongside these under
`.github/skills/` — `sync-skills` only touches the hub-named folders above and
leaves everything else untouched.
