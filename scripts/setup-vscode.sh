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

print_tool_setup_start "VS Code"

# --------------------------
# Install Visual Studio Code
# --------------------------

# Check if VS Code is already installed
if command -v code &> /dev/null; then
    print_info_message "VS Code is already installed. Skipping installation."
else
    print_info_message "Installing VS Code from official Microsoft repository"
    
    # Import the Microsoft GPG key
    print_info_message "Importing Microsoft GPG key"
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc 
   
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null

    dnf check-update
    sudo dnf install code # or code-insiders
    
    print_info_message "VS Code installed successfully"
fi  


print_tool_setup_complete "VS Code"