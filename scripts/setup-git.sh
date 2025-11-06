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

# --------------------------
# See if username and email were passed as arguments
# --------------------------
USERNAME_ARG="$1"
EMAIL_ARG="$2"

# if not passed as arguments, then ask for them
if [ -z "$USERNAME_ARG" ]; then
    read -rp "Enter your full name for git commit history: " USERNAME_ARG
fi

if [ -z "$EMAIL_ARG" ]; then
    read -rp "Enter your email for git commit history: " EMAIL_ARG
fi

if [ -z "$USERNAME_ARG" ] || [ -z "$EMAIL_ARG" ]; then
    print_error_message "Both full name and email address are required to set up Git."
    exit 1
fi

# --------------------------
# End check for username and email arguments
# --------------------------

# --------------------------
# Set up Git configuration
# --------------------------

print_tool_setup_start "Git"

git config --global user.name "$USERNAME_ARG"
git config --global user.email "$EMAIL_ARG"
git config --global core.editor "nvim"
git config --global init.defaultBranch main

# Check to see if SSH keys already exist

if [ -f "$USER_HOME_DIR/.ssh/id_ed25519" ]; then
    echo "SSH key already exists. Skipping key generation."
else
    echo "Generating new SSH key."

    # Create SSH keys for GitHub using Ed25519 without passphrase
    ssh-keygen -t ed25519 -C "$EMAIL_ARG" -f "$USER_HOME_DIR/.ssh/id_ed25519" -N ""
    # Add SSH key to ssh-agent
    eval "$(ssh-agent -s)"
    ssh-add "$USER_HOME_DIR/.ssh/id_ed25519"
    # Display the public key for GitHub
    echo "Your public SSH key is:"
    cat "$USER_HOME_DIR/.ssh/id_ed25519.pub"
    echo "Copy this key to your GitHub account."
fi

print_tool_setup_complete "Git"