{
  flake.modules.nixos.server =
    {
      config,
      namespace,
      lib,
      ...
    }:
    {
      options.${namespace}.security.trustedIP = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "List Of Trusted IP Addresses.";
      };

      config = {
        security = {
          # Enable process confinement
          apparmor = {
            enable = true;
            killUnconfinedConfinables = true;
          };

          # Log reads and writes to sensitive directories
          auditd.enable = true;
          audit = {
            enable = true;
            rules = [
            ];
          };
        };
        services = {
          fail2ban = {
            enable = true;

            maxretry = 6;
            bantime = "30m";

            ignoreIP = [
              "127.0.0.1/8"
              "::1/128"
            ]
            ++ config.${namespace}.security.trustedIP;
          };
        };
      };
    };
}
