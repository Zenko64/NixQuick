# Kernel Module
{
  flake.modules.nixos.aarch64 = { lib, pkgs, ... }: {
    # 1250 Priority is between default option priority and manual mkDefault.
    # mkDefault is unreliable, as some nixos-hardware modules might override this.
    # When using something from nixos-hardware, (particularly in architectures other than x86, it can override this and trigger a build)
    boot.kernelPackages = lib.mkOverride 1250 pkgs.linuxPackages_latest;
  };
}
