{inputs, ...}: {
  imports = [inputs.self._lib.scanPath.importModules ./.];
}
