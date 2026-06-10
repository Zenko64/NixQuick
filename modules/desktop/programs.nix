{
  flake.modules.nixos.desktop =
    { ... }:
    {
      programs = {
        dconf.enable = true;
        uwsm.enable = true;
      };
    };
}
