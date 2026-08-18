{
  inputs,
  ulib,
  ...
}: let
  inherit (inputs) nixpkgs home-manager;
  inherit (nixpkgs) lib;

  mkNixOs = {
    system ? "x86_64-linux",
    modules ? {},
  }:
    nixpkgs.lib.nixosSystem {
      inherit system;
    };
in
  with lib; {
    nixosConfigurations = {
      wsl = mkNixOs;
    };

    homeConfigurations = {};
  }
