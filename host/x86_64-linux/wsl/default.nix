{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.nixos-wsl.nixosModules.wsl];

  wsl.enable = true;
  wsl.defaultUser = "tlmp59";

  # --Docker--
  wsl.docker-desktop.enable = false;
  # Required packages for docker support
  wsl.extraBin = with pkgs; [
    {src = "${coreutils}/bin/cat";}
    {src = "${coreutils}/bin/whoami";}
    {src = "${busybox}/bin/addgroup";}
    {src = "${su}/bin/groupadd";}
  ];

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
  };

  M.defaultPkgs = true;
  M.addPkgs = with pkgs; [
    wsl-open
    xclip
    xdg-utils
  ];

  M.openssh = true;

  # --Vscode remote support--
  programs.nix-ld.enable = true;
}
