# Server Profile
{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    # Terminal toys
    clock-rs
    cmatrix
    pipes-rs
  ];

  programs = {
    fish.enable = true;

    # Toys
    fastfetch.enable = true;

    # Devtools
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
