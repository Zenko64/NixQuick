{ inputs, pkgs, ... }:
{
  imports = [
   # inputs.mt7927.nixosModules.default
    ./hardware-configuration.nix
    ./gpu.nix
    ./networks.nix
  ];

  programs.nix-ld.enable = true;

  boot.kernelParams = [
    "quiet"
    "splash"
    "loglevel=3"
    "rd.udev.log_level=3"
  ];

  boot.plymouth = {
    enable = true;
    theme = "bootTheme";
    themePackages = [ pkgs.main.bootTheme ];
  };
  boot.loader.systemd-boot.edk2-uefi-shell.enable = true;
  boot.loader.timeout = 0;
  boot.loader.systemd-boot.windows."00-windows" = {
    # efiDeviceHandle obtained via EDK2 UEFI Shell.
    title = "Windows";
    efiDeviceHandle = "FS0";
    sortKey = "00";
  };

  #hardware.mediatek-mt7927 = {
  #  enable = true;
  #  enableWifi = true;
  #  enableBluetooth = true;
  #  # Required to fix upload speed issues on MT7927.
  #  disableAspm = true;
  #};

  #main = {
  #  desktops.hyprland = {
  #    enable = true;
  #    settings = {
  #      input = {
  #        kb_layout = "us";
  #        kb_variant = "intl";
  #      };
  #      device = [
  #        {
  #          name = "compx-atk-a9-ultra-1";
  #          accel_profile = "flat";
  #          sensitivity = -0.25;
  #        }
  #        {
  #          name = "compx-atk-mouse-8k-dongle-mouse";
  #          accel_profile = "flat";
  #          sensitivity = -0.25;
  #        }
  #      ];
  #    };
  #  };
#
  #  greeter = "greetd";
  #  desktop.theme = "catppuccin-mocha";
  #  users.simi = {
  #    fullName = "Zenko";
  #    email = "simi.git@outlook.com";
  #    shell = "fish";
  #  };
  #};

  programs.steam.enable = true;
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
  };

  time.timeZone = "Europe/Lisbon";
  i18n.defaultLocale = "en_US.UTF-8";
  
  console.keyMap = "us-intl";

  zramSwap.enable = true;

  # Never change after initial install.
  system.stateVersion = "25.11";
}
