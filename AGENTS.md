# Agent Instructions — life-hub

life-hub is the central source of coding-agent skills (`skills/<name>/SKILL.md`)
and Nix devShells, consumed by other projects via
`nix run github:geeky8/life-hub#bootstrap` (new projects) and
`nix run .#sync-skills` (refresh).

## Before starting any task here
Check `skills/*/SKILL.md` frontmatter (`name` + `description`) for a skill whose
"Use when..." trigger matches the current request, and follow its procedure —
don't wait to be asked by name.

## Skills in this hub
| Skill | Use when |
|---|---|
| `planning` | Starting any non-trivial task — state assumptions, draft a numbered plan, wait for approval before editing code |
| `code-review` | Reviewing a file/diff/PR, or before committing non-trivial changes |
| `commit-planner` | Splitting accumulated staged/unstaged changes into atomic, always-buildable commits |
| `knowledge-base` | A non-obvious technical nuance, gotcha, or root-cause is discovered that's worth recording for later |
| `token-optimizer` | Long sessions, large files/repos, or context-window pressure |

## Editing a skill
Consumer projects only see **committed** state — `github:`/`git+file:` flake
inputs resolve against git history, not the working tree. After editing a
skill: commit and push, then downstream projects pick it up via
`nix flake update life-hub && nix run .#sync-skills`.
