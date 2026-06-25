# Catppuccin Frappe (Stylix)
{ ... }:
let
  themeName = "catppuccin-frappe";
  theme = pkgs: lib: {
    stylix = {
      enable = true;
      polarity = "dark";
      image = lib.mkDefault ./dark.png;

      base16Scheme = "${pkgs.base16-schemes}/share/themes/${themeName}.yaml";

      cursor = {
        package = pkgs.nordzy-cursor-theme;
        name = "Nordzy-catppuccin-frappe-sky";
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
            background = "'#303446'";

            gradient = 1;
            gradient_color_1 = "'#81c8be'";
            gradient_color_2 = "'#99d1db'";
            gradient_color_3 = "'#85c1dc'";
            gradient_color_4 = "'#8caaee'";
            gradient_color_5 = "'#ca9ee6'";
            gradient_color_6 = "'#f4b8e4'";
            gradient_color_7 = "'#ea999c'";
            gradient_color_8 = "'#e78284'";
          };
        }
      );
    };
}
