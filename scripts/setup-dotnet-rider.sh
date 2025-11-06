#!/bin/bash

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

print_tool_setup_start "Dotnet"

# Install .NET SDK if not already installed
if ! command -v dotnet &> /dev/null; then
    print_info_message "Installing .NET SDK"
    sudo add-apt-repository ppa:dotnet/backports -y
    sudo apt-get update && \
      sudo apt-get install -y dotnet-sdk-"$MINIMUM_DOTNET_CORE_SDK_VERSION"
fi

print_tool_setup_complete "Dotnet"

print_tool_setup_start "Rider"

if ! command -v rider &> /dev/null; then
    print_info_message "Installing JetBrains Rider via snap"
    sudo snap install rider --classic
else
    print_info_message "Rider is already installed. Skipping installation."
fi

print_tool_setup_complete "Rider"
