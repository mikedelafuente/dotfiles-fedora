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

print_tool_setup_start "Godot 4 Mono"
# Install Godot 4 Mono if not already installed

# Godot 4 Mono is a standalone application which we will alias to "godot"

# Let's look for the latest version on Github https://github.com/godotengine/godot/releases
if ! command -v godot &> /dev/null; then
  print_info_message "Installing Godot 4 Mono"
  # Download the latest Godot 4 Mono release
  GODOT_URL=$(curl -s https://api.github.com/repos/godotengine/godot/releases/latest | grep "browser_download_url.*stable_mono_linux_x86_64.zip" | cut -d : -f 2,3 | tr -d \")

  if [ -z "$GODOT_URL" ]; then
  print_error_message "Could not find the latest Godot 4 Mono download URL."
  exit 1
  fi

  GODOT_VERSION_NUMBER=$(echo "$GODOT_URL" | grep -oP 'Godot_v\K[0-9]+\.[0-9]+\.[0-9]+')

  # Extract the name of the zip file from the URL
  GODOT_ZIP_NAME=$(basename "$GODOT_URL")

  # The godot folder will be created using the GODOT_ZIP_NAME minus the .zip extension
  GODOT_FOLDER_NAME="${GODOT_ZIP_NAME%.zip}"

  # Trim whitespace
  GODOT_URL="$(echo "$GODOT_URL" | awk '{$1=$1;print}')"
  echo "Latest Godot version detected: $GODOT_VERSION_NUMBER"
  echo "Download URL: $GODOT_URL"
  echo "Godot zip name: $GODOT_ZIP_NAME"
  echo "Godot folder name: $GODOT_FOLDER_NAME"

  VERSIONED_DIR="$USER_HOME_DIR/Godot/$GODOT_FOLDER_NAME"

  # check if the VERSIONED_DIR exists
  if [ -d "$VERSIONED_DIR" ]; then
    print_info_message "Godot versioned directory $VERSIONED_DIR already exists. Skipping download."
  else
    echo "Creating Godot versioned directory at $VERSIONED_DIR"

    TARGET_ZIP="/tmp/godot_${GODOT_VERSION_NUMBER}_mono.zip"

    echo "Downloading Godot 4 Mono from $GODOT_URL ..."
    wget -O "$TARGET_ZIP" "$GODOT_URL"
    # We should unzip into a versioned folder and then alias to /usr/local/bin/godot

    sudo mkdir -p "$VERSIONED_DIR"

    # Unzip the downloaded file
    sudo unzip -o "$TARGET_ZIP" -d "$USER_HOME_DIR/Godot"

    # Clean up
    rm "$TARGET_ZIP"
  fi      


  #List the files in the versioned directory and grab the binary name that ends with .x86_64
  # GODOT_BINARY_NAME=$(ls "$VERSIONED_DIR" | grep -E 'Godot_v.*_mono_linux_x86_64$')

  # Find the Godot binary reliably (match executable files created by the zip)
  GODOT_BINARY_PATH="$(find "$VERSIONED_DIR" -maxdepth 2 -type f -executable -iname 'godot*' -print -quit || true)"

  # fallback: look for any file with "Godot" in name (some builds use different case/sep)
  if [ -z "${GODOT_BINARY_PATH:-}" ]; then
      GODOT_BINARY_PATH="$(find "$VERSIONED_DIR" -maxdepth 2 -type f -print | grep -Ei 'godot|Godot' | head -n1 || true)"
  fi

  if [ -z "${GODOT_BINARY_PATH:-}" ]; then
      print_error_message "Could not locate Godot binary in $VERSIONED_DIR"
      exit 1
  fi


  echo "Godot binary name: $GODOT_BINARY_PATH"

  mkdir -p "${USER_HOME_DIR}/.local/bin"
  ln -sf "$GODOT_BINARY_PATH" "${USER_HOME_DIR}/.local/bin/godot4"
  sudo chmod +x "$GODOT_BINARY_PATH" "${USER_HOME_DIR}/.local/bin/godot4"
  echo "Linked $GODOT_BINARY_PATH -> ${USER_HOME_DIR}/.local/bin/godot4"

else
    print_info_message "Godot 4 Mono is already installed. Skipping installation."
fi



print_tool_setup_complete "Godot 4 Mono"