# Networking Module
# Override Default Settings Put Here Per Host.
{
  flake.modules.nixos.core =
    { ... }:
    {
      networking.firewall = {
        enable = true;
        allowPing = true;
      };
    };
}
