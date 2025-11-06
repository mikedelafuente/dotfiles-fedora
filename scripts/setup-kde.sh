 #!/bin/bash

# --------------------------
# Setup KDE Plasma Configuration for Fedora KDE
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

print_tool_setup_start "KDE Plasma"

# --------------------------
# Determine KDE Configuration Tool
# --------------------------

# Determine which kwriteconfig version to use (kwriteconfig5 for Plasma 5, kwriteconfig6 for Plasma 6)
if command -v kwriteconfig6 &> /dev/null; then
    KWRITECONFIG="kwriteconfig6"
    print_info_message "Using kwriteconfig6 (Plasma 6)"
elif command -v kwriteconfig5 &> /dev/null; then
    KWRITECONFIG="kwriteconfig5"
    print_info_message "Using kwriteconfig5 (Plasma 5)"
else
    print_warning_message "Neither kwriteconfig5 nor kwriteconfig6 found. Some KDE configurations may not be applied."
    KWRITECONFIG=""
fi

# --------------------------
# Configure Touchpad Settings
# --------------------------

if [ -n "$KWRITECONFIG" ]; then
    print_info_message "Configuring touchpad settings..."
    
    # Disable touchpad tap-to-click to prevent accidental clicks
    # This is set in the kcminputrc file under the Libinput section
    $KWRITECONFIG --file kcminputrc --group "Libinput" --group "1739" --group "52710" --group "SYNA8004:00 06CB:CE16 Touchpad" --key "TapToClick" "false" 2>/dev/null || true
    
    # Alternative: Try to set for all touchpads generically
    $KWRITECONFIG --file kcminputrc --group "Libinput" --key "TapToClick" "false" 2>/dev/null || true
    
    print_info_message "Touchpad tap-to-click disabled"
fi

# --------------------------
# Configure Power Management
# --------------------------

if [ -n "$KWRITECONFIG" ]; then
    print_info_message "Configuring power management settings..."
    
    # Configure sleep behavior - prefer s2idle (deep sleep) when available
    # Note: This is handled at the kernel level, not through KDE settings
    # We'll check if grubby is available (Fedora's bootloader configuration tool)
    
    if command -v grubby &> /dev/null; then
        # Check current kernel parameters
        CURRENT_PARAMS=$(sudo grubby --info=DEFAULT | grep args | sed 's/args="//' | sed 's/"$//')
        
        if ! echo "$CURRENT_PARAMS" | grep -q "mem_sleep_default=deep"; then
            print_action_message "Would you like to enable deep sleep mode? This can improve battery life on laptops."
            print_info_message "This will add 'mem_sleep_default=deep' to kernel parameters."
            print_warning_message "Note: Some hardware may not support this. You can revert if you experience issues."
            
            # For automation purposes, we'll skip the interactive prompt
            # Uncomment the following lines if you want to enable this automatically:
            # sudo grubby --update-kernel=ALL --args="mem_sleep_default=deep"
            # print_info_message "Deep sleep mode enabled. Please reboot for changes to take effect."
            
            print_info_message "Skipping automatic deep sleep configuration. Run manually if needed:"
            print_info_message "  sudo grubby --update-kernel=ALL --args=\"mem_sleep_default=deep\""
        else
            print_info_message "Deep sleep mode is already configured"
        fi
    else
        print_warning_message "grubby not found. Skipping kernel parameter configuration."
    fi
    
    # Configure KDE power management settings
    # Prevent automatic screen locking on AC power
    $KWRITECONFIG --file kscreenlockerrc --group "Daemon" --key "Autolock" "false"
    
    print_info_message "Power management settings configured"
fi

# --------------------------
# Configure Desktop Behavior
# --------------------------

if [ -n "$KWRITECONFIG" ]; then
    print_info_message "Configuring desktop behavior..."
    
    # Single-click to open files and folders (KDE default)
    # Uncomment to switch to double-click:
    # $KWRITECONFIG --file kdeglobals --group "KDE" --key "SingleClick" "false"
    
    # Enable desktop effects
    $KWRITECONFIG --file kwinrc --group "Compositing" --key "Enabled" "true"
    
    print_info_message "Desktop behavior configured"
fi

# --------------------------
# Install Useful KDE Utilities (via Flatpak where appropriate)
# --------------------------

print_info_message "Checking for useful KDE utilities..."

# Install KDE Connect for phone integration (Flatpak preferred)
if ! flatpak list | grep -q "org.kde.kdeconnect"; then
    print_info_message "Installing KDE Connect via Flatpak"
    flatpak install -y flathub org.kde.kdeconnect.kde
else
    print_info_message "KDE Connect is already installed"
fi

# # Install Konsole if not present (dnf preferred for system integration)
# if ! command -v konsole &> /dev/null; then
#     print_info_message "Installing Konsole terminal emulator"
#     sudo dnf install -y konsole
# else
#     print_info_message "Konsole is already installed"
# fi

# Install Spectacle (screenshot tool) if not present (dnf preferred for system integration)
if ! command -v spectacle &> /dev/null; then
    print_info_message "Installing Spectacle screenshot tool"
    sudo dnf install -y spectacle
else
    print_info_message "Spectacle is already installed"
fi

# Install KDE Partition Manager if not present (dnf preferred for system tools)
if ! command -v partitionmanager &> /dev/null; then
    print_info_message "Installing KDE Partition Manager"
    sudo dnf install -y partitionmanager
else
    print_info_message "KDE Partition Manager is already installed"
fi

# --------------------------
# Apply Configuration Changes
# --------------------------

print_info_message "Restarting KDE Plasma shell to apply changes..."
print_warning_message "Your desktop may flicker briefly as the shell restarts"

# Restart plasmashell to apply configuration changes
if command -v kquitapp6 &> /dev/null; then
    kquitapp6 plasmashell && kstart6 plasmashell &> /dev/null &
elif command -v kquitapp5 &> /dev/null; then
    kquitapp5 plasmashell && kstart5 plasmashell &> /dev/null &
else
    print_warning_message "Could not restart plasmashell automatically. Please log out and back in to see all changes."
fi

# --------------------------
# Completion
# --------------------------

print_tool_setup_complete "KDE Plasma"
print_info_message "Note: Some changes may require a logout/login or reboot to take full effect"