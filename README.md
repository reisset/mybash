# MyBash V2

A high-performance, opinionated Bash environment configuration for Linux (Ubuntu/Debian).

## Features

- **Starship Prompt:** Beautiful, informative, and fast prompt with Git status, language versions, and execution time.
- **Learning-First Toolset**:
  - **Standard Commands Preserved**: `cd`, `du`, `find`, and `ps` remain untouched for muscle memory.
  - **Modern Superpowers**: Adds `zoxide` (z), `dust`, `fd`, and `procs` (px) as supplementary tools.
  - **Core Enhancements**: `eza` (ls), `bat` (cat), `rg` (grep), and `fzf` for a modern CLI experience.
  - **Interactive TUI**: `lazygit` (lg) for Git and `btop` for system monitoring.
- **Enhanced FZF**: Rich previews using `bat` and `eza` when searching files.
- **Git Delta**: Beautiful, syntax-highlighted git diffs with Tokyo Night theme.
- **Smart Aliases**:
  - Auto-`ls` when changing directories.
  - `y` wrapper for Yazi to change directory on exit.
  - `tools` command for quick reference to modern tools.

- **Kitty Terminal (Optional):**
  - GPU-accelerated, fast, and highly configurable.
  - Configured with **Tokyo Night** theme.
  - Includes font settings for **JetBrainsMono** (default) and **MesloLGS** Nerd Fonts.
  - Installer allows choosing it as the default terminal.

## Installation

### Before Installing

**IMPORTANT**: This installer downloads and executes third-party software from the internet. Please review the following before proceeding:

- Review `install.sh` and understand what it does
- Run only on systems you trust and control
- Ensure you're on a secure network
- Consider backing up your existing `.bashrc` and config files

### Install Steps

1.  Clone the repository:
    ```bash
    git clone https://github.com/yourusername/mybash.git
    cd mybash
    ```
2.  **Review the installer script**:
    ```bash
    cat install.sh  # Review before running
    ```
3.  Run the installer:
    ```bash
    ./install.sh
    ```
4.  After installation, open your terminal preferences and set the font to **JetBrainsMono Nerd Font** (Or any other Nerd Font) to ensure icons render correctly.

### Security Features

MyBash V2 implements several security measures:
- **URL Validation**: All GitHub downloads are validated for HTTPS and correct domain
- **Checksum Verification**: Optional SHA256 verification for downloaded binaries
- **No Pipe-to-Shell**: External scripts are downloaded and inspected before execution
- **GPG Key Verification**: Package repository keys are handled securely
- **Sudo Confirmation**: Explicit user consent required for privileged operations

For detailed security information, see [SECURITY.md](SECURITY.md).

## Customization

- **Aliases:** Edit `scripts/aliases.sh`.
- **Bash Logic:** Edit `scripts/bashrc_custom.sh`.
- **Prompt:** Edit `configs/starship_text.toml`.
- **Kitty:** Edit `configs/kitty.conf` (symlinked to `~/.config/kitty/kitty.conf`).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
