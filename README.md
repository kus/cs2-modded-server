# CS:GO Modded Server

## About

A single modded Counter-Strike: Global Offensive Dedicated Server that you can change the active mod on the server from the admin menu and is setup for:
 - GunGame +Turbo (get the next weapon straight away) +Deathmatch (respawn) +Quake sounds +Mario (on 3 kills)
 - WarMod (competitive)
 - Multi 1v1
 - Practice (record grenade throws etc)
 - Minigames
 - Deathrun
 - Surf

Includes a bash script to automatically setup a Unbuntu server on Google Cloud and a batch script for Windows.

## Mods installed

Mod | Version | Why
--- | --- | ---
[Metamod:Source](http://www.sourcemm.net/downloads.php?branch=stable) | `1.10.7-git968` | Sits between the Game and the Engine, and allows plugins to intercept calls that flow between
[SourceMod](https://www.sourcemod.net/downloads.php?branch=stable) | `1.9.0-git6275` | SourceMod is server modification for any game that runs on the Half-Life 2 engine
[GunGame](https://forums.alliedmods.net/showthread.php?t=93977) | `1.2.16` | Kill an enemy with the current weapon to get next weapon, first person to go through every weapon wins
[DeathMatch](https://forums.alliedmods.net/showthread.php?t=103242) | `1.8.0` | Adds deathmatch mode and spawn protection to the game
[Quake Sounds](https://forums.alliedmods.net/showthread.php?t=224316) | `3.5.0` | Plays sounds and displays text at certain events sometimes based on the number of kills
[NoBlock](https://forums.alliedmods.net/showthread.php?t=91617) | `1.4.2` | Removes player vs player collisions
[WarMod](https://forums.alliedmods.net/showthread.php?t=225474) | `17.08.12.1053` | Used for competitive matches, and provides the flexibility to suit any form of competition, including large tournaments down to clan matches
[Practice Mod](https://github.com/splewis/csgo-practice-mode) | `1.3.3` | Private team/individual practice servers
[Multi 1v1](https://forums.alliedmods.net/showthread.php?t=241056) | `1.1.9` | Sets up 2+ players in separate 1v1 arenas, when all the arenas are done fighting, the winners move up an arena and the losers move down an arena
[AbNeR DeathRun Manager](https://forums.alliedmods.net/showthread.php?t=272017) | `2.6` | Automates Deathrun Server
[Map configs](https://forums.alliedmods.net/showthread.php?p=607079) | `1.3` | Load mod settings on map change for mods that don't have exec's on map change

## Maps

You need to source your own maps and update `csgo/mapcycle_*` to match your maps.

### Zipping maps

From the `csgo/maps/` folder:
`zip -vr -9 maps.zip . -x "*.DS_Store"`

### Unzipping on server

From the `csgo/maps/` folder:
`curl -O http://yourdomain/maps.zip && unzip -u maps.zip`

## License

See `LICENSE` for more details.