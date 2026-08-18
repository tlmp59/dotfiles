lib:
with lib; {
  fromRoot = p: path.append ../. p;

  mkNixOs = nixpkgs: {
    hostname ? "nixos",
    system ? "x86_64-linux",
    modules ? {},
    specialArgs ? [],
  }:
    if !(nixpkgs ? lib) || !(nixpkgs.lib ? nixosSystem)
    then throw "mkNixOs: expected the nixpkgs flake input, got a ${builtins.typeOf nixpkgs} without `.lib.nixosSystem`"
    else
      nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
      };
}
