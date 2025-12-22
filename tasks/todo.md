# Install Script Bug Fixes

## Root Cause Analysis

### Bug 1: glow downloads Darwin (macOS) instead of Linux
**Location:** `install.sh:312`
**Current code:**
```bash
[ ! -x "$LOCAL_BIN/glow" ] && install_from_github "charmbracelet/glow" "glow" "$ARCH.*.tar.gz"
```

**Issue:**
The pattern `"$ARCH.*.tar.gz"` (expands to `"x86_64.*.tar.gz"`) matches BOTH:
- `glow_2.1.1_Darwin_x86_64.tar.gz` ✓ (matched first alphabetically)
- `glow_2.1.1_Linux_x86_64.tar.gz` ✓

Since `grep -E` returns the first match and assets are alphabetically ordered, Darwin comes before Linux.

**Root cause:** Missing OS name in pattern → pattern too generic

---

### Bug 2: gping fails to find release
**Location:** `install.sh:315`
**Current code:**
```bash
[ ! -x "$LOCAL_BIN/gping" ] && install_from_github "orf/gping" "gping" "$ARCH.*linux-musl.tar.gz"
```

**Issue:**
Pattern `"$ARCH.*linux-musl.tar.gz"` (expands to `"x86_64.*linux-musl.tar.gz"`) doesn't match actual filename `gping-Linux-musl-x86_64.tar.gz` because:
1. "linux" is lowercase in pattern but "Linux" is capitalized in actual filename (case-sensitive grep)
2. Architecture comes at the END of filename, not beginning

**Root cause:** Case mismatch + wrong architecture position in pattern

---

### Bug 3: Kitty default terminal fails when installed locally
**Location:** `install.sh:195-208`
**Current code:**
```bash
if command -v kitty &> /dev/null && $USE_SUDO; then
    if confirm_no "Set Kitty as default terminal?"; then
        if ! update-alternatives --list x-terminal-emulator | grep -q "kitty"; then
            sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$(command -v kitty)" 50
        fi
        sudo update-alternatives --set x-terminal-emulator "$(command -v kitty)"
```

**Issue:**
When Kitty is installed locally to `~/.local/bin/kitty` (not system-wide via apt), `update-alternatives --install` fails because:
- `update-alternatives` expects paths like `/usr/bin/kitty` (system paths)
- User-local binaries in `~/.local/bin` are not suitable for system-wide alternatives

**Error message:**
```
update-alternatives: error: alternative /home/king/.local/share/../bin/kitty for x-terminal-emulator not registered; not setting
```

**Root cause:** Attempting to register user-local binary with system-wide alternatives mechanism

---

## Fix Plan

- [x] **Fix glow pattern** - Add "Linux" to pattern to prevent Darwin match
- [x] **Fix gping pattern** - Use correct case and architecture position
- [x] **Fix kitty alternatives** - Only attempt when kitty is system-installed
- [x] **Add ARM64 support** - Map aarch64 to arm64 for both tools
- [x] **Verify patterns** - Test against GitHub releases API
- [x] Update todo.md with results

---

## Proposed Changes

### 1. Fix glow (install.sh:312)
```bash
# Before:
[ ! -x "$LOCAL_BIN/glow" ] && install_from_github "charmbracelet/glow" "glow" "$ARCH.*.tar.gz"

# After:
[ ! -x "$LOCAL_BIN/glow" ] && install_from_github "charmbracelet/glow" "glow" "Linux_$ARCH.*\.tar\.gz"
```

### 2. Fix gping (install.sh:315)
```bash
# Before:
[ ! -x "$LOCAL_BIN/gping" ] && install_from_github "orf/gping" "gping" "$ARCH.*linux-musl.tar.gz"

# After:
[ ! -x "$LOCAL_BIN/gping" ] && install_from_github "orf/gping" "gping" "Linux-musl-$ARCH\.tar\.gz"
```

### 3. Fix kitty alternatives (install.sh:195-208)
```bash
# Before:
if command -v kitty &> /dev/null && $USE_SUDO; then
    if confirm_no "Set Kitty as default terminal?"; then
        if ! update-alternatives --list x-terminal-emulator | grep -q "kitty"; then
            sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$(command -v kitty)" 50
        fi

# After:
if command -v kitty &> /dev/null && $USE_SUDO; then
    # Only attempt to set as default if installed system-wide
    local kitty_path="$(command -v kitty)"
    if [[ "$kitty_path" == /usr/* ]] && confirm_no "Set Kitty as default terminal?"; then
        if ! update-alternatives --list x-terminal-emulator | grep -q "kitty"; then
            sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$kitty_path" 50
        fi
```

---

## Testing Strategy

1. Test glow download pattern matches correct asset
2. Test gping download pattern matches correct asset
3. Test kitty alternatives:
   - System-installed kitty → should prompt and work
   - User-local kitty → should skip silently (no error)

---

## Review Summary

### Changes Made

All three bugs have been fixed with minimal, targeted changes:

#### 1. Fixed glow (install.sh:313-318)
**Change:** Added architecture mapping and corrected pattern
- Maps `aarch64` → `arm64` for GitHub release compatibility
- Pattern changed from `"$ARCH.*.tar.gz"` to `"Linux_${glow_arch}\.tar\.gz"`
- Now correctly matches Linux builds instead of Darwin (macOS)

**Verified:**
- x86_64: `glow_2.1.1_Linux_x86_64.tar.gz` ✓
- arm64: `glow_2.1.1_Linux_arm64.tar.gz` ✓

#### 2. Fixed gping (install.sh:320-325)
**Change:** Added architecture mapping and corrected pattern
- Maps `aarch64` → `arm64` for GitHub release compatibility
- Pattern changed from `"$ARCH.*linux-musl.tar.gz"` to `"Linux-musl-${gping_arch}\.tar\.gz"`
- Fixed case sensitivity (Linux not linux) and architecture position

**Verified:**
- x86_64: `gping-Linux-musl-x86_64.tar.gz` ✓
- arm64: `gping-Linux-musl-arm64.tar.gz` ✓

#### 3. Fixed kitty alternatives (install.sh:195-203)
**Change:** Added system path check before attempting update-alternatives
- Only attempts to set as default if kitty is in `/usr/*` (system-installed)
- Prevents error when kitty is user-local (`~/.local/bin/kitty`)
- User-local installations skip silently without error

**Impact:**
- System-installed kitty: Works as before ✓
- User-local kitty: No error, skips gracefully ✓

### Code Quality
- **Simplicity:** All changes are minimal, affecting only necessary lines
- **Consistency:** Follows existing patterns (tealdeer, lazygit use same arch mapping)
- **No side effects:** Changes isolated to specific installations, no impact on other tools

### Files Modified
- `install.sh` (3 locations, ~15 lines total)
- All changes maintain existing code style and security patterns
