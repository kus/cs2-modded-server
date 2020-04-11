# CS:GO Modded Server

## About

A single modded Counter-Strike: Global Offensive Dedicated Server that you can change the active mod on the server from the admin menu and is setup for:
 - GunGame +Turbo (get the next weapon straight away) +Deathmatch (respawn) +Quake sounds +Mario (on 3 kills)
 - WarMod (competitive)
 - Deathmatch Free For All
 - Retakes
 - Multi 1v1
 - Practice (record grenade throws etc)
 - Minigames
 - Deathrun
 - Surf
 - Kreedz Climbing
 - Soccer

Getting up and running:
 - [Running on Linux](#running-on-linux)
 - [Running on Windows](#running-on-windows)
 - [Running on Google Cloud](#running-on-google-cloud)

## Mods installed

Mod | Version | Why
--- | --- | ---
[Metamod:Source](http://www.sourcemm.net/downloads.php?branch=stable) | `1.10.7-git971` | Sits between the Game and the Engine, and allows plugins to intercept calls that flow between
[SourceMod](https://www.sourcemod.net/downloads.php?branch=stable) | `1.10-git6478` | SourceMod is server modification for any game that runs on the Half-Life 2 engine
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

## Maps

You need to source your own maps and update `csgo/mapcycle_*` to match your maps.

### Download maps

```
# cd to "csgo" parent directory so you are in the same folder as srcds
cd /home/steam/csgo/
curl --silent --output "automate.sh" "https://raw.githubusercontent.com/kus/csgo-modded-server-assets/master/automate.sh" && chmod +x automate.sh && bash automate.sh
```

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

## Running on Google Cloud

### Create firewall rule
```
gcloud compute firewall-rules create source \
--allow tcp:27015-27020,80,udp:27015-27020
```

### Create instance
You need to create a Steam [Game Login Token](https://steamcommunity.com/dev/managegameservers) and set `STEAM_ACCOUNT` to the key.
```
gcloud compute instances create <instance-name> \
--project=<project> \
--zone=australia-southeast1-a \
--machine-type=n1-standard-2 \
--network-tier=PREMIUM \
--metadata=RCON_PASSWORD=changeme,STEAM_ACCOUNT=changeme,FAST_DL_URL=https://raw.githubusercontent.com/kus/csgo-modded-server-assets/master/csgo,DUCK_DOMAIN=changeme,DUCK_TOKEN=changeme,MOD_URL=https://github.com/kus/csgo-modded-server/archive/master.zip,startup-script=echo\ "Delaying\ for\ 30\ seconds..."\ &&\ sleep\ 30\ &&\ cd\ /\ &&\ /gcp.sh \
--no-restart-on-failure \
--maintenance-policy=MIGRATE \
--scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/compute.readonly,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
--tags=source \
--image=ubuntu-1604-xenial-v20190306 \
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

## Running on Linux
Make sure you have **25GB free space**.

* **If setting up internet server:**

   Set environment variable `STEAM_ACCOUNT` to your [Game Server Login Token](https://steamcommunity.com/dev/managegameservers)

* **If setting up LAN server:**

   Set environment variable `LAN` to `1`

```
sudo su
export LAN="0"
export RCON_PASSWORD="changeme"
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

* **If setting up LAN server:**

   Open `\csgo\cfg\env.cfg`

   Set `sv_lan` to `1`

[Add admins](#acessing-admin-menu)

Run `win.bat`

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
Because the way the server is setup with several mods it's not possible. You can't use +exec in the server launcher as that executes to quick before SourceMod is loaded. You can monitor the server once it's started (via RCON) and then load a mod i.e. `exec gg.cfg` then `changelevel ar_shoots`.

It would need a custom plguin that once the first map has loaded, it would execute a mod.cfg delayed and then change the map with a slight delay.

### Why can't I set when a mod is loaded that it changes map
I tried this, and it happens to fast before the mods are fully loaded. If there was a way to delay the map change command that would work.

## License

See `LICENSE` for more details.