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
    entries ? [],
    defaultConfigs ? {...}: {},
  }:
    _lib.mergeAttrsNoOverride (
      map (
        system:
          lib.genAttrs (_lib.scanPath.dirs (_paths.toHost + "/${system}")) (
            hostname: let
              hostPaths = _paths.toConfigs system hostname;
            in
              builder {
                inherit system;
                specialArgs = {inherit inputs hostname;};
                modules = lib.flatten [
                  defaultConfigs

                  #TODO: double check on this, currently a bit wierd on implementation
                  (lib.optional (builtins.pathExists hostPaths.hardware) hostPaths.hardware)
                  (lib.optional (builtins.pathExists hostPaths.host) hostPaths.host)
                ];
              }
          )
      )
      entries
    );
in {
  nixosConfigurations = mkHosts {
    builder = lib.nixosSystem;
    entries = hostSystems.linux;
    defaultConfigs = self.nixosModules.default;
  };
}
