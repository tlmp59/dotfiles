{
  config,
  lib,
  vars,
  ...
}: {
  options.M.sshKeys = lib.mkOption {
    type = with lib.types; listOf str;
    default = [];
    description = "SSH public keys authorized to access this machine.";
  };

  config = {
    users.users.${vars.username} = {
      isNormalUser = true;

      extraGroups = [
        "wheel"
        "networkmanager"
        "docker"
      ];

      # openssh.authorizedKeys.keys = config.M.sshKeys; # make this a config option
    };

    users.mutableUsers = true;
  };
}
