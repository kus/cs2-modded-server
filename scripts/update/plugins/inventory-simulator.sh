#!/usr/bin/env bash
# Project:           Kus' modded Counter Strike 2 (CS2) Dedicated Server - https://github.com/kus/cs2-modded-server/
# Update script for: Inventory Simulator
# README row:        [Inventory Simulator](https://github.com/ianlucas/cs2-css-inventory-simulator)
# Sourced by scripts/update/update.sh - do not run directly.
#
# Manual process this automates:
#   1. Download the latest release zip from GitHub, e.g. InventorySimulator-v3.1.1.zip
#   2. Extract it
#   3. Delete game/csgo/addons/counterstrikesharp/plugins/InventorySimulator/
#      and    game/csgo/addons/counterstrikesharp/gamedata/inventory-simulator.json
#   4. Copy <extracted>/addons/counterstrikesharp/plugins/InventorySimulator -> same path in the repo
#      Copy <extracted>/addons/counterstrikesharp/gamedata/inventory-simulator.json -> same path in the repo
#   5. Delete the extracted folder

PLUGIN_PATHS=(
    "game/csgo/addons/counterstrikesharp/plugins/InventorySimulator"
    "game/csgo/addons/counterstrikesharp/gamedata/inventory-simulator.json"
)

plugin_assets() {
    echo "InventorySimulator-v${NEW_VERSION}.zip"
}

plugin_preflight() {
    require_dir "game/csgo/addons/counterstrikesharp/plugins"
    require_dir "game/csgo/addons/counterstrikesharp/gamedata"
}

plugin_apply() {
    local x
    x=$(extract_asset "InventorySimulator-v*.zip")

    require_dir  "$x/addons/counterstrikesharp/plugins/InventorySimulator"
    require_file "$x/addons/counterstrikesharp/gamedata/inventory-simulator.json"

    remove_path "game/csgo/addons/counterstrikesharp/plugins/InventorySimulator"
    remove_path "game/csgo/addons/counterstrikesharp/gamedata/inventory-simulator.json"

    copy_dir  "$x/addons/counterstrikesharp/plugins/InventorySimulator" \
              "game/csgo/addons/counterstrikesharp/plugins/InventorySimulator"
    copy_file "$x/addons/counterstrikesharp/gamedata/inventory-simulator.json" \
              "game/csgo/addons/counterstrikesharp/gamedata/inventory-simulator.json"

    remove_extracted "$x"
}
