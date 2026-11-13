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
        #NOTE: Azure
        {
          Destination = "20.0.0.0/8";
          Gateway = "192.168.30.1";
        }
        {
          Destination = "13.0.0.0/8";
          Gateway = "192.168.30.1";
        }
        {
          Destination = "52.0.0.0/8";
          Gateway = "192.168.30.1";
        }
      ];
    };
  };
}
