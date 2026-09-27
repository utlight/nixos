{...}: {
  flake.modules.nixos.base = {pkgs, ...}: {
    nix.settings.experimental-features = ["nix-command" "flakes"];

    nixpkgs.config.allowUnfree = true;

    users.defaultUserShell = pkgs.zsh;
    programs.zsh.enable = true;

    programs.gamemode.enable = true;
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
    };

    system.stateVersion = "26.05";
  };
}
