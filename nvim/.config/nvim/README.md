# Neovim config

A fork of [nvim-lua/kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) with personal customizations layered in.

## Attribution

The upstream MIT license is preserved verbatim at `LICENSE.md` in this directory. Credit for the documented single-file foundation goes to the kickstart.nvim maintainers.

For the original kickstart docs (how to customize, add plugins, etc.) — read the [upstream README](https://github.com/nvim-lua/kickstart.nvim#readme).

## What's customized vs upstream

The deltas from a fresh kickstart.nvim clone live in two places:

- **`init.lua`** — inline edits:
  - Catppuccin theme override with `color_overrides.mocha.base = '#000000'` so Neovim matches the terminal-wide OLED black background.
  - TypeScript / TSX language server (`ts_ls`).
  - ESLint LSP for inline lint diagnostics.
  - Prettier registered via `conform.nvim` for format-on-save across `.ts/.tsx/.js/.jsx/.json/.css/.html/.md/.yaml`.
- **`lua/custom/`** — any new plugins beyond the kickstart defaults belong here. Empty by default.

## Pulling upstream changes

To review what's new upstream without losing local edits:

```bash
cd ~/.config/nvim
git remote add upstream https://github.com/nvim-lua/kickstart.nvim
git fetch upstream
git diff upstream/master -- init.lua
```

Cherry-pick what you want, leave the local overrides intact.
