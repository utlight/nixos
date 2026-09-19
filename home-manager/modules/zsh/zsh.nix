{...}: {
  flake.modules.homeManager.base = {pkgs, ...}: {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      # syntaxHighlighting.enable = true;
      shellAliases.yazi = "y";
      plugins = [
        {
          name = "fzf-tab";
          src = pkgs.zsh-fzf-tab;
          file = "/share/fzf-tab/fzf-tab.plugin.zsh";
        }
      ];
      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = ["sudo"];
      };
      sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
      initContent = ''
        source ${./tm.zsh}
      '';
    };
  };
}
