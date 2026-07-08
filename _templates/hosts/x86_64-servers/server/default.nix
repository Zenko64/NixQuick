# Example Server Configuration
{ ... }:
{
  imports = [
    ./disko.nix
    ./users.nix
    ./services.nix
    ./programs.nix
  ];

  local.boot.loader.systemd-boot.enable = true;

  # Network Configuration (NixOS Wiki)
  networking = {
    useDHCP = false;
    interfaces.eth0 = {
      ipv4.addresses = [
        {
          address = "192.168.0.2";
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = {
      address = "192.168.0.1";
      interface = "eth0";
    };
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

  # ----- LOCALE -----
  console.keyMap = "us-intl";
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/New_York";

  zramSwap.enable = true;

  # Do NOT change this after the initial installation.
  system.stateVersion = "26.11";
}
