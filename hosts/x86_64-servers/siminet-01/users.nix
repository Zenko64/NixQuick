# Users and Homes
{ inputs, pkgs, ... }:
let
  sshPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILQyfvGLHb+gMY1dzUZp1ckpktrdF204scLSJc/wxVq0 simi@zenko";
in
{
  users.users.root.openssh.authorizedKeys.keys = [ sshPubKey ];
  users.users.simi = {
    isNormalUser = true;
    home = "/home/simi";
    shell = pkgs.fish;
    hashedPassword = "$y$j9T$tjs435fHbjQ.5SGhfWQP2.$eY6O.M606bYPymg/JU3rFNEWWLkIBba4JYAaU0gEmG4";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [ sshPubKey ];
  };
  home-manager.users.simi.imports = [ "${inputs.self}/homes/simi/profiles/server.nix" ];
}
