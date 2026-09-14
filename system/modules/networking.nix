{...}: {
  flake.modules.nixos.base = {...}: {
    networking.hostName = "nixos";
    networking.wireless.enable = true;

    networking.networkmanager.enable = true;
  };
}
