{...}: {
  flake.modules.nixos.base = {pkgs, ...}: {
    nix.settings.experimental-features = ["nix-command" "flakes"];

    nixpkgs.config.allowUnfree = true;

    users.defaultUserShell = pkgs.zsh;
    programs.zsh.enable = true;

    services.flatpak.enable = true;

    programs.steam.enable = true;
    programs.gamemode.enable = true;

    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [icu openssl zlib krb5 stdenv.cc.cc.lib];

    system.stateVersion = "26.05";

    boot.supportedFilesystems = ["ntfs"];

    fileSystems."/mnt/windows" = {
      device = "/dev/disk/by-partuuid/3506cce8-bf2d-4754-b68f-c93bb2923e5d";
      fsType = "ntfs3";
      options = [
        "ro"
        "nofail"
        "uid=1000"
        "gid=100"
        "windows_names"
      ];
    };
  };
}
