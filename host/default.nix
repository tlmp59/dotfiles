{
  inputs,
  ulib,
  ...
}: let
  inherit (inputs) nixpkgs home-manager;
  inherit (nixpkgs) lib;

  mkNixOs = {
    hostname ? "nixos",
    system ? "x86_64-linux",
    modules ? {},
  }: {
    ${hostname} = nixpkgs.lib.nixosSystem {
      inherit system;
    };
  };

  mkDarwin = {};
in
  with lib; {
    nixosConfigurations = mergeAttrsList [
      (mkNixOs {hostname = "wsl";})
    ];

    homeConfigurations = {};
  }
