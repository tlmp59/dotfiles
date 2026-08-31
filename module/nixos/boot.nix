{pkgs, ...}: {
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
  };

  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
}
