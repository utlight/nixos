{...}: {
  flake.modules.nixos.base = {pkgs, ...}: {
    nix.settings.experimental-features = ["nix-command" "flakes"];

    nixpkgs.config.allowUnfree = true;

    users.defaultUserShell = pkgs.zsh;
    programs.zsh.enable = true;

    system.stateVersion = "26.05";
  };
}
