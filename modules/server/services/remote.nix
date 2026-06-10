{
  flake.modules.nixos.server =
    { ... }:
    {
      services = {
        openssh = {
          enable = true;
          ports = [ 22 ];

          # Security Hardening
          settings = {
            PubkeyAuthentication = true;
            PasswordAuthentication = false;
            KbdInteractiveAuthentication = false;
            PermitRootLogin = "prohibit-password";

            AllowGroups = [ "users" ];
            MaxAuthTries = 6;

            UseDns = false;
            X11Forwarding = false;
            StrictModes = true;
          };
        };
      };
      programs.mosh.enable = true;
    };
}
