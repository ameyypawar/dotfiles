export PATH="$HOME/.local/bin:$PATH"

# Guarded optional paths — no-op if the target doesn't exist on this machine
[ -d /opt/homebrew/opt/ffmpeg-full/bin ] && export PATH="/opt/homebrew/opt/ffmpeg-full/bin:$PATH"
for _py in "$HOME"/Library/Python/*/bin; do
  [ -d "$_py" ] && export PATH="$_py:$PATH"
done
unset _py

# --- completion (required for wt + zsh completions) ---
autoload -Uz compinit && compinit

# --- worktrunk (wt) shell integration ---
if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi

# --- starship prompt ---
eval "$(starship init zsh)"

# --- zoxide (smart cd: type `z <pattern>` to jump to learned paths) ---
eval "$(zoxide init zsh)"

# --- atuin (better history: Ctrl+R for fuzzy search across machines) ---
eval "$(atuin init zsh --disable-up-arrow)"

# --- fzf (fuzzy finder: Ctrl+T for files, Ctrl+R for history-via-atuin, Alt+C for cd) ---
[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ] && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
[ -f /opt/homebrew/opt/fzf/shell/completion.zsh ] && source /opt/homebrew/opt/fzf/shell/completion.zsh
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8,fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc,marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

# --- bat (better cat with syntax highlighting) ---
export BAT_THEME="Catppuccin Mocha"

# --- eza (better ls) ---
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first --git'
alias la='eza -la --icons --group-directories-first --git'
alias lt='eza --tree --icons --level=2'

# --- shortcuts ---
alias lg='lazygit'
alias gd='gh dash'
alias top='btop'

# --- editor (used by git for commit messages, etc.) ---
export EDITOR='nvim'
export VISUAL='nvim'

# --- yazi (file manager): `y` launches it and cd's to wherever you quit ---
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# --- local machine overrides (gitignored — see extra/.extra.example) ---
[ -f "$HOME/.extra" ] && source "$HOME/.extra"
