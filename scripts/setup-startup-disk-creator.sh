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

print_tool_setup_start "Startup Disk Creator"

# Install Startup Disk Creator if not already installed
if ! command -v usb-creator-gtk &> /dev/null; then
    print_info_message "Installing Startup Disk Creator"
    sudo apt install usb-creator-gtk
else
    print_info_message "Startup Disk Creator is already installed. Skipping installation."
fi

print_tool_setup_complete "Startup Disk Creator"