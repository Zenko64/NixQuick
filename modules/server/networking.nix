{
  flake.modules.nixos.server =
    { ... }:
    {
      systemd.network.enable = true;
    };
}
