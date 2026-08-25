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
    defaultModule ? {...}: {},
  }:
    util.mergeAttrsNoOverride (
      map (
        system:
          lib.genAttrs (util.scanPath.subDirs ./${system}) (
            hostname: let
              dir = ./${system}/${hostname};
              configuration = dir + "/configuration.nix";
              hardware = dir + "/hardware-configuration.nix";
              modules = lib.flatten [
                defaultModule
                (lib.optional (builtins.pathExists hardware) hardware)
                (lib.optional (builtins.pathExists configuration) configuration)
              ];
            in
              builder {
                inherit system modules;
                specialArgs = {inherit inputs system hostname;};
              }
          )
      )
      entries
    );
in {
  nixosConfigurations = mkHosts {
    builder = lib.nixosSystem;
    entries = supported.linux;
    defaultModule = self.nixosModules.default;
  };
}
