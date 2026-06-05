# dotfiles

> macOS terminal-first dev setup — Ghostty, tmux, Neovim, zsh, yazi, starship. Catppuccin Mocha on OLED black.

![Terminal](images/terminal.png)

A single repo that gets a fresh Mac from clean to working dev setup with three commands. Every tool here is chosen for keyboard-only operation and visual consistency across panes.

---

## Stack

| Layer | Tool |
|---|---|
| Terminal | [Ghostty](https://ghostty.org) |
| Multiplexer | [tmux](https://github.com/tmux/tmux) + [TPM](https://github.com/tmux-plugins/tpm) |
| Shell | zsh |
| Prompt | [Starship](https://starship.rs) (catppuccin-powerline preset) |
| Editor | [Neovim](https://neovim.io) (forked [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)) |
| File manager | [yazi](https://yazi-rs.github.io) |
| Git pager | [delta](https://github.com/dandavison/delta) |
| Git TUI | [lazygit](https://github.com/jesseduffield/lazygit) |
| Semantic diff | [difftastic](https://difftastic.wilfred.me.uk) |
| Process viewer | [btop](https://github.com/aristocratos/btop) |
| GitHub TUI | [gh](https://cli.github.com) + [gh-dash](https://github.com/dlvhdr/gh-dash) |
| Fuzzy finder | [fzf](https://github.com/junegunn/fzf) + [zoxide](https://github.com/ajeetdsouza/zoxide) + [atuin](https://github.com/atuinsh/atuin) |
| Better core utils | [eza](https://github.com/eza-community/eza), [bat](https://github.com/sharkdp/bat), [fd](https://github.com/sharkdp/fd), [ripgrep](https://github.com/BurntSushi/ripgrep) |

---

## Prerequisites

- macOS 14+ (Apple Silicon tested)
- Xcode Command Line Tools: `xcode-select --install`
- Homebrew (the installer below handles this if missing)

Everything else — fonts, GNU Stow, all CLI tools — comes from the `Brewfile`.

---

## Install

```bash
git clone https://github.com/ameyypawar/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The script installs Homebrew (if missing) → runs `brew bundle` → symlinks each tool's config into your `$HOME` via GNU Stow → clones the tmux plugin manager and installs its plugins → drops the Catppuccin theme into bat.

**Backup first if you have existing dotfiles** — Stow refuses to overwrite real files in `$HOME`. Move or remove any pre-existing `~/.zshrc`, `~/.tmux.conf`, `~/.gitconfig`, `~/.config/ghostty/config`, `~/.config/starship.toml`, `~/.config/yazi/`, and `~/.config/nvim/` before running.

After install, set your git identity (kept in `~/.gitconfig.local`, gitignored from this repo):

```bash
git config -f ~/.gitconfig.local user.email "you@example.com"
git config -f ~/.gitconfig.local user.name  "Your Name"
```

---

## Per-tool guide

### Ghostty

GPU-accelerated terminal, Kitty graphics protocol, native macOS tabs.

- Config: `ghostty/.config/ghostty/config`
- Theme: Catppuccin Mocha
- Background: solid `#000000` (overrides the theme's default mauve)
- Font: JetBrains Mono Nerd Font, 19pt
- Splits: `cmd+d` (right), `cmd+shift+d` (down), `cmd+opt+arrows` to navigate
- Reload after edit: `cmd+shift+,`

### tmux

Persistent session multiplexer. Survives Ghostty closing.

- Config: `tmux/.tmux.conf`
- Prefix: `Ctrl+b` (default; pairs well with Caps Lock remapped to Control in macOS Keyboard Settings)
- Splits: `prefix |` (vertical), `prefix -` (horizontal)
- Pane nav: `prefix h/j/k/l`
- Reload config: `prefix r`
- Plugins via TPM: tmux-sensible, tmux-yank, tmux-resurrect, tmux-continuum, catppuccin/tmux

### zsh

Plain zsh — no oh-my-zsh, no zinit. Just the integrations.

- Config: `zsh/.zshrc`
- Loads: starship → zoxide → atuin → fzf → eza aliases → yazi launcher function → optional `~/.extra`
- Aliases: `ll` / `la` / `lt` (eza), `lg` (lazygit), `gd` (gh dash), `top` (btop), `y` (yazi with cwd-on-quit)

### Neovim

Single-file kickstart fork with TypeScript/React LSP and a Catppuccin override that matches the terminal's OLED black.

- Config: `nvim/.config/nvim/init.lua` (plus `lua/custom/` for additions)
- Attribution: forks [nvim-lua/kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) — upstream MIT license preserved at `nvim/.config/nvim/LICENSE.md`
- LSPs: `lua_ls`, `ts_ls`, `eslint`
- Formatter: Prettier via conform.nvim for `.ts/.tsx/.js/.jsx/.json/.css/.html/.md/.yaml`
- Leader: Space. Telescope: `space sf` (files), `space sg` (grep). LSP nav: `K` (hover), `grd` (go to definition), `grr` (references), `grn` (rename), `gra` (code action)
- More in [`docs/nvim-cheatsheet.md`](docs/nvim-cheatsheet.md)

### yazi

Vim-keys file manager with image/video/PDF previews via Kitty graphics.

- Config: `yazi/.config/yazi/yazi.toml`, `yazi/.config/yazi/keymap.toml`
- Launch: `y` (a zsh function that `cd`s to wherever you quit yazi)
- Custom: text and code files open in `$EDITOR` (nvim), `C` copies the hovered file's contents to clipboard

### Starship

Catppuccin-powerline preset, shows dir, git branch, git status, language runtime.

- Config: `starship/.config/starship.toml`

### Git

- Config: `git/.gitconfig`, `git/.gitignore_global`
- Default branch: `main`
- Pager: delta with line numbers + Catppuccin Mocha syntax theme
- Aliases: `git dft` (semantic diff via difftastic), `git dfts <sha>`, `git dftl`
- Identity lives in `~/.gitconfig.local` (gitignored, included via `[include]`)
- More in [`docs/delta-difft-notes.md`](docs/delta-difft-notes.md)

---

## Theming

Catppuccin Mocha across every layer (Ghostty, tmux, Neovim, starship, bat, fzf, lazygit) with the background overridden to `#000000` for an OLED-black look. Pure dark base instead of catppuccin's default `#1e1e2e` mauve — Material-Design-style neutrality, accent colors pop harder, and visual consistency holds when wallpaper bleed-through is disabled (`background-opacity = 1.0` in Ghostty).

To revert to vanilla catppuccin mauve, remove the `background = #000000` line from `ghostty/.config/ghostty/config` and remove the `color_overrides` block from `nvim/.config/nvim/init.lua`.

---

## Customization

Per-machine PATHs and secrets belong in `~/.extra`. The repo provides a template at `extra/.extra.example`. Copy it, fill it in, and `.zshrc` sources it at the very end if it exists:

```bash
cp ~/dotfiles/extra/.extra.example ~/.extra
```

`~/.extra` is in this repo's `.gitignore` and never reaches GitHub. Pattern stolen from [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles).

---

## Layout

```
dotfiles/
├── README.md           you're reading it
├── LICENSE             MIT
├── Brewfile            full bundle
├── install.sh          bootstrap
├── .gitignore
├── zsh/                stow package → ~/.zshrc
├── git/                → ~/.gitconfig + ~/.gitignore_global
├── tmux/               → ~/.tmux.conf
├── ghostty/            → ~/.config/ghostty/config
├── starship/           → ~/.config/starship.toml
├── yazi/               → ~/.config/yazi/
├── nvim/               → ~/.config/nvim/  (kickstart fork)
├── extra/              .extra.example template (gitignored when copied to ~/.extra)
├── bin/                helper scripts (empty for now)
├── docs/               cheatsheets + runbooks
│   ├── terminal-cheatsheet.md
│   ├── nvim-cheatsheet.md
│   ├── delta-difft-notes.md
│   └── setup-remote-vps.md
└── images/             screenshots
```

Each top-level tool folder is a GNU Stow package — the internal `.config/...` mirrors XDG paths so `stow ghostty` drops files exactly where they belong.

---

## Docs

- [`docs/terminal-cheatsheet.md`](docs/terminal-cheatsheet.md) — daily-driver shortcuts for tmux, worktrunk, fzf, lazygit, git, starship, Ghostty
- [`docs/nvim-cheatsheet.md`](docs/nvim-cheatsheet.md) — modes, motions, operators, text objects, kickstart leader keymaps, LSP shortcuts, 2-week learning plan
- [`docs/delta-difft-notes.md`](docs/delta-difft-notes.md) — when to reach for delta vs. semantic diff with difftastic, PR review workflow
- [`docs/setup-remote-vps.md`](docs/setup-remote-vps.md) — runbook for putting Claude Code on a $5/mo Hetzner VPS so you can drive it from your phone via Remote Control

---

## Attribution

- Neovim config forks [nvim-lua/kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) — original MIT license preserved at `nvim/.config/nvim/LICENSE.md`.
- Stow layout, install patterns, and per-tool README structure inspired by [josean-dev/dev-environment-files](https://github.com/josean-dev/dev-environment-files) and [holman/dotfiles](https://github.com/holman/dotfiles).
- The `~/.extra` pattern is from [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles).
- README visual structure follows [craftzdog/dotfiles-public](https://github.com/craftzdog/dotfiles-public).

---

## License

MIT — see [`LICENSE`](LICENSE).
