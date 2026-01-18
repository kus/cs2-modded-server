# CS2 Auto-Update Feature

## Overview

This feature automatically detects and installs Counter-Strike 2 updates from Steam without manual intervention. The auto-updater runs as a background service within the Docker container and periodically checks for new CS2 builds.

## How It Works

1. **Build Monitoring**: The auto-updater periodically queries SteamCMD to check the latest CS2 build ID (AppID 730)
2. **Version Comparison**: It compares the current installed build with the latest available build
3. **Automatic Update**: When a new build is detected:
   - Downloads and installs the update via SteamCMD
   - Gracefully stops the running CS2 server
   - The container automatically restarts the server with the updated version
4. **Logging**: All activities are logged to /tmp/cs2_autoupdate.log

## Configuration

### Environment Variable

Add to your .env file:

```bash
UPDATE_CHECK_INTERVAL=300  # Time in seconds between update checks (default: 300 = 5 minutes)
```

### Recommended Check Intervals

- **Default (300s / 5min)**: Good balance between responsiveness and resource usage
- **Conservative (600s / 10min)**: Reduce API calls if you don't need immediate updates
- **Aggressive (120s / 2min)**: Get updates faster, but increases SteamCMD API usage

## Files

- auto_update.sh: Main auto-update script
- /tmp/cs2_autoupdate.log: Runtime log file
- /home/steam/cs2/.cs2_version: Stores current build ID

## Monitoring

### Check Auto-Update Status

View the auto-update log:
```bash
docker exec cs2-modded-server tail -f /tmp/cs2_autoupdate.log
```

Check if auto-updater is running:
```bash
docker exec cs2-modded-server ps aux | grep auto_update
```

## Benefits

- Zero Downtime Strategy: Updates happen automatically with minimal interruption
- Always Up-to-Date: Server stays current with Valve's latest patches
- Hands-Off Operation: No manual intervention required
- Logging: Full audit trail of all update activities
- Configurable: Adjust check frequency to your needs
