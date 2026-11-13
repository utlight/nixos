{...}: {
  flake.modules.homeManager.base = {
    config,
    pkgs,
    ...
  }: {
    home.packages = [pkgs.libsecret];

    programs.gh.enable = true;
    programs.git = {
      enable = true;
      package = pkgs.git.override {withLibsecret = true;};
      settings.credential.helper = "${pkgs.git.override {withLibsecret = true;}}/share/git/contrib/credential/libsecret/git-credential-libsecret";
      includes = [
        {
          contents = {
            init.defaultBranch = "main";
          };
        }
        {
          condition = "gitdir:~/nixos/";
          path = "${config.home.homeDirectory}/.gitconfig-personal";
        }
        {
          condition = "gitdir:~/personal/";
          path = "${config.home.homeDirectory}/.gitconfig-personal";
        }
        {
          condition = "gitdir:~/work/";
          path = "${config.home.homeDirectory}/.gitconfig-work";
        }
      ];
    };
  };
}
