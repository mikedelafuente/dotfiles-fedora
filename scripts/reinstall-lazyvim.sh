#!/bin/bash

# required
mv ~/.config/nvim{,.bak} --force

# optional but recommended
mv ~/.local/share/nvim{,.bak} --force
mv ~/.local/state/nvim{,.bak} --force
mv ~/.cache/nvim{,.bak} --force

git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git