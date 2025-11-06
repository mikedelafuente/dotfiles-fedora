#!/bin/bash

# --------------------------
# Setup Spotify for Fedora KDE
# --------------------------
# Spotify is installed via Flatpak, which is the recommended method on Fedora.
# Flatpak provides:
# - Automatic updates through KDE Discover or 'flatpak update'
# - Sandboxed security
# - Consistent versions across distributions
# - Easy maintenance through standard Flatpak tooling
#
# Note: Spotify also offers an official RPM repository, but Flatpak is
# preferred for better integration with Fedora's software management.
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

print_tool_setup_start "Spotify"

# --------------------------
# Install Spotify via Flatpak
# --------------------------

# Check if Spotify is already installed
if ! flatpak list 2>/dev/null | grep -q "com.spotify.Client"; then
    print_info_message "Installing Spotify via Flatpak"
    
    # Install Spotify from Flathub
    print_info_message "Installing Spotify from Flathub"
    flatpak install -y flathub com.spotify.Client
    
    print_info_message "Spotify installed successfully"
    print_info_message "You can launch Spotify from your application menu or run:"
    print_info_message "  flatpak run com.spotify.Client"
    echo ""
    print_info_message "To update Spotify in the future, run:"
    print_info_message "  flatpak update com.spotify.Client"
    print_info_message "Or update all Flatpak apps with:"
    print_info_message "  flatpak update"
else
    print_info_message "Spotify is already installed. Skipping installation."
    print_info_message "Installed version: $(flatpak info com.spotify.Client 2>/dev/null | grep Version | awk '{print $2}')"
fi

print_tool_setup_complete "Spotify"