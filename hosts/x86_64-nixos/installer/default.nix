# Attempt to setup Netboot Installer for testing the configuration on a debuggee
{ modulesPath, lib, ... }:
{
  imports = [ "${modulesPath}/installer/netboot/netboot.nix" ];

  services.openssh.enable = true;
  services.openssh.settings = {
    PermitRootLogin = "yes";
  };

  users.users.root.password = "";

  services.getty.autologinUser = "root";

  # TODO: Remove this later. It's for testing the installer on a debuggee
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILQyfvGLHb+gMY1dzUZp1ckpktrdF204scLSJc/wxVq0 simi@zenko"
  ];

  networking.useDHCP = lib.mkForce true;
}
