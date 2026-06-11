# Nix Daemon Configuration Module
{
  flake.modules.nixos.core =
    { ... }:
    {
      nix.settings.auto-optimise-store = true;
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      nixpkgs.config = {
        allowUnfree = true;
      };
    };
}
