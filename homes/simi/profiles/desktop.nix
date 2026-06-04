# Desktop Profile
{
  pkgs,
  ...
}:
{
  stylix = {
    image = ../wallpapers/Koi.png;
  };

  home.packages = with pkgs; [
    hyprpaper
    # Desktop Apps
    bitwarden-desktop
    gnome-software
    (discord.override {
      withOpenASAR = true;
      withVencord = true;
    })

    # Development Tools
    claude-code
    devenv

    # Terminal toys
    clock-rs
    cmatrix
    pipes-rs
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
