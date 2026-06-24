{
  flake.modules.nixos.desktop = { lib, namespace, ... }: {
    options.${namespace}.desktop.settings.weather = {
      location = lib.mkOption {
        type = lib.types.str;
        default = "New York";
        description = "Location used for weather widgets.";
      };
    };
  };

  flake.modules.homeManager.desktop =
    {
      lib,
      namespace,
      osConfig,
      ...
    }:
    {
      options.${namespace}.desktop.settings.weather = {
        location = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = osConfig.${namespace}.desktop.settings.weather.location;
          description = "Location used for weather widgets.";
        };
      };
    };
}
