#!/bin/bash

# --------------------------
# Setup Neovim for Fedora KDE
# --------------------------

# --------------------------
# Import Common Header 
# --------------------------

# add header file
CURRENT_FILE_DIR="$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"

# source header (uses SCRIPT_DIR and loads lib.sh)
if [ -r "$CURRENT_FILE_DIR/dotheader.sh" ]; then
  # shellcheck source=/dev/null
  source "$CURRENT_FILE_DIR/dotheader.sh"
else
  echo "Missing header file: $CURRENT_FILE_DIR/dotheader.sh"
  exit 1
fi

# --------------------------
# End Import Common Header 
# --------------------------

print_tool_setup_start "Neovim"

# --------------------------
# Install Neovim
# --------------------------

# This script sets up Neovim with the desired plugins and configurations.

# Check if Neovim is installed
if ! command -v nvim &> /dev/null; then
  print_info_message "Neovim is not installed. Installing Neovim."
  
  # Install Neovim from Fedora repositories
  # Note: For the latest stable version, you can also use Flatpak or build from source
  sudo dnf install -y neovim
else
  print_info_message "Neovim is already installed. Skipping installation."
fi

# Print Neovim version
print_info_message "Neovim version: $(nvim --version | head -n 1)"

# --------------------------
# Install LazyVim
# --------------------------

# Install Lazy.nvim setup if Neovim is version 0.8 or higher
# Parse the version number to determine if it meets requirements
NVIM_VERSION=$(nvim --version | head -n 1 | awk '{print $2}')
NVIM_MAJOR_VERSION=$(echo "$NVIM_VERSION" | cut -d'.' -f1 | tr -d 'v')
NVIM_MINOR_VERSION=$(echo "$NVIM_VERSION" | cut -d'.' -f2)


if [ ! -f "$USER_HOME_DIR/.config/nvim/lua/config/lazy.lua" ]; then
  print_info_message "Installing Lazy.nvim"
  
  # Backup existing Neovim configuration if it exists
  print_info_message "Backing up existing Neovim configuration if it exists."
  if [ -d "$USER_HOME_DIR/.config/nvim" ]; then
    print_action_message "Backing up existing Neovim configuration to ~/.config/nvim.bak"
    mv "$USER_HOME_DIR/.config/nvim"{,.bak}
  fi

  # Optional but recommended - backup data directories
  if [ -d "$USER_HOME_DIR/.local/share/nvim" ]; then
    print_action_message "Backing up ~/.local/share/nvim to ~/.local/share/nvim.bak"
    mv "$USER_HOME_DIR/.local/share/nvim"{,.bak}
  fi
  if [ -d "$USER_HOME_DIR/.local/state/nvim" ]; then
    print_action_message "Backing up ~/.local/state/nvim to ~/.local/state/nvim.bak"
    mv "$USER_HOME_DIR/.local/state/nvim"{,.bak}
  fi
  if [ -d "$USER_HOME_DIR/.cache/nvim" ]; then
    print_action_message "Backing up ~/.cache/nvim to ~/.cache/nvim.bak"
    mv "$USER_HOME_DIR/.cache/nvim"{,.bak}
  fi

  # Clone LazyVim starter configuration
  print_info_message "Cloning LazyVim starter configuration"
  git clone https://github.com/LazyVim/starter "$USER_HOME_DIR/.config/nvim"
  rm -rf "$USER_HOME_DIR/.config/nvim/.git"

  print_action_message "LazyVim installed successfully!"
  print_action_message "Start nvim and then run ':LazyHealth' to check if everything is set up correctly."
else
  print_info_message "Lazy.nvim is already installed. Skipping installation."
fi

# Install fd and ripgrep if not already installed (required by some Neovim plugins)
if ! command -v fd &> /dev/null; then
  print_info_message "Installing fd (fd-find)"
  sudo dnf install -y fd-find
else
  print_info_message "fd is already installed. Skipping installation."
fi  

if ! command -v rg &> /dev/null; then
  print_info_message "Installing ripgrep"
  sudo dnf install -y ripgrep
else
  print_info_message "ripgrep is already installed. Skipping installation."
fi


# --------------------------
# Create Neovim Configuration Directories
# --------------------------

# Create the necessary directories for Neovim configuration
print_info_message "Ensuring Neovim plugin directory exists"
mkdir -p "$USER_HOME_DIR/.config/nvim/lua/plugins"

print_tool_setup_complete "Neovim"
