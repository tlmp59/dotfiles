lib: rec {
  scanPath = let
    tryReadDir = path:
      if (builtins.pathExists path)
      then builtins.readDir path
      else builtins.warn "scanPath: directory not found: ${builtins.toString path}" {};
  in {
    allEntries = path: builtins.attrNames (tryReadDir path);

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
  };

  hostSystems = let
    validateAttrs = attrs: let
      partitioned = builtins.mapAttrs (_: {
        entries,
        cond,
      }:
        builtins.partition cond entries)
      attrs;

      valid = lib.mapAttrs (_: v: v.right) partitioned;

      invalid = lib.concatLists (
        lib.mapAttrsToList (name: v: map (s: "${name}/${s}") v.wrong) partitioned
      );
    in
      valid // {inherit invalid;};

    scanned = validateAttrs {
      nixos = {
        entries = scanPath.dirs ./host/nixos;
        cond = s: builtins.elem s lib.systems.doubles.linux;
      };

      darwin = {
        entries = scanPath.dirs ./host/darwin;
        cond = s: builtins.elem s lib.systems.doubles.darwin;
      };
    };
  in
    lib.warnIf (scanned.invalid != [])
    "hostSystems: skipping invalid system dir(s): ${builtins.concatStringsSep ", " scanned.invalid}"
    (scanned // {all = scanned.nixos ++ scanned.darwin;});

  mkConfigs = {
    nixos = {}: {};

    darwin = {}: {};
  };

  fromRoot = path: lib.path.append ../. path;

  forAllSystems = func: lib.genAttrs hostSystems.all func;

  mergeAttrsNoOverride = attrs: builtins.foldl' lib.unionOfDisjoint {} attrs;
}
