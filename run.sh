user="steam"
PUBLIC_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)

# Set IP to PUBLIC_IP if IP is empty
if [ -z "$IP" ]; then
    IP="$PUBLIC_IP"
fi

echo "Downloading any updates for CS2..."
sudo -u $user /steamcmd/steamcmd.sh \
  +force_install_dir /home/${user}/cs2 \
  +login anonymous \
  +app_update 730 \
  +quit

cd /home/${user}/cs2

echo "Starting server on $IP:$PORT"
echo ./game/bin/linuxsteamrt64/cs2 \
    -dedicated \
    -console \
    -usercon \
    -autoupdate \
    -tickrate $TICKRATE \
	-ip $IP \
    -port $PORT \
    +map de_dust2 \
    -maxplayers $MAXPLAYERS \
    -authkey $API_KEY \
    +sv_setsteamaccount $STEAM_ACCOUNT \
    +game_type 0 \
    +game_mode 0 \
    +mapgroup mg_active
sudo -u $user ./game/bin/linuxsteamrt64/cs2 \
    -dedicated \
    -console \
    -usercon \
    -autoupdate \
    -tickrate $TICKRATE \
	-ip $IP \
    -port $PORT \
    +map de_dust2 \
    -maxplayers $MAXPLAYERS \
    -authkey $API_KEY \
    +sv_setsteamaccount $STEAM_ACCOUNT \
    +game_type 0 \
    +game_mode 0 \
    +mapgroup mg_active
