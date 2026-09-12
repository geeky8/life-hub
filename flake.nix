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
      });
}
