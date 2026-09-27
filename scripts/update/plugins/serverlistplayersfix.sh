#!/usr/bin/env bash
# Project:           Kus' modded Counter Strike 2 (CS2) Dedicated Server - https://github.com/kus/cs2-modded-server/
# Update script for: ServerListPlayersFix
# README row:        [ServerListPlayersFix](https://github.com/Source2ZE/ServerListPlayersFix)
# Sourced by scripts/update/update.sh - do not run directly.
#
# Manual process this automates:
#   1. Download the latest Windows zip and Linux steamrt3 tar.gz from GitHub releases
#      e.g. ServerListPlayersFix-v2.0-windows.zip, ServerListPlayersFix-v2.0-steamrt3.tar.gz
#      (the release also ships a steamrt4 build - not used)
#   2. Extract Windows, replace game/csgo/addons/serverlistplayersfix_mm/bin/win64/serverlistplayersfix_mm.dll
#      with the same file from <extracted>/addons/..., delete the extracted folder
#   3. Extract Linux, replace game/csgo/addons/serverlistplayersfix_mm/bin/linuxsteamrt64/serverlistplayersfix_mm.so
#      with the same file from <extracted>/addons/..., delete the extracted folder
#
# Only the two binaries are taken. The archives also ship addons/metamod/serverlistplayersfix_mm.vdf;
# the repo keeps its own per-platform copies (game/csgo/addons/metamod/ for Linux,
# game/csgo/addons/windows/addons/metamod/ for Windows) and they are deliberately not touched.

PLUGIN_PATHS=(
    "game/csgo/addons/serverlistplayersfix_mm/bin/win64/serverlistplayersfix_mm.dll"
    "game/csgo/addons/serverlistplayersfix_mm/bin/linuxsteamrt64/serverlistplayersfix_mm.so"
)

plugin_assets() {
    echo "ServerListPlayersFix-v${NEW_VERSION}-windows.zip"
    echo "ServerListPlayersFix-v${NEW_VERSION}-steamrt3.tar.gz"
}

plugin_preflight() {
    require_file "game/csgo/addons/serverlistplayersfix_mm/bin/win64/serverlistplayersfix_mm.dll"
    require_file "game/csgo/addons/serverlistplayersfix_mm/bin/linuxsteamrt64/serverlistplayersfix_mm.so"
}

plugin_apply() {
    local win linux
    win=$(extract_asset "ServerListPlayersFix-v*-windows.zip")
    linux=$(extract_asset "ServerListPlayersFix-v*-steamrt3.tar.gz")

    require_file "$win/addons/serverlistplayersfix_mm/bin/win64/serverlistplayersfix_mm.dll"
    require_file "$linux/addons/serverlistplayersfix_mm/bin/linuxsteamrt64/serverlistplayersfix_mm.so"

    # Windows first
    remove_path "game/csgo/addons/serverlistplayersfix_mm/bin/win64/serverlistplayersfix_mm.dll"
    copy_file   "$win/addons/serverlistplayersfix_mm/bin/win64/serverlistplayersfix_mm.dll" \
                "game/csgo/addons/serverlistplayersfix_mm/bin/win64/serverlistplayersfix_mm.dll"
    remove_extracted "$win"

    # then Linux
    remove_path "game/csgo/addons/serverlistplayersfix_mm/bin/linuxsteamrt64/serverlistplayersfix_mm.so"
    copy_file   "$linux/addons/serverlistplayersfix_mm/bin/linuxsteamrt64/serverlistplayersfix_mm.so" \
                "game/csgo/addons/serverlistplayersfix_mm/bin/linuxsteamrt64/serverlistplayersfix_mm.so"
    remove_extracted "$linux"
}
