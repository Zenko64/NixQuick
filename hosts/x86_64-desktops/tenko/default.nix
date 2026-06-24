# Main Host Configuration
{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./gpu.nix
    ./networks.nix
    ./programs.nix
    ./users.nix
  ];

  local = {
    desktop = {
      theme = "catppuccin-mocha";
      compositors.hyprland = {
        enable = true;
        shell = "ashell";
      };
      greeters.tuigreet.enable = true;
    };
  };

  boot = {
    #kernelParams = [
    #  "quiet"
    #  "splash"
    #  "loglevel=3"
    #  "rd.udev.log_level=3"
    #];

    # After using EDK2 Shell, Please Disable It, For Security.
    # loader.systemd-boot.edk2-uefi-shell.enable = true;

    # Boot Instantly. To see the bootmenu, hold space during boot.
    loader.timeout = 0;

    # Obtain the EFIDeviceHandle from the EDK2 Shell
    loader.systemd-boot.windows."00-windows" = {
      title = "Windows";
      efiDeviceHandle = "FS1";
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
