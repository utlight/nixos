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
        basedpyright
        sqls

        rustfmt
        alejandra
        stylua
        shfmt
        prettier
        ruff
        jq
        sqruff
        taplo
      ];
    };

    xdg.configFile."nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dotfiles/nvim";
      recursive = true;
    };
  };
}
