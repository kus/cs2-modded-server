#!/bin/bash

# chmod +x get-map-names.sh

# Check if steamcmd.sh exists
if [[ ! -f "steamcmd/steamcmd.sh" ]]; then
    echo "Error: steamcmd/steamcmd.sh not found. Please ensure it is installed and in the correct location. https://developer.valvesoftware.com/wiki/SteamCMD#Downloading_SteamCMD"
    exit 1
fi

# Check if vpk command exists
if ! command -v vpk &> /dev/null; then
    echo "Error: vpk command not found. Please install it 'pip install vpk' before running this script."
    exit 1
fi

# File containing the list of IDs
file="subscribed_file_ids.txt"

# Check if the file exists
if [[ ! -f "$file" ]]; then
    echo "File not found: $file"
    exit 1
fi

# Read each line in the file
while IFS= read -r id; do
    if [[ -n "$id" ]]; then

        echo -e "Processing $id:"

        # Run steamcmd.sh with the current ID and process its output
        ./steamcmd/steamcmd.sh +login anonymous +download_item 730 "$id" +quit 2>&1 | while IFS= read -r line; do
            # Check if line contains specific debug information
            if [[ "$line" == *"Connecting anonymously to Steam Public"* || "$line" == *"Downloading depot 730"* || "$line" == *"finish (OK)"* ]]; then
                echo "$line"
            fi
            if [[ "$line" == *"steamcmd\steamapps\content\app_730\item_$id\" finish (OK)"* ]]; then
                break
            fi
        done

        echo -e "Maps:"

        # Run the vpk command
        # Check to see if $id.vpk exists or $id_dir.vpk or $id_000.vpk"
        vpkfile="steamcmd/steamapps/content/app_730/item_$id/$id.vpk"
        if [[ ! -f "$vpkfile" ]]; then
            vpkfile="steamcmd/steamapps/content/app_730/item_$id/${id}_dir.vpk"
        fi
        if [[ ! -f "$vpkfile" ]]; then
            vpkfile="steamcmd/steamapps/content/app_730/item_$id/${id}_000.vpk"
        fi
        # Check if the vpk file exists
        if [[ ! -f "$vpkfile" ]]; then
            echo "Error: $vpkfile not found."
            continue
        fi
        # Extract the vpk file and list the contents
        echo "Extracting $vpkfile..."
        # Extract the vpk file
        vpk -l "$vpkfile" | grep '^maps/.*\.vpk$' # grep '^maps/' # grep '^maps/.*\.vpk$'

        # New line
        echo ""

        # Delete the folder
        rm -rf "steamcmd/steamapps/content/app_730/item_$id/"
    fi
done < "$file"