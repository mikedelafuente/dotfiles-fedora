#!/bin/bash

# --------------------------
# Setup Postman for Fedora KDE
# --------------------------
# Postman is installed from a direct download of their official tarball.
# The Flatpak on Flathub is unverified and not officially supported by Postman Inc.
#
# This installation method:
# - Uses the official Postman distribution
# - Installs to /opt/Postman for system-wide access
# - Creates a desktop entry for easy launching
# - Provides the full-featured version without sandboxing limitations
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
# Install Postman via Official Tarball
# --------------------------

# Check if Postman is already installed
if [ -d "/opt/Postman" ] || command -v postman &> /dev/null; then
    print_info_message "Postman is already installed. Skipping installation."
else
    print_info_message "Installing Postman from official tarball"
    
    # Download the latest Postman tarball
    print_info_message "Downloading Postman tarball"
    POSTMAN_URL="https://dl.pstmn.io/download/latest/linux64"
    TEMP_POSTMAN_TAR="/tmp/postman.tar.gz"
    
    if wget -O "$TEMP_POSTMAN_TAR" "$POSTMAN_URL"; then
        print_info_message "Extracting Postman to /opt"
        sudo tar -xzf "$TEMP_POSTMAN_TAR" -C /opt
        
        # Create a symbolic link for easy command-line access
        print_info_message "Creating symbolic link"
        sudo ln -sf /opt/Postman/Postman /usr/local/bin/postman
        
        # Create a desktop entry
        print_info_message "Creating desktop entry"
        sudo tee /usr/share/applications/postman.desktop > /dev/null <<EOF
[Desktop Entry]
Name=Postman
Comment=API Development Environment
Exec=/opt/Postman/Postman
Icon=/opt/Postman/app/resources/app/assets/icon.png
Terminal=false
Type=Application
Categories=Development;
EOF
        
        # Clean up the downloaded file
        rm -f "$TEMP_POSTMAN_TAR"
        
        print_info_message "Postman installed successfully"
        print_info_message "You can launch Postman from your application menu or run: postman"
    else
        print_error_message "Failed to download Postman tarball"
        print_info_message "You can manually download and install from: https://www.postman.com/downloads/"
    fi
fi

print_tool_setup_complete "Postman"