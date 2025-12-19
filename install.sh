#!/bin/bash

# MyBash V2 Installer
# Sets up Ghostty, Starship, Yazi, and modern CLI tools.

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS_DIR="$REPO_DIR/configs"
SCRIPTS_DIR="$REPO_DIR/scripts"
LOCAL_BIN="$HOME/.local/bin"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# State
USE_SUDO=false
ARCH=$(uname -m)

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

confirm() {
    read -r -p "$1 [Y/n] " response
    case "$response" in
        [yY][eE][sS]|[yY]|"") return 0 ;;
        *)
            return 1 ;;
    esac
}

confirm_no() {
    read -r -p "$1 [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *)
            return 1 ;;
    esac
}

# Ensure local bin exists
mkdir -p "$LOCAL_BIN"
export PATH="$LOCAL_BIN:$PATH"

# --------------------------------------------------------------------------
# 1. Initialization
# --------------------------------------------------------------------------

log_info "Initializing MyBash V2 Installer..."

if [[ "$ARCH" == "x86_64" ]]; then
    log_info "Detected Architecture: x86_64"
elif [[ "$ARCH" == "aarch64" ]]; then
    log_info "Detected Architecture: ARM64"
else
    log_warn "Architecture $ARCH might require manual steps for some tools."
fi

# Check Sudo
if confirm "Do you want to use sudo for system-wide installs (recommended)?"; then
    if sudo -v; then
        USE_SUDO=true
        log_info "Sudo privileges confirmed."
    else
        log_warn "Sudo failed. Falling back to local installation where possible."
    fi
fi

# Deps
if ! command -v curl &> /dev/null || ! command -v unzip &> /dev/null; then
    if $USE_SUDO; then
        sudo apt update && sudo apt install -y curl unzip fontconfig git
    else
        log_warn "Ensure 'curl', 'unzip', 'git', and 'fontconfig' are installed."
    fi
fi

# Helper for GitHub Releases
install_from_github() {
    local repo=$1
    local binary_name=$2
    local match_pattern=$3
    
    log_info "Installing $binary_name from GitHub ($repo)..."
    
    local latest_url
    latest_url=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | \
        grep "browser_download_url" | \
        grep -E "$match_pattern" | \
        cut -d '"' -f 4 | head -n 1)

    if [ -z "$latest_url" ]; then
        log_error "Could not find release for $binary_name."
        return 1
    fi

    log_info "Downloading $latest_url..."
    curl -L -o "/tmp/$binary_name.archive" "$latest_url"

    if [[ "$latest_url" == *.tar.gz ]]; then
        tar -xzf "/tmp/$binary_name.archive" -C "/tmp/"
    elif [[ "$latest_url" == *.zip ]]; then
        unzip -o "/tmp/$binary_name.archive" -d "/tmp/$binary_name-extracted"
    fi

    # Find binary
    local bin_path
    bin_path=$(find /tmp -type f -name "$binary_name" -perm -u+x | head -n 1)

    if [ -n "$bin_path" ]; then
        mv "$bin_path" "$LOCAL_BIN/"
        log_info "Installed $binary_name to $LOCAL_BIN"
    else
        log_error "Binary $binary_name not found after extraction."
    fi
    
    rm -rf "/tmp/$binary_name.archive" "/tmp/$binary_name-extracted"
}

# --------------------------------------------------------------------------
# 2. Tools
# --------------------------------------------------------------------------

# Ghostty (Optional)
if ! command -v ghostty &> /dev/null; then
    if $USE_SUDO; then
        # Default to NO for Ghostty
        if confirm_no "Install Ghostty Terminal via Snap (Optional, GPU-accelerated)?"; then
             sudo snap install ghostty --classic
        fi
    else
        log_warn "Skipping Ghostty (requires sudo/snap)."
    fi
else
    log_info "Ghostty is already installed."
fi

# Set Ghostty as Default Terminal (Only if installed)
if command -v ghostty &> /dev/null && $USE_SUDO; then
    if confirm_no "Set Ghostty as default terminal?"; then
        if ! update-alternatives --list x-terminal-emulator | grep -q "ghostty"; then
            sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$(command -v ghostty)" 50
        fi
        sudo update-alternatives --set x-terminal-emulator "$(command -v ghostty)"
        
        if command -v gsettings &> /dev/null; then
             gsettings set org.gnome.desktop.default-applications.terminal exec "$(command -v ghostty)"
        fi
        log_info "Ghostty set as default."
    fi
fi

# Starship
if ! command -v starship &> /dev/null; then
    if confirm "Install Starship?"; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y $(! $USE_SUDO && echo "-b $LOCAL_BIN")
    fi
fi

# Yazi
if ! command -v yazi &> /dev/null; then
    if confirm "Install Yazi?"; then
        # yazi-x86_64-unknown-linux-gnu.zip
        install_from_github "sxyazi/yazi" "yazi" "$ARCH.*linux-gnu.zip"
    fi
fi

# Eza, Rg, Bat, FZF
if $USE_SUDO; then
    # Eza (needs repo setup usually, but checking apt first)
    if ! command -v eza &> /dev/null; then
        log_info "Installing Eza setup..."
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg --yes
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo apt update
        sudo apt install -y eza
    fi
    
    # Common tools
    sudo apt install -y ripgrep bat fzf
    
    # Symlink batcat to bat if needed
    if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
        mkdir -p "$LOCAL_BIN"
        ln -sf /usr/bin/batcat "$LOCAL_BIN/bat"
    fi
else
    # Local fallbacks
    [ ! -x "$LOCAL_BIN/eza" ] && install_from_github "eza-community/eza" "eza" "$ARCH.*linux-gnu.tar.gz"
    [ ! -x "$LOCAL_BIN/rg" ] && install_from_github "BurntSushi/ripgrep" "rg" "linux-musl.tar.gz"
    [ ! -x "$LOCAL_BIN/bat" ] && install_from_github "sharkdp/bat" "bat" "$ARCH.*linux-musl.tar.gz"
    
    if [ ! -x "$LOCAL_BIN/fzf" ]; then
        log_info "Installing FZF locally..."
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --bin
        ln -sf ~/.fzf/bin/fzf "$LOCAL_BIN/fzf"
    fi
fi

# --------------------------------------------------------------------------
# 3. Configuration
# --------------------------------------------------------------------------

log_info "Linking Configurations..."

if [ -d "$HOME/.config" ]; then
    # Only link Ghostty config if it's actually installed
    if command -v ghostty &> /dev/null; then
        mkdir -p "$HOME/.config/ghostty"
        ln -sf "$CONFIGS_DIR/ghostty.config" "$HOME/.config/ghostty/config"
        log_info "Linked Ghostty config."
    fi
    
    # Always link Starship
    ln -sf "$CONFIGS_DIR/starship_text.toml" "$HOME/.config/starship.toml"
    log_info "Linked Starship config."
fi

# Bashrc Hook
SOURCE_LINE="source $SCRIPTS_DIR/bashrc_custom.sh"
if ! grep -qF "$SOURCE_LINE" "$HOME/.bashrc"; then
    echo "" >> "$HOME/.bashrc"
    echo "# MyBash Custom Config" >> "$HOME/.bashrc"
    echo "$SOURCE_LINE" >> "$HOME/.bashrc"
    log_info "Added source line to ~/.bashrc"
else
    log_info "bashrc already contains the source line."
fi

log_info "Installation Complete! Restart your shell."
log_warn "IMPORTANT: To see icons, set your terminal font to 'JetBrainsMono Nerd Font' manually in Preferences!"