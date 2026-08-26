{config, ...}: let
  cfg = config.M;
in {
  programs.emacs.enable = true;

  home.file.".config/doom" = {
    source =
      config.lib.file.mkOutOfStoreSymlink
      "${cfg.dotfiles.path}/doom";

    enable = cfg.dotfiles.enable;
  };
}
