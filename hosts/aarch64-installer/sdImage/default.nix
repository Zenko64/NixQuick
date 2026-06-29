{
  modulesPath,
  lib,
  ...
}:
{
  # Use binfmt to build the system instead, so it can pull closure from cache. Uncommenting this will cross-compile the system closure from source! (slow)
  # nixpkgs.buildPlatform.system = "x86_64-linux";

  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
  ];

  # Fix random zfs issue that broke build. we dont need zfs either here
  boot.supportedFilesystems.zfs = lib.mkForce false;
}
