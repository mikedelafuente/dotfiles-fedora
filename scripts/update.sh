#!/bin/bash

# --------------------------
# Update Script for Fedora KDE Setup
# --------------------------
# This script updates the system and all installed tools to their latest versions.
# It ensures that the Fedora KDE environment remains current and secure.
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

print_info_message "Starting system update..."

# --------------------------
# Update DNF Packages
# --------------------------

print_info_message "Updating DNF packages..."
sudo dnf update -y
sudo dnf upgrade --refresh -y

# --------------------------
# Update Flatpak Packages
# --------------------------

if command -v flatpak &> /dev/null; then
    print_info_message "Updating Flatpak packages..."
    flatpak update -y
else
    print_info_message "Flatpak not installed, skipping Flatpak updates"
fi

# --------------------------
# Update Rust (via rustup)
# --------------------------

if command -v rustup &> /dev/null; then
    print_info_message "Updating Rust toolchain..."
    rustup update
else
    print_info_message "Rustup not installed, skipping Rust updates"
fi

# --------------------------
# Update Node.js (via nvm)
# --------------------------

export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    print_info_message "Updating Node.js to latest LTS..."
    
    # Run nvm commands in a subshell to avoid nounset issues
    # nvm.sh has unbound variables that fail when set -u is active
    bash -c '
        export NVM_DIR="$HOME/.nvm"
        source "$NVM_DIR/nvm.sh"
        nvm install --lts
        nvm use --lts
        nvm alias default "lts/*"
    '
    
    # Update global npm packages
    print_info_message "Updating global npm packages..."
    npm update -g
else
    print_info_message "NVM not installed, skipping Node.js updates"
fi

# --------------------------
# Update pip packages
# --------------------------

if command -v pip3 &> /dev/null; then
    print_info_message "Updating pip packages..."
    pip3 list --outdated --format=json | python3 -c "import json, sys; print('\n'.join([x['name'] for x in json.load(sys.stdin)]))" | xargs -n1 pip3 install --upgrade 2>/dev/null || true
else
    print_info_message "pip3 not installed, skipping pip updates"
fi

# --------------------------
# Update Go packages
# --------------------------

if command -v go &> /dev/null; then
    print_info_message "Go is installed. Run 'go install <package>@latest' to update Go packages manually."
else
    print_info_message "Go not installed, skipping Go updates"
fi

# --------------------------
# Clean up
# --------------------------

print_info_message "Cleaning up..."

# Remove unused DNF packages
sudo dnf autoremove -y

# Clean DNF cache
sudo dnf clean all

# Remove old kernel versions (keep only latest 3)
OLD_KERNELS=$(dnf repoquery --installonly --latest-limit=-3 -q)
if [ -n "$OLD_KERNELS" ]; then
    print_info_message "Removing old kernel versions..."
    sudo dnf remove -y $OLD_KERNELS
else
    print_info_message "No old kernels to remove"
fi

# Clean Flatpak unused runtimes and extensions
if command -v flatpak &> /dev/null; then
    print_info_message "Cleaning up Flatpak..."
    flatpak uninstall --unused -y
    flatpak repair --user
fi

# Clean npm cache (if npm is available)
if command -v npm &> /dev/null; then
    print_info_message "Cleaning npm cache..."
    npm cache clean --force
fi

# Clean cargo cache (if cargo is available)
if command -v cargo &> /dev/null && [ -d "$HOME/.cargo/registry" ]; then
    print_info_message "Cleaning old Cargo build artifacts..."
    # Only clean if cargo-cache is installed, otherwise skip
    if cargo install --list | grep -q "cargo-cache"; then
        cargo cache --autoclean
    else
        print_info_message "Install cargo-cache for automatic Cargo cleanup: cargo install cargo-cache"
    fi
fi

# Clean systemd journal logs (keep last 7 days)
print_info_message "Cleaning old journal logs..."
sudo journalctl --vacuum-time=7d

# Clean temporary files
print_info_message "Cleaning temporary files..."
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*

print_info_message "System update and cleanup complete!"
