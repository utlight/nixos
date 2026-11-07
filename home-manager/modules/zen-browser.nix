{inputs, ...}: {
  flake.modules.homeManager.base = {...}: {
    imports = [inputs.zen-browser.homeModules.twilight];

    programs.zen-browser = {
      enable = true;
      setAsDefaultBrowser = true;
    };
  };
}
