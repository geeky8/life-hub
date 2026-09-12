{
  # ---------------------------------------------------------------------
  # PROJECT BLUEPRINT
  # Copy this file into the root of any new project as `flake.nix`.
  # It pulls its devShells directly from the central life-hub repo, so
  # running `nix flake update` in the project pulls in new hub changes.
  #
  # ⚠️  REPLACE THE PLACEHOLDER BELOW:
  #     - Linux/NixOS:  git+file:///home/YOUR_USERNAME/life-hub
  #     - macOS:        git+file:///Users/YOUR_USERNAME/life-hub
  # ---------------------------------------------------------------------
  description = "Example project - inherits tools from the central life-hub";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    life-hub.url = "git+file:///home/YOUR_USERNAME/life-hub";
  };

  outputs = { self, nixpkgs, flake-utils, life-hub }:
    flake-utils.lib.eachDefaultSystem (system:
      {
        # Resolves cleanly: `nix develop` in this project now gives you
        # the hub's unified (general + mcp) devShell for this system.
        devShells.default = life-hub.devShells.${system}.default;

        # Optional: expose the individual hub shells too, in case a
        # project only wants one half of the toolset.
        devShells.general = life-hub.devShells.${system}.general;
        devShells.mcp = life-hub.devShells.${system}.mcp;

        # Forwards the hub's skill-sync app so you can just run
        # `nix run .#sync-skills` from inside this project (instead of
        # typing the full life-hub flake reference each time). Copies
        # life-hub/skills/* into ./.github/skills/* of this project.
        apps.sync-skills = life-hub.apps.${system}.sync-skills;
      });
}
