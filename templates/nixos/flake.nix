{
  description = "__DESCRIPTION__";

  outputs = {
    main,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;

    hostname = "__HOSTNAME__";
    system = "__SYSTEM__";
  in {
    nixosConfigurations.${hostname} = main.util.mkHost {
      inherit hostname system inputs;
      build = lib.nixosSystem;
      hostdir = ./.;
      defaultModule = main.nixosModules.default;
    };

    checks.${system} = main.checks.${system};

    devShells.${system} = main.devShells.${system};

    formatter.${system} = main.formatter.${system};
  };

  inputs = {
    main.url = "github:d3vnrd/nix-config";
    nixpkgs.follows = "main/nixpkgs";
    home-manager.follows = "main/home-manager";
  };
}
