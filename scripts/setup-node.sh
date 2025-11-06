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

print_tool_setup_start "NVM and Node.js"

# Install Nnvm (Node Version Manager) and the latest LTS version of Node.js 

# only if NVM is not already installed or there is no
if command -v nvm &> /dev/null; then
print_info_message "NVM is not installed. Proceeding with installation."
  
    # Unset any existing NVM_DIR to avoid conflicts
    unset NVM_DIR
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
   
else
    print_info_message "NVM is already installed. Skipping installation."
    # Load NVM
    export NVM_DIR="$USER_HOME_DIR/.config/nvm"
    # shellcheck source=/dev/null
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

print_tool_setup_complete "NVM and Node.js"