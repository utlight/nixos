# AGENTS.md

Personal NixOS + home-manager flake (`utlight/nixos`, checked out at `~/nixos`).
Single bare-metal host `nixos` (Lenovo IdeaPad, hybrid AMD/Nvidia), dual-booted
with Windows via GRUB. Desktop: niri + noctalia. Editor: Neovim.
nixpkgs is **unstable**; `stateVersion` is 26.05.

## Layout

- `flake.nix`: inputs only. Uses **flake-parts + import-tree**.
- **Every `*.nix` under the repo root is auto-imported as a flake module**, except
  `flake.nix`, `hardware-configuration.nix`, and `_`-prefixed files. There is no
  import list to update: adding a file is enough.
- `hosts.nix`: the one host, wiring base nixos module + home-manager.
- `system/` defines `flake.modules.nixos.base` (`configuration.nix`, `modules/*`:
  boot, inputs/keyd, locale, networking, users, audio, graphics, compositor).
- `home-manager/` defines `flake.modules.homeManager.base` (`home.nix`,
  `development.nix`, `git.nix`, `neovim.nix`, `tmux.nix`, `zsh/`, `yazi.nix`, ...).
- `dotfiles/{nvim,niri,noctalia}`: plain config files, **symlinked out-of-store**
  into `~/.config` (home-manager `mkOutOfStoreSymlink`). Edits there take effect
  immediately and need **no rebuild**. Only `.nix` changes need one.

## Rules

- **Flakes only see git-tracked files.** After creating a new `.nix` file run
  `git add <file>` (no commit) or evaluation will not find it. 
  Untrack new file before answearing, so user can see your changes.
- Keep module style consistent: new modules go in
  `flake.modules.nixos.base` or `flake.modules.homeManager.base` form, like the
  existing ones. Don't invent a new module mechanism.
- Tools are installed **globally** through this config. Do **not** add per-project
  `nix develop` / devShells or `direnv`/`shell.nix` setups.
- Don't edit `hardware-configuration.nix`. Don't change `stateVersion`.
- Don't bump or reorder flake inputs, or run `nix flake update`, unless asked.
- Never put secrets, tokens or keys in this repo (it's public).
- Verify option names and package attrs with real data (see Tools) instead of
  guessing. Unstable renames things often.

## Sensitive areas: ask first

- `system/modules/networking.nix`: SoftEther VPN + static routes to work (Azure)
  services. Don't touch routes, unless you have a better idea of managing them.
- `system/modules/boot.nix` and the `/mnt/windows` mount (read-only ntfs3 of the
  Windows partition). It also feeds Roslyn's MSBuild paths in
  `dotfiles/nvim/lsp/roslyn_ls.lua`, so don't change the mount point or make it writable.
- `system/modules/graphics.nix` (Nvidia PRIME bus IDs), `inputs.nix` (keyd layers).
- `system/modules/compositor.nix` and udev rules.

## Build and verify

Prefer the cheapest check that answers the question:

1. `alejandra --check .` (formatter for `.nix`; `stylua` for Lua in `dotfiles/nvim`).
2. `nix flake check` or `nix eval .#nixosConfigurations.nixos.config.system.build.toplevel.drvPath`
   to evaluate without building.
3. `nh os build ~/nixos` to build without activating.

**Never run `nh os switch`, `nixos-rebuild switch`, `sudo`, or garbage collection
yourself.** Tell the user what to run. They rebuild with `nh`.

## Conventions

- `.nix` files are formatted with **alejandra**. Don't hand-format against it.
- Comments only where intent isn't obvious (hardware quirks, workarounds, why
  something is pinned).
- Packages go in the narrowest module that owns them (dev tools in
  `development.nix`, editor tooling in `neovim.nix`, desktop in `compositor.nix`).
- Per-folder git identity: `~/nixos/` uses the personal gitconfig. Never commit or
  push unless asked.

## Tools

If the `nixos` MCP server (`mcp-nixos`) is available, use its `nix` tool before
writing options or packages:

- `source="nixos"`: NixOS packages/options (`type="packages"` or `"options"`)
- `source="home-manager"`: home-manager options
- `source="nixvim"` / `"noogle"`: nixvim options / `lib` function docs
- `action="flake-inputs"`: browse the pinned inputs in the local store

Use `nix search`/`nix eval` as a fallback only if the MCP server is not available.
