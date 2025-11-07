#!/bin/bash

# --------------------------
# Setup NVIDIA Drivers for Fedora KDE
# --------------------------
# Installs NVIDIA proprietary drivers from RPM Fusion for optimal performance.
# This script is designed for NVIDIA GPUs (RTX 3080 Ti and similar).
# 
# Why RPM Fusion NVIDIA drivers:
# - Official NVIDIA drivers packaged for Fedora
# - Automatic kernel module rebuilding (akmod)
# - Better integration with Fedora's system
# - CUDA support included
# - Proper Wayland and X11 support
#
# Note: Requires RPM Fusion Non-Free repository to be enabled.
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

print_tool_setup_start "NVIDIA Drivers"

# --------------------------
# Enable RPM Fusion Repositories
# --------------------------

# Check if RPM Fusion repositories are enabled
if ! dnf repolist 2>/dev/null | grep -q "rpmfusion-nonfree"; then
    print_info_message "Enabling RPM Fusion Free and Non-Free repositories"
    sudo dnf install -y \
        https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1
else
    print_info_message "RPM Fusion repositories already enabled"
fi

# --------------------------
# Check for NVIDIA GPU
# --------------------------

print_info_message "Checking for NVIDIA GPU..."
if lspci | grep -i nvidia &> /dev/null; then
    GPU_INFO=$(lspci | grep -i nvidia | head -n1)
    print_info_message "Detected NVIDIA GPU: $GPU_INFO"
else
    print_warning_message "No NVIDIA GPU detected. This script is designed for NVIDIA hardware."
    print_warning_message "Proceeding anyway, but drivers may not load properly."
fi

# --------------------------
# Remove Nouveau (Open Source Driver)
# --------------------------

print_info_message "Checking for nouveau driver..."
if lsmod | grep -q nouveau; then
    print_info_message "Nouveau driver detected. Adding to blacklist..."
    
    # Blacklist nouveau
    echo "blacklist nouveau" | sudo tee /etc/modprobe.d/blacklist-nouveau.conf
    echo "options nouveau modeset=0" | sudo tee -a /etc/modprobe.d/blacklist-nouveau.conf
    
    print_warning_message "Nouveau driver will be disabled on next reboot"
    REBOOT_REQUIRED=true
    INITRAMFS_UPDATE_REQUIRED=true
else
    print_info_message "Nouveau driver not loaded"
fi

# --------------------------
# Install NVIDIA Drivers
# --------------------------

# Check if NVIDIA drivers are already installed
if ! rpm -q akmod-nvidia &> /dev/null; then
    print_info_message "Installing NVIDIA proprietary drivers from RPM Fusion..."
    
    # Install NVIDIA driver packages
    # akmod-nvidia: Automatic kernel module building
    # xorg-x11-drv-nvidia: X11 driver
    # xorg-x11-drv-nvidia-cuda: CUDA support
    sudo dnf install -y \
        akmod-nvidia \
        xorg-x11-drv-nvidia \
        xorg-x11-drv-nvidia-cuda \
        xorg-x11-drv-nvidia-cuda-libs \
        vdpauinfo \
        libva-utils
    
    print_info_message "NVIDIA drivers installed successfully"
    REBOOT_REQUIRED=true
    INITRAMFS_UPDATE_REQUIRED=true
    AKMOD_BUILD_REQUIRED=true
else
    print_info_message "NVIDIA drivers already installed"
    INSTALLED_VERSION=$(rpm -q akmod-nvidia 2>/dev/null || echo 'unknown')
    print_info_message "Installed version: $INSTALLED_VERSION"
fi

# --------------------------
# Configure NVIDIA Settings
# --------------------------

print_info_message "Configuring NVIDIA settings..."

# Enable nvidia-drm modeset for Wayland support
if [ ! -f /etc/modprobe.d/nvidia-drm.conf ]; then
    echo "options nvidia-drm modeset=1" | sudo tee /etc/modprobe.d/nvidia-drm.conf
    print_info_message "Enabled NVIDIA DRM kernel mode setting for Wayland support"
    INITRAMFS_UPDATE_REQUIRED=true
fi

# Update initramfs to include NVIDIA modules (only if changes were made)
if [ "${INITRAMFS_UPDATE_REQUIRED:-false}" = true ]; then
    print_info_message "Updating initramfs with NVIDIA modules..."
    sudo dracut --force
else
    print_info_message "No initramfs update required - skipping dracut"
fi

# --------------------------
# Wait for akmod to build (only if drivers were just installed)
# --------------------------

if [ "${AKMOD_BUILD_REQUIRED:-false}" = true ]; then
    print_info_message "Waiting for NVIDIA kernel modules to build (this may take a few minutes)..."
    print_info_message "You can check the status with: sudo akmods --force"
    sudo akmods --force
else
    print_info_message "NVIDIA kernel modules already built - skipping akmods"
fi

# --------------------------
# Install NVIDIA CUDA Toolkit (Optional)
# --------------------------

print_info_message "CUDA support is included with xorg-x11-drv-nvidia-cuda"
print_info_message "For full CUDA development toolkit, you can install: sudo dnf install cuda"

# --------------------------
# System Configuration
# --------------------------

# Check if running Wayland
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    print_info_message "Wayland session detected"
    print_info_message "NVIDIA drivers support Wayland with GBM backend (Plasma 6+)"
    print_info_message "If you experience issues, you can switch to X11 from the login screen"
else
    print_info_message "X11 session detected - NVIDIA drivers fully supported"
fi

# --------------------------
# Completion Message
# --------------------------

print_tool_setup_complete "NVIDIA Drivers"

if [ "${REBOOT_REQUIRED:-false}" = true ]; then
    echo ""
    print_warning_message "===================================================="
    print_warning_message "  REBOOT REQUIRED FOR NVIDIA DRIVERS TO TAKE EFFECT"
    print_warning_message "===================================================="
    echo ""
    print_info_message "After reboot, verify installation with:"
    print_info_message "  nvidia-smi                    # Check GPU status"
    print_info_message "  nvidia-settings               # Open NVIDIA control panel"
    print_info_message "  lsmod | grep nvidia           # Verify kernel modules loaded"
else
    echo ""
    print_info_message "Verify NVIDIA driver installation:"
    print_info_message "  nvidia-smi                    # Check GPU status"
    print_info_message "  nvidia-settings               # Open NVIDIA control panel"
fi