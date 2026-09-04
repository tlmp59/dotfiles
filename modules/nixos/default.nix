{
  inputs,
  lib,
  ...
}: {
  imports =
    [
      ../. # Global configs
      ./networking.nix
      ./users.nix
      ./packages.nix
    ]
    ++ lib.optional
    (inputs ? "home-manager")
    inputs.home-manager.nixosModules.home-manager;
}
