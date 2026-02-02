{
  config,
  pkgs,
  ...
}: {
  M.sops.enable = true;
  M.addPkgs = with pkgs; [];

  programs.go.enable = true;
  home.sessionVariables = {
    PATH = "${config.home.homeDirectory}/go/bin:$PATH";
  };
}
