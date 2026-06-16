{ ... }: {
  services.home-assistant = {
    enable = true;
    extraComponents = [
      "default_config"
    ];
  };
  networking.firewall.allowedTCPPorts = [ 8123 ];
}
