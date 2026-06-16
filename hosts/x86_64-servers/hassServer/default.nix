# Main Host Configuration
# WARN: Use SOPS only after bootstrapping the system and getting the SSH Host Key inside .sops.yaml
{ config, ... }:
{
  imports = [
    ./disko.nix
    ./users.nix
    ./services.nix
  ];

  sops.secrets."wifi-secret" = {
    sopsFile = ./secrets/wireless.yaml;
    key = "wifiPsk";
  };

  sops.templates."wifi-secret".content = ''
    WIFI_SIMI=${config.sops.placeholder."wifi-secret"}
  '';

  networking = {
    useDHCP = false;
    wireless = {
      enable = true;
      secretsFile = config.sops.templates."wifi-secret".path;
      networks."Simi" = {
        psk = "@WIFI_SIMI@";
      };
    };
    interfaces.wlan0 = {
      ipv4.addresses = [
        {
          address = "192.168.0.6";
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = {
      address = "192.168.0.1";
      interface = "wlan0";
    };
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

  # Portuguese keyboard is "pt-latin1"
  console.keyMap = "us-intl";
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Lisbon";
  zramSwap.enable = true;

  # HW Drivers
  hardware.enableRedistributableFirmware = true;

  # Initrd needs eMMC support
  boot.initrd.availableKernelModules = [
    "mmc_block"
    "sdhci"
    "sdhci_pci"
    "sdhci_acpi"
  ];

  # Space optimization
  documentation = {
    enable = false;
    nixos.enable = false;
    man.enable = false;
  };
  nix.gc = {
    automatic = true;
    dates = "4h";
    options = "--delete-older-than 4h";
  };

  boot.loader.systemd-boot.configurationLimit = 2;
  services.journald.extraConfig = ''
    SystemMaxUse=256M
    SystemKeepFree=1G
    RuntimeMaxUse=16M
  '';

  # DO NOT Alter stateVersion after initial install.
  # This does NOT mean the system is out-of-date or vulnerable.
  system.stateVersion = "26.11";
}
