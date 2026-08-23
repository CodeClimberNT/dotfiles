#!/bin/bash

# ==========================================
# USER CONFIGURATION
# ==========================================
CONFIG_FILE="$HOME/.config/niri/cfg/display.kdl"

# The power profiles list can be seen by running `powerprofilesctl`
AC_PROFILE="balanced"
BAT_PROFILE="power-saver"

# MUST use the exact string from `niri msg outputs`
MODE_AC="\"2560x1440@165.003\""
MODE_BAT="\"2560x1440@60.000\""
# ==========================================

function apply_state() {
    # Check the ACPI sysfs to see if AC power is currently online
    if grep -q 1 /sys/class/power_supply/*/online 2>/dev/null; then
        powerprofilesctl set "$AC_PROFILE"
        sed -i "s/mode .* \/\/ AUTOREFRESH/mode $MODE_AC \/\/ AUTOREFRESH/" "$CONFIG_FILE"
    else
        powerprofilesctl set "$BAT_PROFILE"
        sed -i "s/mode .* \/\/ AUTOREFRESH/mode $MODE_BAT \/\/ AUTOREFRESH/" "$CONFIG_FILE"
    fi
}

# Apply the correct state immediately on startup
apply_state

# Monitor udev for power supply change events and apply updates
udevadm monitor --subsystem-match=power_supply | grep --line-buffered "change" | while read -r line; do
    # Give the system 1 second to update the file flags before checking
    sleep 1
    apply_state
done
