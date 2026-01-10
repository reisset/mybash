#!/bin/bash

# MyBash V2 Installer
# Sets up Kitty, Starship, Yazi, and modern CLI tools.

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS_DIR="$REPO_DIR/configs"
SCRIPTS_DIR="$REPO_DIR/scripts"
BIN_DIR="$REPO_DIR/bin"
LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# State
SERVER_MODE=false
USE_SUDO=false
ARCH=$(uname -m)

# Helper Functions
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

confirm() {
    echo -ne "${YELLOW}[?] $1 (Y/n) ${NC}"
    read -r response
    [[ "$response" =~ ^[Nn]$ ]] && return 1
    return 0
}

confirm_no() {
    echo -ne "${YELLOW}[?] $1 (y/N) ${NC}"
    read -r response
    [[ "$response" =~ ^[Yy]$ ]]
}

# Print a boxed header message
print_header() {
    local msg="$1"
    local color="${2:-$CYAN}"
    local width=65
    local pad=$(( (width - ${#msg}) / 2 ))
    echo ""
    echo -e "${color}╔$(printf '═%.0s' $(seq 1 $width))╗${NC}"
    echo -e "${color}║$(printf ' %.0s' $(seq 1 $pad))${msg}$(printf ' %.0s' $(seq 1 $((width - pad - ${#msg}))))║${NC}"
    echo -e "${color}╚$(printf '═%.0s' $(seq 1 $width))╝${NC}"
    echo ""
}

print_success_box() {
    local msg="$1"
    print_header "$msg" "$GREEN"
}

get_github_arch() {
    if [[ "$ARCH" == "aarch64" ]]; then
        echo "arm64"
    else
        echo "$ARCH"
    fi
}

# Parse arguments
for arg in "$@"; do
    case $arg in
        --server)
            SERVER_MODE=true
            shift
            ;;
    esac
done

print_header "MyBash V2 Installer" "$CYAN"

log_info "Initializing installation..."
if $SERVER_MODE; then
    log_info "Mode: Server/Headless (Skipping desktop tools)"
else
    log_info "Mode: Full Desktop"
fi

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
if ! command -v curl &> /dev/null || ! command -v unzip &> /dev/null || ! command -v bzip2 &> /dev/null; then
    if $USE_SUDO;
        then
        sudo apt update && sudo apt install -y curl unzip fontconfig git bzip2 tar wget
    else
        log_warn "Ensure 'curl', 'unzip', 'git', 'fontconfig', 'bzip2', 'tar', and 'wget' are installed."
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

    # Security: Validate URL is from GitHub and uses HTTPS
    if [[ ! "$latest_url" =~ ^https://github\.com/ ]]; then
        log_error "Security: Invalid or non-GitHub URL detected: $latest_url"
        return 1
    fi

    log_info "Downloading $latest_url..."
    # MODIFIED: Add retry logic with --retry and --retry-delay
    if ! curl -fL \
         --retry 5 \
         --retry-delay 3 \
         --retry-all-errors \
         --connect-timeout 10 \
         -o "/tmp/$binary_name.archive" \
         "$latest_url"; then
        log_error "Failed to download $binary_name after 5 retries"
        return 1
    fi

    # Use dedicated extraction directory for clean cleanup
    local extract_dir="/tmp/$binary_name-extracted"
    mkdir -p "$extract_dir"

    if [[ "$latest_url" == *.tar.gz ]]; then
        tar -xzf "/tmp/$binary_name.archive" -C "$extract_dir"
    elif [[ "$latest_url" == *.tar.bz2 || "$latest_url" == *.tbz ]]; then
        tar -xjf "/tmp/$binary_name.archive" -C "$extract_dir"
    elif [[ "$latest_url" == *.tar.xz ]]; then
        tar -xJf "/tmp/$binary_name.archive" -C "$extract_dir"
    elif [[ "$latest_url" == *.zip ]]; then
        unzip -o "/tmp/$binary_name.archive" -d "$extract_dir"
    else
        # Assume it's a single binary
        mv "/tmp/$binary_name.archive" "$extract_dir/$binary_name"
        chmod +x "$extract_dir/$binary_name"
    fi

    # Find binary in extraction directory
    local bin_path
    bin_path=$(find "$extract_dir" -type f -name "$binary_name" | head -n 1)

    # If not found exactly, try finding something that starts with the name
    if [ -z "$bin_path" ]; then
        bin_path=$(find "$extract_dir" -type f -name "$binary_name*" | head -n 1)
    fi

    if [ -n "$bin_path" ]; then
        chmod +x "$bin_path"
        mv "$bin_path" "$LOCAL_BIN/"
        log_info "Installed $binary_name to $LOCAL_BIN"
    else
        log_error "Binary $binary_name not found after extraction."
    fi

    rm -rf "/tmp/$binary_name.archive" "$extract_dir"
}

# --------------------------------------------------------------------------
# 1.5 Fonts (Desktop only - servers don't render fonts, the SSH client does)
# --------------------------------------------------------------------------

if ! $SERVER_MODE; then
    if ! fc-list : family | grep -qi "JetBrainsMono Nerd Font"; then
        if confirm "Install JetBrainsMono Nerd Font (Recommended for icons)?"; then
            log_info "Downloading JetBrainsMono Nerd Font..."
            mkdir -p "$HOME/.local/share/fonts"

            FONT_ZIP="/tmp/JetBrainsMono.zip"
            # Using v3.2.1 (Latest stable at time of writing)
            if curl -fL \
                --retry 5 \
                --retry-delay 3 \
                --connect-timeout 10 \
                -o "$FONT_ZIP" \
                "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip"; then

                unzip -o -q "$FONT_ZIP" -d "$HOME/.local/share/fonts"
                rm -f "$FONT_ZIP"

                log_info "Rebuilding font cache (this may take a moment)..."
                fc-cache -f "$HOME/.local/share/fonts"
                log_info "JetBrainsMono Nerd Font installed."
            else
                log_error "Failed to download font."
            fi
        fi
    else
        log_info "JetBrainsMono Nerd Font is already installed."
    fi
fi

# --------------------------------------------------------------------------
# 2. Tools
# --------------------------------------------------------------------------

# Kitty (Optional)
if ! $SERVER_MODE; then
    if ! command -v kitty &> /dev/null; then
        if confirm "Install Kitty Terminal (GPU-accelerated, fast)?"; then
            log_info "Installing Kitty from official script..."
            
            # Download installer to temp file (Security: No pipe to shell)
            kitty_installer="/tmp/kitty_installer.sh"
            if curl -L \
                 --retry 5 \
                 --retry-delay 3 \
                 --retry-all-errors \
                 --connect-timeout 10 \
                 "https://sw.kovidgoyal.net/kitty/installer.sh" \
                 -o "$kitty_installer"; then
                chmod +x "$kitty_installer"
                
                # Run installer with launch=n to prevent auto-start
                "$kitty_installer" launch=n
                
                # Symlink kitty and kitten to local bin
                ln -sf ~/.local/kitty.app/bin/kitty "$LOCAL_BIN/kitty"
                ln -sf ~/.local/kitty.app/bin/kitten "$LOCAL_BIN/kitten"
                
                # Desktop Integration
                cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
                # Fix icon path in desktop file
                sed -i "s|Icon=kitty|Icon=$(readlink -f ~)/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty.desktop
                # Ensure Exec path is correct
                sed -i "s|Exec=kitty|Exec=$(readlink -f ~)/.local/bin/kitty|g" ~/.local/share/applications/kitty.desktop
                
                log_info "Kitty installed successfully."
                rm -f "$kitty_installer"
            else
                log_error "Failed to download Kitty installer."
            fi
        fi
    else
        log_info "Kitty is already installed."
    fi

    # Set Kitty as Default Terminal
    # Check both PATH and local bin location
    kitty_path=""
    if command -v kitty &> /dev/null; then
        kitty_path="$(command -v kitty)"
    elif [ -x "$LOCAL_BIN/kitty" ]; then
        kitty_path="$LOCAL_BIN/kitty"
    fi

    if [ -n "$kitty_path" ]; then
        # For system-wide installations, use update-alternatives
        if [[ "$kitty_path" == /usr/* ]] && $USE_SUDO; then
            if confirm_no "Set Kitty as default terminal (update-alternatives)?"; then
                if ! sudo update-alternatives --list x-terminal-emulator 2>/dev/null | grep -q "kitty"; then
                    sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$kitty_path" 50
                fi
                sudo update-alternatives --set x-terminal-emulator "$kitty_path"
                log_info "Kitty set as default via update-alternatives."
            fi
        fi

        # Always set via GNOME settings (works for both system and user installs)
        if command -v gsettings &> /dev/null; then
            if confirm_no "Set Kitty as default terminal (GNOME settings)?"; then
                gsettings set org.gnome.desktop.default-applications.terminal exec "$kitty_path"
                # Clear exec-arg to avoid issues with some shortcuts expecting specific args
                gsettings set org.gnome.desktop.default-applications.terminal exec-arg ''
                log_info "Kitty set as default via GNOME settings."
            fi
        fi
    fi
fi

# Starship
if ! command -v starship &> /dev/null; then
    if confirm "Install Starship?"; then
        log_info "Downloading Starship installer..."
        starship_installer="/tmp/starship_install.sh"

        # Download the installer script
        if ! curl -sS \
             --retry 5 \
             --retry-delay 3 \
             --retry-all-errors \
             --connect-timeout 10 \
             https://starship.rs/install.sh \
             -o "$starship_installer"; then
            log_error "Failed to download Starship installer"
        else
            # Make it executable and run it
            chmod +x "$starship_installer"
            "$starship_installer" -y $(! $USE_SUDO && echo "-b $LOCAL_BIN")
            rm -f "$starship_installer"
        fi
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

        # Download GPG key to temporary location first
        eza_gpg_tmp="/tmp/eza_gierens.asc"
        if ! wget --tries=5 \
                  --waitretry=3 \
                  --timeout=10 \
                  -qO "$eza_gpg_tmp" \
                  https://raw.githubusercontent.com/eza-community/eza/main/deb.asc; then
            log_error "Failed to download eza GPG key after retries"
        else
            # Import and verify the key
            sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg --yes < "$eza_gpg_tmp"
            rm -f "$eza_gpg_tmp"

            echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
            sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
            sudo apt update
            sudo apt install -y eza
        fi
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
# 2.5 Modern CLI Tools (Learning-First)
# --------------------------------------------------------------------------

log_info "Installing Modern CLI Tools (Learning-First)..."

if $USE_SUDO; then
    # APT Installations (where available)
    # Note: git-delta not included - uses GitHub fallback for broader compatibility
    sudo apt install -y tealdeer btop fd-find micro
    
    # Symlink fd if installed via apt
    if command -v fdfind &> /dev/null; then
        ln -sf "$(which fdfind)" "$LOCAL_BIN/fd"
    fi

    # GPU Monitor (NVTOP)
    if ! $SERVER_MODE; then
        if lspci 2>/dev/null | grep -iE 'vga|3d|display' | grep -qvE 'intel.*integrated'; then
            if confirm "Discrete GPU detected. Install nvtop?"; then
                sudo apt install -y nvtop
            fi
        fi
    fi
fi

# Zoxide
[ ! -x "$LOCAL_BIN/zoxide" ] && install_from_github "ajeetdsouza/zoxide" "zoxide" "$ARCH.*linux-musl.tar.gz"

# Glow
if ! command -v glow &> /dev/null; then
    install_from_github "charmbracelet/glow" "glow" "Linux_$(get_github_arch)\.tar\.gz"
fi

# Gping
if ! command -v gping &> /dev/null; then
    install_from_github "orf/gping" "gping" "Linux-musl-$(get_github_arch)\.tar\.gz"
fi

# Btop
if ! command -v btop &> /dev/null; then
    install_from_github "aristocratos/btop" "btop" "$ARCH.*linux-musl.tbz"
fi

# Tealdeer (tldr)
if ! command -v tldr &> /dev/null; then
    install_from_github "dbrgn/tealdeer" "tldr" "tealdeer-linux-$(get_github_arch)-musl"
fi

# Dust
[ ! -x "$LOCAL_BIN/dust" ] && install_from_github "bootandy/dust" "dust" "$ARCH.*linux-musl.tar.gz"

# FD (Fallback)
if ! command -v fd &> /dev/null && ! command -v fdfind &> /dev/null; then
    install_from_github "sharkdp/fd" "fd" "$ARCH.*linux-musl.tar.gz"
fi

# Delta (Fallback)
if ! command -v delta &> /dev/null; then
    install_from_github "dandavison/delta" "delta" "$ARCH.*linux-gnu.tar.gz"
fi

# Micro Editor
if ! command -v micro &> /dev/null; then
    install_from_github "zyedidia/micro" "micro" "linux$(get_github_arch).tar.gz"
fi

# Lazygit
if ! $SERVER_MODE; then
    if ! command -v lazygit &> /dev/null; then
        install_from_github "jesseduffield/lazygit" "lazygit" "lazygit_.*_linux_$(get_github_arch)\.tar\.gz"
    fi
fi

# Zellij (Terminal Multiplexer - Desktop only)
if ! $SERVER_MODE; then
    if ! command -v zellij &> /dev/null; then
        if confirm "Install Zellij (terminal multiplexer)?"; then
            install_from_github "zellij-org/zellij" "zellij" "$ARCH-unknown-linux-musl.tar.gz"
        fi
    fi
fi

# Procs
[ ! -x "$LOCAL_BIN/procs" ] && install_from_github "dalance/procs" "procs" "$ARCH-linux.zip"

# Bandwhich
if [ ! -x "$LOCAL_BIN/bandwhich" ]; then
    install_from_github "imsnif/bandwhich" "bandwhich" "$ARCH.*linux-musl.tar.gz"
    if [ -x "$LOCAL_BIN/bandwhich" ] && $USE_SUDO; then
        if confirm "Allow bandwhich to sniff network without sudo? (Uses setcap)"; then
            sudo setcap cap_sys_ptrace,cap_dac_read_search,cap_net_raw,cap_net_admin+ep "$LOCAL_BIN/bandwhich"
        fi
    fi
fi

# Hyperfine
[ ! -x "$LOCAL_BIN/hyperfine" ] && install_from_github "sharkdp/hyperfine" "hyperfine" "$ARCH.*linux-gnu.tar.gz"

# Tokei (Note: v13.0.0 has no binaries, using v12.1.2)
if ! command -v tokei &> /dev/null; then
    log_info "Installing tokei from GitHub (XAMPPRocky/tokei v12.1.2)..."

    # Determine tokei architecture pattern (ARM64 only has gnu, x86_64 has musl)
    if [ "$ARCH" = "aarch64" ]; then
        tokei_url="https://github.com/XAMPPRocky/tokei/releases/download/v12.1.2/tokei-aarch64-unknown-linux-gnu.tar.gz"
    else
        tokei_url="https://github.com/XAMPPRocky/tokei/releases/download/v12.1.2/tokei-x86_64-unknown-linux-musl.tar.gz"
    fi

    log_info "Downloading $tokei_url..."
    if curl -fL -o "/tmp/tokei.archive" "$tokei_url"; then
        tar -xzf "/tmp/tokei.archive" -C "/tmp/"
        if [ -f "/tmp/tokei" ]; then
            chmod +x "/tmp/tokei"
            mv "/tmp/tokei" "$LOCAL_BIN/tokei"
            log_info "Installed tokei to $LOCAL_BIN"
        else
            log_error "Binary tokei not found after extraction."
        fi
        rm -f "/tmp/tokei.archive"
    else
        log_error "Failed to download tokei"
        # Cargo fallback if github fails
        if command -v cargo &> /dev/null; then
            log_info "Tokei GitHub install failed, trying cargo..."
            cargo install tokei --root "$HOME/.local"
        fi
    fi
fi

# Copy documentation and scripts to local share for aliases
mkdir -p "$HOME/.local/share/mybash"
cp "$REPO_DIR/docs/TOOLS.md" "$HOME/.local/share/mybash/TOOLS.md"
cp "$REPO_DIR/asciiart.txt" "$HOME/.local/share/mybash/asciiart.txt"
cp -r "$REPO_DIR/scripts" "$HOME/.local/share/mybash/"
cp -r "$REPO_DIR/bin" "$HOME/.local/share/mybash/"

# Install mybash CLI to PATH
cp "$BIN_DIR/mybash" "$LOCAL_BIN/mybash"
chmod +x "$LOCAL_BIN/mybash"
log_info "Installed mybash CLI (run 'mybash -h' for help)"

# Git Delta Configuration
if command -v delta &> /dev/null; then
    if confirm "Configure git to use delta for diffs?"; then
        git config --global include.path "$CONFIGS_DIR/delta.gitconfig"
        log_info "Delta git configuration enabled."
    fi
fi

# --------------------------------------------------------------------------
# 3. Configuration
# --------------------------------------------------------------------------

log_info "Linking Configurations..."

if [ -d "$HOME/.config" ]; then
    # Kitty Config
    # Check if kitty is installed (path or local bin)
    if ! $SERVER_MODE && { command -v kitty &> /dev/null || [ -x "$LOCAL_BIN/kitty" ]; }; then
        mkdir -p "$HOME/.config/kitty"
        ln -sf "$CONFIGS_DIR/kitty.conf" "$HOME/.config/kitty/kitty.conf"
        log_info "Linked Kitty config."
    fi

    # Zellij Config
    if ! $SERVER_MODE && { command -v zellij &> /dev/null || [ -x "$LOCAL_BIN/zellij" ]; }; then
        mkdir -p "$HOME/.config/zellij"
        ln -sf "$CONFIGS_DIR/zellij.kdl" "$HOME/.config/zellij/config.kdl"
        log_info "Linked Zellij config."
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

# --------------------------------------------------------------------------
# 4. Generate Install Manifest
# --------------------------------------------------------------------------

log_info "Generating installation manifest..."

MANIFEST_FILE="$HOME/.mybash-manifest.txt"
rm -f "$MANIFEST_FILE"  # Clear old manifest if exists

# Record timestamp
echo "# MyBash Installation Manifest" >> "$MANIFEST_FILE"
echo "# Generated: $(date)" >> "$MANIFEST_FILE"
echo "# Installation Mode: $(if $SERVER_MODE; then echo 'server'; else echo 'desktop'; fi)" >> "$MANIFEST_FILE"
echo "" >> "$MANIFEST_FILE"

# Track symlinked configs
echo "# Configuration Symlinks" >> "$MANIFEST_FILE"
if [ -L "$HOME/.config/starship.toml" ]; then
    echo "symlink:$HOME/.config/starship.toml" >> "$MANIFEST_FILE"
fi
if [ -L "$HOME/.config/kitty/kitty.conf" ]; then
    echo "symlink:$HOME/.config/kitty/kitty.conf" >> "$MANIFEST_FILE"
fi
if [ -L "$HOME/.config/zellij/config.kdl" ]; then
    echo "symlink:$HOME/.config/zellij/config.kdl" >> "$MANIFEST_FILE"
fi

# Track bashrc modification
if grep -qF "source $SCRIPTS_DIR/bashrc_custom.sh" "$HOME/.bashrc"; then
    echo "bashrc_line:source $SCRIPTS_DIR/bashrc_custom.sh" >> "$MANIFEST_FILE"
fi

# Track installed binaries in ~/.local/bin
echo "" >> "$MANIFEST_FILE"
echo "# Installed Binaries" >> "$MANIFEST_FILE"
for binary in eza bat rg fzf zoxide yazi starship kitty kitten \
              btop dust fd delta lazygit procs bandwhich hyperfine tokei \
              glow gping tldr micro mybash zellij; do
    if [ -x "$LOCAL_BIN/$binary" ]; then
        echo "binary:$LOCAL_BIN/$binary" >> "$MANIFEST_FILE"
    fi
done

# Track git config changes
if git config --global --get include.path 2>/dev/null | grep -q "delta.gitconfig"; then
    echo "git_config:include.path=$CONFIGS_DIR/delta.gitconfig" >> "$MANIFEST_FILE"
fi

log_info "Manifest saved to $MANIFEST_FILE"

print_success_box "Installation Complete!"
log_warn "IMPORTANT: To see icons, set your terminal font to 'JetBrainsMono Nerd Font' (or MesloLGS) manually if not using Kitty."
log_info "Restart your shell to apply changes."
