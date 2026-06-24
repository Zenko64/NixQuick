# Programs and Services
{ pkgs, ... }:
{
  programs = {
    nix-ld.enable = true;

    nh = {
      enable = true;
      flake = "/etc/nixos";
    };

    fish.enable = true;

    gamescope = {
      enable = true;
      capSysNice = true;
    };
    steam.gamescopeSession.enable = true;
    steam.enable = true;
  };

  services = {
    ollama = {
      enable = true;
      package = pkgs.ollama-cuda;
    };
  };
}
