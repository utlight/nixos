{...}: {
  flake.modules.homeManager.base = {config, ...}: {
    programs.gh.enable = true;
    programs.git = {
      enable = true;
      settings.credential.helper = "store";
      includes = [
        {
          contents = {
            init.defaultBranch = "main";
          };
        }
        {
          condition = "gitdir:~/.config/";
          path = "${config.home.homeDirectory}/.gitconfig-personal";
        }
        {
          condition = "gitdir:~/Personal/";
          path = "${config.home.homeDirectory}/.gitconfig-personal";
        }
        {
          condition = "gitdir:~/Work/";
          path = "${config.home.homeDirectory}/.gitconfig-work";
        }
      ];
    };
  };
}
