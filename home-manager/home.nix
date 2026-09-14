{
  flake.modules.homeManager.base = {...}: {
    home = {
      username = "utlight";
      homeDirectory = "/home/utlight";
      stateVersion = "26.05";
    };

    programs.gcc.enable = true;
    programs.cargo.enable = true;
    programs.lazygit.enable = true;
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
