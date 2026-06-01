#!/usr/bin/env bash
# Bootstrap installer for a fresh macOS machine.
# Usage:
#   git clone https://github.com/ameyypawar/dotfiles.git ~/dotfiles
#   cd ~/dotfiles
#   ./install.sh

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOW_PACKAGES=(zsh git tmux ghostty starship yazi nvim)

# Pretty logging
say()  { printf "\n\033[1;36m==>\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[warn]\033[0m %s\n" "$*"; }

# ------------------------------------------------------------
# 1. Homebrew
# ------------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
  say "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add brew to current shell PATH (Apple Silicon default)
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
else
  say "Homebrew already installed."
fi

# ------------------------------------------------------------
# 2. Brewfile
# ------------------------------------------------------------
say "Installing Brewfile packages..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

# ------------------------------------------------------------
# 3. Stow each package into $HOME
# ------------------------------------------------------------
say "Symlinking configs via GNU Stow..."
cd "$DOTFILES_DIR"
for pkg in "${STOW_PACKAGES[@]}"; do
  if [ ! -d "$pkg" ]; then
    warn "package '$pkg' missing — skipping"
    continue
  fi
  # Re-stow: removes any prior symlinks then re-creates them. Safe to re-run.
  stow -D "$pkg" 2>/dev/null || true
  stow -t "$HOME" "$pkg"
  echo "  stowed: $pkg"
done

# ------------------------------------------------------------
# 4. gh CLI extensions
# ------------------------------------------------------------
if command -v gh >/dev/null 2>&1; then
  if ! gh extension list 2>/dev/null | grep -q 'dlvhdr/gh-dash'; then
    say "Installing gh-dash extension..."
    gh extension install dlvhdr/gh-dash || warn "gh-dash install failed (gh auth required) — re-run after 'gh auth login'"
  fi
fi

# ------------------------------------------------------------
# 5. Tmux Plugin Manager (TPM) — install BEFORE first tmux start
# ------------------------------------------------------------
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
  say "Cloning TPM..."
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

say "Installing tmux plugins via TPM CLI..."
"$TPM_DIR/bin/install_plugins"

# ------------------------------------------------------------
# 6. Bat catppuccin theme (delta uses bat's themes)
# ------------------------------------------------------------
if command -v bat >/dev/null 2>&1; then
  BAT_THEMES="$(bat --config-dir)/themes"
  mkdir -p "$BAT_THEMES"
  if [ ! -f "$BAT_THEMES/Catppuccin Mocha.tmTheme" ]; then
    say "Installing Catppuccin Mocha theme for bat..."
    curl -fsSL \
      "https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin%20Mocha.tmTheme" \
      -o "$BAT_THEMES/Catppuccin Mocha.tmTheme"
    bat cache --build >/dev/null
  fi
fi

# ------------------------------------------------------------
# 7. Next steps
# ------------------------------------------------------------
cat <<EOF

\033[1;32m✓ Done.\033[0m

Next steps:

  1. Set your git identity (kept in ~/.gitconfig.local, gitignored):
       git config -f ~/.gitconfig.local user.email "you@example.com"
       git config -f ~/.gitconfig.local user.name  "Your Name"

  2. Copy the local-overrides template if you have machine-specific PATHs or secrets:
       cp $DOTFILES_DIR/extra/.extra.example ~/.extra

  3. Open Ghostty (Cmd+Space → "Ghostty"). Default theme is Catppuccin Mocha
     on OLED black (#000000). Tweak via ~/.config/ghostty/config.

  4. Start tmux for the first time:
       tmux

  5. Open Neovim — lazy.nvim bootstraps on first run:
       nvim
     Then run ':checkhealth' to confirm dependencies.

EOF
