{config, ...}: {
  programs.neovim.enable = true;

  home.file.".config/nvim" = {
    source =
      config.lib.file.mkOutOfStoreSymlink
      "${config.M.dotfiles.path}/nvim";

    enable = config.M.dotfiles.enable;
  };
}
