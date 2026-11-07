{
  flake.modules.homeManager.base = {pkgs, ...}: {
    home.packages = with pkgs; [
      (with dotnetCorePackages; combinePackages [sdk_8_0 sdk_9_0 sdk_10_0])
      gnumake
      azure-cli
      nuget
      mono
      azurite
      jetbrains.datagrip
    ];

    programs.gcc.enable = true;
    programs.cargo.enable = true;
    programs.npm.enable = true;

    home.file.".editorconfig".text = ''
      root = true

      [*.cs]
      csharp_style_namespace_declarations = file_scoped:warning
      max_line_length = 120
      indent_style = space
    '';
  };
}
