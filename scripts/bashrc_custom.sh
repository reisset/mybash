# scripts/bashrc_custom.sh

# 1. Source Aliases
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/aliases.sh" ]; then
    source "$SCRIPT_DIR/aliases.sh"
fi

# 2. Path additions (ensure ~/.local/bin is in PATH)
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# 3. Starship Prompt
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi

# 4. FZF
if command -v fzf &> /dev/null; then
    eval "$(fzf --bash)" 2>/dev/null || source /usr/share/doc/fzf/examples/key-bindings.bash 2>/dev/null || true
fi

# 5. Yazi (Shell Wrapper to allow cwd change)
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# 6. Auto-LS on cd
cd() {
    builtin cd "$@" || return
    if command -v eza &> /dev/null; then
        eza --icons
    else
        ls
    fi
}
