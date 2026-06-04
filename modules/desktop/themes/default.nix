{ ... }:
let
  themes = [ "catppuccin-mocha" "catppuccin-macchiato" "catppuccin-latte" "catppuccin-frappe" "tokyo-night-dark" "tokyo-night-storm" "tokyo-night-moon" "tokyo-night-light"];
in
{
  # System Side Defaults
  flake.modules.nixos.desktop =
    { namespace, lib, ... }:
    {
      options.${namespace}.desktop.theme = lib.mkOption {
        type = lib.types.nullOr (lib.types.enum themes);
        default = null;
        description = "Theme to apply to the desktop environment.";
      };
    };

  # Home-Manager Overrides
  flake.modules.homeManager.desktop =
    {
      namespace,
      lib,
      osConfig,
      ...
    }:
    {
      options.${namespace}.desktop.theme = lib.mkOption {
        type = lib.types.nullOr (lib.types.enum themes);
        default = osConfig.${namespace}.desktop.theme;
        description = "Theme to apply to the desktop environment.";
      };
    };
}
