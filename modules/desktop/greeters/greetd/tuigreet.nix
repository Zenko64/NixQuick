# Greetd Login Greeter
{
  flake.modules.nixos.desktop =
    {
      config,
      lib,
      namespace,
      pkgs,
      ...
    }:
    {
      config.services.greetd = lib.mkIf (config.${namespace}.desktop.greeter == "tuigreet") {
        enable = true;
        settings.default_session =
          let
            exec = "${lib.getExe pkgs.tuigreet}";
            sessionsDir = "${config.services.displayManager.sessionData.desktops}";
            xSessions = "${sessionsDir}/share/xsessions";
            waylandSessions = "${sessionsDir}/share/wayland-sessions";

            greeterOptions = lib.concatStringsSep " " [
              "--remember"
              "--remember-session"
              "--sessions ${waylandSessions}:${xSessions}"
              "--time"
            ];
          in
          {
            command = "${exec} ${greeterOptions}";
            user = "greeter";
          };
      };
    };
}
