# Regreet Login Greeter
{
  flake.modules.nixos.greeters =
    {
      config,
      lib,
      namespace,
      ...
    }:
    {
      options.${namespace}.desktop.greeters.regreet = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enables the Regreet Login Greeter.";
        };
      };
      config = lib.mkIf (config.${namespace}.desktop.greeters.regreet.enable) {
        services.greetd = {
          enable = true;

          programs.regreet = {
            enable = true;
          };
        };
      };
    };
}
