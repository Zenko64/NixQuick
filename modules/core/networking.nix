# The Networking Module
# These Options Can Be Overriden Directly On Each Host.
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
