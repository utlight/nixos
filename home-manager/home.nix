{pkgs, ...}: {
  home = {
    username = "utlight";
    homeDirectory = "/home/utlight";
    stateVersion = "26.05";
  };

  programs.gcc.enable = true;
  programs.cargo.enable = true;

  programs.neovim = {
    enable = true;
    sideloadInitLua = true;
    extraPackages = with pkgs; [
      tree-sitter

      rust-analyzer
      nixd
      lua-language-server

      alejandra
      stylua
    ];
  };

  programs.yazi.enable = true;
  programs.fzf.enable = true;
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
      plugins = ["sudo"];
    };
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };
}
