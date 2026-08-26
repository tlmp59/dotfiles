{
  inputs,
  lib,
  ...
}: {
  imports = lib.flatten [
    ../. # Global configs
    (
      lib.optional (inputs ? home-manager)
      inputs.home-manager.nixosModules.home-manager
    )
  ];

  services.openssh.enable = lib.mkDefault true;
}
