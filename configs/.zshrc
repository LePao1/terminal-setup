#!/bin/zsh
# ─── terminal-setup: Zsh config ─────────────────────────────────────
# Powered by: Oh My Zsh + Starship + zsh-autosuggestions
#             + zsh-syntax-highlighting + fzf + zoxide + fnm

# ─── Local bin ───────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"

# ─── Oh My Zsh ───────────────────────────────────────────────────────
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"

# Starship draws the prompt; OMZ must not install a theme of its own.
ZSH_THEME=""

# Load order matters: zsh-syntax-highlighting must stay last so the
# widgets registered by the other plugins are still highlighted.
plugins=(
    git
    sudo
    extract
    fzf
    zoxide
    fnm
    direnv
    zsh-autosuggestions
    zsh-syntax-highlighting
)

# Keep startup snappy; bump by hand with 'omz update'.
DISABLE_AUTO_UPDATE=true
DISABLE_UPDATE_PROMPT=true

source "$ZSH/oh-my-zsh.sh"

# ─── Starship prompt ─────────────────────────────────────────────────
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

# ─── History ─────────────────────────────────────────────────────────
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY

# ─── Completion tweaks on top of OMZ defaults ────────────────────────
# Case-insensitive substring matching.
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=*'

# ─── History prefix search (↑/↓) ─────────────────────────────────────
# up-line-or-beginning-search: cursor stays at prefix position,
# matched tail shown as gray autosuggestion — type more to narrow.
autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

# ─── fzf ─────────────────────────────────────────────────────────────
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
# Use fd for fzf if available (Debian/Ubuntu ship it as 'fdfind')
if command -v fd &>/dev/null; then
    FZF_FINDER=fd
elif command -v fdfind &>/dev/null; then
    FZF_FINDER=fdfind
fi
if [[ -n "${FZF_FINDER:-}" ]]; then
    export FZF_DEFAULT_COMMAND="$FZF_FINDER --type f --hidden --follow --exclude .git"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="$FZF_FINDER --type d --hidden --follow --exclude .git"
fi

# fnm binary path (Linux installs to ~/.local/share/fnm)
export PATH="$HOME/.local/share/fnm:$PATH"

# ─── SSH key switcher (fallback for multi-account setups) ────────────
# Usage: set-ssh-key lewis-official-20260224
# Prefer ~/.ssh/config Host aliases for automatic matching.
# This is a fallback for edge cases where you need to force a specific key.
function set-ssh-key() {
    local key="$HOME/.ssh/$1"
    if [[ ! -f "$key" ]]; then
        echo "Key not found: $key" >&2
        echo "Available keys:" >&2
        ls ~/.ssh/*.pub 2>/dev/null | sed 's/.*\//  /; s/\.pub$//' >&2
        return 1
    fi
    ssh-add -D 2>/dev/null
    ssh-add "$key"
    echo "Active SSH key: $1"
}

# ─── Aliases ─────────────────────────────────────────────────────────
# Only names that don't shadow an existing command: 'ls', 'cat', 'find',
# 'grep' and 'top' keep their standard behaviour on purpose.
alias ll='eza -la --icons --group-directories-first'
alias lt='eza --tree --icons --level=2'
alias lg='lazygit'

# ─── pnpm ────────────────────────────────────────────────────────────
if [[ "$(uname)" == "Darwin" ]]; then
    export PNPM_HOME="$HOME/Library/pnpm"
else
    export PNPM_HOME="$HOME/.local/share/pnpm"
fi
case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
esac
