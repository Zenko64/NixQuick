{ ... }:
# Most stuff is handled by nixos-hardware
{
#  nixpkgs.config.cudaSupport = true;

  boot.initrd.kernelModules = [ "xe" ];
  services.xserver.videoDrivers = [
    "xe"
    "nvidia"
  ];
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    nvidia = {
      powerManagement.enable = true; # Needed for suspend
      nvidiaSettings = true;
      prime.offload.enable = true;
    };
  };
  boot.blacklistedKernelModules = [ "nouveau" ];
}
