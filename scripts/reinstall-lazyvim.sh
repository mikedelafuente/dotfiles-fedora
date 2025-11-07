#!/bin/bash

# required
# remove existing config backup if it exists
rm -rf ~/.config/nvim.bak
mv ~/.config/nvim{,.bak} --force

# optional but recommended
rm -rf ~/.local/share/nvim.bak
rm -rf ~/.local/state/nvim.bak
rm -rf ~/.cache/nvim.bak

mv ~/.local/share/nvim{,.bak} --force
mv ~/.local/state/nvim{,.bak} --force
mv ~/.cache/nvim{,.bak} --force

git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git