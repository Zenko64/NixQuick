# Main Host Configuration
{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./gpu.nix
    ./networks.nix
    ./programs.nix
  ];

  boot = {
    #kernelParams = [
    #  "quiet"
    #  "splash"
    #  "loglevel=3"
    #  "rd.udev.log_level=3"
    #];
    loader.systemd-boot.edk2-uefi-shell.enable = true;

    # Boot Instantly. To see the bootmenu, hold space during boot.
    loader.timeout = 0;

    # Obtain the EFIDeviceHandle from the EDK2 Shell
    loader.systemd-boot.windows."00-windows" = {
      title = "Windows";
      efiDeviceHandle = "FS0";
      sortKey = "00";
    };
  };

  console.keyMap = "us-intl";
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Lisbon";

  zramSwap.enable = true;

  # Never change after initial install.
  system.stateVersion = "25.11";
}
