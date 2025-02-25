{
  description = "A basic flake with a shell";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  inputs.systems.url = "github:nix-systems/default";
  inputs.flake-utils = {
    url = "github:numtide/flake-utils";
    inputs.systems.follows = "systems";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell { packages = with pkgs; [ (php81.buildEnv {
          extensions = ({ enabled, all }: enabled ++ (with all; [
            xdebug
          ]));
          extraConfig = ''
            xdebug.mode=debug
          '';
        }) 
        php81Packages.composer 
        ]; };
      }
    );
}
