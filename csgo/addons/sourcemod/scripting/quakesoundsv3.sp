#include <sourcemod>
#include <sdktools>
#include <clientprefs>

#define PLUGIN_NAME			"Quake Sounds v3"
#define PLUGIN_AUTHOR		"Spartan_C001"
#define PLUGIN_DESCRIPTION	"Plays sounds based on events that happen in game."
#define PLUGIN_VERSION		"3.5.0"
#define PLUGIN_URL			"http://steamcommunity.com/id/spartan_c001/"

public Plugin:myinfo={name=PLUGIN_NAME,author=PLUGIN_AUTHOR,description=PLUGIN_DESCRIPTION,version=PLUGIN_VERSION,url=PLUGIN_URL}

// Sound Sets
#define MAX_NUM_SETS 5
new numSets = 0
new String:setsName[MAX_NUM_SETS][PLATFORM_MAX_PATH]

// Max Kill Streak/Combo Config Setting
#define MAX_NUM_KILLS 50

// Sound Files
new String:headshotSound	[MAX_NUM_SETS][MAX_NUM_KILLS][PLATFORM_MAX_PATH]
new String:grenadeSound		[MAX_NUM_SETS][PLATFORM_MAX_PATH]
new String:selfkillSound	[MAX_NUM_SETS][PLATFORM_MAX_PATH]
new String:roundplaySound	[MAX_NUM_SETS][PLATFORM_MAX_PATH]
new String:knifeSound		[MAX_NUM_SETS][PLATFORM_MAX_PATH]
new String:killSound		[MAX_NUM_SETS][MAX_NUM_KILLS][PLATFORM_MAX_PATH]
new String:firstbloodSound	[MAX_NUM_SETS][PLATFORM_MAX_PATH]
new String:teamkillSound	[MAX_NUM_SETS][PLATFORM_MAX_PATH]
new String:comboSound		[MAX_NUM_SETS][MAX_NUM_KILLS][PLATFORM_MAX_PATH]
new String:joinSound		[MAX_NUM_SETS][PLATFORM_MAX_PATH]

// Sound Configs
new headshotConfig		[MAX_NUM_SETS][MAX_NUM_KILLS]
new grenadeConfig		[MAX_NUM_SETS]
new selfkillConfig		[MAX_NUM_SETS]
new roundplayConfig		[MAX_NUM_SETS]
new knifeConfig			[MAX_NUM_SETS]
new killConfig			[MAX_NUM_SETS][MAX_NUM_KILLS]
new firstbloodConfig	[MAX_NUM_SETS]
new teamkillConfig		[MAX_NUM_SETS]
new comboConfig			[MAX_NUM_SETS][MAX_NUM_KILLS]
new joinConfig			[MAX_NUM_SETS]

// Kill Streaks
new totalKills = 0
new consecutiveKills[MAXPLAYERS+1]
new Float:lastKillTime[MAXPLAYERS+1]
new comboScore[MAXPLAYERS+1]
new consecutiveHeadshots[MAXPLAYERS+1]

// Preferences
new Handle:cookieTextPref
new textPreference[MAXPLAYERS+1]
new Handle:cookieSoundPref
new soundPreference[MAXPLAYERS+1]

// Engine Version for game specific checks / features
new EngineVersion:gameEngine

// Fix any shiz if plugin was loaded late for some reason
new bool:lateLoaded = false

// Checks if plugin was late or normal
public APLRes:AskPluginLoad2(Handle:myself,bool:late,String:error[],err_max)
{
	lateLoaded = late
	gameEngine = GetEngineVersion()
	return APLRes_Success
}

// Stuff to do when plugin is loaded
public OnPluginStart()
{
	LoadTranslations("plugin.quakesounds")
	CreateConVar("sm_quakesoundsv3_version",PLUGIN_VERSION,"Version of currently loaded Quake Sounds v3 plugin.",FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD)
	CreateConVar("sm_quakesoundsv3_announce","1","Sets whether to announcement to clients as they join, 0=Disabled, 1=Enabled.",FCVAR_NONE,true,0.0,true,1.0)
	CreateConVar("sm_quakesoundsv3_text","1","Default text display setting for new users, 0=Disabled, 1=Enabled.",FCVAR_NONE,true,0.0,true,1.0)
	CreateConVar("sm_quakesoundsv3_sound","1","Default sound set for new users, 0=Disabled, 1=Standard, 2=Female.",FCVAR_NONE,true,0.0)
	CreateConVar("sm_quakesoundsv3_volume","1.0","Sound Volume: should be a number between 0.0 and 1.0.",FCVAR_NONE,true,0.0,true,1.0)
	CreateConVar("sm_quakesoundsv3_teamkill_mode","0","Teamkiller Mode; 0=Normal, 1=Team-Kills count as normal kills.",FCVAR_NONE,true,0.0,true,1.0)
	CreateConVar("sm_quakesoundsv3_combo_time","2.0","Max time in seconds between kills to count as combo; 0.0=Minimum, 2.0=Default",FCVAR_NONE,true,0.0)
	AutoExecConfig(true,"plugin.quakesounds")
	RegConsoleCmd("sm_quake",CMD_ShowQuakePrefsMenu)
	HookGameEvents()
	cookieTextPref = RegClientCookie("Quake Text Pref","Text setting",CookieAccess_Private)
	cookieSoundPref = RegClientCookie("Quake Sound Pref","Sound setting",CookieAccess_Private)
	SetCookieMenuItem(QuakePrefSelected,0,"Quake Sound Prefs")
	if(lateLoaded)
	{
		LateLoadedInitialization()
	}
}

// Extra stuff to do if plugin was loaded late
public LateLoadedInitialization()
{
	NewRoundInitialization()
	for(new i = 1; i <= GetMaxHumanPlayers(); i++) 
	{
		if(IsClientInGame(i) && !IsFakeClient(i))
		{
			soundPreference[i] = GetConVarInt(FindConVar("sm_quakesoundsv3_sound")) -1
			textPreference[i] = GetConVarInt(FindConVar("sm_quakesoundsv3_announce"))	
			if(AreClientCookiesCached(i))
			{
				LoadClientCookiesFor(i)
			}
		}
		else
		{
			soundPreference[i] = -1
			textPreference[i] = 0
		}
	}
}

// If Quake Prefs Menu was selected from the clientprefs menyu (!settings)
public QuakePrefSelected(client,CookieMenuAction:action,any:info,String:buffer[],maxlen)
{
	if(action == CookieMenuAction_SelectOption)
	{
		ShowQuakeMenu(client)
	}
}

// Hooks correct game events
public HookGameEvents()
{
	HookEvent("player_death",EventPlayerDeath)
	switch(gameEngine)
	{
		case Engine_CSS,Engine_CSGO:
		{
			HookEvent("round_start",EventRoundStart,EventHookMode_PostNoCopy)
			HookEvent("round_freeze_end",EventRoundFreezeEnd,EventHookMode_PostNoCopy)
		}
		case Engine_DODS:
		{
			HookEvent("dod_round_start",EventRoundStart,EventHookMode_PostNoCopy)
			HookEvent("dod_round_active",EventRoundFreezeEnd,EventHookMode_PostNoCopy)
		}
		case Engine_TF2:
		{
			HookEvent("teamplay_round_start",EventRoundStart,EventHookMode_PostNoCopy)
			HookEvent("teamplay_round_active",EventRoundFreezeEnd,EventHookMode_PostNoCopy)
			HookEvent("arena_round_start",EventRoundFreezeEnd,EventHookMode_PostNoCopy)
		}
		case Engine_HL2DM:
		{
			HookEvent("teamplay_round_start",EventRoundStart,EventHookMode_PostNoCopy)
		}
		default:
		{
			HookEvent("round_start",EventRoundStart,EventHookMode_PostNoCopy)
		}
	}
}

// Loads QuakeSetsList config to check for sound sets
public LoadSoundSets()
{
	new String:bufferString[PLATFORM_MAX_PATH]
	new Handle:SoundSetsKV = CreateKeyValues("SetsList")
	BuildPath(Path_SM,bufferString,PLATFORM_MAX_PATH,"configs/QuakeSetsList.cfg")
	if(FileToKeyValues(SoundSetsKV,bufferString))
	{
		if(KvJumpToKey(SoundSetsKV,"sound sets"))
		{
			numSets = 0
			for(new i = 0; i < MAX_NUM_SETS; i++)
			{
				Format(bufferString,PLATFORM_MAX_PATH,"sound set %i",(i+1))
				KvGetString(SoundSetsKV,bufferString,setsName[i],PLATFORM_MAX_PATH)
				if(!StrEqual(setsName[i],""))
				{
					BuildPath(Path_SM,bufferString,PLATFORM_MAX_PATH,"configs/quake/%s.cfg",setsName[i])
					PrintToServer("[SM] Quake Sounds v3: Loading sound set config '%s'.",bufferString)
					LoadSet(bufferString,i)
					numSets++
				}
			}
		}
		else
		{
			CloseHandle(SoundSetsKV)
			SetFailState("configs/QuakeSetsList.cfg not correctly structured")
		}
	}
	else
	{
		CloseHandle(SoundSetsKV)
		SetFailState("configs/QuakeSetsList.cfg not found")
	}
	CloseHandle(SoundSetsKV)
}

// Loads sound file paths and configs for each sound set
public LoadSet(String:setFile[],setNum)
{
	new String:bufferString[PLATFORM_MAX_PATH]
	new Handle:SetFileKV = CreateKeyValues("SoundSet")
	if(FileToKeyValues(SetFileKV,setFile))
	{
		if(KvJumpToKey(SetFileKV,"headshot"))
		{
			if(KvGotoFirstSubKey(SetFileKV))
			{
				do
				{
					KvGetSectionName(SetFileKV,bufferString,PLATFORM_MAX_PATH)
					new killNum = StringToInt(bufferString)
					if(killNum >= 0)
					{
						KvGetString(SetFileKV,"sound",headshotSound[setNum][killNum],PLATFORM_MAX_PATH)
						headshotConfig[setNum][killNum] = KvGetNum(SetFileKV,"config",9)
						Format(bufferString,PLATFORM_MAX_PATH,"sound/%s",headshotSound[setNum][killNum])
						if(FileExists(bufferString,true))
						{
							PrecacheSoundCustom(headshotSound[setNum][killNum],PLATFORM_MAX_PATH)
							AddFileToDownloadsTable(bufferString)
						}
						else
						{
							headshotConfig[setNum][killNum] = 0
							PrintToServer("[SM] Quake Sounds v3: File specified in 'headshot %i' does not exist in '%s', ignoring.",killNum,setFile)
						}
					}
				} while (KvGotoNextKey(SetFileKV))
				KvGoBack(SetFileKV)
			}
			else
			{
				PrintToServer("[SM] Quake Sounds v3: 'headshot' section not configured correctly in %s.",setFile)
			}
		}
		else
		{
			PrintToServer("[SM] Quake Sounds v3: 'headshot' section missing in %s.",setFile)
		}
		KvRewind(SetFileKV)
		if(KvJumpToKey(SetFileKV,"grenade"))
		{
			if(KvGotoFirstSubKey(SetFileKV))
			{
				PrintToServer("[SM] Quake Sounds v3: 'grenade' section not configured correctly in %s.",setFile)
				KvGoBack(SetFileKV)
			}
			else
			{
				KvGetString(SetFileKV,"sound",grenadeSound[setNum],PLATFORM_MAX_PATH)
				grenadeConfig[setNum] = KvGetNum(SetFileKV,"config",9)
				Format(bufferString,PLATFORM_MAX_PATH,"sound/%s",grenadeSound[setNum])
				if(FileExists(bufferString,true))
				{
					PrecacheSoundCustom(grenadeSound[setNum],PLATFORM_MAX_PATH)
					AddFileToDownloadsTable(bufferString)
				}
				else
				{
					grenadeConfig[setNum] = 0
					PrintToServer("[SM] Quake Sounds v3: File specified in 'grenade' does not exist in '%s', ignoring.",setFile)
				}
			}
		}
		else
		{
			PrintToServer("[SM] Quake Sounds v3: 'grenade' section missing in %s.",setFile)
		}
		KvRewind(SetFileKV)
		if(KvJumpToKey(SetFileKV,"selfkill"))
		{
			if(KvGotoFirstSubKey(SetFileKV))
			{
				PrintToServer("[SM] Quake Sounds v3: 'selfkill' section not configured correctly in %s.",setFile)
				KvGoBack(SetFileKV)
			}
			else
			{
				KvGetString(SetFileKV,"sound",selfkillSound[setNum],PLATFORM_MAX_PATH)
				selfkillConfig[setNum] = KvGetNum(SetFileKV,"config",9)
				Format(bufferString,PLATFORM_MAX_PATH,"sound/%s",selfkillSound[setNum])
				if(FileExists(bufferString,true))
				{
					PrecacheSoundCustom(selfkillSound[setNum],PLATFORM_MAX_PATH)
					AddFileToDownloadsTable(bufferString)
				}
				else
				{
					selfkillConfig[setNum] = 0
					PrintToServer("[SM] Quake Sounds v3: File specified in 'selfkill' does not exist in '%s', ignoring.",setFile)
				}
			}
		}
		else
		{
			PrintToServer("[SM] Quake Sounds v3: 'selfkill' section missing in %s.",setFile)
		}
		KvRewind(SetFileKV)
		if(KvJumpToKey(SetFileKV,"round play"))
		{
			if(KvGotoFirstSubKey(SetFileKV))
			{
				PrintToServer("[SM] Quake Sounds v3: 'round play' section not configured correctly in %s.",setFile)
				KvGoBack(SetFileKV)
			}
			else
			{
				KvGetString(SetFileKV,"sound",roundplaySound[setNum],PLATFORM_MAX_PATH)
				roundplayConfig[setNum] = KvGetNum(SetFileKV,"config",9)
				Format(bufferString,PLATFORM_MAX_PATH,"sound/%s",roundplaySound[setNum])
				if(FileExists(bufferString,true))
				{
					PrecacheSoundCustom(roundplaySound[setNum],PLATFORM_MAX_PATH)
					AddFileToDownloadsTable(bufferString)
				}
				else
				{
					roundplayConfig[setNum] = 0
					PrintToServer("[SM] Quake Sounds v3: File specified in 'round play' does not exist in '%s', ignoring.",setFile)
				}
			}
		}
		else
		{
			PrintToServer("[SM] Quake Sounds v3: 'round play' section missing in %s.",setFile)
		}
		KvRewind(SetFileKV)
		if(KvJumpToKey(SetFileKV,"knife"))
		{
			if(KvGotoFirstSubKey(SetFileKV))
			{
				PrintToServer("[SM] Quake Sounds v3: 'knife' section not configured correctly in %s.",setFile)
				KvGoBack(SetFileKV)
			}
			else
			{
				KvGetString(SetFileKV,"sound",knifeSound[setNum],PLATFORM_MAX_PATH)
				knifeConfig[setNum] = KvGetNum(SetFileKV,"config",9)
				Format(bufferString,PLATFORM_MAX_PATH,"sound/%s",knifeSound[setNum])
				if(FileExists(bufferString,true))
				{
					PrecacheSoundCustom(knifeSound[setNum],PLATFORM_MAX_PATH)
					AddFileToDownloadsTable(bufferString)
				}
				else
				{
					knifeConfig[setNum] = 0
					PrintToServer("[SM] Quake Sounds v3: File specified in 'knife' does not exist in '%s', ignoring.",setFile)
				}
			}
		}
		else
		{
			PrintToServer("[SM] Quake Sounds v3: 'knife' section missing in %s.",setFile)
		}
		KvRewind(SetFileKV)
		if(KvJumpToKey(SetFileKV,"killsound"))
		{
			if(KvGotoFirstSubKey(SetFileKV))
			{
				do
				{
					KvGetSectionName(SetFileKV,bufferString,PLATFORM_MAX_PATH)
					new killNum = StringToInt(bufferString)
					if(killNum >= 0)
					{
						KvGetString(SetFileKV,"sound",killSound[setNum][killNum],PLATFORM_MAX_PATH)
						killConfig[setNum][killNum] = KvGetNum(SetFileKV,"config",9)
						Format(bufferString,PLATFORM_MAX_PATH,"sound/%s",killSound[setNum][killNum])
						if(FileExists(bufferString,true))
						{
							PrecacheSoundCustom(killSound[setNum][killNum],PLATFORM_MAX_PATH)
							AddFileToDownloadsTable(bufferString)
						}
						else
						{
							killConfig[setNum][killNum] = 0
							PrintToServer("[SM] Quake Sounds v3: File specified in 'killsound %i' does not exist in '%s', ignoring.",killNum,setFile)
						}
					}
				} while (KvGotoNextKey(SetFileKV))
				KvGoBack(SetFileKV)
			}
			else
			{
				PrintToServer("[SM] Quake Sounds v3: 'killsound' section not configured correctly in %s.",setFile)
			}
		}
		else
		{
			PrintToServer("[SM] Quake Sounds v3: 'killsound' section missing in %s.",setFile)
		}
		KvRewind(SetFileKV)
		if(KvJumpToKey(SetFileKV,"first blood"))
		{
			if(KvGotoFirstSubKey(SetFileKV))
			{
				PrintToServer("[SM] Quake Sounds v3: 'first blood' section not configured correctly in %s.",setFile)
				KvGoBack(SetFileKV)
			}
			else
			{
				KvGetString(SetFileKV,"sound",firstbloodSound[setNum],PLATFORM_MAX_PATH)
				firstbloodConfig[setNum] = KvGetNum(SetFileKV,"config",9)
				Format(bufferString,PLATFORM_MAX_PATH,"sound/%s",firstbloodSound[setNum])
				if(FileExists(bufferString,true))
				{
					PrecacheSoundCustom(firstbloodSound[setNum],PLATFORM_MAX_PATH)
					AddFileToDownloadsTable(bufferString)
				}
				else
				{
					firstbloodConfig[setNum] = 0
					PrintToServer("[SM] Quake Sounds v3: File specified in 'first blood' does not exist in '%s', ignoring.",setFile)
				}
			}
		}
		else
		{
			PrintToServer("[SM] Quake Sounds v3: 'first blood' section missing in %s.",setFile)
		}
		KvRewind(SetFileKV)
		if(KvJumpToKey(SetFileKV,"teamkill"))
		{
			if(KvGotoFirstSubKey(SetFileKV))
			{
				PrintToServer("[SM] Quake Sounds v3: 'teamkill' section not configured correctly in %s.",setFile)
				KvGoBack(SetFileKV)
			}
			else
			{
				KvGetString(SetFileKV,"sound",teamkillSound[setNum],PLATFORM_MAX_PATH)
				teamkillConfig[setNum] = KvGetNum(SetFileKV,"config",9)
				Format(bufferString,PLATFORM_MAX_PATH,"sound/%s",teamkillSound[setNum])
				if(FileExists(bufferString,true))
				{
					PrecacheSoundCustom(teamkillSound[setNum],PLATFORM_MAX_PATH)
					AddFileToDownloadsTable(bufferString)
				}
				else
				{
					teamkillConfig[setNum] = 0
					PrintToServer("[SM] Quake Sounds v3: File specified in 'teamkill' does not exist in '%s', ignoring.",setFile)
				}
			}
		}
		else
		{
			PrintToServer("[SM] Quake Sounds v3: 'teamkill' section missing in %s.",setFile)
		}
		KvRewind(SetFileKV)
		if(KvJumpToKey(SetFileKV,"combo"))
		{
			if(KvGotoFirstSubKey(SetFileKV))
			{
				do
				{
					KvGetSectionName(SetFileKV,bufferString,PLATFORM_MAX_PATH)
					new killNum = StringToInt(bufferString)
					if(killNum >= 0)
					{
						KvGetString(SetFileKV,"sound",comboSound[setNum][killNum],PLATFORM_MAX_PATH)
						comboConfig[setNum][killNum] = KvGetNum(SetFileKV,"config",9)
						Format(bufferString,PLATFORM_MAX_PATH,"sound/%s",comboSound[setNum][killNum])
						if(FileExists(bufferString,true))
						{
							PrecacheSoundCustom(comboSound[setNum][killNum],PLATFORM_MAX_PATH)
							AddFileToDownloadsTable(bufferString)
						}
						else
						{
							comboConfig[setNum][killNum] = 0
							PrintToServer("[SM] Quake Sounds v3: File specified in 'combo %i' does not exist in '%s', ignoring.",killNum,setFile)
						}
					}
				} while (KvGotoNextKey(SetFileKV))
				KvGoBack(SetFileKV)
			}
			else
			{
				PrintToServer("[SM] Quake Sounds v3: 'combo' section not configured correctly in %s.",setFile)
			}
		}
		else
		{
			PrintToServer("[SM] Quake Sounds v3: 'combo' section missing in %s.",setFile)
		}
		KvRewind(SetFileKV)
		if(KvJumpToKey(SetFileKV,"join server"))
		{
			if(KvGotoFirstSubKey(SetFileKV))
			{
				PrintToServer("[SM] Quake Sounds v3: 'join server' section not configured correctly in %s.",setFile)
				KvGoBack(SetFileKV)
			}
			else
			{
				KvGetString(SetFileKV,"sound",joinSound[setNum],PLATFORM_MAX_PATH)
				joinConfig[setNum] = KvGetNum(SetFileKV,"config",9)
				Format(bufferString,PLATFORM_MAX_PATH,"sound/%s",joinSound[setNum])
				if(FileExists(bufferString,true))
				{
					PrecacheSoundCustom(joinSound[setNum],PLATFORM_MAX_PATH)
					AddFileToDownloadsTable(bufferString)
				}
				else
				{
					joinConfig[setNum] = 0
					PrintToServer("[SM] Quake Sounds v3: File specified in 'join server' does not exist in '%s', ignoring.",setFile)
				}
			}
		}
		else
		{
			PrintToServer("[SM] Quake Sounds v3: 'join server' section missing in %s.",setFile)
		}
	}
	else
	{
		PrintToServer("[SM] Quake Sounds v3: Cannot parse '%s', file not found or incorrectly structured!",setFile)
	}
	CloseHandle(SetFileKV)
}

// Things to do when map starts
public OnMapStart()
{
	LoadSoundSets()
	if(gameEngine == Engine_HL2DM)
	{
		NewRoundInitialization()
	}
}

// Things to do when the round starts
public EventRoundStart(Handle:event,const String:name[],bool:dontBroadcast)
{
	if(gameEngine != Engine_HL2DM)
	{
		NewRoundInitialization()
	}
}

// Resets combo/headshot streaks (not kill streaks though) on new round
public NewRoundInitialization()
{
	totalKills = 0
	for(new i = 1; i <= GetMaxHumanPlayers(); i++) 
	{
		consecutiveHeadshots[i] = 0
		lastKillTime[i] = -1.0
	}
}

// Plays round play sound depending on each players config and the text display
public EventRoundFreezeEnd(Handle:event,const String:name[],bool:dontBroadcast)
{
	for(new i = 1; i <= GetMaxHumanPlayers(); i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i) && soundPreference[i] >= 0)
		{
			if(!StrEqual(roundplaySound[soundPreference[i]],"")  && (roundplayConfig[soundPreference[i]] & 1) || (roundplayConfig[soundPreference[i]] & 2) || (roundplayConfig[soundPreference[i]] & 4))
			{
				EmitSoundCustom(i,roundplaySound[soundPreference[i]],_,_,_,_,GetConVarFloat(FindConVar("sm_quakesoundsv3_volume")))
			}
			if(textPreference[i] && (roundplayConfig[soundPreference[i]] & 8) || (roundplayConfig[soundPreference[i]] & 16) || (roundplayConfig[soundPreference[i]] & 32))
			{
				PrintCenterText(i,"%t","round play")
			}
		}
	}
}

// Reset clients preferences and reload them when they join. Changed to PostAdminCheck for CS:GO compatibility.
public OnClientPostAdminCheck(client)
{
	consecutiveKills[client] = 0
	lastKillTime[client] = -1.0
	consecutiveHeadshots[client] = 0
	if(!IsFakeClient(client))
	{
		soundPreference[client] = GetConVarInt(FindConVar("sm_quakesoundsv3_sound")) -1
		textPreference[client] = GetConVarInt(FindConVar("sm_quakesoundsv3_announce"))
		if(AreClientCookiesCached(client))
		{
			LoadClientCookiesFor(client)
		}
		if(GetConVarBool(FindConVar("sm_quakesoundsv3_announce")))
		{
			CreateTimer(30.0,TimerAnnounce,client)
		}
		if(soundPreference[client] >= 0)
		{
			if(!StrEqual(joinSound[soundPreference[client]],"") && (joinConfig[soundPreference[client]] & 1) || (joinConfig[soundPreference[client]] & 2) || (joinConfig[soundPreference[client]] & 4))
			{
				EmitSoundCustom(client,joinSound[soundPreference[client]],_,_,_,_,GetConVarFloat(FindConVar("sm_quakesoundsv3_volume")))
			}
		}
	}
	else
	{
		soundPreference[client] = -1
		textPreference[client] = 0
	}
}

// Announce the settings option after time set when timer created (Default 30 secs)
public Action:TimerAnnounce(Handle:timer,any:client)
{
	if(IsClientInGame(client))
	{
		PrintToChat(client,"%t","announce message")
	}
}

// When clients cookies have been loaded, check them for prefs
public OnClientCookiesCached(client)
{
	if(IsClientInGame(client) && !IsFakeClient(client))
	{
		LoadClientCookiesFor(client)	
	}
}

// Retrieving clients cookie settings
public LoadClientCookiesFor(client)
{
	new String:buffer[5]
	GetClientCookie(client,cookieTextPref,buffer,5)
	if(!StrEqual(buffer,""))
	{
		textPreference[client] = StringToInt(buffer)
	}
	GetClientCookie(client,cookieSoundPref,buffer,5)
	if(!StrEqual(buffer,""))
	{
		soundPreference[client] = StringToInt(buffer)
	}
}

// Important bit - does all kill/combo/custom kill sounds and things!
public EventPlayerDeath(Handle:event,const String:name[],bool:dontBroadcast)
{
	new attackerClient = GetClientOfUserId(GetEventInt(event,"attacker"))
	new String:attackerName[MAX_NAME_LENGTH]
	GetClientName(attackerClient,attackerName,MAX_NAME_LENGTH)
	new victimClient = GetClientOfUserId(GetEventInt(event,"userid"))
	new String:victimName[MAX_NAME_LENGTH]
	GetClientName(victimClient,victimName,MAX_NAME_LENGTH)
	new String:bufferString[256]
	if(victimClient < 1 || victimClient > GetMaxHumanPlayers())
	{
		return
	}
	else
	{
		if(attackerClient == victimClient || attackerClient == 0)
		{
			consecutiveKills[attackerClient] = 0
			for(new i = 1; i <= GetMaxHumanPlayers(); i++)
			{
				if(IsClientInGame(i) && !IsFakeClient(i) && soundPreference[i] >= 0)
				{
					if(!StrEqual(selfkillSound[soundPreference[i]],""))
					{
						if(selfkillConfig[soundPreference[i]] & 1)
						{
							EmitSoundCustom(i,selfkillSound[soundPreference[i]],_,_,_,_,GetConVarFloat(FindConVar("sm_quakesoundsv3_volume")))
						}
						else if((selfkillConfig[soundPreference[i]] & 2) && attackerClient == i)
						{
							EmitSoundCustom(i,selfkillSound[soundPreference[i]],_,_,_,_,GetConVarFloat(FindConVar("sm_quakesoundsv3_volume")))
						}
						else if((selfkillConfig[soundPreference[i]] & 4) && victimClient == i)
						{
							EmitSoundCustom(i,selfkillSound[soundPreference[i]],_,_,_,_,GetConVarFloat(FindConVar("sm_quakesoundsv3_volume")))
						}
					}
					if(textPreference[i])
					{
						if(selfkillConfig[soundPreference[i]] & 8)
						{
							PrintCenterText(i,"%t","selfkill",victimName)
						}
						else if((selfkillConfig[soundPreference[i]] & 16) && attackerClient == i)
						{
							PrintCenterText(i,"%t","selfkill",victimName)
						}
						else if((selfkillConfig[soundPreference[i]] & 32) && victimClient == i)
						{
							PrintCenterText(i,"%t","selfkill",victimName)
						}
					}
				}
			}
		}
		else if(GetClientTeam(attackerClient) == GetClientTeam(victimClient) && !GetConVarBool(FindConVar("sm_quakesoundsv3_teamkill_mode")))
		{
			consecutiveKills[attackerClient] = 0
			for(new i = 1; i <= GetMaxHumanPlayers(); i++)
			{
				if(IsClientInGame(i) && !IsFakeClient(i) && soundPreference[i] >= 0)
				{
					if(!StrEqual(teamkillSound[soundPreference[i]],""))
					{
						if(teamkillConfig[soundPreference[i]] & 1)
						{
							EmitSoundCustom(i,teamkillSound[soundPreference[i]],_,_,_,_,GetConVarFloat(FindConVar("sm_quakesoundsv3_volume")))
						}
						else if((teamkillConfig[soundPreference[i]] & 2) && attackerClient == i)
						{
							EmitSoundCustom(i,teamkillSound[soundPreference[i]],_,_,_,_,GetConVarFloat(FindConVar("sm_quakesoundsv3_volume")))
						}
						else if((teamkillConfig[soundPreference[i]] & 4) && victimClient == i)
						{
							EmitSoundCustom(i,teamkillSound[soundPreference[i]],_,_,_,_,GetConVarFloat(FindConVar("sm_quakesoundsv3_volume")))
						}
					}
					if(textPreference[i])
					{
						if(teamkillConfig[soundPreference[i]] & 8)
						{
							PrintCenterText(i,"%t","teamkill",attackerName,victimName)
						}
						else if((teamkillConfig[soundPreference[i]] & 16) && attackerClient == i)
						{
							PrintCenterText(i,"%t","teamkill",attackerName,victimName)
						}
						else if((teamkillConfig[soundPreference[i]] & 32) && victimClient == i)
						{
							PrintCenterText(i,"%t","teamkill",attackerName,victimName)
						}
					}
				}
			}
		}
		else
		{
			totalKills++
			consecutiveKills[attackerClient]++
			new bool:firstblood
			new bool:headshot
			new bool:knife
			new bool:grenade
			new bool:combo
			new customkill
			new String:weapon[GetMaxHumanPlayers()]
			GetEventString(event,"weapon",weapon,GetMaxHumanPlayers())
			if(gameEngine == Engine_CSS || gameEngine == Engine_CSGO)
			{
				headshot = GetEventBool(event,"headshot")
			}
			else if(gameEngine == Engine_TF2)
			{
				customkill = GetEventInt(event,"customkill")
				if(customkill == 1)
				{
					headshot = true
				}
			}
			else
			{
				headshot = false
			}
			if(headshot)
			{
				consecutiveHeadshots[attackerClient]++
			}
			new Float:tempLastKillTime = lastKillTime[attackerClient]
			lastKillTime[attackerClient] = GetEngineTime()			
			if(tempLastKillTime == -1.0 || (lastKillTime[attackerClient] - tempLastKillTime) > GetConVarFloat(FindConVar("sm_quakesoundsv3_combo_time")))
			{
				comboScore[attackerClient] = 1
				combo = false
			}
			else
			{
				comboScore[attackerClient]++
				combo = true
			}
			if(totalKills == 1)
			{
				firstblood = true
			}
			if(gameEngine == Engine_TF2)
			{
				if(customkill == 2)
				{
					knife = true
				}
			}
			else if(gameEngine == Engine_CSS)
			{
				if(StrEqual(weapon,"hegrenade") || StrEqual(weapon,"smokegrenade") || StrEqual(weapon,"flashbang"))
				{
					grenade = true
				}
				else if(StrEqual(weapon,"knife"))
				{
					knife = true
				}
			}
			else if(gameEngine == Engine_CSGO)
			{
				if(StrEqual(weapon,"inferno") || StrEqual(weapon,"hegrenade") || StrEqual(weapon,"flashbang") || StrEqual(weapon,"decoy") || StrEqual(weapon,"smokegrenade"))
				{
					grenade = true
				}
				else if(StrEqual(weapon,"knife_default_ct") || StrEqual(weapon,"knife_default_t") || StrEqual(weapon,"knifegg") || StrEqual(weapon,"knife_flip") || StrEqual(weapon,"knife_gut") || StrEqual(weapon,"knife_karambit") || StrEqual(weapon,"bayonet") || StrEqual(weapon,"knife_m9_bayonet"))
				{
					knife = true
				}
			}
			else if(gameEngine == Engine_DODS)
			{
				if(StrEqual(weapon,"riflegren_ger") || StrEqual(weapon,"riflegren_us") || StrEqual(weapon,"frag_ger") || StrEqual(weapon,"frag_us") || StrEqual(weapon,"smoke_ger") || StrEqual(weapon,"smoke_us"))
				{
					grenade = true
				}
				else if((StrEqual(weapon,"spade") || StrEqual(weapon,"amerknife") || StrEqual(weapon,"punch")))
				{
					knife = true
				}
			}
			else if(gameEngine == Engine_HL2DM)
			{
				if(StrEqual(weapon,"grenade_frag"))
				{
					grenade = true
				}
				else if((StrEqual(weapon,"stunstick") || StrEqual(weapon,"crowbar")))
				{
					knife = true
				}
			}
			for(new i = 1; i <= GetMaxHumanPlayers(); i++)
			{
				if(IsClientInGame(i) && !IsFakeClient(i) && soundPreference[i] >= 0)
				{
					if(firstblood && firstbloodConfig[soundPreference[i]] > 0)
					{
						if(!StrEqual(firstbloodSound[soundPreference[i]],""))
						{
							if(firstbloodConfig[soundPreference[i]] & 1)
							{
								EmitSoundCustom(i,firstbloodSound[soundPreference[i]],_,_,_,_,GetConVarFloat(FindConVar("sm_quakesoundsv3_volume")))
							}
							else if((firstbloodConfig[soundPreference[i]] & 2) && attackerClient == i)
							{
								EmitSoundCustom(i,firstbloodSound[soundPreference[i]],_,_,_,_,GetConVarFloat(FindConVar("sm_quakesoundsv3_volume")))
							}
							else if((firstbloodConfig[soundPreference[i]] & 4) && victimClient == i)
							{
								EmitSoundCustom(i,firstbloodSound[soundPreference[i]],_,_,_,_,GetConVarFloat(FindConVar("sm_quakesoundsv3_volume")))
							}
						}
						if(textPreference[i])
						{
							if(firstbloodConfig[soundPreference[i]] & 8)
							{
								PrintCenterText(i,"%t","first blood",attackerName)
							}
							else if((firstbloodConfig[soundPreference[i]] & 16) && attackerClient == i)
							{
								PrintCenterText(i,"%t","first blood",attackerName)
							}
							else if((firstbloodConfig[soundPreference[i]] & 32) && victimClient == i)
							{
								PrintCenterText(i,"%t","first blood",attackerName)
							}
						}
					}
					else if(headshot && headshotConfig[soundPreference[i]][0] > 0)
					{
						if(!StrEqual(headshotSound[soundPreference[i]][0],""))
						{
							if(headshotConfig[soundPreference[i]][0] & 1)
							{
								EmitSoundCustom(i,headshotSound[soundPreference[i]][0],_,_,_,_,GetConVarFloat(FindConVar("sm_quakesoundsv3_volume")))
							}
							else if((headshotConfig[soundPreference[i]][0] & 2) && attackerClient == i)
							{
								EmitSoundCustom(i,headshotSound[soundPreference[i]][0],_,_,_,_,GetConVarFloat(FindConVar("sm_quakesoundsv3_volume")))
							}
							else if((headshotConfig[soundPreference[i]][0] & 4) && victimClient == i)
							{
								EmitSoundCustom(i,headshotSound[soundPreference[i]][0],_,_,_,_,GetConVarFloat(FindConVar("sm_quakesoundsv3_volume")))
							}
						}
						if(textPreference[i])
						{
							if(headshotConfig[soundPreference[i]][0] & 8)
							{
								PrintCenterText(i,"%t","headshot",attackerName)
							}
							else if((headshotConfig[soundPreference[i]][0] & 16) && attackerClient == i)
							{
								PrintCenterText(i,"%t","headshot",attackerName)
							}
							else if((headshotConfig[soundPreference[i]][0] & 32) && victimClient == i)
							{
								PrintCenterText(i,"%t","headshot",attackerName)
							}
						}
					}
					else if(headshot && consecutiveHeadshots[attackerClient] < MAX_NUM_KILLS && headshotConfig[soundPreference[i]][consecutiveHeadshots[attackerClient]] > 0)
					{
						if(!StrEqual(headshotSound[soundPreference[i]][consecutiveHeadshots[attackerClient]],""))
						{
							if(headshotConfig[soundPreference[i]][consecutiveHeadshots[attackerClient]] & 1)
							{
								EmitSoundCustom(i,headshotSound[soundPreference[i]][consecutiveHeadshots[attackerClient]],_,_,_,_,GetConVarFloat(FindConVar("sm_quakesoundsv3_volume")))
							}
							else if((headshotConfig[soundPreference[i]][consecutiveHeadshots[attackerClient]] & 2) && attackerClient == i)
							{
								EmitSoundCustom(i,headshotSound[soundPreference[i]][consecutiveHeadshots[attackerClient]],_,_,_,_,GetConVarFloat(FindConVar("sm_quakesoundsv3_volume")))
							}
							else if((headshotConfig[soundPreference[i]][consecutiveHeadshots[attackerClient]] & 4) && victimClient == i)
							{
								EmitSoundCustom(i,headshotSound[soundPreference[i]][consecutiveHeadshots[attackerClient]],_,_,_,_,GetConVarFloat(FindConVar("sm_quakesoundsv3_volume")))
							}
						}
						if(textPreference[i] && consecutiveHeadshots[attackerClient] < MAX_NUM_KILLS)
						{
							if(headshotConfig[soundPreference[i]][consecutiveHeadshots[attackerClient]] & 8)
							{
								Format(bufferString,256,"headshot %i",consecutiveHeadshots[attackerClient])
								PrintCenterText(i,"%t",bufferString,attackerName)
							}
							else if((headshotConfig[soundPreference[i]][consecutiveHeadshots[attackerClient]] & 16) && attackerClient == i)
							{
								Format(bufferString,256,"headshot %i",consecutiveHeadshots[attackerClient])
								PrintCenterText(i,"%t",bufferString,attackerName)
							}
							else if((headshotConfig[soundPreference[i]][consecutiveHeadshots[attackerClient]] & 32) && victimClient == i)
							{
								Format(bufferString,256,"headshot %i",consecutiveHeadshots[attackerClient])
								PrintCenterText(i,"%t",bufferString,attackerName)
							}
						}
					}
					else if(knife && knifeConfig[soundPreference[i]] > 0)
					{
						if(!StrEqual(knifeSound[soundPreference[i]],""))
						{
							if(knifeConfig[soundPreference[i]] & 1)
							{
								EmitSoundCustom(i,knifeSound[soundPreference[i]],_,_,_,_,GetConVarFloat(FindConVar("sm_quakesoundsv3_volume")))
							}
							else if((knifeConfig[soundPreference[i]] & 2) && attackerClient == i)
							{
								EmitSoundCustom(i,knifeSound[soundPreference[i]],_,_,_,_,GetConVarFloat(FindConVar("sm_quakesoundsv3_volume")))
							}
							else if((knifeConfig[soundPreference[i]] & 4) && victimClient == i)
							{
								EmitSoundCustom(i,knifeSound[soundPreference[i]],_,_,_,_,GetConVarFloat(FindConVar("sm_quakesoundsv3_volume")))
							}
						}
						if(textPreference[i])
						{
							if(knifeConfig[soundPreference[i]] & 8)
							{
								PrintCenterText(i,"%t","knife",attackerName,victimName)
							}
							else if((knifeConfig[soundPreference[i]] & 16) && attackerClient == i)
							{
								PrintCenterText(i,"%t","knife",attackerName,victimName)
							}
							else if((knifeConfig[soundPreference[i]] & 32) && victimClient == i)
							{
								PrintCenterText(i,"%t","knife",attackerName,victimName)
							}
						}
					}
					else if(grenade && grenadeConfig[soundPreference[i]] > 0)
					{
						if(!StrEqual(grenadeSound[soundPreference[i]],""))
						{
							if(grenadeConfig[soundPreference[i]] & 1)
							{
								EmitSoundCustom(i,grenadeSound[soundPreference[i]],_,_,_,_,GetConVarFloat(FindConVar("sm_quakesoundsv3_volume")))
							}
							else if((grenadeConfig[soundPreference[i]] & 2) && attackerClient == i)
							{
								EmitSoundCustom(i,grenadeSound[soundPreference[i]],_,_,_,_,GetConVarFloat(FindConVar("sm_quakesoundsv3_volume")))
							}
							else if((grenadeConfig[soundPreference[i]] & 4) && victimClient == i)
							{
								EmitSoundCustom(i,grenadeSound[soundPreference[i]],_,_,_,_,GetConVarFloat(FindConVar("sm_quakesoundsv3_volume")))
							}
						}
						if(textPreference[i])
						{
							if(grenadeConfig[soundPreference[i]] & 8)
							{
								PrintCenterText(i,"%t","grenade",attackerName,victimName)
							}
							else if((grenadeConfig[soundPreference[i]] & 16) && attackerClient == i)
							{
								PrintCenterText(i,"%t","grenade",attackerName,victimName)
							}
							else if((grenadeConfig[soundPreference[i]] & 32) && victimClient == i)
							{
								PrintCenterText(i,"%t","grenade",attackerName,victimName)
							}
						}
					}
					else if(combo && comboScore[attackerClient] < MAX_NUM_KILLS && comboConfig[soundPreference[i]][comboScore[attackerClient]] > 0)
					{
						if(!StrEqual(comboSound[soundPreference[i]][comboScore[attackerClient]],""))
						{
							if(comboConfig[soundPreference[i]][comboScore[attackerClient]] & 1)
							{
								EmitSoundCustom(i,comboSound[soundPreference[i]][comboScore[attackerClient]],_,_,_,_,GetConVarFloat(FindConVar("sm_quakesoundsv3_volume")))
							}
							else if((comboConfig[soundPreference[i]][comboScore[attackerClient]] & 2) && attackerClient == i)
							{
								EmitSoundCustom(i,comboSound[soundPreference[i]][comboScore[attackerClient]],_,_,_,_,GetConVarFloat(FindConVar("sm_quakesoundsv3_volume")))
							}
							else if((comboConfig[soundPreference[i]][comboScore[attackerClient]] & 4) && victimClient == i)
							{
								EmitSoundCustom(i,comboSound[soundPreference[i]][comboScore[attackerClient]],_,_,_,_,GetConVarFloat(FindConVar("sm_quakesoundsv3_volume")))
							}
						}
						if(textPreference[i] && comboScore[attackerClient] < MAX_NUM_KILLS)
						{
							if(comboConfig[soundPreference[i]][comboScore[attackerClient]] & 8)
							{
								Format(bufferString,256,"combo %i",comboScore[attackerClient])
								PrintCenterText(i,"%t",bufferString,attackerName)
							}
							else if((comboConfig[soundPreference[i]][comboScore[attackerClient]] & 16) && attackerClient == i)
							{
								Format(bufferString,256,"combo %i",comboScore[attackerClient])
								PrintCenterText(i,"%t",bufferString,attackerName)
							}
							else if((comboConfig[soundPreference[i]][comboScore[attackerClient]] & 32) && victimClient == i)
							{
								Format(bufferString,256,"combo %i",comboScore[attackerClient])
								PrintCenterText(i,"%t",bufferString,attackerName)
							}
						}
					}
					else
					{
						if(consecutiveKills[attackerClient] < MAX_NUM_KILLS && !StrEqual(killSound[soundPreference[i]][consecutiveKills[attackerClient]],""))
						{
							if(killConfig[soundPreference[i]][consecutiveKills[attackerClient]] & 1)
							{
								EmitSoundCustom(i,killSound[soundPreference[i]][consecutiveKills[attackerClient]],_,_,_,_,GetConVarFloat(FindConVar("sm_quakesoundsv3_volume")))
							}
							else if((killConfig[soundPreference[i]][consecutiveKills[attackerClient]] & 2) && attackerClient == i)
							{
								EmitSoundCustom(i,killSound[soundPreference[i]][consecutiveKills[attackerClient]],_,_,_,_,GetConVarFloat(FindConVar("sm_quakesoundsv3_volume")))
							}
							else if((killConfig[soundPreference[i]][consecutiveKills[attackerClient]] & 4) && victimClient == i)
							{
								EmitSoundCustom(i,killSound[soundPreference[i]][consecutiveKills[attackerClient]],_,_,_,_,GetConVarFloat(FindConVar("sm_quakesoundsv3_volume")))
							}
						}
						if(textPreference[i] && consecutiveKills[attackerClient] < MAX_NUM_KILLS)
						{
							if(killConfig[soundPreference[i]][consecutiveKills[attackerClient]] & 8)
							{
								Format(bufferString,256,"killsound %i",consecutiveKills[attackerClient])
								PrintCenterText(i,"%t",bufferString,attackerName)
							}
							else if((killConfig[soundPreference[i]][consecutiveKills[attackerClient]] & 16) && attackerClient == i)
							{
								Format(bufferString,256,"killsound %i",consecutiveKills[attackerClient])
								PrintCenterText(i,"%t",bufferString,attackerName)
							}
							else if((killConfig[soundPreference[i]][consecutiveKills[attackerClient]] & 32) && victimClient == i)
							{
								Format(bufferString,256,"killsound %i",consecutiveKills[attackerClient])
								PrintCenterText(i,"%t",bufferString,attackerName)
							}
						}
					}
				}
			}
		}
	}
	consecutiveKills[victimClient] = 0
	consecutiveHeadshots[victimClient] = 0
}

// When someone uses command to open prefs menu, open the menu
public Action:CMD_ShowQuakePrefsMenu(client,args)
{
	ShowQuakeMenu(client)
	return Plugin_Handled
}

// Make the menu or nothing will show
public ShowQuakeMenu(client)
{
	new Handle:menu = CreateMenu(MenuHandlerQuake)
	new String:buffer[100]
	Format(buffer,100,"%T","quake menu",client)
	SetMenuTitle(menu,buffer)
	if(textPreference[client] == 0)
	{
		Format(buffer,100,"%T","enable text",client)
	}
	else
	{
		Format(buffer,100,"%T","disable text",client)
	}
	AddMenuItem(menu,"text pref",buffer)
	if(soundPreference[client] == -1)
	{
		Format(buffer,100,"%T (Enabled)","no quake sounds",client)
	}
	else
	{
		Format(buffer,100,"%T","no quake sounds",client)
	}
	AddMenuItem(menu,"no sounds",buffer)
	for(new set = 0; set < numSets; set++) 
	{
		if(soundPreference[client] == set)
		{
			Format(buffer,50,"%T (Enabled)",setsName[set],client)
		}
		else
		{
			Format(buffer,50,"%T",setsName[set],client)
		}
		AddMenuItem(menu,"sound set",buffer)
	}
	SetMenuExitButton(menu,true)
	DisplayMenu(menu,client,20)
}

// Check what's been selected in the menu
public MenuHandlerQuake(Handle:menu,MenuAction:action,param1,param2)
{
	if(action == MenuAction_Select)	
	{
		if(param2 == 0)
		{
			if(textPreference[param1] == 0)
			{
				textPreference[param1] = 1
			}
			else
			{
				textPreference[param1] = 0
			}
		}
		else if(param2 == 1)
		{
			soundPreference[param1] = -1
		}
		else
		{
			soundPreference[param1] = param2 - 2
		}
		new String:buffer[5]
		IntToString(textPreference[param1],buffer,5)
		SetClientCookie(param1,cookieTextPref,buffer)
		IntToString(soundPreference[param1],buffer,5)
		SetClientCookie(param1,cookieSoundPref,buffer)
		CMD_ShowQuakePrefsMenu(param1,0)
	} 
	else if(action == MenuAction_End)
	{
		CloseHandle(menu)
	}
}

// Adds specified sound to cache (and for CSGO)
stock PrecacheSoundCustom(String:soundFile[],maxLength)
{
	if(gameEngine == Engine_CSGO)
	{
		Format(soundFile,maxLength,"*%s",soundFile)
		AddToStringTable(FindStringTable("soundprecache"),soundFile)
	}
	else
	{
		PrecacheSound(soundFile,true)
	}
}

// Custom EmitSound to allow compatibility with all game engines
stock EmitSoundCustom(client,const String:sound[],entity=SOUND_FROM_PLAYER,channel=SNDCHAN_AUTO,level=SNDLEVEL_NORMAL,flags=SND_NOFLAGS,Float:volume=SNDVOL_NORMAL,pitch=SNDPITCH_NORMAL,speakerentity=-1,const Float:origin[3]=NULL_VECTOR,const Float:dir[3]=NULL_VECTOR,bool:updatePos=true,Float:soundtime=0.0)
{
	new clients[1]
	clients[0]=client
	EmitSound(clients,1,sound,entity,channel,level,flags,volume,pitch,speakerentity,origin,dir,updatePos,soundtime)
}