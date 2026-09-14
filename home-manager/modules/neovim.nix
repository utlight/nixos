{...}: {
  flake.modules.homeManager.base = {pkgs, ...}: {
    programs.neovim = {
      enable = true;
      sideloadInitLua = true;
      extraPackages = with pkgs; [
        tree-sitter

        rust-analyzer
        nixd
        lua-language-server
        bash-language-server

        alejandra
        stylua
        shfmt
      ];
    };
  };
}
