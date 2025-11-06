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

print_tool_setup_start "Fonts"

# Update this array to install different fonts if desired
NERD_FONTS=("Meslo" "Ubuntu" "FiraCode" "JetBrainsMono" "Hack")
# iterate through the array and install each font

FONTS_UPDATED=false

for FONT in "${NERD_FONTS[@]}"; do
    if [ ! -d "$USER_HOME_DIR/.local/share/fonts/NerdFonts/$FONT" ]; then
        print_info_message "Installing $FONT Nerd Font"
        mkdir -p "$USER_HOME_DIR/.local/share/fonts/NerdFonts/$FONT"
        FONTS_UPDATED=true
        cd "$USER_HOME_DIR/.local/share/fonts/NerdFonts/$FONT" || exit 1
        wget "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$FONT.zip"
        unzip "$FONT.zip"
        rm "$FONT.zip"
    fi
done

# Refresh font cache
if [ "$FONTS_UPDATED" = true ]; then
    print_info_message "Fonts were installed. Refreshing font cache."
    fc-cache -f # add -v for verbose output
else
    print_info_message "No new fonts were installed. Skipping font cache refresh."
fi

print_tool_setup_complete "Fonts"