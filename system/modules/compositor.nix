{...}: {
  flake.modules.nixos.base = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      xwayland-satellite
      afterglow-cursors-recolored
    ];

    services.gnome.gnome-keyring.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome
        xdg-desktop-portal-gtk
      ];
    };

    services.udev.extraRules = ''
      ACTION=="add|change", SUBSYSTEM=="platform", DRIVER=="ideapad_acpi", RUN+="${pkgs.coreutils}/bin/chgrp lenovoctl /sys%p/conservation_mode", RUN+="${pkgs.coreutils}/bin/chmod 664 /sys%p/conservation_mode"
    '';

    programs.niri.enable = true;

    programs.noctalia.enable = true;
    programs.noctalia.recommendedServices.enable = true;
    programs.noctalia.systemd.enable = true;

    services.displayManager.noctalia-greeter = {
      enable = true;
      settings = {
        cursor = {
          theme = "Afterglow-Recolored-Original-joris4";
          size = 24;
        };
        appearance = {
          wallpaper = {
            path = "${../../dotfiles/noctalia/3vydZuxp-fond-decran-Printemps-49.png}";
            fill_mode = "fit";
          };
          scheme = "Rose-pine";
          hide_logo = true;
        };
      };
    };
  };
}
