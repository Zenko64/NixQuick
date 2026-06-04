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
      enable = true;
      theme = "catppuccin-mocha";
      compositors.hyprland.enable = true;
    };
    greeter = "greetd";
  };

  home-manager.sharedModules = [
    (
      { ... }:
      {
        wayland.windowManager.hyprland.settings.input.kb_layout = "pt";
      }
    )
  ];

  boot.loader.timeout = 0;
  boot.loader.systemd-boot.edk2-uefi-shell.enable = true;
  # efiDeviceHandle obtained via EDK2 UEFI Shell.
  boot.loader.systemd-boot.windows."00-windows" = {
    title = "Windows";
    efiDeviceHandle = "FS0";
    sortKey = "00";
  };

  console.keyMap = "pt-latin1";
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Lisbon";

  zramSwap.enable = true;

  # Never change after initial install.
  system.stateVersion = "25.11";
}
