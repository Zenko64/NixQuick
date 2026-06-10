# Desktop Packages Module
{
  flake.modules.nixos.desktop =
    {
      pkgs,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        brightnessctl
      ];
    };
}
