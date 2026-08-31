{
  description = "A modular NixOs system built for the road";

  outputs = {nixpkgs, ...} @ inputs: let
    inherit (nixpkgs) lib;
    pkgs = nixpkgs.legacyPackages;
    util = import ./util.nix lib;

    # Return attrset contains all valid supported systems
    supported = let
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
      classify (util.scanPath.subDirs ./host);

    forAllSystems = func: lib.genAttrs supported.all func;
  in
    {
      inherit util;

      nixosModules = util.mkModuleTree ./module/nixos;

      darwinModules = util.mkModuleTree ./module/darwin;

      # `nix eval .#homeModules` to check
      homeModules = util.mkModuleTree ./module/home;

      # Used by `nix develop .#<name>`
      devShells = forAllSystems (system: import ./shell.nix pkgs.${system});

      # Set formatter used by `nix fmt`
      formatter = forAllSystems (system: pkgs.${system}.nixfmt);
    }
    /*
    No need for merge-no-override here, as long as ./host/default.nix only
    return {nixosConfigurations = ...; darwinConfigurations = ...;}
    */
    // (import ./host {inherit inputs supported;});

  inputs = {
    # Default to use unstable packages (current stable version 26.05)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    secrets = {
      url = "git+ssh://git@github.com/d3vnrd/nix-secrets.git?ref=main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
