#!/usr/bin/env bash
# Project:           Kus' modded Counter Strike 2 (CS2) Dedicated Server - https://github.com/kus/cs2-modded-server/
# Update script for: CS2 Deathmatch
# README row:        [CS2 Deathmatch](https://github.com/NockyCZ/CS2-Deathmatch)
# Sourced by scripts/update/update.sh - do not run directly.
#
# Process (reconstructed from the "UPDATED: CS2 Deathmatch" commits, e.g. 1.3.4 > 1.3.4a):
#   1. Download the release zip - it is always just called Deathmatch.zip (tags look like v1.3.4a)
#   2. Extract it and replace, from the archive root:
#        <root>/plugins/Deathmatch    -> game/csgo/addons/counterstrikesharp/plugins/disabled/Deathmatch
#        <root>/shared/DeathmatchAPI  -> game/csgo/addons/counterstrikesharp/shared/DeathmatchAPI
#      (both folders in the repo are byte-identical to the release, so they are replaced whole)
#   3. Delete the extracted folder
#
# The archive root moved in 1.3.6: up to 1.3.5 it was Deathmatch/, from 1.3.6 it is the
# standard addons/counterstrikesharp/. The file names inside are unchanged. Both layouts
# are accepted so either can be re-run; a third layout fails loudly in pick_dir.
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
    local x root
    x=$(extract_asset "Deathmatch.zip")
    # 1.3.6 and newer first, then the pre-1.3.6 layout.
    root=$(pick_dir "$x/addons/counterstrikesharp" "$x/Deathmatch")

    require_file "$root/plugins/Deathmatch/Deathmatch.dll"
    require_dir  "$root/plugins/Deathmatch/spawns"
    require_file "$root/shared/DeathmatchAPI/DeathmatchAPI.dll"

    remove_path "game/csgo/addons/counterstrikesharp/plugins/disabled/Deathmatch"
    remove_path "game/csgo/addons/counterstrikesharp/shared/DeathmatchAPI"
    copy_dir "$root/plugins/Deathmatch"   "game/csgo/addons/counterstrikesharp/plugins/disabled/Deathmatch"
    copy_dir "$root/shared/DeathmatchAPI" "game/csgo/addons/counterstrikesharp/shared/DeathmatchAPI"

    remove_extracted "$x"
}
