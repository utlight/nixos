{
  inputs,
  config,
  ...
}: {
  flake.nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules =
      builtins.attrValues config.flake.modules.nixos
      ++ [
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
}
