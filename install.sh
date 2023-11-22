#!/usr/bin/env bash

# Function to check if MySQL is installed
check_mysql() {
    if dpkg -l | grep -qw mysql-server; then
        return 1
    else
        return 0
    fi
}

# Variables
user="steam"
IP="0.0.0.0"
BRANCH="master"

# Check if MOD_BRANCH is set and not empty
if [ -n "$MOD_BRANCH" ]; then
    BRANCH="$MOD_BRANCH"
fi

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

# Download latest stop script
curl --silent --output "stop.sh" "https://raw.githubusercontent.com/kus/cs2-modded-server/${BRANCH}/stop.sh" && chmod +x stop.sh

# Download latest start script
curl --silent --output "start.sh" "https://raw.githubusercontent.com/kus/cs2-modded-server/${BRANCH}/start.sh" && chmod +x start.sh

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

# /root/.steam/sdk64/steamclient.so

echo "Downloading any updates for CS2..."
sudo -u $user /steamcmd/steamcmd.sh \
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
rm -r /home/${user}/cs2/custom_files/ /home/${user}/cs2/custom_files_example/
cp -R cs2-modded-server-${BRANCH}/game/csgo/ /home/${user}/cs2/game/
cp -R cs2-modded-server-${BRANCH}/custom_files/ /home/${user}/cs2/custom_files/
cp -R cs2-modded-server-${BRANCH}/custom_files_example/ /home/${user}/cs2/custom_files_example/

echo "Dynamically writing /home/$user/cs2/game/csgo/cfg/secrets.cfg"
if [ ! -z "$RCON_PASSWORD" ]; then
	echo "rcon_password						\"$RCON_PASSWORD\"" > /home/${user}/cs2/game/csgo/cfg/secrets.cfg
fi
if [ ! -z "$STEAM_ACCOUNT" ]; then
	echo "sv_setsteamaccount					\"$STEAM_ACCOUNT\"			// Required for online https://steamcommunity.com/dev/managegameservers" >> /home/${user}/cs2/game/csgo/cfg/secrets.cfg
fi
if [ ! -z "$SERVER_PASSWORD" ]; then
	echo "sv_password							\"$SERVER_PASSWORD\"" >> /home/${user}/cs2/game/csgo/cfg/secrets.cfg
fi
echo "" >> /home/${user}/cs2/game/csgo/cfg/secrets.cfg
echo "echo \"secrets.cfg executed\"" >> /home/${user}/cs2/game/csgo/cfg/secrets.cfg

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

# Check if MySQL is installed
if check_mysql; then
    echo "MySQL is not installed. Proceeding with installation and configuration."

    # Update system package index
    apt-get update

    # Install MySQL Server without prompt
	#echo "mysql-server mysql-server/root_password password root" | sudo debconf-set-selections
	#echo "mysql-server mysql-server/root_password_again password root" | sudo debconf-set-selections
    DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server

	# Command to check MySQL connection
	mysql -uroot -e "quit" 2>/dev/null

	# Check the exit status of the MySQL command
	if [ $? -eq 0 ]; then
		echo "Successfully connected to MySQL."
	else
		echo "Failed to connect to MySQL."
	fi

	echo "Configure MySQL with non-interactive secure installation"

	# Search for the line that needs to be commented out
	# LINE_TO_COMMENT="Instead of skip-networking the default is now to listen only on"
	# Check if the line exists and is not already commented out
	# if grep -q "^\s*$LINE_TO_COMMENT" /etc/mysql/mysql.conf.d/mysqld.cnf; then
	# 	# The line exists and is not commented, so comment it out
	# 	sed -i "s/^\s*$LINE_TO_COMMENT/# $LINE_TO_COMMENT/" /etc/mysql/mysql.conf.d/mysqld.cnf
	# 	echo "Error line commented out successfully."
	# else
	# 	echo "The error line is already commented out or does not exist."
	# fi

    # Disable remote access
    #sed -i '/bind-address/s/^/#/' /etc/mysql/mysql.conf.d/mysqld.cnf
    #sed -i '/skip-networking/s/^#//' /etc/mysql/mysql.conf.d/mysqld.cnf

	mkdir -p /var/log/mysql/
	chown mysql:mysql -R /var/log/mysql

    # Configure MySQL with non-interactive secure installation
    mysql --user=root <<_EOF_
	-- Set root password and remove anonymous users
	ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';
	DELETE FROM mysql.user WHERE User='';

	-- Disallow root login remotely
	DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

	-- Remove test database and access to it
	DROP DATABASE IF EXISTS test;
	DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

	-- Reload privilege tables now
	FLUSH PRIVILEGES;
_EOF_

    # Restart MySQL service to apply changes
    systemctl restart mysql

    # Enable MySQL service to start on boot
    systemctl enable mysql

    # Create a default database
    DB_NAME="cs"
    mysql --user=root --password='password' -e "CREATE DATABASE ${DB_NAME};"

    echo "Database $DB_NAME created."

else
    echo "MySQL is already installed."
fi

rm -r /home/${user}/cs2-modded-server-${BRANCH} /home/${user}/${BRANCH}.zip

echo "Starting server on $PUBLIC_IP:$PORT"
sudo -u $user ./game/bin/linuxsteamrt64/cs2 \
    -dedicated \
    -console \
    -usercon \
    -autoupdate \
    -tickrate $TICKRATE \
    -port $PORT \
    +map de_dust2 \
    -maxplayers_override $MAXPLAYERS \
    -authkey $API_KEY \
	+sv_setsteamaccount $STEAM_ACCOUNT \
    +game_type 0 \
    +game_mode 0 \
    +mapgroup mg_active