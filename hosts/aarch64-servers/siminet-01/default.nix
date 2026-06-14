# Main Host Configuration
# Homelab EntryPoint
{ inputs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    ./users.nix
    ./services.nix
    ./programs.nix
  ];

  networking = {
    useDHCP = true;
    interfaces.end0 = {
      ipv4.addresses = [
        {
          address = "192.168.0.2";
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = {
      address = "192.168.0.1";
      interface = "end0";
    };
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

  console.keyMap = "us-intl";
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Lisbon";
  zramSwap.enable = true;

  system.stateVersion = "26.11";
}
