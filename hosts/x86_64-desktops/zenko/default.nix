# Main Host Configuration
{ inputs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.asus-zephyrus-gu605cw
    ./hardware-configuration.nix
    ./gpu.nix
    ./networks.nix
    ./programs.nix
    ./users.nix
  ];

  # For compiling aarch64 SDImage by pulling closure (CC Hashes are different, no cache entries, this emulates it allowing closure to be pulled from cache since it's not CC)
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  local = {
    desktop = {
      theme = "catppuccin-mocha";
      compositors.hyprland = {
        enable = true;
        shell = "ashell";
      };
      greeters.tuigreet.enable = true;
    };
    boot.secureBoot = true;
    boot.splash = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  home-manager.sharedModules = [
    (
      { ... }:
      {
        wayland.windowManager.hyprland.settings = {
          input.kb_layout = "pt";
          xwayland = {
            force_zero_scaling = true;
          };
        };
      }
    )
  ];

  boot.loader.timeout = 0;

  # After using EDK2 Shell, Please Disable It, For Security.
  # boot.loader.systemd-boot.edk2-uefi-shell.enable = true;

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
