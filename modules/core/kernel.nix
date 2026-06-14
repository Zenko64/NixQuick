# Kernel Module
{
  flake.modules.nixos.core = { pkgs, ... }: {
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  };
}
