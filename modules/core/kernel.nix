# Kernel Module
{
  flake.modules.nixos.core = { lib, pkgs, ... }: {
    boot.kernelPackages = lib.mkOptionDefault pkgs.linuxPackages_latest;
  };
}
