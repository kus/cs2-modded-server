#!/usr/bin/env bash

# To exit the screen session without disrupting the Steam process, press CTRL + A and then D.
# To resume, use the `screen -r` command

# Variables
user="steam"
IP="0.0.0.0"
PUBLIC_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)

# Check distrib
if ! command -v apt-get &> /dev/null; then
	echo "ERROR: OS distribution not supported..."
	exit 1
fi

# Check root
if [ "$EUID" -ne 0 ]; then
	echo "ERROR: Please run this script as root..."
	exit 1
fi

if [ -z "$PUBLIC_IP" ]; then
	echo "ERROR: Cannot retrieve your public IP address..."
	exit 1
fi

echo "Updating Operating System..."
apt update -y -q && apt upgrade -y -q >/dev/null
if [ "$?" -ne "0" ]; then
	echo "ERROR: Updating Operating System..."
	exit 1
fi

echo "Adding i386 architecture..."
dpkg --add-architecture i386 >/dev/null
if [ "$?" -ne "0" ]; then
	echo "ERROR: Cannot add i386 architecture..."
	exit 1
fi

echo "Installing required packages..."
apt-get update -y -q >/dev/null
apt-get install -y -q libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1 wget gdb screen tar unzip nano >/dev/null
if [ "$?" -ne "0" ]; then
	echo "ERROR: Cannot install required packages..."
	exit 1
fi

echo "Checking $user user exists..."
getent passwd ${user} >/dev/null 2&>1
if [ "$?" -ne "0" ]; then
	echo "Adding $user user..."
	addgroup ${user} && \
	adduser --system --home /home/${user} --shell /bin/false --ingroup ${user} ${user} && \
	usermod -a -G tty ${user} && \
	mkdir -m 777 /home/${user}/csgo && \
	chown -R ${user}:${user} /home/${user}/csgo
	if [ "$?" -ne "0" ]; then
		echo "ERROR: Cannot add user $user..."
		exit 1
	fi
fi

echo "Checking steamcmd exists..."
if [ ! -d "/steamcmd" ]; then
	mkdir /steamcmd && cd /steamcmd
	wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
	tar -xvzf steamcmd_linux.tar.gz
	mkdir -p /home/steam/.steam/sdk32/
	ln -s /home/steam/linux32/steamclient.so /home/steam/.steam/sdk32/steamclient.so
fi

echo "Downloading any updates for CS:GO..."
/steamcmd/steamcmd.sh +login anonymous \
  +force_install_dir /home/${user}/csgo \
  +app_update 740 \
  +quit

cd /home/${user}

echo "Downloading mod files..."
wget --quiet https://github.com/kus/csgo-modded-server/archive/master.zip
unzip -o -qq master.zip
cp -rlf csgo-modded-server-master/csgo/ /home/${user}/csgo/
rm -r csgo-modded-server-master master.zip

echo "Dynamically writing /home/$user/csgo/csgo/cfg/env.cfg"
echo "rcon_password						\"$RCON_PASSWORD\"" > /home/${user}/csgo/csgo/cfg/env.cfg
echo "sv_setsteamaccount					\"$STEAM_ACCOUNT\"			// Required for online https://steamcommunity.com/dev/managegameservers" >> /home/${user}/csgo/csgo/cfg/env.cfg
if [ -z "$SERVER_PASSWORD" ]; then
	echo "sv_password							\"\"" >> /home/${user}/csgo/csgo/cfg/env.cfg
else
	echo "sv_password							\"$SERVER_PASSWORD\"" >> /home/${user}/csgo/csgo/cfg/env.cfg
fi
if [ "$LAN" = "1" ]; then
	echo "sv_lan								1" >> /home/${user}/csgo/csgo/cfg/env.cfg
else
	echo "sv_lan								0" >> /home/${user}/csgo/csgo/cfg/env.cfg
fi
echo "sv_downloadurl						\"$FAST_DL_URL\"			// Fast download (custom files uploaded to web server)" >> /home/${user}/csgo/csgo/cfg/env.cfg
echo "sv_allowupload						0" >> /home/${user}/csgo/csgo/cfg/env.cfg
if [ -z "$FAST_DL_URL" ]; then
	# No Fast DL
	echo "sv_allowdownload					1			// If using Fast download change to 0" >> /home/${user}/csgo/csgo/cfg/env.cfg
else
	# Has Fast DL
	echo "sv_allowdownload					0			// If using Fast download change to 0" >> /home/${user}/csgo/csgo/cfg/env.cfg
fi
echo "" >> /home/${user}/csgo/csgo/cfg/env.cfg
echo "echo \"env.cfg executed\"" >> /home/${user}/csgo/csgo/cfg/env.cfg

chown -R ${user}:${user} /home/${user}/csgo

cd /home/${user}/csgo

echo "Starting server on $PUBLIC_IP:$PORT"
./srcds_run \
    -console \
    -usercon \
    -autoupdate \
    -game csgo \
    -tickrate $TICKRATE \
    -port $PORT \
    -maxplayers_override $MAXPLAYERS \
    +game_type 0 \
    +game_mode 1 \
    +mapgroup mg_active \
    +map de_dust2 \
    +ip $IP