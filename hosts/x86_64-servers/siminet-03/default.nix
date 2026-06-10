# Main Host Configuration
# TODO: Configure Server GPU
{ ... }:
{
  imports = [
    ./disko.nix
    ./users.nix
    ./services.nix
    ./programs.nix
  ];

  console.keyMap = "pt-latin1";
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Lisbon";
  zramSwap.enable = true;
}
