{inputs, ...}: {
  flake.modules.homeManager.base = {pkgs, ...}: {
    imports = [inputs.deepseek-harness.homeModules.default];

    services.dsh.profiles.web.bundles = [pkgs.dsh.bundles.web-app];
    services.dsh.enable = true;
    services.dsh.port = 3080;

    programs.dsh = {
      enable = true;
      profiles.acp = {
        bundles = [(pkgs.callPackage ../../pkgs/_dsh-acp-enhanced.nix {})];
        patch = [
          # Do not add an `acp-enhanced` config row here: a profile patch
          # replaces the row's whole config, which would drop the bridge's
          # provider/model route. Use DSH_ACP_* environment variables instead.
          {
            id = "headless-runner";
            disabled = true;
          }
          {
            id = "credentials";
            disabled = false;
          }
          {
            id = "authorization";
            disabled = false;
          }
          {
            id = "deepseek-account";
            disabled = false;
          }
        ];
      };
    };
  };
}
