#!/bin/bash

# --------------------------
# Setup Steam for Fedora KDE
# --------------------------
# Steam is installed via DNF from RPM Fusion, which provides the official
# Steam package for Fedora. This is the recommended method because:
# - Official Steam package maintained for Fedora
# - Better integration with system libraries and drivers
# - Optimal gaming performance (no containerization overhead)
# - Standard Fedora package management via DNF
#
# Note: Requires RPM Fusion Free repository to be enabled.
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

print_tool_setup_start "Steam"

# --------------------------
# Enable RPM Fusion Repository
# --------------------------

# Check if RPM Fusion Free repository is enabled
if ! dnf repolist 2>/dev/null | grep -q "rpmfusion-free"; then
    print_info_message "Enabling RPM Fusion Free repository"
    sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
    sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1
else
    print_info_message "RPM Fusion Free repository already enabled"
fi

# --------------------------
# Install Steam via DNF
# --------------------------

# Check if Steam is already installed
if ! command -v steam &> /dev/null; then
    print_info_message "Installing Steam from RPM Fusion"
    
    # Install Steam
    sudo dnf install -y steam
    
    print_info_message "Steam installed successfully"
    print_info_message "You can launch Steam from your application menu or run: steam"
    echo ""
    print_info_message "To update Steam in the future, run:"
    print_info_message "  sudo dnf update steam"
    print_info_message "Or update all packages with:"
    print_info_message "  sudo dnf upgrade"
    echo ""
    print_info_message "Note: Steam may require additional setup for optimal gaming:"
    print_info_message "  - Enable Proton for Windows games in Steam settings"
    print_info_message "  - Install GPU drivers if needed (NVIDIA/AMD)"
    print_info_message "  - Consider enabling Steam Play for all titles"
else
    print_info_message "Steam is already installed. Skipping installation."
    print_info_message "Installed version: $(rpm -q steam 2>/dev/null || echo 'unknown')"
fi

print_tool_setup_complete "Steam"