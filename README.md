# CS:GO Modded Server

## About

A single modded Counter-Strike: Global Offensive Dedicated Server that you can change the active mod on the server from the admin menu and is setup for:
 - GunGame +Turbo (get the next weapon straight away) +Deathmatch (respawn) +Quake sounds +Mario (on 3 kills)
 - WarMod (competitive)
 - Deathmatch Free For All
 - Retakes
 - Wingman
 - Multi 1v1
 - Practice (record grenade throws etc)
 - Minigames
 - Red Bull Flick (only Flux map which has surfing and jump pads [Steam API key](#playing-workshop-maps-collections) required)
 - Deathrun
 - Surf
 - Kreedz Climbing
 - Soccer
 - Capture The Flag

Getting up and running:
 - [Running on Linux](#running-on-linux)
 - [Running on Windows](#running-on-windows)
 - [Running on Google Cloud](#running-on-google-cloud)

## Mods installed

Mod | Version | Why
--- | --- | ---
[Metamod:Source](http://www.sourcemm.net/downloads.php?branch=stable) | `1.11.0-1145` | Sits between the Game and the Engine, and allows plugins to intercept calls that flow between
[SourceMod](https://www.sourcemod.net/downloads.php?branch=stable) | `1.10.0-6522` | SourceMod is server modification for any game that runs on the Half-Life 2 engine
[GunGame](https://forums.alliedmods.net/showthread.php?t=93977) | `1.2.16` | Kill an enemy with the current weapon to get next weapon, first person to go through every weapon wins
[DeathMatch](https://forums.alliedmods.net/showthread.php?t=103242) | `1.8.0` | Required for GunGame to enable spawn protection and other things to the game
[Quake Sounds](https://forums.alliedmods.net/showthread.php?t=224316) | `3.5.0` | Plays sounds and displays text at certain events sometimes based on the number of kills
[NoBlock](https://forums.alliedmods.net/showthread.php?t=91617) | `1.4.2` | Removes player vs player collisions
[WarMod](https://forums.alliedmods.net/showthread.php?t=225474) | `17.08.12.1053` | Used for competitive matches, and provides the flexibility to suit any form of competition, including large tournaments down to clan matches
[Practice Mod](https://github.com/splewis/csgo-practice-mode) | `1.3.3` | Private team/individual practice servers
[Multi 1v1](https://forums.alliedmods.net/showthread.php?t=241056) | `1.1.9` | Sets up 2+ players in separate 1v1 arenas, when all the arenas are done fighting, the winners move up an arena and the losers move down an arena
[AbNeR DeathRun Manager](https://forums.alliedmods.net/showthread.php?t=272017) | `2.6` | Automates Deathrun Server
[Map configs](https://forums.alliedmods.net/showthread.php?p=607079) | `1.3` | Load mod settings on map change for mods that don't have exec's on map change
[Deathmatch v2](https://forums.alliedmods.net/showthread.php?t=246405) | `2.0.9` | Custom deathmatch
[Retakes](https://github.com/splewis/csgo-retakes) | `0.3.4` | Site retake gamemode
[Retakes Autoplant](https://github.com/b3none/retakes-autoplant) | `2.3.0` | Automatically plant the bomb at the start of the round
[Retakes MyWeaponAllocator](https://forums.alliedmods.net/showthread.php?p=2604368) | `2.3` | This weapon allocator simulates different kinds of rounds
[Instant Defuse](https://forums.alliedmods.net/showthread.php?p=2558854) | `1.2.1` | Instantly defuse the bomb if no Terrorists are alive and there is a sufficient amount of time remaining
[RankMe Kento Edition](https://forums.alliedmods.net/showthread.php?t=290063) | `3.0.3` | Stats
[DHooks](https://github.com/XutaxKamay/dhooks/releases) | `2.2.1b` | Required by KZTimer
[KZTimer](https://bitbucket.org/kztimerglobalteam/kztimerglobal/src/master/) | `1.91.1` | KZTimer is a powerful, feature rich SourceMod climb timer plugin for CS:GO servers
[SoccerMod](https://github.com/marcoboogers/soccermod) | `2017.5.5` | Soccer gamemode
[Command Time-Traveler](https://forums.alliedmods.net/showthread.php?t=134288) | `1.2.0` | Run a command in the future
[P Tools and Hooks](https://forums.alliedmods.net/showthread.php?t=289289) | `1.1.3-build19` | Additional CS:GO Hooks and Natives 
[Gloves](https://forums.alliedmods.net/showthread.php?t=299977) | `1.0.5` | Custom gloves
[Weapon & Knives](https://forums.alliedmods.net/showthread.php?t=298770) | `1.7.1` | Custom weapon skins
[Accelerator](https://forums.alliedmods.net/showthread.php?t=277703) | `2.5.0-cd575aa` | Crash Reporting That Doesn't Suck
[Capture the flag](https://forums.alliedmods.net/showthread.php?p=2466337) | `1.2` | Capture the flag for CS:GO
[Models in map](https://forums.alliedmods.net/showthread.php?p=2389415) | `1.2` | Allows you to place models in map. Required for CTF
[Easy Downloader](https://forums.alliedmods.net/showthread.php?t=292207) | `1.03` | Downloads and Precaches Files/Folders. Required for CTF
[PropHunt](https://gitlab.com/Zipcore/Prophunt) | `3` | Terrorists choose a model and hide, and CTs try to find and kill them.

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

A [bash script](https://github.com/kus/csgo-modded-server/blob/master/scripts/bzip.sh) is included to make this process easy and automatically create the correct directory structure and compress your files with [bzip2](https://en.wikipedia.org/wiki/Bzip2) and create a "fastdl" folder which you simply host on a webserver and set your `FAST_DL_URL` on your server to something like `http://yoursite.com/fastdl/csgo`.

Windows users can [download this](http://gnuwin32.sourceforge.net/packages/bzip2.htm) and manually create the directory structure and compress the files. Anything in `maps`, `sounds`, `materials`, `models` and you need to keep the same directory structure. You should end up with something like:

```
fastdl
-csgo
--maps
--sounds
--materials
--models
```

If you want to use my bundled maps and this server setup you can use `https://raw.githubusercontent.com/kus/csgo-modded-server-assets/master/csgo` for your `FAST_DL_URL` linux environment variable or `sv_downloadurl` in `cfg/env.cfg` for Windows. Make sure you change `sv_allowdownload` to `0`.

## Updating Metamod/SourceMod

Periodically CS:GO will release updates which break Metamod:Source and SourceMod (the server won't start), and they will patch for the updates and release new updates. These need to be applied for the server to run properly. I will try to keep them up to date here which your server will automatically download if using my Linux gcp script but in the case I haven't updated them you can update them your self by checking the version I have bundled above and downloading the latest and putting on your server manually.

### SourceMod

[Download](https://www.sourcemod.net/downloads.php?branch=stable) Linux and Window and in each folder do the following:

From `/addons/sourcemod/` copy `bin`, `extensions`, `gamedata`, `sripting`, `translations` to your servers `/addons/sourcemod/` and *Merge All*

### Metamod:Source

[Download](http://www.sourcemm.net/downloads.php?branch=stable) Linux and Window and in each folder do the following:

From `/addons/metamod/` copy `bin` to your servers `/addons/metamod/` and *Merge All*

## Acessing admin menu

Bind a key to `sm_admin` from console i.e. `bind p sm_admin` then press `p` and the admin menu should open.

If you want to add admins, you need to edit this file `/addons/sourcemod/configs/admins_simple.ini` and add the admin to the bottom i.e. `"STEAM_0:0:56050"	"9:z"` save the file and if the server is running run `sm_reloadadmins` and reconnect to the server.

If you want to read more about admin flags you can do that [here](https://wiki.alliedmods.net/Adding_Admins_(SourceMod)).

Note: `/addons/sourcemod/configs/admins_simple.ini` will be overwritten by my script defaultly each time `install.sh` runs so once you have `install.sh` on your server you may want to update `gcp.sh` and comment out the `curl` line which downloads the latest `install.sh` as it shouldn't change too much.

Open `install.sh` and after it dynamically creates `cfg/env.cfg` you there is commented out code that will dynamically overwrite `/addons/sourcemod/configs/admins_simple.ini` with your own admins. Simply update the Steam ID's and uncomment the lines.

## Changing game modes

Once you are setup as an admin, open up the admin menu and go to Server Commands > Exec Configs and choose a game mode i.e. "Competitive" and you need to change the map for it to properly kick in so open the admin menu again and Server Commands > Maps > de_dust2 and once the server changes map the new game mode will be running.

## Running multiple servers

You can run multiple servers by modifying the launch scripts (install.sh/win.bat) and duplicating the lines that start the server and manually setting the port and optionally set the sourcemod path with `+sm_basepath addons/sourcemod_custom +exec custom.cfg +servercfgfile customserver.cfg` 

## Making changes to WarMod plugin

You need [SourceMod 1.8](http://sourcemod.net/downloads.php?all=1&branch=1.8-dev) to compile and add the following into `addons/sourcemod/scripting/includes` [tEasyFTP.inc](https://raw.githubusercontent.com/thraaawn/tEasyFTP/master/scripting/include/tEasyFTP.inc) [bzip2.inc](https://raw.githubusercontent.com/thraaawn/SMbz2/master/pawn/scripting/include/bzip2.inc) [updater.inc](https://bitbucket.org/GoD_Tony/updater/raw/12181277db77d6117052b8ddf5810c7681745156/include/updater.inc) [zip.inc](https://raw.githubusercontent.com/Versatile-BFG/sm-zip/master/sm-zip/scripting/include/zip.inc) and copy the compiled `warmod.smx` from `addons/sourcemod/scripting/compiled` to `addons/sourcemod/plugins/disabled`.

## Adding new maps to Capture The Flag

Type `!props` in chat to open the props menu.
Stand where you want the T flag and click `Spawn models > Ground` (and `Ground2` for CT) and a platform should appear in front of you. Enable `Move models (On)` and stand near it and grab it with your use key (E) and you can move it around. Rotate with reload (R) and push/pull with attack (Mouse1) and secondary fire (Mouse2).
Once you have it on the floor, click `Save models` and close the props menu.
Type `!ctf` in chat to open the Capture The Flag menu.
Aim at the floor where you want to place it and push `Spawn T flag` and click `Save flags` and close the menu.
Repeat this process for CT's and then reload the map and it should have the platform and flags.

## Running on Google Cloud

### Create firewall rule
```
gcloud compute firewall-rules create source \
--allow tcp:27015-27020,tcp:80,udp:27015-27020
```

### Create instance
You need to create a Steam [Game Login Token](https://steamcommunity.com/dev/managegameservers) and set `STEAM_ACCOUNT` to the key.

To download maps from the workshop, your server needs access to the steam web api. To allow this you'll need an authorization key which you can generate [here](http://steamcommunity.com/dev/apikey) and set `API_KEY` to the key.

If you don't want to make a [preemptible](https://cloud.google.com/compute/docs/instances/create-start-preemptible-instance#gcloud) instace; remove `--preemptible` from the below command.

```
gcloud beta compute instances create <instance-name> \
--maintenance-policy=TERMINATE \
--preemptible \
--project=<project> \
--zone=australia-southeast1-a \
--machine-type=n1-standard-2 \
--network-tier=PREMIUM \
--metadata=RCON_PASSWORD=changeme,STEAM_ACCOUNT=changeme,API_KEY=changeme,FAST_DL_URL=https://raw.githubusercontent.com/kus/csgo-modded-server-assets/master/csgo,DUCK_DOMAIN=changeme,DUCK_TOKEN=changeme,MOD_URL=https://github.com/kus/csgo-modded-server/archive/master.zip,startup-script=echo\ "Delaying\ for\ 30\ seconds..."\ &&\ sleep\ 30\ &&\ cd\ /\ &&\ /gcp.sh \
--no-restart-on-failure \
--maintenance-policy=MIGRATE \
--scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/compute.readonly,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
--tags=source \
--image-family=ubuntu-1804-lts \
--image-project=ubuntu-os-cloud \
--boot-disk-size=40GB \
--boot-disk-type=pd-standard \
--boot-disk-device-name=<instance-name>
```

### SSH to server
```
gcloud compute ssh <instance-name> \
--zone=australia-southeast1-a
```

### Install mod
```
sudo su
cd / && curl --silent --output "gcp.sh" "https://raw.githubusercontent.com/kus/csgo-modded-server/master/gcp.sh" && chmod +x gcp.sh && bash gcp.sh
```

### Stop server
```
gcloud compute instances stop <instance-name> \
--zone australia-southeast1-a
```

### Start server
```
gcloud compute instances start <instance-name> \
--zone australia-southeast1-a
```

### Delete server
```
gcloud compute instances delete <instance-name> \
--zone australia-southeast1-a
```

### Push file to server from local machine

For example a map:

```
On local:
gcloud config set project <project>
cd /path/to/folder
gcloud compute scp soccer_breezeway_lite.bsp root@<instance-name>:/home/steam/csgo/csgo/maps --zone australia-southeast1-a

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
Make sure you have **25GB free space**.

* **If setting up internet server:**

   Set environment variable `STEAM_ACCOUNT` to your [Game Server Login Token](https://steamcommunity.com/dev/managegameservers)

   Make sure you [port forward](https://portforward.com/router.htm) on your router TCP: `27015` and UDP: `27015` & `27020` so players can connect from the internet.

* **If setting up LAN server:**

   Set environment variable `LAN` to `1`

```
sudo su
export LAN="0"
export RCON_PASSWORD="changeme"
export API_KEY="changeme"
export STEAM_ACCOUNT=""
export FAST_DL_URL="https://raw.githubusercontent.com/kus/csgo-modded-server-assets/master/csgo"
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

   If you want to use my bundled maps and this server setup you can use `https://raw.githubusercontent.com/kus/csgo-modded-server-assets/master/csgo` for your `FAST_DL_URL` linux environment variable.

   Update each `/csgo/mapcycle_` file to match your maps

   Open `/install.sh` and after it dynamically creates `cfg/env.cfg` you there is commented out code that will dynamically overwrite `/addons/sourcemod/configs/admins_simple.ini` with your own admins. Simply update the Steam ID's and uncomment the lines.

   Run `./install.sh` again

When you join the server you can [change game modes](#changing-game-modes).

## Running on Windows
Make sure you have **25GB free space**.

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

## How do I connect to RCON remotely?
[Download SourceAdminTool](https://users.alliedmods.net/~drifter/SAT/) for your OS (you can read about it [here](https://forums.alliedmods.net/showthread.php?t=289370)) and click `Servers > Add Servers` and put in the `<IP>:27015` and when you see the server show in the list, down the bottom left type in your RCON password and click `Login` and you should be able to execute commands from the bottom text box i.e. `exec gg.cfg`

## FAQ

### Why can't I set the server to start automatically with a mod loaded
Because the way the server is setup with several mods it's not possible. You can't use `+exec` in the server launcher as that executes to quick before SourceMod is loaded. You can monitor the server once it's started (via RCON) and then load a mod i.e. `exec gg.cfg`.

## License

See `LICENSE` for more details.
