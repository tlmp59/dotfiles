{
  description = "A modular NixOs system built for the road";

  outputs = {nixpkgs, ...} @ inputs: let
    inherit (nixpkgs) lib;
    ulib = import ./lib.nix lib;
    pkgs = nixpkgs.legacyPackages;

    forAllSystems = lib.genAttrs [
      /*
      Self-maintained system architectures, for a full list of current
      supported architectures consider using `lib.systems.flakeExposed`
      (experimental)
      */
      "x86_64-linux"
    ];
  in
    lib.mergeAttrsList [
      # Per-host outputs: NixOS, home-manager, and nix-darwin configs
      (import ./host {inherit inputs ulib;})

      {
        # Used by `nix develop .#<name>`
        devShells = forAllSystems (
          system: import ./shell.nix pkgs.${system}
        );

        # Set formatter used by `nix fmt`
        formatter = forAllSystems (
          system: pkgs.${system}.nixfmt
        );
      }
    ];

  inputs = {
    # Default to use unstable packages (current stable version 26.05)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
  };
}
