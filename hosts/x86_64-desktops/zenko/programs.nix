# Programs and Services
{ pkgs, ... }:
{
  programs = {
    fish.enable = true;
    steam.enable = true;
  };

  services = {
    asusd.enable = true;
    ollama = {
      enable = false;
      package = pkgs.ollama-cuda;
    };
  };
}
