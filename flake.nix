{
  description = "life-hub: centralized dev environment for coding-agent skills & MCP servers";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells = {
          # a) Framework-agnostic agent core tools.
          general = pkgs.mkShell {
            name = "life-hub-general";
            packages = with pkgs; [
              git
              ripgrep
              fd
              jq
              tokei
            ];
          };

          # b) Environments for running Model Context Protocol servers.
          mcp = pkgs.mkShell {
            name = "life-hub-mcp";
            packages = with pkgs; [
              nodejs_20
              python311
              curl
            ];
          };

          # Unified shell: merges general + mcp via inputsFrom so both
          # toolsets are available together (see task 3 below).
          default = pkgs.mkShell {
            name = "life-hub-unified";
            inputsFrom = [
              self.devShells.${system}.general
              self.devShells.${system}.mcp
            ];
          };
        };

        # `nix run <hub>#sync-skills` (or `nix run .#sync-skills` once
        # forwarded by a consumer's own flake) copies this hub's skills/
        # into ./.github/skills/<name> of whatever directory it's run
        # from, and also refreshes ./AGENTS.md from templates/AGENTS.md.
        # Only the named skill subfolders + AGENTS.md are touched, so any
        # project-local custom skills placed alongside them are left
        # alone. NOTE: AGENTS.md is fully overwritten every run (hub-owned,
        # like skills/) — don't hand-edit it in a project if you plan to
        # keep re-running this. Re-run after `nix flake update life-hub`
        # to pick up the latest hub commit.
        apps.sync-skills = {
          type = "app";
          program = "${pkgs.writeShellApplication {
            name = "sync-skills";
            runtimeInputs = [ pkgs.rsync ];
            text = ''
              set -euo pipefail
              hub_skills="${self}/skills"
              target="''${1:-.github/skills}"
              mkdir -p "$target"
              for skill_dir in "$hub_skills"/*/; do
                name="$(basename "$skill_dir")"
                mkdir -p "$target/$name"
                rsync -a --delete --chmod=u+w "$skill_dir" "$target/$name/"
                echo "synced: $target/$name"
              done
              cp "${self}/templates/AGENTS.md" ./AGENTS.md
              echo "synced: AGENTS.md"
              echo "done. skills synced into $target/, AGENTS.md refreshed."
            '';
          }}/bin/sync-skills";
        };

        # One-shot setup for a NEW or EXISTING project directory:
        # `nix run <hub>#bootstrap` — drops in flake.nix + .envrc (only if
        # not already present, so it never clobbers an existing project's
        # own files), points flake.nix at this hub, runs `direnv allow` if
        # direnv is installed, and syncs skills + AGENTS.md (AGENTS.md is
        # always (re)written here too — see apps.sync-skills for the
        # ongoing-refresh path used after `nix flake update life-hub`).
        # Override the hub location with LIFE_HUB_URL if needed, e.g.
        # LIFE_HUB_URL="github:you/life-hub" nix run .../life-hub#bootstrap
        apps.bootstrap = {
          type = "app";
          program = "${pkgs.writeShellApplication {
            name = "bootstrap";
            runtimeInputs = [ pkgs.rsync ];
            text = ''
              set -euo pipefail
              hub_url="''${LIFE_HUB_URL:-github:geeky8/life-hub}"
              target_dir="''${1:-.}"
              cd "$target_dir"

              if [ -f flake.nix ]; then
                echo "flake.nix already exists here — leaving it as-is."
                echo "  (add life-hub as an input manually if you want to merge it in)"
              else
                cp "${self}/templates/flake.nix" ./flake.nix
                sed -i.bak "s#life-hub.url = \"github:geeky8/life-hub\";#life-hub.url = \"$hub_url\";#" ./flake.nix
                rm -f ./flake.nix.bak
                echo "created flake.nix -> life-hub: $hub_url"
              fi

              if [ -f .envrc ]; then
                echo ".envrc already exists here — leaving it as-is."
              else
                cp "${self}/templates/.envrc" ./.envrc
                echo "created .envrc"
              fi

              if [ -f AGENTS.md ]; then
                echo "AGENTS.md already exists here — leaving it as-is."
              else
                cp "${self}/templates/AGENTS.md" ./AGENTS.md
                echo "created AGENTS.md"
              fi

              if command -v direnv >/dev/null 2>&1; then
                direnv allow . || true
              fi

              mkdir -p .github/skills
              for skill_dir in "${self}/skills"/*/; do
                name="$(basename "$skill_dir")"
                mkdir -p ".github/skills/$name"
                rsync -a --delete --chmod=u+w "$skill_dir" ".github/skills/$name/"
              done
              echo "synced skills into .github/skills/"
              echo "bootstrap complete. run 'nix develop' (or cd back in, if using direnv)."
            '';
          }}/bin/bootstrap";
        };
      }) // {
        # `nix flake init -t git+file:///Users/YOU/life-hub` (or the
        # github: url once pushed) scaffolds flake.nix + .envrc into an
        # empty/new directory directly from Nix itself, no hub-specific
        # app required. Note: you still need to hand-edit the
        # YOUR_USERNAME placeholder afterwards — `bootstrap` above does
        # that substitution for you automatically.
        templates.default = {
          path = ./templates;
          description = "life-hub project starter: flake.nix + .envrc";
        };
      };
}
