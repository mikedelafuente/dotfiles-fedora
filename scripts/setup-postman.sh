#!/bin/bash

# --------------------------
# Setup Postman for Fedora KDE
# --------------------------
# Postman is installed via Flatpak, which is the recommended method on Fedora.
# Flatpak provides:
# - Automatic updates through KDE Discover or 'flatpak update'
# - Sandboxed security
# - Consistent versions across distributions
# - Easy maintenance through standard Flatpak tooling
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

print_tool_setup_start "Postman"

# --------------------------
# Install Postman via Flatpak
# --------------------------

# Check if Postman is already installed
if ! flatpak list 2>/dev/null | grep -q "com.getpostman.Postman"; then
    print_info_message "Installing Postman via Flatpak"
    
    # Install Postman from Flathub
    print_info_message "Installing Postman from Flathub"
    flatpak install -y flathub com.getpostman.Postman
    
    print_info_message "Postman installed successfully"
    print_info_message "You can launch Postman from your application menu or run:"
    print_info_message "  flatpak run com.getpostman.Postman"
    echo ""
    print_info_message "To update Postman in the future, run:"
    print_info_message "  flatpak update com.getpostman.Postman"
    print_info_message "Or update all Flatpak apps with:"
    print_info_message "  flatpak update"
else
    print_info_message "Postman is already installed. Skipping installation."
    print_info_message "Installed version: $(flatpak info com.getpostman.Postman 2>/dev/null | grep Version | awk '{print $2}')"
fi

print_tool_setup_complete "Postman"