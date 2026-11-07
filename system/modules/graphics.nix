{...}: {
  flake.modules.nixos.base = {...}: {
    hardware.graphics.enable = true;
    hardware.graphics.enable32Bit = true;

    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {
      modesetting.enable = true;
      open = true;

      powerManagement.enable = true;
      powerManagement.finegrained = true;

      nvidiaSettings = true;
      prime = {
        offload.enable = true;
        offload.enableOffloadCmd = true;

        amdgpuBusId = "PCI:6:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };
}
