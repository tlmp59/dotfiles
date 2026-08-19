{
  inputs,
  ulib,
  ...
}: let
  inherit (inputs) nixpkgs;
  inherit (nixpkgs) lib;
in {
  nixosConfigurations =
    ulib.mergeAttrsNoOverride [
    ];

  darwinConfigurations = {};
}
