# Dotfiles for Fedora KDE

A complete, automated development environment setup for Fedora KDE Plasma. From zero to a fully configured machine with development tools, terminals, editors, and applications in one command.

## What You Get

Run the bootstrap script once and get:

- **Modern Shell Setup**: Bash with Starship prompt + aliases/functions
- **Terminal Emulator**: Alacritty (GPU-accelerated) with custom theming
- **Editors & IDEs**: Neovim with LazyVim, VS Code, JetBrains Rider
- **Development Tools**: Git with GitHub CLI, Docker, lazygit, lazydocker
- **Language Ecosystems**: Rust (rustup), Node.js (nvm), .NET SDK, Python, Go, PHP
- **CLI Productivity**: fzf (fuzzy finder), ripgrep, fd, zoxide smart navigation
- **Applications**: Discord, Spotify, Obsidian, Steam, Postman, Godot 4, Zoom
- **System Extras**: Fonts (Nerd Fonts), Mullvad VPN, NVIDIA drivers, KDE customizations

Everything is linked to your home directory with sensible defaults and carefully curated configurations.

## Quick Start

```bash
git clone <your-github-url> dotfiles-fedora
cd dotfiles-fedora
bash scripts/bootstrap.sh
```

The bootstrap script will prompt you for:
- Full name (for Git configuration)
- Email address (for Git configuration)
- .NET SDK version (default: 9.0)

Everything else is automated—the script installs all tools, configures your shell, links dotfiles, and sets up your development environment. Just answer the prompts and grab coffee!

## Table of Contents

- [Quick Start](#quick-start)
- [What Gets Installed](#what-gets-installed)
- [Configuration Files](#configuration-files)
- [Installation Methods](#installation-methods)
- [CLI Quick Reference](#cli-quick-reference)
- [License](#license)

## What Gets Installed

The bootstrap script installs a comprehensive development environment organized by category:

### Shell & Terminal
- **Bash** - Default shell with custom configurations
- **Starship** - Fast, customizable shell prompt
- **Alacritty** - GPU-accelerated terminal emulator with theming

### Editors & IDEs
- **Neovim** with **LazyVim** - Modern Vim setup with lazy plugin loading
- **VS Code** - Visual Studio Code with custom settings
- **JetBrains Rider** - Full-featured .NET IDE

### Development Tools
- **Git** + **GitHub CLI** - Version control with command-line interface
- **lazygit** - Terminal UI for Git operations
- **Docker** + **lazydocker** - Containerization with terminal UI

### Language Ecosystems
- **Rust** (via rustup) - Systems programming language
- **Node.js** (via nvm) - JavaScript runtime with version management
- **.NET SDK** (configurable version) - Microsoft's development framework
- **Python** - Dynamic programming language
- **Go** (golang) - Systems programming language
- **PHP** - Server-side scripting language

### CLI Productivity Tools
- **fzf** - Fuzzy finder for files and commands
- **ripgrep** (`rg`) - Fast text search across files
- **fd** - Fast alternative to `find` command
- **zoxide** - Smart directory navigation with `z` command
- **curl** & **wget** - Command-line download tools
- **xsel** - Clipboard manipulation from terminal

### Applications
- **Discord** - Communication and community (Flatpak)
- **Spotify** - Music streaming
- **Obsidian** - Knowledge base and note-taking app
- **Steam** - Gaming platform
- **Postman** - API development and testing
- **Godot 4 Mono** - Game engine with C# support
- **Zoom** - Video conferencing
- **TablePlus** - Database management GUI
- **Mullvad VPN** - Privacy-focused VPN client

### System Utilities
- **Nerd Fonts** - Programming fonts with icons
- **NVIDIA drivers** - GPU drivers (auto-detected if needed)
- **Flatpak** - Universal package manager for Linux
- **KDE Plasma customizations** - Optimized desktop environment settings

## CLI Quick Reference

Here are some essential commands for the tools installed:

### Navigation & Search
```bash
# Smart directory jumping
z <partial-directory-name>    # Jump to frequently used directory
zi                           # Interactive directory selection

# Fast file search
fd <filename>                # Find files by name
fd -t f "\.js$"             # Find all .js files
rg "search term"            # Search text in files
rg -i "case insensitive"    # Case-insensitive search

# Fuzzy finding
fzf                         # Interactive file finder
history | fzf               # Search command history
```

### Development Tools
```bash
# Git with LazyGit
lazygit                     # Terminal UI for Git operations
git status                  # Check repository status
git add .                   # Stage all changes
git commit -m "message"     # Commit changes

# Docker with LazyDocker
lazydocker                  # Terminal UI for Docker
docker ps                   # List running containers
docker images               # List Docker images
docker compose up -d        # Start services in background

# Rust development
cargo new myproject         # Create new Rust project
cargo build                 # Build project
cargo run                   # Run project
cargo test                  # Run tests
rustup update               # Update Rust toolchain

# Node.js development
nvm list                    # List installed Node versions
nvm use --lts              # Use latest LTS version
nvm install node           # Install latest Node.js
npm init                   # Initialize new project
npm install <package>      # Install package
```

### Text Editing
```bash
# Neovim with LazyVim
nvim <file>                # Edit file with Neovim
nvim .                     # Open current directory
# Inside Neovim:
# <leader>ff - Find files
# <leader>fg - Live grep
# <leader>e  - File explorer

# VS Code
code <file>                # Edit file with VS Code
code .                     # Open current directory
```

### System Management
```bash
# Package management
sudo dnf update            # Update system packages
sudo dnf install <pkg>     # Install system package
flatpak update            # Update Flatpak apps
flatpak install <app>     # Install Flatpak app

# Process monitoring (if installed)
htop                      # Interactive process viewer
```

### Clipboard & Utilities  
```bash
# Clipboard operations
echo "text" | xsel -b     # Copy to clipboard
xsel -b                   # Paste from clipboard
```

## Configuration Files

The following dotfiles are symlinked to your home directory during installation:

### Shell Configuration
- **home/.bashrc**: Bash shell configuration with aliases and functions
- **home/.profile**: Login environment setup

### Git Configuration
- **home/.gitconfig**: Global Git settings (user info, core settings)
- **home/.gitignore_global**: Global gitignore patterns

### Editor & IDE Configuration
- **.config/nvim/init.lua**: Neovim configuration with LazyVim
- **.config/Code/User/settings.json**: VS Code user settings
- **.config/starship.toml**: Starship prompt configuration

### Terminal & Application Configuration
- **.config/alacritty/alacritty.toml**: Alacritty terminal emulator configuration
- **.config/lazygit/config.yml**: LazyGit configuration
- **.config/lazydocker/config.yml**: LazyDocker configuration

### Application Data
- **.config/obsidian/**: Obsidian vaults and settings
- **.config/openvpn/**: VPN configuration files

## Installation Scripts

The bootstrap process runs 27 automated setup scripts:

### Core Infrastructure
- **bootstrap.sh** - Main orchestrator; prompts for config and runs all setup scripts
- **setup-essentials.sh** - Core CLI tools, build dependencies, and system libraries
- **setup-fonts.sh** - Installs Nerd Fonts for terminal and editor icons

### Shell & Terminal
- **setup-bash.sh** - Configures Bash and Starship prompt
- **setup-alacritty.sh** - Installs and configures Alacritty terminal emulator

### Development Tools & IDEs
- **setup-git.sh** - Configures Git with your user information
- **setup-github-cli.sh** - Installs GitHub CLI and Copilot CLI
- **setup-neovim.sh** - Installs Neovim with LazyVim configuration
- **setup-vscode.sh** - Installs VS Code from Microsoft repository
- **setup-dotnet-rider.sh** - Installs .NET SDK and JetBrains Rider IDE

### Language Ecosystems
- **setup-rust.sh** - Installs Rust via rustup
- **setup-node.sh** - Installs Node.js via NVM (Node Version Manager)
- **setup-python.sh** - Installs Python and development tools
- **setup-golang.sh** - Installs Go programming language
- **setup-php.sh** - Installs PHP and development tools

### Containerization & DevOps
- **setup-docker.sh** - Installs Docker from official Docker repository
- **setup-tableplus.sh** - Installs TablePlus database management tool

### Applications (Flatpak & System)
- **setup-discord.sh** - Discord via Flatpak (official)
- **setup-spotify.sh** - Spotify from official repository
- **setup-obsidian.sh** - Obsidian via Flatpak (verified)
- **setup-postman.sh** - Postman API tool from official tarball
- **setup-steam.sh** - Steam gaming platform via RPM Fusion
- **setup-zoom.sh** - Zoom video conferencing from official RPM
- **setup-godot.sh** - Godot 4 Mono game engine from GitHub releases
- **setup-mullvad.sh** - Mullvad VPN from official repository
- **setup-claude.sh** - Claude Code CLI for AI-assisted development

### System Configuration
- **setup-nvidia.sh** - NVIDIA drivers (auto-detected if applicable)
- **setup-kde.sh** - KDE Plasma desktop customizations
- **link-dotfiles.sh** - Symlinks all dotfiles to home directory

## Installation Methods

This repository follows Fedora best practices for package management:

### Flatpak (for GUI Applications)
Prefers official or verified Flatpaks from Flathub when available:
- **Discord** (official from Discord Inc.)
- **Obsidian** (verified by Obsidian team)
- **Rider** (official from JetBrains)

### DNF (for System Packages & Development Frameworks)
Used for core development tools and official vendor repositories:
- **Languages**: Rust, Python, Go, PHP (system packages)
- **Tools**: Git, Docker (from official vendor repos), VS Code, Spotify, Mullvad
- **Libraries**: Build tools, development headers, system utilities
- **Gaming**: Steam (via RPM Fusion)

### Version Managers
Provides flexible version switching without system dependency conflicts:
- **NVM** (Node Version Manager) - Switch between Node.js versions easily
- **Rustup** (Rust toolchain manager) - Recommended by Fedora for Rust

### Official Releases
Direct downloads from official sources when no repository/Flatpak exists:
- **Postman** - Downloaded as tarball from official site
- **Godot 4 Mono** - Latest release from GitHub
- **Zoom** - Official RPM from vendor

## Why These Dotfiles?

This repository solves several common problems for Fedora developers:

- **Complete Setup in One Command**: No need to remember which tools to install or how to configure them
- **Sensible Defaults**: Carefully configured editors, shell, and tools that work well together
- **Version Management**: Node.js and Rust use version managers, not system packages (easier to update)
- **Consistent Environment**: Same configurations across multiple machines by cloning this repo
- **Well-Documented**: Each script is clear about what it's doing and why
- **Modular Design**: Run individual scripts or the full bootstrap—your choice

## For Existing Fedora Users

If you already have Fedora installed, you can:
1. Clone this repository
2. Run `bash scripts/bootstrap.sh` to install and configure everything
3. Your existing home directory data is preserved (dotfiles are symlinked, not copied)

Or selectively install by running individual setup scripts in `scripts/`.

## Customization

The configuration files are designed to be starting points. Feel free to:
- Edit `.bashrc` to add your own aliases
- Modify `.config/nvim/init.lua` for Neovim plugins
- Adjust `.config/starship.toml` for your preferred prompt style
- Customize `.config/alacritty/alacritty.toml` for terminal appearance

## License

This project is licensed under the MIT License. See the LICENSE file for more details.
