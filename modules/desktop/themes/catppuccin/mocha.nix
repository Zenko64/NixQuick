# Catppuccin Mocha (Stylix)
{ ... }:
let
  themeName = "catppuccin-mocha";
  theme = pkgs: lib: {
    stylix = {
      enable = true;
      polarity = "dark";
      image = lib.mkDefault ./dark.png;

      base16Scheme = "${pkgs.base16-schemes}/share/themes/${themeName}.yaml";

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
      pkgs,
      ...
    }:
    {
      config = lib.mkIf (config.${namespace}.desktop.theme == themeName) (theme pkgs lib);
    };

  flake.modules.homeManager.desktop =
    {
      config,
      lib,
      namespace,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf (config.${namespace}.desktop.theme == themeName) (
        (theme pkgs lib)
        // {
          programs.cava.settings.color = {
            background = "'#1e1e2e'";

            gradient = 1;
            gradient_color_1 = "'#94e2d5'";
            gradient_color_2 = "'#89dceb'";
            gradient_color_3 = "'#74c7ec'";
            gradient_color_4 = "'#89b4fa'";
            gradient_color_5 = "'#cba6f7'";
            gradient_color_6 = "'#f5c2e7'";
            gradient_color_7 = "'#eba0ac'";
            gradient_color_8 = "'#f38ba8'";
          };
        }
      );
    };
}
