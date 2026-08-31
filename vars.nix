{
  lib,
  secrets ? {},
}: let
  default = {
    username = "nixos";
    timeZone = "UTC";
  };
in
  lib.recursiveUpdate default (secrets.vars or {})
