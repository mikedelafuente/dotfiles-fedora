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


print_tool_setup_start "Rust and Cargo"

# Install Rust and Cargo if not already installed
if ! command -v cargo &> /dev/null; then
    print_info_message "Installing Rust and Cargo"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$USER_HOME_DIR/.cargo/env"
else
    print_info_message "Rust and Cargo are already installed. Skipping installation."
fi

print_tool_setup_complete "Rust and Cargo"  