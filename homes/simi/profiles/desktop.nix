# Desktop Profile
{
  pkgs,
  ...
}:
{
  local.desktop = {
    theme = "catppuccin-macchiato";
    wallpaper = null;
  };

  services.linux-wallpaperengine = {
    enable = true;
    assetsPath = /mnt/files/Games/Steam/steamapps/common/wallpaper_engine/assets;
  };

  home.packages = with pkgs; [
    # Desktop Apps
    gnome-software
    (discord.override {
      withOpenASAR = true;
      withVencord = true;
    })
    waypaper

    # Development Tools
    claude-code
    devenv

    # Terminal toys
    clock-rs
    cmatrix
    pipes-rs

    # Tools
    gotop
  ];

  programs = {
    fish.enable = true;
    # Desktop Apps
    firefox.enable = true;
    neovide.enable = true;
    obsidian.enable = true;
    thunderbird.enable = true;
    vscode = {
      enable = true;
      mutableExtensionsDir = true;
    };

    # Toys
    cava.enable = true;
    fastfetch.enable = true;

    # Devtools
    direnv.enable = true;
    neovim.enable = true;
    git = {
      enable = true;
      settings.user = {
        name = "simi";
        email = "simi.git@outlook.com";
      };
    };
  };
}
