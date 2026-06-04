{ ... }:
let
  shells = [ "ashell" ];
  notifs = [ "mako" ];
  launchers = [ "walker" ];
in
{

  flake.modules.nixos.desktop =
    { ... }:
    {
    };
}
