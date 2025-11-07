#!/bin/bash
# -------------------------
# Bootstrap Script for Fedora KDE
# -------------------------

# --------------------------
# Variables to be kept in ~/.dotfiles_bootstrap_config and loaded from there
# --------------------------

# Determine if we are running with sudo, and if so get the actual user's home directory
if [ "$(whoami)" != "${SUDO_USER:-$(whoami)}" ]; then
    USER_HOME_DIR=$(eval echo ~${SUDO_USER})
else
    USER_HOME_DIR="$HOME"
fi

# --------------------------
# Read Configuration or Prompt User
# --------------------------

# Read in configuration from file if it exists
if [ -r "$USER_HOME_DIR/.dotfiles_bootstrap_config" ]; then
  # shellcheck source=/dev/null
  source "$USER_HOME_DIR/.dotfiles_bootstrap_config"
else
  print_info_message "Configuration file not found. Setting based on System User."
  FULL_NAME=""$(getent passwd "$(whoami)" | cut -d ':' -f 5 | cut -d ',' -f 1)""
  DOTNET_CORE_SDK_VERSION="9.0"
fi

# Prompt for full name
if [ -z "$FULL_NAME" ]; then
  read -rp "Enter your full name (e.g., John Doe): " FULL_NAME
else
  read -rp "Enter your full name (e.g., John Doe) [$FULL_NAME]: " INPUT_FULL_NAME
  if [ -n "$INPUT_FULL_NAME" ]; then
    FULL_NAME="$INPUT_FULL_NAME"
  fi
fi

# Prompt for email address
if [ -z "$EMAIL_ADDRESS" ]; then
  read -rp "Enter your email address (e.g., john.doe@example.com): " EMAIL_ADDRESS
else
  read -rp "Enter your email address (e.g., john.doe@example.com) [$EMAIL_ADDRESS]: " INPUT_EMAIL_ADDRESS
  if [ -n "$INPUT_EMAIL_ADDRESS" ]; then
    EMAIL_ADDRESS="$INPUT_EMAIL_ADDRESS"
  fi
fi

# Prompt for .NET Core SDK version
if [ -z "$DOTNET_CORE_SDK_VERSION" ]; then
  read -rp "Enter the .NET Core SDK version to install (e.g., 9.0): " DOTNET_CORE_SDK_VERSION
else
  read -rp "Enter the .NET Core SDK version to install (e.g., 9.0) [$DOTNET_CORE_SDK_VERSION]: " INPUT_DOTNET_CORE_SDK_VERSION
  if [ -n "$INPUT_DOTNET_CORE_SDK_VERSION" ]; then
    DOTNET_CORE_SDK_VERSION="$INPUT_DOTNET_CORE_SDK_VERSION"
  fi
fi

# Validate the variables with the user
echo "Please confirm the following information:"
echo "Full Name: $FULL_NAME"
echo "Email Address: $EMAIL_ADDRESS"
echo ".NET Core SDK Version: $DOTNET_CORE_SDK_VERSION"

read -rp "Is this information correct? (y/n): " CONFIRMATION
if [[ ! "$CONFIRMATION" =~ ^[Yy]$ ]]; then
  echo "Aborting. Please run the script again to enter the correct information."
  exit 1
fi

# Write the configuration file
{
  echo "# Configuration file for dotfiles bootstrap script"
  echo "FULL_NAME=\"$FULL_NAME\""
  echo "EMAIL_ADDRESS=\"$EMAIL_ADDRESS\""
  echo "DOTNET_CORE_SDK_VERSION=\"$DOTNET_CORE_SDK_VERSION\""
} > "$USER_HOME_DIR/.dotfiles_bootstrap_config"

# --------------------------
# Start of Bootstrap Script
# --------------------------

echo "Starting bootstrap process... pwd is $(pwd)"
echo "Display server protocol: $XDG_SESSION_TYPE"
echo "Current user: $(whoami)"
echo "Home directory: $HOME"
echo "Real user: ${SUDO_USER:-$(whoami)}"
echo "Home directory of real user: $(eval echo ~${SUDO_USER:-$(whoami)})" 
echo "Shell: $SHELL"
echo "Script directory: $(dirname -- "${BASH_SOURCE[0]}")"
echo "----------------------------------------"

if [ "$(whoami)" != "${SUDO_USER:-$(whoami)}" ]; then
    echo "Please start this script without sudo."
    exit 1
fi

# Run a sudo command early to prompt for the password
sudo -v

# --------------------------
# Import Common Header 
# --------------------------

# Add header file
CURRENT_FILE_DIR="$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"

# Source header (uses SCRIPT_DIR and loads lib.sh)
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

# Set the script directory variable
DF_SCRIPT_DIR="$CURRENT_FILE_DIR"

# --------------------------
# Update System Packages
# --------------------------

# Update package list and upgrade installed packages
# Check how recent the last update was

LAST_DNF_UPDATE=$(cat "$USER_HOME_DIR/.last_dnf_update" 2>/dev/null || echo 0)
CURRENT_TIME=$(date +%s)
TIME_DIFF=$((CURRENT_TIME - LAST_DNF_UPDATE))

# If more than 1 day (86400 seconds) has passed since the last update, perform update
if [ "$TIME_DIFF" -lt 86400 ]; then
    print_info_message "Last DNF update was less than a day ago. Skipping update."
else
    print_info_message "Last DNF update was more than a day ago. Performing update."
    sudo dnf check-update || true
    # Write a file to ~/.last_dnf_update with the current timestamp
    echo "$(date +%s)" > "$USER_HOME_DIR/.last_dnf_update"
fi

LAST_DNF_UPGRADE=$(cat "$USER_HOME_DIR/.last_dnf_upgrade" 2>/dev/null || echo 0)
CURRENT_TIME=$(date +%s)
TIME_DIFF=$((CURRENT_TIME - LAST_DNF_UPGRADE))

# If more than 1 day (86400 seconds) has passed since the last upgrade, perform upgrade
if [ "$TIME_DIFF" -lt 86400 ]; then
    print_info_message "Last DNF upgrade was less than a day ago. Skipping upgrade."
else
    print_info_message "Last DNF upgrade was more than a day ago. Performing upgrade."
    sudo dnf upgrade -y
    # Write a file to ~/.last_dnf_upgrade with the current timestamp
    echo "$(date +%s)" > "$USER_HOME_DIR/.last_dnf_upgrade"
fi

# Ensure Flatpak is installed
if ! command -v flatpak &> /dev/null; then
    print_info_message "Installing Flatpak first"
    sudo dnf install -y flatpak
fi

# Add Flathub repository if not already added
if ! flatpak remotes 2>/dev/null | grep -q flathub; then
    print_info_message "Adding Flathub repository"
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

# Update Flatpak apps if they have not been updated in the last day
LAST_FLATPAK_UPDATE=$(cat "$USER_HOME_DIR/.last_flatpak_update" 2>/dev/null || echo 0)
CURRENT_TIME=$(date +%s)
TIME_DIFF=$((CURRENT_TIME - LAST_FLATPAK_UPDATE)) 

if [ "$TIME_DIFF" -lt 86400 ]; then
    print_info_message "Last Flatpak update was less than a day ago. Skipping update."
else
    print_info_message "Last Flatpak update was more than a day ago. Performing update."
    # Write a file to ~/.last_flatpak_update with the current timestamp
    echo "$(date +%s)" > "$USER_HOME_DIR/.last_flatpak_update"
    flatpak update -y
fi

# --------------------------
# Install Essential Packages
# --------------------------

ESSENTIAL_PACKAGES=(git curl wget xsel fzf ripgrep fd)
print_line_break "Installing essential packages"

for package in "${ESSENTIAL_PACKAGES[@]}"; do
    if ! dnf list installed "$package" &> /dev/null; then
        print_info_message "Installing $package"
        sudo dnf install -y "$package"
    else
        print_info_message "$package is already installed. Skipping installation."
    fi
done


# Explicitly install zoxide and then initialize it in the shell profile
if ! command -v z &> /dev/null; then
    print_info_message "Installing zoxide via dnf"
    sudo dnf install -y zoxide
    eval "$(zoxide init bash)"
else
    print_info_message "zoxide is already installed. Skipping installation."
fi

# --------------------------
# Run Individual Setup Scripts
# --------------------------

# Set up Git configuration
bash "$DF_SCRIPT_DIR/setup-git.sh" "$FULL_NAME" "$EMAIL_ADDRESS"

# Setup Python
bash "$DF_SCRIPT_DIR/setup-python.sh"

# Setup Fonts
bash "$DF_SCRIPT_DIR/setup-fonts.sh"

# Setup Bash
bash "$DF_SCRIPT_DIR/setup-bash.sh"

# Before setting up Alacritty, ensure Rust is installed
bash "$DF_SCRIPT_DIR/setup-rust.sh"

# Before setting up Alacritty, ensure that VS Code is installed
bash "$DF_SCRIPT_DIR/setup-vscode.sh"

# Setup a terminal emulator - Alacritty in this case
bash "$DF_SCRIPT_DIR/setup-alacritty.sh"

# Setup Neovim and Lazyvim - This needs to run after python setup
bash "$DF_SCRIPT_DIR/setup-neovim.sh"

# Setup Mullvad VPN
bash "$DF_SCRIPT_DIR/setup-mullvad.sh"

# Setup NVIDIA drivers
bash "$DF_SCRIPT_DIR/setup-nvidia.sh"

# Run the setup-docker.sh script to set up Docker
bash "$DF_SCRIPT_DIR/setup-docker.sh"

# Install Node.js and npm
bash "$DF_SCRIPT_DIR/setup-node.sh"

# Install .NET SDK and Rider
bash "$DF_SCRIPT_DIR/setup-dotnet-rider.sh" "$DOTNET_CORE_SDK_VERSION"

# Install Godot 4 Mono
bash "$DF_SCRIPT_DIR/setup-godot.sh"

# Install Postman
bash "$DF_SCRIPT_DIR/setup-postman.sh"

# Install Steam
bash "$DF_SCRIPT_DIR/setup-steam.sh"

# Install Discord
bash "$DF_SCRIPT_DIR/setup-discord.sh"

# Install Spotify
bash "$DF_SCRIPT_DIR/setup-spotify.sh"

# Install Obsidian
bash "$DF_SCRIPT_DIR/setup-obsidian.sh"

# Install Zoom
bash "$DF_SCRIPT_DIR/setup-zoom.sh"

# Link configuration files
bash "$DF_SCRIPT_DIR/link-dotfiles.sh"

# Set up KDE Plasma settings
bash "$DF_SCRIPT_DIR/setup-kde.sh"

# --------------------------
# Clean Up
# --------------------------

print_line_break "Cleaning up"
sudo dnf autoremove -y

print_line_break "Bootstrap completed. Please restart your terminal or log out and log back in."

echo "Shell: $SHELL"
