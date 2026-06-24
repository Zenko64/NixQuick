# Catppuccin Latte (Stylix)
{ ... }:
let
  themeName = "catppuccin-latte";
  theme = pkgs: lib: {
    stylix = {
      enable = true;
      polarity = "light";
      image = lib.mkDefault ./light.png;

      base16Scheme = "${pkgs.base16-schemes}/share/themes/${themeName}.yaml";

      cursor = {
        package = pkgs.nordzy-cursor-theme;
        name = "Nordzy-catppuccin-latte-sky";
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
            background = "#eff1f5";

            gradient = 1;
            gradient_color_1 = "#179299";
            gradient_color_2 = "#04a5e5";
            gradient_color_3 = "#209fb5";
            gradient_color_4 = "#1e66f5";
            gradient_color_5 = "#8839ef";
            gradient_color_6 = "#ea76cb";
            gradient_color_7 = "#e64553";
            gradient_color_8 = "#d20f39";
          };
        };
      };
    };
}
