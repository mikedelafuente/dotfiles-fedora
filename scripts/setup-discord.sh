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

# --------------------------
# Setup Discord
# --------------------------

print_line_break "Installing Discord"

# Determine if Discord is already installed
if command -v discord &> /dev/null; then
    print_info_message "Discord is already installed. Skipping installation."
    print_line_break "Discord installation completed."
    exit 0
fi

# Download the latest Discord .deb package
DISCORD_DEB_URL="https://discord.com/api/download?platform=linux&format=deb"
TEMP_DEB_FILE="/tmp/discord.deb"

wget -O "$TEMP_DEB_FILE" "$DISCORD_DEB_URL"

# Install the downloaded package
sudo apt install -y "$TEMP_DEB_FILE"

# Clean up
rm -f "$TEMP_DEB_FILE"

print_line_break "Discord installation completed."