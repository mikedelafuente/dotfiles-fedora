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

print_tool_setup_start "Zsh + Oh My Zsh + Powerlevel10k"

# Install Zsh if not already installed
if ! command -v zsh &> /dev/null; then
    print_info_message "Installing Zsh"
    sudo apt install -y zsh
else
    print_info_message "Zsh is already installed. Skipping installation."
fi  

# Install Oh My Zsh if not already installed
if [ ! -d "$USER_HOME_DIR/.oh-my-zsh" ]; then
    print_info_message "Installing Oh My Zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi


# Install Powerlevel10k theme if not already installed
if [ ! -d "${ZSH_CUSTOM:-$USER_HOME_DIR/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    print_line_break "Installing Powerlevel10k theme"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$USER_HOME_DIR/.oh-my-zsh/custom}/themes/powerlevel10k

    # Update .zshrc to set Powerlevel10k as the theme
    # sed command to replace the ZSH_THEME line
    sed -i 's/^ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$USER_HOME_DIR/.zshrc"
fi

# Set Zsh as the default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    print_info_message "Changing default shell to Zsh"
    chsh -s "$(which zsh)"
else
    print_info_message "Zsh is already the default shell. Skipping change."
fi

print_tool_setup_complete "Zsh + Oh My Zsh + Powerlevel10k"
