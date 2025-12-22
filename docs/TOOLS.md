# 📚 MyBash V2.2 - Modern CLI Tools Guide

Welcome to the **Learning-First** toolset. This guide helps you navigate the modern CLI landscape while keeping your traditional Linux skills sharp.

## 💡 Quick Access

- **mybash-tools** - View this guide with pretty formatting (uses glow for beautiful rendering)
- **mybash-doctor** - Check if your MyBash setup is healthy and troubleshoot issues

## 🧠 Philosophy: Learning-First
MyBash V2.2 adds powerful modern tools but **does not replace** the originals.
- `cd`, `du`, `find`, and `ps` work exactly as they do on any standard Linux system.
- Modern tools are provided as **separate commands** (e.g., `z`, `dust`, `fd`).
- This ensures your muscle memory remains compatible with "vanilla" systems like a Raspberry Pi or a fresh server.

---

## 🛠️ Tool Reference

### 1. Navigation & Search
| Modern Tool | Command | Standard Equivalent | Why use it? |
| :--- | :--- | :--- | :--- |
| **zoxide** | `z`, `zi` | `cd` | Jumps to frequent directories by name. |
| **fd** | `fd` | `find` | Much faster, simpler syntax, ignores `.git`. |
| **fzf** | `Ctrl+t`, `Ctrl+r` | `grep`, `history` | Fuzzy finder with live previews. |

### 2. System Monitoring
| Modern Tool | Command | Standard Equivalent | Why use it? |
| :--- | :--- | :--- | :--- |
| **btop** | `btop` | `top`, `htop` | Beautiful UI, mouse support, network/disk monitoring. |
| **procs** | `px` | `ps` | Colored output, human-readable columns, search. |
| **dust** | `dust` | `du -sh` | Visual tree of disk usage. |
| **nvtop** | `nvtop` | N/A | Monitor GPU usage (NVIDIA/AMD/Intel). |

### 3. Development & Utilities
| Modern Tool | Command | Description |
| :--- | :--- | :--- |
| **tealdeer** | `tldr` | Practical examples for any command (instead of long man pages). |
| **lazygit** | `lg` | Incredible TUI for managing git repos, commits, and branches. |
| **delta** | `git diff` | Syntax highlighting and side-by-side diffs for Git. |
| **bandwhich** | `bandwhich` | See which process is using your bandwidth in real-time. |
| **hyperfine** | `benchmark` | Benchmark command execution speed. |
| **tokei** | `cloc` | Statistics about your code lines, comments, and languages. |
| **glow** | `glow` | Render markdown in the terminal. |
| **gping** | `gping` | Ping with a live graph. |

---

## ⌨️ Quick Shortcuts
- `tools`: Show this guide.
- `lg`: Open LazyGit.
- `zi`: Interactive directory jumper (zoxide).
- `px`: List processes (procs).
- `tldr <cmd>`: Get quick help for a command.

---

## 🚀 Power Mode (Optional)
If you decide you want to fully commit to the modern tools and replace standard commands, see `scripts/aliases.sh`. There is a commented-out section for "Power Mode". 

**Warning:** This will break muscle memory for vanilla systems. Use with caution!
