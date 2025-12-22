#!/bin/bash

# MyBash Doctor - Health check and diagnostics
# Helps users troubleshoot installation issues

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

check_pass() { echo -e "${GREEN}✅${NC} $1"; }
check_warn() { echo -e "${YELLOW}⚠️ ${NC} $1"; }
check_fail() { echo -e "${RED}❌${NC} $1"; }
check_info() { echo -e "${BLUE}ℹ️ ${NC} $1"; }

echo "============================================="
echo "🩺 MyBash Doctor - Health Check"
echo "============================================="
echo ""

ISSUES_FOUND=0

# Check 1: Nerd Fonts
echo "1. Checking Nerd Fonts installation..."
if fc-list 2>/dev/null | grep -qi "nerd font"; then
    check_pass "Nerd Fonts detected"
else
    check_warn "Nerd Fonts not detected - icons may not render properly"
    check_info "Install with: wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

# Check 2: PATH configuration
echo ""
echo "2. Checking PATH configuration..."
if [[ ":$PATH:" == *":$HOME/.local/bin:"* ]]; then
    check_pass "~/.local/bin is in PATH"
else
    check_fail "~/.local/bin is NOT in PATH"
    check_info "Add to ~/.bashrc: export PATH=\"\$HOME/.local/bin:\$PATH\""
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

# Check 3: Bashrc sourcing
echo ""
echo "3. Checking .bashrc integration..."
if grep -q "bashrc_custom.sh" "$HOME/.bashrc" 2>/dev/null; then
    check_pass "MyBash is sourced in ~/.bashrc"
else
    check_fail "MyBash is NOT sourced in ~/.bashrc"
    check_info "Run install.sh to add source line"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

# Check 4: Starship
echo ""
echo "4. Checking Starship prompt..."
if command -v starship &> /dev/null; then
    check_pass "Starship is installed ($(starship --version | head -n1))"

    if [ -f "$HOME/.config/starship.toml" ]; then
        check_pass "Starship config found at ~/.config/starship.toml"
    else
        check_warn "Starship config not found"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
else
    check_fail "Starship is not installed"
    check_info "Install with: curl -sS https://starship.rs/install.sh | sh"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

# Check 5: Zoxide
echo ""
echo "5. Checking Zoxide (smart cd)..."
if command -v zoxide &> /dev/null; then
    check_pass "Zoxide is installed"

    # Check if initialized in current shell
    if type -t __zoxide_z &> /dev/null; then
        check_pass "Zoxide is initialized (z command available)"
    else
        check_warn "Zoxide installed but not initialized in current shell"
        check_info "Restart your shell or run: source ~/.bashrc"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
else
    check_warn "Zoxide not installed (optional)"
fi

# Check 6: Modern tools availability
echo ""
echo "6. Checking modern CLI tools..."
TOOLS_FOUND=0
TOOLS_TOTAL=0

check_tool() {
    local tool=$1
    local name=$2
    TOOLS_TOTAL=$((TOOLS_TOTAL + 1))

    if command -v "$tool" &> /dev/null; then
        TOOLS_FOUND=$((TOOLS_FOUND + 1))
        return 0
    else
        return 1
    fi
}

check_tool "eza" "eza" && check_pass "eza (modern ls)" || check_warn "eza not found"
check_tool "bat" "bat" && check_pass "bat (syntax highlighting)" || check_warn "bat not found"
check_tool "fzf" "fzf" && check_pass "fzf (fuzzy finder)" || check_warn "fzf not found"
check_tool "rg" "ripgrep" && check_pass "ripgrep (fast grep)" || check_warn "ripgrep not found"
check_tool "fd" "fd" && check_pass "fd (fast find)" || check_warn "fd not found"
check_tool "btop" "btop" && check_pass "btop (system monitor)" || check_warn "btop not found"
check_tool "delta" "delta" && check_pass "delta (git diff)" || check_warn "delta not found"

echo ""
check_info "Found $TOOLS_FOUND/$TOOLS_TOTAL modern tools"

# Check 7: Git Delta configuration
echo ""
echo "7. Checking Git Delta configuration..."
if command -v delta &> /dev/null; then
    if git config --global --get core.pager 2>/dev/null | grep -q "delta" || \
       git config --global --get include.path 2>/dev/null | grep -q "delta"; then
        check_pass "Git is configured to use delta"
    else
        check_warn "Delta installed but not configured for git"
        check_info "Run: git config --global include.path ~/mybash/configs/delta.gitconfig"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
fi

# Check 8: Kitty terminal
echo ""
echo "8. Checking Kitty terminal..."
if command -v kitty &> /dev/null; then
    check_pass "Kitty is installed"

    if [ -f "$HOME/.config/kitty/kitty.conf" ]; then
        check_pass "Kitty config found"
    else
        check_warn "Kitty installed but config not found"
    fi
else
    check_info "Kitty not installed (optional for --server mode)"
fi

# Check 9: Shell type
echo ""
echo "9. Checking shell environment..."
if [ -n "$BASH_VERSION" ]; then
    check_pass "Running in Bash (version $BASH_VERSION)"
else
    check_warn "Not running in Bash - MyBash is designed for Bash"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

# Summary
echo ""
echo "============================================="
if [ $ISSUES_FOUND -eq 0 ]; then
    check_pass "All checks passed! MyBash is healthy."
else
    check_warn "Found $ISSUES_FOUND issue(s) that may need attention"
    echo ""
    echo "For help, see: https://github.com/reisset/mybash"
fi
echo "============================================="
echo ""
