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
    
    # Disable tap-to-click and set ClickMethod=2 for each detected touchpad
    # KDE stores settings as: [Libinput][vendorID][productID][deviceName]
    TOUCHPADS=()
    
    if command -v libinput &> /dev/null; then
        # Parse libinput list-devices to extract device names with vendor:product IDs
        while IFS= read -r line; do
            if [[ "$line" =~ Device:[[:space:]]*(.*) ]]; then
                device_name="${BASH_REMATCH[1]}"
                device_name=$(echo "$device_name" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                
                if echo "$device_name" | grep -qi touchpad; then
                    # Extract vendor:product (4 hex digits each) e.g., "2808:0106"
                    if [[ "$device_name" =~ [[:space:]]([0-9A-Fa-f]{4}):([0-9A-Fa-f]{4})[[:space:]] ]]; then
                        vendor_hex="${BASH_REMATCH[1]}"
                        product_hex="${BASH_REMATCH[2]}"
                        vendor_dec=$((16#$vendor_hex))
                        product_dec=$((16#$product_hex))
                        TOUCHPADS+=("$vendor_dec:$product_dec:$device_name")
                    fi
                fi
            fi
        done < <(sudo libinput list-devices 2>/dev/null)
    fi

    # Apply settings to each touchpad
    if [ ${#TOUCHPADS[@]} -gt 0 ]; then
        for entry in "${TOUCHPADS[@]}"; do
            IFS=':' read -r vendor_dec product_dec device_name <<< "$entry"
            print_info_message "Configuring: $device_name"
            
            # Create nested group structure: [Libinput][vendor][product][device]
            $KWRITECONFIG --file kcminputrc --group "Libinput" --group "$vendor_dec" --group "$product_dec" --group "$device_name" --key "TapToClick" "false"
            $KWRITECONFIG --file kcminputrc --group "Libinput" --group "$vendor_dec" --group "$product_dec" --group "$device_name" --key "ClickMethod" "2"
        done
        print_info_message "Touchpad settings applied (tap-to-click disabled, physical click enabled)"
    else
        print_warning_message "No touchpads detected. Settings will be applied on next login if touchpad is connected."
    fi

    # Set generic defaults as fallback
    $KWRITECONFIG --file kcminputrc --group "Libinput" --key "TapToClick" "false"
    
    print_warning_message "Touchpad changes require logout/login to take effect"
fi

# --------------------------
# Configure Power Management
# --------------------------

if [ -n "$KWRITECONFIG" ]; then
    print_info_message "Configuring power management settings..."
    
    # Disable automatic screen locking
    $KWRITECONFIG --file kscreenlockerrc --group "Daemon" --key "Autolock" "false"
    
    print_info_message "Power management settings configured (auto-lock disabled)"
fi

# --------------------------
# Configure Desktop Behavior
# --------------------------

if [ -n "$KWRITECONFIG" ]; then
    print_info_message "Configuring desktop behavior..."
    
    # Enable desktop effects (compositing)
    $KWRITECONFIG --file kwinrc --group "Compositing" --key "Enabled" "true"
    
    # Set Breeze Dark theme
    $KWRITECONFIG --file kdeglobals --group "General" --key "ColorScheme" "BreezeDark"
    
    # Configure 4 virtual desktops
    $KWRITECONFIG --file kwinrc --group "Desktops" --key "Number" "4"
    $KWRITECONFIG --file kwinrc --group "Desktops" --key "Rows" "1"
    
    print_info_message "Desktop behavior configured (compositing enabled, Breeze Dark theme, 4 virtual desktops)"
fi

# --------------------------
# Configure Displays and Panel
# --------------------------

if [ -n "$KWRITECONFIG" ]; then
    print_info_message "Configuring display and panel settings..."
    
    # Find the largest monitor and set as primary
    if command -v xrandr &> /dev/null; then
        # Get connected monitors with their resolutions
        LARGEST_MONITOR=$(xrandr --query | grep " connected" | awk '{
            # Extract resolution (e.g., "1920x1080")
            if ($3 ~ /^[0-9]+x[0-9]+/) {
                res = $3
            } else if ($4 ~ /^[0-9]+x[0-9]+/) {
                res = $4
            } else {
                next
            }
            # Parse width and height
            split(res, dims, "x")
            width = dims[1]
            split(dims[2], h, "+")
            height = h[1]
            area = width * height
            if (area > max_area) {
                max_area = area
                monitor = $1
            }
        }
        END { print monitor }')
        
        if [ -n "$LARGEST_MONITOR" ]; then
            print_info_message "Setting $LARGEST_MONITOR as primary display"
            xrandr --output "$LARGEST_MONITOR" --primary
        else
            print_warning_message "Could not detect largest monitor"
        fi
    fi
    
    # Configure panel to auto-hide
    # Panel configuration is stored in plasma-org.kde.plasma.desktop-appletsrc
    # We'll use a Python/DBus script or kwriteconfig with the panel's config group
    PANEL_CONFIG="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
    
    if [ -f "$PANEL_CONFIG" ]; then
        # Find the panel container ID (usually [Containments][1] or [Containments][2])
        PANEL_ID=$(grep -E "^\[Containments\]\[[0-9]+\]" "$PANEL_CONFIG" | grep -A5 "panel" | head -n1 | sed 's/\[Containments\]\[\([0-9]*\)\]/\1/')
        
        if [ -n "$PANEL_ID" ]; then
            print_info_message "Configuring panel $PANEL_ID to auto-hide"
            $KWRITECONFIG --file plasma-org.kde.plasma.desktop-appletsrc --group "Containments" --group "$PANEL_ID" --group "General" --key "hiding" "1"
        else
            print_warning_message "Could not find panel ID. Panel auto-hide must be configured manually."
        fi
    else
        print_warning_message "Panel configuration file not found. Panel settings will be applied on next login."
    fi
    
    print_info_message "Display and panel settings configured"
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

print_info_message "KDE Plasma configuration complete"
print_warning_message "Please log out and log back in for all changes to take effect"

# --------------------------
# Completion
# --------------------------

print_tool_setup_complete "KDE Plasma"