{
  description = "A modular NixOs system built for the road";

  outputs = {nixpkgs, ...} @ inputs: let
    inherit (nixpkgs) lib;
    pkgs = nixpkgs.legacyPackages;

    _paths = {
      toHost = ./host;
      toModule = ./module;
      toLib = ./lib.nix;
      toShells = ./shell.nix;
    };

    _lib = import _paths.toLib lib;

    _modules = import _paths.toModule;

    # Return attrset contains all valid supported systems
    hostSystems = let
      classify = entries: let
        doublesByOs = {
          inherit (lib.systems.doubles) linux darwin;
        };

        matched =
          builtins.mapAttrs (
            _: doubles:
              builtins.filter
              (s: builtins.elem s doubles)
              entries
          )
          doublesByOs;

        all = lib.flatten (lib.attrValues matched);
        invalid = lib.subtractLists entries all;
      in
        lib.warnIf (invalid != [])
        "Skipping invalid system dir(s): ${builtins.concatStringsSep ", " invalid}"
        (matched // {inherit all;});
    in
      classify (_lib.scanPath.dirs _paths.toHost);

    forAllSystems = func: lib.genAttrs hostSystems.all func;
  in
    {
      # Exposed as attrs to access with `self.<attr>`
      inherit _paths _lib;

      # Preset configs for outside flake use
      nixosModules = {
        default = _modules.nixos;
      };

      darwinModules = {
        default = _modules.darwin;
      };

      homeModules.default = _modules.home;

      # Used by `nix develop .#<name>`
      devShells = forAllSystems (
        system: import _paths.toShells pkgs.${system}
      );

      # Set formatter used by `nix fmt`
      formatter = forAllSystems (
        system: pkgs.${system}.nixfmt
      );
    }
    /*
    No need for merge-no-override here, as long as ./host/default.nix only
    return os-specific configs
    */
    // (import _paths.toHost {inherit inputs hostSystems;});

  inputs = {
    # Default to use unstable packages (current stable version 26.05)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    import-tree.url = "github:vic/import-tree";
  };
}
