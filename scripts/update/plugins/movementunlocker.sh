#!/usr/bin/env bash
# Project:           Kus' modded Counter Strike 2 (CS2) Dedicated Server - https://github.com/kus/cs2-modded-server/
# Update script for: MovementUnlocker
# README row:        [MovementUnlocker](https://github.com/Source2ZE/MovementUnlocker)
# Sourced by scripts/update/update.sh - do not run directly.
#
# Manual process this automates:
#   1. Download the latest Windows zip and Linux steamrt3 tar.gz from GitHub releases
#      e.g. MovementUnlocker-v2.0-windows.zip, MovementUnlocker-v2.0-steamrt3.tar.gz
#      (the release also ships a steamrt4 build - not used)
#   2. Extract Windows, replace game/csgo/addons/MovementUnlocker/bin/win64/MovementUnlocker.dll
#      with the same file from <extracted>/addons/..., delete the extracted folder
#   3. Extract Linux, replace game/csgo/addons/MovementUnlocker/bin/linuxsteamrt64/MovementUnlocker.so
#      with the same file from <extracted>/addons/..., delete the extracted folder
#
# Only the two binaries are taken. The archives also ship addons/metamod/MovementUnlocker.vdf;
# the repo keeps its own per-platform copies under game/csgo/addons/surf/{linux,windows}/
# (loaded on demand) and they are deliberately not touched.

PLUGIN_PATHS=(
    "game/csgo/addons/MovementUnlocker/bin/win64/MovementUnlocker.dll"
    "game/csgo/addons/MovementUnlocker/bin/linuxsteamrt64/MovementUnlocker.so"
)

plugin_assets() {
    echo "MovementUnlocker-v${NEW_VERSION}-windows.zip"
    echo "MovementUnlocker-v${NEW_VERSION}-steamrt3.tar.gz"
}

plugin_preflight() {
    require_file "game/csgo/addons/MovementUnlocker/bin/win64/MovementUnlocker.dll"
    require_file "game/csgo/addons/MovementUnlocker/bin/linuxsteamrt64/MovementUnlocker.so"
}

plugin_apply() {
    local win linux
    win=$(extract_asset "MovementUnlocker-v*-windows.zip")
    linux=$(extract_asset "MovementUnlocker-v*-steamrt3.tar.gz")

    require_file "$win/addons/MovementUnlocker/bin/win64/MovementUnlocker.dll"
    require_file "$linux/addons/MovementUnlocker/bin/linuxsteamrt64/MovementUnlocker.so"

    # Windows first
    remove_path "game/csgo/addons/MovementUnlocker/bin/win64/MovementUnlocker.dll"
    copy_file   "$win/addons/MovementUnlocker/bin/win64/MovementUnlocker.dll" \
                "game/csgo/addons/MovementUnlocker/bin/win64/MovementUnlocker.dll"
    remove_extracted "$win"

    # then Linux
    remove_path "game/csgo/addons/MovementUnlocker/bin/linuxsteamrt64/MovementUnlocker.so"
    copy_file   "$linux/addons/MovementUnlocker/bin/linuxsteamrt64/MovementUnlocker.so" \
                "game/csgo/addons/MovementUnlocker/bin/linuxsteamrt64/MovementUnlocker.so"
    remove_extracted "$linux"
}
