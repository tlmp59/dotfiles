{lib, ...}: {
  programs = {
    zoxide = {
      enable = true;
      enableBashIntegration = true;
    };

    fzf = {
      enable = true;
      enableBashIntegration = true;
    };

    yazi = {
      enable = true;
      settings = {
        mgr = {
          ratio = [0 3 5];
          show_hidden = true;
          sort_by = "extension";
          sort_dir_first = true;
          show_symlink = true;
        };
      };
      enableBashIntegration = true;
    };

    lazygit = {
      enable = true;
    };

    starship = {
      enable = true;
      settings = lib.mkForce {
        add_newline = true;
        scan_timeout = 10;
      };
      enableBashIntegration = true;
    };

    zellij = {
      enable = true;
      settings = lib.mkForce {
        theme = "kanagawa";
        simplified_ui = true;
        default_layout = "compact";
        mouse_mode = true;
      };
      enableBashIntegration = true;
    };
  };
}
