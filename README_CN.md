# Counter-Strike 2 (CS2) 模组服

如果你需要CS:GO版本的服务器文件，可以前往 [此处](https://github.com/kus/csgo-modded-server/tree/csgo).

## 关于

这是一个为CS2制作的预设多个 [可调整的模组](#changing-game-modes) 的服务器，这些模组模式可以通过游戏内聊天或服务器控制台更改. [所有地图都为这些游戏模式做了预设](#what-maps-are-preconfigured-with-each-mode) ，并且可以在游戏模式更换时随之更改.

所有游戏模式都有其相对应的地图池预设，同时也可以 [自由调整/添加](#setting-maps-for-different-game-modes).

- 1v1 (with arenas) (需要[Steam API key](#playing-workshop-mapscollections))
- Deathmatch//死斗/死亡竞赛 (需要[Steam API key](#playing-workshop-mapscollections))
- Competitive//竞技模式 (利用 [MatchZy](https://github.com/shobhit-pathak/MatchZy#usage-commands))
- Practice//练习 (例如练习扔雷)
- Prefire practice//提前枪练习
- GunGame//军备竞赛
- Retake//回防
- Executes//处决
- Wingman //飞狙(允许4人及以上) (需要[Steam API key](#playing-workshop-mapscollections))
- KZ (需要[Steam API key](#playing-workshop-mapscollections))
- BHop//兔子跳 (需要[Steam API key](#playing-workshop-mapscollections))
- Surf//滑行 (需要[Steam API key](#playing-workshop-mapscollections))
- ScoutzKnivez//刀战 (需要[Steam API key](#playing-workshop-mapscollections) )
- Mini Games //小游戏(需要[Steam API key](#playing-workshop-mapscollections) )
- Deathrun //死亡跑酷(需要[Steam API key](#playing-workshop-mapscollections))
- Course format//闯关 (需要[Steam API key](#playing-workshop-mapscollections))
- Hide n Seek//躲猫猫 需要[Steam API key](#playing-workshop-mapscollections))
- Soccer//足球 (需要[Steam API key](#playing-workshop-mapscollections))

启动服务器前, 你需要先运行 `gcp.sh` (使用Google Cloud时) 或`install.sh` (使用Linux时) 以确保系统和CS2都处于最新状态, 并下载我上传的模组更新.

也正因如此，更新可能导致你的服务器文件被还原，所以我建立了 "[custom files](#custom-files)" 文件夹，以此模拟 `game/csgo/` 文件夹, 将你所要更改的文件放入此处，在服务器启动时便会自动将里面的文件复制到服务端文件夹中。 详情[见此](#custom-files).

快速设置步骤:

1. [建立防火墙规则](#建立防火墙规则)
2. [将服务器文件上传至谷歌云](#建立进程)
3. [利用SSH登录服务器](#利用SSH登录服务器)
4. [安装 mod](#安装mod)
5. [设置自定义文件，管理员等等](#自定义文件)
6. 确保你已完成了 [建立线上服务器](#建立线上服务器) 或 [本地服务器](#建立本地服务器)的步骤
7. 关闭服务器： `./stop.sh` ，重启服务器 `gcp.sh` (使用Google Cloud时) or `install.sh` (使用Linux时)

到此你的服务器就可以正常运行了!

若要检查服务器是否正常运作，可在服务器控制台输入下列指令:

- `meta list` 会输出 `CounterStrikeSharp`
- `css_plugins list` 会输出一些已被启用的模组

如果两个输出都正常，代表服务器在正常运行.

> [!注意]
> 连接服务器时，无法使用RCON.原因[见此](https://www.reddit.com/r/GlobalOffensive/comments/167spzi/cs2_rcon/).
> 替代方案如下:
>
> - 模组中包含 [CS2Rcon](https://github.com/LordFetznschaedl/CS2Rcon) ，管理员可在聊天框里输入!rcon以使用相关功能.
> - 离开服务器，然后在服务器控制台中输入 `rcon_address IP:PORT`即可使用rcon命令.
> - 使用外置RCON软件，例如 [这个](https://github.com/fpaezf/CS2-RCON-Tool-V2).

有用的东西:

- [启用管理员菜单](#启用管理员菜单)
- [切换游戏模式](#更换游戏模式)
- [更换地图](#更换地图)
- [玩家指令](#玩家指令)

服务器设置:

- [Google Cloud](#GoogleCloud上运行)
- [Linux](#Linux上运行)
- [Docker](#Docker上运行)
- [Windows](#Windows上运行)

## 包含的mod

Mod | Version | 介绍
--- | --- | ---
[Metamod:Source](http://www.sourcemm.net/downloads.php?branch=master) | `2.0.0-1293` | 作为游戏与引擎的“桥梁”，允许插件在其上运行，是很多CS2服务端插件的前置
[CounterStrikeSharp](https://github.com/roflmuffin/CounterStrikeSharp) | `237` |在Metamod Source插件上设置一个.NET核心插件运行层,使开发者们能以现代语言开发插件(C#)
[CS2_ExecAfter](https://github.com/kus/CS2_ExecAfter) | `1.0.0` | 在服务器开始特定事件(i.e. OnMapStart)时或延时执行指令.
[CS2 Remove Map Weapons](https://github.com/kus/CS2-Remove-Map-Weapons) | `1.0.1` | 移除地图上的武器，因为 `mp_weapons_allow_map_placed 0`指令无效.
[CS2_DamageInfo](https://github.com/K4ryuu/CS2_DamageInfo) | `2.3.2` | 显示玩家受击与造成伤害的记录.
[GameModeManager](https://github.com/nickj609/GameModeManager)| `1.0.3-custombuild` | 便于服务器管理员管理服务器上运行的游戏模式.
[Rock The Vote](https://github.com/abnerfs/cs2-rockthevote)| `1.8.5-custombuild` | CS2地图更换投票插件，是人家从头开始制作出来的。
[MatchZy](https://github.com/shobhit-pathak/MatchZy) | `0.7.11` | MatchZy是一个能轻松管理练习/pugs/scrims/比赛的插件，设置非常简单!
[MapConfigurator](https://github.com/ManifestManah/MapConfigurator)| `1.0.2` | 允许你在不同地图上套用不同的配置文件.
[SimpleAdmin](https://github.com/connercsbn/SimpleAdmin/)| `0.1.2` | 添加基础管理功能。
[CS2Rcon](https://github.com/LordFetznschaedl/CS2Rcon)| `1.2.0` | 对RCON无法通过控制台启用缺陷的替代方案
[SharpTimer](https://github.com/DEAFPS/SharpTimer/)| `0.2.5` | SharpTimer 用于 Surf/KZ/Bhop/MG/Deathrun/etc 模式的计时
[GunGame](https://github.com/ssypchenko/cs2-gungame)| `1.1.1` | 利用Counter Strike Sharp制作的军备竞赛模式
[K4-Arenas](https://github.com/K4ryuu/K4-Arenas)| `1.4.3` | 提供竞技场模式的支持.支持所有地图, 2v2/3v3/etc
[CS2 Retakes](https://github.com/B3none/cs2-retakes)| `2.0.5` | 回防模式支持
[CS2 Retakes Shared](https://github.com/B3none/cs2-retakes)| `2.0.0` | 回防模式插件资源.
[CS2 Instadefuse](https://github.com/B3none/cs2-instadefuse)| `1.4.3` | 允许CT在T方无人时立即拆除炸弹
[CS2 Retakes Allocator](https://github.com/yonilerner/cs2-retakes-allocator)| `2.3.10` | 为B3none/cs2-retakes设计的武器分配系统
[CS2 Whitelist](https://github.com/PhantomYopta/CS2_WhiteList)| `1.0.0`| 服务器白名单[使用方法](#enable-whitelist-so-only-a-list-of-people-can-play)
[CS2 Executes](https://github.com/zwolof/cs2-executes)| `1.0.4` | CS2处决模式支持
[CS2 Advertisement](https://github.com/partiusfabaa/cs2-advertisement)| `1.0.6.8` | 允许在聊天框等处推送通知与广告 [使用方法](#enable-advertisements)
[CS2 Deathmatch](https://github.com/NockyCZ/CS2-Deathmatch)| `1.1.3` | 自定义死斗模式(包含自定义出生点，多配置文件支持，选枪，出生保护, etc)
[OpenPrefirePrac](https://github.com/lengran/OpenPrefirePrac)| `0.1.35` | 在竞技地图上的提前枪练习，支持多人.
[CS2-CustomVotes](https://github.com/imi-tat0r/CS2-CustomVotes)| `1.0.1` | 允许建立自定义投票.
[deathrun-manager](https://github.com/leoskiline/cs2-deathrun-manager)| `0.0.8` | 死亡跑酷管理，基于css插件.
[AnnouncementBroadcaster](https://github.com/lengran/CS2AnnouncementBroadcaster) | `0.3.1` | 多种特定情境提醒, OnCommand, OnPlayerConnect, OnRoundStart, and TimerMsgs.

## 分享快乐！

如果你喜欢这个repo的内容，别忘了给个Star！ 🙏

<img alt="Star the project" src="https://github.com/kus/cs2-modded-server/blob/assets/assets/star.png?raw=true&sanitize=true">

## 保持更新

关注以获知更新资讯:

<img alt="Subscribe to updates" src="https://github.com/kus/cs2-modded-server/blob/assets/assets/watch.png?raw=true&sanitize=true">

## 自定义文件

> [!注意]  
> 下文所述的文件地址均以服务端安装位置为根目录. Linux上经常会是 `/home/steam/cs2/` ，而在Windows则是你解压缩文件的地方.
>
> 例如Linux:
> `/custom_files/addons/counterstrikesharp/configs/admins.json` 完整路径应为 `/home/steam/cs2/custom_files/addons/counterstrikesharp/configs/admins.json`
> `/game/csgo/addons/counterstrikesharp/configs/admins.json` 完整路径应为 `/home/steam/cs2/game/csgo/addons/counterstrikesharp/configs/admins.json`

服务器文件更新时，你的服务端的文件可能会被覆盖. 我建立了 "[custom files]" 文件夹，以此模拟 `game/csgo/` 文件夹, 将你所要更改的文件放入此处，在服务器启动时便会自动将里面的文件复制到服务端文件夹中。

这样一来，你就可以用来设置服务器名，设置管理员与RCON密码.

你可以查看文件中的例子，即`/custom_files_example/`文件夹, 展示了服务器名，服务器图片与管理员的设置.

例如; 若要将你自己设为管理员，你可以打开 `/game/csgo/addons/counterstrikesharp/configs/admins.json`. 修改后,将文件复制至 `/custom_files/addons/counterstrikesharp/configs/admins.json` 然后在文件底部写入你的管理员信息. 之后更新文件运行时,它都会自动将 `/custom_files/addons/counterstrikesharp/configs/admins.json` 覆盖到 `/game/csgo/addons/counterstrikesharp/configs/admins.json`.

如果你要修改服务器名, 或者在`/cfg/custom_MOD.cfg` 调整mod设置. 由于它会在服务器启动的后期运行，导致设置被重置。因此如果你要把服务器名改为GunGame,你需要复制 `/game/csgo/cfg/custom_dm.cfg` 到 `/custom_files/cfg/custom_dm.cfg` 然后写入 `hostname "shipREKT GunGame +Deathmatch +Turbo"`及其他你想添加的设置。该文件会在每次 `gcp.sh`/`install.sh`/`win.bat`运行时覆盖`/game/csgo/cfg/custom_dm.cfg` , 这些设置便会在启动 GunGame mod模式时自动应用.

### plugin文件夹下config配置文件的管理

如果安装的一个插件在dll安装的地方生成了配置文件(i.e.: `/game/csgo/addons/counterstrikesharp/plugins/disabled/Advertisement/advertisement.json`) ，它会在服务器启动过程中同 `addons` 文件夹被删除。这样做是为了删除我在新版本中删除的插件。 你需要手动将该配置文件复制到`/custom_files/` 文件夹，这样它就会自动复制回服务器文件夹. 例如在 `/custom_files/addons/counterstrikesharp/plugins/disabled/Advertisement/advertisement.json` 中做改动，可以在每次服务器启动时将改文件复制进服务端目录，这样一来你就不会丢失你的更改了.

若要生成该文件夹, 你可以运行`gcp.sh` 脚本 (Google Cloud), `install.sh` 脚本 （Linux） 或 `win.bat` 脚本 （Windows）.

## 建立线上服务器

若要建立线上服务器, 你需要Steam [游戏登陆密钥](https://steamcommunity.com/dev/managegameservers), 这是使你的服务器能公开加入的必要条件. 将生成的密钥填入 `STEAM_ACCOUNT` 环境变量中.

同时你还需要建立 [API授权密钥](http://steamcommunity.com/dev/apikey) 以使你的服务器能够下载创意工坊上的地图. 将生成的密钥填入 `API_KEY` 环境变量中.

详见 [环境变量](#environment-variables).

**若要连接服务器，你需要连接公开IP, 而非本地IP，即使在同一网络下也要如此. 脚本会以如下方式记录公开IP `Starting server on XXX.XXX.XXX.XXX:27015`**

## 建立本地服务器

将环境变量 `LAN` 设为 `1`.

同时你还需要建立 [API授权密钥](http://steamcommunity.com/dev/apikey)以使你的服务器能够下载创意工坊上的地图. 将生成的密钥填入 `API_KEY` 环境变量中.

详见 [环境变量](#environment-variables).

## 环境变量

### 下列设置仅能通过环境变量更改

*Windows端在  `win.ini`中设置.*

名称| 默认值| 解释
--- | --- | ---
`API_KEY` | `changeme` |你需要API授权密钥以从创意工坊下载地图. API授权密钥可在 [此处](http://steamcommunity.com/dev/apikey)生成
`IP` | `` | 非必要.可调整服务器IP为一固定值. 多适用于服务器需要在特定IP地址上运行的时候.
`PORT` | `27015` | 服务器端口
`TICKRATE` | `128` | 服务器tick,MM为64, Faceit 为128
`MAXPLAYERS` | `32` | 最大玩家数
`CUSTOM_FOLDER` | `custom_files` | 模拟服务器文件的文件夹，用于存储修改后的文件. 详见 [此处](#custom-files)
`RCON_PASSWORD` | `changeme` | RCON 登录密码，可用于在服务器内，或服务器外远程执行指令
`STEAM_ACCOUNT` | `` | 若要建立线上服务器, 你需要Steam [游戏登陆密钥](https://steamcommunity.com/dev/managegameservers). 这是使你的服务器能公开加入的必要条件。
`SERVER_PASSWORD` | `` | 可用于设置密码
`LAN` | `0` | 决定是否为本地服务器
`EXEC` | `on_boot.cfg` | 服务器启动时运行的配置文件. 若要切换模式, 建议在配置文件中增加延时，具体可参考示例 `on_boot.cfg` 文件
`DUCK_DOMAIN` | `` | (仅限Linux ) [Duck DNS](https://www.duckdns.org/) 的链接，适用于你想让你的服务器地址为一个特定域名的情况
`DUCK_TOKEN` | `` | (仅限Linux) [Duck DNS](https://www.duckdns.org/)上用于服务器启动的密钥

## 游玩创意工坊地图/合集

你需要API授权密钥以从创意工坊下载地图. API授权密钥可在 [此处](http://steamcommunity.com/dev/apikey)生成，将生成的密钥填入 `API_KEY` 环境变量中.

启动创意工坊地图的指令为 `host_workshop_map fileid` ，其中 `fileid` 为工坊地图链接中 `?id=`后的数字。 例如: [https://steamcommunity.com/sharedfiles/filedetails/?id=2433686680](https://steamcommunity.com/sharedfiles/filedetails/?id=2433686680)

启动创意工坊合集的指令为 `host_workshop_collection collectionid` ，其中`collectionid` 为工坊合集链接中 `?id=`后的数字。例如: [https://steamcommunity.com/sharedfiles/filedetails/?id=1092904694](https://steamcommunity.com/sharedfiles/filedetails/?id=1092904694). 该指令会下载合集中包含的所有地图，并在下载完成后启动。

## 针对不同模式设置地图

 参考 [自定义文件](#custom-files) 中的步骤 复制`/game/csgo/gamemodes_server.txt`(`/custom_files/gamemodes_server.txt`) 并在文件中为游戏模式地图池中添加地图. 多数模式会以休闲模式为基础运行, 但我为不同游戏模式都做了相应的地图池，而你只需要对地图池中的内容做修改即可.

此步骤不是必要的, 但你可以参考 [自定义文件](#custom-files) 中的步骤更新 `/game/csgo/subscribed_file_ids.txt`  (`/custom_files/subscribed_file_ids.txt`)中的（创意工坊id）以使服务器能自动更新地图.

## Google Cloud上运行

### 建立防火墙规则

```
gcloud compute firewall-rules create source \
--allow tcp:27015-27020,tcp:80,udp:27015-27020
```

### 建立进程

确保你已完成了 [环境变量](#environment-variables)的设置.

如果你的已有服务器无法承载, 可以考虑 [compute-optimized](https://cloud.google.com/compute/vm-instance-pricing#compute-optimized_machine_types) 中的机器 `c2-standard-4`.

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

### 利用SSH登录服务器

```
gcloud compute ssh <instance-name> \
--zone=australia-southeast1-c
```

### 安装mod

```
sudo su
cd / && curl --silent --output "gcp.sh" "https://raw.githubusercontent.com/kus/cs2-modded-server/master/gcp.sh" && chmod +x gcp.sh && bash gcp.sh
```

If the installation has paused for a long time, restart the server and do it again.

### 停止服务器

```
gcloud compute instances stop <instance-name> \
--zone australia-southeast1-c
```

### 启动服务器

```
gcloud compute instances start <instance-name> \
--zone australia-southeast1-c
```

### 删除服务器

```
gcloud compute instances delete <instance-name> \
--zone australia-southeast1-c
```

### 将文件从服务器推送到本地机器上

例如地图:

```
本地机器:
gcloud config set project <project>
cd /path/to/folder
gcloud compute scp de_kus.vpk root@<instance-name>:/home/steam/cs2/game/csgo/maps --zone australia-southeast1-c

服务器SSH:
cd /home/steam/cs2/game/csgo/maps
chown steam:steam de_kus.vpk
chmod 644 de_kus.vpk
```

### 从服务器上下载内容

`gcloud compute scp root@<instance-name>:/home/steam/cs2/gamecsgo/cfg/comp.cfg  ~/Desktop/`

### 设置每天3:30AM关闭VM（虚拟机）

利用SSH登录虚拟机

切换至根目录 `sudo su`

确认服务器的时区 `sudo hwclock --show`

打开crontab 文件 `nano /etc/crontab`

在crontab 文件末尾写入 `30 3    * * *   root    shutdown -h now`

保存 `CTRL + X`

## Linux上运行

请确保你有 **60GB及以上的可用磁盘空间**.

确保你已完成了 [环境变量](#environment-variables)的设置.

- **设置线上服务器:**

   将环境变量 `STEAM_ACCOUNT` 设为你的 [游戏登陆密钥](https://steamcommunity.com/dev/managegameservers)

   确认你的路由器已 [开放端口](https://portforward.com/router.htm) TCP: `27015` 和UDP: `27015` & `27020` 以使玩家可以通过服务器浏览器加入你的服务器.

   **若要连接服务器，你需要连接公开IP, 而非本地IP，即使在同一网络下也要如此. 脚本会以如下方式记录公开IP `Starting server on XXX.XXX.XXX.XXX:27015`**

- **设置本地服务器:**

   将环境变量 `LAN` 设为 `1`

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

- **首次运行时**

若要检查服务器是否正常运作，可在服务器控制台输入下列指令:

- `meta list` 会输出 `CounterStrikeSharp`
- `css_plugins list` 会输出一些已被启用的模组

如果两个输出都正常，代表服务器在正常运行.

在你加入服务器后，可以 [切换游戏模式](#changing-game-modes).

## Docker上运行

*仅在Windows 11 和WSL2 integration环境下测试*

确保Docker已正确安装，且有不少于40GB的可用磁盘空间。

你可以下载这个repo并解压到你想要解压到的位置上 (i.e. C:\Server\cs2-modded-server)或用git进行克隆 `git clone https://github.com/kus/cs2-modded-server.git` 并在克隆后的文件夹中运行. 此种方式允许你通过git pull指令获取更新.

- **设置线上服务器:**

   在根目录'.env'-file中设置环境变量'STEAM_ACCOUNT' 
   若要运行工坊地图，还需设置变量'API_KEY'。

- **建立docker镜像:**

   `docker build -t cs2-modded-server .`

- **启动服务器**

   `docker compose up`

## Windows上运行

确保你有 **60GB 及以上的磁盘可用空间**.

你可以 [下载这个repo](https://github.com/kus/cs2-modded-server/archive/master.zip) 并解压到你想要解压到的位置上 (i.e. `C:\Server\cs2-modded-server`) 或用git进行克隆 `git clone https://github.com/kus/cs2-modded-server.git` 并在克隆后的文件夹中运行. 此种方式允许你通过`git pull`指令获取更新.

后文中提到的文件路径均以你的服务器文件夹为根目录.

建立 `steamcmd` 文件夹然后[下载 SteamCMD](https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip) 并解压至 `steamcmd`文件夹中。现在服务器文件夹中应有`\steamcmd\steamcmd.exe`.

需要API授权密钥以从创意工坊下载地图. API授权密钥可在 [此处](http://steamcommunity.com/dev/apikey)生成，成功生成密钥后, 打开 `\win.ini` 并将 `cs_api_key` 设为你的 [Steam Web API密钥](http://steamcommunity.com/dev/apikey).

- **设置线上服务器:**

   打开 `\win.ini`

   将 `IP`设为 [公网IP](http://checkip.amazonaws.com/)

   将 `STEAM_ACCOUNT` 设为你的 [游戏服务器登录密钥](https://steamcommunity.com/dev/managegameservers)

   将 `API_KEY` 设为你的 [Steam Web API密钥](http://steamcommunity.com/dev/apikey) (required to play workshop maps)

   确认你的路由器已 [开放端口](https://portforward.com/router.htm) TCP: `27015` 和UDP: `27015` & `27020` 以使玩家可以通过服务器浏览器加入你的服务器.

   **若要连接服务器，你需要连接公开IP, 而非本地IP，即使在同一网络下也要如此. 脚本会以如下方式记录公开IP `Starting server on XXX.XXX.XXX.XXX:27015`**

- **设置本地服务器**

   打开 `\win.ini`

   将 `LAN` 设为 `1`

   将 `API_KEY` 设为 [Steam Web API key](http://steamcommunity.com/dev/apikey) (required to play workshop maps)

[添加管理员](#acessing-admin-menu)

启动 `win.bat`

如有提示，请允许服务器进程访问公共网络和专用网络。

- **首次运行时**

若要检查服务器是否正常运作，可在服务器控制台输入下列指令:

- `meta list` 会输出 `CounterStrikeSharp`
- `css_plugins list` 会输出一些已被启用的模组

如果两个输出都正常，代表服务器在正常运行.

在你加入服务器后，可以 [切换游戏模式](#changing-game-modes).

## FAQ

### 玩家命令

#### !rtv

玩家可通过发送 `!rtv` 启动地图轮换投票

<img alt="Vote to change map" src="https://github.com/kus/cs2-modded-server/blob/assets/assets/rtv.png?raw=true&sanitize=true">

#### !gamemode

玩家可通过发送 `!gamemode` 启动游戏模式轮换投票

<img alt="Vote to change game mode" src="https://github.com/kus/cs2-modded-server/blob/assets/assets/vote-gamemode.png?raw=true&sanitize=true">

玩家还可以通过输入下列指令来启动切换至某一特定游戏模式的投票： `!comp`, `!wingman`, `!dm`, `!gg`, `!1v1`, `!awp`, `!aim`, `!prefire`, `!executes`, `!retake`, `!prac`, `!bhop`, `!kz`, `!surf`, `!minigames`, `!deathrun`, `!course`, `!scoutzknivez`, `!hns`, `!soccer`, `!1.6`.

### 哪些地图已经被预先设置了呢?

#### mg_active

<table><tr><td><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_ancient.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_ancient<br><sup><sub>changelevel de_ancient</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_anubis.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_anubis<br><sup><sub>changelevel de_anubis</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_inferno.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_inferno<br><sup><sub>changelevel de_inferno</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_mirage.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_mirage<br><sup><sub>changelevel de_mirage</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_nuke.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_nuke<br><sup><sub>changelevel de_nuke</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_dust2.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_dust2<br><sup><sub>changelevel de_dust2</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_vertigo.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_vertigo<br><sup><sub>changelevel de_vertigo</sub></sup></td></tr></table></td></tr></table>

#### mg_comp

<table><tr><td><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/cs_italy.jpg?raw=true&sanitize=true"></td></tr><tr><td>cs_italy<br><sup><sub>changelevel cs_italy</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/cs_office.jpg?raw=true&sanitize=true"></td></tr><tr><td>cs_office<br><sup><sub>changelevel cs_office</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_vertigo.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_vertigo<br><sup><sub>changelevel de_vertigo</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_ancient.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_ancient<br><sup><sub>changelevel de_ancient</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_anubis.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_anubis<br><sup><sub>changelevel de_anubis</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_dust2.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_dust2<br><sup><sub>changelevel de_dust2</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_inferno.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_inferno<br><sup><sub>changelevel de_inferno</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_mirage.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_mirage<br><sup><sub>changelevel de_mirage</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_nuke.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_nuke<br><sup><sub>changelevel de_nuke</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_overpass.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_overpass<br><sup><sub>changelevel de_overpass</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_vertigo.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_vertigo<br><sup><sub>changelevel de_vertigo</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_assembly.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3071005299">de_assembly</a><br><sup><sub>host_workshop_map 3071005299</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_cbble.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070212801">de_cbble</a><br><sup><sub>host_workshop_map 3070212801</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_cache.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070244931">de_cache</a><br><sup><sub>host_workshop_map 3070244931</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_pipeline.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3079872050">de_pipeline</a><br><sup><sub>host_workshop_map 3079872050</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_biome.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3075706807">de_biome</a><br><sup><sub>host_workshop_map 3075706807</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/mp_raid.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070346180">mp_raid</a><br><sup><sub>host_workshop_map 3070346180</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_mutiny.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070766070">de_mutiny</a><br><sup><sub>host_workshop_map 3070766070</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/cs_assault.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070594412">cs_assault</a><br><sup><sub>host_workshop_map 3070594412</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_ruins_d_prefab.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3072352643">de_ruins_d_prefab</a><br><sup><sub>host_workshop_map 3072352643</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/cs_militia.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3089953774">cs_militia</a><br><sup><sub>host_workshop_map 3089953774</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_aztec.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070960099">de_aztec</a><br><sup><sub>host_workshop_map 3070960099</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_akiba.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3108513658">de_akiba</a><br><sup><sub>host_workshop_map 3108513658</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/cs_insertion2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3236615060">cs_insertion2</a><br><sup><sub>host_workshop_map 3236615060</sub></sup></td></tr></table></td></tr></table>

#### mg_wingman

<table><tr><td><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/cs_italy.jpg?raw=true&sanitize=true"></td></tr><tr><td>cs_italy<br><sup><sub>changelevel cs_italy</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/cs_office.jpg?raw=true&sanitize=true"></td></tr><tr><td>cs_office<br><sup><sub>changelevel cs_office</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_vertigo.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_vertigo<br><sup><sub>changelevel de_vertigo</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_ancient.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_ancient<br><sup><sub>changelevel de_ancient</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_anubis.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_anubis<br><sup><sub>changelevel de_anubis</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_dust2.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_dust2<br><sup><sub>changelevel de_dust2</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_inferno.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_inferno<br><sup><sub>changelevel de_inferno</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_mirage.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_mirage<br><sup><sub>changelevel de_mirage</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_nuke.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_nuke<br><sup><sub>changelevel de_nuke</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_overpass.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_overpass<br><sup><sub>changelevel de_overpass</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_vertigo.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_vertigo<br><sup><sub>changelevel de_vertigo</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/ar_shoots.jpg?raw=true&sanitize=true"></td></tr><tr><td>ar_shoots<br><sup><sub>changelevel ar_shoots</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/ar_baggage.jpg?raw=true&sanitize=true"></td></tr><tr><td>ar_baggage<br><sup><sub>changelevel ar_baggage</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/gd_rialto.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3085490518">gd_rialto</a><br><sup><sub>host_workshop_map 3085490518</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_safehouse.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070550406">de_safehouse</a><br><sup><sub>host_workshop_map 3070550406</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_lake.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070563536">de_lake</a><br><sup><sub>host_workshop_map 3070563536</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_bank.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070581293">de_bank</a><br><sup><sub>host_workshop_map 3070581293</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_shortdust.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070612859">de_shortdust</a><br><sup><sub>host_workshop_map 3070612859</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_assembly.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3071005299">de_assembly</a><br><sup><sub>host_workshop_map 3071005299</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_cbble.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070212801">de_cbble</a><br><sup><sub>host_workshop_map 3070212801</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_cache.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070244931">de_cache</a><br><sup><sub>host_workshop_map 3070244931</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_pipeline.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3079872050">de_pipeline</a><br><sup><sub>host_workshop_map 3079872050</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_biome.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3075706807">de_biome</a><br><sup><sub>host_workshop_map 3075706807</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/mp_raid.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070346180">mp_raid</a><br><sup><sub>host_workshop_map 3070346180</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_mutiny.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070766070">de_mutiny</a><br><sup><sub>host_workshop_map 3070766070</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/cs_assault.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070594412">cs_assault</a><br><sup><sub>host_workshop_map 3070594412</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_ruins_d_prefab.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3072352643">de_ruins_d_prefab</a><br><sup><sub>host_workshop_map 3072352643</sub></sup></td></tr></table></td></tr></table>

#### mg_dm

<table><tr><td><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/cs_italy.jpg?raw=true&sanitize=true"></td></tr><tr><td>cs_italy<br><sup><sub>changelevel cs_italy</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/cs_office.jpg?raw=true&sanitize=true"></td></tr><tr><td>cs_office<br><sup><sub>changelevel cs_office</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_vertigo.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_vertigo<br><sup><sub>changelevel de_vertigo</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_ancient.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_ancient<br><sup><sub>changelevel de_ancient</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_anubis.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_anubis<br><sup><sub>changelevel de_anubis</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_dust2.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_dust2<br><sup><sub>changelevel de_dust2</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_inferno.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_inferno<br><sup><sub>changelevel de_inferno</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_mirage.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_mirage<br><sup><sub>changelevel de_mirage</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_nuke.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_nuke<br><sup><sub>changelevel de_nuke</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_overpass.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_overpass<br><sup><sub>changelevel de_overpass</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_vertigo.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_vertigo<br><sup><sub>changelevel de_vertigo</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/ar_shoots.jpg?raw=true&sanitize=true"></td></tr><tr><td>ar_shoots<br><sup><sub>changelevel ar_shoots</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/ar_baggage.jpg?raw=true&sanitize=true"></td></tr><tr><td>ar_baggage<br><sup><sub>changelevel ar_baggage</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/gd_rialto.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3085490518">gd_rialto</a><br><sup><sub>host_workshop_map 3085490518</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_safehouse.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070550406">de_safehouse</a><br><sup><sub>host_workshop_map 3070550406</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_lake.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070563536">de_lake</a><br><sup><sub>host_workshop_map 3070563536</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_bank.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070581293">de_bank</a><br><sup><sub>host_workshop_map 3070581293</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_shortdust.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070612859">de_shortdust</a><br><sup><sub>host_workshop_map 3070612859</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/fy_pool_day.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070923343">fy_pool_day</a><br><sup><sub>host_workshop_map 3070923343</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/fy_iceworld.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070238628">fy_iceworld</a><br><sup><sub>host_workshop_map 3070238628</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/daymare.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3072640420">daymare</a><br><sup><sub>host_workshop_map 3072640420</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/aim_theorem.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070348309">aim_theorem</a><br><sup><sub>host_workshop_map 3070348309</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_assembly.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3071005299">de_assembly</a><br><sup><sub>host_workshop_map 3071005299</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_cbble.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070212801">de_cbble</a><br><sup><sub>host_workshop_map 3070212801</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_cache.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070244931">de_cache</a><br><sup><sub>host_workshop_map 3070244931</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_pipeline.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3079872050">de_pipeline</a><br><sup><sub>host_workshop_map 3079872050</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_biome.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3075706807">de_biome</a><br><sup><sub>host_workshop_map 3075706807</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/dm_desk.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3077599381">dm_desk</a><br><sup><sub>host_workshop_map 3077599381</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/fun_bounce.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3088183343">fun_bounce</a><br><sup><sub>host_workshop_map 3088183343</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/1v1aim_map_longdustversion_d.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3082605693">1v1aim_map_longdustversion_d</a><br><sup><sub>host_workshop_map 3082605693</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/ar_churches_s2r.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070291913">ar_churches_s2r</a><br><sup><sub>host_workshop_map 3070291913</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/mcdonalds.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3134466699">mcdonalds</a><br><sup><sub>host_workshop_map 3134466699</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/aim_ag_texture_city_advanced.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3082113929">aim_ag_texture_city_advanced</a><br><sup><sub>host_workshop_map 3082113929</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/traningoutside.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3080973179">traningoutside</a><br><sup><sub>host_workshop_map 3080973179</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/shipment_version_1_0.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3086555291">shipment_version_1_0</a><br><sup><sub>host_workshop_map 3086555291</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/aim_ag_texture2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3074961197">aim_ag_texture2</a><br><sup><sub>host_workshop_map 3074961197</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/aim_ag_texture_jungle.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3095778105">aim_ag_texture_jungle</a><br><sup><sub>host_workshop_map 3095778105</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/cs2_bloodstrike.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3071890065">cs2_bloodstrike</a><br><sup><sub>host_workshop_map 3071890065</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/gg_simpsons_vs_flanders_v2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3109232789">gg_simpsons_vs_flanders_v2</a><br><sup><sub>host_workshop_map 3109232789</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_akiba.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3108513658">de_akiba</a><br><sup><sub>host_workshop_map 3108513658</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/cs_facingworlds-99.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3112806723">cs_facingworlds-99</a><br><sup><sub>host_workshop_map 3112806723</sub></sup></td></tr></table></td></tr></table>

#### mg_gg

<table><tr><td><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/ar_shoots.jpg?raw=true&sanitize=true"></td></tr><tr><td>ar_shoots<br><sup><sub>changelevel ar_shoots</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/ar_baggage.jpg?raw=true&sanitize=true"></td></tr><tr><td>ar_baggage<br><sup><sub>changelevel ar_baggage</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/fy_pool_day.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070923343">fy_pool_day</a><br><sup><sub>host_workshop_map 3070923343</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/fy_iceworld.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070238628">fy_iceworld</a><br><sup><sub>host_workshop_map 3070238628</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/daymare.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3072640420">daymare</a><br><sup><sub>host_workshop_map 3072640420</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/mcdonalds.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3134466699">mcdonalds</a><br><sup><sub>host_workshop_map 3134466699</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/aim_theorem.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070348309">aim_theorem</a><br><sup><sub>host_workshop_map 3070348309</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_safehouse.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070550406">de_safehouse</a><br><sup><sub>host_workshop_map 3070550406</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_lake.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070563536">de_lake</a><br><sup><sub>host_workshop_map 3070563536</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_bank.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070581293">de_bank</a><br><sup><sub>host_workshop_map 3070581293</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/fun_bounce.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3088183343">fun_bounce</a><br><sup><sub>host_workshop_map 3088183343</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/1v1aim_map_longdustversion_d.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3082605693">1v1aim_map_longdustversion_d</a><br><sup><sub>host_workshop_map 3082605693</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/ar_churches_s2r.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070291913">ar_churches_s2r</a><br><sup><sub>host_workshop_map 3070291913</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/aim_ag_texture_city_advanced.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3082113929">aim_ag_texture_city_advanced</a><br><sup><sub>host_workshop_map 3082113929</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/traningoutside.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3080973179">traningoutside</a><br><sup><sub>host_workshop_map 3080973179</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/shipment_version_1_0.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3086555291">shipment_version_1_0</a><br><sup><sub>host_workshop_map 3086555291</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/aim_ag_texture2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3074961197">aim_ag_texture2</a><br><sup><sub>host_workshop_map 3074961197</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/aim_ag_texture_jungle.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3095778105">aim_ag_texture_jungle</a><br><sup><sub>host_workshop_map 3095778105</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/cs2_bloodstrike.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3071890065">cs2_bloodstrike</a><br><sup><sub>host_workshop_map 3071890065</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/gg_simpsons_vs_flanders_v2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3109232789">gg_simpsons_vs_flanders_v2</a><br><sup><sub>host_workshop_map 3109232789</sub></sup></td></tr></table></td></tr></table>

#### mg_1v1

<table><tr><td><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/aim_redline_fp.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070253400">aim_redline_fp</a><br><sup><sub>host_workshop_map 3070253400</sub></sup></td></tr></table></td></tr></table>

#### mg_bhop

<table><tr><td><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/bhop_at_night.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3077211069">bhop_at_night</a><br><sup><sub>host_workshop_map 3077211069</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/bhop_asiimov.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3076417347">bhop_asiimov</a><br><sup><sub>host_workshop_map 3076417347</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/bhop_ragnarok.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3077153735">bhop_ragnarok</a><br><sup><sub>host_workshop_map 3077153735</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/bhop_zunron.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3077475505">bhop_zunron</a><br><sup><sub>host_workshop_map 3077475505</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/bhop_1derland.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3077596014">bhop_1derland</a><br><sup><sub>host_workshop_map 3077596014</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/bhop_whiteshit.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3078523849">bhop_whiteshit</a><br><sup><sub>host_workshop_map 3078523849</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/bhop_cherryblossom.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3082038560">bhop_cherryblossom</a><br><sup><sub>host_workshop_map 3082038560</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/bhop_arcturus.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3088973190">bhop_arcturus</a><br><sup><sub>host_workshop_map 3088973190</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/bhop_kiwi_cwfx.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3095219437">bhop_kiwi_cwfx</a><br><sup><sub>host_workshop_map 3095219437</sub></sup></td></tr></table></td></tr></table>

#### mg_kz

<table><tr><td><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/only_up.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3074758439">only_up</a><br><sup><sub>host_workshop_map 3074758439</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/ewii_challenge.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3170668869">ewii_challenge</a><br><sup><sub>host_workshop_map 3170668869</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/kz_hub.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070220367">kz_hub</a><br><sup><sub>host_workshop_map 3070220367</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/hellcasecyrilchallenge.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3145779590">hellcasecyrilchallenge</a><br><sup><sub>host_workshop_map 3145779590</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/kz_checkmate.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070194623">kz_checkmate</a><br><sup><sub>host_workshop_map 3070194623</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/kz_victoria.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3086304337">kz_victoria</a><br><sup><sub>host_workshop_map 3086304337</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/kz_rc_stonehenge.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3072219045">kz_rc_stonehenge</a><br><sup><sub>host_workshop_map 3072219045</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/kz_sxb2_cxz.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3083714192">kz_sxb2_cxz</a><br><sup><sub>host_workshop_map 3083714192</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/kz_rc_twotowers.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3083509404">kz_rc_twotowers</a><br><sup><sub>host_workshop_map 3083509404</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/kz_simplyhard.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3078311932">kz_simplyhard</a><br><sup><sub>host_workshop_map 3078311932</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/kz_nomibo.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3077122656">kz_nomibo</a><br><sup><sub>host_workshop_map 3077122656</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/kz_sxb2_biewan.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3076000218">kz_sxb2_biewan</a><br><sup><sub>host_workshop_map 3076000218</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/kz_ggsh.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3072744536">kz_ggsh</a><br><sup><sub>host_workshop_map 3072744536</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/kz_ltt.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3072699538">kz_ltt</a><br><sup><sub>host_workshop_map 3072699538</sub></sup></td></tr></table></td></tr></table>

#### mg_surf

<table><tr><td><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/surf_kitsune.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3076153623">surf_kitsune</a><br><sup><sub>host_workshop_map 3076153623</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/surf_utopia_njv.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3073875025">surf_utopia_njv</a><br><sup><sub>host_workshop_map 3073875025</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/surf_beginner.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070321829">surf_beginner</a><br><sup><sub>host_workshop_map 3070321829</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/surf_mesa_revo.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3076980482">surf_mesa_revo</a><br><sup><sub>host_workshop_map 3076980482</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/surf_deathstar.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3080544577">surf_deathstar</a><br><sup><sub>host_workshop_map 3080544577</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/surf_rookie.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3082548297">surf_rookie</a><br><sup><sub>host_workshop_map 3082548297</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/surf_benevolent.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3098972556">surf_benevolent</a><br><sup><sub>host_workshop_map 3098972556</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/surf_ace.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3088413071">surf_ace</a><br><sup><sub>host_workshop_map 3088413071</sub></sup></td></tr></table></td></tr></table>

#### mg_minigames

<table><tr><td><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/mg_skeet_multigames_v7.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3082120895">mg_skeet_multigames_v7</a><br><sup><sub>host_workshop_map 3082120895</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/mg_lego_course_2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3202752274">mg_lego_course_2</a><br><sup><sub>host_workshop_map 3202752274</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/mg_warmcup_headshot.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3076765511">mg_warmcup_headshot</a><br><sup><sub>host_workshop_map 3076765511</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/minecraft.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3186779271">minecraft</a><br><sup><sub>host_workshop_map 3186779271</sub></sup></td></tr></table></td></tr></table>

#### mg_deathrun

<table><tr><td><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/deathrun_playground.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3164611860">deathrun_playground</a><br><sup><sub>host_workshop_map 3164611860</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/deathrun_civilization.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3188021118">deathrun_civilization</a><br><sup><sub>host_workshop_map 3188021118</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/deathrun_iceworld_cs2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3083325292">deathrun_iceworld_cs2</a><br><sup><sub>host_workshop_map 3083325292</sub></sup></td></tr></table></td></tr></table>

#### mg_course

<table><tr><td><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/cr_devisland_p1_v1.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3076483842">cr_devisland_p1_v1</a><br><sup><sub>host_workshop_map 3076483842</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/mg_switch_course_v2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070439729">mg_switch_course_v2</a><br><sup><sub>host_workshop_map 3070439729</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/cr_minecraft_jb_v2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070896876">cr_minecraft_jb_v2</a><br><sup><sub>host_workshop_map 3070896876</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/mg_metro_course_v1.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070463151">mg_metro_course_v1</a><br><sup><sub>host_workshop_map 3070463151</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/mg_alley_course_v2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070455802">mg_alley_course_v2</a><br><sup><sub>host_workshop_map 3070455802</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/mg_glave_course_v2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070445185">mg_glave_course_v2</a><br><sup><sub>host_workshop_map 3070445185</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/mg_office_course_v3.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070459211">mg_office_course_v3</a><br><sup><sub>host_workshop_map 3070459211</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/mg_metal_course_v2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070464208">mg_metal_course_v2</a><br><sup><sub>host_workshop_map 3070464208</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/mg_acrophobia_run_v2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070463620">mg_acrophobia_run_v2</a><br><sup><sub>host_workshop_map 3070463620</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/mg_metro_course_s2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3071040020">mg_metro_course_s2</a><br><sup><sub>host_workshop_map 3071040020</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/mg_circle_course_v3.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070434475">mg_circle_course_v3</a><br><sup><sub>host_workshop_map 3070434475</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/mg_simpsons_course_v2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070447697">mg_simpsons_course_v2</a><br><sup><sub>host_workshop_map 3070447697</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/mg_sonic_course_v2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070452642">mg_sonic_course_v2</a><br><sup><sub>host_workshop_map 3070452642</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/mg_sky_realm_v3.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070451616">mg_sky_realm_v3</a><br><sup><sub>host_workshop_map 3070451616</sub></sup></td></tr></table></td></tr></table>

#### mg_scoutzknivez

<table><tr><td><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/scoutzknivez_pure_cs2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3073929825">scoutzknivez_pure_cs2</a><br><sup><sub>host_workshop_map 3073929825</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/ar_dizzy.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070553020">ar_dizzy</a><br><sup><sub>host_workshop_map 3070553020</sub></sup></td></tr></table></td></tr></table>

#### mg_hns

<table><tr><td><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/infernohideandseek.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3097563690">infernohideandseek</a><br><sup><sub>host_workshop_map 3097563690</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/seek_town_bs.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3074479691">seek_town_bs</a><br><sup><sub>host_workshop_map 3074479691</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/winterday_bs.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070951079">winterday_bs</a><br><sup><sub>host_workshop_map 3070951079</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/minus_denhet.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070541369">minus_denhet</a><br><sup><sub>host_workshop_map 3070541369</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/hs_lake.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3071094345">hs_lake</a><br><sup><sub>host_workshop_map 3071094345</sub></sup></td></tr></table></td></tr></table>

#### mg_soccer

<table><tr><td><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/ka_soccer_2009.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070198374">ka_soccer_2009</a><br><sup><sub>host_workshop_map 3070198374</sub></sup></td></tr></table></td></tr></table>

#### mg_awp

<table><tr><td><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/awp_bhop_rocket.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3142070597">awp_bhop_rocket</a><br><sup><sub>host_workshop_map 3142070597</sub></sup></td></tr></table></td></tr></table>

#### mg_aim

<table><tr><td><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/aim_map.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3084291314">aim_map</a><br><sup><sub>host_workshop_map 3084291314</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/freebet_aim_map.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3146122036">freebet_aim_map</a><br><sup><sub>host_workshop_map 3146122036</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/fy_pool_day.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3070923343">fy_pool_day</a><br><sup><sub>host_workshop_map 3070923343</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/aim_ak-colt_CS2.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3078701726">aim_ak-colt_CS2</a><br><sup><sub>host_workshop_map 3078701726</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/aim_usp.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3085962528">aim_usp</a><br><sup><sub>host_workshop_map 3085962528</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/aim_deagle.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3075996446">aim_deagle</a><br><sup><sub>host_workshop_map 3075996446</sub></sup></td></tr></table></td></tr></table>

#### mg_prefire

<table><tr><td><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_ancient.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_ancient<br><sup><sub>changelevel de_ancient</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_dust2.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_dust2<br><sup><sub>changelevel de_dust2</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_inferno.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_inferno<br><sup><sub>changelevel de_inferno</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_mirage.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_mirage<br><sup><sub>changelevel de_mirage</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_overpass.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_overpass<br><sup><sub>changelevel de_overpass</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_anubis.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_anubis<br><sup><sub>changelevel de_anubis</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_nuke.jpg?raw=true&sanitize=true"></td></tr><tr><td>de_nuke<br><sup><sub>changelevel de_nuke</sub></sup></td></tr></table></td></tr></table>

#### mg_Casual16

<table><tr><td><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/as_oilrig.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3104677430">as_oilrig</a><br><sup><sub>host_workshop_map 3104677430</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/cs_assult_classic.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3215705579">cs_assult_classic</a><br><sup><sub>host_workshop_map 3215705579</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_aztec_classic.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3213800338">de_aztec_classic</a><br><sup><sub>host_workshop_map 3213800338</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_dust_classic.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3078095785">de_dust_classic</a><br><sup><sub>host_workshop_map 3078095785</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_dust2_classic.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3201205818">de_dust2_classic</a><br><sup><sub>host_workshop_map 3201205818</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/cs_italy_classic.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3212419403">cs_italy_classic</a><br><sup><sub>host_workshop_map 3212419403</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/cs_militia_classic.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3144773563">cs_militia_classic</a><br><sup><sub>host_workshop_map 3144773563</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_nuke_classic.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3205793205">de_nuke_classic</a><br><sup><sub>host_workshop_map 3205793205</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/cs_office_classic.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3216844784">cs_office_classic</a><br><sup><sub>host_workshop_map 3216844784</sub></sup></td></tr></table><table align="left"><tr><td><img height="112" src="https://github.com/kus/cs2-modded-server/blob/assets/images/de_survivor_classic_m.jpg?raw=true&sanitize=true"></td></tr><tr><td><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3217247541">de_survivor_classic_m</a><br><sup><sub>host_workshop_map 3217247541</sub></sup></td></tr></table></td></tr></table>

### 我要如何远程连接RCON?

为你的系统[下载 SourceAdminTool](https://nightly.link/Drifter321/admintool/workflows/build/master) ([源代码](https://github.com/Drifter321/admintool)) (详情 [见此](https://forums.alliedmods.net/showthread.php?t=289370)) 
点击 `Servers > Add Servers` 然后输入 `<IP>:27015` 。当你看到服务器出现在列表中后, 在左下角输入你的RCON密码然后点击 `Login`至此，你就可以正常在下方输入框中输入指令了。 i.e. `exec dm.cfg`

**若要连接服务器，你需要连接公开IP, 而非本地IP，即使在同一网络下也要如此. 脚本会以如下方式记录公开IP `Starting server on XXX.XXX.XXX.XXX:27015`**

### 访问管理员菜单

管理员设置由[CounterStrikeSharp](https://github.com/roflmuffin/CounterStrikeSharp)使用[Admin Framework](https://docs.cssharp.dev/admin-framework/defining-admins/)插件管理. 你可以在其配置文件中设置管理员及他们的权限标识。
若想查看例子，可查看 [/custom_files_example/addons/counterstrikesharp/configs/admins.json](https://github.com/kus/cs2-modded-server/blob/master/custom_files_example/addons/counterstrikesharp/configs/admins.json). 仿照这些例子并利用 [自定义文件](#custom-files) 系统来自行修改.

### 使用数字键控制菜单，省区输入!1的时间

如果你实在嫌天天打！1太麻烦，可参照下面的控制台指令绑定按键。设置后，按下数字1键就相当于输出了指令！1:

_提醒: 下列设置为标准预设.你可以根据自身需要自行调整._

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

### 切换地图

<img alt="Admin change map menu" src="https://github.com/kus/cs2-modded-server/blob/assets/assets/admin-maps.png?raw=true&sanitize=true">

管理员可在聊天栏输入 `!maps` 以直接更换适用当前运行游戏模式的地图. 所有由管理员发出的换图指令会立刻执行，无需等到回合结束.

当轮结束时 (时间用尽/任意一方达成胜利条件) 会推送一次投票，以更换至适用于当前模式的地图.

### 更换游戏模式

<img alt="Admin change game mode menu" src="https://github.com/kus/cs2-modded-server/blob/assets/assets/admin-modes.png?raw=true&sanitize=true">

管理员可在聊天栏输入 `!modes` 以更换游戏模式. 所有由管理员发出的游戏模式更换指令会立刻执行，无需等到回合结束.更换游戏模式会启动目标模式的初始地图。

`!maps` 中所呈现的地图列表也会随模式的更换而更换。

你也可以直接在聊天框执行RCOM指令以更换模式 i.e. `!rcon exec dm` will change to deathmatch.

下为各个游戏模式所对应的rcon指令:

| Command                   | Game mode                                                                         |
| ------------------------- | --------------------------------------------------------------------------------- |
| `!rcon exec 1v1`          | 1v1 (allows more than 2 players)                                                  |
| `!rcon exec aim`          | Aim  //瞄准练习                                                                             |
| `!rcon exec ar`           | Arms Race //军备竞赛                                                                        |
| `!rcon exec awp`          | Awp only //仅AWP                                                                         |
| `!rcon exec bhop`         | Bunny hop maps//兔子跳                                                                    |
| `!rcon exec comp`         | Competitive//竞技模式 (利用 [MatchZy](https://github.com/shobhit-pathak/MatchZy#usage-commands)) |
| `!rcon exec course`       | Course format//闯关                               |
| `!rcon exec dm`           | Deathmatch//死斗/死亡竞赛                                                                        |
| `!rcon exec dm-multicfg`  | Deathmatch Multi Config 死斗变化版                                                          |
| `!rcon exec executes`     | Executes//处决                                                                          |
| `!rcon exec gg`           | GunGame//军备竞赛                                                                          |
| `!rcon exec hns`          | Hide n Seek//躲猫猫                                                                       |
| `!rcon exec kz`           | Kreedz Climbing                                                                   |
| `!rcon exec minigames`    | Mini Games //小游戏                                                                        |
| `!rcon exec deathrun`     | Deathrun //死亡跑酷                                                                          |
| `!rcon exec prac`         | Practice//练习 (例如练习扔雷)                                                    |
| `!rcon exec prefire`      | Prefire practice//提前枪练习                                                                  |
| `!rcon exec retake`       | Retake//回防                                                                           |
| `!rcon exec scoutzknivez` | ScoutzKnivez                                                                      |
| `!rcon exec soccer`       | Soccer//足球                                                                            |
| `!rcon exec surf`         | Surf//滑行                                                                              |
| `!rcon exec wingman`      | Wingman //飞狙(允许4人及以上)                                              |

不建议频繁多次切换模式, 切换模式期间建议重启服务器.

若要获取更多插件相关命令，请移步插件列表中的原链接.

### RCON 无法正常运行

连接服务器时，无法使用RCON.原因[见此](https://www.reddit.com/r/GlobalOffensive/comments/167spzi/cs2_rcon/).
替代方案如下:

- 模组中包含 [CS2Rcon](https://github.com/LordFetznschaedl/CS2Rcon) ，管理员可在聊天框里输入!rcon以使用相关功能.
- 离开服务器，然后在服务器控制台中输入 `rcon_address IP:PORT`即可使用rcon命令.
- 使用外置RCON软件，例如 [这个](https://github.com/fpaezf/CS2-RCON-Tool-V2).

若仍无法使用，请尝试在主菜单中，使用控制台加入服务器:

**若要连接服务器，你需要连接公开IP, 而非本地IP，即使在同一网络下也要如此. 脚本会以如下方式记录公开IP `Starting server on XXX.XXX.XXX.XXX:27015`**

```bash
rcon_address ip:port
rcon_password "password"
rcon say "hi"
```

同时检查端口是否被其他进程占用 i.e. Ubuntu `sudo lsof -i -P -n | head -n 1; sudo lsof -i -P -n | grep cs2`.

### 如何添加bots?

默认状态下，下列模式中启用bot: deathmatch, gungame, gungame ffa, retakes, scoutsknives and wingman.

初始设定为当服务器内有1个人类玩家时会添加一个bot, 当玩家数大于等于2时就不再添加bot.

你可以利用"[自定义文件](#custom-files)"系统调整 [custom_bots.cfg](https://github.com/kus/cs2-modded-server/blob/master/game/csgo/cfg/custom_bots.cfg).

将 [custom_bots.cfg](https://github.com/kus/cs2-modded-server/blob/master/game/csgo/cfg/custom_bots.cfg) 放入 `custom_files/cfg/` 文件夹 (Linux上的默认路径为：`/home/steam/cs2/custom_files/cfg/` ) 然后你可以在其中进行修改，例如将 `bot_quota` 设为 `10` 可使服务器内始终包含BOTS在内的10个玩家. 服务器启动后 (on Linux and Windows) 该文件便会整合进一些文件并同 `bots.cfg` 一并执行.

你也可以登录RCON `rcon_password yourpassword` 然后使用 `rcon bot_add_ct` 和 `rcon bot_add_t`命令.

若要移除bots可用`rcon bot_kick`.

### 为什么我无法在装载mod的情况下直接启动服务器？

因为服务器在启动前就加载mod.  在SourceMod装载前你无法使用`+exec` 指令来执行mod的配置. 你可以在服务器启动后 (通过RCON) 监测然后装载mod i.e. `exec dm.cfg`.

### 手动更新 Metamod:Source 和 CounterStrikeSharp

如果你使用的是以 unix 为基础的系统,你可以通过执行 `scripts/check-updates.sh` 来检查当前安装的版本与最新版本间的差距, 这有利于简化更新的流程.

前往 [Metamod:Source](http://www.sourcemm.net/downloads.php?branch=master) and [CounterStrikeSharp](https://github.com/roflmuffin/CounterStrikeSharp) 的Release页面并下载最新版本. 你需要手动将压缩包中的 `addons` 与服务器文件的 `/game/csgo/addons` 进行整合. 在unix 为基础的系统上可利用 rsync进行:

打开控制台， `cd` 到文件解压缩的位置 i.e.: `cd ~/Downloads` 修改指令中的文件夹位置为服务器文件位置后运行:

`rsync -rhavz --exclude "._*" --exclude ".DS_Store" --partial --progress --stats ./addons/ /Users/kus/dev/personal/counter-strike/cs2-modded-server/game/csgo/addons/`

在Windows, 将 [CounterStrikeSharp](https://github.com/roflmuffin/CounterStrikeSharp/releases) 压缩包中的 `api`,`bin`, `dotnet` 文件夹到服务器文件的`game/csgo/addons/windows/counterstrikesharp` .

### 启用广告推送

若要将该插件加入白名单并在服务器启动时运行，将 `css_plugins load "plugins/disabled/Advertisement/Advertisement.dll"`放入其中一个你自己的`.cfg` 配置文件中.

若要使其在所有mod模式中都启用, 可将其填入 `/custom_files/cfg/custom_all.cfg` 文件中.

文件位于 `/game/csgo/addons/counterstrikesharp/plugins/disabled/Advertisement/advertisement.json` ，修改后将文件复制到 `/custom_files/addons/counterstrikesharp/plugins/disabled/Advertisement/advertisement.json` 以保证其不会被覆盖.

### 启用白名单功能

若要将该插件加入白名单并在服务器启动时运行，将 `css_plugins load "plugins/disabled/WhiteList/WhiteList.dll"` 放入其中一个你自己的 `.cfg` 配置文件中.

若要使其在所有mod模式中都启用, 可将其填入 `/custom_files/cfg/custom_all.cfg` 文件中.

白名单文件位于 `/game/csgo/addons/counterstrikesharp/plugins/disabled/WhiteList/whitelist.txt`
建议将其放入 `/custom_files/addons/counterstrikesharp/plugins/disabled/WhiteList/whitelist.txt` 以保证其不会被覆盖.

### Failed to open libtier0.so 错误

`Failed to open libtier0.so (/home/steam/cs2/bin/libgcc_s.so.1: version 'GCC_7.0.0' not found (required by /lib/i386-linux-gnu/libstdc++.so.6))`

这是应为Valve将其同游戏文件一同安装了进来。 由于目前该文件已有适配新系统的更新版本, 你可以安全的删除这些文件. 切记不要删除system文件夹内的文件 (通常有 lib 或 lib32)[*](https://wiki.alliedmods.net/Installing_metamod:source).

执行`cd /home/steam/cs2/bin/` 和 `rm libgcc_s.so.1` 命令后重启服务器。

## 版权相关

详见 `LICENSE` 。
