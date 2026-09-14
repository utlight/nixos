{...}: {
  flake.modules.homeManager.base = {...}: {
    programs.gh.enable = true;
    programs.git = {
      enable = true;
      includes = [
        {
          contents = {
            init.defaultBranch = "main";
          };
        }
        {
          condition = "gitdir:~/.config/";
          contents = {
            user.name = "utlight";
            user.email = "250863253+utlight@users.noreply.github.com";
          };
        }
        {
          condition = "gitdir:~/Work/";
          contents = {
            user.name = "";
            user.email = "";
          };
        }
      ];
    };
  };
}
