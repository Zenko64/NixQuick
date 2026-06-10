{
  flake.modules.nixos.desktop =
    let
      greeters = [
        "tuigreet"
        "regreet"

        "sddm"
        "lightdm"
        "ly"
      ];
    in
    {
      lib,
      namespace,
      ...
    }:
    {
      options.${namespace}.desktop.greeter = lib.mkOption {
        type = lib.types.nullOr (lib.types.enum greeters);
        default = null;
        description = "Login greeter to enable.";
      };
    };
}
