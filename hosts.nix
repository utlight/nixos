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
        config.flake.modules.nixos.baremetal
        ./system/hardware-configuration.nix
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.utlight.imports = builtins.attrValues config.flake.modules.homeManager;
          };
        }
      ];
    };
    wsl = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        config.flake.modules.nixos.base
        config.flake.modules.nixos.wsl
        inputs.nixos-wsl.nixosModules.default
        inputs.home-manager.nixosModules.home-manager
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
