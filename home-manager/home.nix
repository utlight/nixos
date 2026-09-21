{
  flake.modules.homeManager.base = {pkgs, ...}: {
    home = {
      username = "utlight";
      homeDirectory = "/home/utlight";
      stateVersion = "26.05";
      packages = with pkgs; [
        (azure-cli.withExtensions [azure-cli-extensions.azure-devops])
        (with dotnetCorePackages; combinePackages [sdk_8_0 sdk_9_0 sdk_10_0])
        nerd-fonts.jetbrains-mono
        cmake
      ];
    };

    home.file.".editorconfig".text = ''
      root = true

      [*.cs]
      csharp_style_namespace_declarations = file_scoped:warning
      max_line_length = 120
      indent_style = space
    '';

    programs.fastfetch.enable = true;
    programs.gcc.enable = true;
    programs.cargo.enable = true;
    programs.npm.enable = true;
    programs.lazygit.enable = true;
    programs.ripgrep.enable = true;
    programs.fd.enable = true;
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
