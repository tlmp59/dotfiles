{
  inputs,
  hostSystems,
  ...
}: let
  inherit (inputs) self nixpkgs;
  inherit (nixpkgs) lib;
  inherit (self) _lib _paths;

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
in {
  nixosConfigurations = mkHosts {
    builder = lib.nixosSystem;
    entries = hostSystems.linux;
    modules = [
      self.nixosModules.default
    ];
  };
}
