{...}: {
  flake.modules.nixos.base = {...}: {
    users.groups.lenovoctl = {};

    users.users."utlight" = {
      isNormalUser = true;
      description = "Utlight";
      extraGroups = ["networkmanager" "wheel" "lenovoctl"];
    };
  };
}
