lib: {
  scanPath = let
    tryReadDir = path:
      if (builtins.pathExists path)
      then builtins.readDir path
      else builtins.warn "scanPath: directory not found: ${builtins.toString path}" {};
  in rec {
    allEntries = path: builtins.attrNames (tryReadDir path);

    excludeEntries = excludes: entries:
      lib.filter
      (name: !builtins.elem name excludes)
      entries;

    dirs = path:
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

    toPaths = path: entries: map (name: path + "/${name}") entries;

    importModules = path: toPaths path (excludeEntries ["default.nix"] (allEntries path));
  };

  classifyHostSystems = entries: let
    platforms = {
      inherit (lib.systems.doubles) linux darwin;
    };

    systems =
      builtins.mapAttrs (
        _: supported:
          builtins.filter
          (s: builtins.elem s supported)
          entries
      )
      platforms;

    valid = lib.flatten (lib.attrValues systems);
    invalid = lib.subtractLists entries valid;
  in
    lib.warnIf (invalid != [])
    "hostSystems: skipping invalid system dir(s): ${builtins.concatStringsSep ", " invalid}"
    systems;

  fromRoot = path: lib.path.append ../. path;

  mergeAttrsNoOverride = attrs: builtins.foldl' lib.attrsets.unionOfDisjoint {} attrs;
}
