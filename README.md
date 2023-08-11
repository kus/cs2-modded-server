# CS:GO Modded Server

## About

A single modded Counter-Strike: Global Offensive Dedicated Server that you can change the active mod on the server from the admin menu and is setup for:

- GunGame +Turbo (get the next weapon straight away) +Deathmatch (respawn) +Quake sounds +Mario (on 3 kills)
- GunGame +FFA (free for all) +Turbo (get the next weapon straight away) +Deathmatch (respawn) +Quake sounds +Mario (on 3 kills)
- Pug Setup (competitive - alternative to WarMod, has captains who can pick team)
- WarMod (competitive)
- Scoutz Knivez
- Deathmatch Free For All
- Prop Hunt / Hide n Seek
- Retakes
- Wingman
- Zombie:Reloaded
- JailBreak
- Multi 1v1
- Practice (record grenade throws etc)
- Minigames
- Death Racers (Wipeout) ([Steam API key](#playing-workshop-maps-collections) required)
- Jump Training ([Steam API key](#playing-workshop-maps-collections) required)
- Squid Game ([Steam API key](#playing-workshop-maps-collections) required)
- Red Bull Flick (only Flux map which has surfing and jump pads [Steam API key](#playing-workshop-maps-collections) required)
- Fortnite ([Steam API key](#playing-workshop-maps-collections) required)
- Only Up! ([Steam API key](#playing-workshop-maps-collections) required)
- Go Kart ([Steam API key](#playing-workshop-maps-collections) required)
- Fall Guys ([Steam API key](#playing-workshop-maps-collections) required)
- WarOwl Teleport Gamemode ([Steam API key](#playing-workshop-maps-collections) required)
- Deathrun
- Surf
- Soccer
- Capture The Flag

Every time you want to boot the server, you should run `gcp.sh` (if on Google Cloud) or `install.sh` (on Linux) and it will ensure your OS is up to date, CS:GO is up to date, and pull down the latest patches from this mod (any updates that I push up).

Obviously, any changes you have made to the files in this mod will be overwritten so I have created a "[custom files](#custom-files)" folder where you mirror the contents of the `csgo/` folder, and any files you want to tweak, you put in there in the same spot and they will always overwrite the mods default files. Read more about it [here](#custom-files).

The simple quick setup:

1. [Create your firewall rules](#create-firewall-rule)
2. [Provision your server on Google Cloud](#create-instance)
3. [SSH into server](#ssh-to-server)
4. [Install mod](#install-mod)
5. [Install maps/sounds/models/textures for custom maps/mods](#download-maps)
6. [Create your custom files for hostname, admins etc](#custom-files)
7. Ensure you have followed the steps for creating an [online server](#creating-an-online-server) or [LAN server](#creating-a-lan-server)
8. Kill server if running `./stop.sh` and start again `gcp.sh` (if on Google Cloud) or `install.sh` (on Linux)

Your server should be up and running!

Useful things to know:

- [Access admin menu](#acessing-admin-menu)
- [Changing game mode](#changing-game-modes)
- If you follow the steps above and use my default settings and config files it will automatically use my [FastDL](#fast-dl) server so users download your assets quickly and takes the strain of the server.

Getting up and running:

- [Running on Google Cloud](#running-on-google-cloud)
- [Running on Linux](#running-on-linux)
- [Running on Windows](#running-on-windows)

## Mods installed

Mod | Version | Why
--- | --- | ---
[Metamod:Source](http://www.sourcemm.net/downloads.php?branch=stable) | `1.11.0-1148` | Sits between the Game and the Engine, and allows plugins to intercept calls that flow between
[SourceMod](https://www.sourcemod.net/downloads.php?branch=stable) | `1.11.0-6936` | SourceMod is server modification for any game that runs on the Half-Life 2 engine
[GunGame](https://github.com/nvrm/sourcemod-plugin-gungame) | `1.2.16` | Kill an enemy with the current weapon to get next weapon, first person to go through every weapon wins
[DeathMatch](https://forums.alliedmods.net/showthread.php?t=103242) | `1.8.0` | Required for GunGame to enable spawn protection and other things to the game
[Quake Sounds](https://forums.alliedmods.net/showthread.php?t=224316) | `3.5.0` | Plays sounds and displays text at certain events sometimes based on the number of kills
[NoBlock](https://forums.alliedmods.net/showthread.php?t=91617) | `1.4.2` | Removes player vs player collisions
[csgo-pug-setup](https://github.com/splewis/csgo-pug-setup) | `2.0.7` | This is a useful plugin for managing pug games, especially 10 mans/gathers
[PugSetup RoundRestore](https://forums.alliedmods.net/showthread.php?p=2707964) | `1.2` | Restore the match to the previous round for pug setup
[WarMod](https://forums.alliedmods.net/showthread.php?t=225474) | `20.07.15.1214` | Used for competitive matches, and provides the flexibility to suit any form of competition, including large tournaments down to clan matches
[Practice Mod](https://github.com/splewis/csgo-practice-mode) | `1.3.3` | Private team/individual practice servers
[KZTimer Jumpstats](https://forums.alliedmods.net/showthread.php?t=317121) | `2.3` | KZTimer Jumpstats With Ownages & More!
[Multi 1v1](https://forums.alliedmods.net/showthread.php?t=241056) | `1.1.9` | Sets up 2+ players in separate 1v1 arenas, when all the arenas are done fighting, the winners move up an arena and the losers move down an arena
[AbNeR DeathRun Manager](https://forums.alliedmods.net/showthread.php?t=272017) | `2.6` | Automates Deathrun Server
[Map configs](https://forums.alliedmods.net/showthread.php?p=607079) | `1.3` | Load mod settings on map change for mods that don't have exec's on map change
[Deathmatch v2](https://forums.alliedmods.net/showthread.php?t=246405) | `2.0.9` | Custom deathmatch
[Retakes](https://github.com/splewis/csgo-retakes) | `0.3.4` | Site retake gamemode
[Retakes Autoplant](https://github.com/b3none/retakes-autoplant) | `2.3.0` | Automatically plant the bomb at the start of the round
[Retakes MyWeaponAllocator](https://forums.alliedmods.net/showthread.php?p=2604368) | `2.3` | This weapon allocator simulates different kinds of rounds
[Instant Defuse](https://forums.alliedmods.net/showthread.php?p=2558854) | `1.2.1` | Instantly defuse the bomb if no Terrorists are alive and there is a sufficient amount of time remaining
[RankMe Kento Edition](https://forums.alliedmods.net/showthread.php?t=290063) | `3.0.3` | Stats
[DHooks](https://forums.alliedmods.net/showpost.php?p=2588686) | `2.2.0-detours17` | Required by Practice Mod
[SoccerMod](https://github.com/marcoboogers/soccermod) | `2017.5.5` | Soccer gamemode
[Command Time-Traveler](https://forums.alliedmods.net/showthread.php?t=134288) | `1.2.0` | Run a command in the future
[P Tools and Hooks](https://forums.alliedmods.net/showthread.php?t=289289) | `1.1.4` | Additional CS:GO Hooks and Natives 
[Gloves](https://forums.alliedmods.net/showthread.php?t=299977) | `1.0.5` | Custom gloves
[Weapon & Knives](https://forums.alliedmods.net/showthread.php?t=298770) | `1.7.8` | Custom weapon skins
[Accelerator](https://forums.alliedmods.net/showthread.php?t=277703) | `2.5.0-cd575aa` | Crash Reporting That Doesn't Suck
[Fix Mapchange Crash](https://forums.alliedmods.net/showthread.php?p=2748951) | `1.0` |  Fix players crash on map change. This plugin will reconnect all players before the map is changed.
[CSGOFixes](https://github.com/Vauff/CSGOFixes) | `2.0` |  A collection of various fixes for CS:GO
[Capture the flag](https://forums.alliedmods.net/showthread.php?p=2466337) | `1.2` | Capture the flag for CS:GO
[Models in map](https://forums.alliedmods.net/showthread.php?p=2389415) | `1.2` | Allows you to place models in map. Required for CTF
[Easy Downloader](https://forums.alliedmods.net/showthread.php?t=292207) | `1.03` | Downloads and Precaches Files/Folders. Required for CTF
[PropHunt](https://gitlab.com/Zipcore/Prophunt) | `3.0.0` | Terrorists choose a model and hide, and CTs try to find and kill them.
[Zombie:Reloaded](https://forums.alliedmods.net/showthread.php?t=277597) | `3.6.5` | Zombie Escape.
[-N- Arms Fix](https://forums.alliedmods.net/showthread.php?t=293295) | `2.0.3` | -N- Arms Fix helps you to fix arms/gloves in your plugin.
[ZR Custom arms](https://forums.alliedmods.net/showthread.php?p=2277249) | `5.1` | Set custom arms in CS:GO for zombiereloaded servers
[SM_Hosties v2](https://forums.alliedmods.net/showthread.php?t=108810) | `2.2.0` | Required by MyJailbreak
[MyJailbreak](https://forums.alliedmods.net/showthread.php?t=283212) | `b14.0` | MyJailbreak is a redux rewrite of Franugs Special Jailbreak a merge/redux of eccas, ESK0s & zipcores Jailbreak warden and many other plugins.
[MyJailbreak patches by azalty](https://github.com/azalty/MyJailbreak/releases) | `v9` | Patches to fix MyJailbreak by azalty
[Sound Info Library](https://forums.alliedmods.net/showthread.php?t=105816) | `1.0.1` | Better calculation of sound length and information required for PropHunt
[SpeedRules](https://gitlab.com/Zipcore/speedrules) | `1.0` | Advanced system to sync speed rules required for PropHunt
[Simple-Downloader](https://github.com/JakubKosmaty/Simple-Downloader) | `1.0` | Force clients to download files (audio for PropHunt)
[Disable Radar](https://forums.alliedmods.net/showthread.php?t=240500) | `1.2.2` | Simply hides the radar for everyone that spawns
[Fortnite like damage](https://forums.alliedmods.net/showthread.php?p=2604384) | `1.2.0` | Plugin that shows total damage like in fortnite

## Custom files

Any changes you have made to the files in this mod will be overwritten when the update scripts are ran. I have created a folder `/custom_files/` in the root of the project, where you mirror the contents of the `csgo/` folder, and any files you want to tweak, you put in there in the same spot and they will always overwrite the mods default files.

So this can be used to set the server hostname to something you want, set the RCON or serverpassword or set the admins of the server.

You can see an example of what I use on my server in the `/custom_files_example/` directory, which sets the hostname, server image and admins.

For example; if you want to add yourself as an admin, that file is located `/csgo/addons/sourcemod/configs/admins_simple.ini`. So to make your tweak to it, you would copy that file to `/custom_files/addons/sourcemod/configs/admins_simple.ini` and add yourself as an admin at the bottom. Then when the update scripts run, it will copy your custom file at `/custom_files/addons/sourcemod/configs/admins_simple.ini` and overwrite the default mod file at `/csgo/addons/sourcemod/configs/admins_simple.ini`.

If you want to change the server name, or make any changes to any mod settings use the `/cfg/custom_MOD.cfg` as it executes at the end and can overwrite any setting. So if you wanted to change the server name for GunGame, you would copy `/csgo/cfg/custom_gg.cfg` to `/custom_files/cfg/custom_gg.cfg` and and write `hostname "shipREKT GunGame +Deathmatch +Turbo"` and any other settings you want and this file will overwrite `/csgo/cfg/custom_gg.cfg` each time the `gcp.sh`/`install.sh`/`win.bat` script is ran, and these settings will run at the end when you load the GunGame mod.

To generate this directory, you can run the `gcp.sh` script (if on Google Cloud), `install.sh` script on Linux once or on `win.bat` script on Windows where you extracted the mod zip and this is where you would put your custom modifications.

## Creating an online server

If you are hosting an online server, you need to create a Steam [Game Login Token](https://steamcommunity.com/dev/managegameservers), your server will not run online without this. Put this value in the `STEAM_ACCOUNT` environment variable or create a custom file for `/csgo/cfg/secrets.cfg` following the [custom files](#custom-files) steps (`/custom_files/cfg/secrets.cfg`) and set it in `sv_setsteamaccount`.

You also need to create an [authorization key](http://steamcommunity.com/dev/apikey) which will allow your server to download maps from the workshop. Put this value in the `API_KEY` environment variable.

## Creating a LAN server

Create a custom file for `/csgo/cfg/env.cfg` following the [custom files](#custom-files) steps (`/custom_files/cfg/env.cfg`) and set `sv_lan` to `1`, `sv_downloadurl` to `""` and `sv_allowdownload` to `1`.

## Environment variables

### Available via environment variable only

Key | Default value | What is it
--- | --- | ---
`API_KEY` | `changeme` | To download maps from the workshop, your server needs access to the steam web api. To allow this you'll need an authorization key which you can generate [here](http://steamcommunity.com/dev/apikey)
`MOD_URL` | `https://github.com/kus/csgo-modded-server/archive/master.zip` | The zip for mod files to download and extract (defaultly this repo)
`PORT` | `27015` | Server port
`TICKRATE` | `128` | Server tickrate MM is 64, Faceit is 128
`MAXPLAYERS` | `32` | Max player limit
`DUCK_DOMAIN` | `` | [Duck DNS](https://www.duckdns.org/) domain if you want to utalise the free service to get a domain for your server instead of IP
`DUCK_TOKEN` | `` | [Duck DNS](https://www.duckdns.org/) access token to update domain when server boots
`CUSTOM_FOLDER` | `custom_files` | Folder of your own modifications to the mod that mirror the csgo/ structure and overwrite the mode files. More on that [here](#custom-files)

### Can be configured via config file in custom files directory

These values can be set via environment variable or a config file in the custom files directory.
Copy `/csgo/cfg/secrets.cfg` to `/custom_files/cfg/secrets.cfg` and write the values you want and this file will overwrite `/csgo/cfg/secrets.cfg` each time the `gcp.sh`/`install.sh` script is ran.

Key | Value | What is it
--- | --- | ---
`RCON_PASSWORD` | `changeme` | RCON password to control server from console also remotely configure
`STEAM_ACCOUNT` | `` | To host a server online, you need to create a Steam [Game Login Token](https://steamcommunity.com/dev/managegameservers). Your server will not run online without this
`SERVER_PASSWORD` | `` | If you want a password protected server

## Maps

You can source your own maps and update `csgo/mapcycle_*` to match or you can use [my bundled maps](https://github.com/kus/csgo-modded-server-assets) that my server uses.

### Download maps

Linux: 

```
# cd to "csgo" parent directory so you are in the same folder as srcds
cd /home/steam/csgo/
curl --silent --output "automate.sh" "https://raw.githubusercontent.com/kus/csgo-modded-server-assets/master/automate.sh" && chmod +x automate.sh && bash automate.sh
```

Windows:

[Download](https://github.com/kus/csgo-modded-server-assets/archive/master.zip), unzip and unbzip all the files with [7-Zip](https://www.7-zip.org/download.html) and copy the contents from the csgo/ folder into your servers csgo/csgo/ folder.

### Playing workshop maps/collections

To download maps from the workshop, your server needs access to the steam web api. To allow this you'll need an authorization key which you can generate [here](http://steamcommunity.com/dev/apikey) and set `API_KEY` to the key.

The console command for hosting a workshop map is `host_workshop_map fileid` where `fileid` is the number that comes after `?id=` in the workshop URL for example: [https://steamcommunity.com/sharedfiles/filedetails/?id=2433686680](https://steamcommunity.com/sharedfiles/filedetails/?id=2433686680)

The console command for hosting a workshop collection is `host_workshop_collection collectionid` where `collectionid` is the number that comes after `?id=` in the workshop URL for example: [https://steamcommunity.com/sharedfiles/filedetails/?id=1092904694](https://steamcommunity.com/sharedfiles/filedetails/?id=1092904694). This command will then download all maps in the collection and create a mapgroup out of them, then host it.

## Fast DL

By default the download limit of CS:GO is capped at 20kb/s and also adds additional strain to servers if multiple clients are downloading files at the same time on map changes.

[sv_downloadurl](https://developer.valvesoftware.com/wiki/Sv_downloadurl) allows CS:GO clients to get custom server content (maps/sounds etc) at high speeds from web servers using HTTP which also takes the strain off the game server.

A [bash script](https://github.com/kus/csgo-modded-server/blob/master/scripts/bzip.sh) is included to make this process easy and automatically create the correct directory structure and compress your files with [bzip2](https://en.wikipedia.org/wiki/Bzip2) and create a "fastdl" folder which you simply host on a webserver.

Create a custom file for `/csgo/cfg/env.cfg` following the [custom files](#custom-files) steps (`/custom_files/cfg/env.cfg`) and set `sv_downloadurl` to `http://yoursite.com/fastdl/csgo`, and `sv_allowdownload` to `0`.

Windows users can [download this](http://gnuwin32.sourceforge.net/packages/bzip2.htm) and manually create the directory structure and compress the files. Anything in `maps`, `sounds`, `materials`, `models` and you need to keep the same directory structure. You should end up with something like:

```
fastdl
-csgo
--maps
--sounds
--materials
--models
```

If you use my [bundled maps](#download-maps) the `env.cfg` is defaultly setup to use my FastDL server so you don't have to change anything.

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
--metadata=RCON_PASSWORD=changeme,STEAM_ACCOUNT=changeme,API_KEY=changeme,DUCK_DOMAIN=changeme,DUCK_TOKEN=changeme,MOD_URL=https://github.com/kus/csgo-modded-server/archive/master.zip,startup-script="echo \"Delaying for 30 seconds...\" && sleep 30 && cd / && /gcp.sh" \
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
cd / && curl --silent --output "gcp.sh" "https://raw.githubusercontent.com/kus/csgo-modded-server/master/gcp.sh" && chmod +x gcp.sh && bash gcp.sh
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
gcloud compute scp soccer_breezeway_lite.bsp root@<instance-name>:/home/steam/csgo/csgo/maps --zone australia-southeast1-c

On server SSH:
cd /home/steam/csgo/csgo/maps
chown steam:steam soccer_breezeway_lite.bsp
chmod 644 soccer_breezeway_lite.bsp
```

### Turn VM off at 3:30AM every day

SSH into the VM

Switch to root `sudo su`

Check the timezone your server is running in `sudo hwclock --show`

Open crontab file `nano /etc/crontab`

Append to the end of the crontab file `30 3    * * *   root    shutdown -h now`

Save `CTRL + X`

## WARNING: If running an internet server; custom gloves and knives plugin could get you a temp ban

If running an internet server, and your Steam Game Server Login Token is tied to your account, Steam has banned the token plus a 30 day cool down for the account that created it in the past. [Read about it here](http://blog.counter-strike.net/index.php/server_guidelines/). There haven't been any bans in the last few years, and there are plenty of servers running these plugins, so do so at your own risk.

If you want to disable these plugins do the following:

Edit `csgo/addons/sourcemod/configs/core.cfg` and change `"FollowCSGOServerGuidelines" "no"` to `"yes"`

## Running on Linux

Make sure you have **40GB free space**.

Ensure you have all the settings for your [environment variables](#environment-variables).

* **If setting up internet server:**

   Set environment variable `STEAM_ACCOUNT` to your [Game Server Login Token](https://steamcommunity.com/dev/managegameservers)

   Make sure you [port forward](https://portforward.com/router.htm) on your router TCP: `27015` and UDP: `27015` & `27020` so players can connect from the internet.

* **If setting up LAN server:**

   Set environment variable `LAN` to `1`

```
sudo su
export RCON_PASSWORD="changeme"
export API_KEY="changeme"
export STEAM_ACCOUNT=""
export MOD_URL="https://github.com/kus/csgo-modded-server/archive/master.zip"
export SERVER_PASSWORD=""
export PORT="27015"
export TICKRATE="128"
export MAXPLAYERS="32"
cd / && curl --silent --output "install.sh" "https://raw.githubusercontent.com/kus/csgo-modded-server/master/install.sh" && chmod +x install.sh && bash install.sh
```

* **If running for the first time**

   Once the CS:GO server has started close it

   Copy your maps to `/home/steam/csgo/csgo/maps/` or you can use my [bundled maps](#download-maps)

   Update each `/csgo/mapcycle_` file to match your maps

   Open `/install.sh` and after it dynamically creates `cfg/env.cfg` you there is commented out code that will dynamically overwrite `/addons/sourcemod/configs/admins_simple.ini` with your own admins. Simply update the Steam ID's and uncomment the lines.

   Run `./install.sh` again

When you join the server you can [change game modes](#changing-game-modes).

## Running on Windows
Make sure you have **40GB free space**.

[Download this repo](https://github.com/kus/csgo-modded-server/archive/master.zip) and extract it to where you want your server (i.e. `C:\Server\csgo-modded-server`). All the following instructions will use this as the root.

Create a folder `steamcmd` and [download SteamCMD](https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip) and extract it inside `steamcmd` so you should have `\steamcmd\steamcmd.exe`.

* **If setting up internet server:**

   Open `\csgo\cfg\env.cfg`

   Set `sv_setsteamaccount` to your [Game Server Login Token](https://steamcommunity.com/dev/managegameservers)

   Open `\win.ini`

   Set `ip_internet` to your [public ip](http://checkip.amazonaws.com/)

   Make sure you [port forward](https://portforward.com/router.htm) on your router TCP: `27015` and UDP: `27015` & `27020` so players can connect from the internet.

* **If setting up LAN server:**

   Open `\csgo\cfg\env.cfg`

   Set `sv_lan` to `1`

[Add admins](#acessing-admin-menu)

Run `win.bat`

Accept both Private and Public connections on Windows Firewall.

* **If running for the first time**

   Once the CS:GO server has started close it

   Copy your maps to `\server\csgo\maps\` or you can use my [bundled maps](#download-maps) (you need to unzip them all)

   If you want to use my bundled maps and this server setup you can use `https://raw.githubusercontent.com/kus/csgo-modded-server-assets/master/csgo` for your your `sv_downloadurl` in `cfg/env.cfg`. Make sure you change `sv_allowdownload` to `0`.

   Update each `\csgo\mapcycle_` file to match your maps

   Run `win.bat` again

When you join the server you can [change game modes](#changing-game-modes).
## FAQ

### How do I add more bots?

By default bots are enabled in deathmatch, gungame, gungame ffa, retakes, scoutsknives and wingman.

The default is set to add 1 bot if only 1 human is in the server, and then if there is 2 or more humans there will be no bots.

You can overwrite the settings for the bots by creating a "[custom file](#custom-files)" for this file [custom_bots.cfg](https://github.com/kus/csgo-modded-server/blob/master/csgo/cfg/custom_bots.cfg).

If you copy [custom_bots.cfg](https://github.com/kus/csgo-modded-server/blob/master/csgo/cfg/custom_bots.cfg) and put it in the `custom_files/cfg/` directory (`/home/steam/csgo/custom_files/cfg/` on default Linux setup) and you can modify it and change say `bot_quota` to `10` if you want 10 players at all times. When the server starts (on Linux and Windows) it will merge this file into the game cfg and it will execute every time `bots.cfg` executes.

You can also just login to RCON `rcon_password yourpassword` and use `rcon bot_add_ct` and `rcon bot_add_t`.

If you want to remove bots you use `rcon bot_kick`.

### Failed to open libtier0.so

`Failed to open libtier0.so (/home/steam/csgo/bin/libgcc_s.so.1: version 'GCC_7.0.0' not found (required by /lib/i386-linux-gnu/libstdc++.so.6))`

This is because Valve ships their own copies of those libraries. As modern systems will have newer versions, you can safely delete the listed file from the server install. Do not delete the file in the system path (usually lib or lib32)[*](https://wiki.alliedmods.net/Installing_metamod:source).

`cd /home/steam/csgo/bin/` and `rm libgcc_s.so.1` and restart the server.

### How do I connect to RCON remotely?

[Download SourceAdminTool](https://users.alliedmods.net/~drifter/SAT/) for your OS (you can read about it [here](https://forums.alliedmods.net/showthread.php?t=289370)) and click `Servers > Add Servers` and put in the `<IP>:27015` and when you see the server show in the list, down the bottom left type in your RCON password and click `Login` and you should be able to execute commands from the bottom text box i.e. `exec gg.cfg`

### Why can't I set the server to start automatically with a mod loaded
Because the way the server is setup with several mods it's not possible. You can't use `+exec` in the server launcher as that executes to quick before SourceMod is loaded. You can monitor the server once it's started (via RCON) and then load a mod i.e. `exec gg.cfg`.

### How do I restart the server quickly?
Run the command `exec sourcemod/restart` via the admin menu (Server EXEC > Restart), RCON or from the server console. It is best to restart the server when changing between mods as some code/settings aren't fully removed when changing between mods.

## How do I update Metamod/SourceMod myself?

Periodically CS:GO will release updates which break Metamod:Source and SourceMod (the server won't start), and they will patch for the updates and release new updates. These need to be applied for the server to run properly. I will try to keep them up to date here which your server will automatically download if using my Linux gcp script but in the case I haven't updated them you can update them your self by checking the version I have bundled above and downloading the latest and putting on your server manually.

### SourceMod

[Download](https://www.sourcemod.net/downloads.php?branch=stable) Linux and Window and in each folder do the following:

From `/addons/sourcemod/` copy `bin`, `extensions`, `gamedata`, `sripting`, `translations` to your servers `/addons/sourcemod/` and *Merge All*

### Metamod:Source

[Download](http://www.sourcemm.net/downloads.php?branch=stable) Linux and Window and in each folder do the following:

From `/addons/metamod/` copy `bin` to your servers `/addons/metamod/` and *Merge All*

## Acessing admin menu

Bind a key to `sm_admin` from console i.e. `bind p sm_admin` then press `p` and the admin menu should open.

If you want to add admins, the admins are located at the bottom of this file `/addons/sourcemod/configs/admins_simple.ini` but we can't edit it directly as it gets overwritten when the mod updates. So we need to create a custom file following the [custom files](#custom-files) steps (copy the file to `/custom_files/addons/sourcemod/configs/admins_simple.ini`) and add the admin(s) to the bottom i.e. `"STEAM_0:0:56050" "9:z"` save the file and if the server is running you will need to close the server and start it again (with `gcp.sh`/`start.sh`/`install.sh`/`win.bat`) so the custom file is merged into your server.

If you want to read more about admin flags you can do that [here](https://wiki.alliedmods.net/Adding_Admins_(SourceMod)).

## Changing game modes

Once you are setup as an admin, open up the admin menu and go to Server Commands > Exec Configs and choose a game mode i.e. "Competitive" and you need to change the map for it to properly kick in so open the admin menu again and Server Commands > Maps > de_dust2 and once the server changes map the new game mode will be running.

## Running multiple servers

You can run multiple servers by modifying the launch scripts (install.sh/win.bat) and duplicating the lines that start the server and manually setting the port and optionally set the sourcemod path with `+sm_basepath addons/sourcemod_custom +exec custom.cfg +servercfgfile customserver.cfg`

## Making changes to WarMod plugin

You need [SourceMod 1.10](http://sourcemod.net/downloads.php?all=1&branch=1.10-dev) to compile and add the following into `addons/sourcemod/scripting/includes` [tEasyFTP.inc](https://raw.githubusercontent.com/thraaawn/tEasyFTP/master/scripting/include/tEasyFTP.inc) [bzip2.inc](https://raw.githubusercontent.com/thraaawn/SMbz2/master/pawn/scripting/include/bzip2.inc) [updater.inc](https://bitbucket.org/GoD_Tony/updater/raw/12181277db77d6117052b8ddf5810c7681745156/include/updater.inc) [zip.inc](https://raw.githubusercontent.com/Versatile-BFG/sm-zip/master/sm-zip/scripting/include/zip.inc) and copy the compiled `warmod.smx` from `addons/sourcemod/scripting/compiled` to `addons/sourcemod/plugins/disabled`.

On Windows:
Open up a command prompt (Start > Run > "cmd")

```
cd /d C:\git\csgo-modded-server\csgo\addons\sourcemod\scripting
spcomp warmod.sp -o compiled/warmod.smx
```

## Adding new maps to Capture The Flag

Type `!props` in chat to open the props menu.
Stand where you want the T flag and click `Spawn models > Ground` (and `Ground2` for CT) and a platform should appear in front of you. Enable `Move models (On)` and stand near it and grab it with your use key (E) and you can move it around. Rotate with reload (R) and push/pull with attack (Mouse1) and secondary fire (Mouse2).
Once you have it on the floor, click `Save models` and close the props menu.
Type `!ctf` in chat to open the Capture The Flag menu.
Aim at the floor where you want to place it and push `Spawn T flag` and click `Save flags` and close the menu.
Repeat this process for CT's and then reload the map and it should have the platform and flags.

## License

See `LICENSE` for more details.
