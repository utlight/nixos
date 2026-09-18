{...}: {
  flake.modules.homeManager.base = {
    pkgs,
    config,
    ...
  }: {
    programs.neovim = {
      enable = true;
      sideloadInitLua = true;
      extraPackages = with pkgs; [
        tree-sitter

        rustc
        typescript_5

        rust-analyzer
        nixd
        lua-language-server
        bash-language-server
        roslyn-ls
        typescript-language-server

        rustfmt
        alejandra
        stylua
        shfmt
      ];
    };

    xdg.configFile."nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nixos/dotfiles/nvim";
      recursive = true;
    };
  };
}
