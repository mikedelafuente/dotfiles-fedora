#!/bin/bash

# --------------------------
# Setup Alacritty Terminal for Fedora KDE
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

print_tool_setup_start "Alacritty"

# --------------------------
# Install Alacritty
# --------------------------

# Install Alacritty using DNF (Fedora's package manager)
if ! command -v alacritty &> /dev/null; then
    print_info_message "Installing Alacritty via DNF"
    sudo dnf install -y alacritty
else
    print_info_message "Alacritty is already installed. Skipping installation."
fi

# --------------------------
# Set Default Terminal for KDE
# --------------------------

# Get the path to Alacritty
alacritty_path=$(which alacritty)

print_info_message "Alacritty path: $alacritty_path"

# For KDE Plasma, set Alacritty as the default terminal emulator
# KDE uses kwriteconfig to modify settings
if command -v kwriteconfig5 &> /dev/null || command -v kwriteconfig6 &> /dev/null; then
    print_info_message "Setting Alacritty as the default terminal emulator for KDE"
    
    # Determine which version of kwriteconfig is available (KDE 5 or KDE 6)
    if command -v kwriteconfig6 &> /dev/null; then
        KWRITECONFIG="kwriteconfig6"
    else
        KWRITECONFIG="kwriteconfig5"
    fi
    
    # Set Alacritty as the default terminal in KDE settings
    $KWRITECONFIG --file kdeglobals --group General --key TerminalApplication alacritty
    $KWRITECONFIG --file kdeglobals --group General --key TerminalService ""
    
    print_info_message "Alacritty has been set as the default terminal emulator for KDE"
else
    print_warning_message "KDE configuration tools not found. Skipping default terminal setup."
    print_info_message "You can manually set Alacritty as default in KDE System Settings:"
    print_info_message "  Settings > Applications > Default Applications > Terminal Emulator"
fi

print_tool_setup_complete "Alacritty"
