#!/usr/bin/env bash
# Project:           Kus' modded Counter Strike 2 (CS2) Dedicated Server - https://github.com/kus/cs2-modded-server/
# Update script for: jRandomSkills
# README row:        [jRandomSkills](https://github.com/Juzlus/jRandomSkills)
# Sourced by scripts/update/update.sh - do not run directly.
#
# Process (derived from the version-bump commits by Vinicius Trevisan: c6f2918d, 2870ad55,
# 80a5c94d, 79c0cbc5, a455e6a0, 47ede6d0, 0ff6f7e6, 5f8ba4b6, and from the v1.2.4.b3 archive):
#   1. Download the release zip, named jRandomSkills.v<version>.zip
#   2. Extract it. The archive is laid out relative to addons/counterstrikesharp/:
#        plugins/jRandomSkills/                plugin, its configs, languages and packages
#        gamedata/jRandomSkills.gamedata.json  the signatures
#   3. Replace game/csgo/addons/counterstrikesharp/plugins/disabled/jRandomSkills whole, and
#      copy the gamedata over game/csgo/addons/counterstrikesharp/gamedata/.
#   4. Delete the extracted folder
#
# The plugin is kept under plugins/disabled/ in this repo; it is switched on per game mode.
#
# configs/config.json and configs/skillsInfo.json are NOT customised here: both are
# byte-identical to the release, and since the folder was renamed from !jRandomSkills in
# 4163c6bd every change to them has come from a version bump. So they are upstream-owned and
# replaced, like the languages/ and packages/ files. The pre-rename "improvements" commits
# (c6829731, 2703895d) predate that and are not customisations of the current paths.
#
# Replace-whole, not merge, because the manual history deletes files when a release stops
# shipping them (a455e6a0 dropped jRandomSkills.pdb) and adds them back when it resumes
# (47ede6d0). Note the repo currently carries WASDMenuAPI.pdb and jRandomSkills.pdb, which
# v1.2.4.b3 does not ship, so the first run that applies an update will drop both.
#
# Release versions look like v1.2.4.b3, so NEW_VERSION is the bare 1.2.4.b3 after the usual
# normalisation. The README table must hold the bare form too: a leading "v" there never
# compares equal to the detected version and would report an update forever.

PLUGIN_PATHS=(
    "game/csgo/addons/counterstrikesharp/plugins/disabled/jRandomSkills"
    "game/csgo/addons/counterstrikesharp/gamedata/jRandomSkills.gamedata.json"
)

plugin_assets() {
    echo "jRandomSkills.v${NEW_VERSION}.zip"
}

plugin_preflight() {
    require_dir  "game/csgo/addons/counterstrikesharp/plugins/disabled/jRandomSkills"
    require_dir  "game/csgo/addons/counterstrikesharp/gamedata"
    require_file "game/csgo/addons/counterstrikesharp/gamedata/jRandomSkills.gamedata.json"
}

plugin_apply() {
    local x
    x=$(extract_asset "jRandomSkills.v*.zip")

    require_file "$x/plugins/jRandomSkills/jRandomSkills.dll"
    require_dir  "$x/plugins/jRandomSkills/configs"
    require_dir  "$x/plugins/jRandomSkills/languages"
    require_file "$x/gamedata/jRandomSkills.gamedata.json"

    remove_path "game/csgo/addons/counterstrikesharp/plugins/disabled/jRandomSkills"
    remove_path "game/csgo/addons/counterstrikesharp/gamedata/jRandomSkills.gamedata.json"

    copy_dir  "$x/plugins/jRandomSkills" \
              "game/csgo/addons/counterstrikesharp/plugins/disabled/jRandomSkills"
    copy_file "$x/gamedata/jRandomSkills.gamedata.json" \
              "game/csgo/addons/counterstrikesharp/gamedata/jRandomSkills.gamedata.json"

    remove_extracted "$x"
}
