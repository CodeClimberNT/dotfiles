#!/bin/bash
set -euo pipefail

# Usage: power-profile.sh [ac|battery]

PROFILE=${1:-}

if [[ "$PROFILE" != "ac" && "$PROFILE" != "battery" ]]; then
    echo "Usage: $0 [ac|battery]"
    exit 1
fi

KSCREEN=$(kscreen-doctor -j)

read -r DISP_NAME WIDTH HEIGHT TARGET_MODE_ID TARGET_REFRESH <<< "$(echo "$KSCREEN" | jq -r --arg profile "$PROFILE" '
    .outputs[]
    | select(.enabled and .priority == 1)
    | . as $output
    | ($output.modes[] | select(.id == $output.currentModeId)) as $current
    | [
        $output.name,
        $current.size.width,
        $current.size.height,
        (
            $output.modes
            | map(select(
                .size == $current.size
                and (
                    ($profile == "battery" and .refreshRate >= 59 and .refreshRate <= 61)
                    or
                    ($profile == "ac")
                )
            ))
            | if $profile == "battery"
              then .[0]
              else max_by(.refreshRate)
              end
        )
    ]
    | "\(.[0]) \(.[1]) \(.[2]) \(.[3].id) \(.[3].refreshRate)"
')"

if [[ -z "$DISP_NAME" || -z "$TARGET_MODE_ID" ]]; then
    echo "Error: Could not determine a suitable display mode."
    exit 1
fi

echo "Display: $DISP_NAME"
echo "Resolution: ${WIDTH}x${HEIGHT}"
echo "Target refresh: ${TARGET_REFRESH}Hz"
echo "Target mode: $TARGET_MODE_ID"

if [[ "$PROFILE" == "ac" ]]; then
    echo "Switching to AC Profile..."
    sudo systemctl start nvidia-persistenced
    sudo systemctl start nvidia-powerd
else
    echo "Switching to Battery Profile..."
fi

kscreen-doctor "output.$DISP_NAME.mode.$TARGET_MODE_ID"

notify-send \
    "Power Profile" \
    "Switched to $PROFILE mode (${TARGET_REFRESH}Hz)"