{...}: {
  flake.modules.homeManager.base = {...}: {
    programs.ghostty = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        font-family = "JetBrainsMono Nerd Font Mono";
        font-size = 13;
        theme = "noctalia";
        background-opacity = 0.9;
        confirm-close-surface = false;
        custom-shader = "shaders/cursor-warp.glsl";
      };
    };

    xdg.configFile."ghostty/shaders/cursor-warp.glsl".source = ./cursor-warp.glsl;
  };
}
