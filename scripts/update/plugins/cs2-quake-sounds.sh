#!/usr/bin/env bash
# Project:           Kus' modded Counter Strike 2 (CS2) Dedicated Server - https://github.com/kus/cs2-modded-server/
# Update script for: cs2-quake-sounds
# README row:        [cs2-quake-sounds](https://github.com/Kandru/cs2-quake-sounds)
# Sourced by scripts/update/update.sh - do not run directly.
#
# Process (reconstructed from the "UPDATED: cs2-quake-sounds" commits, e.g. 26.06.2 > 26.08.1):
#   1. Download the release zip, e.g. cs2-quake-sounds-release-26.08.1.zip
#   2. Extract it; the archive root is QuakeSounds/. Replace
#        <extracted>/QuakeSounds -> game/csgo/addons/counterstrikesharp/plugins/disabled/QuakeSounds
#   3. Delete the extracted folder
#
# Not touched: game/csgo/addons/counterstrikesharp/configs/plugins/QuakeSounds/QuakeSounds.json
# (customised, not shipped by the release).

PLUGIN_PATHS=(
    "game/csgo/addons/counterstrikesharp/plugins/disabled/QuakeSounds"
)

plugin_assets() {
    echo "cs2-quake-sounds-release-${NEW_VERSION}.zip"
}

plugin_preflight() {
    require_dir "game/csgo/addons/counterstrikesharp/plugins/disabled/QuakeSounds"
}

plugin_apply() {
    local x
    x=$(extract_asset "cs2-quake-sounds-release-*.zip")

    require_file "$x/QuakeSounds/QuakeSounds.dll"

    remove_path "game/csgo/addons/counterstrikesharp/plugins/disabled/QuakeSounds"
    copy_dir "$x/QuakeSounds" "game/csgo/addons/counterstrikesharp/plugins/disabled/QuakeSounds"

    remove_extracted "$x"
}
