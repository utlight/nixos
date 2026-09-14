{...}: {
  flake.modules.nixos.base = {...}: {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    users.users.utlight.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIAfEFuYu3lTYh5GNdNoWzgTyaQPYSS5uvRhqeHWudo7 nixos"
    ];
  };
}
