# Programs and Services
{ pkgs, ... }:
{
  programs = {
    # Needed in some cases for development.
    # nix-ld.enable = true;

    fish.enable = true;

    # Steam and Gamescope (Includes Deck Ui)
    #gamescope = {
    #  enable = true;
    #  capSysNice = true;
    #};
    #steam.gamescopeSession.enable = true;
    #steam.enable = true;
  };

  services = {
    # EXAMPLE: Enable Ollama for CUDA (Ai Model Runner)
    #ollama = {
    #  enable = true;
    #  package = pkgs.ollama-cuda;
    #};
  };
}
