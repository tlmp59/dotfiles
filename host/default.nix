{
  inputs,
  ulib,
  ...
} @ args: let
  # 'self' arg is auto injected by nix as a reference to 'outputs' attrset
  inherit (inputs) self nixpkgs home-manager;
  inherit (nixpkgs) lib;

  mkHosts = {
    builder,
    entries,
    extraModules ? [],
  }:
    ulib.mergeAttrsNoOverride (
      map (
        system:
          lib.genAttrs (ulib.scanPath.dirs ./host/${system}) (
            hostname:
              builder {
                inherit system;
                specialArgs = args // {inherit hostname;};
                modules = lib.flatten [
                  self.nixosModules.default
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
      self.nixosModules.nixos
    ];
  };

  # darwinConfigurations = mkHosts {
  #   builder = nix-darwin.lib.darwinSystem;
  #   entries = ulib.hostSystems.darwin;
  # };
}
