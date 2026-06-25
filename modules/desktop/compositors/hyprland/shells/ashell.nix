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
      config =
        lib.mkIf
          (
            osConfig.${namespace}.desktop.compositors.hyprland.enable == true
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

            # Rules
            wayland.windowManager.hyprland.settings = {
              gaps_out = "15 15 10 15";
              exec-once = [ "uwsm app -- ashell" ];
              layerrule = [
                "blur on, match:namespace ashell-main-layer"
                "ignore_alpha 0, match:namespace ashell-main-layer"
              ];
            };

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
                      "Notifications"
                      "Tempo"
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
          };
    };
}
