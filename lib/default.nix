# TODO: separate these into files for documentations
lib: rec {
  forAllSystems = lib.genAttrs lib.systems.flakeExposed;

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

  mkVars = secrets: let
    defaults = {
      username = "nixos";
      timeZone = "UTC";
    };
  in
    lib.recursiveUpdate defaults (secrets.vars or {});

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

  mkHost = {
    build,
    system,
    hostname,
    hostdir ? null,
    inputs ? {},
    defaultModule ? {...}: {},
  }: let
    modules = let
      safeImport = file:
        lib.optional (
          hostdir != null && builtins.pathExists (hostdir + "/${file}")
        ) (hostdir + "/${file}");
    in
      lib.flatten [
        defaultModule
        (safeImport "configuration.nix")
        (safeImport "hardware-configuration.nix")
      ];
  in
    build {
      inherit system modules;
      specialArgs = {inherit inputs system hostname hostdir;};
    };

  mergeAttrsNoOverride = builtins.foldl' lib.attrsets.unionOfDisjoint {};
}
