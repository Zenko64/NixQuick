# Hyprland Window Manager Module
{ ... }:
{
  # System Side Defaults
  flake.modules.nixos.desktop =
    {
      lib,
      pkgs,
      config,
      namespace,
      inputs,
      ...
    }:
    {
      options.${namespace}.desktop.compositors.hyprland.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enables the Hyprland Window Manager.";
      };

      config = lib.mkIf config.${namespace}.desktop.compositors.hyprland.enable {
        programs.hyprland = {
          enable = true;
          withUWSM = true;

          package = # UWSM Patches
            inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland.overrideAttrs (prev: {
              # Patch out unnecessary desktop entries
              postInstall = (prev.postInstall or "") + ''
                rm $out/share/wayland-sessions/hyprland.desktop
                substituteInPlace $out/share/wayland-sessions/hyprland-uwsm.desktop \
                  --replace-fail "Name=Hyprland (uwsm-managed)" "Name=Hyprland"

                substituteInPlace $out/share/wayland-sessions/hyprland-uwsm.desktop \
                  --replace-fail "Exec=uwsm start -e -D Hyprland hyprland.desktop" \
                  "Exec=uwsm start -e -D Hyprland -- $out/bin/start-hyprland"
              '';
              passthru.providedSessions = [ "hyprland-uwsm" ];
            });
        };
      };
    };

  # Home-Manager Configurations
  flake.modules.homeManager.desktop =
    {
      lib,
      pkgs,
      config,
      osConfig,
      namespace,
      ...
    }:
    {
      # User-Side Configurations
      config = lib.mkIf osConfig.${namespace}.desktop.compositors.hyprland.enable {
        home.packages = with pkgs; [
          pwvucontrol
          nwg-displays
          libnotify
        ];

        # Seed Empty NWG-Displays Config to avoid errors.
        systemd.user.tmpfiles.rules = [
          "f ${config.home.homeDirectory}/.config/hypr/monitors.conf 0644 ${config.home.username} users -"
          "f ${config.home.homeDirectory}/.config/hypr/workspaces.conf 0644 ${config.home.username} users -"
        ];

        wayland.windowManager.hyprland = {
          enable = true;
          configType = "hyprlang";

          # UWSM-Managed. Keep OFF.
          systemd.enable = false;

          # Use the host portal and package configuration.
          # Do NOT Remove.
          package = null;
          portalPackage = null;

          # Import the settings
          settings = import ./_settings.nix {
            inherit config lib pkgs;
          };

          # QOL ExtraConfig
          extraConfig = ''
            windowrule {
                name = suppress-maximize-events
                match:class = .*
                suppress_event = maximize
            }
            windowrule {
                name = fix-xwayland-drags
                match:class = ^$
                match:title = ^$
                match:xwayland = true
                match:float = true
                match:fullscreen = false
                match:pin = false
                no_focus = true
            }
          '';
        };
      };
    };
}
