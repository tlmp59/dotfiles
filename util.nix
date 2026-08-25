lib: rec {
  scanPath = rec {
    tryReadDir = path:
      if (builtins.pathExists path)
      then builtins.readDir path
      else builtins.warn "scanPath: directory not found: ${builtins.toString path}" {};

    allEntries = path: builtins.attrNames (tryReadDir path);

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

  flakeRoot = builtins.toString ./.;

  mkModuleTree = with scanPath;
    path: let
      entries =
        lib.filterAttrs (
          name: type:
            type
            == "directory"
            || (type == "regular" && lib.hasSuffix ".nix" name)
        )
        (tryReadDir path);
    in
      lib.mapAttrs' ( # Prime version allows changes to attr names
        name: type: {
          name = lib.removeSuffix ".nix" name;
          value =
            if type == "directory"
            then moduleTree (path + "/${name}")
            else path + "/${name}";
        }
      )
      entries;

  mergeAttrsNoOverride = attrs: builtins.foldl' lib.attrsets.unionOfDisjoint {} attrs;
}
