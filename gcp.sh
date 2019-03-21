#!/usr/bin/env bash

# Install
# As root (sudo su)
# cd / && curl --silent --output "gcp.sh" "https://raw.githubusercontent.com/kus/csgo-modded-server/master/gcp.sh" && chmod +x gcp.sh && bash gcp.sh

METADATA_URL="${METADATA_URL:-http://metadata.google.internal/computeMetadata/v1/instance/attributes}"

get_metadata () {
    if [ -z "$1" ]
    then
        local result=""
    else
        local result=$(curl -s "$METADATA_URL/$1?alt=text" -H "Metadata-Flavor: Google")
		if [[ $result == *"<!DOCTYPE html>"* ]]; then
			result=""
		fi
    fi

    echo $result
}

# Get meta data from GCP and set environment variables
META_RCON_PASSWORD=$(get_metadata RCON_PASSWORD)
META_MOD_URL=$(get_metadata MOD_URL)
META_PORT=$(get_metadata PORT)
META_TICKRATE=$(get_metadata TICKRATE)
META_MAXPLAYERS=$(get_metadata MAXPLAYERS)
export LAN="${LAN:-$(get_metadata LAN)}"
export RCON_PASSWORD="${META_RCON_PASSWORD:-changeme}"
export STEAM_ACCOUNT="${STEAM_ACCOUNT:-$(get_metadata STEAM_ACCOUNT)}"
export FAST_DL_URL="${FAST_DL_URL:-$(get_metadata FAST_DL_URL)}"
export MOD_URL="${META_MOD_URL:-https://github.com/kus/csgo-modded-server/archive/master.zip}"
export SERVER_PASSWORD="${SERVER_PASSWORD:-$(get_metadata SERVER_PASSWORD)}"
export PORT="${META_PORT:-27015}"
export TICKRATE="${META_TICKRATE:-128}"
export MAXPLAYERS="${META_MAXPLAYERS:-32}"

cd /

# Download latest installer
curl --silent --output "install.sh" "https://raw.githubusercontent.com/kus/csgo-modded-server/master/install.sh" && chmod +x install.sh

# Run in a screen session
screen bash install.sh
