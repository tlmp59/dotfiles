{
  inputs,
  lib,
  ...
}: {
  imports = lib.flatten [
    ../.
    (inputs.self.util.importModules ./.)
    (
      lib.optional (inputs ? home-manager)
      inputs.home-manager.darwinModules.home-manager
    )
  ];

  homebrew.enable = lib.mkDefault true;
  homebrew.onActivation.cleanup = "zap";
}
