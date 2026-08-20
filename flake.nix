{
  description = "A modular NixOs system built for the road";

  outputs = {nixpkgs, ...} @ inputs: let
    inherit (nixpkgs) lib;
    pkgs = nixpkgs.legacyPackages;

    _internal = {
      lib = import ./lib.nix lib;
      paths = {
        hostRoot = ./host;
        moduleRoot = ./module;
        shells = ./shell.nix;
      };
    };
  in
    {
      # Exposed as attr within `self`
      inherit _internal;

      # Used by `nix develop .#<name>`
      devShells = _internal.lib.forAllSystems (
        system: import _internal.paths.shells pkgs.${system}
      );

      # Set formatter used by `nix fmt`
      formatter = _internal.lib.forAllSystems (
        system: pkgs.${system}.nixfmt
      );
    }
    /*
    No need for merge-no-override here, as long as ./host/default.nix only
    return os-specific configs
    */
    // (import _internal.paths.hostRoot inputs);

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

    import-tree.url = "github:vic/import-tree";
  };
}
