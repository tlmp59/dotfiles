{
  description = "__DESCRIPTION__";

  outputs = {
    nix-config,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;

    hostname = "__HOSTNAME__";
    system = "__SYSTEM__";
  in {
    nixosConfigurations.${hostname} = nix-config.util.mkHost {
      inherit hostname system inputs;
      build = lib.nixosSystem;
      hostdir = ./.;
      defaultModule = nix-config.nixosModules.default;
    };

    checks.${system} = nix-config.checks.${system};

    devShells.${system} = nix-config.devShells.${system};

    formatter.${system} = nix-config.formatter.${system};
  };

  inputs = {
    nix-config.url = "github:d3vnrd/nix-config";

    nixpkgs.follows = "nix-config/nixpkgs";
    home-manager.follows = "nix-config/home-manager";
  };
}
