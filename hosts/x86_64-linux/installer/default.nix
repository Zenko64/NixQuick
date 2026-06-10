# X86 NixOS Installer PXE Configuration
{ modulesPath, ... }:
let
  sshPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILQyfvGLHb+gMY1dzUZp1ckpktrdF204scLSJc/wxVq0 simi@zenko";
in
{
  imports = [ "${modulesPath}/installer/netboot/netboot.nix" ];

  services.getty.autologinUser = "root";
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  # Key to access the debuggee installer over SSH.
  users.users.root = {
    password = "";
    openssh.authorizedKeys.keys = [
      sshPubKey
    ];
  };
}
