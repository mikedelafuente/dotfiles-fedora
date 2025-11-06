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

print_tool_setup_start "Alacritty"

# Leverage snapd to install Alacritty
if ! command -v alacritty &> /dev/null; then
    print_info_message "Installing Alacritty via snap"
    sudo snap install alacritty --classic
else
    print_info_message "Alacritty is already installed. Skipping installation."
fi

# Set the default terminal emulator to Alacritty

# Read the current default terminal emulator
current_terminal=$(readlink /etc/alternatives/x-terminal-emulator)
alacritty_path=$(which alacritty)

print_info_message "Current default terminal emulator: $current_terminal"

if [ "$current_terminal" != "$alacritty_path" ]; then
    print_info_message "Setting Alacritty as the default terminal emulator"
    
    # Update alternatives to set Alacritty as the default terminal
    sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$alacritty_path" 50
    sudo update-alternatives --set x-terminal-emulator "$alacritty_path"

    print_info_message "New default terminal emulator: $(readlink /etc/alternatives/x-terminal-emulator)"
else
    print_info_message "Alacritty is already the default terminal emulator. Skipping change."
fi  

print_tool_setup_complete "Alacritty"
