# Catppuccin Mocha (Stylix)
{ ... }:
let
  themeName = "catppuccin-mocha";
  theme =
    { pkgs, ... }:
    {
      stylix = {
        enable = true;
        polarity = "dark";

        base16Scheme = "${pkgs.base16-schemes}/share/themes/${themeName}.yaml";

        opacity.desktop = 0.8;
        opacity.popups = 0.8;

        cursor = {
          package = pkgs.nordzy-cursor-theme;
          name = "Nordzy-catppuccin-mocha-sky";
          size = 24;
        };
        icons = {
          enable = true;
          package = pkgs.nordzy-icon-theme;
          dark = "Nordzy-cyan-dark";
          light = "Nordzy-cyan";
        };
      };
    };
in
{
  flake.modules.nixos.desktop =
    {
      config,
      lib,
      namespace,
      ...
    }:
    {
      config = lib.mkIf (config.${namespace}.desktop.theme == themeName) theme;
    };

  flake.modules.homeManager.desktop =
    {
      config,
      lib,
      namespace,
      ...
    }:
    {
      config = lib.mkIf (config.${namespace}.desktop.theme == themeName) theme;
    };
}
