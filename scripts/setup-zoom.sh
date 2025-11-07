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

print_tool_setup_start "Zoom"

# --------------------------
# Install Zoom
# --------------------------

# Check if Zoom is already installed
if command -v zoom &> /dev/null; then
    print_info_message "Zoom is already installed. Skipping installation."
else
    print_info_message "Installing Zoom from official RPM package"
    
    # Download the latest Zoom RPM for Fedora/CentOS
    print_info_message "Downloading Zoom RPM package"
    ZOOM_RPM_URL="https://zoom.us/client/latest/zoom_x86_64.rpm"
    TEMP_ZOOM_RPM="/tmp/zoom_x86_64.rpm"
    
    # Download the package
    if wget -O "$TEMP_ZOOM_RPM" "$ZOOM_RPM_URL"; then
        print_info_message "Installing Zoom package"
        sudo dnf install -y "$TEMP_ZOOM_RPM"
        
        # Clean up the downloaded file
        rm -f "$TEMP_ZOOM_RPM"
        
        print_info_message "Zoom installed successfully"
    else
        print_error_message "Failed to download Zoom RPM package"
        print_info_message "You can manually download and install from: https://zoom.us/download?os=linux"
    fi
fi

print_tool_setup_complete "Zoom"