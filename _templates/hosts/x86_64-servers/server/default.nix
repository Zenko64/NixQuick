# Main Host Configuration
{ ... }:
{
  imports = [
    ./disko.nix
    ./users.nix
    ./services.nix
    ./programs.nix
  ];

  # Network Configuration (NixOS Wiki)
  networking = {
    useDHCP = false;
    interfaces.enp0s20f0u3 = {
      ipv4.addresses = [
        {
          address = "192.168.0.3";
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = {
      address = "192.168.0.1";
      interface = "enp0s20f0u3";
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
