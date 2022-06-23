#!/bin/bash

# https://developer.valvesoftware.com/wiki/Sv_downloadurl

# Windows: http://gnuwin32.sourceforge.net/packages/bzip2.htm

# Max/Linux:
# Place bzip.sh in your csgo/ folder (the same directory maps and sounds folders are in)
# chmod +x bzip.sh
# Run: ./bzip.sh
# It will create a fastdl folder with all your custom files compressed with bzip2.

# Upload the fastdl folder to your host.
# Your directory structure should look like:
# Your host
# -fastdl
# --csgo
# ---maps
# ---sounds
# ---materials
# ---models

# And be accessible from http://yoursite.com/fastdl/csgo/maps
# Follow instructions at https://github.com/kus/csgo-modded-server#fast-dl to set your Fast DL server

if [ ! -d fastdl/csgo ]
then
	mkdir -p fastdl/csgo
fi

array=($(find maps sound materials models -type f \( ! -name ".DS_Store" -and ! -name "*.bz2" -and ! -name "*.nav" -and ! -name "*.ztmp" \)))
for i in ${array[@]};
do
	DIR=$(dirname "${i}")
	echo "Compressing $i"
	if [ ! -d fastdl/csgo/$DIR ]
	then
		mkdir -p fastdl/csgo/$DIR
	fi
	bzip2 -c $i > fastdl/csgo/$i.bz2;
done