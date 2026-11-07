{
  flake.modules.homeManager.base = {pkgs, ...}: let
    version = "4.16.0";
    func = pkgs.stdenvNoCC.mkDerivation {
      pname = "azure-functions-core-tools-bin";
      inherit version;
      src = pkgs.fetchurl {
        url = "https://github.com/Azure/azure-functions-core-tools/releases/download/${version}/Azure.Functions.Cli.linux-x64.${version}.zip";
        hash = "sha256-xox3gNlMdYMVf3p9GgXg7D40BXw9VeTHvnH8SqDCNmc=";
      };
      nativeBuildInputs = [pkgs.unzip];
      sourceRoot = ".";
      dontConfigure = true;
      dontBuild = true;
      dontFixup = true;
      installPhase = ''
        mkdir -p $out/libexec/func $out/bin
        cp -r . $out/libexec/func
        chmod +x $out/libexec/func/func
        find $out/libexec/func -name gozip -exec chmod +x {} +
        ln -s $out/libexec/func/func $out/bin/func
      '';
    };
  in {
    home.packages = [func];
  };
}
