{config, ...}: {
  programs.emacs.enable = true;

  home.file.".config/doom" = {
    source =
      config.lib.file.mkOutOfStoreSymlink
      "${config.M.dotfiles.path}/doom";

    enable = config.M.dotfiles.enable;
  };
}
