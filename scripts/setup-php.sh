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

print_tool_setup_start "PHP"

# --------------------------
# Install PHP
# --------------------------

# Check if PHP is already installed
if command -v php &> /dev/null; then
    print_info_message "PHP is already installed. Skipping installation."
else
    /bin/bash -c "$(curl -fsSL https://php.new/install/linux)"
    
    # Since the script requires a reload of the shell, we need to source the profile again
    # shellcheck source=/dev/null
    source "$USER_HOME_DIR/.bashrc"
    
    # Verify installation
    if command -v php &> /dev/null; then
        print_info_message "PHP installed successfully."
    else
        print_error_message "PHP installation failed."
        exit 1
    fi
fi

# Print PHP version
print_info_message "PHP version: $(php --version | head -n 1)"

# Install Composer if not already installed
if command -v composer &> /dev/null; then
    print_info_message "Composer is already installed. Skipping installation."
    print_info_message "Composer version: $(composer --version)"
else
    print_warn_message "We need to manually install Composer for PHP"
fi

# Laravel should have also been installed via the php.new script - verify installation
if command -v laravel &> /dev/null; then
    print_info_message "Laravel is already installed. Skipping installation."
    print_info_message "Laravel version: $(laravel --version)"
else
    print_warn_message "We need to manually install Laravel for PHP"
fi

print_tool_setup_complete "PHP"

