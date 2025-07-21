# Counter-Strike 2 (CS2) Modded Dedicated Server

If you are looking for the CS:GO version you can still access that [here](https://github.com/kus/csgo-modded-server/tree/csgo).

## About

A single modded Counter-Strike 2 (CS2) Modded Dedicated Server that you can [change the active mod](#changing-game-modes) on the server from chat or server console. [Maps are preconfigured per game mode](#what-maps-are-preconfigured-with-each-mode) and change when the game mode changes.

Each game mode has a hand full of maps preset so you are ready to go and it's [easy to add more](#setting-maps-for-different-game-modes).

- Competitive (using [MatchZy](https://github.com/shobhit-pathak/MatchZy#usage-commands))
- Practice (record grenade throws etc) (using [MatchZy](https://github.com/shobhit-pathak/MatchZy#usage-commands))
- Wingman (allows more than 4 players) ([Steam API key](#playing-workshop-mapscollections) required)
- GunGame ([Steam API key](#playing-workshop-mapscollections) required)
- Custom Deathmatch ([Steam API key](#playing-workshop-mapscollections) required)
- Prefire practice
- Retakes
- Executes
- One In The Chamber
- 1v1 (with arenas) ([Steam API key](#playing-workshop-mapscollections) required)
- ScoutzKnivez ([Steam API key](#playing-workshop-mapscollections) required)
- KZ ([Steam API key](#playing-workshop-mapscollections) required)
- BHop ([Steam API key](#playing-workshop-mapscollections) required)
- Surf ([Steam API key](#playing-workshop-mapscollections) required)
- Mini Games ([Steam API key](#playing-workshop-mapscollections) required)
- Deathrun ([Steam API key](#playing-workshop-mapscollections) required)
- Course format (tests players with different traps, kz, surf, bhop) ([Steam API key](#playing-workshop-mapscollections) required)
- Hide n Seek ([Steam API key](#playing-workshop-mapscollections) required)
- Battle Royale ([Steam API key](#playing-workshop-mapscollections) required)
- Soccer ([Steam API key](#playing-workshop-mapscollections) required)
- Battle Ball ([Steam API key](#playing-workshop-mapscollections) required)

You can also enable modifiers in game modes from the `!settings` menu in chat i.e. Competitive with random rounds like [NadeKings video](https://www.youtube.com/watch?v=OQQBUFB56Iw).

- [Random Rounds](https://www.youtube.com/watch?v=OQQBUFB56Iw) - CS2, but every round is a SURPRISE.
- [WarcraftMod](https://www.youtube.com/watch?v=Z9HdF47zPss) - An open-source Warcraft mod for CS2 featuring a fully-fledged RPG system.
- Roll The Dice - Roll the dice to get either a positive or negative effect for the current round.
- Bunny hopping

Every time you want to boot the server, you should run `gcp.sh` (if on Google Cloud) or `install.sh` (on Linux) or `update.bat` (on Windows) and it will ensure your OS is up to date, CS2 is up to date, and pull down the latest patches from this mod (any updates that I push up).

Obviously, any changes you have made to the files in this mod will be overwritten so I have created a "[custom files](#custom-files)" folder where you mirror the contents of the `game/csgo/` folder, and any files you want to tweak, you put in there in the same spot and they will always overwrite the mods default files. Read more about it [here](#custom-files).

The simple quick setup:

1. [Create your firewall rules](#create-firewall-rule)
2. [Provision your server on Google Cloud](#create-instance)
3. [SSH into server](#ssh-to-server)
4. [Install mod](#install-mod)
5. [Create your custom files for hostname, admins etc](#custom-files)
6. [Add admins](#acessing-admin-menu)
7. Ensure you have followed the steps for creating an [online server](#creating-an-online-server) or [LAN server](#creating-a-lan-server)
8. Kill server if running `./stop.sh` and start again `gcp.sh` (if on Google Cloud) or `install.sh` (on Linux)

Your server should be up and running!

To check everything is working correctly run the following commands in the server console:

- `meta list` and you should see `CounterStrikeSharp` in the output
- `css_plugins list` and you should see a few plugins in the output

If you see content in both; everything is working.

> [!IMPORTANT]
> Using RCON whilst connected to the server does not work. See discussion [here](https://www.reddit.com/r/GlobalOffensive/comments/167spzi/cs2_rcon/).
> The current work arounds are:
>
> - I have included [CS2Rcon](https://github.com/LordFetznschaedl/CS2Rcon) which allows admins to use !rcon in chat.
> - You can disconnect from the server and use `rcon_address IP:PORT` in console and you can use rcon commands.
> - Use an external RCON program which has implemented the RCON protocol such as [this](https://github.com/fpaezf/CS2-RCON-Tool-V2).

Useful things to know:

- [Access admin menu](#acessing-admin-menu)
- [Changing game mode](#changing-game-modes)
- [Changing maps](#changing-maps)
- [Player commands](#player-commands)

Getting up and running:

- [Running on Google Cloud](#running-on-google-cloud)
- [Running on Linux](#running-on-linux)
- [Running in Docker](#running-in-docker)
- [Running on Windows](#running-on-windows)

## Mods installed

Mod | Version | Why
--- | --- | ---
[Metamod:Source](https://www.metamodsource.net/downloads.php?branch=dev) | `2.0.0-1359` | Sits between the Game and the Engine, and allows plugins to intercept calls that flow between
[CounterStrikeSharp](https://github.com/roflmuffin/CounterStrikeSharp) | `1.0.328` | Attempts to implement a .NET Core scripting layer on top of a Metamod Source Plugin, allowing developers to create plugins that interact with the game server in a modern language (C#)
[MultiAddonManager](https://github.com/Source2ZE/MultiAddonManager) | `1.4.2` | Allows you to use multiple workshop addons at once and have clients download them
[ServerListPlayersFix](https://github.com/Source2ZE/ServerListPlayersFix) | `1.0.1-Rebuild-04102024` | Fixes players not showing up in the server browser
[MovementUnlocker](https://github.com/Source2ZE/MovementUnlocker)| `1.4` | Removes max speed limitation from players on the ground, feels like CS:S [How?](#i-run-a-surfkzbhop-server-and-want-movementunlocker-and-cs2fixes-rampbugfix-permanently-on)
[CS2Fixes-RampbugFix](https://github.com/Interesting-exe/CS2Fixes-RampbugFix)| `2025-05-22` | Minimizes rampbugs (needs to be enabled via `!settings` [How?](#i-run-a-surfkzbhop-server-and-want-movementunlocker-and-cs2fixes-rampbugfix-permanently-on))
[CS2_ExecAfter](https://github.com/kus/CS2_ExecAfter) | `1.0.0` | Executes a command after server event (i.e. OnMapStart) or a delay.
[CS2 Remove Map Weapons](https://github.com/kus/CS2-Remove-Map-Weapons) | `1.0.1` | Remove weapons from the map in CS2 as `mp_weapons_allow_map_placed 0` does not work.
[GameModeManager](https://github.com/nickj609/GameModeManager)| `1.0.62` | A simple Counter-Strike 2 server plugin that helps admins manage game modes and map groups.
[cs2-inventory-simulator](https://github.com/ianlucas/cs2-inventory-simulator-plugin)| `27` | Use any Weapon, Knife, Gloves, Agent, Music Kit, Pin or Graffiti. [How?](#skin-changer)
[MatchZy](https://github.com/shobhit-pathak/MatchZy) | `0.8.10` | MatchZy is a plugin for CS2 for running and managing practice/pugs/scrims/matches with easy configuration!
[MapConfigurator](https://github.com/ManifestManah/MapConfigurator)| `1.0.2` | Allows you to quick and easily create unique configuration files for each map on your server.
[K4-DamageInfo](https://github.com/KitsuneLab-Development/K4-DamageInfo) | `2.4.0` | Displays the amount of damage players have inflicted on the victim's HP and Armor, as well as the hit groups they have hit.
[SimpleAdmin](https://github.com/connercsbn/SimpleAdmin/)| `0.1.2` | Adds basic administrator functions
[CS2Rcon](https://github.com/LordFetznschaedl/CS2Rcon)| `1.2.0` | This is a rudimentary implementation of a RCON plugin for CS2 using CounterStrikeSharp as RCON does not work whilst connected to the server
[SharpTimer](https://github.com/Letaryat/poor-sharptimer)| `0.3.1x` | SharpTimer is a simple Surf/KZ/Bhop/MG/Deathrun/etc CS2 Timer plugin
[STFixes](https://github.com/rcnoob/STFixes)| `1.0.4` | A CounterStrikeSharp plugin with common fixes and features for SharpTimer servers
[GunGame](https://github.com/ssypchenko/cs2-gungame)| `1.1.2` | GunGame mode on Counter Strike Sharp
[K4-Arenas](https://github.com/KitsuneLab-Development/K4-Arenas)| `2.0.7` | All in one arena plugin, that you can use to have a ladder type gameplay. Support all map, 2v2/3v3/etc [How?](#enable-k4-arenas)
[CS2 Retakes](https://github.com/B3none/cs2-retakes)| `2.1.3` | CS2 implementation of retakes. Based on the version for CS:GO by Splewis.
[CS2 Instadefuse](https://github.com/B3none/cs2-instadefuse)| `2.0.0` | Allows a CT to instantly defuse the bomb when nothing can prevent defusal. Written in C# for CounterStrikeSharp.
[CS2 Retakes Allocator](https://github.com/yonilerner/cs2-retakes-allocator)| `2.4.2` | Advanced weapon allocation for B3none/cs2-retakes
[CS2 Whitelist](https://github.com/PhantomYopta/CS2_WhiteList)| `1.0.0`| Restricts access to the server for SteamID members/employees listed in the whitelist. [How?](#enable-whitelist-so-only-a-list-of-people-can-play)
[CS2 Executes](https://github.com/zwolof/cs2-executes)| `1.0.6` | CS2 implementation of executes. Based on the version for CS:GO by Splewis.
[CS2 Advertisement](https://github.com/partiusfabaa/cs2-advertisement)| `1.0.8fix` | Allows you to show ads in chat/center/panel. [How?](#enable-advertisements)
[CS2 Deathmatch](https://github.com/NockyCZ/CS2-Deathmatch)| `1.2.9` | Custom Deathmatch CS2 plugin (Includes custom spawnpoints, multicfg, gun selection, spawn protection, etc)
[OpenPrefirePrac](https://github.com/lengran/OpenPrefirePrac)| `0.1.47` | Multiple prefire practices on competitive maps and support multiplayer practicing simultaneously.
[CS2-CustomVotes](https://github.com/imi-tat0r/CS2-CustomVotes)| `1.1.3` | A plugin for Counter-Strike 2 to create custom votes for settings.
[deathrun-manager](https://github.com/leoskiline/cs2-deathrun-manager)| `0.1.0` | Deathrun Manager for CounterStrikeSharp Framework CS2.
[AnnouncementBroadcaster](https://github.com/lengran/CS2AnnouncementBroadcaster) | `0.5` | Conditional messages, OnCommand, OnPlayerConnect, OnRoundStart, and TimerMsgs.
[CS2-GameModifiers](https://github.com/Lewisscrivens/CS2-GameModifiers-Plugin) | `1.0.3` | CS2, but every round is a SURPRISE. Inspiration from [NadeKings video](https://www.youtube.com/watch?v=OQQBUFB56Iw).
[CS2FunMatchPlugin](https://github.com/TitaniumLithium/CS2FunMatchPlugin) | `1.1.1` | Random fun mode every round
[RollTheDice](https://github.com/Kandru/cs2-roll-the-dice) | `1.3.19` | Roll the dice to get either a positive or negative effect for the current round.
[CS2-FixRandomSpawn](https://github.com/qstage/CS2-FixRandomSpawn) | `1.1.4` | Fixes ConVar `mp_randomspawn` for any game mode.
[CS2-MutualScoringPlayers](https://github.com/qstage/CS2-MutualScoringPlayers) | `1.0.1` | Keeps score of kills between players.
[CS2WarcraftMod](https://github.com/Wngui/CS2WarcraftMod) | `3.3.1` | An open-source Warcraft mod for CS2 featuring a fully-fledged RPG system.
[cs2-advanced-weapon-system](https://github.com/schwarper/cs2-advanced-weapon-system) | `1.4` | An advanced weapon system that gives full control over weapon attributes, dynamic adjustments to weapon behaviour, restrictions and advanced customisation.
[cs2-OneInTheChamber](https://github.com/ShookEagle/cs2-OneInTheChamber) | `1.0.0` | One in the Chamber game mode.
[cs2-quake-sounds](https://github.com/Kandru/cs2-quake-sounds) | `1.0.7` | Quake Sounds on multi kills.
[CS2-WeaponSpeed](https://github.com/akanora/CS2-WeaponSpeed) | `1.2` | Gives players a speed boost when they fire specified weapons.
[SpectatorList-CS2](https://github.com/wiruwiru/SpectatorList-CS2) | `build-9` | Shows real-time spectators in on-screen display.
[BotsNoKnife](https://discord.com/channels/1160907911501991946/1365937101886984262) | `1.0` | Keeps Bots from using the knife.

## Share the love

If you appreciate the project then please take the time to star the repository 🙏

<img alt="Star the project" src="https://github.com/kus/cs2-modded-server/blob/assets/assets/star.png?raw=true&sanitize=true">

## Stay up to date

Subscribe to release notifications and stay up to date with the latest features and patches:

<img alt="Subscribe to updates" src="https://github.com/kus/cs2-modded-server/blob/assets/assets/watch.png?raw=true&sanitize=true">

## Custom files

> [!NOTE]  
> Any reference to a path is always the root of the installation. Which on Linux will typically be `/home/steam/cs2/` and on Windows where ever you extracted the zip.
>
> For example on Linux:
> `/custom_files/addons/counterstrikesharp/configs/admins.json` full path is `/home/steam/cs2/custom_files/addons/counterstrikesharp/configs/admins.json`
> `/game/csgo/addons/counterstrikesharp/configs/admins.json` full path is `/home/steam/cs2/game/csgo/addons/counterstrikesharp/configs/admins.json`

Any changes you have made to the files in this mod will be overwritten when the update scripts are ran. I have created a folder `/custom_files/` in the root of the project, where you mirror the contents of the `csgo/` folder, and any files you want to tweak, you put in there in the same spot and they will always overwrite the mods default files.

So this can be used to set the server hostname to something you want, set the RCON or serverpassword or set the admins of the server.

You can see an example of what I use on my server in the `/custom_files_example/` directory, which sets the hostname, server image and admins.

For example; if you want to add yourself as an admin, that file is located `/game/csgo/addons/counterstrikesharp/configs/admins.json`. So to make your tweak to it, you would copy that file to `/custom_files/addons/counterstrikesharp/configs/admins.json` and add yourself as an admin at the bottom. Then when the update scripts run, it will copy your custom file at `/custom_files/addons/counterstrikesharp/configs/admins.json` and overwrite the default mod file at `/game/csgo/addons/counterstrikesharp/configs/admins.json`.

If you want to change the server name, or make any changes to any mod settings use the `/cfg/custom_MOD.cfg` as it executes at the end and can overwrite any setting. So if you wanted to change the server name for GunGame, you would copy `/game/csgo/cfg/custom_dm.cfg` to `/custom_files/cfg/custom_dm.cfg` and and write `hostname "shipREKT GunGame +Deathmatch +Turbo"` and any other settings you want and this file will overwrite `/game/csgo/cfg/custom_dm.cfg` each time the `gcp.sh`/`install.sh`/`win.bat` script is ran, and these settings will run at the end when you load the GunGame mod.

### Dynamically creates config files in plugin folder

If a plugin creates a config file in the plugins folder where the dll is (i.e.: `/game/csgo/addons/counterstrikesharp/plugins/disabled/Advertisement/advertisement.json`) it will be deleted when the server starts as the `addons` folder is deleted to make sure old plugins are removed if I removed them. You need to copy this file and your changes to your `/custom_files/` folder so it merges it back in. You would put the example file in `/custom_files/addons/counterstrikesharp/plugins/disabled/Advertisement/advertisement.json` and every time the server starts it will merge it back in and you will have your changes.

To generate this directory, you can run the `gcp.sh` script (if on Google Cloud), `install.sh` script on Linux once or on `win.bat` script on Windows where you extracted the mod zip and this is where you would put your custom modifications.

## Creating an online server

If you are hosting an online server, you need to create a Steam [Game Login Token](https://steamcommunity.com/dev/managegameservers), your server will not run online without this. Put this value in the `STEAM_ACCOUNT` environment variable.

You also need to create an [authorization key](http://steamcommunity.com/dev/apikey) which will allow your server to download maps from the workshop. Put this value in the `API_KEY` environment variable.

See all available [environment variables](#environment-variables).

**You must connect to the server from the public IP, not the LAN IP even if you are on the same network. The script logs the public IP `Starting server on XXX.XXX.XXX.XXX:27015`**

## Creating a LAN server

Set the environment variable `LAN` to `1`.

You also need to create an [authorization key](http://steamcommunity.com/dev/apikey) which will allow your server to download maps from the workshop. Put this value in the `API_KEY` environment variable.

See all available [environment variables](#environment-variables).

## Environment variables

### Available via environment variable only

*On Windows set these in `win.ini`.*

Key | Default value | What is it
--- | --- | ---
`API_KEY` | `changeme` | To download maps from the workshop, your server needs access to the steam web api. To allow this you'll need an authorization key which you can generate [here](http://steamcommunity.com/dev/apikey)
`IP` | `` | Not required. Allows the server IP to be set. Useful if a CS2 server needs to be bound to a specific IP address.
`PORT` | `27015` | Server port
`TICKRATE` | `128` | Server tickrate MM is 64, Faceit is 128
`MAXPLAYERS` | `32` | Max player limit
`CUSTOM_FOLDER` | `custom_files` | Folder of your own modifications to the mod that mirror the csgo/ structure and overwrite the mode files. More on that [here](#custom-files)
`RCON_PASSWORD` | `changeme` | RCON password to control server from console also remotely configure
`STEAM_ACCOUNT` | `` | To host a server online, you need to create a Steam [Game Login Token](https://steamcommunity.com/dev/managegameservers). Your server will not run online without this
`SERVER_PASSWORD` | `` | If you want a password protected server
`LAN` | `0` | If the server is a LAN only server
`EXEC` | `on_boot.cfg` | Config file to run when server boots. If switching gamemode, it's recommended to do a delay see the example `on_boot.cfg` file
`DUCK_DOMAIN` | `` | (Linux only) [Duck DNS](https://www.duckdns.org/) domain if you want to utalise the free service to get a domain for your server instead of IP
`DUCK_TOKEN` | `` | (Linux only) [Duck DNS](https://www.duckdns.org/) access token to update domain when server boots

## Playing workshop maps/collections

To download maps from the workshop, your server needs access to the steam web api. To allow this you'll need an authorization key which you can generate [here](http://steamcommunity.com/dev/apikey) and set `API_KEY` to the key.

The console command for hosting a workshop map is `host_workshop_map fileid` where `fileid` is the number that comes after `?id=` in the workshop URL for example: [https://steamcommunity.com/sharedfiles/filedetails/?id=2433686680](https://steamcommunity.com/sharedfiles/filedetails/?id=2433686680)

The console command for hosting a workshop collection is `host_workshop_collection collectionid` where `collectionid` is the number that comes after `?id=` in the workshop URL for example: [https://steamcommunity.com/sharedfiles/filedetails/?id=1092904694](https://steamcommunity.com/sharedfiles/filedetails/?id=1092904694). This command will then download all maps in the collection and create a mapgroup out of them, then host it.

## Setting maps for different game modes

Copy the file `/game/csgo/gamemodes_server.txt` following the [custom files](#custom-files) steps (`/custom_files/gamemodes_server.txt`) and add the maps you want per gamemode. Most gamemodes fall under casual, but I have created unique groups for each mode so adding your own maps is easy by updating this one file.

It isn't required, but you should add the fileid into `/game/csgo/subscribed_file_ids.txt` following the [custom files](#custom-files) steps (`/custom_files/subscribed_file_ids.txt`) so the server keeps it up to date.

If you have python available, you can use our tool available to add a map to your custom game mode map groups: `python scripts/add-map.py <group_name> <map_name> [workshop_id] --custom`. Refer to `scripts/add-map.py` for more information.
## Running on Google Cloud

### Create firewall rule

```
gcloud compute firewall-rules create source \
--allow tcp:27015-27020,tcp:80,udp:27015-27020
```

### Create instance

Ensure you have all the settings for your [environment variables](#environment-variables).

If you have issues with the server not handling load, you may want to consider [compute-optimized](https://cloud.google.com/compute/vm-instance-pricing#compute-optimized_machine_types) machine `c2-standard-4`.

```
gcloud beta compute instances create <instance-name> \
--maintenance-policy=TERMINATE \
--project=<project> \
--zone=australia-southeast1-c \
--machine-type=n2-standard-2 \
--network-tier=PREMIUM \
--metadata=RCON_PASSWORD=changeme,STEAM_ACCOUNT=changeme,API_KEY=changeme,DUCK_DOMAIN=changeme,DUCK_TOKEN=changeme,startup-script="echo \"Delaying for 30 seconds...\" && sleep 30 && cd / && /gcp.sh" \
--no-restart-on-failure \
--scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/compute.readonly,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
--tags=source \
--image-family=ubuntu-2204-lts \
--image-project=ubuntu-os-cloud \
--boot-disk-size=60GB \
--boot-disk-type=pd-standard \
--boot-disk-device-name=<instance-name>
```

### SSH to server

```
gcloud compute ssh <instance-name> \
--zone=australia-southeast1-c
```

### Install mod

```
sudo su
cd / && curl --silent --output "gcp.sh" "https://raw.githubusercontent.com/kus/cs2-modded-server/master/gcp.sh" && chmod +x gcp.sh && bash gcp.sh
```

If the installation has paused for a long time, restart the server and do it again.

### Stop server

```
gcloud compute instances stop <instance-name> \
--zone australia-southeast1-c
```

### Start server

```
gcloud compute instances start <instance-name> \
--zone australia-southeast1-c
```

### Delete server

```
gcloud compute instances delete <instance-name> \
--zone australia-southeast1-c
```

### Push file to server from local machine

For example a map:

```
On local:
gcloud config set project <project>
cd /path/to/folder
gcloud compute scp de_kus.vpk root@<instance-name>:/home/steam/cs2/game/csgo/maps --zone australia-southeast1-c

On server SSH:
cd /home/steam/cs2/game/csgo/maps
chown steam:steam de_kus.vpk
chmod 644 de_kus.vpk
```

### Download from server

`gcloud compute scp root@<instance-name>:/home/steam/cs2/gamecsgo/cfg/comp.cfg  ~/Desktop/`

### Turn VM off at 3:30AM every day

SSH into the VM

Switch to root `sudo su`

Check the timezone your server is running in `sudo hwclock --show`

Open crontab file `nano /etc/crontab`

Append to the end of the crontab file `30 3    * * *   root    shutdown -h now`

Save `CTRL + X`

## Running on Linux

Make sure you have **60GB free space**.

Ensure you have all the settings for your [environment variables](#environment-variables).

- **If setting up internet server:**

   Set environment variable `STEAM_ACCOUNT` to your [Game Server Login Token](https://steamcommunity.com/dev/managegameservers)

   Make sure you [port forward](https://portforward.com/router.htm) on your router TCP: `27015` and UDP: `27015` & `27020` so players can connect from the internet.

   **You must connect to the server from the public IP, not the LAN IP even if you are on the same network. The script logs the public IP `Starting server on XXX.XXX.XXX.XXX:27015`**

- **If setting up LAN server:**

   Set environment variable `LAN` to `1`

```
sudo su
export RCON_PASSWORD="changeme"
export API_KEY="changeme"
export STEAM_ACCOUNT=""
export SERVER_PASSWORD=""
export PORT="27015"
export TICKRATE="128"
export MAXPLAYERS="32"
cd / && curl --silent --output "install.sh" "https://raw.githubusercontent.com/kus/cs2-modded-server/master/install.sh" && chmod +x install.sh && bash install.sh
```

- **If running for the first time**

To check everything is working correctly run the following commands in the server console:

- `meta list` and you should see `CounterStrikeSharp` in the output
- `css_plugins list` and you should see a few plugins in the output

If you see content in both; everything is working.

When you join the server you can [change game modes](#changing-game-modes).

## Running in Docker

Make sure Docker is installed and about 40 GB disk space is free.

- **If setting up for internet server:**

   Set 'STEAM_ACCOUNT' variable in '.env'-file in the root if the repository.
   For workshop maps set 'API_KEY' in '.env'-file.

   Or provide via -e to the run command

It is also recommended to have a cron to reboot the container once a day, this will allow for the server to auto-update when new CS versions are released

```bash
docker run
  --name='cs2'
  -e 'API_KEY'='REPLACE_ME'
  -p '27015:27015/tcp'
  -p '27015:27015/udp'
  -p '27020:27020/udp'
  -v '/SOME/DIR/STORES_MAIN_INSTALL/':'/home/steam/cs2/':'rw'
  -v '/SOME/DIR/STORES_CUSTOM_OVERRIDES':'/home/custom_files/':'rw'
  'ghcr.io/kus/cs2-modded-server:latest' 
```

Note: if you don't mount `/home/steam/cs2/` it will download the game every launch
Note: If you find issues between version upgrades your first step should be to blat `/SOME/DIR/STORES_MAIN_INSTALL/` so that it downloads completely fresh

Or to build yourself

You can either Download this repo and extract it to where you want your server (i.e. C:\Server\cs2-modded-server) or use git and clone the repo `git clone https://github.com/kus/cs2-modded-server.git` and run your server from inside of it. This way you can simply git pull updates.

- **Build docker image:**

   `docker build -t cs2-modded-server .`

- **Run the server**

   `docker compose up`

## Running in Kubernetes

You should have a Kubernetes distribution already running. To set up a K8s Cluster please refer to [RKE2 Quickstart](https://docs.rke2.io/install/quickstart)

First create a namespace for your deployment with `kubectl create ns game-server`

To securly pass .env vars to the container, *Kubernetes Secrets* are used. Make a file called `cs2-secret.yaml`. Your keys need to be base64 encoded. Simply `echo "my_key" | base64` in your bash shell and then put them in the data section of your Secret manifest.

```
apiVersion: v1
kind: Secret
metadata:
  name: cs2-secret
  namespace: game-server
type: Opaque
data:
  STEAM_ACCOUNT: {your_steam_account_key_goes_here}
  API_KEY: {your_api_key_goes_here}
```

Assuming you already have a `defaultStorageClass` and a `defaultLoadBalancerClass` you can apply the manifest with

```kubectl apply -f manifest.yaml```

Note: `custom_files` is mounted as a `hostPath` this wont work for multi-node setups. For this there are several solutions such as initContainer or Operators to automatically update the `custom_files` 

Your service will receive an external IP and can be found with `kubectl get svc -n game-server`.


## Running on Windows

Make sure you have **60GB free space**.

If you have git installed; it is recommended to use git and clone the repo `git clone https://github.com/kus/cs2-modded-server.git` and run your server from inside of it. This way you can simply `git pull` updates (or run `update.bat`). Alternatively you can [Download this repo](https://github.com/kus/cs2-modded-server/archive/master.zip) and extract it to where you want your server (i.e. `C:\Server\cs2-modded-server`) but you will manually have to handle updates.

All the following instructions will use the repo folder location as the root.

~~Create a folder `steamcmd` and [download SteamCMD](https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip) and extract it inside `steamcmd` so you should have `\steamcmd\steamcmd.exe`.~~

* Manual download of SteamCMD is no longer necessary as the startup script will handle it for you now.

To download maps from the workshop, your server [needs access](https://developer.valvesoftware.com/wiki/Counter-Strike:_Global_Offensive/Dedicated_Servers#Steam_Workshop) to the Steam Web API. To allow this, open `\win.ini` and set `cs_api_key` to your [Steam Web API Key](http://steamcommunity.com/dev/apikey).

- **If setting up internet server:**

   Open `\win.ini`

   Set `IP` to your [public ip](http://checkip.amazonaws.com/)

   Set `STEAM_ACCOUNT` to your [Game Server Login Token](https://steamcommunity.com/dev/managegameservers)

   Set `API_KEY` to your [Steam Web API key](http://steamcommunity.com/dev/apikey) (required to play workshop maps)

   Make sure you [port forward](https://portforward.com/router.htm) on your router TCP: `27015` and UDP: `27015` & `27020` so players can connect from the internet.

   **You must connect to the server from the public IP, not the LAN IP even if you are on the same network.**

- **If setting up LAN server:**

   Open `\win.ini`

   Set `LAN` to `1`

   Set `API_KEY` to your [Steam Web API key](http://steamcommunity.com/dev/apikey) (required to play workshop maps)

[Add admins](#acessing-admin-menu)

Run `win.bat`

Accept both Private and Public connections on Windows Firewall.

- **If running for the first time**

To check everything is working correctly run the following commands in the server console:

- `meta list` and you should see `CounterStrikeSharp` in the output
- `css_plugins list` and you should see a few plugins in the output

If you see content in both; everything is working.

When you join the server you can [change game modes](#changing-game-modes).

## FAQ

### Player commands

#### !rtv

Players can start a vote to change the map in the current mod by typing `!rtv` in chat.

<img alt="Vote to change map" src="https://github.com/kus/cs2-modded-server/blob/assets/assets/rtv.png?raw=true&sanitize=true">

#### !gamemode

Players can start a vote to change the game mode by typing `!gamemode` in chat.

<img alt="Vote to change game mode" src="https://github.com/kus/cs2-modded-server/blob/assets/assets/vote-gamemode.png?raw=true&sanitize=true">

You can also start a specific game mode vote by typing `!comp`, `!wingman`, `!dm`, `!gg`, `!1v1`, `!awp`, `!aim`, `!prefire`, `!executes`, `!retake`, `!prac`, `!bhop`, `!kz`, `!surf`, `!minigames`, `!deathrun`, `!course`, `!scoutzknivez`, `!hns`, `!br`, `!soccer`, `!1.6`.

### What maps are preconfigured with each mode?

#### mg_active

<table><tr><td><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_ancient.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_ancient<br><sup><sub>changelevel de_ancient</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_anubis.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_anubis<br><sup><sub>changelevel de_anubis</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_inferno.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_inferno<br><sup><sub>changelevel de_inferno</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_mirage.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_mirage<br><sup><sub>changelevel de_mirage</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_nuke.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_nuke<br><sup><sub>changelevel de_nuke</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_dust2.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_dust2<br><sup><sub>changelevel de_dust2</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_train.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_train<br><sup><sub>changelevel de_train</sub></sup></td></tr></table></td></tr></table>

#### mg_comp

<table><tr><td><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/cs_italy.jpg?raw=true&sanitize=true"></td></tr><tr><td>cs_italy<br><sup><sub>changelevel cs_italy</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/cs_office.jpg?raw=true&sanitize=true"></td></tr><tr><td>cs_office<br><sup><sub>changelevel cs_office</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_vertigo.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_vertigo<br><sup><sub>changelevel de_vertigo</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_ancient.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_ancient<br><sup><sub>changelevel de_ancient</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_anubis.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_anubis<br><sup><sub>changelevel de_anubis</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_dust2.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_dust2<br><sup><sub>changelevel de_dust2</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_inferno.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_inferno<br><sup><sub>changelevel de_inferno</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_mirage.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_mirage<br><sup><sub>changelevel de_mirage</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_nuke.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_nuke<br><sup><sub>changelevel de_nuke</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_train.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_train<br><sup><sub>changelevel de_train</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_overpass.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_overpass<br><sup><sub>changelevel de_overpass</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_vertigo.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_vertigo<br><sup><sub>changelevel de_vertigo</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_jura.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_jura<br><sup><sub>changelevel de_jura</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_grail.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_grail<br><sup><sub>changelevel de_grail</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/cs_agency.jpg?raw=true&sanitize=true"></td></tr><tr><td>cs_agency<br><sup><sub>changelevel cs_agency</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_basalt.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3329258290">de_basalt</a><br><sup><sub>host_workshop_map 3329258290</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_edin.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3328169568">de_edin</a><br><sup><sub>host_workshop_map 3328169568</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_assembly.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3071005299">de_assembly</a><br><sup><sub>host_workshop_map 3071005299</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_cbble.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3329387648">de_cbble</a><br><sup><sub>host_workshop_map 3329387648</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_cache.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3437809122">de_cache</a><br><sup><sub>host_workshop_map 3437809122</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_pipeline.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3079872050">de_pipeline</a><br><sup><sub>host_workshop_map 3079872050</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_biome.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3075706807">de_biome</a><br><sup><sub>host_workshop_map 3075706807</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/mp_raid.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070346180">mp_raid</a><br><sup><sub>host_workshop_map 3070346180</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_mutiny.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070766070">de_mutiny</a><br><sup><sub>host_workshop_map 3070766070</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/cs_assault.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070594412">cs_assault</a><br><sup><sub>host_workshop_map 3070594412</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_ruins_d_prefab.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3072352643">de_ruins_d_prefab</a><br><sup><sub>host_workshop_map 3072352643</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/cs_militia.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3089953774">cs_militia</a><br><sup><sub>host_workshop_map 3089953774</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_aztec_hr.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3079692971">de_aztec_hr</a><br><sup><sub>host_workshop_map 3079692971</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_akiba.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3108513658">de_akiba</a><br><sup><sub>host_workshop_map 3108513658</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/cs_insertion2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3236615060">cs_insertion2</a><br><sup><sub>host_workshop_map 3236615060</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_train.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070284539">de_train</a><br><sup><sub>host_workshop_map 3070284539</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_mills.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3152430710">de_mills</a><br><sup><sub>host_workshop_map 3152430710</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_thera.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3121217565">de_thera</a><br><sup><sub>host_workshop_map 3121217565</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_season.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3073892687">de_season</a><br><sup><sub>host_workshop_map 3073892687</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_ema.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3386116667">de_ema</a><br><sup><sub>host_workshop_map 3386116667</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/twofort_cs2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3345551391">twofort_cs2</a><br><sup><sub>host_workshop_map 3345551391</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_rats_remake.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3460962520">de_rats_remake</a><br><sup><sub>host_workshop_map 3460962520</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_mirage_bricks.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3464733042">de_mirage_bricks</a><br><sup><sub>host_workshop_map 3464733042</sub></sup></td></tr></table></td></tr></table>

#### mg_retake

<table><tr><td><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_ancient.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_ancient<br><sup><sub>changelevel de_ancient</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_anubis.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_anubis<br><sup><sub>changelevel de_anubis</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_inferno.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_inferno<br><sup><sub>changelevel de_inferno</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_mirage.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_mirage<br><sup><sub>changelevel de_mirage</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_nuke.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_nuke<br><sup><sub>changelevel de_nuke</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_dust2.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_dust2<br><sup><sub>changelevel de_dust2</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_train.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_train<br><sup><sub>changelevel de_train</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_overpass.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_overpass<br><sup><sub>changelevel de_overpass</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_vertigo.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_vertigo<br><sup><sub>changelevel de_vertigo</sub></sup></td></tr></table></td></tr></table>

#### mg_prefire

<table><tr><td><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_ancient.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_ancient<br><sup><sub>changelevel de_ancient</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_anubis.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_anubis<br><sup><sub>changelevel de_anubis</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_inferno.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_inferno<br><sup><sub>changelevel de_inferno</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_mirage.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_mirage<br><sup><sub>changelevel de_mirage</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_nuke.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_nuke<br><sup><sub>changelevel de_nuke</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_dust2.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_dust2<br><sup><sub>changelevel de_dust2</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_train.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_train<br><sup><sub>changelevel de_train</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_overpass.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_overpass<br><sup><sub>changelevel de_overpass</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_vertigo.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_vertigo<br><sup><sub>changelevel de_vertigo</sub></sup></td></tr></table></td></tr></table>

#### mg_executes

<table><tr><td><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_mirage.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_mirage<br><sup><sub>changelevel de_mirage</sub></sup></td></tr></table></td></tr></table>

#### mg_wingman

<table><tr><td><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_dust2_wingman.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3413800427">de_dust2_wingman</a><br><sup><sub>host_workshop_map 3413800427</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_mirage_d.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3402437047">de_mirage_d</a><br><sup><sub>host_workshop_map 3402437047</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/cs_italy.jpg?raw=true&sanitize=true"></td></tr><tr><td>cs_italy<br><sup><sub>changelevel cs_italy</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/cs_office.jpg?raw=true&sanitize=true"></td></tr><tr><td>cs_office<br><sup><sub>changelevel cs_office</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_vertigo.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_vertigo<br><sup><sub>changelevel de_vertigo</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_ancient.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_ancient<br><sup><sub>changelevel de_ancient</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_anubis.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_anubis<br><sup><sub>changelevel de_anubis</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_inferno.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_inferno<br><sup><sub>changelevel de_inferno</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_nuke.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_nuke<br><sup><sub>changelevel de_nuke</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_train.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_train<br><sup><sub>changelevel de_train</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_overpass.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_overpass<br><sup><sub>changelevel de_overpass</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_vertigo.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_vertigo<br><sup><sub>changelevel de_vertigo</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/ar_shoots.jpg?raw=true&sanitize=true"></td></tr><tr><td>ar_shoots<br><sup><sub>changelevel ar_shoots</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/ar_baggage.jpg?raw=true&sanitize=true"></td></tr><tr><td>ar_baggage<br><sup><sub>changelevel ar_baggage</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_brewery.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_brewery<br><sup><sub>changelevel de_brewery</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_dogtown.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_dogtown<br><sup><sub>changelevel de_dogtown</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_palais.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3257582863">de_palais</a><br><sup><sub>host_workshop_map 3257582863</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_whistle.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3308613773">de_whistle</a><br><sup><sub>host_workshop_map 3308613773</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/gd_rialto.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3085490518">gd_rialto</a><br><sup><sub>host_workshop_map 3085490518</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_safehouse.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070550406">de_safehouse</a><br><sup><sub>host_workshop_map 3070550406</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_lake.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070563536">de_lake</a><br><sup><sub>host_workshop_map 3070563536</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_bank.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070581293">de_bank</a><br><sup><sub>host_workshop_map 3070581293</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_shortdust.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070612859">de_shortdust</a><br><sup><sub>host_workshop_map 3070612859</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_assembly.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3071005299">de_assembly</a><br><sup><sub>host_workshop_map 3071005299</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_cbble.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3329387648">de_cbble</a><br><sup><sub>host_workshop_map 3329387648</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_cache.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3437809122">de_cache</a><br><sup><sub>host_workshop_map 3437809122</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_pipeline.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3079872050">de_pipeline</a><br><sup><sub>host_workshop_map 3079872050</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_biome.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3075706807">de_biome</a><br><sup><sub>host_workshop_map 3075706807</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/mp_raid.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070346180">mp_raid</a><br><sup><sub>host_workshop_map 3070346180</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_mutiny.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070766070">de_mutiny</a><br><sup><sub>host_workshop_map 3070766070</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/cs_assault.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070594412">cs_assault</a><br><sup><sub>host_workshop_map 3070594412</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_ruins_d_prefab.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3072352643">de_ruins_d_prefab</a><br><sup><sub>host_workshop_map 3072352643</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_train.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070284539">de_train</a><br><sup><sub>host_workshop_map 3070284539</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_sakura.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3082340867">de_sakura</a><br><sup><sub>host_workshop_map 3082340867</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_memento.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3165559377">de_memento</a><br><sup><sub>host_workshop_map 3165559377</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/skatepark.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3309665004">skatepark</a><br><sup><sub>host_workshop_map 3309665004</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_ema.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3386116667">de_ema</a><br><sup><sub>host_workshop_map 3386116667</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/paintit.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3360723913">paintit</a><br><sup><sub>host_workshop_map 3360723913</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_mirage_bricks.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3464733042">de_mirage_bricks</a><br><sup><sub>host_workshop_map 3464733042</sub></sup></td></tr></table></td></tr></table>

#### mg_dm

<table><tr><td><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_vertigo.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_vertigo<br><sup><sub>changelevel de_vertigo</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_dust2.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_dust2<br><sup><sub>changelevel de_dust2</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_inferno.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_inferno<br><sup><sub>changelevel de_inferno</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_mirage.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_mirage<br><sup><sub>changelevel de_mirage</sub></sup></td></tr></table></td></tr></table>

#### mg_gg

<table><tr><td><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/ar_shoots.jpg?raw=true&sanitize=true"></td></tr><tr><td>ar_shoots<br><sup><sub>changelevel ar_shoots</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/ar_baggage.jpg?raw=true&sanitize=true"></td></tr><tr><td>ar_baggage<br><sup><sub>changelevel ar_baggage</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/ar_pool_day.jpg?raw=true&sanitize=true"></td></tr><tr><td>ar_pool_day<br><sup><sub>changelevel ar_pool_day</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/speedball.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3443206318">speedball</a><br><sup><sub>host_workshop_map 3443206318</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_assembly.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3071005299">de_assembly</a><br><sup><sub>host_workshop_map 3071005299</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/fy_iceworld.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070238628">fy_iceworld</a><br><sup><sub>host_workshop_map 3070238628</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/daymare.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3072640420">daymare</a><br><sup><sub>host_workshop_map 3072640420</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/mcdonalds.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3134466699">mcdonalds</a><br><sup><sub>host_workshop_map 3134466699</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/aim_theorem.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070348309">aim_theorem</a><br><sup><sub>host_workshop_map 3070348309</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_safehouse.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070550406">de_safehouse</a><br><sup><sub>host_workshop_map 3070550406</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_lake.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070563536">de_lake</a><br><sup><sub>host_workshop_map 3070563536</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_bank.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070581293">de_bank</a><br><sup><sub>host_workshop_map 3070581293</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/fun_bounce.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3088183343">fun_bounce</a><br><sup><sub>host_workshop_map 3088183343</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/1v1aim_map_longdustversion_d.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3082605693">1v1aim_map_longdustversion_d</a><br><sup><sub>host_workshop_map 3082605693</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/ar_churches_s2r.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070291913">ar_churches_s2r</a><br><sup><sub>host_workshop_map 3070291913</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/aim_ag_texture_city_advanced.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3082113929">aim_ag_texture_city_advanced</a><br><sup><sub>host_workshop_map 3082113929</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/trainingoutside.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3475270536">trainingoutside</a><br><sup><sub>host_workshop_map 3475270536</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/shipment_version_1_0.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3086555291">shipment_version_1_0</a><br><sup><sub>host_workshop_map 3086555291</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/aim_ag_texture2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3074961197">aim_ag_texture2</a><br><sup><sub>host_workshop_map 3074961197</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/aim_ag_texture_jungle.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3095778105">aim_ag_texture_jungle</a><br><sup><sub>host_workshop_map 3095778105</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/cs2_bloodstrike.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3071890065">cs2_bloodstrike</a><br><sup><sub>host_workshop_map 3071890065</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/gg_simpsons_vs_flanders_v2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3109232789">gg_simpsons_vs_flanders_v2</a><br><sup><sub>host_workshop_map 3109232789</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/school_d_environment_prefab.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3343693110">school_d_environment_prefab</a><br><sup><sub>host_workshop_map 3343693110</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_ema.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3386116667">de_ema</a><br><sup><sub>host_workshop_map 3386116667</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/twofort_cs2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3345551391">twofort_cs2</a><br><sup><sub>host_workshop_map 3345551391</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/paintit.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3360723913">paintit</a><br><sup><sub>host_workshop_map 3360723913</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/kloce.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3248340515">kloce</a><br><sup><sub>host_workshop_map 3248340515</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/gulag.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3326465469">gulag</a><br><sup><sub>host_workshop_map 3326465469</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_rats_remake.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3460962520">de_rats_remake</a><br><sup><sub>host_workshop_map 3460962520</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_mirage_bricks.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3464733042">de_mirage_bricks</a><br><sup><sub>host_workshop_map 3464733042</sub></sup></td></tr></table></td></tr></table>

#### mg_1v1

<table><tr><td><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/aim_redline_fp.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070253400">aim_redline_fp</a><br><sup><sub>host_workshop_map 3070253400</sub></sup></td></tr></table></td></tr></table>

#### mg_bhop

<table><tr><td><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/bhop_at_night.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3077211069">bhop_at_night</a><br><sup><sub>host_workshop_map 3077211069</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/bhop_ragnarok.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3077153735">bhop_ragnarok</a><br><sup><sub>host_workshop_map 3077153735</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/bhop_zunron.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3077475505">bhop_zunron</a><br><sup><sub>host_workshop_map 3077475505</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/bhop_1derland.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3077596014">bhop_1derland</a><br><sup><sub>host_workshop_map 3077596014</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/bhop_whiteshit.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3078523849">bhop_whiteshit</a><br><sup><sub>host_workshop_map 3078523849</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/bhop_cherryblossom.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3082038560">bhop_cherryblossom</a><br><sup><sub>host_workshop_map 3082038560</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/bhop_arcturus.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3088973190">bhop_arcturus</a><br><sup><sub>host_workshop_map 3088973190</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/bhop_kiwi_cwfx.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3095219437">bhop_kiwi_cwfx</a><br><sup><sub>host_workshop_map 3095219437</sub></sup></td></tr></table></td></tr></table>

#### mg_kz

<table><tr><td><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/only_up.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3074758439">only_up</a><br><sup><sub>host_workshop_map 3074758439</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/kz_dima.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3343029934">kz_dima</a><br><sup><sub>host_workshop_map 3343029934</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/ewii_challenge.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3170668869">ewii_challenge</a><br><sup><sub>host_workshop_map 3170668869</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/hellcasecyrilchallenge.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3145779590">hellcasecyrilchallenge</a><br><sup><sub>host_workshop_map 3145779590</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/kz_checkmate.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070194623">kz_checkmate</a><br><sup><sub>host_workshop_map 3070194623</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/kz_victoria.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3086304337">kz_victoria</a><br><sup><sub>host_workshop_map 3086304337</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/kz_rc_stonehenge.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3072219045">kz_rc_stonehenge</a><br><sup><sub>host_workshop_map 3072219045</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/kz_sxb2_cxz.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3083714192">kz_sxb2_cxz</a><br><sup><sub>host_workshop_map 3083714192</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/kz_rc_twotowers.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3083509404">kz_rc_twotowers</a><br><sup><sub>host_workshop_map 3083509404</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/kz_simplyhard.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3078311932">kz_simplyhard</a><br><sup><sub>host_workshop_map 3078311932</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/kz_nomibo.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3077122656">kz_nomibo</a><br><sup><sub>host_workshop_map 3077122656</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/kz_sxb2_biewan.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3076000218">kz_sxb2_biewan</a><br><sup><sub>host_workshop_map 3076000218</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/kz_ggsh.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3072744536">kz_ggsh</a><br><sup><sub>host_workshop_map 3072744536</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/kz_ltt.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3072699538">kz_ltt</a><br><sup><sub>host_workshop_map 3072699538</sub></sup></td></tr></table></td></tr></table>

#### mg_surf

<table><tr><td><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/surf_kitsune.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3076153623">surf_kitsune</a><br><sup><sub>host_workshop_map 3076153623</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/surf_utopia_njv.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3073875025">surf_utopia_njv</a><br><sup><sub>host_workshop_map 3073875025</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/surf_beginner.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070321829">surf_beginner</a><br><sup><sub>host_workshop_map 3070321829</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/surf_mesa_revo.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3076980482">surf_mesa_revo</a><br><sup><sub>host_workshop_map 3076980482</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/surf_deathstar.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3080544577">surf_deathstar</a><br><sup><sub>host_workshop_map 3080544577</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/surf_rookie.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3082548297">surf_rookie</a><br><sup><sub>host_workshop_map 3082548297</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/surf_benevolent.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3098972556">surf_benevolent</a><br><sup><sub>host_workshop_map 3098972556</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/surf_ace.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3088413071">surf_ace</a><br><sup><sub>host_workshop_map 3088413071</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/surf_boreas.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3133346713">surf_boreas</a><br><sup><sub>host_workshop_map 3133346713</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/surf_nyx.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3129698096">surf_nyx</a><br><sup><sub>host_workshop_map 3129698096</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/surf_whiteout.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3296258256">surf_whiteout</a><br><sup><sub>host_workshop_map 3296258256</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/surf_ski_2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3079877518">surf_ski_2</a><br><sup><sub>host_workshop_map 3079877518</sub></sup></td></tr></table></td></tr></table>

#### mg_minigames

<table><tr><td><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/mg_skeet_multigames_v7.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3082120895">mg_skeet_multigames_v7</a><br><sup><sub>host_workshop_map 3082120895</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/mg_lego_course_2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3202752274">mg_lego_course_2</a><br><sup><sub>host_workshop_map 3202752274</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/mg_warmcup_headshot.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3076765511">mg_warmcup_headshot</a><br><sup><sub>host_workshop_map 3076765511</sub></sup></td></tr></table></td></tr></table>

#### mg_battleroyale

<table><tr><td><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/br_t2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3462095803">br_t2</a><br><sup><sub>host_workshop_map 3462095803</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/br_electrified.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3330484099">br_electrified</a><br><sup><sub>host_workshop_map 3330484099</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/br_stacks.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3297489255">br_stacks</a><br><sup><sub>host_workshop_map 3297489255</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/br_flood.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3267454508">br_flood</a><br><sup><sub>host_workshop_map 3267454508</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/minecraft.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3186779271">minecraft</a><br><sup><sub>host_workshop_map 3186779271</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/minecraft_hungergame.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3240933254">minecraft_hungergame</a><br><sup><sub>host_workshop_map 3240933254</sub></sup></td></tr></table></td></tr></table>

#### mg_deathrun

<table><tr><td><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/deathrun_playground.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3164611860">deathrun_playground</a><br><sup><sub>host_workshop_map 3164611860</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/deathrun_egypt.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3311285877">deathrun_egypt</a><br><sup><sub>host_workshop_map 3311285877</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/deathrun_civilization.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3188021118">deathrun_civilization</a><br><sup><sub>host_workshop_map 3188021118</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/deathrun_iceworld_cs2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3083325292">deathrun_iceworld_cs2</a><br><sup><sub>host_workshop_map 3083325292</sub></sup></td></tr></table></td></tr></table>

#### mg_course

<table><tr><td><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/cr_devisland_p1_v1.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3076483842">cr_devisland_p1_v1</a><br><sup><sub>host_workshop_map 3076483842</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/mg_switch_course_v2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070439729">mg_switch_course_v2</a><br><sup><sub>host_workshop_map 3070439729</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/cr_minecraft_jb_v2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070896876">cr_minecraft_jb_v2</a><br><sup><sub>host_workshop_map 3070896876</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/mg_metro_course_v1.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070463151">mg_metro_course_v1</a><br><sup><sub>host_workshop_map 3070463151</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/mg_alley_course_v2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070455802">mg_alley_course_v2</a><br><sup><sub>host_workshop_map 3070455802</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/mg_glave_course_v2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070445185">mg_glave_course_v2</a><br><sup><sub>host_workshop_map 3070445185</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/mg_office_course_v3.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070459211">mg_office_course_v3</a><br><sup><sub>host_workshop_map 3070459211</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/mg_metal_course_v2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070464208">mg_metal_course_v2</a><br><sup><sub>host_workshop_map 3070464208</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/mg_acrophobia_run_v2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070463620">mg_acrophobia_run_v2</a><br><sup><sub>host_workshop_map 3070463620</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/mg_metro_course_s2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3071040020">mg_metro_course_s2</a><br><sup><sub>host_workshop_map 3071040020</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/mg_circle_course_v3.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070434475">mg_circle_course_v3</a><br><sup><sub>host_workshop_map 3070434475</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/mg_simpsons_course_v2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070447697">mg_simpsons_course_v2</a><br><sup><sub>host_workshop_map 3070447697</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/mg_sonic_course_v2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070452642">mg_sonic_course_v2</a><br><sup><sub>host_workshop_map 3070452642</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/mg_sky_realm_v3.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070451616">mg_sky_realm_v3</a><br><sup><sub>host_workshop_map 3070451616</sub></sup></td></tr></table></td></tr></table>

#### mg_scoutzknivez

<table><tr><td><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/scoutzknivez_pure_cs2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3073929825">scoutzknivez_pure_cs2</a><br><sup><sub>host_workshop_map 3073929825</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/ar_dizzy.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070553020">ar_dizzy</a><br><sup><sub>host_workshop_map 3070553020</sub></sup></td></tr></table></td></tr></table>

#### mg_hns

<table><tr><td><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_nuke_prophunt.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3366748499">de_nuke_prophunt</a><br><sup><sub>host_workshop_map 3366748499</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_overpass_prophunt.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3382166635">de_overpass_prophunt</a><br><sup><sub>host_workshop_map 3382166635</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_inferno_prophunt.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3348038890">de_inferno_prophunt</a><br><sup><sub>host_workshop_map 3348038890</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_vertigo_prophunt.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3292648008">de_vertigo_prophunt</a><br><sup><sub>host_workshop_map 3292648008</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_mirage_prophunt.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3287578956">de_mirage_prophunt</a><br><sup><sub>host_workshop_map 3287578956</sub></sup></td></tr></table></td></tr></table>

#### mg_soccer

<table><tr><td><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/futsal.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3293224257">futsal</a><br><sup><sub>host_workshop_map 3293224257</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/ka_soccer_2009.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070198374">ka_soccer_2009</a><br><sup><sub>host_workshop_map 3070198374</sub></sup></td></tr></table></td></tr></table>

#### mg_awp

<table><tr><td><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/awp_bhop_rocket.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3142070597">awp_bhop_rocket</a><br><sup><sub>host_workshop_map 3142070597</sub></sup></td></tr></table></td></tr></table>

#### mg_battle

<table><tr><td><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/battleball.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3280650663">battleball</a><br><sup><sub>host_workshop_map 3280650663</sub></sup></td></tr></table></td></tr></table>

#### mg_aim

<table><tr><td><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/aim_map.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3084291314">aim_map</a><br><sup><sub>host_workshop_map 3084291314</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/freebet_aim_map.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3146122036">freebet_aim_map</a><br><sup><sub>host_workshop_map 3146122036</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/fy_pool_day.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070923343">fy_pool_day</a><br><sup><sub>host_workshop_map 3070923343</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/aim_ak-colt_CS2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3078701726">aim_ak-colt_CS2</a><br><sup><sub>host_workshop_map 3078701726</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/aim_usp.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3085962528">aim_usp</a><br><sup><sub>host_workshop_map 3085962528</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/aim_deagle.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3075996446">aim_deagle</a><br><sup><sub>host_workshop_map 3075996446</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/1v1aim_map_longdustversion_d.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3082605693">1v1aim_map_longdustversion_d</a><br><sup><sub>host_workshop_map 3082605693</sub></sup></td></tr></table></td></tr></table>

#### mg_prefire

<table><tr><td><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_ancient.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_ancient<br><sup><sub>changelevel de_ancient</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_dust2.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_dust2<br><sup><sub>changelevel de_dust2</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_inferno.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_inferno<br><sup><sub>changelevel de_inferno</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_mirage.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_mirage<br><sup><sub>changelevel de_mirage</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_overpass.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_overpass<br><sup><sub>changelevel de_overpass</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_anubis.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_anubis<br><sup><sub>changelevel de_anubis</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_nuke.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_nuke<br><sup><sub>changelevel de_nuke</sub></sup></td></tr></table></td></tr></table>

#### mg_casual16

<table><tr><td><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/as_oilrig.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3104677430">as_oilrig</a><br><sup><sub>host_workshop_map 3104677430</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/cs_assult_classic.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3215705579">cs_assult_classic</a><br><sup><sub>host_workshop_map 3215705579</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_aztec_classic.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3213800338">de_aztec_classic</a><br><sup><sub>host_workshop_map 3213800338</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_dust_classic.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3078095785">de_dust_classic</a><br><sup><sub>host_workshop_map 3078095785</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_dust2_classic.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3201205818">de_dust2_classic</a><br><sup><sub>host_workshop_map 3201205818</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/cs_italy_classic.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3212419403">cs_italy_classic</a><br><sup><sub>host_workshop_map 3212419403</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/cs_militia_classic.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3144773563">cs_militia_classic</a><br><sup><sub>host_workshop_map 3144773563</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_nuke_classic.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3205793205">de_nuke_classic</a><br><sup><sub>host_workshop_map 3205793205</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/cs_office_classic.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3216844784">cs_office_classic</a><br><sup><sub>host_workshop_map 3216844784</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_survivor_classic_m.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3217247541">de_survivor_classic_m</a><br><sup><sub>host_workshop_map 3217247541</sub></sup></td></tr></table></td></tr></table>

#### mg_45

<table><tr><td><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_vertigo_45.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3276886893">de_vertigo_45</a><br><sup><sub>host_workshop_map 3276886893</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_anubis_silly.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3245985233">de_anubis_silly</a><br><sup><sub>host_workshop_map 3245985233</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_overpass_45.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3270066070">de_overpass_45</a><br><sup><sub>host_workshop_map 3270066070</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_nuke_silly.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3245245780">de_nuke_silly</a><br><sup><sub>host_workshop_map 3245245780</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_mirage45.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3270516952">de_mirage45</a><br><sup><sub>host_workshop_map 3270516952</sub></sup></td></tr></table><table align="left"><tr><td><img src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_train_twyxe.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3406937162">de_train_twyxe</a><br><sup><sub>host_workshop_map 3406937162</sub></sup></td></tr></table></td></tr></table>

### How do I connect to RCON remotely?

[Download SourceAdminTool](https://nightly.link/Drifter321/admintool/workflows/build/master) ([source](https://github.com/Drifter321/admintool)) for your OS (you can read about it [here](https://forums.alliedmods.net/showthread.php?t=289370)) and click `Servers > Add Servers` and put in the `<IP>:27015` and when you see the server show in the list, down the bottom left type in your RCON password and click `Login` and you should be able to execute commands from the bottom text box i.e. `exec dm.cfg`

**You must connect to the server from the public IP if hosting an online server, not the LAN IP even if you are on the same network. The script logs the public IP `Starting server on XXX.XXX.XXX.XXX:27015`**

### Acessing admin menu

Admins are managed by [CounterStrikeSharp](https://github.com/roflmuffin/CounterStrikeSharp) using the [Admin Framework](https://docs.cssharp.dev/docs/admin-framework/defining-admins.html). You define admins and their flags and most plugins now utilise this framework.

You must use the [custom files](#custom-files) to set your admins, as they will be overwritten when you update your server.

To see an example of my admins you can look at this file [/custom_files_example/addons/counterstrikesharp/configs/admins.json](https://github.com/kus/cs2-modded-server/blob/master/custom_files_example/addons/counterstrikesharp/configs/admins.json).

If you don't want to define any new groups, you can copy this file [/custom_files_example/addons/counterstrikesharp/configs/admins.json](https://github.com/kus/cs2-modded-server/blob/master/custom_files_example/addons/counterstrikesharp/configs/admins.json) into `/custom_files/addons/counterstrikesharp/configs/admins.json` and set your own admins and this will overwrite the default admins from this mod.

Ensure your `.json` files are valid JSON by using [this website](https://jsonformatter.org/json-viewer).

If you have added the admins correctly you should see `Loaded admin data with X admins.` in the server logs when it starts.

If you modify the server whilst the server is on you can run `css_admins_reload` and `css_groups_reload` to reload the admins and see the admins with `css_admins_list` and `css_groups_list`.

### Use number keys to operate menu instead of typing !1 in chat

If you don't like having to type in chat !number every time you want to use a menu item; you can use this trick to bind the corresponding !number command to the number key. So when you press 1 it will select the 1 option:

_Note: This is assuming you are using the standard binds. You can change accordingly for your own setup._

```
bind "1" "slot1; css_1"
bind "2" "slot2; css_2"
bind "3" "slot3; css_3"
bind "4" "slot4; css_4"
bind "5" "slot5; css_5"
bind "6" "slot6; css_6"
bind "7" "slot7; css_7"
bind "8" "slot8; css_8"
bind "9" "slot9; css_9"
bind "0" "slot10; css_0"
```

### Changing maps

<img alt="Admin change map menu" src="https://github.com/kus/cs2-modded-server/blob/assets/assets/admin-maps.png?raw=true&sanitize=true">

Admins can type `!maps` in chat and it will bring up a menu of all the maps for the current mod. When a map is selected it will change the map straight away.

At the end of the map (if time runs out or win conditions are met) it a vote will show to choose a map from the current mod.

### Changing settings

Admins can type `!settings` in chat and it will bring up a menu of all the settings you can enable or disable. i.e.: Bunnyhopping, fun mode etc.

### Changing game modes

<img alt="Admin change game mode menu" src="https://github.com/kus/cs2-modded-server/blob/assets/assets/admin-modes.png?raw=true&sanitize=true">

Admins can type `!modes` in chat and it will bring up a menu of all the game modes. Simply choose one and it will switch to that game mode and change to a default map for that game mode.

The maps in `!maps` will also update to the new game mode when it has changed.

Changing between gamemodes multiple times is not recommended, and it is better if you restart the CS2 server in-between.

To view what other commands are available view the plugins documentation at the top of the page.

### RCON doesn't work

Using RCON whilst connected to the server does not work. See discussion [here](https://www.reddit.com/r/GlobalOffensive/comments/167spzi/cs2_rcon/).
The current work arounds are:

- I have included [CS2Rcon](https://github.com/LordFetznschaedl/CS2Rcon) which allows admins to use !rcon in chat.
- You can disconnect from the server and use `rcon_address IP:PORT` in console and you can use rcon commands.
- Use an external RCON program which has implemented the RCON protocol such as [this](https://github.com/fpaezf/CS2-RCON-Tool-V2).

If it still doesn't work, make sure you try connect from CS2 outside of a game via console:

**You must connect to the server from the public IP if hosting an online server, not the LAN IP even if you are on the same network. The script logs the public IP `Starting server on XXX.XXX.XXX.XXX:27015`**

```bash
rcon_address ip:port
rcon_password "password"
rcon say "hi"
```

And check the ports cs2 is using on your OS i.e. on Ubuntu `sudo lsof -i -P -n | head -n 1; sudo lsof -i -P -n | grep cs2`.

### My server has run out of space!

Workshop maps take up a lot of space! If you want to delete all your workshop maps so the server can run again (it will download the maps you want to play). Stop the server, delete the `workshop` and start the server again:

Linux:

```
cd /home/steam/cs2/game/bin/linuxsteamrt64/steamapps
ls -lah # You should see a workshop folder
du -sh workshop # To get the size of it
rm -rf workshop # Delete the workshop folder
```

Windows:

- Browse to where ever you are running your server from
- Open `game/bin/win64/steamapps/` and you should see a workshop folder
- Delete the workshop folder

### How do I add more bots?

By default bots are enabled in deathmatch, gungame, gungame ffa, retakes, scoutsknives and wingman.

The default is set to add 1 bot if only 1 human is in the server, and then if there is 2 or more humans there will be no bots.

You can overwrite the settings for the bots by creating a "[custom file](#custom-files)" for this file [custom_bots.cfg](https://github.com/kus/cs2-modded-server/blob/master/game/csgo/cfg/custom_bots.cfg).

If you copy [custom_bots.cfg](https://github.com/kus/cs2-modded-server/blob/master/game/csgo/cfg/custom_bots.cfg) and put it in the `custom_files/cfg/` directory (`/home/steam/cs2/custom_files/cfg/` on default Linux setup) and you can modify it and change say `bot_quota` to `10` if you want 10 players at all times. When the server starts (on Linux and Windows) it will merge this file into the game cfg and it will execute every time `bots.cfg` executes.

You can also just login to RCON `rcon_password yourpassword` and use `rcon bot_add_ct` and `rcon bot_add_t`.

If you want to remove bots you use `rcon bot_kick`.

### Why can't I set the server to start automatically with a mod loaded

Because the way the server is setup with several mods it's not possible. You can't use `+exec` in the server launcher as that executes to quick before SourceMod is loaded. You can monitor the server once it's started (via RCON) and then load a mod i.e. `exec dm.cfg`.

### Manually updating Metamod:Source and CounterStrikeSharp

If you are on a unix based system, you can run `scripts/check-updates.sh` which will check the current versions of each plugin installed in this repo vs what the latest is, this makes it easier than going through each one manually.

Go to the Releases page for [Metamod:Source](http://www.sourcemm.net/downloads.php?branch=master) and [CounterStrikeSharp](https://github.com/roflmuffin/CounterStrikeSharp) and download the latest. You need to merge the `addons` folder from the zips into the `/game/csgo/addons` of this repo. This is easy to do with unix based systems with rsync:

First open terminal and `cd` into the folder where you unzipped the zips i.e.: `cd ~/Downloads` then update the command below with the full path to the repo and run it:

`rsync -rhavz --exclude "._*" --exclude ".DS_Store" --partial --progress --stats ./addons/ /Users/kus/dev/personal/counter-strike/cs2-modded-server/game/csgo/addons/`

If you are on Windows, from the [CounterStrikeSharp](https://github.com/roflmuffin/CounterStrikeSharp/releases) with runtime zip, you need to copy the `api`,`bin`, `dotnet` folders from the `/addons/counterstrikesharp` folder to `/game/csgo/addons/windows/counterstrikesharp` in this repo.

### Quake Sounds

Quake Sounds is enabled by default, so it will play the Quake Sound "HEADSHOT" for headshots, and for kill streaks different multi-kill sounds. Players can disable it by typing `!qs` in chat.

If you **DO NOT** want to use it on your server, you need to modify two files using the [custom files](#custom-files) method.

Copy `game/csgo/cfg/multiaddonmanager/multiaddonmanager.cfg` to `/custom_files/cfg/multiaddonmanager/multiaddonmanager.cfg` and delete `3461824328` from `mm_extra_addons` i.e.: so it reads `mm_extra_addons ""`. _This will stop it prompting your players to download the Quake Sound Pack when they join your server._

Copy `game/csgo/cfg/settings/quake_sounds.cfg` to `/custom_files/cfg/settings/quake_sounds.cfg` and delete everything in the file so it is empty. _This will stop the plugin from loading._

### Skin changer

On your server your players will have the ability to change the following:

- Weapon
  - Paint Kit, Wear, Seed, Name tag, StatTrak (with increment), and Stickers.
- Knife
  - Paint Kit, Wear, Seed, Name tag, and StatTrak (with increment).
- Gloves
  - Paint Kit, Wear, Seed.
- Agent
  - Patches.
- Music Kit
  - StatTrak (with increment). 
- Pin
- Graffiti

Go to [https://inventory.cstrike.app](https://inventory.cstrike.app/) and click `Sign-in to sync` and log in with Steam (this needs to be the same Steam account you are playing on).

Click `Craft Item` and create the items you want. You need to right click them and "Equip" them like you do in-game.

On the server type `!ws` and it should update your skins to what you have set.

> [!CAUTION]  
> Your server can be banned by Valve for using this plugin (see their [server guidelines](https://blog.counter-strike.net/index.php/server_guidelines)). Use at your own risk.

If you **DO NOT** want to use this plugin; change `FollowCS2ServerGuidelines` to `true` in `addons/counterstrikesharp/configs/core.json`. It is recommended to do this via [custom files](#custom-files).

### I run a Surf/KZ/Bhop server and want [MovementUnlocker](https://github.com/Source2ZE/MovementUnlocker) and [CS2Fixes-RampbugFix](https://github.com/Interesting-exe/CS2Fixes-RampbugFix) permanently on

Based on your OS; copy:

`game/csgo/addons/surf/<linux|windows>/addons/metamod/cs2fixes-rampbugfix.vdf` to `/custom_files/addons/metamod/cs2fixes-rampbugfix.vdf`
`game/csgo/addons/surf/<linux|windows>/addons/metamod/MovementUnlocker.vdf` to `/custom_files/addons/metamod/MovementUnlocker.vdf`

This will enable [MovementUnlocker](https://github.com/Source2ZE/MovementUnlocker) and [CS2Fixes-RampbugFix](https://github.com/Interesting-exe/CS2Fixes-RampbugFix) on your server when it boots.

To check type `meta list` in console and you should see `Movement Unlocker` and `Rampbugfix` in the list of loaded plugins.

If you only want to turn it on ad hoc then in chat use the command `!settings` > `Enable` > `Surf` and it will load them and change the map to de_dust to avoid the server crashing, then change the map back to what you want with `!maps`.

### Setup MySQL database

Setting up a MySQL Database is outside the scope of this repo.

It is recommended to use 5.2 or higher.

You can set one up yourself or use a hosted one (there are also some free options such as [filess.io](https://filess.io/#DBMS) [aiven.io](https://aiven.io/pricing?product=mysql) but reliability isn't guaranteed).

Once you have the connection details; the config files are generally located in `/game/csgo/addons/counterstrikesharp/configs/plugins/` which you would need to update via [custom files](#custom-files).

For this example; I'll use K4-Arenas. The config is located at `/game/csgo/addons/counterstrikesharp/configs/plugins/K4-Arenas/K4-Arenas.json` which you would put in `/custom_files/addons/counterstrikesharp/configs/plugins/K4-Arenas/K4-Arenas.json` so it is not overwritten/deleted and open the file `K4-Arenas.json` and add your database connection details to `"database-settings"`.

> [!TIP]
> If `K4-Arenas.json` does not exist, copy `K4-Arenas.json.example` and remove `.example` from the name and use that.

Restart your server.

### Enable advertisements

If you want to enable a whitelist on your server load the plugin by putting this `css_plugins load "plugins/disabled/Advertisement/Advertisement.dll"` in one of your `.cfg` files.

If you want it to load on every mod on your server, you can put it in your `/custom_files/cfg/custom_all.cfg` file.

The config file is located at `/game/csgo/addons/counterstrikesharp/plugins/disabled/Advertisement/advertisement.json` which you would put in `/custom_files/addons/counterstrikesharp/plugins/disabled/Advertisement/advertisement.json` so it is not overwritten/deleted.

### Enable Whitelist so only a list of people can play

If you want to enable a whitelist on your server load the plugin by putting this `css_plugins load "plugins/disabled/WhiteList/WhiteList.dll"` in one of your `.cfg` files.

If you want it to load on every mod on your server, you can put it in your `/custom_files/cfg/custom_all.cfg` file.

The whitelist file is located at `/game/csgo/addons/counterstrikesharp/plugins/disabled/WhiteList/whitelist.txt` which you would put in `/custom_files/addons/counterstrikesharp/plugins/disabled/WhiteList/whitelist.txt` so it is not overwritten.

### Failed to open libtier0.so

`Failed to open libtier0.so (/home/steam/cs2/bin/libgcc_s.so.1: version 'GCC_7.0.0' not found (required by /lib/i386-linux-gnu/libstdc++.so.6))`

This is because Valve ships their own copies of those libraries. As modern systems will have newer versions, you can safely delete the listed file from the server install. Do not delete the file in the system path (usually lib or lib32)[*](https://wiki.alliedmods.net/Installing_metamod:source).

`cd /home/steam/cs2/bin/` and `rm libgcc_s.so.1` and restart the server.

## License

See `LICENSE` for more details.

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=kus/cs2-modded-server)](https://star-history.com/#kus/cs2-modded-server)
