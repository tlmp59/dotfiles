{...}: {
  M.sops.enable = true;

  M.dotfiles = {
    enable = true;
    url = "git+ssh://git@github.com/d3vnrd/dotfiles.git?ref=main&shallow=1";
  };

  home.stateVersion = "26.11";
}
