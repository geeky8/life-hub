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
        # from. Only the named skill subfolders are touched, so any
        # project-local custom skills placed alongside them are left
        # alone. Re-run after `nix flake update life-hub` to sync.
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
              echo "done. skills synced into $target/"
            '';
          }}/bin/sync-skills";
        };
}
