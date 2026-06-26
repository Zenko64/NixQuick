# Users and Homes
{ self, pkgs, ... }:
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
  # Append the path to self (the flake root). Note: inputs.self resolves to NixQuick here, not your flake.
  # TODO: Correct this after setting up a home-manager.
  #home-manager.users.user.imports = [
  #  "${self}/homes/user/profiles/server.nix"
  #];
}
