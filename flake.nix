{
  description = "A modular NixOs system built for the road";

  outputs = {nixpkgs, ...} @ inputs: let
    inherit (nixpkgs) lib;
    pkgs = nixpkgs.legacyPackages;

    _paths = {
      toHost = ./host;
      toPresets = ./presets;
      toLib = ./lib.nix;
      toShells = ./shell.nix;
      toConfigs = system: hostname: let
        dir = ./host/${system}/${hostname};
      in {
        host = dir;
        user = dir + "/home.nix";
        hardware = dir + "/hardware-configuration.nix";
      };
    };

    _lib = import _paths.toLib lib;

    _presets = import _paths.toPresets; # collection of predefined configurations

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
        default = _presets.nixos.default;
      };

      darwinModules = {
        default = _presets.darwin.default;
      };

      homeModules.default = _presets.home;

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
  };
}
