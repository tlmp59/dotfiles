{
  description = "Minimal flake for bootstraping NixOs systems";

  outputs = {nixpkgs, ...}: let
    inherit (nixpkgs) lib;

    supported = [
      "x86_64-linux"
    ];

    mkIso = system:
      lib.nixosSystem {
        inherit system;

        modules = [
          ({modulesPath, ...}: {
            imports = lib.flatten [
              "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
            ];
          })
        ];
      };
  in {
    #TODO: create a function to allow iso creation with options wihout specify
    #them within this flake
    #TODO: specify the scope of this flake, decide whether it should focus on
    #being a minimal flake for boostraping or general Iso
    nixosConfigurations = builtins.listToAttrs (
      map (system: {
        name = "iso-${system}";
        value = mkIso system;
      })
      supported
    );
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
