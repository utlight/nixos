{...}: {
  flake.modules.nixos.wsl = {lib, ...}: {
    wsl = {
      enable = true;
      defaultUser = "utlight";
      useWindowsDriver = true;

      wslConf = {
        automount.enabled = false;
        interop.appendWindowsPath = false;
      };
    };

    networking.wireless.enable = lib.mkForce false;
  };
}
