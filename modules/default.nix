{
  inputs,
  lib,
  pkgs,
  hostname,
  hostdir,
  ...
}: let
  vars = inputs.self.util.mkVars (inputs.secrets or {});
in {
  options.M = {};

  config = lib.mkMerge [
    {
      # Adding finalized vars into module's args
      _module.args.vars = vars;

      # Setting machine's hostname
      networking.hostName = lib.mkForce hostname;

      # Always enable flake's fetures
      nix.settings = {
        experimental-features = ["nix-command" "flakes"];
        # trusted-users, substituters, etc.
      };

      nixpkgs.config.allowUnfree = lib.mkDefault true;

      # Global system-wide packages
      environment.systemPackages = with pkgs; [
        git
        curl
      ];
    }

    (lib.mkIf (inputs ? "home-manager") {
      home-manager = {
        useGlobalPkgs = lib.mkDefault true;
        useUserPackages = lib.mkDefault true;
        extraSpecialArgs = {inherit inputs vars;};
      };

      # TODO: update to support perhost configs
      home-manager.users.${vars.username}.imports = let
        home = hostdir + "/home.nix";
      in
        [./home]
        ++ lib.optional (hostdir != null && builtins.pathExists home) home;
    })
  ];
}
