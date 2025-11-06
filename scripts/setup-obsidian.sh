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

print_tool_setup_start "Obsidian"

# Install Obsidian via snap if not already installed
if ! command -v obsidian &> /dev/null; then
    print_info_message "Installing Obsidian via snap"
    sudo snap install obsidian --classic
else
    print_info_message "Obsidian is already installed. Skipping installation."
fi

print_tool_setup_complete "Obsidian"