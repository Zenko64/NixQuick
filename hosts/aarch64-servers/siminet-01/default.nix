# Main Host Configuration
# Homelab EntryPoint
{ modulesPath, ... }:
{
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
    ./disko.nix
    ./users.nix
    ./services.nix
    ./programs.nix
  ];

  networking = {
    useDHCP = true;
    #interfaces.eth0 = {
    #  ipv4.addresses = [
    #    {
    #      address = "192.168.0.2";
    #      prefixLength = 24;
    #    }
    #  ];
    #};
    #defaultGateway = {
    #  address = "192.168.0.1";
    #  interface = "eth0";
    #};
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

  console.keyMap = "pt-latin1";
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Lisbon";
  zramSwap.enable = true;

  system.stateVersion = "26.11";
}
