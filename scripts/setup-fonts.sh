#!/bin/bash

# --------------------------
# Setup Nerd Fonts for Fedora KDE
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

print_tool_setup_start "Fonts"

# --------------------------
# Install Nerd Fonts
# --------------------------

# Update this array to install different fonts if desired
NERD_FONTS=("Meslo" "Ubuntu" "FiraCode" "JetBrainsMono" "Hack")

FONTS_UPDATED=false

print_info_message "Installing Nerd Fonts to $USER_HOME_DIR/.local/share/fonts/NerdFonts/"

# Iterate through the array and install each font
for FONT in "${NERD_FONTS[@]}"; do
    FONT_DIR="$USER_HOME_DIR/.local/share/fonts/NerdFonts/$FONT"
    
    if [ ! -d "$FONT_DIR" ]; then
        print_info_message "Installing $FONT Nerd Font"
        mkdir -p "$FONT_DIR"
        FONTS_UPDATED=true
        
        cd "$FONT_DIR" || {
            print_error_message "Failed to change directory to $FONT_DIR"
            continue
        }
        
        # Download font from GitHub releases
        DOWNLOAD_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$FONT.zip"
        if wget -q "$DOWNLOAD_URL"; then
            unzip -q "$FONT.zip"
            rm "$FONT.zip"
            print_info_message "$FONT Nerd Font installed successfully"
        else
            print_error_message "Failed to download $FONT Nerd Font from $DOWNLOAD_URL"
            FONTS_UPDATED=false
        fi
    else
        print_info_message "$FONT Nerd Font already installed. Skipping."
    fi
done

# --------------------------
# Refresh Font Cache
# --------------------------

# Refresh font cache if new fonts were installed
if [ "$FONTS_UPDATED" = true ]; then
    print_info_message "Fonts were installed. Refreshing font cache."
    fc-cache -f # add -v for verbose output
    print_info_message "Font cache refreshed successfully"
else
    print_info_message "No new fonts were installed. Skipping font cache refresh."
fi

print_tool_setup_complete "Fonts"
