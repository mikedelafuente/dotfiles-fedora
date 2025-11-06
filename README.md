# Dotfiles for Pop!_OS

This repository contains my personal dotfiles and configuration for Pop!_OS. The goal of this project is to provide a streamlined setup and configuration for my development environment.

## Table of Contents

- [Installation](#installation)
- [Configuration Files](#configuration-files)
- [Scripts](#scripts)
- [License](#license)

## Installation

To set up the environment, run the following command:

```bash
bash scripts/bootstrap.sh
```

This script will install necessary packages and dependencies for your system.

## Configuration Files

The following configuration files are included in this repository:

- **home/.bashrc**: User-specific shell configuration for bash.
- **home/.zshrc**: User-specific shell configuration for zsh.
- **home/.profile**: Executed at login to set up the user environment.
- **home/.gitconfig**: Global Git configuration settings.
- **home/.gitignore_global**: Global Git ignore file.
- **.config/nvim/init.lua**: Main configuration file for Neovim.
- **.config/starship.toml**: Configuration file for Starship prompt.
- **.config/Code/User/settings.json**: User-specific settings for the code editor.
- **.config/lazygit/config.yml**: Configuration for LazyGit.
- **.config/lazydocker/config.yml**: Configuration for LazyDocker.
- **.config/obsidian**: Configuration and vaults for Obsidian.
- **.config/openvpn**: Configuration files for OpenVPN.

## Scripts

The following scripts are included to automate setup and configuration:

- **scripts/bootstrap.sh**: Sets up the environment.
- **scripts/install-pop-os.sh**: Automates the installation of Pop!_OS.
- **scripts/setup-neovim.sh**: Sets up Neovim with desired plugins.
- **scripts/link-dotfiles.sh**: Creates symbolic links for the dotfiles in the home directory.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.