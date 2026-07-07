{
  flake.modules.homeManager.desktop =
    {
      lib,
      osConfig,
      config,
      namespace,
      pkgs,
      ...
    }:
    {
      config = lib.mkMerge [ # (MkMerge is needed since we are merging multiple settings and one of them is guarded)
        # Inject The Shell Module Into The Shells Registry
        { ${namespace}.desktop.compositors.hyprland._shells = [ "ashell" ]; }

        (lib.mkIf # Verify the shell and hyprland are enabled
          (
            osConfig.${namespace}.desktop.compositors.hyprland.enable
            && config.${namespace}.desktop.compositors.hyprland.shell == "ashell"
          )
          {
            # Enable the components this shell uses
            ${namespace}.desktop.compositors.hyprland._components = {
              walker.enable = true;
              hyprpaper.enable = true;
              hyprpolkit.enable = true;
              hyprlock.enable = true;
              hypridle = {
                enable = true;
                onIdle = lib.getExe pkgs.hyprlock; # Trigger Hyprlock on idle
              };
            };

            # Inject Shell-Specific Configuration Into Hyprland
            wayland.windowManager.hyprland.settings = {
              general.gaps_out = lib.mkForce "15 15 0 15";
              exec-once = [ "uwsm app -- ashell" ];
              layerrule = [
                "blur on, match:namespace ashell-main-layer"
                "blur on, match:namespace ashell-menu-layer"
                "ignore_alpha 0.5, match:namespace ashell-main-layer"
                "ignore_alpha 0.5, match:namespace ashell-menu-layer"
              ];
            };

            # Shell Configuration
            programs.ashell = {
              enable = true;
              settings = {
                log_level = "warn";

                position = "Top";

                modules = {
                  left = [
                    "appLauncher"
                    "Workspaces"
                  ];
                  center = [ "WindowTitle" ];
                  right = [
                    "MediaPlayer"
                    "Tray"
                    [
                      "SystemInfo"
                      "Tempo"
                      "Notifications"
                      "Privacy"
                      "Settings"
                    ]
                  ];
                };

                workspaces = {
                  visibility_mode = "All";
                  group_by_monitor = false;
                  enable_workspace_filling = true;
                };

                CustomModule = [
                  {
                    name = "appLauncher";
                    icon = " 󰀶  ";
                    command = "walker";
                  }
                ];

                system_info = {
                  indicators = [
                    "Memory"
                    "Temperature"
                  ];
                };

                window_title = {
                  mode = "Title";
                  truncate_title_after_length = 64;
                };

                media_player = {
                  truncate_title_after_length = 64;
                };

                tempo = {
                  clock_format = "%a %d - %R";
                  weather_location = {
                    City = "${config.${namespace}.desktop.settings.weather.location}";
                  };
                  weather_indicator = "IconAndTemperature";
                };

                notifications = {
                  format = "%m/%d %H:%M";
                  show_timestamps = true;
                  show_bodies = false;
                  grouped = true;
                  toast = true;
                  toast_position = "top_right";
                  toast_timeout = 4000;
                  toast_limit = 5;
                  toast_max_height = 150;
                  blocklist = [
                    "blueman"
                    "^org\\.gnome\\."
                  ];
                };

                settings = {
                  lock_cmd = "playerctl --all-players pause; hyprlock &";
                  audio_sinks_more_cmd = "pwvucontrol -t 3";
                  audio_sources_more_cmd = "pwvucontrol -t 4";
                  wifi_more_cmd = "nm-connection-editor";
                  vpn_more_cmd = "nm-connection-editor";
                  bluetooth_more_cmd = "blueman-manager";
                  battery_format = "IconAndPercentage";
                  peripheral_battery_format = "Icon";
                  audio_indicator_format = "Icon";
                  microphone_indicator_format = "Icon";
                  network_indicator_format = "Icon";
                  bluetooth_indicator_format = "Icon";
                  brightness_indicator_format = "Icon";
                  indicators = [
                    "IdleInhibitor"
                    "PowerProfile"
                    "Vpn"
                    "Network"
                    "Audio"
                    "Battery"
                  ];
                };

                appearance = {
                  scale_factor = 1.12;
                  style = "Islands";
                };
              };
            };
          }
        )
      ];
    };
}
