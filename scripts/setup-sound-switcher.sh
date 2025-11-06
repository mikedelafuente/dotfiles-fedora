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

print_tool_setup_start "Indicator Sound Switcher"

# Only install if we are on Ubuntu version 22 or lower because Ubuntu 23.04+ has built-in support
if [ $(lsb_release -rs | cut -d'.' -f1) -gt 22 ]; then
    print_info_message "Ubuntu version is greater than 22. Skipping installation of Indicator Sound Switcher."
    print_tool_setup_complete "Indicator Sound Switcher"
    exit 0
fi

# Install Indicator Sound Switcher via snap if not already installed
if ! command -v indicator-sound-switcher &> /dev/null; then
    print_info_message "Installing Indicator Sound Switcher via snap"
    sudo snap install indicator-sound-switcher
else
    print_info_message "Indicator Sound Switcher is already installed. Skipping installation."
fi

print_tool_setup_complete "Indicator Sound Switcher"