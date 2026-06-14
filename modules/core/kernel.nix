# Kernel Module
{
  flake.modules.nixos.core = { lib, pkgs, ... }: {
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  };
}
