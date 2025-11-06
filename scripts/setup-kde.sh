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
    
    # Disable tap-to-click and set ClickMethod=2 for each detected touchpad.
    # We need to extract vendor:product IDs from libinput to create proper nested groups
    TOUCHPADS=()
    
    if command -v libinput &> /dev/null; then
        # Parse libinput list-devices output to extract device name and IDs
        while IFS= read -r line; do
            if [[ "$line" =~ Device:[[:space:]]*(.*) ]]; then
                device_name="${BASH_REMATCH[1]}"
                device_name=$(echo "$device_name" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                
                # Check if this is a touchpad
                if echo "$device_name" | grep -qi touchpad; then
                    # Extract hex vendor:product (e.g., "2808:0106" from "ASUF1205:00 2808:0106 Touchpad")
                    # Match pattern: 4 hex digits, colon, 4 hex digits (with word boundaries)
                    if [[ "$device_name" =~ [[:space:]]([0-9A-Fa-f]{4}):([0-9A-Fa-f]{4})[[:space:]] ]]; then
                        vendor_hex="${BASH_REMATCH[1]}"
                        product_hex="${BASH_REMATCH[2]}"
                        vendor_dec=$((16#$vendor_hex))
                        product_dec=$((16#$product_hex))
                        TOUCHPADS+=("$vendor_dec:$product_dec:$device_name")
                    else
                        # No vendor:product found, store with placeholder
                        TOUCHPADS+=(":0:$device_name")
                    fi
                fi
            fi
        done < <(sudo libinput list-devices 2>/dev/null)
    elif command -v xinput &> /dev/null; then
        # Fallback to xinput (won't have vendor:product IDs)
        mapfile -t raw < <(xinput --list --name-only 2>/dev/null | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | grep -i touchpad || true)
        for d in "${raw[@]}"; do
            TOUCHPADS+=(":0:$d")
        done
    fi

    if [ ${#TOUCHPADS[@]} -gt 0 ]; then
        for entry in "${TOUCHPADS[@]}"; do
            IFS=':' read -r vendor_dec product_dec device_name <<< "$entry"
            
            if [ -n "$vendor_dec" ] && [ "$vendor_dec" != "0" ] && [ -n "$product_dec" ] && [ "$product_dec" != "0" ]; then
                print_info_message "Applying touchpad settings to: $device_name (vendor=$vendor_dec, product=$product_dec)"
                # Create nested group structure: [Libinput][vendor][product][device]
                $KWRITECONFIG --file kcminputrc --group "Libinput" --group "$vendor_dec" --group "$product_dec" --group "$device_name" --key "TapToClick" "false" 2>/dev/null || true
                $KWRITECONFIG --file kcminputrc --group "Libinput" --group "$vendor_dec" --group "$product_dec" --group "$device_name" --key "ClickMethod" "2" 2>/dev/null || true
            else
                print_info_message "Applying touchpad settings to: $device_name (no vendor/product ID)"
                # Fallback: just use device name
                $KWRITECONFIG --file kcminputrc --group "Libinput" --group "$device_name" --key "TapToClick" "false" 2>/dev/null || true
                $KWRITECONFIG --file kcminputrc --group "Libinput" --group "$device_name" --key "ClickMethod" "2" 2>/dev/null || true
            fi
        done
    else
        print_info_message "No touchpads detected via libinput/xinput; applying generic settings"
    fi

    # Also set the generic Libinput defaults (covers devices not enumerated above)
    $KWRITECONFIG --file kcminputrc --group "Libinput" --key "TapToClick" "false" 2>/dev/null || true
    $KWRITECONFIG --file kcminputrc --group "Libinput" --key "ClickMethod" "2" 2>/dev/null || true

     print_info_message "Touchpad tap-to-click disabled and click method set"

    # Reload KDE input device configuration
    if command -v kquitapp6 &> /dev/null; then
        print_info_message "Reloading KDE input device settings..."
        # Restart the KDE settings daemon to reload input configurations
        kquitapp6 kded6 2>/dev/null || true
        sleep 1
        kded6 &> /dev/null &
        print_info_message "Input settings reloaded using kquitapp6"
    elif command -v qdbus6 &> /dev/null; then
        print_info_message "Reloading KDE input device settings..."
        qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null || true
        print_info_message "Input settings reloaded using qdbus6"
    else
        print_warning_message "Could not reload settings automatically. Changes will take effect after logout/login"
    fi
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
            # Detect if the system has a battery (i.e., is a laptop)
            if [ -d "/sys/class/power_supply/BAT0" ] || [ -d "/sys/class/power_supply/BAT1" ]; then
                IS_LAPTOP=true
            else
                IS_LAPTOP=false
            fi

            if [ "$IS_LAPTOP" = true ]; then
                print_info_message "Laptop detected. Enabling deep sleep configuration"
                sudo grubby --update-kernel=ALL --args="mem_sleep_default=deep"
                print_info_message "Deep sleep mode enabled. Please reboot for changes to take effect."
            else
                print_info_message "No laptop battery detected; skipping deep sleep configuration"
            fi
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

# Default to the Breeze Dark theme
if [ -n "$KWRITECONFIG" ]; then
    $KWRITECONFIG --file kwinrc --group "Theme" --key "name" "Breeze Dark"
    print_info_message "Set KDE Plasma theme to Breeze Dark"
fi

# Restart plasmashell to apply configuration changes
# if command -v kquitapp6 &> /dev/null; then
#     kquitapp6 plasmashell && kstart6 plasmashell &> /dev/null &
# elif command -v kquitapp5 &> /dev/null; then
#     kquitapp5 plasmashell && kstart5 plasmashell &> /dev/null &
# else
#     print_warning_message "Could not restart plasmashell automatically. Please log out and back in to see all changes."
# fi

# --------------------------
# Completion
# --------------------------

print_tool_setup_complete "KDE Plasma"
print_info_message "Note: Some changes may require a logout/login or reboot to take full effect"