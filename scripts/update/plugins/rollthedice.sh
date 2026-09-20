#!/usr/bin/env bash
# Project:           Kus' modded Counter Strike 2 (CS2) Dedicated Server - https://github.com/kus/cs2-modded-server/
# Update script for: RollTheDice
# README row:        [RollTheDice](https://github.com/Kandru/cs2-roll-the-dice)
# Sourced by scripts/update/update.sh - do not run directly.
#
# Process (reconstructed from the "UPDATED: RollTheDice" commits, e.g. 26.05.1 > 26.07.1):
#   1. Download the release zip, e.g. cs2-roll-the-dice-release-26.07.1.zip
#   2. Extract it; the archive root is RollTheDice/. Replace
#        <extracted>/RollTheDice -> game/csgo/addons/counterstrikesharp/plugins/disabled/RollTheDice
#   3. Delete the extracted folder
#
# Not touched: game/csgo/addons/counterstrikesharp/configs/plugins/RollTheDice/RollTheDice.json
# (customised, not shipped by the release).

PLUGIN_PATHS=(
    "game/csgo/addons/counterstrikesharp/plugins/disabled/RollTheDice"
)

plugin_assets() {
    echo "cs2-roll-the-dice-release-${NEW_VERSION}.zip"
}

plugin_preflight() {
    require_dir "game/csgo/addons/counterstrikesharp/plugins/disabled/RollTheDice"
}

plugin_apply() {
    local x
    x=$(extract_asset "cs2-roll-the-dice-release-*.zip")

    require_file "$x/RollTheDice/RollTheDice.dll"

    remove_path "game/csgo/addons/counterstrikesharp/plugins/disabled/RollTheDice"
    copy_dir "$x/RollTheDice" "game/csgo/addons/counterstrikesharp/plugins/disabled/RollTheDice"

    remove_extracted "$x"
}
