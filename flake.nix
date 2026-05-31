{
  description = "My Custom NixOS Configuration.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:denful/import-tree";
    easy-hosts.url = "github:tgirlcloud/easy-hosts";

    disko.url = "github:nix-community/disko";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      flake-parts,
      import-tree,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { config, ... }:
      {
        debug = true;
        systems = [ "x86_64-linux" ];

        # You can set this to whatever you want.
        # Local is the default everwhere.
        # All Framework Modules Are Under This Namespace.
        namespace = "local";

        imports = [
          inputs.flake-parts.flakeModules.modules
          (import-tree ./modules)
          (import-tree ./lib)
          inputs.easy-hosts.flakeModule
          inputs.disko.flakeModule
        ];

        easy-hosts = {
          path = ./hosts;
          autoConstruct = true;
          shared.modules = [
            config.flake.modules.nixos.core
          ];
        };

        # Development Shell For The Configuration
        # Start with "nix develop"
        perSystem =
          { pkgs, ... }:
          let
            installer = inputs.self.nixosConfigurations.installer.config.system.build;
          in
          {
            devShells.default = pkgs.mkShell {
              buildInputs = [
                pkgs.nixd
                pkgs.nixfmt

                # Testing Machine In Lab
                pkgs.nixos-anywhere
                pkgs.pixiecore
                pkgs.dnsmasq

                # Function "writeShellScriptBin", arg1: Script FileName, arg2: Script Content
                # This script starts the Pixiecore server to boot the OS in a debuggee machine in labs.
                (pkgs.writeShellScriptBin "netdev" ''
                  # This cleans up background processes when the script exits to avoid port conflicts.
                  cleanup() {
                    kill "$DNSMASQ_PID" "$PIXIECORE_PID" 2>/dev/null || true
                    wait "$DNSMASQ_PID" "$PIXIECORE_PID" 2>/dev/null || true
                      sudo iptables -t nat -D POSTROUTING -o $GATEWAY -j MASQUERADE 2>/dev/null || true
                      sudo iptables -D FORWARD -i $INTERNAL -o $GATEWAY -j ACCEPT 2>/dev/null || true
                      sudo iptables -D FORWARD -i $GATEWAY -o $INTERNAL -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || true
                      sudo ip addr del 10.0.0.1/24 dev $INTERNAL 2>/dev/null || true 
                  }
                  trap cleanup EXIT # Runs Cleanup On Exit Signal

                  if [[ $1 == "" ]]; then
                    echo "Usage: netdev <iface> <gatewayIface>"
                    exit 1
                  fi

                  INTERNAL=$1
                  GATEWAY=$2

                  # Extract the IP Address of the selected interface
                  IFACEIP=$(ip addr show $INTERNAL | grep -oP 'inet \K[\d.]+' | head -1)
                  IFACESTATE=$(ip link show $INTERNAL | awk '{print $9}')

                  if [[ $IFACESTATE == "" ]]; then
                    echo "Could not determine the state of the interface."
                    exit 1
                  fi

                  if [[ $IFACESTATE != "UP" || $IFACEIP == "" ]]; then
                    sudo ip link set $INTERNAL up
                    sudo ip addr add 10.0.0.1/24 dev $INTERNAL
                    IFACEIP=$(ip addr show $INTERNAL | grep -oP 'inet \K[\d.]+' | head -1)
                    sleep 1.5
                  fi

                  sudo sysctl -w net.ipv4.ip_forward=1
                  if [[ $GATEWAY == "" ]]; then
                    GATEWAY=$(sudo ip route show default | awk '{print $5}')
                  fi
                  sudo iptables -t nat -A POSTROUTING -o $GATEWAY -j MASQUERADE
                  sudo iptables -A FORWARD -i $INTERNAL -o $GATEWAY -j ACCEPT
                  sudo iptables -A FORWARD -i $GATEWAY -o $INTERNAL -m state --state RELATED,ESTABLISHED -j ACCEPT


                  if ! ping -4 -I $GATEWAY 1.1.1.1 -c 1 > /dev/null 2>&1; then
                    echo "Gateway Iface $GATEWAY does not have internet access.\nPlease ensure the gateway interface has internet access."
                    exit 1
                  fi

                  shift 2

                  # DNSMasq DHCP Server Assigns IP Addresses To The Debuggees
                  sudo ${pkgs.dnsmasq}/bin/dnsmasq \
                    -i $INTERNAL \
                    --bind-interfaces \
                    --dhcp-range 10.0.0.2,10.0.0.254,24h \
                    --dhcp-option=option:router,$IFACEIP \
                    --dhcp-option=option:dns-server,1.1.1.1,8.8.8.8 \
                    --no-resolv \
                    --no-hosts \
                    --no-daemon &
                  DNSMASQ_PID=$!

                  # Pixiecore Boots The Debuggees
                  sudo ${pkgs.pixiecore}/bin/pixiecore \
                    boot ${installer.kernel}/bzImage ${installer.netbootRamdisk}/initrd \
                    --cmdline "init=${installer.toplevel}/init loglevel=4" --debug \
                    --dhcp-no-bind \
                    --port 64172 --status-port 64172 "$@" &
                  PIXIECORE_PID=$!

                  wait "$DNSMASQ_PID" "$PIXIECORE_PID"
                '')
              ];
            };
          };
      }
    );
}
