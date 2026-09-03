{
  config,
  lib,
  pkgs,
  vars,
  ...
}: let
  cfg = config.M;
in {
  options.M.dotfiles = {
    enable = lib.mkEnableOption "Enable support for user dotfiles.";

    url = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Git repository containing the user's dotfiles.";
      example = "https://github.com/example/dotfiles.git";
    };

    path = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/dotfiles";
      description = "Location where the dotfiles repository is cloned.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.dotfiles.enable {
      # https://nixos.org/manual/nixos/stable/#sec-assertions-assetions
      assertions = [
        {
          assertion = cfg.dotfiles.url != "";
          message = "A dotfiles URL is required.";
        }
      ];

      # https://www.foodogsquared.one/posts/2023-03-24-managing-mutable-files-in-nixos/
      home.activation.fetchDotfiles = lib.hm.dag.entryBefore ["writeBoundary"] ''
        if [ ! -d "${cfg.dotfiles.path}/.git" ]; then
          ${pkgs.git}/bin/git clone \
            "${cfg.dotfiles.url}" \
            "${cfg.dotfiles.path}"
        fi
      '';
    })

    (lib.mkDefault {
      home.username = vars.username;
      home.stateVersion = "25.11";
    })
  ];
}
