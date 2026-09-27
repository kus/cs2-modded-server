#!/usr/bin/env bash
# Project:           Kus' modded Counter Strike 2 (CS2) Dedicated Server - https://github.com/kus/cs2-modded-server/
# Update script for: MatchZy
# README row:        [MatchZy](https://github.com/shobhit-pathak/MatchZy)
# Sourced by scripts/update/update.sh - do not run directly.
#
# Process (reconstructed from the "UPDATED: MatchZy" commits, e.g. 0.8.14 > 0.8.15):
#   1. Download the plain release zip, e.g. MatchZy-0.8.15.zip
#      (NOT the "-with-cssharp-linux/-windows" bundles the release also ships)
#   2. Extract it and copy <extracted>/addons/counterstrikesharp/plugins/MatchZy over
#      game/csgo/addons/counterstrikesharp/plugins/disabled/MatchZy (merge: existing files are
#      overwritten, nothing is deleted - the plugin is kept disabled by default in this repo)
#   3. Delete the extracted folder
#
# The release also ships cfg/MatchZy/*.cfg. The repo's game/csgo/cfg/MatchZy/ (and the copy in
# custom_files_example/cfg/MatchZy/) is customised, so it is NEVER overwritten here. When
# upstream added a new setting (0.8.12 > 0.8.13 added matchzy_demo_recording_enabled) it was
# merged into both customised copies by hand; this script only reports new upstream files/settings.
#
# Known quirk: the archive ships lang/pt-PT.json while the repo tracks lang/pt-pt.json. On the
# case-insensitive macOS filesystem (core.ignorecase=true) the copy just updates the tracked file.

PLUGIN_PATHS=(
    "game/csgo/addons/counterstrikesharp/plugins/disabled/MatchZy"
)

plugin_assets() {
    echo "MatchZy-${NEW_VERSION}.zip"
}

plugin_preflight() {
    require_dir  "game/csgo/addons/counterstrikesharp/plugins/disabled/MatchZy"
    require_file "game/csgo/cfg/MatchZy/config.cfg"
}

plugin_apply() {
    local x
    x=$(extract_asset "MatchZy-*.zip")

    require_dir  "$x/addons/counterstrikesharp/plugins/MatchZy"
    require_file "$x/addons/counterstrikesharp/plugins/MatchZy/MatchZy.dll"
    require_dir  "$x/cfg/MatchZy"

    copy_dir "$x/addons/counterstrikesharp/plugins/MatchZy" \
             "game/csgo/addons/counterstrikesharp/plugins/disabled/MatchZy"

    # heads-up only: the customised cfg/MatchZy copies are never written
    warn_cfg_dir_changes "$x/cfg/MatchZy" "game/csgo/cfg/MatchZy"
    warn_cfg_dir_changes "$x/cfg/MatchZy" "custom_files_example/cfg/MatchZy" existing-only

    remove_extracted "$x"
}
