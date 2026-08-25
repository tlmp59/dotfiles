{
  config,
  lib,
  pkgs,
  ...
}: {
  options.M.pkgs = {
    enableDefault = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable default user packages.";
    };

    add = lib.mkOption {
      type = with lib.types; listOf package;
      default = [];
      description = "Additional user packages.";
    };
  };

  home.packages = lib.flatten [
    (lib.optionals config.M.pkgs.enableDefault (with pkgs; [
      ripgrep
      pandoc
      fzf
    ]))

    config.M.pkgs.add
  ];
}
