{ ... }:
let
  # Missing Theme Error Assertion
  themeAssertion = namespace: cfg: [
    {
      assertion = cfg.theme == null || builtins.elem cfg.theme cfg._themes;
      message = "[ ${namespace}.desktop.theme ]: '${toString cfg.theme}' does not exist. Available Themes: [${builtins.concatStringsSep ", " cfg._themes}].";
    }
  ];
in
{
  # System Side
  flake.modules.nixos.desktop =
    {
      namespace,
      lib,
      config,
      ...
    }:
    {
      options.${namespace}.desktop = {
        _themes = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          internal = true;
          description = "Registered theme names.";
        };
        theme = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Theme to apply to the desktop. Must be one of `config.${namespace}.desktop._themes`.";
        };
        wallpaper = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "Wallpaper to apply to the desktop environment.";
        };
      };

      config = {
        assertions = themeAssertion namespace config.${namespace}.desktop;

        # If statement stops null value from overriding theme images
        stylix.image = lib.mkIf (
          config.${namespace}.desktop.wallpaper != null
        ) config.${namespace}.desktop.wallpaper;
      };
    };

  # Home-Manager Side (per-home override of the host default)
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
        _themes = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          internal = true;
          description = "Registered theme names.";
        };
        theme = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = osConfig.${namespace}.desktop.theme;
          description = "Theme to apply to this home.";
        };

        wallpaper = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = osConfig.${namespace}.desktop.wallpaper;
          description = "Wallpaper to apply to this home.";
        };
      };

      config = {
        assertions = themeAssertion namespace config.${namespace}.desktop;

        stylix = {
          # If statement stops null value from overriding theme images
          image = lib.mkIf (
            config.${namespace}.desktop.wallpaper != null
          ) config.${namespace}.desktop.wallpaper;
        };
      };
    };
}
