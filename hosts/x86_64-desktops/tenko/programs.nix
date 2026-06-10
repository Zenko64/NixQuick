# Programs and Services
{ pkgs, ... }:
{
  programs = {
    nix-ld.enable = true;
    steam.enable = true;
  };

  services = {
    ollama = {
      enable = true;
      package = pkgs.ollama-cuda;
    };
  };
}
