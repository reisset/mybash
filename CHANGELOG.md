# MyBash V2 Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.2.0] - 2025-12-22

### Added

- **Uninstall Script** (`uninstall.sh`): Complete MyBash removal tool
  - Interactive prompts for safe removal of all components
  - Removes configuration symlinks (~/.config/starship.toml, ~/.config/kitty/kitty.conf)
  - Cleans up ~/.bashrc modifications with automatic backup
  - Optional removal of installed binaries from ~/.local/bin
  - Removes git delta configuration
  - Removes installation manifest file

- **Install Manifest System**: Automatic tracking of all installed files
  - Generated at ~/.mybash-manifest.txt during installation
  - Records all symlinks, binaries, and configuration changes
  - Enables safe, complete uninstallation
  - Tracks installation mode (desktop vs server)

- **mybash-tools Command**: Interactive tool discovery and reference
  - Uses glow for beautiful markdown rendering
  - Fallback to bat or less if glow unavailable
  - Quick access to complete tool documentation
  - Helps users discover available modern CLI tools

- **mybash-doctor Command**: Comprehensive health check and diagnostics
  - Verifies Nerd Fonts installation (font-config check)
  - Validates PATH configuration
  - Checks .bashrc integration
  - Verifies Starship installation and configuration
  - Tests Zoxide initialization
  - Scans for modern tool availability (eza, bat, fzf, fd, btop, delta, etc.)
  - Validates Git Delta configuration
  - Checks Kitty terminal setup
  - Provides actionable troubleshooting steps

- **Download Retry Logic**: Robust network error handling
  - Implements curl --retry flag with 5 automatic retry attempts
  - 3-second delay between retry attempts
  - --retry-all-errors flag for comprehensive error coverage
  - 10-second connection timeout
  - Applied to all GitHub release downloads
  - Applied to GPG key downloads
  - Applied to script installer downloads (Starship, Kitty)

### Changed

- **Welcome Message**: Modernized shell startup message
  - Removed nerdfetch execution (eliminated startup delay)
  - Now references mybash-tools for tool discovery
  - Added mybash-doctor reference for troubleshooting
  - Cleaner, faster message display

- **Installation Process**: Enhanced reliability and tracking
  - All downloads now use retry logic
  - Manifest file generated automatically at end of installation
  - Better error messages for failed downloads

- **Shell Startup Performance**: Significantly improved
  - Removed nerdfetch execution (~22ms reduction)
  - Conditional welcome message (only shows once per session)
  - No additional overhead from new features (mybash-tools and mybash-doctor are on-demand only)

### Removed

- **Nerdfetch**: Removed from installation and shell startup
  - Eliminated ~22ms shell startup delay
  - Removed from install.sh (lines 327-341)
  - Removed from bashrc_custom.sh (lines 58-63)
  - Users can manually install fastfetch if desired for system info display

- **Feature Planning Files**: Archived after v2.2 implementation
  - Deleted featuresplan.txt (implementation complete)
  - Deleted featuresuggestions.txt (features evaluated and implemented)

### Fixed

- **Network Reliability**: Installations no longer fail on temporary network issues
  - Automatic retry on connection timeouts
  - Automatic retry on DNS failures
  - Automatic retry on temporary HTTP errors

- **Uninstall Process**: Complete, safe cleanup of all MyBash modifications
  - Properly removes all symlinks
  - Safely removes bashrc source line with backup
  - Tracks and removes all installed files
  - No orphaned configurations left behind

### Security

- **Maintained Security Standards**: All new features follow existing security practices
  - uninstall.sh creates timestamped .bashrc backups before modifications
  - mybash-doctor performs read-only checks (no system modifications)
  - Retry logic doesn't bypass existing URL validation
  - All new scripts follow principle of least privilege

## [2.0.1] - 2024-12-21

### Fixed

- **Critical Bug Fix**: Fixed nerdfetch download failure (404 error) during `--server` mode installation
  - Changed URL from `https://raw.githubusercontent.com/TadeasKriz/nerdfetch/master/nerdfetch` 
  - To `https://raw.githubusercontent.com/ThatOneCalculator/NerdFetch/main/nerdfetch`
  - Verified with HTTP 200 response

- **Syntax Error Fix**: Resolved "local: can only be used in a function" error in install.sh
  - Removed `local` keyword from line 197: `kitty_path="$(command -v kitty)"`
  - Script now passes `bash -n` syntax validation

### Changed

- **Installation Script**: Improved error handling and URL validation for external downloads
- **Documentation**: Removed deprecated DEBUGGING.txt and TODOlist.txt files
- **Code Cleanup**: Removed obsolete checksum verification references

### Security

- **URL Validation**: Enhanced GitHub URL validation in install.sh to prevent malicious downloads
- **Path Safety**: Ensured PATH modifications use safe append pattern instead of overwrite

## [2.0.0] - 2024-12-20

### Added

- **Server Mode**: Added `--server` flag for headless/server installations
- **Architecture Support**: Added ARM64/aarch64 architecture detection and support
- **New Tools**: Added support for glow, gping, and NerdFetch utilities
- **Kitty Configuration**: Added default kitty terminal opacity setting (0.90)

### Changed

- **Installation Logic**: Refactored to use conditional logic based on installation mode
- **Path Management**: Improved PATH handling to preserve existing user configurations
- **Error Handling**: Enhanced error messages and user prompts

### Removed

- **Checksum Verification**: Removed non-functional checksum verification system
- **Obsolete Documentation**: Updated SECURITY.md to remove checksum references

## 2025-12-19: Modern CLI Tools Expansion (v2.1)

### Major Enhancements
- **Learning-First Toolset**: Integrated 12 modern CLI tools while preserving standard commands (`cd`, `du`, `find`, `ps`) to maintain muscle memory for vanilla systems.
- **Enhanced FZF**: Added `bat` and `eza` integration for rich previews during file searching (Ctrl+T).
- **Git Delta Integration**: Configured `delta` for beautiful, syntax-highlighted git diffs with Tokyo Night theme.
- **Smart Directory Navigation**: Integrated `zoxide` (`z`/`zi`) for frequency-based directory jumping.

### Tool Breakdown
- **Tier 1 (Core)**: `zoxide`, `tealdeer` (tldr), `btop`, `dust`, `fd`, `delta`, `lazygit`.
- **Tier 2 (Power)**: `procs` (`px`), `bandwhich`, `hyperfine`, `tokei`.
- **Tier 3 (GPU)**: `nvtop` (conditional installation).

### File Changes
- **New**: `docs/TOOLS.md` (Reference guide), `configs/delta.gitconfig`.
- **Modified**: `install.sh` (Installer logic), `scripts/aliases.sh`, `scripts/bashrc_custom.sh`, `README.md`, `SECURITY.md`.

## 2025-12-19: Transition from Ghostty to Kitty

### Architecture Changes
- **Terminal Emulator**: Replaced Ghostty (Snap-based) with Kitty (Official binary install).
  - *Reasoning*: Faster startup times (no Snap overhead), better reproducibility via text-based config, and native GPU acceleration.

### File Changes
- **Deleted**: `configs/ghostty.config`
- **Created**: `configs/kitty.conf`
  - Applied **Tokyo Night** theme.
  - Configured font rendering for **JetBrainsMono Nerd Font** (default) and **MesloLGS Nerd Font** (optional).
  - Added `window_padding_width 10` for better aesthetics.
- **Modified**: `install.sh`
  - Replaced Snap installation logic with official Kitty installer script.
  - Implemented secure script download and execution (no pipe-to-shell).
  - Added desktop integration (icons, .desktop file) and `update-alternatives` support.
  - **Bug Fix**: Fixed `local` variable scope errors in global context for Kitty, Starship, and Eza installer blocks.
- **Modified**: `README.md`
  - Updated Feature list and Customization instructions to reflect Kitty usage.

### Security Compliance
- All new installation steps follow the `SECURITY.md` guidelines regarding URL validation and script execution safety.


[Unreleased]: https://github.com/king/mybash/compare/v2.0.1...HEAD
[2.0.1]: https://github.com/king/mybash/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/king/mybash/compare/v1.0.0...v2.0.0

