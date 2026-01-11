# MyBash V2 Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.7.1] - 2026-01-11

### Changed

- **Starship Time Display**: Moved time to left prompt (Bash doesn't support right_format)
  - Changed prefix from "at" to "//" for cleaner look
  - Displays as `// 󱑈 HH:MM` at end of prompt line

### Removed

- **Kitty Tab Bar**: Hidden redundant bottom tab bar
  - Tab information already visible in prompt
  - Cleaner terminal appearance

---

## [2.7.0] - 2026-01-11

### Added

- **Starship Time Display**: Time clock now appears in prompt
  - Displays as `󱑈 HH:MM` format
  - Uses Tokyo Night cyan color scheme

- **Docker Context Display**: Docker environment now shown with other dev tools
  - Appears in "via" section alongside Python, Node, etc.
  - Only displays when in Docker contexts

### Changed

- **Cleaner Welcome Banner**: Removed redundant date string below ASCII art
  - Date no longer duplicates Starship's time display
  - Streamlined terminal startup appearance

### Fixed

- **Starship Config**: Docker module now properly displays (was enabled but not in format string)
- **Directory Truncation**: Confirmed 3-level truncation working as intended

---

## [2.6.0] - 2026-01-10

### Added

- **Kitty Kitten Integration**: Terminal eye candy and utilities
  - `icat` alias - Display images directly in terminal
  - `kdiff` alias - Syntax-highlighted side-by-side diff viewer
  - `Ctrl+Shift+E` - Hints kitten (clickable URLs, paths, git hashes)
  - `Ctrl+Shift+P>F` - Quick file path selection
  - `Ctrl+Shift+U` - Unicode/emoji picker
  - `Ctrl+Shift+F5` - Live theme browser and switcher

### Changed

- **ASCII Art Banner**: Reverted to clean plain text (no color gradient)
  - Simplified visual presentation
  - Faster rendering without RGB escape codes

### Documentation

- Updated `TOOLS.md` with Kitty kittens reference section
- Updated `README.md` to mention kitten features

---

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

- **Dynamic Welcome Line**: Shows current date and version below banner
  - Format: "Friday, January 10 • mybash v2.5.0"

### Removed

- **Zellij**: Removed terminal multiplexer (redundant with Kitty's native features)
- **Unused CLI Tools**: bandwhich, hyperfine, tokei (rarely used, cleaner install)

### Changed

- **Installer UI**: Added visual box formatting with Unicode borders for better UX

---

## [2.3.0] - 2026-01-02

### Added

- **Unified `mybash` CLI**: Single command interface for all utilities
  - `mybash -h` - Help and alias reference
  - `mybash tools` - Browse tool guide with glow
  - `mybash doctor` - Health checks and diagnostics
  - `mybash version` - Version info

- **Micro Editor**: Modern terminal text editor
  - Set as default `EDITOR` and `VISUAL`
  - Aliases: `m`, `edit`

### Changed

- **FZF Auto-Enabled**: Ctrl+R and Ctrl+T work immediately after install
- Skipped font installation on `--server` mode (servers don't render fonts)

### Fixed

- ASCII banner now displays cleanly without bat decorations
- Kitty properly set as default terminal after installation
- FZF initialization compatibility with older versions

---

## [2.2.0] - 2025-12-22

### Added

- **Uninstall Script**: Safe, complete removal of all MyBash components
- **Install Manifest System**: Tracks all installed files at `~/.mybash-manifest.txt`
- **Download Retry Logic**: 5 automatic retry attempts for network resilience

### Removed

- **Nerdfetch**: Eliminated ~22ms shell startup delay

---

## [2.0.0] - 2024-12-20

### Added

- **Modern CLI Toolset**: Integrated 12+ modern tools while preserving standard commands
  - Core: `zoxide`, `eza`, `bat`, `fzf`, `fd`, `ripgrep`, `delta`, `lazygit`
  - System: `btop`, `dust`, `procs`, `glow`, `gping`
  - Optional: `nvtop` (GPU monitoring)

- **Kitty Terminal**: GPU-accelerated terminal with Tokyo Night theme
  - Replaced Ghostty (Snap-based) for better performance
  - Text-based config for reproducibility

- **Starship Prompt**: Fast, git-aware prompt with custom Tokyo Night theme

- **Git Delta Integration**: Syntax-highlighted diffs with Tokyo Night colors

- **Server Mode**: `--server` flag for headless installations (skips GUI tools)

- **ARM64 Support**: Full architecture detection and compatibility

### Philosophy

- **Learning-First**: Standard commands (`cd`, `ls`, `find`, `ps`) preserved
- Modern tools are separate commands or aliases
- Maintains muscle memory for vanilla Linux systems

### Security

- URL validation (HTTPS from github.com only)
- No pipe-to-shell downloads
- Explicit confirmation before sudo operations
- GPG verification for APT sources

---

[Unreleased]: https://github.com/reisset/mybash/compare/v2.7.1...HEAD
[2.7.1]: https://github.com/reisset/mybash/compare/v2.7.0...v2.7.1
[2.7.0]: https://github.com/reisset/mybash/compare/v2.6.0...v2.7.0
[2.6.0]: https://github.com/reisset/mybash/compare/v2.5.0...v2.6.0
[2.5.0]: https://github.com/reisset/mybash/compare/v2.3.0...v2.5.0
[2.3.0]: https://github.com/reisset/mybash/compare/v2.2.0...v2.3.0
[2.2.0]: https://github.com/reisset/mybash/compare/v2.0.0...v2.2.0
[2.0.0]: https://github.com/reisset/mybash/releases/tag/v2.0.0
