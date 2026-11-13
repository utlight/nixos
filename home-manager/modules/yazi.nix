{...}: {
  flake.modules.homeManager.base = {pkgs, ...}: {
    xdg.configFile."xdg-desktop-portal-termfilechooser/config".text = ''
      [filechooser]
      cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
      default_dir=$HOME
      env=TERMCMD='${pkgs.ghostty}/bin/ghostty --title=termfilechooser -e'
      open_mode=suggested
      save_mode=last
    '';

    xdg.desktopEntries.yazi-ghostty = {
      name = "Yazi";
      exec = "ghostty --title=yazi -e yazi %u";
      terminal = false;
      mimeType = ["inode/directory"];
      categories = ["System" "FileTools" "FileManager"];
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = ["yazi-ghostty.desktop"];
      };
    };

    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
      plugins = {
        full-border = pkgs.yaziPlugins.full-border;
        toggle-pane = pkgs.yaziPlugins.toggle-pane;
      };
      initLua = ''
        require("full-border"):setup()
      '';
      keymap = {
        mgr.prepend_keymap = [
          {
            on = "!";
            run = "shell '$SHELL' --block";
            desc = "Open $SHELL here";
          }
          {
            on = "y";
            run = [
              ''shell -- for path in %s; do echo "file://$path"; done | wl-copy -t text/uri-list''
              "yank"
            ];
            desc = "Yank selected files";
          }
          {
            on = "T";
            run = "plugin toggle-pane min-preview";
            desc = "Show or hide the preview pane";
          }
          {
            on = "I";
            run = "plugin toggle-pane min-current";
            desc = "Show or hide the preview pane";
          }
          {
            on = ["g" "d"];
            run = ''shell 'nvim -c "DiffviewDiffFiles %s %h"' --block'';
            desc = "Diffview selected with the hovered file";
          }
        ];
      };
    };
  };
}
