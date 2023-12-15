#!/bin/bash

# chmod +x parse-gamemodes.sh

# Path to the gamemodes_server.txt file
FILE_PATH="../game/csgo/gamemodes_server.txt"

# Specify the path for the output file
OUTPUT_FILE="maps.md"

# Declare an array
declare -a MAP_LIST

# Function to echo and write to file
echo_and_write() {
    echo "$1"
    echo "$1" >> "$OUTPUT_FILE"
}

# Function to process each ID
process_id() {
    local id=$1
    local name=$2
    local force_download=${3:-false}

    # Check if the image file already exists
    if [ -f "maps/${name}.png" ] && [ "$force_download" != "true" ]; then
        # echo "Image for ID $id already exists. Skipping download."
        return
    fi

    # Fetch the webpage content
    content=$(curl -s "https://steamcommunity.com/sharedfiles/filedetails/?id=$id")

    # Use awk to process the content
    url=$(echo "$content" | awk '{
        gsub(/ /, "");  # Remove spaces from each line
        indexStart = index($0, "ShowEnlargedImagePreview(");
        if(indexStart != 0) {
            subStrStart = indexStart + length("ShowEnlargedImagePreview(") + 1;
            subStrEnd = index($0, ",g_HighlightPlayer);") - 1;
            if(subStrEnd > subStrStart) {
                url = substr($0, subStrStart, subStrEnd - subStrStart);
                sub(/\?.*/, "", url);  # Remove everything from '?' onwards
                print url;
                exit 0;  # Exit after the first match
            }
        }
    }')

    # If no URL found, look for an alternative image source
    if [ -z "$url" ]; then
        url=$(echo "$content" | awk '{
            linkIndex = index($0, "<link rel=\"image_src\" href=\"");
            if(linkIndex != 0) {
                start = linkIndex + length("<link rel=\"image_src\" href=\"");
                end = index($0, "\">");
                if(end > start) {
                    url = substr($0, start, end - start);
                    sub(/\?.*/, "", url);  # Remove everything from '?' onwards
                    print url;
                    exit 0;
                }
            }
        }')
    fi

    # Log the URL
    echo "ID: $id, Name: $name, URL: $url"

    # Download the image and save it as <id>.png
    if [ ! -z "$url" ]; then
        curl -s -o "maps/${name}.png" "$url"
        echo "Image downloaded as ${name}.png"
    else
        echo "No image URL found for ID: $id"
    fi
}

# Function to add a string to the array if it doesn't already exist
addToArray() {
    local newElement=$1
    for element in "${MAP_LIST[@]}"; do
        if [[ $element == $newElement ]]; then
            # echo "The element '$newElement' already exists in the array."
            return
        fi
    done
    MAP_LIST+=("$newElement")
    # echo "Added '$newElement' to the array."
}

# Function to write the list to a file
writeListToFile() {
    local filename=$1
    > "$filename"  # Clear the file content before writing
    for element in "${MAP_LIST[@]}"; do
        echo "$element" >> "$filename"
    done
    echo "List written to file '$filename'."
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

# echo_and_write "| Group | Maps |";
# echo_and_write "| ----- | ---- |";

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
            if [ -n "$current_group" ]; then
                echo_and_write "#### $current_group"
                echo_and_write "<table><tr><td>$maps_in_group</td></tr></table>";
                echo_and_write "";
            fi
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
            # maps_in_group="$maps_in_group[$map](https://steamcommunity.com/sharedfiles/filedetails/?id=$id) ";
            maps_in_group="$maps_in_group<table align=\"left\"><tr><td><img height=\"112\" src=\"https://github.com/kus/cs2-modded-server/blob/assets/images/$map.jpg?raw=true&sanitize=true\"></td></tr><tr><td><a href=\"https://steamcommunity.com/sharedfiles/filedetails/?id=$id\">$map</a><br><sup><sub>host_workshop_map $id</sub></sup></td></tr></table>";
            process_id "$id" "$map"
            addToArray "$id"
        else
            # Extract and print the map name for non-workshop maps
            if [[ $line =~ \"([^\"]+)\" ]]; then
                map="${BASH_REMATCH[1]}"
                # echo_and_write "$map "
                # maps_in_group="$maps_in_group$map ";
                maps_in_group="$maps_in_group<table align=\"left\"><tr><td><img height=\"112\" src=\"https://github.com/kus/cs2-modded-server/blob/assets/images/$map.jpg?raw=true&sanitize=true\"></td></tr><tr><td>$map<br><sup><sub>changelevel $map</sub></sup></td></tr></table>";
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

# Writing the list to a file
writeListToFile "NEW_subscribed_file_ids.txt"

# Directory containing the map files
map_dir="maps"

# Destination directory for compressed images
output_dir="compressed_maps"

# Delete the compressed directory
rm -rf "$output_dir"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Loop through each file in the map directory
for file in "$map_dir"/*; do
    # Check if the file is an image
    if file "$file" | grep -qE 'image|bitmap'; then
        # Extract the filename without the extension
        filename=$(basename "$file" | cut -d. -f1)

        # Compress, convert to JPG and downscale if necessary using ffmpeg
        # -vf "scale='min(1920,iw)':'min(1080,ih)':force_original_aspect_ratio=decrease" resizes images larger than 1920x1080
        # while maintaining aspect ratio
        ffmpeg -i "$file" -vf "scale='min(1920,iw)':'min(1080,ih)':force_original_aspect_ratio=decrease" -qscale:v 2 "$output_dir/${filename}.jpg"
    fi
done

echo "Compression completed."