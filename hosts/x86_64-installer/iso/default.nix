# X86 NixOS Installer Configuration
{
  inputs,
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [ "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix" ];

  environment.systemPackages = [
    inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}.disko
    inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}.disko-install
  ];
}
