#!/bin/bash

# --------------------------
# Setup Discord for Fedora KDE
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

# --------------------------
# Install Discord
# --------------------------

print_line_break "Installing Discord"

# Determine if Discord is already installed
if command -v discord &> /dev/null; then
    print_info_message "Discord is already installed. Skipping installation."
    print_line_break "Discord installation completed."
    exit 0
fi

# Install Discord via Flatpak (recommended method for Fedora)
print_info_message "Installing Discord via Flatpak"

# Ensure Flatpak is installed
if ! command -v flatpak &> /dev/null; then
    print_info_message "Installing Flatpak first"
    sudo dnf install -y flatpak
fi

# Add Flathub repository if not already added
if ! flatpak remotes | grep -q flathub; then
    print_info_message "Adding Flathub repository"
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

# Install Discord from Flathub
print_info_message "Installing Discord from Flathub"
flatpak install -y flathub com.discordapp.Discord

# It is possible that this is the wrong flatpak and you may need to try:
# flatpak install -y discord


print_line_break "Discord installation completed."
print_info_message "You can launch Discord with: flatpak run com.discordapp.Discord"