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

# 7. Zoxide (Smart Directory Jumper)
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init bash)"
fi

# 8. Enhanced FZF Previews (bat + eza integration)
if command -v fzf &> /dev/null; then
    # Use bat for file previews and eza for directory previews
    # Only applies to CTRL-T (files) by default
    export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || eza --tree --level=2 --icons {} 2>/dev/null || cat {}'"
fi

# 9. Learning Mode Indicator (show on shell start)
if [[ $- == *i* ]]; then
    # Run nerdfetch if in Kitty
    if [[ "$TERM" == "xterm-kitty" ]] || [ -n "$KITTY_PID" ]; then
        if command -v nerdfetch &> /dev/null; then
            nerdfetch
        fi
    fi

    if [ -z "$MYBASH_WELCOME_SHOWN" ]; then
        echo -e "\033[1;36m📚 MyBash V2 - Learning Mode Active\033[0m"
        echo -e "\033[0;90mNew tools: z/zi, tldr, btop, dust, fd, delta, lg, glow, gping\033[0m"
        echo -e "\033[0;90mOriginal commands (cd, du, find, ps) still work! Type 'tools' for quick reference.\033[0m"
        export MYBASH_WELCOME_SHOWN=1
    fi
fi
