#!/usr/bin/env bash

# As root (sudo su)
# cd / && curl -s -H "Cache-Control: no-cache" -o "run.sh" "https://raw.githubusercontent.com/kus/cs2-modded-server/master/run.sh" && chmod +x run.sh && bash run.sh


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

echo "Starting server on $PUBLIC_IP:$PORT"
echo ./game/bin/linuxsteamrt64/cs2 \
    -dedicated \
    -console \
    -usercon \
    -autoupdate \
    -tickrate $TICKRATE \
	$IP_ARGS \
    -port $PORT \
    +map de_dust2 \
    -maxplayers $MAXPLAYERS \
    -authkey $API_KEY \
    +sv_setsteamaccount $STEAM_ACCOUNT \
    +game_type 0 \
    +game_mode 0 \
    +mapgroup mg_active \
    +sv_lan $LAN \
	+sv_password $SERVER_PASSWORD \
	+rcon_password $RCON_PASSWORD \
	+exec $EXEC
sudo -u $user ./game/bin/linuxsteamrt64/cs2 \
    -dedicated \
    -console \
    -usercon \
    -autoupdate \
    -tickrate $TICKRATE \
	$IP_ARGS \
    -port $PORT \
    +map de_dust2 \
    -maxplayers $MAXPLAYERS \
    -authkey $API_KEY \
    +sv_setsteamaccount $STEAM_ACCOUNT \
    +game_type 0 \
    +game_mode 0 \
    +mapgroup mg_active \
    +sv_lan $LAN \
	+sv_password $SERVER_PASSWORD \
	+rcon_password $RCON_PASSWORD \
	+exec $EXEC
