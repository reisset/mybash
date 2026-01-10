# MyBash V2 Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.5.0] - 2026-01-10

### Added

- **Kitty Framed Aesthetic**: Enhanced terminal visual experience without a multiplexer
  - Powerline-style tab bar at bottom edge (like status bar)
  - Visible window borders with Tokyo Night colors
  - Round powerline separators for modern look
  - Tab bar shows even with single tab for consistent UI

- **Colorized Welcome Banner**: Tokyo Night gradient ASCII art
  - Pink → Blue → Purple gradient using RGB ANSI codes
  - Matches overall theme consistency
  - More visually striking on terminal startup

- **Dynamic Welcome Line**: Shows current date and version below banner
  - Format: "Friday, January 10 • mybash v2.5.0"
  - Subtle gray color for non-intrusive display

### Removed

- **Zellij**: Removed terminal multiplexer (redundant with Kitty's native features)
  - Removed installation section from `install.sh`
  - Deleted `configs/zellij.kdl`
  - Removed from documentation and manifest

- **Unused CLI Tools**: Cleaned up rarely-used utilities
  - **bandwhich**: Network bandwidth monitor (niche use case)
  - **hyperfine**: Command benchmarking tool (occasional use)
  - **tokei**: Code statistics (showcase tool)
  - Faster installation and more focused toolset

### Changed

- **Installer UI Enhancement**: Added visual box formatting for better user experience
  - PowerShell-style Unicode box borders (╔═══╗) at installer start and completion
  - Cyan box for "MyBash V2 Installer" header
  - Green success box for "Installation Complete!" message

## [2.3.0] - 2026-01-02

### Added

- **Unified `mybash` CLI**: Consolidated help and utility commands into a single interface
  - `mybash` - Quick status showing version and help hint
  - `mybash -h` / `--help` - CLI-style help with subcommands and quick alias reference
  - `mybash tools` - Browse tool reference guide (renders TOOLS.md with glow)
  - `mybash doctor` - Run health checks and diagnostics
  - `mybash version` - Show version info
  - Follows modern CLI patterns similar to git, docker, etc.

- **Micro Editor**: Modern, intuitive terminal text editor
  - Installs via apt (with sudo) or GitHub fallback (without sudo)
  - Set as default `EDITOR` and `VISUAL` for git commits, crontab, etc.
  - New aliases: `m` and `edit` point to micro
  - Power Mode includes optional `alias nano='micro'` for full replacement
  - Learning-First: `nano` remains nano by default

### Fixed

- **Font installation prompt in server mode**: Skipped font install on `--server` mode
  - Servers don't render fonts - the SSH client (your local terminal) does
  - Previously prompted to install JetBrainsMono even on headless systems
  - Now the entire font section is skipped when using `./install.sh --server`

### Changed

- **Installer Optimization**: Reduced code duplication for architecture mapping
  - Added `get_github_arch` helper function
  - Replaced repetitive `aarch64` -> `arm64` mapping blocks with single function call
  - Simplified installation logic for Glow, Gping, Tealdeer, and Lazygit

- **Project Structure Reorganization**: Improved repository clarity by separating standalone tools from internal logic.
  - Created `bin/` directory for standalone executable tools.
  - Moved `mybash-doctor.sh` and `mybash-tools.sh` from `scripts/` to `bin/`.
  - Updated `install.sh` to properly deploy the new `bin/` directory to `~/.local/share/mybash/bin/`.
  - Updated `scripts/aliases.sh` and internal script references to reflect new paths.
  - Maintained `scripts/` specifically for internal shell configuration files (`aliases.sh`, `bashrc_custom.sh`).

- **FZF Keybindings Now Auto-Enabled**: Changed from opt-in lazy-loading to auto-enable on startup
  - Ctrl+R (history search) and Ctrl+T (file finder) now work immediately after installation
  - Keybindings cannot be lazy-loaded since they're handled at readline level, not as shell functions
  - Adds ~50ms to startup but provides expected behavior for standard Ctrl+R muscle memory
  - Can be disabled by setting `export MYBASH_DISABLE_FZF=1` before sourcing bashrc
  - Removed `fzf-enable` command (no longer needed)

### Fixed

- **ASCII Art Banner Formatting**: Welcome banner now displays cleanly without bat decorations
  - Changed `cat` to `command cat` in bashrc_custom.sh to bypass bat alias
  - Previously showed file path, line numbers, and decorative borders from bat
  - Now displays raw ASCII art as intended
  - Added blank line between ASCII art and info message for better spacing

- **CRITICAL: Install script exits early and doesn't configure .bashrc**: Fixed lazygit download pattern
  - Two issues: (1) Pattern used "Linux" instead of "linux", (2) Pattern ended with `$` anchor
  - The `$` anchor failed because JSON lines end with `"` not `.tar.gz`
  - This caused install_from_github to fail, and with `set -e`, the entire script exited
  - Script never reached .bashrc configuration or manifest generation
  - Changed pattern from `lazygit_.*_Linux_${lazygit_arch}\.tar\.gz$` to `lazygit_.*_linux_${lazygit_arch}\.tar\.gz`
  - Install now completes successfully and properly configures .bashrc

- **CRITICAL: Ctrl+Alt+T keyboard shortcut broken after uninstall**: Script now restores default terminal
  - Checks if Kitty is set as default via update-alternatives
  - Checks if Kitty is set as default via GNOME gsettings
  - Restores gnome-terminal as default **before** removing Kitty binary
  - Prevents Ubuntu's terminal shortcut (Ctrl+Alt+T) from failing silently
  - Users prompted to confirm terminal restoration

- **uninstall.sh hanging issue**: Script now properly cleans up shell environment
  - Unsets PROMPT_COMMAND to prevent deleted starship from being called
  - Resets PS1 to basic prompt before script exits
  - Prevents infinite "No such file or directory" errors when starship binary is removed
  - Users can now exit cleanly without force-closing terminal

- **Kitty not set as default terminal after install**: Fixed install.sh logic for setting default terminal
  - Previous logic only set Kitty as default if installed to /usr/* (system-wide)
  - Kitty is installed to ~/.local/bin/ (user-local), so check always failed
  - Now separates update-alternatives (for system installs) from GNOME gsettings (works for all)
  - GNOME settings method works for both system and user-local Kitty installations
  - Ctrl+Alt+T now launches Kitty after installation completes

- **"unknown option: --bash" error on terminal startup**: Fixed FZF initialization in bashrc_custom.sh
  - Older fzf versions don't support the --bash flag
  - Error was displayed despite stderr redirect because eval tried to execute error text
  - Now checks if fzf supports --bash before using it
  - Falls back to traditional key-bindings.bash source for older versions
  - Error message no longer appears on terminal startup

- **CRITICAL: Fresh install directory creation**: Fixed `ln: No such file` error by creating `~/.local/bin` immediately at script start
  - Ensures destination exists before any tools attempt to link binaries
  - Prevents script failure on brand new OS installations

- **Font Installation**: Added missing download and install logic for JetBrainsMono Nerd Font
  - Previously only checked for font presence but did not install it
  - Now downloads latest release from GitHub, installs to `~/.local/share/fonts`, and runs `fc-cache`
  - Ensures icons render correctly immediately after install

- **Kitty Path Resolution**: Improved Kitty detection for first-run scenarios
  - Fixed issue where config linking and default terminal setting failed if Kitty wasn't yet in PATH
  - Now explicitly checks `~/.local/bin/kitty` in addition to `command -v kitty`
  - Ensures `Ctrl+Alt+T` works immediately after installation without needing a relogin

### Removed

- **`mybash-tools` command**: Replaced by `mybash tools` subcommand
- **`mybash-doctor` command**: Replaced by `mybash doctor` subcommand
- **`bin/mybash-tools.sh`**: Consolidated into unified `bin/mybash` script
- **`bin/mybash-doctor.sh`**: Consolidated into unified `bin/mybash` script

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


[Unreleased]: https://github.com/reisset/mybash/compare/v2.5.0...HEAD
[2.5.0]: https://github.com/reisset/mybash/compare/v2.3.0...v2.5.0
[2.3.0]: https://github.com/reisset/mybash/compare/v2.2.0...v2.3.0
[2.2.0]: https://github.com/reisset/mybash/compare/v2.0.1...v2.2.0
[2.0.1]: https://github.com/reisset/mybash/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/reisset/mybash/compare/v1.0.0...v2.0.0

