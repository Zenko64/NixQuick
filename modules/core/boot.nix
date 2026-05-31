# Module responsible for setting a bootloader and a kernel.
{
  flake.modules.nixos.core = {lib, pkgs, ...}:
  {
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    boot.loader.systemd-boot.enable = true;
    boot.loader.systemd-boot.editor = false; # Security Measure
    boot.loader.efi.canTouchEfiVariables = true;
  };
}
