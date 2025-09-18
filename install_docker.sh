#!/usr/bin/env bash

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

# Check root
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Please run this script as root..."
    exit 1
fi

PUBLIC_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)

if [ -z "$PUBLIC_IP" ]; then
    echo "ERROR: Cannot retrieve your public IP address..."
    exit 1
fi

# Update DuckDNS with our current IP
if [ ! -z "$DUCK_TOKEN" ]; then
    echo url="http://www.duckdns.org/update?domains=$DUCK_DOMAIN&token=$DUCK_TOKEN&ip=$PUBLIC_IP" | curl -k -o /duck.log -K -
fi

echo "Checking $user user exists..."
getent passwd ${user} 2 >/dev/null &>1
if [ "$?" -ne "0" ]; then
    echo "Adding $user user..."
    addgroup ${user} &&
        adduser --system --home /home/${user} --shell /bin/false --ingroup ${user} ${user} &&
        usermod -a -G tty ${user} &&
        mkdir -m 777 /home/${user}/cs2 &&
        chown -R ${user}:${user} /home/${user}/cs2
    if [ "$?" -ne "0" ]; then
        echo "ERROR: Cannot add user $user..."
        exit 1
    fi
fi

chmod 777 /home/${user}/cs2
chown -R ${user}:${user} /home/${user}

echo "Checking steamcmd exists..."
if [ ! -d "/steamcmd" ]; then
    mkdir /steamcmd && cd /steamcmd || exit
    wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
    tar -xvzf steamcmd_linux.tar.gz
fi

chown -R ${user}:${user} /steamcmd
chown -R ${user}:${user} /home/${user}

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

# https://developer.valvesoftware.com/wiki/Command_line_options
sudo -u $user /steamcmd/steamcmd.sh \
    +api_logging 1 1 \
    +@sSteamCmdForcePlatformType linux \
    +@sSteamCmdForcePlatformBitness "$BITS" \
    +force_install_dir /home/${user}/cs2 \
    +login anonymous \
    +app_update 730 \
    +quit

cd /home/${user} || exit

# Set up steam client libraries
# 32-bit
mkdir -p /home/${user}/.steam/sdk32/
rm /home/${user}/.steam/sdk32/steamclient.so
cp -v /steamcmd/linux32/steamclient.so /home/${user}/.steam/sdk32/steamclient.so || {
	echo "ERROR: Failed to copy 32-bit libraries"
}
# 64-bit
mkdir -p /home/${user}/.steam/sdk64/
rm /home/${user}/.steam/sdk64/steamclient.so
cp -v /steamcmd/linux64/steamclient.so /home/${user}/.steam/sdk64/steamclient.so || {
	echo "ERROR: Failed to copy 64-bit libraries"
}

echo "Installing mods"
cp -R /home/cs2-modded-server/game/csgo/ /home/${user}/cs2/game/

echo "Merging in custom files"
cp -RT /home/custom_files/ /home/${user}/cs2/game/csgo/

chown -R ${user}:${user} /home/${user}

cd /home/${user}/cs2 || exit

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
    }' "$FILE" >tmp_file && mv tmp_file "$FILE"
    echo "$FILE successfully patched for Metamod."
fi

# Try to enable unprivileged namespaces
enable_unprivileged_namespaces

echo "Starting server on $PUBLIC_IP:$PORT"
# https://developer.valvesoftware.com/wiki/Counter-Strike_2/Dedicated_Servers#Command-Line_Parameters
sudo -u $user /home/${user}/steamrt/run ./game/bin/linuxsteamrt64/cs2 --graphics-provider "" -- \
    -dedicated \
    -console \
    -usercon \
    -autoupdate \
    -tickrate "$TICKRATE" \
    "$IP_ARGS" \
    -port "$PORT" \
    +map "${MAP-de_dust2}" \
    +sv_visiblemaxplayers "$MAXPLAYERS" \
    -authkey "$API_KEY" \
    +sv_setsteamaccount "$STEAM_ACCOUNT" \
    +game_type "${GAME_TYPE-0}" \
    +game_mode "${GAME_MODE-0}" \
    +mapgroup "${MAP_GROUP-mg_active}" \
    +sv_lan "$LAN" \
    +sv_password "$SERVER_PASSWORD" \
    +rcon_password "$RCON_PASSWORD" \
    +exec "$EXEC"
