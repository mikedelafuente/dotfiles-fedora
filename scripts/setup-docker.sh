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

print_tool_setup_start "Docker"

# Uninstall old versions of Docker if they exist
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
  sudo apt-get remove -y --purge "$pkg" || true
done

# Check to see if the newer Docker packages are already installed
if command -v docker >/dev/null 2>&1 && docker --version >/dev/null 2>&1; then
  print_info_message "Docker is already installed. Skipping installation."
  print_tool_setup_complete "Docker"
  exit 0
else
  print_info_message "Docker not found or not working. Proceeding with installation."
fi

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install the latest version of Docker Engine, CLI, and Containerd
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add original user (when run with sudo) or current user to the docker group
if [ -n "${SUDO_USER-}" ]; then
  TARGET_USER="$SUDO_USER"
else
  TARGET_USER="$USER"
fi
sudo usermod -aG docker "$TARGET_USER"

# Do NOT run `newgrp` here — it spawns an interactive shell and blocks scripts.
echo "Docker installation completed."
docker --version
echo "To apply the new group membership, please log out and log back in, or restart your terminal session."


print_tool_setup_complete "Docker"