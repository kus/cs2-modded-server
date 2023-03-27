#!/usr/bin/env bash

# Install
# As root (sudo su)
# cd / && curl --silent --output "start.sh" "https://raw.githubusercontent.com/kus/csgo-modded-server/master/start.sh" && chmod +x start.sh && bash start.sh

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
export MOD_URL="${META_MOD_URL:-https://github.com/kus/csgo-modded-server/archive/master.zip}"
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

# Variables
user="steam"
IP="0.0.0.0"
PUBLIC_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
CUSTOM_FILES="${CUSTOM_FOLDER:-custom_files}"
if [ -f /etc/os-release ]; then
	# freedesktop.org and systemd
	. /etc/os-release
	DISTRO_OS=$NAME
	DISTRO_VERSION=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
	# linuxbase.org
	DISTRO_OS=$(lsb_release -si)
	DISTRO_VERSION=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
	# For some versions of Debian/Ubuntu without lsb_release command
	. /etc/lsb-release
	DISTRO_OS=$DISTRIB_ID
	DISTRO_VERSION=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
	# Older Debian/Ubuntu/etc.
	DISTRO_OS=Debian
	DISTRO_VERSION=$(cat /etc/debian_version)
else
	# Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
	DISTRO_OS=$(uname -s)
	DISTRO_VERSION=$(uname -r)
fi

# Check distrib
if ! command -v apt-get &> /dev/null; then
	echo "ERROR: OS distribution not supported... $DISTRO_OS $DISTRO_VERSION"
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

echo "Installing required packages for $DISTRO_OS $DISTRO_VERSION..."
apt-get update -y -q >/dev/null
if [ "${DISTRO_OS}" == "Ubuntu" ]; then
	if [ "${DISTRO_VERSION}" == "16.04" ]; then
		apt-get install -y -q curl wget screen nano file tar bzip2 gzip unzip hostname bsdmainutils python3 util-linux xz-utils ca-certificates binutils bc jq tmux netcat lib32stdc++6 libsdl2-2.0-0:i386 lib32gcc1 steamcmd >/dev/null
	elif [ "${DISTRO_VERSION}" == "18.04" ]; then
		apt-get install -y -q curl wget screen nano file tar bzip2 gzip unzip hostname bsdmainutils python3 util-linux xz-utils ca-certificates binutils bc jq tmux netcat lib32stdc++6 libsdl2-2.0-0:i386 distro-info lib32gcc1 steamcmd >/dev/null
	elif [ "${DISTRO_VERSION}" == "20.04" ]; then
		apt-get install -y -q curl wget screen nano file tar bzip2 gzip unzip hostname bsdmainutils python3 util-linux xz-utils ca-certificates binutils bc jq tmux netcat lib32stdc++6 libsdl2-2.0-0:i386 distro-info lib32gcc1 steamcmd >/dev/null
	elif [ "${DISTRO_VERSION}" == "22.04" ]; then
		apt-get install -y -q curl wget screen nano file tar bzip2 gzip unzip hostname bsdmainutils python3 util-linux xz-utils ca-certificates binutils bc jq tmux netcat lib32stdc++6 libsdl2-2.0-0:i386 distro-info lib32gcc-s1 steamcmd >/dev/null
	else
		echo "$DISTRO_OS $DISTRO_VERSION not officially supported; using Ubuntu 22.04 config"
		apt-get install -y -q curl wget screen nano file tar bzip2 gzip unzip hostname bsdmainutils python3 util-linux xz-utils ca-certificates binutils bc jq tmux netcat lib32stdc++6 libsdl2-2.0-0:i386 distro-info lib32gcc-s1 steamcmd >/dev/null
	fi
else
	echo "ERROR: OS distribution not supported. $DISTRO_OS $DISTRO_VERSION"
	exit 1
fi

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
	mkdir -p /root/.steam/sdk32/
	ln -s /steamcmd/linux32/steamclient.so /root/.steam/sdk32/steamclient.so
fi

echo "Downloading any updates for CS:GO..."
/steamcmd/steamcmd.sh +login anonymous \
  +force_install_dir /home/${user}/csgo \
  +app_update 740 \
  +quit

cd /home/${user}/csgo/csgo/warmod/ && python3 -m http.server 80 </dev/null &>/dev/null &

cd /home/${user}

echo "Dynamically writing /home/$user/csgo/csgo/cfg/secrets.cfg"
if [ ! -z "$RCON_PASSWORD" ]; then
	echo "rcon_password						\"$RCON_PASSWORD\"" > /home/${user}/csgo/csgo/cfg/secrets.cfg
fi
if [ ! -z "$STEAM_ACCOUNT" ]; then
	echo "sv_setsteamaccount					\"$STEAM_ACCOUNT\"			// Required for online https://steamcommunity.com/dev/managegameservers" >> /home/${user}/csgo/csgo/cfg/secrets.cfg
fi
if [ ! -z "$SERVER_PASSWORD" ]; then
	echo "sv_password							\"$SERVER_PASSWORD\"" >> /home/${user}/csgo/csgo/cfg/secrets.cfg
fi
echo "" >> /home/${user}/csgo/csgo/cfg/secrets.cfg
echo "echo \"secrets.cfg executed\"" >> /home/${user}/csgo/csgo/cfg/secrets.cfg

echo "Merging in custom files from ${CUSTOM_FILES}"
cp -RT /home/${user}/csgo/${CUSTOM_FILES}/ /home/${user}/csgo/csgo/

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
    +map de_dust2 \
    -maxplayers_override $MAXPLAYERS \
    -authkey $API_KEY
    +ip $IP \
    +game_type 0 \
    +game_mode 0 \
    +mapgroup mg_active
