#!/bin/bash

# -------------------------
# Allow for the profile name to be passed as an argument
# -------------------------
PROFILE_NAME="${1:-dela}"

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

print_tool_setup_start "Linking dotfiles"

# Create symbolic links for dotfiles in the home directory
DOTFILES_HOME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/home"
DOTFILES_CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/.config"


for file in .bashrc .profile .gitconfig .gitignore_global; do
  target="$USER_HOME_DIR/$file"
  source_file="$DOTFILES_HOME_DIR/$file"
  
  # Add debug output to your script
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "Warning: $target exists and is not a symlink."
    echo "Backing up existing $target to $target.backup"
    mv "$target" "$target.backup"
  elif [ -L "$target" ]; then
    echo "Overwriting existing symlink $target"
  fi
  ln -sf "$source_file" "$target"
done

# iterate over all files in the .config directory recursively and create symlinks
# Create directories as needed
CONFIG_SOURCE_DIR="$DOTFILES_CONFIG_DIR"
CONFIG_TARGET_DIR="$USER_HOME_DIR/.config"
mkdir -p "$CONFIG_TARGET_DIR"

find "$CONFIG_SOURCE_DIR" -type f | while read -r file; do
  echo "Processing .config folder: $file"
  relative_path="${file#$CONFIG_SOURCE_DIR/}"
  target="$CONFIG_TARGET_DIR/$relative_path"
  source_file="$file"
  target_dir="$(dirname "$target")"
  mkdir -p "$target_dir"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "Warning: $target exists and is not a symlink."
    echo "Backing up existing $target to $target.backup"
    mv "$target" "$target.backup"
  elif [ -L "$target" ]; then
    echo "Overwriting existing symlink $target"
  fi
  ln -sf "$source_file" "$target"
done


print_tool_setup_complete "Linking dotfiles"