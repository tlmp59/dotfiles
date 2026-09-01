{inputs, ...}: let
  inherit (inputs) self;

  modules = self.nixosModules;
in {
  imports = [
    modules.boot # require hardware-configuration
  ];
}
