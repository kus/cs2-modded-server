# Counter-Strike 2 (CS2) Modded Dedicated Server

If you are looking for the CS:GO version you can still access that [here](https://github.com/kus/csgo-modded-server/tree/csgo).

## About

A single modded Counter-Strike 2 (CS2) Modded Dedicated Server that you can [change the active mod](#changing-game-modes) on the server from chat or server console. [Maps are pre setup and configured per game mode](#setting-maps-for-different-game-modes) and change when the game mode changes.

Each game mode has a hand full of maps preset so you are ready to go and it's [easy to add more](#setting-maps-for-different-game-modes).

- 1v1 (allows more than 2 players) ([Steam API key](#playing-workshop-mapscollections) required)
- Deathmatch ([Steam API key](#playing-workshop-mapscollections) required)
- Competitive (using [MatchZy](https://github.com/shobhit-pathak/MatchZy#usage-commands))
- Practice (record grenade throws etc)
- Wingman (allows more than 4 players) ([Steam API key](#playing-workshop-mapscollections) required)
- KZ ([Steam API key](#playing-workshop-mapscollections) required)
- BHop ([Steam API key](#playing-workshop-mapscollections) required)
- Surf ([Steam API key](#playing-workshop-mapscollections) required)
- ScoutzKnivez ([Steam API key](#playing-workshop-mapscollections) required)
- Mini Games ([Steam API key](#playing-workshop-mapscollections) required)
- Course format (tests players with different traps, kz, surf, bhop) ([Steam API key](#playing-workshop-mapscollections) required)
- Hide n Seek ([Steam API key](#playing-workshop-mapscollections) required)
- Soccer ([Steam API key](#playing-workshop-mapscollections) required)

Every time you want to boot the server, you should run `gcp.sh` (if on Google Cloud) or `install.sh` (on Linux) and it will ensure your OS is up to date, CS2 is up to date, and pull down the latest patches from this mod (any updates that I push up).

Obviously, any changes you have made to the files in this mod will be overwritten so I have created a "[custom files](#custom-files)" folder where you mirror the contents of the `game/csgo/` folder, and any files you want to tweak, you put in there in the same spot and they will always overwrite the mods default files. Read more about it [here](#custom-files).

The simple quick setup:

1. [Create your firewall rules](#create-firewall-rule)
2. [Provision your server on Google Cloud](#create-instance)
3. [SSH into server](#ssh-to-server)
4. [Install mod](#install-mod)
5. [Create your custom files for hostname, admins etc](#custom-files)
6. Ensure you have followed the steps for creating an [online server](#creating-an-online-server) or [LAN server](#creating-a-lan-server)
7. Kill server if running `./stop.sh` and start again `gcp.sh` (if on Google Cloud) or `install.sh` (on Linux)

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

Getting up and running:

- [Running on Google Cloud](#running-on-google-cloud)
- [Running on Linux](#running-on-linux)

## Mods installed

Mod | Version | Why
--- | --- | ---
[Metamod:Source](http://www.sourcemm.net/downloads.php?branch=master) | `2.0.0-1270` | Sits between the Game and the Engine, and allows plugins to intercept calls that flow between
[CounterStrikeSharp](https://github.com/roflmuffin/CounterStrikeSharp) | `86` | Attempts to implement a .NET Core scripting layer on top of a Metamod Source Plugin, allowing developers to create plugins that interact with the game server in a modern language (C#)
[CS2_ExecAfter](https://github.com/kus/CS2_ExecAfter) | `1.0.0` | Executes a command after server event (i.e. OnMapStart) or a delay.
[CS2_DamageInfo](https://github.com/K4ryuu/CS2_DamageInfo) | `1.3.3` | Displays the amount of damage players have inflicted on the victim's HP and Armor, as well as the hit groups they have hit.
[MatchZy](https://github.com/shobhit-pathak/MatchZy) | `0.4.3` | MatchZy is a plugin for CS2 for running and managing practice/pugs/scrims/matches with easy configuration!
[MapConfigurator](https://github.com/ManifestManah/MapConfigurator)| `1.0.2` | Allows you to quick and easily create unique configuration files for each map on your server.
[SimpleAdmin](https://github.com/connercsbn/SimpleAdmin/)| `0.0.3` | Adds basic administrator functions
[LiteMapChooser](https://github.com/PhantomYopta/LiteMapChooser)| `1.0.2` | This plugin allows you to change map, nominate map, rtv
[CS2Rcon](https://github.com/LordFetznschaedl/CS2Rcon)| `1.2.0` | This is a rudimentary implementation of a RCON plugin for CS2 using CounterStrikeSharp as RCON does not work whilst connected to the server
[SharpTimer](https://github.com/DEAFPS/SharpTimer/)| `0.0.8` | SharpTimer is a simple Surf/KZ/Bhop/MG/Deathrun/etc CS2 Timer plugin

## Custom files

Any changes you have made to the files in this mod will be overwritten when the update scripts are ran. I have created a folder `/custom_files/` in the root of the project, where you mirror the contents of the `csgo/` folder, and any files you want to tweak, you put in there in the same spot and they will always overwrite the mods default files.

So this can be used to set the server hostname to something you want, set the RCON or serverpassword or set the admins of the server.

You can see an example of what I use on my server in the `/custom_files_example/` directory, which sets the hostname, server image and admins.

For example; if you want to add yourself as an admin, that file is located `/game/csgo/addons/counterstrikesharp/configs/admins.json`. So to make your tweak to it, you would copy that file to `/custom_files/addons/counterstrikesharp/configs/admins.json` and add yourself as an admin at the bottom. Then when the update scripts run, it will copy your custom file at `/custom_files/addons/counterstrikesharp/configs/admins.json` and overwrite the default mod file at `/game/csgo/addons/counterstrikesharp/configs/admins.json`.

If you want to change the server name, or make any changes to any mod settings use the `/cfg/custom_MOD.cfg` as it executes at the end and can overwrite any setting. So if you wanted to change the server name for GunGame, you would copy `/game/csgo/cfg/custom_dm.cfg` to `/custom_files/cfg/custom_dm.cfg` and and write `hostname "shipREKT GunGame +Deathmatch +Turbo"` and any other settings you want and this file will overwrite `/game/csgo/cfg/custom_dm.cfg` each time the `gcp.sh`/`install.sh`/`win.bat` script is ran, and these settings will run at the end when you load the GunGame mod.

To generate this directory, you can run the `gcp.sh` script (if on Google Cloud), `install.sh` script on Linux once or on `win.bat` script on Windows where you extracted the mod zip and this is where you would put your custom modifications.

## Creating an online server

If you are hosting an online server, you need to create a Steam [Game Login Token](https://steamcommunity.com/dev/managegameservers), your server will not run online without this. Put this value in the `STEAM_ACCOUNT` environment variable or create a custom file for `/game/csgo/cfg/secrets.cfg` following the [custom files](#custom-files) steps (`/custom_files/cfg/secrets.cfg`) and set it in `sv_setsteamaccount`.

You also need to create an [authorization key](http://steamcommunity.com/dev/apikey) which will allow your server to download maps from the workshop. Put this value in the `API_KEY` environment variable.

**You must connect to the server from the public IP, not the LAN IP even if you are on the same network. The script logs the public IP `Starting server on XXX.XXX.XXX.XXX:27015`**

## Creating a LAN server

Create a custom file for `/game/csgo/cfg/env.cfg` following the [custom files](#custom-files) steps (`/custom_files/cfg/env.cfg`) and set `sv_lan` to `1`, `sv_downloadurl` to `""` and `sv_allowdownload` to `1`.

## Environment variables

### Available via environment variable only

Key | Default value | What is it
--- | --- | ---
`API_KEY` | `changeme` | To download maps from the workshop, your server needs access to the steam web api. To allow this you'll need an authorization key which you can generate [here](http://steamcommunity.com/dev/apikey)
`MOD_URL` | `https://github.com/kus/cs2-modded-server/archive/master.zip` | The zip for mod files to download and extract (defaultly this repo)
`IP` | `` | Not required. Allows the server IP to be set. Useful if a CS2 server needs to be bound to a specific IP address.
`PORT` | `27015` | Server port
`TICKRATE` | `128` | Server tickrate MM is 64, Faceit is 128
`MAXPLAYERS` | `32` | Max player limit
`DUCK_DOMAIN` | `` | [Duck DNS](https://www.duckdns.org/) domain if you want to utalise the free service to get a domain for your server instead of IP
`DUCK_TOKEN` | `` | [Duck DNS](https://www.duckdns.org/) access token to update domain when server boots
`CUSTOM_FOLDER` | `custom_files` | Folder of your own modifications to the mod that mirror the csgo/ structure and overwrite the mode files. More on that [here](#custom-files)

### Can be configured via config file in custom files directory

These values can be set via environment variable or a config file in the custom files directory.
Copy `/game/csgo/cfg/secrets.cfg` to `/custom_files/cfg/secrets.cfg` and write the values you want and this file will overwrite `/game/csgo/cfg/secrets.cfg` each time the `gcp.sh`/`install.sh` script is ran.

Key | Value | What is it
--- | --- | ---
`RCON_PASSWORD` | `changeme` | RCON password to control server from console also remotely configure
`STEAM_ACCOUNT` | `` | To host a server online, you need to create a Steam [Game Login Token](https://steamcommunity.com/dev/managegameservers). Your server will not run online without this
`SERVER_PASSWORD` | `` | If you want a password protected server

### Playing workshop maps/collections

To download maps from the workshop, your server needs access to the steam web api. To allow this you'll need an authorization key which you can generate [here](http://steamcommunity.com/dev/apikey) and set `API_KEY` to the key.

The console command for hosting a workshop map is `host_workshop_map fileid` where `fileid` is the number that comes after `?id=` in the workshop URL for example: [https://steamcommunity.com/sharedfiles/filedetails/?id=2433686680](https://steamcommunity.com/sharedfiles/filedetails/?id=2433686680)

The console command for hosting a workshop collection is `host_workshop_collection collectionid` where `collectionid` is the number that comes after `?id=` in the workshop URL for example: [https://steamcommunity.com/sharedfiles/filedetails/?id=1092904694](https://steamcommunity.com/sharedfiles/filedetails/?id=1092904694). This command will then download all maps in the collection and create a mapgroup out of them, then host it.

### Setting maps for different game modes

Copy the file `/game/csgo/gamemodes_server.txt` following the [custom files](#custom-files) steps (`/custom_files/gamemodes_server.txt`) and add the maps you want per gamemode. Most gamemodes fall under casual, but I have created unique groups for each mode so adding your own maps is easy by updating this one file.

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
--metadata=RCON_PASSWORD=changeme,STEAM_ACCOUNT=changeme,API_KEY=changeme,DUCK_DOMAIN=changeme,DUCK_TOKEN=changeme,MOD_URL=https://github.com/kus/cs2-modded-server/archive/master.zip,startup-script="echo \"Delaying for 30 seconds...\" && sleep 30 && cd / && /gcp.sh" \
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
export MOD_URL="https://github.com/kus/cs2-modded-server/archive/master.zip"
export SERVER_PASSWORD=""
export PORT="27015"
export TICKRATE="128"
export MAXPLAYERS="32"
cd / && curl --silent --output "install.sh" "https://raw.githubusercontent.com/kus/cs2-modded-server/master/install.sh" && chmod +x install.sh && bash install.sh
```

- **If running for the first time**

   Once the CS2 server has started close it

   Open `/install.sh` and after it dynamically creates `cfg/env.cfg` you there is commented out code that will dynamically overwrite `/addons/sourcemod/configs/admins_simple.ini` with your own admins. Simply update the Steam ID's and uncomment the lines.

   Run `./install.sh` again

To check everything is working correctly run the following commands in the server console:

- `meta list` and you should see `CounterStrikeSharp` in the output
- `css_plugins list` and you should see a few plugins in the output

If you see content in both; everything is working.

When you join the server you can [change game modes](#changing-game-modes).

## Running on Windows

Make sure you have **60GB free space**.

[Download this repo](https://github.com/kus/cs2-modded-server/archive/master.zip) and extract it to where you want your server (i.e. `C:\Server\cs2-modded-server`). All the following instructions will use this as the root.

Edit `\game\csgo\gameinfo.gi` and search for `Game_LowViolence    csgo_lv` it should be under `GameInfo > FileSystem > SearchPaths` and below it add `Game    csgo/addons/metamod` and save the file. You can find detailed instructions [here](https://cs2.poggu.me/metamod/installation/).

Create a folder `steamcmd` and [download SteamCMD](https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip) and extract it inside `steamcmd` so you should have `\steamcmd\steamcmd.exe`.

- **If setting up internet server:**

   Open `\csgo\cfg\env.cfg`

   Set `sv_setsteamaccount` to your [Game Server Login Token](https://steamcommunity.com/dev/managegameservers)

   Open `\win.ini`

   Set `ip_internet` to your [public ip](http://checkip.amazonaws.com/)

   Make sure you [port forward](https://portforward.com/router.htm) on your router TCP: `27015` and UDP: `27015` & `27020` so players can connect from the internet.

   **You must connect to the server from the public IP, not the LAN IP even if you are on the same network.**

- **If setting up LAN server:**

   Open `\csgo\cfg\env.cfg`

   Set `sv_lan` to `1`

[Add admins](#acessing-admin-menu)

Run `win.bat`

Accept both Private and Public connections on Windows Firewall.

- **If running for the first time**

   Once the CS2 server has started close it

   If you want to use my bundled maps and this server setup you can use `https://raw.githubusercontent.com/kus/cs2-modded-server-assets/master/game/csgo` for your your `sv_downloadurl` in `cfg/env.cfg`. Make sure you change `sv_allowdownload` to `0`.

   Run `win.bat` again

To check everything is working correctly run the following commands in the server console:

- `meta list` and you should see `CounterStrikeSharp` in the output
- `css_plugins list` and you should see a few plugins in the output

If you see content in both; everything is working.

When you join the server you can [change game modes](#changing-game-modes).

## FAQ

### How do I add more bots?

By default bots are enabled in deathmatch, gungame, gungame ffa, retakes, scoutsknives and wingman.

The default is set to add 1 bot if only 1 human is in the server, and then if there is 2 or more humans there will be no bots.

You can overwrite the settings for the bots by creating a "[custom file](#custom-files)" for this file [custom_bots.cfg](https://github.com/kus/cs2-modded-server/blob/master/game/csgo/cfg/custom_bots.cfg).

If you copy [custom_bots.cfg](https://github.com/kus/cs2-modded-server/blob/master/game/csgo/cfg/custom_bots.cfg) and put it in the `custom_files/cfg/` directory (`/home/steam/cs2/custom_files/cfg/` on default Linux setup) and you can modify it and change say `bot_quota` to `10` if you want 10 players at all times. When the server starts (on Linux and Windows) it will merge this file into the game cfg and it will execute every time `bots.cfg` executes.

You can also just login to RCON `rcon_password yourpassword` and use `rcon bot_add_ct` and `rcon bot_add_t`.

If you want to remove bots you use `rcon bot_kick`.

### Failed to open libtier0.so

`Failed to open libtier0.so (/home/steam/cs2/bin/libgcc_s.so.1: version 'GCC_7.0.0' not found (required by /lib/i386-linux-gnu/libstdc++.so.6))`

This is because Valve ships their own copies of those libraries. As modern systems will have newer versions, you can safely delete the listed file from the server install. Do not delete the file in the system path (usually lib or lib32)[*](https://wiki.alliedmods.net/Installing_metamod:source).

`cd /home/steam/cs2/bin/` and `rm libgcc_s.so.1` and restart the server.

### How do I connect to RCON remotely?

[Download SourceAdminTool](https://nightly.link/Drifter321/admintool/workflows/build/master) ([source](https://github.com/Drifter321/admintool)) for your OS (you can read about it [here](https://forums.alliedmods.net/showthread.php?t=289370)) and click `Servers > Add Servers` and put in the `<IP>:27015` and when you see the server show in the list, down the bottom left type in your RCON password and click `Login` and you should be able to execute commands from the bottom text box i.e. `exec dm.cfg`

**You must connect to the server from the public IP if hosting an online server, not the LAN IP even if you are on the same network. The script logs the public IP `Starting server on XXX.XXX.XXX.XXX:27015`**

### Why can't I set the server to start automatically with a mod loaded

Because the way the server is setup with several mods it's not possible. You can't use `+exec` in the server launcher as that executes to quick before SourceMod is loaded. You can monitor the server once it's started (via RCON) and then load a mod i.e. `exec dm.cfg`.

## Acessing admin menu

Admins are managed by [CounterStrikeSharp](https://github.com/roflmuffin/CounterStrikeSharp) using the [Admin Framework](https://docs.cssharp.dev/admin-framework/defining-admins/). You define admins and their flags and most plugins now utilise this framework.

To see an example of my admins you can look at this file [/custom_files_example/addons/counterstrikesharp/configs/admins.json](https://github.com/kus/cs2-modded-server/blob/master/custom_files_example/addons/counterstrikesharp/configs/admins.json). To set your admins on your own server use this file as a reference and use the [custom files](#custom-files) system to have your own version.

## Changing game modes

There is no "menu" feature in CS2, so it's all via the chat window or server console.

The easiest way to manage the server is to use the Rcon commands via chat i.e. `!rcon exec dm` will change to deathmatch.

These are all the available chat commands to change the game mode:

| Command                | Game mode                                                                         |
| ---------------------- | --------------------------------------------------------------------------------- |
| `!rcon exec 1v1`     | 1v1 (allows more than 2 players)                                                    |
| `!rcon exec bhop`    | Bunny hop maps                                                                    |
| `!rcon exec comp`    | Competitive using [MatchZy](https://github.com/shobhit-pathak/MatchZy#usage-commands) |
| `!rcon exec course`  | Tests players with different traps, kz, surf, bhop                                |
| `!rcon exec dm`      | Deathmatch                                                                        |
| `!rcon exec hns`     | Hide n Seek                                                                       |
| `!rcon exec kz`      | Kreedz Climbing                                                                   |
| `!rcon exec minigames` | Mini Games                                                                      |
| `!rcon exec prac`    | Practice (grenade lineups etc)                                                    |
| `!rcon exec scoutzknivez` | ScoutzKnivez                                                                 |
| `!rcon exec soccer`  | Soccer                                                                            |
| `!rcon exec surf`    | Surf                                                                              |
| `!rcon exec wingman` | Wingman (allows more than 4 players)                                              |

Changing between gamemodes multiple times is not recommended, and it is better if you restart the CS2 server in-between.

To view what other commands are available view the plugins at the top of the page.

## RCON doesn't work

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

## License

See `LICENSE` for more details.
