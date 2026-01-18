#!/usr/bin/env bash

# CS2 Auto-Update Script
# Checks for CS2 updates on Steam and automatically updates the server

# Configuration
CHECK_INTERVAL=${UPDATE_CHECK_INTERVAL:-300}  # Check every 5 minutes by default
user="steam"
APPID=730  # CS2 AppID
INSTALL_DIR="/home/${user}/cs2"
VERSION_FILE="${INSTALL_DIR}/.cs2_version"
LOGFILE="/tmp/cs2_autoupdate.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "${LOGFILE}"
}

get_current_buildid() {
    if [ -f "${VERSION_FILE}" ]; then
        cat "${VERSION_FILE}"
    else
        echo "0"
    fi
}

get_latest_buildid() {
    # Use SteamCMD to check the latest available build ID
    local output=$(/steamcmd/steamcmd.sh         +login anonymous         +app_info_update 1         +app_info_print ${APPID}         +quit 2>&1)
    
    # Extract buildid from the output
    local buildid=$(echo "$output" | grep -A 1000 '"730"' | grep -m 1 '"buildid"' | grep -o '[0-9]*')
    
    if [ -z "$buildid" ]; then
        log "ERROR: Could not retrieve buildid from Steam"
        return 1
    fi
    
    echo "$buildid"
}

update_server() {
    log "Update detected! Starting CS2 server update..."
    
    # Run SteamCMD to update the server
    sudo -u $user /steamcmd/steamcmd.sh         +api_logging 1 1         +@sSteamCmdForcePlatformType linux         +@sSteamCmdForcePlatformBitness 64         +force_install_dir ${INSTALL_DIR}         +login anonymous         +app_update ${APPID} validate         +quit
    
    if [ $? -eq 0 ]; then
        log "CS2 update completed successfully"
        return 0
    else
        log "ERROR: CS2 update failed"
        return 1
    fi
}

restart_server() {
    log "Restarting CS2 server..."
    
    # Find and gracefully stop the CS2 server process
    local cs2_pid=$(pgrep -f "cs2.*-dedicated")
    
    if [ -n "$cs2_pid" ]; then
        log "Stopping CS2 server (PID: $cs2_pid)"
        kill -TERM $cs2_pid
        
        # Wait up to 30 seconds for graceful shutdown
        for i in {1..30}; do
            if ! kill -0 $cs2_pid 2>/dev/null; then
                log "CS2 server stopped gracefully"
                break
            fi
            sleep 1
        done
        
        # Force kill if still running
        if kill -0 $cs2_pid 2>/dev/null; then
            log "Force stopping CS2 server"
            kill -KILL $cs2_pid
        fi
    fi
    
    # The container should automatically restart the server via the CMD
    log "Server will restart automatically via container CMD"
}

main() {
    log "CS2 Auto-Update service started (checking every ${CHECK_INTERVAL} seconds)"
    
    # Store initial version
    local latest_build=$(get_latest_buildid)
    if [ -n "$latest_build" ]; then
        echo "$latest_build" > "${VERSION_FILE}"
        log "Initial build ID: $latest_build"
    fi
    
    while true; do
        sleep ${CHECK_INTERVAL}
        
        local current_build=$(get_current_buildid)
        local latest_build=$(get_latest_buildid)
        
        if [ -z "$latest_build" ]; then
            log "WARNING: Could not check for updates, will retry in ${CHECK_INTERVAL} seconds"
            continue
        fi
        
        log "Current build: $current_build | Latest build: $latest_build"
        
        if [ "$current_build" != "$latest_build" ]; then
            log "New CS2 update available! (Current: $current_build -> Latest: $latest_build)"
            
            if update_server; then
                echo "$latest_build" > "${VERSION_FILE}"
                restart_server
                log "Update process completed"
            else
                log "Update failed, will retry on next check"
            fi
        else
            log "No update available"
        fi
    done
}

# Run main function
main
