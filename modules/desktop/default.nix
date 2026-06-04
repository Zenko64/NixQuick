# Desktop Main Module
# Contains Options and Essential Services
{ ... }:
let
  themeNames = [ "catppuccin-mocha" ];
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
      options.${namespace} = {
        desktop = {
          enable = lib.mkEnableOption "desktop environment support";
          theme = lib.mkOption {
            type = lib.types.nullOr (lib.types.enum themeNames);
            default = null;
            description = "Theme applied to the desktop environment.";
          };
        };
        greeter = lib.mkOption {
          type = lib.types.enum [
            null
            "greetd"
          ];
          default = null;
          description = "Login greeter to enable.";
        };
      };

      config = lib.mkIf config.${namespace}.desktop.enable {
        programs.dconf.enable = true;

        services.gvfs.enable = true;
        services.libinput.enable = true;
        services.upower.enable = true;

        services.pipewire = {
          enable = true;
          pulse.enable = true;
          wireplumber = {
            enable = true;
            # Save CPU cycles by skipping camera monitor.
            extraConfig."10-disable-camera" = {
              "wireplumber.profiles".main."monitor.libcamera" = "disabled";
            };
          };
        };
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
        type = lib.types.nullOr (lib.types.enum themeNames);
        default = osConfig.${namespace}.desktop.theme;
        description = "Theme applied to the desktop environment.";
      };
    };
}
