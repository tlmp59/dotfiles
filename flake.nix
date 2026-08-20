{
  description = "A modular NixOs system built for the road";

  outputs = {nixpkgs, ...} @ inputs: let
    pkgs = nixpkgs.legacyPackages;
    ulib = import ./lib.nix nixpkgs.lib;
  in
    {
      # Reusable modules access through self.nixosModules.<name>
      nixosModules = {
        default = ./module;
        nixos = ./module/nixos;
        darwin = ./module/darwin;
      };

      # Used by `nix develop .#<name>`
      devShells = ulib.forAllSystems (
        system: import ./shell.nix pkgs.${system}
      );

      # Set formatter used by `nix fmt`
      formatter = ulib.forAllSystems (
        system: pkgs.${system}.nixfmt
      );
    }
    /*
    No need for merge-no-override here, as long as ./host/default.nix only
    return os-specific configs
    */
    // (import ./host {inherit inputs ulib;});

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
