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

print_tool_setup_start "Mullvad VPN"

# Install Mullvad VPN if not already installed
if ! command -v mullvad &> /dev/null; then
    print_info_message "Installing Mullvad VPN"
    
    # Download the Mullvad signing key
    sudo curl -fsSLo /usr/share/keyrings/mullvad-keyring.asc https://repository.mullvad.net/deb/mullvad-keyring.asc

    # Add the Mullvad repository server to apt
    echo "deb [signed-by=/usr/share/keyrings/mullvad-keyring.asc arch=$( dpkg --print-architecture )] https://repository.mullvad.net/deb/stable stable main" | sudo tee /etc/apt/sources.list.d/mullvad.list

    # Install the package
    # it is possible that we will need to run the following to avoid the "Could not get lock /var/llb/apt/lists/lock"
    # We could first see if there is someone who has a lock: 
    #       sudo lsof /var/lib/apt/lists/lock
    # At first we could sleep for 5 seconds at a time up to 60 seconds and keep checking to see if it was freed up...
    # This feels like a common function for us to call... like safe-apt-update
    # Then we could kill it...
    # And in the worst case we can run:
    # sudo service packagekit restart
    
    sudo apt update # Because we added a repo, we need to update
    sudo apt install -y mullvad-vpn
else
    print_info_message "Mullvad VPN is already installed. Skipping installation."
fi

print_tool_setup_complete "Mullvad VPN"
