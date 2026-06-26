# X86 NixOS Installer PXE Configuration
{
  inputs,
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [ "${modulesPath}/installer/netboot/netboot.nix" ];

  environment.systemPackages = [
    inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}.disko
    inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}.disko-install
  ];
}
