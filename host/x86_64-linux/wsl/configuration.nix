{
  config,
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

  users.users.${config.M.defaultUser}.extraGroups = [
    "wheel"
    "docker"
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.tinos
  ];
}
