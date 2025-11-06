#!/bin/bash

# --------------------------
# Setup .NET SDK and JetBrains Rider for Fedora KDE
# --------------------------

# --------------------------
# Allow passing in argument for the minimum .NET SDK version, default to 9.0
MINIMUM_DOTNET_CORE_SDK_VERSION="${1:-9.0}"


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
# Install .NET SDK
# --------------------------

print_tool_setup_start "Dotnet"

# Install .NET SDK if not already installed
if ! command -v dotnet &> /dev/null; then
    print_info_message "Installing .NET SDK $MINIMUM_DOTNET_CORE_SDK_VERSION"
    
    # Add Microsoft package repository for Fedora
    print_info_message "Adding Microsoft package repository"
    sudo dnf install -y dotnet-sdk-"$MINIMUM_DOTNET_CORE_SDK_VERSION"
else
    print_info_message ".NET SDK is already installed. Skipping installation."
    dotnet --version
fi

print_tool_setup_complete "Dotnet"

# --------------------------
# Install JetBrains Rider
# --------------------------

print_tool_setup_start "Rider"

if ! command -v rider &> /dev/null && ! flatpak list | grep -q "com.jetbrains.Rider"; then
    print_info_message "Installing JetBrains Rider via Flatpak"
    
    # Ensure Flatpak is installed
    if ! command -v flatpak &> /dev/null; then
        print_info_message "Installing Flatpak first"
        sudo dnf install -y flatpak
    fi
    
    # Add Flathub repository if not already added
    if ! flatpak remotes | grep -q flathub; then
        print_info_message "Adding Flathub repository"
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    fi
    
    # Install Rider from Flathub
    print_info_message "Installing Rider from Flathub"
    flatpak install -y flathub com.jetbrains.Rider
    
    print_info_message "Rider installed successfully"
    print_info_message "You can launch Rider with: flatpak run com.jetbrains.Rider"
else
    print_info_message "Rider is already installed. Skipping installation."
fi

print_tool_setup_complete "Rider"
