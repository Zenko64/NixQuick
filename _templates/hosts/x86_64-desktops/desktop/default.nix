# Main Host Configuration
{ ... }:
{
  imports = [
    # ./hardware-configuration.nix
    ./gpu.nix
    ./networks.nix
    ./programs.nix
    ./users.nix
  ];

  # For compiling aarch64 SDImage by pulling closure (CC Hashes are different, no cache entries, this emulates it allowing closure to be pulled from cache since it's not CC)
  # boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  local = {
    desktop = {
      theme = "catppuccin-mocha";
      compositors.hyprland.enable = true;
      greeters.tuigreet.enable = true;
    };
    boot.loader.systemd-boot.enable = true;
    # boot.loader.systemd-boot.secureBoot = true; # also enrolls Secure Boot via lanzaboote
    boot.splash = true;
  };

  # Enable Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # ------ Locale and Homes ------

  # EXAMPLE: Global Defaults For All Users Homes
  home-manager.sharedModules = [
    # Nest a module
    {
      programs.fish.enable = true;
      wayland.windowManager.hyprland.settings = {
        input.kb_layout = "us-intl"; # Hyprland KBD Layout
        #xwayland = {
        #  force_zero_scaling = true;
        #};
      };
    }
  ];

  # ----- LOCALE -----
  console.keyMap = "us-intl";
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/New_York";

  zramSwap.enable = true;

  # ------ DUAL Booting ------
  # boot.loader.timeout = 0;

  # After using EDK2 Shell, Please Disable It If Possible, For Security.
  boot.loader.systemd-boot.edk2-uefi-shell.enable = true;

  # efiDeviceHandle obtained via EDK2 UEFI Shell
  #boot.loader.systemd-boot.windows."00-windows" = {
  #  title = "Windows";
  #  efiDeviceHandle = "FS0";
  #  sortKey = "00";
  #};

  # Do NOT change this after the initial installation.
  system.stateVersion = "26.11";
}
