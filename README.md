# Dotfiles for Fedora KDE

This repository contains my personal dotfiles and configuration for Fedora KDE Plasma. The goal of this project is to provide a streamlined setup and configuration for my development environment on Fedora.

## Table of Contents

- [Installation](#installation)
- [Configuration Files](#configuration-files)
- [Scripts](#scripts)
- [Installation Methods](#installation-methods)
- [License](#license)

## Installation

To set up the environment, run the following command:

```bash
bash scripts/bootstrap.sh
```

This script will:
- Install essential packages and dependencies
- Configure Flatpak with Flathub repository
- Install development tools and applications
- Set up KDE Plasma customizations
- Link dotfiles to your home directory

**Note:** The bootstrap script will prompt for some configuration values (name, email, .NET SDK version) on first run.

## What Gets Installed

The bootstrap script installs a comprehensive development environment with the following tools:

### Essential CLI Tools
- **git** - Version control system
- **curl** - Command line tool for transferring data
- **wget** - Network downloader
- **xsel** - Command-line clipboard manipulation
- **fzf** - Fuzzy finder for files and commands
- **zoxide** - Smart directory navigation (`z` command)
- **ripgrep** (`rg`) - Fast text search tool
- **fd** - Fast alternative to `find`

### Development Tools & Languages

#### Rust Ecosystem
- **rustup** - Rust toolchain installer and version manager
- **cargo** - Rust package manager and build tool
- **rustc** - Rust compiler

#### Node.js Ecosystem
- **nvm** - Node Version Manager
- **node** - JavaScript runtime
- **npm** - Node package manager

#### .NET Ecosystem
- **.NET SDK** - Microsoft's development framework
- **JetBrains Rider** - .NET IDE

#### Text Editors & IDEs
- **Neovim** with **LazyVim** - Modern Vim-based editor
- **VS Code** - Microsoft's code editor

#### Containerization
- **Docker** - Container platform
- **lazydocker** - Terminal UI for Docker management

#### Version Control UI
- **lazygit** - Terminal UI for Git - Make sure to watch [LazyGit](https://www.youtube.com/watch?v=CPLdltN7wgE)

### Shell & Terminal
- **Bash** - Default shell
- **Starship** - Cross-shell prompt
- **Alacritty** - GPU-accelerated terminal emulator

### Applications (Flatpak/System)
- **Discord** - Communication platform
- **Spotify** - Music streaming
- **Obsidian** - Note-taking and knowledge management
- **Steam** - Gaming platform
- **Postman** - API development tool
- **Godot 4 Mono** - Game engine
- **Zoom** - Video conferencing
- **Mullvad VPN** - Privacy-focused VPN client

### System & Utilities
- **NVIDIA drivers** - Graphics drivers (if NVIDIA GPU detected)
- **Nerd Fonts** - Programming fonts with icons
- **Flatpak** - Universal package system

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

The following configuration files are included in this repository:

- **home/.bashrc**: User-specific shell configuration for bash.
- **home/.profile**: Executed at login to set up the user environment.
- **home/.gitconfig**: Global Git configuration settings.
- **home/.gitignore_global**: Global Git ignore file.
- **.config/nvim/init.lua**: Main configuration file for Neovim with LazyVim.
- **.config/starship.toml**: Configuration file for Starship prompt.
- **.config/Code/User/settings.json**: User-specific settings for VS Code.
- **.config/alacritty/alacritty.toml**: Configuration for Alacritty terminal.
- **.config/lazygit/config.yml**: Configuration for LazyGit.
- **.config/lazydocker/config.yml**: Configuration for LazyDocker.
- **.config/obsidian**: Configuration and vaults for Obsidian.
- **.config/openvpn**: Configuration files for OpenVPN.

## Scripts

The following scripts are included to automate setup and configuration:

### Core Scripts
- **scripts/bootstrap.sh**: Main setup script that orchestrates the entire installation
- **scripts/dotheader.sh**: Common header imported by all setup scripts
- **scripts/fn-lib.sh**: Library of reusable bash functions
- **scripts/link-dotfiles.sh**: Symlinks configuration files to home directory

### Development Tools
- **scripts/setup-git.sh**: Configures Git with user information
- **scripts/setup-neovim.sh**: Installs Neovim and LazyVim configuration
- **scripts/setup-vscode.sh**: Installs VS Code from official Microsoft repository
- **scripts/setup-docker.sh**: Installs Docker from official Docker repository
- **scripts/setup-node.sh**: Installs NVM (Node Version Manager) and Node.js
- **scripts/setup-rust.sh**: Installs Rust toolchain via rustup
- **scripts/setup-dotnet-rider.sh**: Installs .NET SDK and JetBrains Rider

### Applications
- **scripts/setup-alacritty.sh**: Installs Alacritty terminal emulator
- **scripts/setup-discord.sh**: Installs Discord (Flatpak - official)
- **scripts/setup-spotify.sh**: Installs Spotify from official repository
- **scripts/setup-obsidian.sh**: Installs Obsidian (Flatpak - verified)
- **scripts/setup-postman.sh**: Installs Postman from official tarball
- **scripts/setup-steam.sh**: Installs Steam from RPM Fusion
- **scripts/setup-zoom.sh**: Installs Zoom from official RPM
- **scripts/setup-godot.sh**: Installs Godot 4 Mono from GitHub releases
- **scripts/setup-mullvad.sh**: Installs Mullvad VPN from official repository

### System Configuration
- **scripts/setup-bash.sh**: Configures Bash shell and Starship prompt
- **scripts/setup-fonts.sh**: Installs Nerd Fonts
- **scripts/setup-kde.sh**: Applies KDE Plasma customizations

## Installation Methods

This dotfiles repository follows Fedora best practices for package installation:

### Flatpak (for applications)
Used when an **official verified** Flatpak exists on Flathub:
- Discord (official from Discord Inc.)
- Obsidian (verified by Obsidian team)
- JetBrains Rider (official from JetBrains)
- KDE Connect

### DNF (for system packages & frameworks)
Used for:
- Languages and frameworks (Rust, .NET, etc.)
- System utilities and libraries
- Official vendor repositories (Docker, VS Code, Spotify, Mullvad)
- RPM Fusion packages (Steam)

### Other Methods
- **NVM**: For Node.js version management
- **Rustup**: For Rust toolchain (Fedora's recommended approach)
- **Official Downloads**: For tools without verified Flatpaks or repositories (Postman, Godot, Zoom)

## License

This project is licensed under the MIT License. See the LICENSE file for more details.
