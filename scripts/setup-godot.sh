#!/bin/bash

# --------------------------
# Setup Godot 4 Mono for Fedora KDE
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

print_tool_setup_start "Godot 4 Mono"

# --------------------------
# Ensure Required Dependencies
# --------------------------

# Ensure wget and unzip are installed (needed for downloading and extracting Godot)
print_info_message "Ensuring required dependencies are installed"
if ! command -v wget &> /dev/null || ! command -v unzip &> /dev/null; then
    print_info_message "Installing wget and unzip via DNF"
    sudo dnf install -y wget unzip
fi

# --------------------------
# Check if Godot is Already Installed
# --------------------------

# Godot 4 Mono is a standalone application which we will alias to "godot4"
# Check if it's already installed in the user's local bin
if command -v godot4 &> /dev/null; then
    print_info_message "Godot 4 Mono is already installed. Skipping installation."
    print_info_message "Location: $(which godot4)"
    print_tool_setup_complete "Godot 4 Mono"
    exit 0
fi

# --------------------------
# Download Latest Godot 4 Mono
# --------------------------

print_info_message "Installing Godot 4 Mono"

# Fetch the latest Godot 4 Mono release from GitHub
GODOT_URL=$(curl -s https://api.github.com/repos/godotengine/godot/releases/latest | grep "browser_download_url.*stable_mono_linux_x86_64.zip" | cut -d : -f 2,3 | tr -d \")

if [ -z "$GODOT_URL" ]; then
    print_error_message "Could not find the latest Godot 4 Mono download URL."
    exit 1
fi

GODOT_VERSION_NUMBER=$(echo "$GODOT_URL" | grep -oP 'Godot_v\K[0-9]+\.[0-9]+\.[0-9]+')

# Extract the name of the zip file from the URL
GODOT_ZIP_NAME=$(basename "$GODOT_URL")

# The Godot folder will be created using the GODOT_ZIP_NAME minus the .zip extension
GODOT_FOLDER_NAME="${GODOT_ZIP_NAME%.zip}"

# Trim whitespace from URL
GODOT_URL="$(echo "$GODOT_URL" | awk '{$1=$1;print}')"

print_info_message "Latest Godot version detected: $GODOT_VERSION_NUMBER"
print_info_message "Download URL: $GODOT_URL"
print_info_message "Godot zip name: $GODOT_ZIP_NAME"
print_info_message "Godot folder name: $GODOT_FOLDER_NAME"

VERSIONED_DIR="$USER_HOME_DIR/Godot/$GODOT_FOLDER_NAME"

# --------------------------
# Install Godot to Versioned Directory
# --------------------------

# Check if the versioned directory already exists
if [ -d "$VERSIONED_DIR" ]; then
    print_info_message "Godot versioned directory $VERSIONED_DIR already exists. Skipping download."
else
    print_info_message "Creating Godot versioned directory at $VERSIONED_DIR"

    TARGET_ZIP="/tmp/godot_${GODOT_VERSION_NUMBER}_mono.zip"

    print_info_message "Downloading Godot 4 Mono from GitHub..."
    wget -q --show-progress -O "$TARGET_ZIP" "$GODOT_URL"

    # Create the versioned directory
    mkdir -p "$VERSIONED_DIR"

    # Unzip the downloaded file
    print_info_message "Extracting Godot 4 Mono to $USER_HOME_DIR/Godot"
    unzip -q -o "$TARGET_ZIP" -d "$USER_HOME_DIR/Godot"

    # Clean up the downloaded zip file
    rm "$TARGET_ZIP"
    print_info_message "Download and extraction complete"
fi

# --------------------------
# Create Symlink to Godot Binary
# --------------------------

# Find the Godot binary reliably (match executable files created by the zip)
GODOT_BINARY_PATH="$(find "$VERSIONED_DIR" -maxdepth 2 -type f -executable -iname 'godot*' -print -quit || true)"

# Fallback: look for any file with "Godot" in name (some builds use different case/separator)
if [ -z "${GODOT_BINARY_PATH:-}" ]; then
    GODOT_BINARY_PATH="$(find "$VERSIONED_DIR" -maxdepth 2 -type f -print | grep -Ei 'godot|Godot' | head -n1 || true)"
fi

if [ -z "${GODOT_BINARY_PATH:-}" ]; then
    print_error_message "Could not locate Godot binary in $VERSIONED_DIR"
    exit 1
fi

print_info_message "Godot binary found: $GODOT_BINARY_PATH"

# Create local bin directory if it doesn't exist
mkdir -p "${USER_HOME_DIR}/.local/bin"

# Create symlink to the Godot binary
ln -sf "$GODOT_BINARY_PATH" "${USER_HOME_DIR}/.local/bin/godot4"
chmod +x "$GODOT_BINARY_PATH" "${USER_HOME_DIR}/.local/bin/godot4"

print_info_message "Created symlink: $GODOT_BINARY_PATH -> ${USER_HOME_DIR}/.local/bin/godot4"
print_info_message "You can launch Godot with: godot4"

print_tool_setup_complete "Godot 4 Mono"