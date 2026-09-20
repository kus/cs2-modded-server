#!/usr/bin/env bash
# Project:           Kus' modded Counter Strike 2 (CS2) Dedicated Server - https://github.com/kus/cs2-modded-server/
# Update script for: Metamod:Source
# README row:        [Metamod:Source](https://www.metamodsource.net/downloads.php?branch=dev)
# Sourced by scripts/update/update.sh - do not run directly.
#
# Manual process this automates:
#   1. Download the pinned (latest) Windows zip and Linux tar.gz from the dev downloads page
#      e.g. mmsource-2.0.0-git1469-windows.zip, mmsource-2.0.0-git1469-linux.tar.gz
#   2. Extract Windows, rsync <extracted>/addons/ -> game/csgo/addons/, delete the extracted folder
#   3. Extract Linux,   rsync <extracted>/addons/ -> game/csgo/addons/, delete the extracted folder
#
# Windows MUST be applied before Linux: both archives ship addons/metamod.vdf,
# addons/metamod_x64.vdf, addons/metamod/metaplugins.ini and addons/metamod/README.txt.
# The Windows copies have CRLF line endings and point metamod_x64.vdf at bin/win64; the
# Linux copies (applied last) are the ones the repo keeps. The Windows-specific
# metamod_x64.vdf lives in game/csgo/addons/windows/addons/ and is not touched here.

PLUGIN_PATHS=(
    "game/csgo/addons/metamod"
    "game/csgo/addons/metamod.vdf"
    "game/csgo/addons/metamod_x64.vdf"
)

plugin_assets() {
    echo "mmsource-*-windows.zip"
    echo "mmsource-*-linux.tar.gz"
}

plugin_preflight() {
    require_dir  "game/csgo/addons/metamod/bin"
    require_file "game/csgo/addons/metamod.vdf"
    require_file "game/csgo/addons/metamod_x64.vdf"
}

plugin_apply() {
    local win linux
    win=$(extract_asset "mmsource-*-windows.zip")
    linux=$(extract_asset "mmsource-*-linux.tar.gz")

    # verify the archives look like Metamod before touching the repo
    require_dir  "$win/addons/metamod/bin"
    require_file "$win/addons/metamod_x64.vdf"
    require_dir  "$linux/addons/metamod/bin"
    require_file "$linux/addons/metamod_x64.vdf"

    # Windows first
    sync_dir "$win/addons/" "game/csgo/addons/"
    remove_extracted "$win"

    # then Linux
    sync_dir "$linux/addons/" "game/csgo/addons/"
    remove_extracted "$linux"
}
