#!/usr/bin/env bash
# Project:           Kus' modded Counter Strike 2 (CS2) Dedicated Server - https://github.com/kus/cs2-modded-server/
# Update script for: CS2-FixRandomSpawn
# README row:        [CS2-FixRandomSpawn](https://github.com/qstage/CS2-FixRandomSpawn)
# Sourced by scripts/update/update.sh - do not run directly.
#
# Process (derived from the four commits that touch this mod: 1a95694d, 807ee506,
# 08e48f15, 63e067b9, and from the 1.1.4.1 and 1.2.0 archives):
#   1. Download the release zip. In 1.2.0 it is CS2-FixRandomSpawn.zip; up to 1.1.4.1 it
#      was FixRandomSpawn.zip, so the name is pinned rather than globbed loosely.
#   2. Extract it. The 1.2.0 archive is laid out relative to addons/counterstrikesharp/:
#        plugins/FixRandomSpawn/        the plugin itself
#        gamedata/FixRandomSpawn.json   the signatures
#   3. Replace game/csgo/addons/counterstrikesharp/plugins/FixRandomSpawn whole, and copy
#      gamedata/FixRandomSpawn.json over game/csgo/addons/counterstrikesharp/gamedata/.
#   4. Delete the extracted folder
#
# The plugin is NOT under plugins/disabled/ - this one runs by default.
#
# The gamedata is upstream-owned signature data, not a customised config, so it is
# replaced like CounterStrikeSharp's gamedata.json and Inventory Simulator's gamedata.
# It has to move in step with the dll: 1.2.0 renamed its keys from EntSelectSpawnPoint to
# CCSPlayerPawn_EntSelectSpawnPoint, so an old gamedata with a new dll would not work.
# Commit 08e48f15 hand-patched the repo copy with signatures from an upstream commit that
# had not been released yet; a release now supersedes that, which is the same thing that
# happened to the hand-patched CounterStrikeSharp gamedata in adc43d3d.
#
# Up to 1.1.4.1 the archive was flat (the plugin's own files at the archive root, with
# gamedata/ inside it), which is why the repo carried a stale
# plugins/FixRandomSpawn/gamedata/FixRandomSpawn.json. 1.2.0 does not ship one there, and
# replacing the plugin folder whole removes it. That older flat layout is not supported:
# it needs different copy logic, so if the archive changes again this fails loudly.
#
# Not shipped and not touched: there is no configs/plugins/FixRandomSpawn in this repo.

PLUGIN_PATHS=(
    "game/csgo/addons/counterstrikesharp/plugins/FixRandomSpawn"
    "game/csgo/addons/counterstrikesharp/gamedata/FixRandomSpawn.json"
)

plugin_assets() {
    echo "CS2-FixRandomSpawn.zip"
}

plugin_preflight() {
    require_dir  "game/csgo/addons/counterstrikesharp/plugins/FixRandomSpawn"
    require_dir  "game/csgo/addons/counterstrikesharp/gamedata"
    require_file "game/csgo/addons/counterstrikesharp/gamedata/FixRandomSpawn.json"
}

plugin_apply() {
    local x
    x=$(extract_asset "CS2-FixRandomSpawn.zip")

    require_file "$x/plugins/FixRandomSpawn/FixRandomSpawn.dll"
    require_dir  "$x/plugins/FixRandomSpawn/lang"
    require_file "$x/gamedata/FixRandomSpawn.json"

    remove_path "game/csgo/addons/counterstrikesharp/plugins/FixRandomSpawn"
    remove_path "game/csgo/addons/counterstrikesharp/gamedata/FixRandomSpawn.json"

    copy_dir  "$x/plugins/FixRandomSpawn" \
              "game/csgo/addons/counterstrikesharp/plugins/FixRandomSpawn"
    copy_file "$x/gamedata/FixRandomSpawn.json" \
              "game/csgo/addons/counterstrikesharp/gamedata/FixRandomSpawn.json"

    remove_extracted "$x"
}
