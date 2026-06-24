# NVIDIA GPU Configuration
{ ... }:
{
  # ! If your system takes too long to compile, disable this for the first time and then re-enable it after the first build.
  # This will force the Binary Cache to be used, skipping the compilation of CUDA Packages.
  nixpkgs.config.cudaSupport = true;
  
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    nvidia = {
      powerManagement.enable = true; # Needed for suspend
      nvidiaSettings = true;
      # prime.offload.enable = true;
    };
  };
  boot.blacklistedKernelModules = [ "nouveau" ];
}
