#!/usr/bin/env bash
# Project:           Kus' modded Counter Strike 2 (CS2) Dedicated Server - https://github.com/kus/cs2-modded-server/
# Update script for: deathrun-manager
# README row:        [deathrun-manager](https://github.com/leoskiline/cs2-deathrun-manager)
# Sourced by scripts/update/update.sh - do not run directly.
#
# Process (reconstructed from the "UPDATED: deathrun-manager" commits, e.g. 0.1.0 > 0.5.0):
#   1. Download the release zip, e.g. cs2-deathrun-manager-0.5.1.zip (tags look like V0.5.1)
#   2. Extract it. Replace
#        <extracted>/plugins/DeathrunManager -> game/csgo/addons/counterstrikesharp/plugins/disabled/DeathrunManager
#      The archive's README-ME.txt and logs/ are ignored.
#   3. Delete the extracted folder
#
# The release also ships configs/plugins/DeathrunManager/DeathrunManager.json. The 0.5.0 manual
# update copied it over the repo's copy (which is still the stock upstream one), but by policy
# config files are never written by these scripts: it is only compared and new upstream
# settings are reported for a manual port.

PLUGIN_PATHS=(
    "game/csgo/addons/counterstrikesharp/plugins/disabled/DeathrunManager"
)

plugin_assets() {
    echo "cs2-deathrun-manager-${NEW_VERSION}.zip"
}

plugin_preflight() {
    require_dir  "game/csgo/addons/counterstrikesharp/plugins/disabled/DeathrunManager"
    require_file "game/csgo/addons/counterstrikesharp/configs/plugins/DeathrunManager/DeathrunManager.json"
}

plugin_apply() {
    local x
    x=$(extract_asset "cs2-deathrun-manager-*.zip")

    require_file "$x/plugins/DeathrunManager/DeathrunManager.dll"
    require_file "$x/configs/plugins/DeathrunManager/DeathrunManager.json"

    remove_path "game/csgo/addons/counterstrikesharp/plugins/disabled/DeathrunManager"
    copy_dir "$x/plugins/DeathrunManager" "game/csgo/addons/counterstrikesharp/plugins/disabled/DeathrunManager"

    # heads-up only: the config is never written
    warn_new_settings "$x/configs/plugins/DeathrunManager/DeathrunManager.json" \
                      "game/csgo/addons/counterstrikesharp/configs/plugins/DeathrunManager/DeathrunManager.json"

    remove_extracted "$x"
}
