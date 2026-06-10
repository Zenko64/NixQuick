# Graphics Hardware Configuration
{ ... }:
{
  nixpkgs.config.cudaSupport = true;

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    nvidia = {
      modesetting.enable = true;
      nvidiaSettings = true;
      open = true;
    };
  };

  boot = {
    blacklistedKernelModules = [ "nouveau" ];
    # Load NVIDIA early in initrd.
    initrd.kernelModules = [
      "nvidia"
      "nvidia_modeset"
      "nvidia_uvm"
      "nvidia_drm"
    ];
    # Disable the dummy HDMI plug.
    kernelParams = [ "video=HDMI-A-3:d" ];
  };

  services.xserver.videoDrivers = [
    "amdgpu"
    "nvidia"
    "nvidia_drm"
    "nvidia_modeset"
  ];
}
