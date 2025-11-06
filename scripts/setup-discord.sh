#!/bin/bash

# --------------------------
# Setup Discord for Fedora KDE
# --------------------------
# Discord is installed via Flatpak from Flathub.
# The Discord Flatpak is published by Discord Inc. and is the recommended
# installation method for Linux distributions.
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

print_tool_setup_start "Discord"

# --------------------------
# Install Discord via Flatpak
# --------------------------

# Check if Discord is already installed
if flatpak list 2>/dev/null | grep -q "com.discordapp.Discord"; then
    print_info_message "Discord is already installed. Skipping installation."
else
    print_info_message "Installing Discord via Flatpak"
    
    # Install Discord from Flathub
    print_info_message "Installing Discord from Flathub"
    flatpak install -y flathub com.discordapp.Discord
    
    print_info_message "Discord installed successfully"
    print_info_message "You can launch Discord from your application menu or run:"
    print_info_message "  flatpak run com.discordapp.Discord"
    echo ""
    print_info_message "Note: Some features (Game Activity, Rich Presence) may be limited"
    print_info_message "due to sandboxing. Check the Flatpak README for workarounds if needed."
fi

print_tool_setup_complete "Discord"