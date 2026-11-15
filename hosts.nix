{
  inputs,
  config,
  ...
}: {
  flake.nixosConfigurations = {
    nixos = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        config.flake.modules.nixos.base
        ./system/hardware-configuration.nix
        inputs.grub2-themes.nixosModules.default
        inputs.home-manager.nixosModules.home-manager
        {nixpkgs.overlays = [inputs.deepseek-harness.overlays.default];}
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.utlight.imports = builtins.attrValues config.flake.modules.homeManager;
          };
        }
      ];
    };
  };
}
