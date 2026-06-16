# Users and Home Configurations
{ inputs, ... }:
let
  sshPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILQyfvGLHb+gMY1dzUZp1ckpktrdF204scLSJc/wxVq0 simi@zenko";
in
{
  users.users.nacho = {
    isNormalUser = true;
    home = "/home/nacho";
    createHome = true;
    initialPassword = "nacho";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [ sshPubKey ];
  };

  # Don't use Relative Paths as it is impure. Always append the path to inputs.self, as inputs.self leads to the root.
  home-manager.users.nacho.imports = [
    (inputs.self + "/homes/nacho/profiles/server.nix")
  ];
}
