{
  inputs,
  lib,
  ...
}: {
  imports = lib.flatten [
    ../. # Global configs
    (inputs.self.util.importModules ./.)
    (
      lib.optional (inputs ? home-manager)
      inputs.home-manager.nixosModules.home-manager
    )
  ];

  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  services.openssh.enable = lib.mkDefault true;
}
