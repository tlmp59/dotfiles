lib: rec {
  default = nixos-init;

  nixos-init = {
    path = ./nixos;
    description = "Template to initialize new host";
  };
}
