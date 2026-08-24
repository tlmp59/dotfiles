{
  inputs,
  supported,
  ...
}: let
  inherit (inputs) self nixpkgs;
  inherit (self) util;
  inherit (nixpkgs) lib;

  mkHosts = {
    builder,
    entries ? [],
    modules ? {...}: {},
  }:
    util.mergeAttrsNoOverride (
      map (
        system:
          lib.genAttrs (util.scanPath.dirs ./${system}) (
            hostname: let
              dir = ./${system}/${hostname};
              configuration = dir + "/configuration.nix";
              hardware = dir + "/hardware-configuration.nix";
            in
              builder {
                inherit system;
                specialArgs = {inherit inputs system hostname;};
                modules =
                  [modules]
                  ++ lib.optional (builtins.pathExists hardware) hardware
                  ++ lib.optional (builtins.pathExists configuration) configuration;
              }
          )
      )
      entries
    );
in {
  nixosConfigurations = mkHosts {
    builder = lib.nixosSystem;
    entries = supported.linux;
    modules = self.nixosModules.default;
  };
}
