{
  config,
  inputs,
  lib,
  pkgs,
  hostname,
  ...
}: {
  options.M = {
    enableHomeManager = lib.mkEnableOption "enable home-manager integration";
    defaultUser = lib.mkOption {
      type = lib.types.str;
      default = "d3vnrd";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf config.M.enableHomeManager {
      home-manager.users.${config.M.defaultUser}.imports = [];
      home-manager = {
        useGlobalPkgs = lib.mkDefault true;
        useUserPackages = lib.mkDefault true;
        extraSpecialArgs = lib.mkForce {inherit inputs;};
      };
    })

    {
      networking.hostName = lib.mkDefault hostname;

      nixpkgs.config.allowUnfree = lib.mkDefault true;

      nix.settings = {
        experimental-features = ["nix-command" "flakes"];
        # trusted-users, substituters, etc.
      };

      environment.systemPackages = with pkgs; [
        git
        curl
      ];
    }
  ];
}
