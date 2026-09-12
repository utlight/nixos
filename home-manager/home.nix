{ config, pkgs, ... }:
{
	home = {
		username = "utlight";
		homeDirectory = "/home/utlight";
		stateVersion = "26.05";
	};

	programs.neovim.enable = true;
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
	      condition = "gitdir:~/.config";
	      contents = {
	        user.name = "utlight";
		user.email = "250863253+utlight@users.noreply.github.com";
	      };
	    }
	  ];
	};

	programs.zsh = 
	{
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
	      plugins = [ "sudo" ];
	    };
	};
}
