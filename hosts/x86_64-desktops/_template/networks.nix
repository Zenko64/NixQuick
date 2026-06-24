# Network Configuration
{ ... }:
{
  # Example Open a Port Range in Firewall
  #networking.firewall.allowedTCPPortRanges = [
  #  {
  #    from = 4000;
  #    to = 5000;
  #  }
  #];

  # Don't block boot on Network Connectivity.
  systemd.network.wait-online.enable = false;
  boot.initrd.systemd.network.wait-online.enable = false;
}
