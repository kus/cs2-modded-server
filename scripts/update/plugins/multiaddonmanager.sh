#!/usr/bin/env bash
# Project:           Kus' modded Counter Strike 2 (CS2) Dedicated Server - https://github.com/kus/cs2-modded-server/
# Update script for: MultiAddonManager
# README row:        [MultiAddonManager](https://github.com/Source2ZE/MultiAddonManager)
# Sourced by scripts/update/update.sh - do not run directly.
#
# Manual process this automates:
#   1. Download the latest Windows zip and Linux steamrt3 tar.gz from GitHub releases
#      e.g. MultiAddonManager-v1.6-windows.zip, MultiAddonManager-v1.6-steamrt3.tar.gz
#      (the release also ships a steamrt4 build - not used)
#   2. Extract Windows, replace game/csgo/addons/multiaddonmanager/bin/multiaddonmanager.dll
#      with <extracted>/addons/multiaddonmanager/bin/multiaddonmanager.dll, delete the extracted folder
#   3. Extract Linux, replace game/csgo/addons/multiaddonmanager/bin/multiaddonmanager.so
#      with <extracted>/addons/multiaddonmanager/bin/multiaddonmanager.so, delete the extracted folder
#
# Only the two binaries are taken. The archives also ship addons/metamod/multiaddonmanager.vdf
# and cfg/multiaddonmanager/multiaddonmanager.cfg; the repo keeps its own copies of those
# (game/csgo/addons/multiaddonmanager/multiaddonmanager.vdf, game/csgo/cfg/multiaddonmanager/)
# and they are deliberately not touched. The customised cfg is only compared against the
# release's copy and new upstream settings are reported for a manual port.

PLUGIN_PATHS=(
    "game/csgo/addons/multiaddonmanager/bin/multiaddonmanager.dll"
    "game/csgo/addons/multiaddonmanager/bin/multiaddonmanager.so"
)

plugin_assets() {
    echo "MultiAddonManager-v${NEW_VERSION}-windows.zip"
    echo "MultiAddonManager-v${NEW_VERSION}-steamrt3.tar.gz"
}

plugin_preflight() {
    require_file "game/csgo/addons/multiaddonmanager/bin/multiaddonmanager.dll"
    require_file "game/csgo/addons/multiaddonmanager/bin/multiaddonmanager.so"
}

plugin_apply() {
    local win linux
    win=$(extract_asset "MultiAddonManager-v*-windows.zip")
    linux=$(extract_asset "MultiAddonManager-v*-steamrt3.tar.gz")

    require_file "$win/addons/multiaddonmanager/bin/multiaddonmanager.dll"
    require_file "$linux/addons/multiaddonmanager/bin/multiaddonmanager.so"
    require_file "$linux/cfg/multiaddonmanager/multiaddonmanager.cfg"

    # Windows first
    remove_path "game/csgo/addons/multiaddonmanager/bin/multiaddonmanager.dll"
    copy_file   "$win/addons/multiaddonmanager/bin/multiaddonmanager.dll" \
                "game/csgo/addons/multiaddonmanager/bin/multiaddonmanager.dll"
    remove_extracted "$win"

    # then Linux
    remove_path "game/csgo/addons/multiaddonmanager/bin/multiaddonmanager.so"
    copy_file   "$linux/addons/multiaddonmanager/bin/multiaddonmanager.so" \
                "game/csgo/addons/multiaddonmanager/bin/multiaddonmanager.so"

    # heads-up only: the customised cfg is never written
    warn_new_settings "$linux/cfg/multiaddonmanager/multiaddonmanager.cfg" "game/csgo/cfg/multiaddonmanager/multiaddonmanager.cfg"
    remove_extracted "$linux"
}
