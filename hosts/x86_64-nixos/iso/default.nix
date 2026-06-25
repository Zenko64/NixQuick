# X86 NixOS Installer Configuration
{
  namespace,
  inputs,
  modulesPath,
  pkgs,
  ...
}:
let
  sshPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILQyfvGLHb+gMY1dzUZp1ckpktrdF204scLSJc/wxVq0 simi@zenko";
in
{
  imports = [ "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix" ];

  ${namespace}.boot.secureBoot = false;

  boot.blacklistedKernelModules = [ "nouveau" ];

  environment = {
    etc."nixos".source = inputs.self;
    systemPackages = with pkgs; [
      inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}.disko
      inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}.disko-install

      git
      vim
    ];
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  # Key to access the debuggee installer over SSH.
  users.users.root = {
    openssh.authorizedKeys.keys = [
      sshPubKey
    ];
  };
}
