{ ... }:
# Most stuff is handled by nixos-hardware
{
  nixpkgs.config.cudaSupport = true;
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    nvidia = {
      powerManagement.enable = true; # Needed for suspend
      nvidiaSettings = true;
    };
  };
  boot.blacklistedKernelModules = [ "nouveau" ];
}
