# TODO: separate these into files for documentations
lib: rec {
  mkVars = secrets: let
    defaults = {
      username = "nixos";
      timeZone = "UTC";
    };
  in
    lib.recursiveUpdate defaults (secrets.vars or {});

  scanPath = rec {
    tryReadDir = path:
      if (builtins.pathExists path)
      then builtins.readDir path
      else builtins.warn "scanPath: directory not found: ${builtins.toString path}" {};

    excludeEntries = excludes: entries:
      lib.filter
      (name: !builtins.elem name excludes)
      entries;

    toPaths = path: entries: map (name: path + "/${name}") entries;

    subDirs = path:
      builtins.attrNames (
        lib.filterAttrs (_: type: type == "directory") (tryReadDir path)
      );

    nixFiles = path:
      builtins.attrNames (
        lib.filterAttrs (
          name: type:
            (type == "regular")
            && (name != "default.nix")
            && (lib.hasSuffix ".nix" name)
        ) (tryReadDir path)
      );
  };

  mkModuleTree = path: let
    entries =
      lib.filterAttrs (
        name: type:
          type
          == "directory"
          || (type == "regular" && lib.hasSuffix ".nix" name)
      )
      (scanPath.tryReadDir path);
  in
    lib.mapAttrs' ( # Prime version allows changes to attr names
      name: type: {
        name = lib.removeSuffix ".nix" name;
        value =
          if type == "directory"
          then mkModuleTree (path + "/${name}")
          else path + "/${name}";
      }
    )
    entries;

  mergeAttrsNoOverride = builtins.foldl' lib.attrsets.unionOfDisjoint {};
}
