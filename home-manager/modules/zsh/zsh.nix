{...}: {
  flake.modules.homeManager.base = {pkgs, ...}: {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
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
        plugins = ["sudo" "dotnet" "vi-mode"];
      };
      sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
      initContent = ''
        source ${./softether.zsh}
        source ${./history-separation.zsh}
      '';
    };
  };
}
