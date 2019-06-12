# CS:GO Modded Server

## About

A single modded Counter-Strike: Global Offensive Dedicated Server that you can change the active mod on the server from the admin menu and is setup for:
 - GunGame +Turbo (get the next weapon straight away) +Deathmatch (respawn) +Quake sounds +Mario (on 3 kills)
 - WarMod (competitive)
 - Deathmatch Free For All
 - Multi 1v1
 - Practice (record grenade throws etc)
 - Minigames
 - Deathrun
 - Surf

Includes a bash script to automatically setup a Unbuntu server on Google Cloud and a batch script for Windows.

## Mods installed

Mod | Version | Why
--- | --- | ---
[Metamod:Source](http://www.sourcemm.net/downloads.php?branch=stable) | `1.10.7-git970` | Sits between the Game and the Engine, and allows plugins to intercept calls that flow between
[SourceMod](https://www.sourcemod.net/downloads.php?branch=stable) | `1.9.0-git6280` | SourceMod is server modification for any game that runs on the Half-Life 2 engine
[GunGame](https://forums.alliedmods.net/showthread.php?t=93977) | `1.2.16` | Kill an enemy with the current weapon to get next weapon, first person to go through every weapon wins
[DeathMatch](https://forums.alliedmods.net/showthread.php?t=103242) | `1.8.0` | Adds deathmatch mode and spawn protection to the game
[Quake Sounds](https://forums.alliedmods.net/showthread.php?t=224316) | `3.5.0` | Plays sounds and displays text at certain events sometimes based on the number of kills
[NoBlock](https://forums.alliedmods.net/showthread.php?t=91617) | `1.4.2` | Removes player vs player collisions
[WarMod](https://forums.alliedmods.net/showthread.php?t=225474) | `17.08.12.1053` | Used for competitive matches, and provides the flexibility to suit any form of competition, including large tournaments down to clan matches
[Practice Mod](https://github.com/splewis/csgo-practice-mode) | `1.3.3` | Private team/individual practice servers
[Multi 1v1](https://forums.alliedmods.net/showthread.php?t=241056) | `1.1.9` | Sets up 2+ players in separate 1v1 arenas, when all the arenas are done fighting, the winners move up an arena and the losers move down an arena
[AbNeR DeathRun Manager](https://forums.alliedmods.net/showthread.php?t=272017) | `2.6` | Automates Deathrun Server
[Map configs](https://forums.alliedmods.net/showthread.php?p=607079) | `1.3` | Load mod settings on map change for mods that don't have exec's on map change
[Server Startup Configuration](https://forums.alliedmods.net/showthread.php?t=64625) | `0.2.1` | Run a config file on server boot once Source Mod loaded

## Maps

You need to source your own maps and update `csgo/mapcycle_*` to match your maps.

### Zipping maps

From the `csgo/maps/` folder:
`zip -vr -9 maps.zip . -x "*.DS_Store"`

### Unzipping on server

From the `csgo/maps/` folder:
`curl -O http://yourdomain/maps.zip && unzip -u maps.zip`

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

## Running the server on Google Cloud

### Create firewall rule
```
gcloud compute firewall-rules create source \
--allow tcp:27015-27020,udp:27015-27020
```

### Create instance
You need to create a Steam [Game Login Token](https://steamcommunity.com/dev/managegameservers) and set `STEAM_ACCOUNT` to the key.
```
gcloud compute instances create <instance-name> \
--project=<project> \
--zone=australia-southeast1-a \
--machine-type=n1-standard-2 \
--network-tier=PREMIUM \
--metadata=RCON_PASSWORD=changeme,STEAM_ACCOUNT=changeme,FAST_DL_URL=http://yourdomain/,DUCK_DOMAIN=changeme,DUCK_TOKEN=changeme,MOD_URL=https://github.com/kus/csgo-modded-server/archive/master.zip,startup-script=echo\ "Delaying\ for\ 10\ seconds..."\ &&\ sleep\ 10\ &&\ cd\ /\ &&\ /gcp.sh \
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

## License

See `LICENSE` for more details.