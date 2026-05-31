{lib, ...}: {
  options.namespace = lib.mkOption {
    type = lib.types.str;
    default = "local";
    description = "The Namespace For The Framework's Custom Modules.";
  };
}