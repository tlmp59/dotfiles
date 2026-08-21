/*
Default configuration for this flake's hosts — `base` applies to every
host regardless of OS, `nixos`/`darwin` apply on top for their
respective OS. These are included automatically via `mkHosts`, not
opt-in presets to pick from.

Also exposed via `self.nixosModules`/`self.darwinModules` so a separate,
standalone flake (e.g. a single-purpose server repo) can pull in the
same defaults directly, without going through this flake's `mkHosts`
pipeline.

Not zero-assumption modules - a consuming flake must supply, via
`specialArgs`:
  - hostname   (string, required, no default — e.g. "myServer")
  - inputs     (this flake's `inputs`, so `inputs.home-configs`/
                `inputs.import-tree`/etc. resolve correctly)

Minimal example for a standalone flake using these defaults directly:

  nixosConfigurations.myServer = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; hostname = "myServer"; };
    modules = [ inputs.main-flake.nixosModules.nixos ];
  };
*/
rec {
  base = {
    inputs,
    lib,
    pkgs,
    hostname,
    ...
  }: {
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

    # home-manager.users."nixos".imports = lib.flatten [
    #   inputs.home-configs.homeModules.default
    # ];

    home-manager = {
      useGlobalPkgs = lib.mkDefault true;
      useUserPackages = lib.mkDefault true;
      extraSpecialArgs = lib.mkForce {inherit inputs;};
    };
  };

  nixos = {
    inputs,
    lib,
    ...
  }: {
    imports = [
      base
      (inputs.import-tree ./nixos)
    ];

    boot.loader.systemd-boot.enable = lib.mkDefault true;
    boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

    services.openssh.enable = lib.mkDefault true;

    # users.users.${config.myConfig.primaryUser} = {
    #   isNormalUser = true;
    #   extraGroups = ["wheel" "networkmanager"];
    # };
  };

  darwin = {
    inputs,
    lib,
    ...
  }: {
    imports = [
      base
      (inputs.import-tree ./darwin)
    ];

    homebrew.enable = lib.mkDefault true;
    homebrew.onActivation.cleanup = "zap";
  };
}
