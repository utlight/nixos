{inputs, ...}: {
  flake.modules.homeManager.base = {pkgs, ...}: {
    imports = [inputs.deepseek-harness.homeModules.default];

    home.packages = with pkgs; [mcp-nixos];

    programs.dsh = {
      enable = true;
      profiles.acp-enhanced = {
        bundles = [pkgs.dsh.bundles.acp-enhanced];
        patch = [
          {
            id = "mcp-nixos";
            name = "@deepseek-ai/dsh-mcp-client";
            config = {
              serverName = "nixos";
              transport = "stdio";
              command = "nix";
              args = ["run" "github:utensils/mcp-nixos" "--"];
            };
          }
          {
            id = "roseline-mcp";
            name = "@deepseek-ai/dsh-mcp-client";
            config = {
              serverName = "roseline";
              transport = "stdio";
              command = "dotnet";
              args = ["dnx" "RoselineMCP@3.2.1" "--yes"];
            };
          }
        ];
      };
    };
  };
}
