{
  inputs,
  pkgs,
  vars,
  ...
}: {
  imports = [
    inputs.nixos-wsl.nixosModules.wsl
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  wsl.enable = true;
  wsl.defaultUser = vars.username;

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
}
