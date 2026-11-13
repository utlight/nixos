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
      jetbrains.rider
      jetbrains.webstorm
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

    home.file.".sqruff".text = ''
      [sqruff]
      dialect = tsql
      output_line_length = 100
      max_line_length = 100

      [sqruff:indentation]
      indented_joins = true

      [sqruff:rules]
      unquoted_identifiers_policy = aliases

      [sqruff:rules:capitalisation.identifiers]
      extended_capitalisation_policy = lowercase
    '';
  };
}
