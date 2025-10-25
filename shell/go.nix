pkgs: {
  packages = with pkgs; [
    go
  ];
  shellHook = ''
    echo "Go development environment"
    exec zsh
  '';
  name = "go";
}
