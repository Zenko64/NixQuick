{ lib, pkgs, ... }:
{
  time.timeZone = "Europe/Lisbon";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "pt-latin1";

  # Enable SSH Server
  services.openssh.enable = true;
  services.openssh.settings = {
    PermitRootLogin = "yes";
  };

  # Normal User
  users.users.simi = {
    isNormalUser = true;
    home = "/home/simi";
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
    # For Debuggee Testing
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILQyfvGLHb+gMY1dzUZp1ckpktrdF204scLSJc/wxVq0 simi@zenko"
    ];
  };

  networking.useDHCP = lib.mkForce true;
  zramSwap.enable = true;

  disko.devices.osDisk = {
    
  };
}
