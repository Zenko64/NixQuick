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
    # Terminal Shell Configuration
    fish.enable = true;

    # Toys
    fastfetch.enable = true;

    # Devtools
    neovim.enable = true;
    git = {
      enable = true;
      settings.user = {
        name = "user";
        email = "user.mail@example.com";
      };
    };
  };
}
