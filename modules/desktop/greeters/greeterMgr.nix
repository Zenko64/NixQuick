# Greeter Registry
{
  flake.modules.nixos.greeters =
    {
      config,
      lib,
      namespace,
      ...
    }:
    {
      # Assert that there is only a single greeter enable at a time.
      config.assertions = [
        {
          assertion = lib.count (c: c.enable) (lib.attrValues config.${namespace}.desktop.greeters) <= 1;
          message = "[ ${namespace}.desktop.greeters ]: Only a single greeter can be enabled at a time!";
        }
      ];
    };
}
