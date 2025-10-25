{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.M.editor;
in {
  options.M.editor = mkOption {
    type = types.enum ["nvim" "nvim_vscode"];
    default = "nvim";
    description = "Editor options.";
  };

  config = {
    programs = {
      neovim = mkMerge [
        {
          enable = mkDefault true;
          viAlias = mkDefault true;
          vimAlias = mkDefault true;
        }

        (mkIf (cfg == "nvim") {
          package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
          defaultEditor = mkDefault true;

          extraWrapperArgs = [
            "--suffix"
            "LIBRARY_PATH"
            ":"
            "${lib.makeLibraryPath [pkgs.stdenv.cc.cc pkgs.zlib]}"
            "--suffix"
            "PKG_CONFIG_PATH"
            ":"
            "${lib.makeSearchPathOutput "dev" "lib/pkgconfig" [pkgs.stdenv.cc.cc pkgs.zlib]}"
          ];

          extraPackages = with pkgs; [
            gcc
            tree-sitter
            sqlite
            xclip
            fd
          ];
        })
      ];

      vscode = {
        enable = cfg == "nvim_vscode";
        # source: https://nixos.wiki/wiki/Visual_Studio_Code (impure setup)
        package = pkgs.vscode.fhs;
      };
    };

    home.packages = with pkgs; [
      # -- LSP --
      bash-language-server
      lua-language-server
      yaml-language-server
      vscode-css-languageserver
      nixd
      harper
      pyright
      tinymist
      markdown-oxide

      # -- DAP --

      # -- Linter --

      # -- Formatter --
      alejandra
      black
      dprint
      isort
      stylua
      typstyle
      shfmt

      # -- Other --
      websocat # dependency for typst-preview
    ];
  };
}
