# Services Definition File
{ ... }:
{
  # Enable Caddy Webserver
  services.caddy = {
    enable = true;
    virtualHosts = {
      "example.com" = {
        # Reverse Proxy Example
        extraConfig = ''
          encode gzip
          reverse_proxy localhost:8080
        '';
      };
    };
  };
}
