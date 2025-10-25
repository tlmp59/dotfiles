{pkgs, ...}: {
  M.sops.enable = true;
  M.addPkgs = with pkgs; [];
}
