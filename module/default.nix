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
        home-manager.users.${config.M.defaultUser}.imports = [home];
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
  };

  home = {inputs, ...}: {
    imports = [(inputs.import-tree ./home)];
  };

  nixos = {
    inputs,
    lib,
    ...
  }: {
    imports = [
      base
      (inputs.import-tree ./nixos)
      inputs.home-manager.nixosModules.home-manager
    ];

    boot.loader.systemd-boot.enable = lib.mkDefault true;
    boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

    services.openssh.enable = lib.mkDefault true;

    home-manager = {
      useGlobalPkgs = lib.mkDefault true;
      useUserPackages = lib.mkDefault true;
      extraSpecialArgs = lib.mkForce {inherit inputs;};
    };
  };

  darwin = {
    inputs,
    lib,
    ...
  }: {
    imports = [
      base
      (inputs.import-tree ./darwin)
      inputs.home-manager.darwinModules.home-manager
    ];

    homebrew.enable = lib.mkDefault true;
    homebrew.onActivation.cleanup = "zap";
  };
}
