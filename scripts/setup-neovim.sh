#!/bin/bash

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

# This script sets up Neovim with the desired plugins and configurations.

# Check if Neovim is installed
if ! command -v nvim &> /dev/null; then
  print_info_message "Neovim is not installed. Installing Neovim."
  # Neovim has been added to a "Personal Package Archive" (PPA). This allows you to install it with apt-get. Follow the links to the PPAs to see which versions of Ubuntu are currently available via the PPA.
  # sudo apt-get install software-properties-common
  sudo add-apt-repository ppa:neovim-ppa/stable
  sudo apt-get update
  sudo apt-get install -y neovim
else
  print_info_message "Neovim is already installed. Skipping installation."
fi

# Print Neovim version
print_info_message "Neovim version: $(nvim --version | head -n 1)"

# install lazy neovim setup if neovim is version 0.8 or higher - parse the first two digits of the version number and determine if it is 0.8 or higher (--version returns:
# NVIM v0.7.2
# Build type: Release
# LuaJIT 2.1.0-beta3
# Compiled by team+vim@tracker.debian.org

NVIM_VERSION=$(nvim --version | head -n 1 | awk '{print $2}')
NVIM_MAJOR_VERSION=$(echo "$NVIM_VERSION" | cut -d'.' -f1)
NVIM_MINOR_VERSION=$(echo "$NVIM_VERSION" | cut -d'.' -f2)  
if [ "$NVIM_MAJOR_VERSION" -lt 0 ] || { [ "$NVIM_MAJOR_VERSION" -eq 0 ] && [ "$NVIM_MINOR_VERSION" -lt 8 ]; }; then
  print_error_message "Neovim version is less than 0.8. Please upgrade Neovim to version 0.8 or higher to use Lazy.nvim."
  exit 0
else
  if [ ! -f "$USER_HOME_DIR/.config/nvim/lua/config/lazy.lua" ]; then
    print_info_message "Installing Lazy.nvim"
    # required
    print_info_message "Backing up existing Neovim configuration if it exists."
    if [ -d "$USER_HOME_DIR/.config/nvim" ] || [ -d "$USER_HOME_DIR/.local/share/nvim" ] || [ -d "$USER_HOME_DIR/.local/state/nvim" ] || [ -d "$USER_HOME_DIR/.cache/nvim" ]; then
      print_action_message "Backing up existing Neovim configuration directories to *.bak"
      mv "$USER_HOME_DIR/.config/nvim"{,.bak}
    fi

    # optional but recommended
    if [ -d "$USER_HOME_DIR/.local/share/nvim" ]; then
      mv "$USER_HOME_DIR/.local/share/nvim"{,.bak}
    fi
    if [ -d "$USER_HOME_DIR/.local/state/nvim" ]; then
      mv "$USER_HOME_DIR/.local/state/nvim"{,.bak}
    fi
    if [ -d "$USER_HOME_DIR/.cache/nvim" ]; then
      mv "$USER_HOME_DIR/.cache/nvim"{,.bak}
    fi  

    git clone https://github.com/LazyVim/starter "$USER_HOME_DIR/.config/nvim"
    rm -rf "$USER_HOME_DIR/.config/nvim/.git"

    print_action_message "Start nvim and then run ':LazyHealth' to check if everything is set up correctly."

  else
    print_info_message "Lazy.nvim is already installed. Skipping installation."
  fi
fi

# Create the necessary directories for Neovim configuration
mkdir -p "$USER_HOME_DIR/.config/nvim/lua/plugins"

print_tool_setup_complete "Neovim"
