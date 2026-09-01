{
  config,
  lib,
  pkgs,
  ...
}: {
  options.M.enableDefaultPkgs = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable default user packages.";
  };

  home.packages = lib.optionals config.M.enableDefaultPkgs (with pkgs; [
    ripgrep
    pandoc
    fzf
  ]);
}
