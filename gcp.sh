#!/usr/bin/env bash

# Install
# As root (sudo su)
# cd / && curl --silent --output "gcp.sh" "https://raw.githubusercontent.com/kus/cs2-modded-server/csgo/gcp.sh" && chmod +x gcp.sh && bash gcp.sh

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
META_API_KEY=$(get_metadata API_KEY)
META_MOD_URL=$(get_metadata MOD_URL)
META_PORT=$(get_metadata PORT)
META_TICKRATE=$(get_metadata TICKRATE)
META_MAXPLAYERS=$(get_metadata MAXPLAYERS)
export RCON_PASSWORD="${META_RCON_PASSWORD:-changeme}"
export API_KEY="${META_API_KEY:-changeme}"
export STEAM_ACCOUNT="${STEAM_ACCOUNT:-$(get_metadata STEAM_ACCOUNT)}"
export MOD_URL="${META_MOD_URL:-https://github.com/kus/cs2-modded-server/archive/csgo.zip}"
export SERVER_PASSWORD="${SERVER_PASSWORD:-$(get_metadata SERVER_PASSWORD)}"
export PORT="${META_PORT:-27015}"
export TICKRATE="${META_TICKRATE:-128}"
export MAXPLAYERS="${META_MAXPLAYERS:-32}"
export DUCK_DOMAIN="${DUCK_DOMAIN:-$(get_metadata DUCK_DOMAIN)}"
export DUCK_TOKEN="${DUCK_TOKEN:-$(get_metadata DUCK_TOKEN)}"
export CUSTOM_FOLDER="${CUSTOM_FOLDER:-$(get_metadata CUSTOM_FOLDER)}"

cd /

# Update DuckDNS with our current IP
if [ ! -z "$DUCK_TOKEN" ]; then
    echo url="http://www.duckdns.org/update?domains=$DUCK_DOMAIN&token=$DUCK_TOKEN&ip=$(dig +short myip.opendns.com @resolver1.opendns.com)" | curl -k -o /duck.log -K -
fi

# Download latest installer
curl --silent --output "install.sh" "https://raw.githubusercontent.com/kus/cs2-modded-server/csgo/install.sh" && chmod +x install.sh

# Run
bash install.sh |& tee /install.log
