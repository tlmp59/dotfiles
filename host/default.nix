{
  self,
  nixpkgs,
  home-manager,
  ...
} @ inputs: let
  inherit (nixpkgs) lib;
  ulib = self._internal.lib;
  myModules = import self._internal.paths.moduleRoot;

  mkHosts = {
    builder,
    entries,
    extraModules ? [],
  }:
    ulib.mergeAttrsNoOverride (
      map (
        system:
          lib.genAttrs (ulib.scanPath.dirs ./${system}) (
            hostname:
              builder {
                inherit system;
                specialArgs = {inherit inputs hostname;};
                modules = lib.flatten [
                  myModules.base
                  extraModules
                ];
              }
          )
      )
      entries
    );
in {
  nixosConfigurations = mkHosts {
    builder = lib.nixosSystem;
    entries = ulib.hostSystems.nixos;
    extraModules = [
      home-manager.nixosModules.home-manager
      myModules.nixos
    ];
  };
}
