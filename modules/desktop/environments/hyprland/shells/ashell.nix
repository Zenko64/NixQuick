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
            osConfig.${namespace}.desktop.environments.hyprland.enable == true
            && config.${namespace}.desktop.environments.hyprland.shell == "ashell"
          )
          {

            # We have to do this because Home-Manager needs to auto-style it
            #services.mako.enable = true;
#
            #home.packages = with pkgs; [
            #  awww
            #  elephant
            #  walker
#
            #  hyprlock
            #  hypridle
            #];

            # We don't want these to be started by SystemD because it might interfere with other compositors
            # Force Disable SystemD services
            #systemd.user.services = {
            #  mako = lib.mkForce { };
            #};

            #wayland.windowManager.hyprland.settings = {
            #  exec-once = [
            #    "uwsm app -- ${lib.getExe pkgs.ashell}"
            #    "uwsm app -- ${lib.getExe pkgs.mako}"
            #    "uwsm app -- ${lib.getExe pkgs.elephant}"
            #    "uwsm app -- sh -c \"${lib.getExe pkgs.walker} --gapplication-service\""
            #  ];
            #  bind = [
            #    "SUPER, R, exec, ${lib.getExe pkgs.walker}"
            #  ];
            #};

            services.mako.enable = true;

            home.packages = with pkgs; [
              awww
              elephant
              walker

              hyprlock
              hypridle
            ];

            wayland.windowManager.hyprland.extraConfig = ''
              bind = SUPER, R, exec, ${pkgs.walker}/bin/walker
              bind = SUPER, L, exec, ${pkgs.hyprlock}/bin/hyprlock

              exec-once = uwsm app -- ${pkgs.ashell}/bin/ashell
              exec-once = uwsm app -- ${pkgs.hypridle}/bin/hypridle
              exec-once = uwsm app -- ${pkgs.elephant}/bin/elephant
              exec-once = uwsm app -- sh -c "${pkgs.walker}/bin/walker --gapplication-service"
              exec-once = uwsm app -- ${pkgs.mako}/bin/mako

              layerrule = blur on, match:namespace ashell-main-layer
              layerrule = ignore_alpha 0, match:namespace ashell-main-layer
            '';

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

                tempo = {
                  clock_format = "%a %d - %R";
                  weather_location = {
                    City = "Loulé";
                  };
                  weather_indicator = "IconAndTemperature";
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
                  style = "Islands";
                  #opacity = 0.72;
                  #menu.opacity = 0.72;
                  # primary_color = "#ff96dc";
                  # success_color = "#ff96dc";
                  # text_color = "#dbe3ff";
                  #  workspace_colors = [
                  #    "#ff96dc"
                  #    "#104e64"
                  #  ];
                  #  special_workspace_colors = [
                  #    "#104e64"
                  #    "#ff96dc"
                  #  ];
                  #  background_color = {
                  #    base = "#281e19";
                  #    weak = "#292524";
                  #    strong = "#0c0d14";
                  #  };
                  #  danger_color = {
                  #    base = "#f37671";
                  #    weak = "#ffdf7b";
                  #  };
                  #  secondary_color.base = "#292524";
                  #};
                };
              };
            };
          };
    };
}
