return {
  settings = {
    nixd = {
      nixpkgs = {
        expr = "import <nixpkgs> { }",
      },
      formatting = {
        command = { "alejandra" },
      },
      options = {
        nixos = {
          expr = '(builtins.getFlake "/home/utlight/nixos").nixosConfigurations.nixos.options',
        },
        home_manager = {
          expr = '(builtins.getFlake "/home/utlight/nixos").nixosConfigurations.nixos.options.home-manager.users.type.getSubOptions []',
        },
      },
    },
  },
}
