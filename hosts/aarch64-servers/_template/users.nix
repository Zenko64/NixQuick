# Users and Homes
{ inputs, pkgs, ... }:
let
  sshPubKey = "ssh-ed25519 AAAA...REPLACE_ME you@host";
in
{
  users.users.root.openssh.authorizedKeys.keys = [ sshPubKey ];

  users.users.user = {
    isNormalUser = true;
    home = "/home/user";
    createHome = true;
    initialPassword = "password"; # Initial password. Change immediately after the first login.
    extraGroups = [ "wheel" ]; # Add all your needed user groups, check Arch Wiki for a list of groups and their purpose.
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [ sshPubKey ];
  };

  # Don't use Relative Paths as it is impure.
  # Always append the path to inputs.self, as inputs.self leads to the root of the flake.
  home-manager.users.user.imports = [
    "${inputs.self}/homes/_template/profiles/server.nix"
  ];
}
