#!/bin/bash

# ============================================================================
# Reset Neovim Configuration
# ============================================================================
# Completely removes Neovim configuration, data, state, and cache
# Then reinstalls Neovim and relinks configuration from dotfiles
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/fn-lib.sh"

info "Resetting Neovim configuration..."

# Remove existing backups
info "Removing old backups..."
rm -rf ~/.config/nvim.bak
rm -rf ~/.local/share/nvim.bak
rm -rf ~/.local/state/nvim.bak
rm -rf ~/.cache/nvim.bak

# Backup current config (if exists and is not a symlink)
if [ -e ~/.config/nvim ] && [ ! -L ~/.config/nvim ]; then
    info "Backing up current config..."
    mv ~/.config/nvim ~/.config/nvim.bak
elif [ -L ~/.config/nvim ]; then
    info "Removing symlinked config..."
    rm -rf ~/.config/nvim
fi

# Remove data, state, and cache
info "Removing Neovim data directories..."
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim

success "Neovim reset complete!"

# Run setup script
info "Running setup-neovim.sh..."
bash "${SCRIPT_DIR}/setup-neovim.sh"

# Run link script
info "Linking dotfiles..."
bash "${SCRIPT_DIR}/link-dotfiles.sh"

success "Neovim has been reset and reinstalled!"
info "Start Neovim with: nvim"