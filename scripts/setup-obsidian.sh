#!/bin/bash

# --------------------------
# Setup Obsidian for Fedora KDE
# --------------------------
# Obsidian is installed via Flatpak, which is the recommended method on Fedora.
# Flatpak provides:
# - Automatic updates through KDE Discover or 'flatpak update'
# - Sandboxed security
# - Consistent versions across distributions
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

print_tool_setup_start "Obsidian"

# --------------------------
# Install Obsidian via Flatpak
# --------------------------

# Check if Obsidian is already installed
if ! flatpak list 2>/dev/null | grep -q "md.obsidian.Obsidian"; then
    print_info_message "Installing Obsidian via Flatpak"
    
    # Install Obsidian from Flathub
    print_info_message "Installing Obsidian from Flathub"
    flatpak install -y flathub md.obsidian.Obsidian
    
    print_info_message "Obsidian installed successfully"
    print_info_message "You can launch Obsidian from your application menu or run:"
    print_info_message "  flatpak run md.obsidian.Obsidian"
    echo ""
    print_info_message "To update Obsidian in the future, run:"
    print_info_message "  flatpak update md.obsidian.Obsidian"
    print_info_message "Or update all Flatpak apps with:"
    print_info_message "  flatpak update"
else
    print_info_message "Obsidian is already installed. Skipping installation."
    print_info_message "Installed version: $(flatpak info md.obsidian.Obsidian 2>/dev/null | grep Version | awk '{print $2}')"
fi

print_tool_setup_complete "Obsidian"