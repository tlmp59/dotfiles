{
  config,
  inputs,
  lib,
  pkgs,
  system,
  hostname,
  ...
}: {
  options.M = {
    defaultUser = lib.mkOption {
      type = lib.types.str;
      default = "d3vnrd";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (inputs ? "home-manager") {
      home-manager.users.${config.M.defaultUser}.imports = let
        home = ../host/${system}/${hostname}/home.nix;
      in
        [./home]
        ++ lib.optional (builtins.pathExists home) home;

      home-manager = {
        useGlobalPkgs = lib.mkDefault true;
        useUserPackages = lib.mkDefault true;
        extraSpecialArgs = {inherit inputs;};
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
