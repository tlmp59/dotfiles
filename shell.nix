pkgs: {
  default = pkgs.mkShell {
    packages = with pkgs; [
      nixfmt
      deadnix
    ];
    name = "nix-flake";
  };
}
