#!/usr/bin/env bash
# Project:           Kus' modded Counter Strike 2 (CS2) Dedicated Server - https://github.com/kus/cs2-modded-server/
# Update script for: CS2 Deathmatch
# README row:        [CS2 Deathmatch](https://github.com/NockyCZ/CS2-Deathmatch)
# Sourced by scripts/update/update.sh - do not run directly.
#
# Process (reconstructed from the "UPDATED: CS2 Deathmatch" commits, e.g. 1.3.4 > 1.3.4a):
#   1. Download the release zip - it is always just called Deathmatch.zip (tags look like v1.3.4a)
#   2. Extract it; the archive root is Deathmatch/ with plugins/ and shared/ inside. Replace:
#        <extracted>/Deathmatch/plugins/Deathmatch    -> game/csgo/addons/counterstrikesharp/plugins/disabled/Deathmatch
#        <extracted>/Deathmatch/shared/DeathmatchAPI  -> game/csgo/addons/counterstrikesharp/shared/DeathmatchAPI
#      (both folders in the repo are byte-identical to the release, so they are replaced whole)
#   3. Delete the extracted folder
#
# Not touched: game/csgo/addons/counterstrikesharp/configs/plugins/Deathmatch/Deathmatch.json
# (customised, the release does not ship it) and gamedata/Deathmatch.json (not shipped either).

PLUGIN_PATHS=(
    "game/csgo/addons/counterstrikesharp/plugins/disabled/Deathmatch"
    "game/csgo/addons/counterstrikesharp/shared/DeathmatchAPI"
)

plugin_assets() {
    echo "Deathmatch.zip"
}

plugin_preflight() {
    require_dir "game/csgo/addons/counterstrikesharp/plugins/disabled/Deathmatch"
    require_dir "game/csgo/addons/counterstrikesharp/shared/DeathmatchAPI"
}

plugin_apply() {
    local x
    x=$(extract_asset "Deathmatch.zip")

    require_file "$x/Deathmatch/plugins/Deathmatch/Deathmatch.dll"
    require_dir  "$x/Deathmatch/plugins/Deathmatch/spawns"
    require_file "$x/Deathmatch/shared/DeathmatchAPI/DeathmatchAPI.dll"

    remove_path "game/csgo/addons/counterstrikesharp/plugins/disabled/Deathmatch"
    remove_path "game/csgo/addons/counterstrikesharp/shared/DeathmatchAPI"
    copy_dir "$x/Deathmatch/plugins/Deathmatch"   "game/csgo/addons/counterstrikesharp/plugins/disabled/Deathmatch"
    copy_dir "$x/Deathmatch/shared/DeathmatchAPI" "game/csgo/addons/counterstrikesharp/shared/DeathmatchAPI"

    remove_extracted "$x"
}
