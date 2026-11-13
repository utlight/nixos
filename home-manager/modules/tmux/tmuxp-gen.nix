{
  flake.modules.homeManager.base = {
    pkgs,
    lib,
    ...
  }: let
    tmuxp-gen = pkgs.writeShellApplication {
      name = "tmuxp-gen";
      text = builtins.readFile ./tmuxp-gen.sh;
    };
  in {
    home.packages = [tmuxp-gen];

    systemd.user.services.tmuxp-gen = {
      Unit.Description = "Generate tmuxp configs for source projects";
      Service = {
        Type = "oneshot";
        ExecStart = lib.getExe tmuxp-gen;
      };
    };

    systemd.user.paths.tmuxp-gen = {
      Unit.Description = "Watch ~/work/source/ and ~/personal/source/ for added or removed projects";
      Path.PathChanged = [
        "%h/work/source"
        "%h/personal/source"
      ];
      Install.WantedBy = ["paths.target"];
    };
  };
}
