#!/bin/bash

# chmod +x check-updates.sh

extract_mods() {
    local README_URL="https://raw.githubusercontent.com/kus/cs2-modded-server/master/README.md"
    
    curl -s "$README_URL" | awk '
        BEGIN { modsStarted = 0 }
        $0 == "Mod | Version | Why" { modsStarted = 1; next }  # Look for the specific header to start
        modsStarted == 1 && $0 ~ /^$/ { exit }  # Stop at the first empty line
        modsStarted == 1 && /^\[/ {
            # Extract mod name, URL, and version
            split($0, nameParts, /\[/)
            split(nameParts[2], name, /\]/)
            modName = name[1]
            
            split($0, urlParts, /\(/)
            split(urlParts[2], url, /\)/)
            modURL = url[1]
            
            split($0, versionParts, /`/)
            modVersion = versionParts[2]
            
            # Print in a format that separates fields with a delimiter
            print modName "|" modURL "|" modVersion
        }
    '
}

# Log function for printing messages to the console
log() {
    local message="$1"
    # Print the current date and time along with the message
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message"
}

# Function to fetch the latest release name of a GitHub repository
fetch_latest_release() {
    local url="$1"

	if [[ $url == *"github.com"* ]]; then
		# Use curl to fetch the releases page content
		# Then use grep and sed to find and extract the latest release tag
		# Finally, use sed to remove any characters that aren't numbers or full stops
		local latest_release=$(curl -s "${url}/releases" | grep -m 1 -o 'href="[^"]*/releases/tag/[^"]*"' | sed 's/.*tag\/\([^"]*\)".*/\1/' | sed 's/[^0-9.]//g')

		# Check if we found a release name
		if [ -n "$latest_release" ]; then
			echo "$latest_release"
		else
			echo ""
		fi
	elif [[ $url == *"sourcemm.net"* ]]; then
		# Filter lines with the specific class and extract the version string
		local latest_release=$(curl -s "$url" | grep "class=['\"]quick-download download-link['\"]" | grep -o "mmsource-[0-9.]*-git[0-9]*-linux.tar.gz" | sed -E 's/mmsource-([0-9.]+)-git([0-9]+)-linux.tar.gz/\1-\2/' | head -n 1)

		# Check if we found a release name
		if [ -n "$latest_release" ]; then
			echo "$latest_release"
		else
			echo ""
		fi
	else
		echo ""
	fi
}


# Function to fetch when the last commit was made to a GitHub repository
fetch_last_updated() {
    local url="$1"

	if [[ $url == *"github.com"* ]]; then
		# Get last commit date
		latest_release=$(curl -s "${url}/commits" | grep -m 1 -o '"commitGroups":\[{"title":"[^"]*"' | sed 's/.*"title":"\([^"]*\)".*/\1/' | sed 's/[^a-zA-Z 0-9]//g')
		if [ -n "$latest_release" ]; then
			echo "$latest_release"
		else
			echo ""
		fi
	else
		echo ""
	fi
}

main() {
	# Call extract_mods and read output into an array
    IFS=$'\n' read -rd '' -a modList < <(extract_mods)
    
    # Reset IFS to default
    IFS=$' \t\n'
    
    # Loop through the array and print each mod's details
    for mod in "${modList[@]}"; do
        IFS='|' read -ra ADDR <<< "$mod" # Split each line based on "|"
		local name="${ADDR[0]}"
		local url="${ADDR[1]}"
		local version="${ADDR[2]}"
		local latest_release=$(fetch_latest_release "$url")
		local last_updated=$(fetch_last_updated "$url")

		if [ -n "$latest_release" ]; then
			if [ "$version" == "$latest_release" ]; then
				echo -e "\033[0;32m✅ ${name} ${latest_release}\033[0m"
			else
				echo -e "\033[0;33m📦 ${name} update available ${version} > ${latest_release} ${url}\033[0m"
			fi
		elif [ -n "$last_updated" ]; then
			echo -e "\033[1;30m🔍 ${name} ${version} - Last updated ${last_updated} ${url}\033[0m"
		else
			echo -e "\033[0;31m🚫 ${name} ${version} - Could not find latest version or last update ${url}\033[0m"
		fi
    done
}

main
