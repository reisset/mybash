# MyBash V2

A high-performance, opinionated Bash environment configuration for Linux (Ubuntu/Debian).

## Features

- **Starship Prompt:** Beautiful, informative, and fast prompt with Git status, language versions, and execution time.
- **Modern Tools:**
  - `eza` (replaces `ls`) - Colorful, icon-rich file listing.
  - `bat` (replaces `cat`) - Syntax highlighting and git integration.
  - `rg` (replaces `grep`) - Blazingly fast search.
  - `fzf` - Fuzzy history search (Ctrl+R).
  - `yazi` - Terminal file manager with directory navigation.
- **Smart Aliases:**
  - Auto-`ls` when changing directories.
  - `y` wrapper for Yazi to change the shell's working directory on exit.
  - Common shortcuts (`..`, `...`, `gs`, `ga`, etc.).
- **Ghostty Terminal (Optional):**
  - Configured for performance and aesthetics.
  - Includes `Adwaita Dark` theme and window controls.
  - Installer allows choosing it as the default terminal.

## Installation

1.  Clone the repository:
    ```bash
    git clone https://github.com/yourusername/mybash.git
    cd mybash
    ```
2.  Run the installer:
    ```bash
    ./install.sh
    ```
3.  **Important:** After installation, open your terminal preferences (whether Ptyxis, GNOME Terminal, or Ghostty) and set the font to **JetBrainsMono Nerd Font** to ensure icons render correctly.

## Customization

- **Aliases:** Edit `scripts/aliases.sh`.
- **Bash Logic:** Edit `scripts/bashrc_custom.sh`.
- **Prompt:** Edit `configs/starship_text.toml`.
- **Ghostty:** Edit `configs/ghostty.config` (symlinked to `~/.config/ghostty/config`).

## Project Structure

- `install.sh`: Main setup script (Architecture detection, Sudo handling, Symlinking).
- `configs/`: Configuration files for Starship and Ghostty.
- `scripts/`: Modular Bash scripts sourced by your `.bashrc`.
