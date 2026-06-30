{
  themeName,
  stylixConfig ? { ... }: { },
  hmExtra ? { ... }: { },
}:
{
  flake.modules.nixos.desktop =
    {
      config,
      namespace,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkMerge [
        { ${namespace}.desktop._themes = [ themeName ]; }
        (lib.mkIf (config.${namespace}.desktop.theme == themeName) (stylixConfig {
          inherit pkgs lib;
        }))
      ];
    };

  flake.modules.homeManager.desktop =
    {
      config,
      namespace,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkMerge [
        { ${namespace}.desktop._themes = [ themeName ]; }
        (lib.mkIf (config.${namespace}.desktop.theme == themeName) (
          lib.mkMerge [
            (stylixConfig { inherit pkgs lib; })
            (hmExtra { inherit pkgs lib; })
          ]
        ))
      ];
    };
}
