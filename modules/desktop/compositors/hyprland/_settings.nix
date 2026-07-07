{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Variables
  "$mainMod" = "SUPER";
  "$altMod" = "SHIFT";
  "$subMod" = "CONTROL";

  # Environment
  # Set XCursor and Hyprcursor from themes
  env = [
    "HYPRCURSOR_SIZE,24"
    "XCURSOR_SIZE,24"
  ];

  # Layout
  general = {
    allow_tearing = false;
    border_size = 3;
    extend_border_grab_area = 15;
    gaps_in = 5;
    gaps_out = "15";
    layout = "dwindle";
    resize_on_border = true;
  };

  dwindle = {
    preserve_split = true;
  };
  master.new_status = "master";

  # Visuals
  decoration = {
    active_opacity = 0.95;
    inactive_opacity = 0.825;
    rounding = 10;
    blur = {
      enabled = true;
      passes = 3;
      size = 5;
      vibrancy = 1.25;
      ignore_opacity = true;
      noise = 0.05;
      contrast = 1.5;
    };
  };

  # Animations
  animations = {
    enabled = true;
    bezier = [
      "easeOutQuint,   0.23, 1,    0.32, 1"
      "easeInOutCubic, 0.65, 0.05, 0.36, 1"
      "linear,         0,    0,    1,    1"
      "almostLinear,   0.5,  0.5,  0.75, 1"
      "quick,          0.15, 0,    0.1,  1"
    ];
    animation = [
      "borderangle,   1, 250,  linear,       loop"
      "global,        1, 10,   default"
      "border,        1, 5.5, easeOutQuint"
      "windows,       1, 4.8, easeOutQuint"
      "windowsIn,     1, 4.2,  easeOutQuint, popin 85%"
      "windowsOut,    1, 1.5, linear,       popin 85%"
      "fadeIn,        1, 1.75, almostLinear"
      "fadeOut,       1, 1.5, almostLinear"
      "fade,          1, 3, quick"
      "layers,        1, 3.8, easeOutQuint"
      "layersIn,      1, 4,    easeOutQuint, fade"
      "layersOut,     1, 1.5,  linear,       fade"
      "fadeLayersIn,  1, 1.8, almostLinear"
      "fadeLayersOut, 1, 1.3, almostLinear"
      "workspaces,    1, 2, almostLinear, fade"
      "workspacesIn,  1, 1.25, almostLinear, fade"
      "workspacesOut, 1, 2, almostLinear, fade"
      "zoomFactor,    1, 7,    quick"
    ];
  };

  # Input
  input = {
    follow_mouse = 1;
    sensitivity = 0;
    touchpad = {
      clickfinger_behavior = true;
      natural_scroll = true;
    };
  };
  gesture = "3, horizontal, workspace";

  # Keybinds
  bindel = [
    ", XF86AudioRaiseVolume, exec, ${lib.getExe' pkgs.wireplumber "wpctl"} set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
    ", XF86AudioLowerVolume, exec, ${lib.getExe' pkgs.wireplumber "wpctl"} set-volume @DEFAULT_AUDIO_SINK@ 5%-"
    ", XF86MonBrightnessUp, exec, ${lib.getExe pkgs.brightnessctl} s 5%+"
    ", XF86MonBrightnessDown, exec, ${lib.getExe pkgs.brightnessctl} s 5%-"
  ];
  bindl = [
    ", XF86AudioMute, exec, ${lib.getExe' pkgs.wireplumber "wpctl"} set-mute @DEFAULT_AUDIO_SINK@ toggle"
    ", XF86AudioMicMute, exec, ${lib.getExe' pkgs.wireplumber "wpctl"} set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
    ", XF86AudioPlay, exec, ${lib.getExe pkgs.playerctl} play-pause"
    ", XF86AudioNext, exec, ${lib.getExe pkgs.playerctl} next"
    ", XF86AudioPrev, exec, ${lib.getExe pkgs.playerctl} previous"
  ];

  bind = [
    # Window focus
    "$mainMod, W, movefocus, u"
    "$mainMod, A, movefocus, l"
    "$mainMod, S, movefocus, d"
    "$mainMod, D, movefocus, r"
    "$mainMod, up,    movefocus, u"
    "$mainMod, left,  movefocus, l"
    "$mainMod, down,  movefocus, d"
    "$mainMod, right, movefocus, r"

    # Window move
    "$mainMod $altMod, W, movewindow, u"
    "$mainMod $altMod, A, movewindow, l"
    "$mainMod $altMod, S, movewindow, d"
    "$mainMod $altMod, D, movewindow, r"
    "$mainMod $altMod, up,    movewindow, u"
    "$mainMod $altMod, left,  movewindow, l"
    "$mainMod $altMod, down,  movewindow, d"
    "$mainMod $altMod, right, movewindow, r"

    # Workspace switch
    "$mainMod, 1, workspace, 1"
    "$mainMod, 2, workspace, 2"
    "$mainMod, 3, workspace, 3"
    "$mainMod, 4, workspace, 4"
    "$mainMod, 5, workspace, 5"
    "$mainMod, 6, workspace, 6"
    "$mainMod, 7, workspace, 7"
    "$mainMod, 8, workspace, 8"
    "$mainMod, 9, workspace, 9"
    "$mainMod, 0, workspace, 10"

    # Workspace move
    "$mainMod $altMod, 1, movetoworkspace, 1"
    "$mainMod $altMod, 2, movetoworkspace, 2"
    "$mainMod $altMod, 3, movetoworkspace, 3"
    "$mainMod $altMod, 4, movetoworkspace, 4"
    "$mainMod $altMod, 5, movetoworkspace, 5"
    "$mainMod $altMod, 6, movetoworkspace, 6"
    "$mainMod $altMod, 7, movetoworkspace, 7"
    "$mainMod $altMod, 8, movetoworkspace, 8"
    "$mainMod $altMod, 9, movetoworkspace, 9"
    "$mainMod $altMod, 0, movetoworkspace, 10"

    # Special workspace
    "$mainMod, Z, togglespecialworkspace, Magic"
    "$mainMod $altMod, Z, movetoworkspace, special:Magic"

    # Window control
    "$mainMod $altMod, Q, killactive"
    "$mainMod $altMod, F, fullscreen,"
    "$mainMod $altMod, X, layoutmsg, togglesplit"
    "$mainMod $subMod, F, togglefloating"
    "$mainMod $subMod, Space, pseudo"

    # Mouse workspace switch
    "$mainMod, mouse_down, workspace, e+1"
    "$mainMod, mouse_up,   workspace, e-1"
  ];

  binde = [
    "$mainMod $subMod, W, resizeactive, 0 -50"
    "$mainMod $subMod, A, resizeactive, -50 0"
    "$mainMod $subMod, S, resizeactive, 0 50"
    "$mainMod $subMod, D, resizeactive, 50 0"
    "$mainMod $subMod, up,    resizeactive, 0 -50"
    "$mainMod $subMod, left,  resizeactive, -50 0"
    "$mainMod $subMod, down,  resizeactive, 0 50"
    "$mainMod $subMod, right, resizeactive, 50 0"
  ];

  bindm = [
    "$mainMod, mouse:272, movewindow"
    "$mainMod, mouse:273, resizewindow"
  ];

  layerrule = [
    "blur on, match:namespace notifications"
    "ignore_alpha 0, match:namespace notifications"
  ];

  source = [
    "${config.home.homeDirectory}/.config/hypr/monitors.conf"
    "${config.home.homeDirectory}/.config/hypr/workspaces.conf"
  ];
}
