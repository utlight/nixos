{
  flake.modules.homeManager.base = {
    pkgs,
    config,
    ...
  }: {
    home = {
      username = "utlight";
      homeDirectory = "/home/utlight";
      stateVersion = "26.05";
      packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        playerctl
        teams-for-linux
        telegram-desktop
        bitwarden-cli
        pciutils
        protonup-qt
      ];
    };

    xdg.configFile."niri" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dotfiles/niri";
      recursive = true;
    };

    xdg.configFile."noctalia" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dotfiles/noctalia";
      recursive = true;
    };

    programs.nix-search-tv.enable = true;
    programs.fastfetch.enable = true;
    programs.lazygit.enable = true;
    programs.ripgrep.enable = true;
    programs.fd.enable = true;
    programs.lutris.enable = true;

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.discord = {
      enable = true;
      settings.SKIP_HOST_UPDATE = true;
    };

    programs.mangohud = {
      enable = true;
      enableSessionWide = true;
      settings = {
        toggle_hud = "Shift_L+F12";
        no_display = true;
        gpu_name = true;
      };
    };

    programs.nh = {
      enable = true;
      flake = "${config.home.homeDirectory}/nixos";
      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep-since 7d --keep 5";
      };
    };
  };
}
