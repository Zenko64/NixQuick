{ ... }:
let
  themes = [
    "catppuccin-mocha"
    "catppuccin-macchiato"
    "catppuccin-latte"
    "catppuccin-frappe"
    "tokyo-night-dark"
    "tokyo-night-storm"
    "tokyo-night-moon"
    "tokyo-night-light"
  ];
in
{
  # System Side Defaults
  flake.modules.nixos.desktop =
    {
      namespace,
      lib,
      config,
      ...
    }:
    {
      options.${namespace}.desktop = {
        theme = lib.mkOption {
          type = lib.types.nullOr (lib.types.enum themes);
          default = null;
          description = "Theme to apply to the desktop environment.";
        };
        wallpaper = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "Wallpaper to apply to the desktop environment.";
        };
      };

      # If statement stops null value from overriding theme images
      config.stylix.image = lib.mkIf (
        config.${namespace}.desktop.wallpaper != null
      ) config.${namespace}.desktop.wallpaper;
    };

  # Home-Manager Overrides
  flake.modules.homeManager.desktop =
    {
      namespace,
      lib,
      osConfig,
      config,
      ...
    }:
    {
      options.${namespace}.desktop = {
        theme = lib.mkOption {
          type = lib.types.nullOr (lib.types.enum themes);
          default = osConfig.${namespace}.desktop.theme;
          description = "Theme to apply to the desktop environment.";
        };
        wallpaper = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = osConfig.${namespace}.desktop.wallpaper;
          description = "Wallpaper to apply to the desktop environment.";
        };
      };

      # If statement stops null value from overriding theme images
      config = {
        stylix = {
          opacity = {
            applications = 0.85;
            desktop = 0.875;
            popups = 0.9;
            terminal = 0.85;
          };

          image = lib.mkIf (
            config.${namespace}.desktop.wallpaper != null
          ) config.${namespace}.desktop.wallpaper;
        };
      };
    };
}
