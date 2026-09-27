{...}: {
  flake.modules.nixos.base = {...}: {
    networking.hostName = "nixos";
    networking.wireless.enable = true;

    networking.networkmanager.enable = true;
    networking.useNetworkd = true;

    services.softether = {
      enable = true;
      vpnclient.enable = true;
    };

    systemd.network.networks."50-softether" = {
      matchConfig.Name = "vpn_vpn";
      networkConfig.DHCP = "ipv4";
      routes = [
        {
          Destination = "20.107.224.22/32";
          Gateway = "192.168.30.1";
        }
        {
          Destination = "20.107.224.35/32";
          Gateway = "192.168.30.1";
        }
        {
          Destination = "13.69.227.72/30";
          Gateway = "192.168.30.1";
        }
        {
          Destination = "13.74.111.148/30";
          Gateway = "192.168.30.1";
        }
        {
          Destination = "20.50.80.192/30";
          Gateway = "192.168.30.1";
        }
        {
          Destination = "52.146.137.168/29";
          Gateway = "192.168.30.1";
        }
        {
          Destination = "52.146.137.68/30";
          Gateway = "192.168.30.1";
        }
      ];
    };
  };
}
