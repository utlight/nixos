{inputs, ...}: {
  flake.modules.homeManager.base = {...}: {
    imports = [inputs.zen-browser.homeModules.twilight];

    programs.zen-browser = {
      enable = true;
      setAsDefaultBrowser = true;
      # profiles.default = {
      #   mods = [
      #     "cb5efa80-f1e1-43ce-8c0b-fece8462d225"
      #   ];
      # };
    };
  };
}
