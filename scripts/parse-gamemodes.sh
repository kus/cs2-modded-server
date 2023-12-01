#!/bin/bash

# chmod +x parse-gamemodes.sh

# Path to the gamemodes_server.txt file
FILE_PATH="gamemodes_server.txt"

# Specify the path for the output file
OUTPUT_FILE="maps.md"

# Function to echo and write to file
echo_and_write() {
    echo "$1"
    echo "$1" >> "$OUTPUT_FILE"
}

# Check if the file exists
if [ ! -f "$FILE_PATH" ]; then
    echo "File not found: $FILE_PATH"
    exit 1
fi


# Variables to track depth and states
depth=0
in_mapgroups=false
in_mapgroup=false
in_maps=false
current_group=""
maps_in_group=""

# Clear the output file
> "$OUTPUT_FILE"

echo_and_write "| Group | Maps |";
echo_and_write "| ----- | ---- |";

# Read the file line by line
while IFS= read -r line; do
    # Debugging information
    # echo "Depth: $depth, In MapGroups: $in_mapgroups, Current Group: $current_group, Line: $line"

    # Check for the start of a block
    if [[ "$line" == *{* ]]; then
        ((depth++))

    # Check for the end of a block
    elif [[ "$line" == *}* ]]; then
        if [ "$depth" -eq 3 ]; then
            echo_and_write "| $current_group | $maps_in_group|";
            in_maps=false
        fi
        if [ "$depth" -eq 2 ]; then
            in_mapgroup=false
            current_group=""
        fi
        ((depth--))
    fi

    # Process the line if we are inside the maps list
    if [ "$in_maps" = true ] && [ "$depth" -eq 4 ]; then
        # map_name=$(echo "$line" | sed 's/[^a-zA-Z0-9_]*//g')
        # Check if the line contains a workshop map
        if [[ $line =~ workshop/([0-9]+)/([^\"]+) ]]; then
            # Extract workshop id and map name, and remove any trailing whitespaces
            id="${BASH_REMATCH[1]}"
            map=$(echo "${BASH_REMATCH[2]}" | xargs)
            # echo_and_write "[$map](https://steamcommunity.com/sharedfiles/filedetails/?id=$id) "
            maps_in_group="$maps_in_group[$map](https://steamcommunity.com/sharedfiles/filedetails/?id=$id) ";
        else
            # Extract and print the map name for non-workshop maps
            if [[ $line =~ \"([^\"]+)\" ]]; then
                map="${BASH_REMATCH[1]}"
                # echo_and_write "$map "
                maps_in_group="$maps_in_group$map ";
            fi
        fi
    fi

    # Check if entering the maps list
    if [ "$in_mapgroup" = true ] && [[ "$line" == *"maps"* ]] && [ "$depth" -eq 3 ]; then
        in_maps=true
        # echo_and_write "| $current_group | ";
    fi

    # Capture the group name at level 2
    if [ "$in_mapgroups" = true ] && [ "$depth" -eq 2 ]; then
        current_group=$(echo "$line" | sed 's/[^a-zA-Z0-9_]*//g')
        maps_in_group=""
        in_mapgroup=true
    fi

    # Check if this is the mapgroups block
    if [[ "$line" == *"mapgroups"* ]] && [ "$depth" -eq 1 ]; then
        in_mapgroups=true
    fi
done < "$FILE_PATH"