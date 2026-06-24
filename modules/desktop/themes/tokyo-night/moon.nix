# Tokyo Night Moon (Stylix)
{ ... }:
let
  themeName = "tokyo-night-moon";
  theme = pkgs: lib: {
    stylix = {
      enable = true;
      polarity = "dark";

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
      config = lib.mkIf (config.${namespace}.desktop.theme == themeName) (theme pkgs lib);
    };
}
