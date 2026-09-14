{...}: {
  flake.modules.homeManager.base = {pkgs, ...}: {
    programs.tmux = {
      enable = true;
      shell = "${pkgs.zsh}/bin/zsh";
      extraConfig = ''
        set -g base-index 1
        set -g mouse on

        bind-key -n M-1 select-window -t 1
        bind-key -n M-2 select-window -t 2
        bind-key -n M-3 select-window -t 3
        bind-key -n M-4 select-window -t 4
        bind-key -n M-` detach-client

        set -g default-terminal "tmux-256color"
        set -ga terminal-overrides ",*256col*:Tc"
        set -g status off

        set -s extended-keys always
        set -g extended-keys-format csi-u
        set -as terminal-features 'xterm*:extkeys'
      '';
    };
  };
}
