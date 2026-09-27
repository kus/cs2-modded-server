#!/usr/bin/env bash
# Project:           Kus' modded Counter Strike 2 (CS2) Dedicated Server - https://github.com/kus/cs2-modded-server/
# Update script for: CS2 Retakes
# README row:        [CS2 Retakes](https://github.com/B3none/cs2-retakes)
# Sourced by scripts/update/update.sh - do not run directly.
#
# Manual process this automates:
#   1. Download the latest full release zip from GitHub, e.g. RetakesPlugin-3.1.1.zip
#      (NOT the "-no-map-configs" variant the release also ships)
#   2. Extract it
#   3. Delete the RetakesPlugin plugin folder and the RetakesPluginShared shared folder in the repo
#   4. Copy <extracted>/addons/counterstrikesharp/plugins/RetakesPlugin -> the plugin folder in the repo
#      Copy <extracted>/addons/counterstrikesharp/shared/RetakesPluginShared -> game/csgo/addons/counterstrikesharp/shared/RetakesPluginShared
#   5. Delete the extracted folder
#
# NOTE: in this repo the plugin is kept DISABLED by default, so it lives at
# game/csgo/addons/counterstrikesharp/plugins/disabled/RetakesPlugin (not plugins/RetakesPlugin).
# Every previous "UPDATED: CS2 Retakes" commit changed that path, so that is what is used here.

PLUGIN_PATHS=(
    "game/csgo/addons/counterstrikesharp/plugins/disabled/RetakesPlugin"
    "game/csgo/addons/counterstrikesharp/shared/RetakesPluginShared"
)

plugin_assets() {
    echo "RetakesPlugin-${NEW_VERSION}.zip"
}

plugin_preflight() {
    require_dir "game/csgo/addons/counterstrikesharp/plugins/disabled"
    require_dir "game/csgo/addons/counterstrikesharp/shared"
}

plugin_apply() {
    local x
    x=$(extract_asset "RetakesPlugin-*.zip")

    require_dir "$x/addons/counterstrikesharp/plugins/RetakesPlugin"
    require_dir "$x/addons/counterstrikesharp/plugins/RetakesPlugin/map_config"
    require_dir "$x/addons/counterstrikesharp/shared/RetakesPluginShared"

    remove_path "game/csgo/addons/counterstrikesharp/plugins/disabled/RetakesPlugin"
    remove_path "game/csgo/addons/counterstrikesharp/shared/RetakesPluginShared"

    copy_dir "$x/addons/counterstrikesharp/plugins/RetakesPlugin" \
             "game/csgo/addons/counterstrikesharp/plugins/disabled/RetakesPlugin"
    copy_dir "$x/addons/counterstrikesharp/shared/RetakesPluginShared" \
             "game/csgo/addons/counterstrikesharp/shared/RetakesPluginShared"

    remove_extracted "$x"
}
