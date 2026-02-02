{
  config,
  lib,
  pkgs,
  vars,
  ...
}:
with lib; {
  imports = [./packages];

  config = {
    nix.settings.experimental-features = mkForce ["nix-command" "flakes"];
    nixpkgs.config.allowUnfree = mkDefault true;
    users.defaultUserShell = mkIf config.programs.zsh.enable pkgs.zsh;

    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    users.mutableUsers = false;
    users.users.${vars.username} = {
      isNormalUser = mkForce true;
      extraGroups = mkDefault ["wheel" "networking" "docker"];
      initialHashedPassword = "$y$j9T$M6TybczU2EA.4QsbGotzL/$D4CO6z0J.jJsIx84jlHSmQ/FRVxzp9i6.U8T2TlbMV6";
    };

    time.timeZone = mkDefault vars.timeZone;
    system.stateVersion = mkForce vars.stateVersion;
  };
}
