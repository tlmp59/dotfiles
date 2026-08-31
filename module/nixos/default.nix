{
  inputs,
  lib,
  ...
}: {
  imports = lib.flatten [
    ../. # Global configs
    ./networking.nix
    ./users.nix
    ./packages.nix

    (
      lib.optional (inputs ? home-manager)
      inputs.home-manager.nixosModules.home-manager
    )
  ];
}
