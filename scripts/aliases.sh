# scripts/aliases.sh

# Eza (modern ls)
if command -v eza &> /dev/null; then
  alias ls='eza --icons'
  alias ll='eza -al --icons --group-directories-first'
  alias la='eza -a --icons --group-directories-first'
  alias lt='eza --tree --level=2 --icons'
else
  alias ll='ls -alF'
  alias la='ls -A'
  alias l='ls -CF'
fi

# Ripgrep
if command -v rg &> /dev/null; then
  alias grep='rg'
fi

# Bat (modern cat)
if command -v batcat &> /dev/null; then
  alias cat='batcat'
elif command -v bat &> /dev/null; then
  alias cat='bat'
fi

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# Git shortcuts
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
