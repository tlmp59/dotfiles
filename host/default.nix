{
  inputs,
  hostSystems,
  ...
}: let
  inherit (inputs) self nixpkgs;
  inherit (self) _lib _paths;
  inherit (nixpkgs) lib;

  mkHosts = {
    builder,
    entries,
    modules ? [],
  }:
    _lib.mergeAttrsNoOverride (
      map (
        system:
          lib.genAttrs (_lib.scanPath.dirs (_paths.toHost + "/${system}")) (
            hostname:
              builder {
                inherit system modules;
                specialArgs = {inherit inputs hostname;};
              }
          )
      )
      entries
    );

  mkHome = {}: {};
in {
  nixosConfigurations = mkHosts {
    builder = lib.nixosSystem;
    entries = hostSystems.linux;
    modules = [
      self.nixosModules.default
    ];
  };
}
