#!/usr/bin/env bash
# Project:           Kus' modded Counter Strike 2 (CS2) Dedicated Server - https://github.com/kus/cs2-modded-server/
# Update script for: CounterStrikeSharp
# README row:        [CounterStrikeSharp](https://github.com/roflmuffin/CounterStrikeSharp)
# Sourced by scripts/update/update.sh - do not run directly.
#
# Manual process this automates:
#   1. Download the latest "with-runtime" Windows and Linux zips from GitHub releases
#      e.g. counterstrikesharp-with-runtime-windows-1.0.374.zip / ...-linux-1.0.374.zip
#   2. Extract Windows, rsync <extracted>/addons/ -> game/csgo/addons/
#   3. (Windows special treatment) empty game/csgo/addons/windows/addons/counterstrikesharp/
#      then copy <extracted>/addons/counterstrikesharp/{api,bin,dotnet} into it
#   4. Delete the extracted Windows folder
#   5. Extract Linux, rsync <extracted>/addons/ -> game/csgo/addons/, delete the extracted folder
#
# Windows MUST be applied before Linux so the Linux runtime/binaries end up on top in
# game/csgo/addons/counterstrikesharp/ (bin/win64 from Windows + bin/linuxsteamrt64 from Linux).

PLUGIN_PATHS=(
    "game/csgo/addons/counterstrikesharp"
    "game/csgo/addons/metamod/counterstrikesharp.vdf"
    "game/csgo/addons/windows/addons/counterstrikesharp"
)

plugin_assets() {
    echo "counterstrikesharp-with-runtime-windows-${NEW_VERSION}.zip"
    echo "counterstrikesharp-with-runtime-linux-${NEW_VERSION}.zip"
}

plugin_preflight() {
    require_dir  "game/csgo/addons/counterstrikesharp/api"
    require_dir  "game/csgo/addons/counterstrikesharp/bin"
    require_dir  "game/csgo/addons/counterstrikesharp/dotnet"
    require_file "game/csgo/addons/metamod/counterstrikesharp.vdf"
    require_dir  "game/csgo/addons/windows/addons/counterstrikesharp"
}

plugin_apply() {
    local win linux
    win=$(extract_asset "counterstrikesharp-with-runtime-windows-*.zip")
    linux=$(extract_asset "counterstrikesharp-with-runtime-linux-*.zip")

    # verify the archives look like CounterStrikeSharp before touching the repo
    require_dir  "$win/addons/counterstrikesharp/api"
    require_dir  "$win/addons/counterstrikesharp/bin"
    require_dir  "$win/addons/counterstrikesharp/dotnet"
    require_file "$win/addons/metamod/counterstrikesharp.vdf"
    require_dir  "$linux/addons/counterstrikesharp/api"
    require_dir  "$linux/addons/counterstrikesharp/bin"
    require_dir  "$linux/addons/counterstrikesharp/dotnet"

    # Windows first
    sync_dir "$win/addons/" "game/csgo/addons/"
    empty_dir "game/csgo/addons/windows/addons/counterstrikesharp"
    copy_dir "$win/addons/counterstrikesharp/api"    "game/csgo/addons/windows/addons/counterstrikesharp/api"
    copy_dir "$win/addons/counterstrikesharp/bin"    "game/csgo/addons/windows/addons/counterstrikesharp/bin"
    copy_dir "$win/addons/counterstrikesharp/dotnet" "game/csgo/addons/windows/addons/counterstrikesharp/dotnet"
    remove_extracted "$win"

    # then Linux
    sync_dir "$linux/addons/" "game/csgo/addons/"
    remove_extracted "$linux"
}
