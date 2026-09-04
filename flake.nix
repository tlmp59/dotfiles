{
  description = "A modular NixOs system built for the road";

  outputs = {nixpkgs, ...}: let
    inherit (nixpkgs) lib legacyPackages;
    util = import ./lib lib;
  in {
    inherit util;

    nixosModules = util.mkModuleTree ./modules/nixos;

    darwinModules = util.mkModuleTree ./modules/darwin;

    homeModules = util.mkModuleTree ./modules/home;

    # Used by `nix develop .#<name>`
    devShells = util.forAllSystems (system: import ./shells legacyPackages.${system});

    # Set formatter used by `nix fmt`
    formatter = util.forAllSystems (system: legacyPackages.${system}.nixfmt);

    # Used by `nix flake init -t <flake>`
    templates = import ./templates lib;
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
