# Compositor Registry
{
  flake.modules.nixos.desktop =
    {
      config,
      lib,
      namespace,
      ...
    }:
    {
      # Assert that there is only a single compositor enabled at a time.
      config.assertions = [
        {
          assertion = lib.count (c: c.enable) (lib.attrValues config.${namespace}.desktop.compositors) <= 1;
          message = "[ ${namespace}.desktop.compositors ]: Only a single compositor can be enabled at a time!";
        }
      ];
    };
}
