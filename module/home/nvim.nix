{config, ...}: let
  cfg = config.M;
in {
  programs.neovim.enable = true;

  home.file.".config/nvim" = {
    source =
      config.lib.file.mkOutOfStoreSymlink
      "${cfg.dotfiles.path}/nvim";

    enable = cfg.dotfiles.enable;
  };
}
