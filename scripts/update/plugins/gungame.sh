#!/usr/bin/env bash
# Project:           Kus' modded Counter Strike 2 (CS2) Dedicated Server - https://github.com/kus/cs2-modded-server/
# Update script for: GunGame
# README row:        [GunGame](https://github.com/ssypchenko/cs2-gungame)
# Sourced by scripts/update/update.sh - do not run directly.
#
# Process (reconstructed from the "UPDATED: GunGame" commits, e.g. 1.2.2 > 1.2.4):
#   1. Download the release zip, e.g. GG2.plugin.1.2.4.zip
#   2. Extract it and copy over (merge, nothing deleted):
#        <extracted>/csgo/addons/counterstrikesharp/plugins/GG2      -> game/csgo/addons/counterstrikesharp/plugins/disabled/GG2
#        <extracted>/csgo/addons/counterstrikesharp/shared/GunGameAPI -> game/csgo/addons/counterstrikesharp/shared/GunGameAPI
#      (the repo's GG2 folder still carries Dapper.dll and runtimes/ from older releases; the
#      manual updates never removed them, so this script does not either)
#   3. game/csgo/cfg/gungame/ is customised and is NEVER written by this script. The release's
#      csgo/cfg/gungame/ is only compared against it: new upstream files, files upstream no longer
#      ships, and new settings inside existing files are reported so they can be ported by hand.
#      (The manual updates did add/delete cfg files: 1.2.1 > 1.2.2 added gungame.gameend.cfg,
#      1.2.4 deleted gungame_weapons-small-for-tests.json - with this script those are manual steps.)
#   4. Delete the extracted folder

PLUGIN_PATHS=(
    "game/csgo/addons/counterstrikesharp/plugins/disabled/GG2"
    "game/csgo/addons/counterstrikesharp/shared/GunGameAPI"
)

plugin_assets() {
    echo "GG2.plugin.${NEW_VERSION}.zip"
}

plugin_preflight() {
    require_dir "game/csgo/addons/counterstrikesharp/plugins/disabled/GG2"
    require_dir "game/csgo/addons/counterstrikesharp/shared/GunGameAPI"
    require_dir "game/csgo/cfg/gungame"
}

plugin_apply() {
    local x
    x=$(extract_asset "GG2.plugin.*.zip")

    require_file "$x/csgo/addons/counterstrikesharp/plugins/GG2/GG2.dll"
    require_file "$x/csgo/addons/counterstrikesharp/shared/GunGameAPI/GunGameAPI.dll"
    require_dir  "$x/csgo/cfg/gungame"

    copy_dir "$x/csgo/addons/counterstrikesharp/plugins/GG2" \
             "game/csgo/addons/counterstrikesharp/plugins/disabled/GG2"
    copy_dir "$x/csgo/addons/counterstrikesharp/shared/GunGameAPI" \
             "game/csgo/addons/counterstrikesharp/shared/GunGameAPI"

    # heads-up only: the customised cfg/gungame is never written
    warn_cfg_dir_changes "$x/csgo/cfg/gungame" "game/csgo/cfg/gungame"

    remove_extracted "$x"
}
