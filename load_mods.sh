#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

# CONFIGURATION
REPO_URL="https://github.com/beladevo/cs2-modded-server"
BRANCH="${BRANCH:-master}"
USER="${user:-steam}"
CS2_HOME="/home/${USER}/cs2"
REPO_ZIP="${BRANCH}.zip"
TMP_DIR="/tmp/cs2_mod_tmp"
CUSTOM_FOLDER="${CUSTOM_FOLDER:-custom_files}"

# 1. CLEANUP OLD MOD DATA
echo "[MOD-LOADER] Cleaning previous addons and settings..."
rm -rf "${CS2_HOME}/game/csgo/addons"
rm -rf "${CS2_HOME}/game/csgo/cfg/settings"

# 2. DOWNLOAD AND EXTRACT MOD FILES
echo "[MOD-LOADER] Downloading latest mod branch: ${BRANCH} ..."
mkdir -p "$TMP_DIR"
cd "$TMP_DIR"

wget -q "${REPO_URL}/archive/${REPO_ZIP}" -O "${REPO_ZIP}"
unzip -o -qq "${REPO_ZIP}"

REPO_FOLDER="cs2-modded-server-${BRANCH}"

# 3. REMOVE PREVIOUS EXAMPLE CUSTOM FILES
echo "[MOD-LOADER] Resetting example custom_files..."
rm -rf "${CS2_HOME}/custom_files_example/"
cp -R "${REPO_FOLDER}/custom_files_example/" "${CS2_HOME}/custom_files_example/"

# 4. MERGE GAME FILES
echo "[MOD-LOADER] Merging core game mod files..."
cp -R "${REPO_FOLDER}/game/csgo/" "${CS2_HOME}/game/"

# 5. MERGE CUSTOM FILES
echo "[MOD-LOADER] Syncing custom files from repository..."
if [ ! -d "${CS2_HOME}/custom_files/" ]; then
    cp -R "${REPO_FOLDER}/custom_files/" "${CS2_HOME}/custom_files/"
else
    cp -RT "${REPO_FOLDER}/custom_files/" "${CS2_HOME}/custom_files/"
fi

# 6. COPY CUSTOM FILES INTO GAME DIR
echo "[MOD-LOADER] Injecting active custom files (${CUSTOM_FOLDER}) into game directory..."
cp -RT "${CS2_HOME}/${CUSTOM_FOLDER}/" "${CS2_HOME}/game/csgo/"

# 7. SET OWNERSHIP TO USER
echo "[MOD-LOADER] Fixing ownership..."
chown -R "${USER}:${USER}" "${CS2_HOME}"

# 8. CLEAN TMP
echo "[MOD-LOADER] Cleaning temporary files..."
rm -rf "$TMP_DIR"

echo "[MOD-LOADER] ✅ Mods loaded successfully for branch: ${BRANCH}"
