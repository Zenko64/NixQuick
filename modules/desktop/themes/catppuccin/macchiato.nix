# Catppuccin Macchiato (Stylix)
{ ... }:
let
  themeName = "catppuccin-macchiato";
  theme = pkgs: lib: {
    stylix = {
      enable = true;
      polarity = "dark";
      image = lib.mkDefault ./dark.png;

      base16Scheme = "${pkgs.base16-schemes}/share/themes/${themeName}.yaml";

      cursor = {
        package = pkgs.nordzy-cursor-theme;
        name = "Nordzy-catppuccin-macchiato-sky";
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
      config = lib.mkIf (config.${namespace}.desktop.theme == themeName) (theme pkgs lib) // {
        programs.cava = {
          settings.color = {
            background = "#24273a";

            gradient = 1;
            gradient_color_1 = "#8bd5ca";
            gradient_color_2 = "#91d7e3";
            gradient_color_3 = "#7dc4e4";
            gradient_color_4 = "#8aadf4";
            gradient_color_5 = "#c6a0f6";
            gradient_color_6 = "#f5bde6";
            gradient_color_7 = "#ee99a0";
            gradient_color_8 = "#ed8796";
          };
        };
      };
    };
}
