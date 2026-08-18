lib: {
  fromRoot = path: lib.path.append ../. path;

  scanPath = {
    entries = path: builtins.attrNames (builtins.readDir path);

    dirs = path:
      builtins.attrNames (
        lib.filterAttrs (_: type: type == "directory") (builtins.readDir path)
      );

    nixFiles = path:
      builtins.attrNames (
        lib.filterAttrs (
          name: type:
            (type == "regular")
            && (name != "default.nix")
            && (lib.hasSuffix ".nix" name)
        ) (builtins.readDir path)
      );

    exclude = entries: excludeList:
      builtins.filter (name: !(builtins.elem name excludeList)) entries;

    toPaths = path: entries: map (name: path + "/${name}") entries;
  };

  genConfigs = {
    nixos = {};

    darwin = {};

    home-manger = {};
  };
}
