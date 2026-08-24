{
  inputs,
  lib,
  ...
}: {
  imports = lib.flatten [
    (inputs.self._lib.scanPath.importModules ./.)
    (
      lib.optional (inputs ? home-manager)
      inputs.home-manager.darwinModules.home-manager
    )
  ];

  homebrew.enable = lib.mkDefault true;
  homebrew.onActivation.cleanup = "zap";
}
