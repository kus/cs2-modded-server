#!/usr/bin/env bash

# As root (sudo su)
# cd / && curl -s -H "Cache-Control: no-cache" -o "run.sh" "https://raw.githubusercontent.com/kus/cs2-modded-server/master/run.sh" && chmod +x run.sh && bash run.sh

# Function to safely enable unprivileged user namespaces
enable_unprivileged_namespaces() {
    # Check if the sysctl parameter exists (some kernels don't have it)
    if ! sysctl kernel.unprivileged_userns_clone >/dev/null 2>&1; then
        echo "Info: kernel.unprivileged_userns_clone not available on this system"
        return 0
    fi
    
    # Check current value
    local current_value=$(sysctl -n kernel.unprivileged_userns_clone 2>/dev/null)
    
    if [ "$current_value" != "1" ]; then
        echo "Enabling unprivileged user namespaces..."
        if sudo sysctl kernel.unprivileged_userns_clone=1; then
            echo "Successfully enabled unprivileged user namespaces"
            return 0
        else
            echo "Warning: Failed to enable unprivileged user namespaces"
            return 1
        fi
    else
        echo "Unprivileged user namespaces already enabled"
        return 0
    fi
}

user="steam"
PUBLIC_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)

# 32 or 64 bit Operating System
# If BITS environment variable is not set, try determine it
if [ -z "$BITS" ]; then
    # Determine the operating system architecture
    architecture=$(uname -m)

    # Set OS_BITS based on the architecture
    if [[ $architecture == *"64"* ]]; then
        export BITS=64
    elif [[ $architecture == *"i386"* ]] || [[ $architecture == *"i686"* ]]; then
        export BITS=32
    else
        echo "Unknown architecture: $architecture"
        exit 1
    fi
fi

if [[ -z $IP ]]; then
    IP_ARGS=""
else
    IP_ARGS="-ip ${IP}"
fi

echo "Downloading any updates for Steam Linux Runtime 3.0 (sniper)..."
# https://discord.com/channels/1160907911501991946/1160907912445710479/1411330429679829013
# https://steamdb.info/app/1628350/depots/
sudo -u $user /steamcmd/steamcmd.sh \
  +api_logging 1 1 \
  +@sSteamCmdForcePlatformType linux \
  +@sSteamCmdForcePlatformBitness $BITS \
  +force_install_dir /home/${user}/steamrt \
  +login anonymous \
  +app_update 1628350 \
  +validate \
  +quit
chown -R ${user}:${user} /home/${user}/steamrt

echo "Downloading any updates for CS2..."
# https://developer.valvesoftware.com/wiki/Command_line_options
sudo -u $user /steamcmd/steamcmd.sh \
  +api_logging 1 1 \
  +@sSteamCmdForcePlatformType linux \
  +@sSteamCmdForcePlatformBitness $BITS \
  +force_install_dir /home/${user}/cs2 \
  +login anonymous \
  +app_update 730 \
  +quit

cd /home/${user}/cs2

# Try to enable unprivileged namespaces
enable_unprivileged_namespaces

echo "Starting server on $PUBLIC_IP:$PORT"
echo /home/${user}/steamrt/run ./game/bin/linuxsteamrt64/cs2 --graphics-provider "" -- \
    -dedicated \
    -console \
    -usercon \
    -autoupdate \
    -tickrate $TICKRATE \
	$IP_ARGS \
    -port $PORT \
    +map de_dust2 \
    +sv_visiblemaxplayers $MAXPLAYERS \
    -authkey $API_KEY \
    +sv_setsteamaccount $STEAM_ACCOUNT \
    +game_type 0 \
    +game_mode 0 \
    +mapgroup mg_active \
    +sv_lan $LAN \
	+sv_password $SERVER_PASSWORD \
	+rcon_password $RCON_PASSWORD \
	+exec $EXEC
sudo -u $user /home/${user}/steamrt/run ./game/bin/linuxsteamrt64/cs2 --graphics-provider "" -- \
    -dedicated \
    -console \
    -usercon \
    -autoupdate \
    -tickrate $TICKRATE \
	$IP_ARGS \
    -port $PORT \
    +map de_dust2 \
    +sv_visiblemaxplayers $MAXPLAYERS \
    -authkey $API_KEY \
    +sv_setsteamaccount $STEAM_ACCOUNT \
    +game_type 0 \
    +game_mode 0 \
    +mapgroup mg_active \
    +sv_lan $LAN \
	+sv_password $SERVER_PASSWORD \
	+rcon_password $RCON_PASSWORD \
	+exec $EXEC
