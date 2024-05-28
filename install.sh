#!/usr/bin/env bash

# As root (sudo su)
# cd / && curl -s -H "Cache-Control: no-cache" -o "install.sh" "https://raw.githubusercontent.com/kus/cs2-modded-server/master/install.sh" && chmod +x install.sh && bash install.sh

# Variables
user="steam"
BRANCH="master"

# Check if MOD_BRANCH is set and not empty
if [ -n "$MOD_BRANCH" ]; then
    BRANCH="$MOD_BRANCH"
fi

CUSTOM_FILES="${CUSTOM_FOLDER:-custom_files}"

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

echo "Starting on $DISTRO_OS: $DISTRO_VERSION..."

# Get the free space on the root filesystem in GB
FREE_SPACE=$(df / --output=avail -BG | tail -n 1 | tr -d 'G')

echo "With $FREE_SPACE Gb free space..."

# Check distrib
if ! command -v apt-get &> /dev/null; then
	echo "ERROR: OS distribution not supported (apt-get not available). $DISTRO_OS: $DISTRO_VERSION"
	exit 1
fi

# Check root
if [ "$EUID" -ne 0 ]; then
	echo "ERROR: Please run this script as root..."
	exit 1
fi

echo "Updating Operating System..."
apt-get update -y -q && apt-get upgrade -y -q >/dev/null
if [ "$?" -ne "0" ]; then
	echo "ERROR: Updating Operating System..."
	exit 1
fi

dpkg --configure -a >/dev/null

echo "Adding i386 architecture..."
dpkg --add-architecture i386 >/dev/null
if [ "$?" -ne "0" ]; then
	echo "ERROR: Cannot add i386 architecture..."
	exit 1
fi

echo "Installing required packages for $DISTRO_OS: $DISTRO_VERSION..."
apt-get update -y -q >/dev/null
if [ "${DISTRO_OS}" == "Ubuntu" ]; then
	if [ "${DISTRO_VERSION}" == "16.04" ]; then
		apt-get install -y -q dnsutils curl wget screen nano file tar bzip2 gzip unzip hostname bsdmainutils python3 util-linux xz-utils ca-certificates binutils bc jq tmux netcat lib32stdc++6 libsdl2-2.0-0:i386 lib32gcc1 steamcmd >/dev/null
	elif [ "${DISTRO_VERSION}" == "18.04" ]; then
		apt-get install -y -q dnsutils curl wget screen nano file tar bzip2 gzip unzip hostname bsdmainutils python3 util-linux xz-utils ca-certificates binutils bc jq tmux netcat lib32stdc++6 libsdl2-2.0-0:i386 distro-info lib32gcc1 steamcmd >/dev/null
	elif [ "${DISTRO_VERSION}" == "20.04" ]; then
		apt-get install -y -q dnsutils curl wget screen nano file tar bzip2 gzip unzip hostname bsdmainutils python3 util-linux xz-utils ca-certificates binutils bc jq tmux netcat lib32stdc++6 libsdl2-2.0-0:i386 distro-info lib32gcc1 steamcmd >/dev/null
	elif [ "${DISTRO_VERSION}" == "22.04" ]; then
		apt-get install -y -q dnsutils curl wget screen nano file tar bzip2 gzip unzip hostname bsdmainutils python3 util-linux xz-utils ca-certificates binutils bc jq tmux netcat lib32stdc++6 libsdl2-2.0-0:i386 distro-info lib32gcc-s1 steamcmd >/dev/null
	else
		echo "$DISTRO_OS $DISTRO_VERSION not officially supported; using Ubuntu 22.04 config"
		apt-get install -y -q dnsutils curl wget screen nano file tar bzip2 gzip unzip hostname bsdmainutils python3 util-linux xz-utils ca-certificates binutils bc jq tmux netcat lib32stdc++6 libsdl2-2.0-0:i386 distro-info lib32gcc-s1 steamcmd >/dev/null
	fi
elif [[ $DISTRO_OS == Debian* ]]; then
	if [ "${DISTRO_VERSION}" == "10" ]; then
		apt-get install -y dnsutils curl wget screen nano file tar bzip2 gzip unzip hostname bsdmainutils python3 util-linux xz-utils ca-certificates binutils bc jq tmux netcat-traditional lib32stdc++6 libsdl2-2.0-0:i386 distro-info lib32gcc1 >/dev/null
	elif [ "${DISTRO_VERSION}" == "11" ]; then
		apt-get install -y dnsutils curl wget screen nano file tar bzip2 gzip unzip hostname bsdmainutils python3 util-linux xz-utils ca-certificates binutils bc jq tmux netcat-traditional lib32stdc++6 libsdl2-2.0-0:i386 distro-info lib32gcc-s1 >/dev/null
	elif [ "${DISTRO_VERSION}" == "12" ]; then
		apt-get install -y dnsutils curl wget screen nano file tar bzip2 gzip unzip hostname bsdmainutils python3 util-linux xz-utils ca-certificates binutils bc jq tmux netcat-traditional lib32stdc++6 libsdl2-2.0-0:i386 distro-info lib32gcc-s1 >/dev/null
	elif [ "${DISTRO_VERSION}" == "13" ]; then
		apt-get install -y dnsutils curl wget screen nano file tar bzip2 gzip unzip hostname bsdmainutils python3 util-linux xz-utils ca-certificates binutils bc jq tmux netcat-traditional lib32stdc++6 libsdl2-2.0-0:i386 distro-info lib32gcc-s1 >/dev/null
	else
		echo "$DISTRO_OS: $DISTRO_VERSION not officially supported; using Debian 13 config"
		apt-get install -y dnsutils curl wget screen nano file tar bzip2 gzip unzip hostname bsdmainutils python3 util-linux xz-utils ca-certificates binutils bc jq tmux netcat-traditional lib32stdc++6 libsdl2-2.0-0:i386 distro-info lib32gcc-s1 >/dev/null
	fi
else
	echo "ERROR: OS distribution not supported. $DISTRO_OS: $DISTRO_VERSION"
	exit 1
fi

# Download latest stop script
curl -s -H "Cache-Control: no-cache" -o "stop.sh" "https://raw.githubusercontent.com/kus/cs2-modded-server/${BRANCH}/stop.sh" && chmod +x stop.sh

# Download latest start script
curl -s -H "Cache-Control: no-cache" -o "start.sh" "https://raw.githubusercontent.com/kus/cs2-modded-server/${BRANCH}/start.sh" && chmod +x start.sh

PUBLIC_IP=$(dig -4 +short myip.opendns.com @resolver1.opendns.com)

if [ -z "$PUBLIC_IP" ]; then
	echo "ERROR: Cannot retrieve your public IP address..."
	exit 1
fi

# Update DuckDNS with our current IP
if [ ! -z "$DUCK_TOKEN" ]; then
    echo url="http://www.duckdns.org/update?domains=$DUCK_DOMAIN&token=$DUCK_TOKEN&ip=$PUBLIC_IP" | curl -k -o /duck.log -K -
fi

echo "Checking $user user exists..."
getent passwd ${user} >/dev/null 2&>1
if [ "$?" -ne "0" ]; then
	echo "Adding $user user..."
	addgroup ${user} && \
	adduser --system --home /home/${user} --shell /bin/false --ingroup ${user} ${user} && \
	usermod -a -G tty ${user} && \
	mkdir -m 777 /home/${user}/cs2 && \
	chown -R ${user}:${user} /home/${user}/cs2
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
	ln -s /steamcmd/linux32/steamclient.so /root/.steam/sdk32/
	mkdir -p /root/.steam/sdk64/
	ln -s /steamcmd/linux64/steamclient.so /root/.steam/sdk64/
fi

chown -R ${user}:${user} /steamcmd

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

cd /home/${user}

mkdir -p /root/.steam/sdk32/
ln -s /steamcmd/linux32/steamclient.so /root/.steam/sdk32/
mkdir -p /root/.steam/sdk64/
ln -s /steamcmd/linux64/steamclient.so /root/.steam/sdk64/

mkdir -p /home/${user}/.steam/sdk32/
ln -s /steamcmd/linux32/steamclient.so /home/${user}/.steam/sdk32/
mkdir -p /home/${user}/.steam/sdk64/
ln -s /steamcmd/linux64/steamclient.so /home/${user}/.steam/sdk64/

if [ "${DISTRO_OS}" == "Ubuntu" ]; then
	if [ "${DISTRO_VERSION}" == "22.04" ]; then
		# https://forums.alliedmods.net/showthread.php?t=336183
		rm /home/${user}/cs2/bin/libgcc_s.so.1
	fi
fi

# Delete addons folder as if we remove something later in git it won't get deleted
rm -r /home/${user}/cs2/game/csgo/addons

echo "Downloading mod files..."
wget --quiet https://github.com/kus/cs2-modded-server/archive/${BRANCH}.zip
unzip -o -qq ${BRANCH}.zip
# Delete custom_files_example as I use this for my server and as a demo for others and I want it to always reflect git
rm -r /home/${user}/cs2/custom_files_example/
cp -R cs2-modded-server-${BRANCH}/custom_files_example/ /home/${user}/cs2/custom_files_example/
# Merge mod files into server files
cp -R cs2-modded-server-${BRANCH}/game/csgo/ /home/${user}/cs2/game/
# Merge custom files into server files
if [ ! -d "/home/${user}/cs2/custom_files/" ]; then
    # If the target directory doesn't exist, copy the source directory to the target location
    cp -R cs2-modded-server-${BRANCH}/custom_files/ /home/${user}/cs2/custom_files/
else
    # If the target directory exists, copy all the contents of the source directory to the target directory
    cp -RT cs2-modded-server-${BRANCH}/custom_files/ /home/${user}/cs2/custom_files/
fi

echo "Merging in custom files from ${CUSTOM_FILES}"
cp -RT /home/${user}/cs2/${CUSTOM_FILES}/ /home/${user}/cs2/game/csgo/

chown -R ${user}:${user} /home/${user}/cs2

cd /home/${user}/cs2

# Define the file name
FILE="game/csgo/gameinfo.gi"

# Define the pattern to search for and the line to add
PATTERN="Game_LowViolence[[:space:]]*csgo_lv // Perfect World content override"
LINE_TO_ADD="\t\t\tGame\tcsgo/addons/metamod"

# Use a regular expression to ignore spaces when checking if the line exists
REGEX_TO_CHECK="^[[:space:]]*Game[[:space:]]*csgo/addons/metamod"

# Check if the line already exists in the file, ignoring spaces
if grep -qE "$REGEX_TO_CHECK" "$FILE"; then
    echo "$FILE already patched for Metamod."
else
    # If the line isn't there, use awk to add it after the pattern
    awk -v pattern="$PATTERN" -v lineToAdd="$LINE_TO_ADD" '{
        print $0;
        if ($0 ~ pattern) {
            print lineToAdd;
        }
    }' "$FILE" > tmp_file && mv tmp_file "$FILE"
    echo "$FILE successfully patched for Metamod."
fi

rm -r /home/${user}/cs2-modded-server-${BRANCH} /home/${user}/${BRANCH}.zip

echo "Starting server on $PUBLIC_IP:$PORT"
# https://developer.valvesoftware.com/wiki/Counter-Strike_2/Dedicated_Servers#Command-Line_Parameters
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
