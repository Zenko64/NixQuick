# Users and Homes
{ self, pkgs, ... }:
{
  users.users.user = {
    isNormalUser = true;
    createHome = true;
    home = "/home/user";
    initialPassword = "password"; # Initial password. Change immediately after the first login.
    extraGroups = [ "wheel" "networkmanager" "render" "input" "video" "audio" ]; # Add all your needed user groups, check Arch Wiki for a list of groups and their purpose.
    shell = pkgs.fish;
  };

  # Don't use Relative Paths as it is impure.
  # TODO: Correct this after setting up a home-manager.
  #home-manager.users.user.imports = [
  #  "${self}/homes/user/profiles/desktop.nix"
  #];
}
