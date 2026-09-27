{...}: {
  flake.modules.nixos.base = {...}: {
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.timeout = 5;

    boot.loader.grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = true;
    };

    boot.loader.grub2-theme = {
      enable = true;
      theme = "vimix";
      footer = true;
      customResolution = "1920x1080";
    };
  };
}
