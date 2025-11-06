#!/bin/bash

# --------------------------
# Setup Docker for Fedora KDE
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

print_tool_setup_start "Docker"

# --------------------------
# Remove Old Docker Versions
# --------------------------

# Uninstall old versions of Docker and Podman packages if they exist
print_info_message "Removing old Docker/Podman versions if present"
for pkg in docker docker-client docker-client-latest docker-common docker-latest \
           docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux \
           docker-engine podman-docker; do
  sudo dnf remove -y "$pkg" 2>/dev/null || true
done

# --------------------------
# Check if Docker is Already Installed
# --------------------------

# Check to see if Docker is already installed and working
if command -v docker >/dev/null 2>&1 && docker --version >/dev/null 2>&1; then
  print_info_message "Docker is already installed. Skipping installation."
  print_tool_setup_complete "Docker"
  exit 0
else
  print_info_message "Docker not found or not working. Proceeding with installation."
fi

# --------------------------
# Install Docker Repository
# --------------------------

# Install required packages
print_info_message "Installing required packages"
sudo dnf install -y dnf-plugins-core

# Add Docker's official repository for Fedora
print_info_message "Adding Docker repository for Fedora"
sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
#sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

# --------------------------
# Install Docker Packages
# --------------------------

# Install the latest version of Docker Engine, CLI, Containerd, and plugins
print_info_message "Installing Docker Engine, CLI, and plugins"
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# --------------------------
# Configure and Start Docker Service
# --------------------------

# Start and enable Docker service
print_info_message "Starting and enabling Docker service"
sudo systemctl start docker
sudo systemctl enable docker

# --------------------------
# Add User to Docker Group
# --------------------------

# Add original user (when run with sudo) or current user to the docker group
if [ -n "${SUDO_USER-}" ]; then
  TARGET_USER="$SUDO_USER"
else
  TARGET_USER="$USER"
fi

print_info_message "Adding user '$TARGET_USER' to docker group"
sudo usermod -aG docker "$TARGET_USER"

# --------------------------
# Installation Complete
# --------------------------

echo ""
print_info_message "Docker installation completed successfully!"
docker --version
echo ""
print_warning_message "IMPORTANT: To apply the new group membership, please log out and log back in,"
print_warning_message "or restart your terminal session. You may also need to restart your system."
echo ""

print_tool_setup_complete "Docker"