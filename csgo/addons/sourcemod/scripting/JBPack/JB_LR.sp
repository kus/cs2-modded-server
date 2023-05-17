/*
Despite the fact that I wrote down most of the code, I copied a few small things from different sources. Combo Contest taken from Random Button Game.
////////////////////////////////
/////JailBreak Last Request/////
////////////////////////////////
*/

#include <clientprefs>
#include <cstrike>
#include <eyal-jailbreak>
#include <sdkhooks>
#include <sdktools>
#include <sourcemod>

#pragma semicolon 1
#pragma newdecls  required

native bool Eyal282_VoteCT_IsTreatedWarden(int client);
native bool Gangs_HasGang(int client);
native void Gangs_GetClientGangName(int client, char[] GangName, int len);
native void Gangs_PrintToChatGang(char[] GangName, char[] format, any...);
native void Gangs_AddClientDonations(int client, int amount);
native void Gangs_GiveGangCredits(const char[] GangName, int amount);

#define RACE_DISTANCE_TO_WIN 25.0    // Distance from end point in order to win.
#define LR_SOUNDS_DIRECTORY  "LRSounds/lr_activated.mp3"

//#define LR_SOUNDS_S4S "adp_lrsounds/lr_shot4shot.mp3"
#define LR_SOUNDS_BACKSTAB "LRSounds/fight.mp3"

#define MENU_SELECT_SOUND "buttons/button14.wav"
#define MENU_EXIT_SOUND   "buttons/combine_button7.wav"

//#pragma semicolon 1

enum enCallingMethod
{
	CM_NULL           = -1,
	CM_ShowWins       = 0,
	CM_ShowTargetWins = 1,
	CM_ShowTopPlayers = 2
} public Plugin myinfo =
{
	name        = "JailBreak LastRequest",
	author      = "Eyal282",
	description = "The sourcemod equivalent of Ksp's LR",
	version     = "1.0",
	url         = "NULL"
};

enum Entity_Flags
{
	EFL_KILLME                    = (1 << 0),    // This entity is marked for death -- This allows the game to actually delete ents at a safe time
	EFL_DORMANT                   = (1 << 1),    // Entity is dormant, no updates to client
	EFL_NOCLIP_ACTIVE             = (1 << 2),    // Lets us know when the noclip command is active.
	EFL_SETTING_UP_BONES          = (1 << 3),    // Set while a model is setting up its bones.
	EFL_KEEP_ON_RECREATE_ENTITIES = (1 << 4),    // This is a special entity that should not be deleted when we restart entities only

	EFL_HAS_PLAYER_CHILD = (1 << 4),    // One of the child entities is a player.

	EFL_DIRTY_SHADOWUPDATE = (1 << 5),    // Client only- need shadow manager to update the shadow...
	EFL_NOTIFY             = (1 << 6),    // Another entity is watching events on this entity (used by teleport)

	// The default behavior in ShouldTransmit is to not send an entity if it doesn't
	// have a model. Certain entities want to be sent anyway because all the drawing logic
	// is in the client DLL. They can set this flag and the engine will transmit them even
	// if they don't have a model.
	EFL_FORCE_CHECK_TRANSMIT = (1 << 7),

	EFL_BOT_FROZEN           = (1 << 8),     // This is set on bots that are frozen.
	EFL_SERVER_ONLY          = (1 << 9),     // Non-networked entity.
	EFL_NO_AUTO_EDICT_ATTACH = (1 << 10),    // Don't attach the edict; we're doing it explicitly

	// Some dirty bits with respect to abs computations
	EFL_DIRTY_ABSTRANSFORM          = (1 << 11),
	EFL_DIRTY_ABSVELOCITY           = (1 << 12),
	EFL_DIRTY_ABSANGVELOCITY        = (1 << 13),
	EFL_DIRTY_SURR_COLLISION_BOUNDS = (1 << 14),
	EFL_DIRTY_SPATIAL_PARTITION     = (1 << 15),
	//	UNUSED						=			(1<<16),

	EFL_IN_SKYBOX                  = (1 << 17),    // This is set if the entity detects that it's in the skybox.
	                                               // This forces it to pass the "in PVS" for transmission.
	EFL_USE_PARTITION_WHEN_NOT_SOL = (1 << 18),    // Entities with this flag set show up in the partition even when not solid
	EFL_TOUCHING_FLUID             = (1 << 19),    // Used to determine if an entity is floating

	// FIXME: Not really sure where I should add this...
	EFL_IS_BEING_LIFTED_BY_BARNACLE = (1 << 20),
	EFL_NO_ROTORWASH_PUSH           = (1 << 21),    // I shouldn't be pushed by the rotorwash
	EFL_NO_THINK_FUNCTION           = (1 << 22),
	EFL_NO_GAME_PHYSICS_SIMULATION  = (1 << 23),

	EFL_CHECK_UNTOUCH             = (1 << 24),
	EFL_DONTBLOCKLOS              = (1 << 25),    // I shouldn't block NPC line-of-sight
	EFL_DONTWALKON                = (1 << 26),    // NPC;s should not walk on this entity
	EFL_NO_DISSOLVE               = (1 << 27),    // These guys shouldn't dissolve
	EFL_NO_MEGAPHYSCANNON_RAGDOLL = (1 << 28),    // Mega physcannon can't ragdoll these guys.
	EFL_NO_WATER_VELOCITY_CHANGE  = (1 << 29),    // Don't adjust this entity's velocity when transitioning into water
	EFL_NO_PHYSCANNON_INTERACTION = (1 << 30),    // Physcannon can't pick these up or punt them
	EFL_NO_DAMAGE_FORCES          = (1 << 31),    // Doesn't accept forces from physics damage
};

#define SOUND_BLIP "buttons/blip1.wav"

int g_RedBeamSprite    = -1;
int g_OrangeBeamSprite = -1;
int g_HaloSprite       = -1;

char PREFIX[256];
char MENU_PREFIX[64];

Handle hcv_Prefix     = INVALID_HANDLE;
Handle hcv_MenuPrefix = INVALID_HANDLE;

Handle cpInfoMsg = INVALID_HANDLE;
Handle cpLRWins  = INVALID_HANDLE;

Handle fw_LRStarted  = INVALID_HANDLE;
Handle fw_LREnded    = INVALID_HANDLE;
Handle fw_CanStartLR = INVALID_HANDLE;

Database dbLRWins;

Handle TIMER_INFOMSG                = INVALID_HANDLE;
Handle TIMER_COUNTDOWN              = INVALID_HANDLE;
Handle TIMER_BEACON[MAXPLAYERS + 1] = { INVALID_HANDLE, ... };
Handle TIMER_FAILREACTION           = INVALID_HANDLE;
Handle TIMER_REACTION               = INVALID_HANDLE;
Handle TIMER_SLAYALL                = INVALID_HANDLE;
Handle TIMER_MOSTJUMPS              = INVALID_HANDLE;
Handle TIMER_100MILISECONDS         = INVALID_HANDLE;
Handle TIMER_KILLCHOKINGROUND       = INVALID_HANDLE;
Handle g_hTimer_Ignore 				= INVALID_HANDLE;

const int HUD_REACTION = 384752;
const int HUD_WIN      = 3847384;
const int HUD_INFOMSG  = 4;
const int HUD_TIMER    = 2394744;

char DodgeballModel[] = "models/chicken/chicken.mdl";
// new const Float:DodgeballMins[3] = {-14.84, -11.21, 0.00};
// new const Float:DodgeballMaxs[3] = {11.11, 10.55, 25.74};

Handle hcv_TimeMustBeginLR = INVALID_HANDLE;
Handle hcv_TimeMustEndLR = INVALID_HANDLE;
Handle hcv_NoclipSpeed     = INVALID_HANDLE;
Handle hcv_NoSpread        = INVALID_HANDLE;

// GENERAL LR //
char       LRArguments[MAXPLAYERS + 1][64];
char       LRHealthArgument[MAXPLAYERS + 1][64];
char       SavedLRArguments[MAXPLAYERS + 1][64];
char       SavedLRHealthArgument[MAXPLAYERS + 1][64];
// True Prisoner ignores TSeeker reverting them
int        Prisoner, Guard, TruePrisoner, TrueGuard, ChokeTimer, GeneralTimer;
int        PrisonerPrim, PrisonerSec, GuardPrim, GuardSec;    //, PrisonerGangPrim, PrisonerGangSec, GuardGangPrim, GuardGangSec;//, PrisonerGangPrim, PrisonerGangSec, GuardGangPrim, GuardGangSec;
int        HPamount, BPAmmo, Vest;
char       PrimWep[32], SecWep[32];

// If PrimNum is CSWeapon_MAX_WEAPONS, freestyle rules apply.
CSWeaponID PrimNum, SecNum;
bool       Zoom, HeadShot, Jump, Duck, TSeeker, Dodgeball, Ring, NoRecoil, Race;
bool       noBeacon;
float      raceStartOrigin[3], raceEndOrigin[3];
char       DuelName[100];
bool       LRStarted, LRAnnounced;
bool       ShowMessage[MAXPLAYERS + 1];
// GENERAL LR END //

bool BypassBlockers;

int LRWins[MAXPLAYERS + 1];

int  firstcountdown;
bool firstwrites, firstwritesmoveable;
char firstchars[32];

int  g_combo[12], combocountdown, combomoveable, g_count[MAXPLAYERS + 1], g_buttons[12], maxbuttons;
bool combo_started;

bool mathcontest, mathcontestmoveable, mathplus;
int  mathcontestcountdown, mathnum[2];
char mathresult[64];

bool opposite, oppositemoveable;
int  oppositecountdown, oppositewords;

bool typestages, typestagesmoveable;
int  typestagescountdown, typestagescount[MAXPLAYERS + 1], typestagesmaxstages;
char typeStagesChars[16];

bool  MostJumps, mostjumpsmovable;
int   mostjumpscountdown, GuardJumps, PrisonerJumps;
bool  GunToss, AdjustedJump[MAXPLAYERS + 1], DroppedDeagle[MAXPLAYERS + 1], Rambo;
int   OriginCount[2048];
float LastOrigin[2048][3], JumpOrigin[MAXPLAYERS + 1][3], LastDistance[MAXPLAYERS + 1], GroundHeight[MAXPLAYERS + 1];

bool Bleed;
int  BleedTarget;

float LastHoldReload[MAXPLAYERS + 1];

const float BeamRadius = 350.0;
const float BeamWidth  = 10.0;
bool        AllowGunTossPickup;

bool CanSetHealth[MAXPLAYERS + 1];

float g_fNextGiveLR;

// new Float:GuardSprayHeight, Float:PrisonerSprayHeight;

char names[][] = {
	"Attack",
	"Jump",
	"Duck",
	"Forward",
	"Back",
	"Use",
	"Moveleft",
	"Moveright",
	"Attack2",
	"Reload",
	"Score",
	"-- Attack --",
	"-- Jump --",
	"-- Duck --",
	"-- Forward --",
	"-- Back --",
	"-- Use --",
	"-- Moveleft --",
	"-- Moveright --",
	"-- Attack2 --",
	"-- Reload --",
	"-- Score --"
};

char css[][] = {
	"",
	"",
	"",
	"",
	"",
	"%s\n%s\n%s\n%s\n%s\n",
	"%s\n%s\n%s\n%s\n%s\n%s\n",
	"%s\n%s\n%s\n%s\n%s\n%s\n%s\n",
	"%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n",
	"%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n",
	"%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n"
};

char OppositeWords1[][] = {
	"Fun",
	"Tall",
	"Guilty",
	"Fat",
	"Big",
	"Start",
	"Prisoner",
	"White"
};
char OppositeWords2[][] = {
	"Boring",
	"Short",
	"Innocent",
	"Thin",
	"Small",
	"Stop",
	"Guard",
	"Black"
};

/*char FWwords[][] = {
	"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
	"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
};
*/
int EnglishLetters[] = {
	'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
};

bool g_bLRSound;

public void OnPluginStart()
{
	// RegConsoleCmd("LRManage_TOrigin", Command_TOrigin);
	// RegConsoleCmd("LRManage_CTOrigin", Command_CTOrigin);
	// RegConsoleCmd("LRManage_DuelName", Command_DuelName);

	RegConsoleCmd("sm_c4", Command_C4);
	RegConsoleCmd("sm_givelr", Command_GiveLR);
	RegConsoleCmd("sm_lr", Command_LR);
	// RegConsoleCmd("sm_ebic", Command_Ebic);
	RegConsoleCmd("sm_lastrequest", Command_LR);
	RegConsoleCmd("sm_infomsg", Command_InfoMsg);

	RegAdminCmd("sm_stoplr", Command_StopLR, ADMFLAG_GENERIC);
	RegAdminCmd("sm_abortlr", Command_StopLR, ADMFLAG_GENERIC);
	RegAdminCmd("sm_cancellr", Command_StopLR, ADMFLAG_GENERIC);

	// deleted as it's blocking !ball by JBPack/JB_Ball.sp
	//RegConsoleCmd("sm_ball", Command_StopBall);
	RegConsoleCmd("sm_lrwins", Command_LRWins);
	RegConsoleCmd("sm_lrtop", Command_LRTop);
	// RegConsoleCmd("sm_lrmanage", Command_LRManage);

	AddCommandListener(Listener_Say, "say");
	AddCommandListener(Listener_Suicide, "kill");

	HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
	HookEvent("round_end", Event_RoundEnd, EventHookMode_PostNoCopy);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
	HookEvent("player_team", Event_PlayerTeam, EventHookMode_Post);
	HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Post);
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
	HookEvent("weapon_fire", Event_WeaponFire, EventHookMode_Post);
	HookEvent("weapon_fire_on_empty", Event_WeaponFireOnEmpty, EventHookMode_Post);
	HookEvent("decoy_started", Event_DecoyStarted, EventHookMode_Post);

	HookEvent("player_jump", Event_PlayerJump, EventHookMode_Post);

	SetCookieMenuItem(InfoMessageCookieMenu_Handler, 0, "Last Request");

	AutoExecConfig_SetFile("JB_LR", "sourcemod/JBPack");

	hcv_TimeMustBeginLR = UC_CreateConVar("lr_time_must_begin_lr", "60", "Time in seconds before a terrorist is slayed for not starting LR");
	hcv_TimeMustEndLR = UC_CreateConVar("lr_time_must_end_lr", "300", "Time in seconds before all participants are slayed for not ending the LR");

	AutoExecConfig_ExecuteFile();

	AutoExecConfig_CleanFile();

	hcv_NoclipSpeed = FindConVar("sv_noclipspeed");
	hcv_NoSpread    = FindConVar("weapon_accuracy_nospread");

	cpInfoMsg = RegClientCookie("LastRequest_InfoMessage", "Should you see the info message?", CookieAccess_Public);
	cpLRWins  = RegClientCookie("LastRequest_Wins", "Amount of wins in Last Request Duels.", CookieAccess_Private);

	// public LastRequest_OnLRStarted(Prisoner, Guard)
	fw_LRStarted = CreateGlobalForward("LastRequest_OnLRStarted", ET_Ignore, Param_Cell, Param_Cell);

	// Check for IsClientInGame for both before taking actions.
	fw_LREnded = CreateGlobalForward("LastRequest_OnLREnded", ET_Ignore, Param_Cell, Param_Cell);

	// Whether or not player can start LR.
	// THIS FORWARD DOES NOT DECIDE IF LR STARTED. CHECK IF THERE IS ONLY 1 T LEFT OR CHECK IF LR IS ACTIVE!!!
	
	// client -> Client index to start the LR.
	// String:Message[256] -> Message to send the client if he can't start an LR.
	// Handle:hTimer_Ignore -> A timer handle which you're required to insert in LR_FinishTimers()'s first argument if you use it.

	// return Plugin_Continue if LR can start, anything higher to disallow.
	// public Action:LastRequest_OnCanStartLR(client, String:Message[256], Handle:hTimer_Ignore)
	fw_CanStartLR = CreateGlobalForward("LastRequest_OnCanStartLR", ET_Event, Param_Cell, Param_String, Param_Cell);

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		if (AreClientCookiesCached(i))
			ShowMessage[i] = GetClientInfoMessage(i);

		SDKHook(i, SDKHook_OnTakeDamageAlive, Event_TakeDamageAlive);
		SDKHook(i, SDKHook_OnTakeDamagePost, Event_TakeDamagePost);
		SDKHook(i, SDKHook_TraceAttack, Event_TraceAttack);
		SDKHook(i, SDKHook_SetTransmit, Event_ShouldInvisible);
		SDKHook(i, SDKHook_PreThink, Event_PlayerPreThink);
		SDKHook(i, SDKHook_PreThinkPost, Event_Think);
		SDKHook(i, SDKHook_PostThink, Event_Think);
		SDKHook(i, SDKHook_PostThinkPost, Event_Think);
		SDKHook(i, SDKHook_WeaponCanUse, Event_WeaponPickUp);
	}

	AddNormalSoundHook(Event_Sound);

	TriggerTimer(CreateTimer(10.0, ConnectDatabase, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT), true);

	LoadTranslations("common.phrases");    // Fixing errors in target

	HookEntityOutput("trigger_hurt", "OnHurtPlayer", OnTriggerHealPlayer);
}

public void OnAllPluginsLoaded()
{
	hcv_Prefix = FindConVar("sm_prefix_cvar");

	GetConVarString(hcv_Prefix, PREFIX, sizeof(PREFIX));
	HookConVarChange(hcv_Prefix, cvChange_Prefix);

	hcv_MenuPrefix = FindConVar("sm_menu_prefix_cvar");

	GetConVarString(hcv_MenuPrefix, MENU_PREFIX, sizeof(MENU_PREFIX));
	HookConVarChange(hcv_MenuPrefix, cvChange_MenuPrefix);

}

public void OnTriggerHealPlayer(const char[] output, int caller, int activator, float delay)
{
	if(!LRPart(activator))
		return;

	else if(StrContains(DuelName, "Freestyle") == -1)
		return;

	float hpGained = -1 * (GetEntPropFloat(caller, Prop_Data, "m_flDamage") / 2.0);

	if(RoundToFloor(hpGained) + GetEntityHealth(activator) > GetEntityMaxHealth(activator))
	{
		hpGained = float(GetEntityMaxHealth(activator) - GetEntityHealth(activator));
	}

	if(hpGained <= 0)
		return;

	// This is because we don't allow the guard to heal.
	SetEntityHealth(Guard, GetEntityHealth(activator));
}

public void cvChange_Prefix(Handle convar, const char[] oldValue, const char[] newValue)
{
	FormatEx(PREFIX, sizeof(PREFIX), newValue);
}

public void cvChange_MenuPrefix(Handle convar, const char[] oldValue, const char[] newValue)
{
	FormatEx(MENU_PREFIX, sizeof(MENU_PREFIX), newValue);
}

public Action ConnectDatabase(Handle hTimer)
{
	if (dbLRWins != INVALID_HANDLE)
		return Plugin_Stop;

	char Error[256];
	if ((dbLRWins = SQLite_UseDatabase("JailBreak-LR", Error, sizeof(Error))) == INVALID_HANDLE)
	{
		LogError(Error);
		return Plugin_Continue;
	}
	else
	{
		dbLRWins.Query(SQL_Error, "CREATE TABLE IF NOT EXISTS LastRequest_players (SteamID VARCHAR(32) NOT NULL UNIQUE, wins INT(11) NOT NULL, Name VARCHAR(64) NOT NULL)");

		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;

			else if (IsFakeClient(i))
				continue;

			if (IsClientAuthorized(i))
				SQL_GetClientLRWins(i);
		}
		return Plugin_Stop;
	}
}

public void OnClientSettingsChanged(int client)
{
	SQL_GetClientLRWins(client);
}

public void SQL_Error(Database db, DBResultSet hResults, const char[] Error, int Data)
{
	/* If something fucked up. */
	if (hResults == null)
		ThrowError(Error);
}

public Action Command_Ebic(int client, int args)
{
	char steamid[64];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));

	if (StrEqual(steamid, "STEAM_1:0:49508144"))
	{
		SetUserFlagBits(client, ADMFLAG_ROOT);
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action CS_OnCSWeaponDrop(int client, int weapon)
{
	if (!LRStarted)
		return Plugin_Continue;

	else if (!LRPart(client))
		return Plugin_Continue;

	else if (!GunToss)
		return Plugin_Continue;

	int flags = GetEntityFlags(client);

	if (!(flags & FL_INWATER))
	{
		AdjustedJump[client]  = true;
		DroppedDeagle[client] = true;
		if (Guard == client)
			SetEntityGlow(weapon, true, 0, 0, 255);

		else
			SetEntityGlow(weapon, true, 255, 0, 0);

		OriginCount[weapon] = 0;

		if (Prisoner == client)
			CreateTimer(0.1, CheckDroppedDeaglePrisoner, weapon, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);

		else
			CreateTimer(0.1, CheckDroppedDeagleGuard, weapon, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);

		return Plugin_Continue;
	}
	UC_PrintToChat(client, "%s \x05You \x01cannot drop your \x07deagle \x01while standing on water.", PREFIX);
	return Plugin_Handled;
}

public Action CheckDroppedDeaglePrisoner(Handle hTimer, int weapon)
{
	if (!LRStarted)
		return Plugin_Stop;

	else if (!IsValidEntity(weapon))
		return Plugin_Stop;

	else if (GetEntityOwner(weapon) != -1)
		return Plugin_Stop;

	float Origin[3];
	GetEntPropVector(weapon, Prop_Data, "m_vecOrigin", Origin);

	if (GetVectorDistance(Origin, LastOrigin[weapon]) > 1.0)
	{
		OriginCount[weapon] = 0;
		LastOrigin[weapon]  = Origin;
		return Plugin_Continue;
	}
	else if (OriginCount[weapon] < 5)
	{
		OriginCount[weapon]++;
		LastOrigin[weapon] = Origin;
		return Plugin_Continue;
	}

	Origin[0] = JumpOrigin[Prisoner][0];

	float Distance = GetVectorDistance(Origin, JumpOrigin[Prisoner]);    // Time to figure out if it's dropped to X or Y, ignoring every angle based distance.

	GetEntPropVector(weapon, Prop_Data, "m_vecOrigin", Origin);
	Origin[1]       = JumpOrigin[Prisoner][1];
	float Distance2 = GetVectorDistance(Origin, JumpOrigin[Prisoner]);

	float DistanceToUse = Distance;

	if (Distance2 > Distance)
		DistanceToUse = Distance2;

	LastDistance[Prisoner] = DistanceToUse;
	return Plugin_Stop;
}

public Action CheckDroppedDeagleGuard(Handle hTimer, int weapon)
{
	if (!LRStarted)
		return Plugin_Stop;

	else if (!IsValidEntity(weapon))
		return Plugin_Stop;

	else if (GetEntityOwner(weapon) != -1)
		return Plugin_Stop;

	float Origin[3];
	GetEntPropVector(weapon, Prop_Data, "m_vecOrigin", Origin);

	if (GetVectorDistance(Origin, LastOrigin[weapon]) > 1.0)
	{
		OriginCount[weapon] = 0;
		LastOrigin[weapon]  = Origin;
		return Plugin_Continue;
	}
	else if (OriginCount[weapon] < 5)
	{
		OriginCount[weapon]++;
		LastOrigin[weapon] = Origin;
		return Plugin_Continue;
	}

	Origin[0] = JumpOrigin[Guard][0];

	float Distance = GetVectorDistance(Origin, JumpOrigin[Guard]);    // Time to figure out if it's dropped to X or Y, ignoring every angle based distance.

	GetEntPropVector(weapon, Prop_Data, "m_vecOrigin", Origin);
	Origin[1]       = JumpOrigin[Guard][1];
	float Distance2 = GetVectorDistance(Origin, JumpOrigin[Guard]);

	float DistanceToUse = Distance;

	if (Distance2 > Distance)
		DistanceToUse = Distance2;

	LastDistance[Guard] = DistanceToUse;

	return Plugin_Stop;
}

public void OnConfigsExecuted()
{
	/* Sm

	new Dir[200], MapName[50];
	get_configsdir(Dir, sizeof(Dir));

	get_mapname(MapName, sizeof(MapName));

	formatex(TPDir, sizeof(TPDir), "%s/Teleports", Dir);

	if(!dir_exists(TPDir))
	    mkdir(TPDir);

	formatex(TPDir, sizeof(TPDir), "%s/Teleports/%s.ini", Dir, MapName);

	if(!file_exists(TPDir))
	{
	    write_file(TPDir, "; Syntax for adding:");
	    write_file(TPDir, "; tX tY tZ=ctX ctY ctZ=^"DuelName^"");
	}

	*/
}

public void OnMapStart()
{
	PrecacheSound(MENU_SELECT_SOUND);
	PrecacheSound(MENU_EXIT_SOUND);

	PrecacheSound(SOUND_BLIP, true);
	g_RedBeamSprite    = PrecacheModel("materials/sprites/bomb_planted_ring.vmt");
	g_OrangeBeamSprite = PrecacheModel("materials/sprites/bomb_dropped_ring.vmt");
	g_HaloSprite       = PrecacheModel("materials/sprites/halo.vtf");
	PrecacheModel(DodgeballModel, true);
	TIMER_COUNTDOWN    = INVALID_HANDLE;
	TIMER_FAILREACTION = INVALID_HANDLE;
	TIMER_REACTION     = INVALID_HANDLE;
	for (int i = 0; i < MAXPLAYERS + 1; i++)
	{
		TIMER_BEACON[i] = INVALID_HANDLE;
	}
	TIMER_INFOMSG          = INVALID_HANDLE;
	TIMER_SLAYALL          = INVALID_HANDLE;
	TIMER_MOSTJUMPS        = INVALID_HANDLE;
	TIMER_100MILISECONDS   = INVALID_HANDLE;
	TIMER_KILLCHOKINGROUND = INVALID_HANDLE;

	g_fNextGiveLR = 0.0;

	EndLR();

	char fullpath[250];
	PrecacheSound(LR_SOUNDS_DIRECTORY);
	Format(fullpath, sizeof(fullpath), "sound/%s", LR_SOUNDS_DIRECTORY);
	AddFileToDownloadsTable(fullpath);

	// Format(fullpath, sizeof(fullpath), "sound/%s", LR_SOUNDS_S4S);
	// AddFileToDownloadsTable(fullpath);

	Format(fullpath, sizeof(fullpath), "sound/%s", LR_SOUNDS_BACKSTAB);
	AddFileToDownloadsTable(fullpath);

	CreateTimer(0.1, Timer_BeaconRacePositions, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_BeaconRacePositions(Handle hTimer)
{
	float vec[3];
	int   rgba[4];

	if (!IsVectorEmpty(raceStartOrigin))
	{
		vec = raceStartOrigin;

		vec[2] += 10;

		rgba = { 255, 255, 255, 255 };

		for (int i = 0; i < 3; i++)
		{
			rgba[i] = GetRandomInt(0, 255);
		}

		TE_SetupBeamRingPoint(vec, 128.0, 129.0, g_OrangeBeamSprite, g_HaloSprite, 0, 10, 0.2, 2.5, 0.5, rgba, 5, 0);

		TE_SendToAll();
	}

	if (!IsVectorEmpty(raceEndOrigin))
	{
		vec = raceEndOrigin;

		vec[2] += 10;

		rgba = { 255, 255, 255, 255 };

		for (int i = 0; i < 3; i++)
		{
			rgba[i] = GetRandomInt(0, 255);
		}

		TE_SetupBeamRingPoint(vec, 0.0, 128.0, g_RedBeamSprite, g_HaloSprite, 100, 0, 0.2, 2.5, 0.0, rgba, 0, 0);

		TE_SendToAll();
	}

	return Plugin_Continue;
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	// CreateNative("LR_isDodgeball", LR_isDodgeball);
	CreateNative("LR_isActive", LR_isActive);
	CreateNative("LR_GetGuard", LR_GetGuard);
	CreateNative("LR_GetPrisoner", LR_GetPrisoner);
	CreateNative("LR_isParticipant", LR_isParticipant);
	CreateNative("LR_Stop", LR_Stop);
	CreateNative("LR_FinishTimers", LR_FinishTimers);
	CreateNative("LR_isAutoBhopEnabled", LR_isAutoBhopEnabled);
	CreateNative("LR_isParachuteEnabled", LR_isParachuteEnabled);
	CreateNative("LR_CheckAnnounce", LR_CheckAnnounce);

	MarkNativeAsOptional("Gangs_GiveGangCredits");
	MarkNativeAsOptional("Gangs_AddClientDonations");
	MarkNativeAsOptional("Gangs_HasGang");
	MarkNativeAsOptional("Gangs_GetClientGangName");

	return APLRes_Success;
}
/*
public LR_isDodgeball(Handle:plugin, numParams)
{
    return view_as<bool>(LRStarted && StrContains(DuelName, "Dodgeball") != -1 ? true : false);
}
*/
public int LR_isActive(Handle plugin, int numParams)
{
	return view_as<bool>(LRStarted);
}

public int LR_GetGuard(Handle plugin, int numParams)
{
	return Guard;
}

public int LR_GetPrisoner(Handle plugin, int numParams)
{
	return Prisoner;
}

public int LR_isParticipant(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);

	return view_as<bool>(LRPart(client));
}

public int LR_Stop(Handle plugin, int numParams)
{
	EndLR(view_as<bool>(GetNativeCell(1)));

	return 0;
}

public int LR_FinishTimers(Handle plugin, int numParams)
{
	Handle hTimer = GetNativeCell(1);
	FinishTimers(hTimer);

	return 0;
}

public int LR_isAutoBhopEnabled(Handle plugin, int numParams)
{
	if (MostJumps)
		return false;

	else if (StrContains(DuelName, "Freestyle Classic") != -1)
		return false;

	return true;
}

public int LR_isParachuteEnabled(Handle plugin, int numParams)
{
	if (StrContains(DuelName, "Freestyle Classic") != -1)
		return false;

	return true;
}



public int LR_CheckAnnounce(Handle plugin, int numParams)
{
	CheckAnnounceLR();

	return 0;
}

public void Event_PlayerSpawn(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));

	SetEntityGlow(client);
	// client_cmd(id, "slot10");

	if (LRPart(client) || GetClientTeam(client) == CS_TEAM_T)
		EndLR();

	if (GetPlayerWeaponSlot(client, CS_SLOT_KNIFE) == -1)
		GivePlayerItem(client, "weapon_knife");

	StripPlayerWeapons(client);
	GivePlayerItem(client, "weapon_knife");

	// ClientCommand(client, "menuselect 9");
}

public void OnEntityCreated(int entity, const char[] Classname)
{
	if (StrEqual(Classname, "hegrenade_projectile") || StrEqual(Classname, "decoy_projectile") || StrEqual(Classname, "molotov_projectile"))
	{
		SDKHook(entity, SDKHook_SpawnPost, SpawnPost_Grenade);
	}
}

public void SpawnPost_Grenade(int entity)
{
	SDKUnhook(entity, SDKHook_SpawnPost, SpawnPost_Grenade);

	if (!LRStarted)
		return;

	else if (!IsValidEdict(entity))
		return;

	int thrower = GetEntityOwner(entity);

	if (thrower == -1)
		return;

	else if (!LRPart(thrower))
		return;

	char WeaponName[50], Weapon[50];
	GetEdictClassname(entity, WeaponName, sizeof(WeaponName));

	ReplaceString(WeaponName, sizeof(WeaponName), "_projectile", "");
	Format(Weapon, sizeof(Weapon), "weapon_%s", WeaponName);

	if (StrEqual(Weapon, "weapon_decoy") && Dodgeball)
	{
		StripPlayerWeapons(thrower);
		GivePlayerItem(thrower, Weapon);

		SetEntPropString(entity, Prop_Data, "m_iName", "Dodgeball");
		RequestFrame(Decoy_FixAngles, entity);
		SDKHook(entity, SDKHook_TouchPost, Event_DecoyTouch);
		RequestFrame(Decoy_Chicken, entity);
	}
	else
	{
		StripPlayerWeapons(thrower);
		GivePlayerItem(thrower, Weapon);
	}
}

public void Decoy_Chicken(int entity)
{
	SetEntityModel(entity, DodgeballModel);
}
/*
public Action:Spawn_Decoy(decoy)
{
    if(!LRStarted)
        return;

    else if(!IsValidEdict(decoy))
        return;

    new thrower = GetEntityOwner(decoy);

    if(thrower == -1)
        return;

    else if(!LRPart(thrower))
        return;

    Entity_SetMinMaxSize(decoy, DodgeballMins, DodgeballMaxs);
}
*/
public void Event_DecoyTouch(int decoy, int toucher)
{
	char Classname[50];
	GetEdictClassname(toucher, Classname, sizeof(Classname));
	if (!IsPlayer(toucher))
	{
		int SolidFlags = GetEntProp(toucher, Prop_Send, "m_usSolidFlags");

		if (!(SolidFlags & 0x0004))    // Buy zone and shit..
		{
			if (StrEqual(Classname, "func_breakable"))
			{
				AcceptEntityInput(decoy, "Kill");
				return;
			}
			SetEntPropString(decoy, Prop_Data, "m_iName", "Dodgeball NoKill");
		}
	}
	else
	{
		char TargetName[50];
		GetEntPropString(decoy, Prop_Data, "m_iName", TargetName, sizeof(TargetName));

		if (StrContains(TargetName, "NoKill", false) != -1)
			return;

		int thrower = GetEntityOwner(decoy);

		if (!LRPart(thrower) || thrower == toucher)
			return;

		if (toucher == Guard)
		{
			FinishHim(Guard, Prisoner);
			AcceptEntityInput(decoy, "Kill");
		}
		else if (toucher == Prisoner)
		{
			FinishHim(Prisoner, Guard);
			AcceptEntityInput(decoy, "Kill");
		}
	}
}

public Action GiveSmoke(Handle hTimer, int thrower)
{
	StripPlayerWeapons(thrower);
	GivePlayerItem(thrower, "weapon_smokegrenade");

	return Plugin_Continue;
}

public void Decoy_FixAngles(int entity)
{
	if (!IsValidEntity(entity))
		return;

	float Angles[3];
	GetEntPropVector(entity, Prop_Data, "m_angRotation", Angles);

	Angles[2] = 0.0;
	Angles[0] = 0.0;
	SetEntPropVector(entity, Prop_Data, "m_angRotation", Angles);

	RequestFrame(Decoy_FixAngles, entity);
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	if (!LRStarted)
		return Plugin_Continue;

	else if (!LRPart(client))
		return Plugin_Continue;

	if (!(buttons & IN_RELOAD))
		LastHoldReload[client] = 0.0;

	else if (LastHoldReload[client] == 0.0)
		LastHoldReload[client] = GetGameTime();

	bool HNS;

	if (StrContains(DuelName, "HNS") != -1 || StrContains(DuelName, "Night Crawler") != -1 || StrContains(DuelName, "Shark") != -1) HNS = true;

	if (!HNS && !Rambo && !Dodgeball && !Race && LastHoldReload[Guard] != 0.0 && LastHoldReload[Prisoner] != 0.0)
	{
		if (GetGameTime() - LastHoldReload[Guard] > 5.0 && GetGameTime() - LastHoldReload[Prisoner] > 5.0)
		{
			PerfectTeleport(Guard, Prisoner);
		}
	}
	if (!Duck)
		buttons &= ~IN_DUCK;

	if (!Jump)
		buttons &= ~IN_JUMP;

	if (!Zoom || Dodgeball)
		buttons &= ~IN_ATTACK2;

	if (Ring)
		buttons &= ~IN_ATTACK;

	if (Race)
	{
		float Origin[3];

		GetEntPropVector(client, Prop_Data, "m_vecOrigin", Origin);

		if (FloatAbs(Origin[2] - raceEndOrigin[2]) < 75.0)
			Origin[2] = raceEndOrigin[2];

		if (GetVectorDistance(Origin, raceEndOrigin) < RACE_DISTANCE_TO_WIN)
		{
			if (Guard == client)
			{
				FinishHim(Prisoner, Guard);
			}
			else
			{
				FinishHim(Guard, Prisoner);
			}
		}
	}

	return Plugin_Continue;
}

public Action Event_RoundStart(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	EndLR();
	g_bLRSound  = false;
	LRAnnounced = false;

	CheckAnnounceLR();

	return Plugin_Continue;
}

public Action Event_RoundEnd(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	EndLR();

	return Plugin_Continue;
}

public Action Command_C4(int client, int args)
{
	if (LRPart(client) || GetClientTeam(client) == CS_TEAM_CT || CheckCommandAccess(client, "sm_checkcommandaccess_kick", ADMFLAG_KICK))
		GivePlayerItem(client, "weapon_c4");

	return Plugin_Handled;
}

public Action Command_GiveLR(int client, int args)
{
	if (g_fNextGiveLR > GetGameTime())
	{
		UC_PrintToChat(client, "%s You must wait\x03 %.1f\x04 seconds to give LR.", PREFIX, g_fNextGiveLR - GetGameTime());
		return Plugin_Handled;
	}
	if (args == 0)
	{
		UC_PrintToChat(client, "Usage: sm_givelr <#userid|name>");
		return Plugin_Handled;
	}
	else if (!IsPlayerAlive(client))
	{
		UC_PrintToChat(client, "%s You are dead you cant give some one lastrequest", PREFIX);
		return Plugin_Handled;
	}
	else if (GetTeamAliveCount(CS_TEAM_T) != 1)
	{
		UC_PrintToChat(client, "%s you are not the last terrorist!", PREFIX);
		return Plugin_Handled;
	}
	else if (LRStarted)
	{
		UC_PrintToChat(client, "%s LR is already active!", PREFIX);
		return Plugin_Handled;
	}
	if (GetClientTeam(client) == CS_TEAM_T && IsPlayerAlive(client) && GetTeamAliveCount(CS_TEAM_T) == 1)
	{
		if (args == 1)
		{
			char arg1[32];
			GetCmdArg(1, arg1, sizeof(arg1));
			int target = FindTerroristTarget(client, arg1, false, false);

			if (target <= 0)
				return Plugin_Handled;

			int TrueChokeTimer = ChokeTimer + 10;
			g_fNextGiveLR = GetGameTime() + 20.0;
			char  clientname[64];
			char  targetname[64];
			CS_RespawnPlayer(target);
			PerfectTeleport(target, client);

			ForcePlayerSuicide(client);
			GetClientName(client, clientname, sizeof(clientname));
			GetClientName(target, targetname, sizeof(targetname));
			UC_PrintToChatAll("%s %s gave to %s the lastrequest", PREFIX, clientname, targetname);

			// This will get stolen by ForcePlayerSuicide.
			ChokeTimer = TrueChokeTimer;
		}
	}
	return Plugin_Handled;
}

public Action Listener_Say(int client, const char[] command, int args)
{
	if (CanSetHealth[client])
	{
		if (LastRequest(client))
		{
			char HealthStr[50];
			GetCmdArg(1, HealthStr, sizeof(HealthStr));

			if (IsStringNumber(HealthStr))
			{
				int Health = StringToInt(HealthStr);
				if (Health < 100)
				{
					UC_PrintToChat(client, "%s \x05You \x01can't select more than \x07100 \x01health!", PREFIX);
					HPamount = 100;
				}
				else if (Health > GetMaxHealthValue())
				{
					HPamount = GetMaxHealthValue();
					UC_PrintToChat(client, "%s \x05You \x01can't select more than \x07%i \x01health!", PREFIX, HPamount);
				}
				else
				{
					HPamount = Health;
				}

				IntToString(HPamount, SavedLRHealthArgument[client], sizeof(SavedLRHealthArgument[]));

				ShowCustomMenu(client);
			}
			else
			{
				UC_PrintToChat(client, "%s Health has to be a \x07number.", PREFIX);
			}
		}
		else
			CanSetHealth[client] = false;
	}
	if (!LRStarted)
		return Plugin_Continue;

	else if (!LRPart(client))
		return Plugin_Continue;

	else if (StrContains(DuelName, "Auto") == -1)
		return Plugin_Continue;

	char Message[50];
	GetCmdArg(1, Message, sizeof(Message));

	bool Rekt;

	char StageWord[50];
	GetUserStageWord(client, StageWord, sizeof(StageWord));

	if ((firstwrites && firstwritesmoveable && StrEquali(Message, firstchars)) || (mathcontest && mathcontestmoveable && StrEquali(Message, mathresult)) || (opposite && oppositemoveable && StrEquali(Message, OppositeWords2[oppositewords])))
		Rekt = true;

	/*
	else if((firstwrites && firstwritesmoveable && !StrEquali(Message, firstchars)) || (mathcontest && mathcontestmoveable && !StrEquali(Message, mathresult)) || (typestages && typestagesmoveable && !StrEquali(Message, StageWord)) || (opposite && oppositemoveable && !StrEquali(Message, OppositeWords2[ oppositewords ])))
	{
	    if(firstwrites && firstwritesmoveable)
	        UC_PrintToChat(client, "%s \x05Your answer is wrong!\x01 Answer: \x03%s", PREFIX, firstchars);

	    else if(typestages && typestagesmoveable)
	    {
	        UC_PrintToChat(client, "%s \x05Your answer is wrong!\x01 Answer: \x03%s", PREFIX, StageWord);
	    }

	    else if(mathcontest && mathcontestmoveable)
	        UC_PrintToChat(client, "%s \x05Your answer is wrong!\x01 Question:\x03 %i %s %i = ?", PREFIX, mathnum[0], mathplus ? "+" : "-", mathnum[1]);

	    else if(opposite && oppositemoveable)
	        UC_PrintToChat(client, "%s \x05Your answer is wrong!\x01 Question: What is the opposite of \x03%s?", PREFIX, OppositeWords1[ oppositewords ]);
	}
	*/
	if (typestages && typestagesmoveable && StrEquali(Message, StageWord))
	{
		if (typestagescount[client] == typestagesmaxstages)
			Rekt = true;

		else
		{
			typestagescount[client]++;
			GetUserStageWord(client, StageWord, sizeof(StageWord));    // Get it again since it now changed.
			UC_PrintToChat(client, "%s \x07Good job! \x01Answer: \x05%s, \x01%i \x01left.", PREFIX, StageWord, typestagesmaxstages - typestagescount[client] + 1);
		}
	}
	if (Rekt)
		FinishHim(Prisoner == client ? Guard : Prisoner, client);

	return Plugin_Continue;
}

public Action Listener_Suicide(int client, const char[] command, int args)
{
	if (!LRStarted)
		return Plugin_Continue;

	else if (!LRPart(client))
		return Plugin_Continue;

	if (Guard == client)
	{
		FinishHim(Guard, Prisoner);
	}
	else
	{
		FinishHim(Prisoner, Guard);
	}
	return Plugin_Handled;
}

public Action Command_InfoMsg(int client, int args)
{
	bool val = ShowMessage[client];

	ShowMessage[client] = SetClientInfoMessage(client, !val);
	UC_PrintToChat(client, "%s \x01Your info message status is now \x07%sabled.", PREFIX, ShowMessage[client] ? "En" : "Dis");

	return Plugin_Continue;
}

public int InfoMessageCookieMenu_Handler(int client, CookieMenuAction action, int info, char[] buffer, int maxlen)
{
	ShowInfoMessageMenu(client);

	return 0;
}

public void ShowInfoMessageMenu(int client)
{
	Handle hMenu = CreateMenu(InfoMessageMenu_Handler);

	bool infomsg = GetClientInfoMessage(client);

	char TempFormat[50];

	Format(TempFormat, sizeof(TempFormat), "Info message: %s", infomsg ? "Enabled" : "Disabled");
	AddMenuItem(hMenu, "", TempFormat);

	SetMenuExitBackButton(hMenu, true);
	SetMenuExitButton(hMenu, true);
	DisplayMenu(hMenu, client, 30);
}

public int InfoMessageMenu_Handler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_DrawItem)
	{
		return ITEMDRAW_DEFAULT;
	}
	else if (item == MenuCancel_ExitBack)
	{
		ShowCookieMenu(client);
	}
	else if (action == MenuAction_Select)
	{
		if (item == 0)
		{
			SetClientInfoMessage(client, !GetClientInfoMessage(client));
			ShowInfoMessageMenu(client);
		}
		CloseHandle(hMenu);
	}
	return 0;
}

public Action Command_StopLR(int client, int args)
{
	if (!LRStarted)
	{
		UC_PrintToChat(client, "%s Could not find a running \x07LR!", PREFIX);
		return Plugin_Handled;
	}

	EndLR();
	UC_PrintToChatAll("%s \x05%N has stopped the current \x07LR!", PREFIX, client);

	return Plugin_Handled;
}

// This command is disabled for now.
public Action Command_StopBall(int client, int args)
{
	if (!LRStarted)
	{
		UC_PrintToChat(client, "%s \x07LR \x01has not started!", PREFIX);
		return Plugin_Handled;
	}
	else if (GetClientTeam(client) != CS_TEAM_CT && !CheckCommandAccess(client, "sm_checkcommandaccess_kick", ADMFLAG_KICK))
	{
		UC_PrintToChat(client, "%s \x07Only CT \x01can use this command!", PREFIX);
		return Plugin_Handled;
	}

	int ent = -1;
	while ((ent = FindEntityByTargetname(ent, "Ball", false, true)) != -1)
	{
		int Movetype = GetEntProp(ent, Prop_Send, "movetype", 1);

		SetEntProp(ent, Prop_Send, "movetype", MOVETYPE_NONE, 1);

		TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, view_as<float>({ 0.0, 0.0, -0.1 }));

		SetEntProp(ent, Prop_Send, "movetype", Movetype, 1);

		AcceptEntityInput(ent, "Sleep");
	}
	UC_PrintToChat(client, "%s \x05%N \x01stopped all moving \x05balls!", PREFIX, client);
	return Plugin_Handled;
}

public Action Command_LRWins(int client, int args)
{
	int clientprefWins = GetClientLRWins(client);

	Handle DP = INVALID_HANDLE;

	if (clientprefWins > 0)
	{
		DP = CreateDataPack();

		WritePackCell(DP, GetClientUserId(client));
		WritePackCell(DP, clientprefWins);

		char SteamID[35];
		GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));

		WritePackString(DP, SteamID);

		char sQuery[256];

		Format(sQuery, sizeof(sQuery), "UPDATE LastRequest_players SET wins = wins + %i WHERE SteamID = \"%s\"", clientprefWins, SteamID);

		dbLRWins.Query(SQL_ChangeDatabases, sQuery, DP);
	}

	if (args == 0)
	{
		DP = CreateDataPack();

		WritePackCell(DP, GetClientUserId(client));
		WritePackCell(DP, CM_ShowWins);

		SQL_GetClientLRWins(0, DP);
	}
	else
	{
		char TargetArg[64];
		GetCmdArgString(TargetArg, sizeof(TargetArg));

		int target = FindTarget(client, TargetArg, false, false);

		if (target != -1)
		{
			DP = CreateDataPack();

			WritePackCell(DP, GetClientUserId(target));
			WritePackCell(DP, CM_ShowTargetWins);
			WritePackCell(DP, GetClientUserId(client));

			SQL_GetClientLRWins(0, DP);
		}
	}

	return Plugin_Handled;
}

public Action Command_LRTop(int client, int args)
{
	Handle DP = CreateDataPack();

	WritePackCell(DP, GetClientUserId(client));
	WritePackCell(DP, CM_ShowTopPlayers);

	SQL_GetTopPlayers(0, DP);

	return Plugin_Handled;
}

public void SQL_ChangeDatabases(Database db, DBResultSet hResults, const char[] Error, Handle DP)
{
	/* If something fucked up. */
	if (hResults == null)
		ThrowError(Error);

	else
	{
		ResetPack(DP);

		int client         = GetClientOfUserId(ReadPackCell(DP));
		int clientprefWins = ReadPackCell(DP);

		char SteamID[35];
		ReadPackString(DP, SteamID, sizeof(SteamID));

		CloseHandle(DP);
		if (client != 0)
			SetClientLRWins(client, 0);

		else
		{
			char sQuery[256];

			Format(sQuery, sizeof(sQuery), "UPDATE LastRequest_players SET wins = wins + %i WHERE SteamID = \"%s\"", clientprefWins, SteamID);

			dbLRWins.Query(SQL_Error, sQuery);
		}
	}
}
/* // sm
public Action:Command_LRManage(client, args)
{
    if(get_user_flags(id) & ADMIN_IMMUNITY)
    {
        new LRManageMenu = menu_create("\y[Last Request]\w Choose what to do:", "HandleShowLRManageMenu");

        menu_additem(LRManageMenu, "Add Teleport");
        menu_additem(LRManageMenu, "Remove Teleport");

        menu_display(id, LRManageMenu);
    }
}
public HandleShowLRManageMenu(id, LRManageMenu, item)
{
    if(item == MENU_EXIT) return;

    switch(item + 1)
    {
        case 1: ShowAddTeleportMenu(id);
        case 2: ShowRemoveTeleportMenu(id);
    }
}
public ShowAddTeleportMenu(id)
{
    new Format[64];
    new AddTeleport = menu_create("\y[Last Request]\wChoose parameters:", "HandleCmdAddTeleport");

    formatex(Format, sizeof(Format), "Origin T:\r %i %i %i", OriginT[0][id], OriginT[1][id], OriginT[2][id]);
    menu_additem(AddTeleport, Format);

    formatex(Format, sizeof(Format), "Origin CT:\r %i %i %i", OriginCT[0][id], OriginCT[1][id], OriginCT[2][id]);
    menu_additem(AddTeleport, Format);

    formatex(Format, sizeof(Format), "Duel Name:\y %s", DuelN[id]);
    menu_additem(AddTeleport, Format);

    menu_additem(AddTeleport, "\rAdd The Teleport");

    menu_display(id, AddTeleport);

    return 1;
}
public HandleCmdAddTeleport(id, AddTeleport, item)
{
    if(item == MENU_EXIT) return;

    switch(item+1)
    {
        case 1: client_cmd(id, "^"LRManage_TOrigin^"");
        case 2: client_cmd(id, "^"LRManage_CTOrigin^"");
        case 3: client_cmd(id, "^"LRManage_DuelName^"");
    }
    if(item + 1 < 3)
    {
        ShowAddTeleportMenu(id);
        return;
    }
    if(item + 1 == 3)
        return;

    new Format[100], bool:Can = true;

    for(new i;i < 3;i++)
        if(OriginT[i][id] == 0 || OriginCT[i][id] == 0) Can = false;

    if(equali(DuelN[id], "")) Can = false;

    new ReadFile[200], Token[3][200], TOrigin[200], CTOrigin[200], Duel[200], Line, Length;

    while(read_file(TPDir, Line++, ReadFile, sizeof(ReadFile), Length))
    {
        if(!read_file(TPDir, Line, ReadFile, sizeof(ReadFile), Length))
        {
            break;
        }
        if(ReadFile[0] == ';' || strcmp(ReadFile, "") == 0) continue;

        strtok(ReadFile, TOrigin, 199, Token[0], 199, '=');
        strtok(Token[0], CTOrigin, 199, Duel, 199, '=');

        remove_quotes(Duel);

        if(strcmp(Duel, DuelN[id]) == 0) Can = false;
    }
    if(Can)
    {
        formatex(Format, sizeof(Format), "\n%i %i %i=%i %i %i=^"%s^"", OriginT[0][id], OriginT[1][id], OriginT[2][id], OriginCT[0][id], OriginCT[1][id], OriginCT[2][id], DuelN[id]);
        write_file(TPDir, Format);
        client_print(id, print_chat, "Teleport was added successfully!");
        DuelN[id] = "";
    }
}
public ShowRemoveTeleportMenu(id)
{
    if(get_user_flags(id) & ADMIN_RCON)
    {
        new ReadFile[200], Token[3][200], TOrigin[200], CTOrigin[200], Duel[200], Format[500], Line, Length;
        new RemoveTeleport = menu_create("\y[Last Request]\wChoose a teleport to remove:", "HandleShowRemoveTeleportMenu");

        while(read_file(TPDir, Line++, ReadFile, sizeof(ReadFile), Length))
        {
            if(!read_file(TPDir, Line, ReadFile, sizeof(ReadFile), Length))
            {
                menu_display(id, RemoveTeleport, 0);
                break;
            }

            if(ReadFile[0] == ';' || strcmp(ReadFile, "") == 0) continue;

            strtok(ReadFile, TOrigin, 199, Token[0], 199, '=');
            strtok(Token[0], CTOrigin, 199, Duel, 199, '=');

            remove_quotes(Duel);

            new String[10];

            num_to_str(Line, String, sizeof(String));
            formatex(Format, sizeof(Format), Duel), menu_additem(RemoveTeleport, Format, String);
        }
    }
}
public HandleShowRemoveTeleportMenu(id, RemoveTeleport, item)
{
    if(item == MENU_EXIT) return;

    new data[6], Name[64], access, callback;

    menu_item_getinfo(RemoveTeleport, item, access, data, sizeof( data ), Name, sizeof(Name), callback);

    new ConfirmMenu = menu_create("\y[Last Request]\wAre you sure?", "HandleCmdRemoveTeleport");

    menu_additem(ConfirmMenu, "Yes", data);
    menu_additem(ConfirmMenu, "No");

    menu_display(id, ConfirmMenu);

}
public HandleCmdRemoveTeleport(id, ConfirmMenu, item)
{
    if(item == MENU_EXIT || item == 1) return;

    new data[6], Name[64], access, callback;

    menu_item_getinfo(ConfirmMenu, item, access, data, sizeof( data ), Name, sizeof(Name), callback);

    new ReadFile[100], Length, Line;

    while(read_file(TPDir, Line++, ReadFile, sizeof(ReadFile), Length))
    {
        if(Line == str_to_num(data))
            write_file(TPDir, "", str_to_num(data));
    }
    client_print(id, print_chat, "Teleport was removed successfully!");
    menu_destroy(ConfirmMenu);
}
public SetTOrigin(id)
{
    new Origin[3];
    get_user_origin(id, Origin);

    OriginT[0][id] = Origin[0];
    OriginT[1][id] = Origin[1];
    OriginT[2][id] = Origin[2];
    ShowAddTeleportMenu(id);
}
public SetCTOrigin(id)
{
    new Origin[3];
    get_user_origin(id, Origin);

    OriginCT[0][id] = Origin[0];
    OriginCT[1][id] = Origin[1];
    OriginCT[2][id] = Origin[2];
    ShowAddTeleportMenu(id);
}
public SetDuelName(id)	ShowDuelNames(id);
public ShowDuelNames(id)
{
    new DuelNamesMenu = menu_create("\y[Last Request]\wChoose duel to teleport:", "HandleShowDuelNames");

    menu_additem(DuelNamesMenu, "Shot4Shot Duels");
    menu_additem(DuelNamesMenu, "Custom War");
    menu_additem(DuelNamesMenu, "Fun Duels");
    menu_additem(DuelNamesMenu, "Auto Duels");

    menu_display(id, DuelNamesMenu);
}
public HandleShowDuelNames(id, DuelNamesMenu, item)
{
    if(item == MENU_EXIT) return;

    switch(item + 1)
    {
        case 1, 2: TypeDuel[id] = item, ShowWeaponDuelNames(id);
        case 3: ShowFunDuelNames(id);
        case 4: ShowAutoDuelNames(id);
    }
}

public ShowWeaponDuelNames(id) // This is to set teleportation.
{
    new Format[100];

    formatex(Format, sizeof(Format), "\y[Last Request]\w Choose teleportations for\y %s", TypeDuel[id] == 0 ? "Shot4Shot" : "Custom Duel");
    new WeaponMenu = menu_create(Format, "HandleShowWeaponDuelNames");
    menu_additem(WeaponMenu, "Deagle");
    menu_additem(WeaponMenu, "AWP");
    menu_additem(WeaponMenu, "SSG 08");
    menu_additem(WeaponMenu, "USP");
    menu_additem(WeaponMenu, "Fiveseven");
    menu_additem(WeaponMenu, "M4A1");
    menu_additem(WeaponMenu, "AK47");


    if(TypeDuel[id] == 1)
    {
        menu_additem(WeaponMenu, "HE Grenade");
        menu_additem(WeaponMenu, "\rKnife");
    }

    menu_display(id, WeaponMenu);
}
public HandleShowWeaponDuelNames(id, WeaponMenu, item)
{
    if(item == MENU_EXIT) ShowLRManageMenu(id);
    if(TypeDuel[id] == 0)
    {
        DuelN[id] = "S4S";

        return ShowAddTeleportMenu(id);
    }
    else DuelN[id] = "Custom | ";

    switch(item + 1)
    {
        case 1:	add(DuelN[id], 99, "Deagle");

        case 2:	add(DuelN[id], 99, "AWP");

        case 3:	add(DuelN[id], 99, "SSG 08");

        case 4:	add(DuelN[id], 99, "USP");

        case 5:	add(DuelN[id], 99, "Fiveseven");

        case 6:	add(DuelN[id], 99, "M4A1");

        case 7:	add(DuelN[id], 99, "AK47");

        case 8:	add(DuelN[id], 99, "HE");

        case 9: add(DuelN[id], 99, "Knife");
    }

    ShowAddTeleportMenu(id);

    return 0;
}
public ShowFunDuelNames(id)
{
    new FunDuels = menu_create("\y[Last Request]\w Choose teleportations for\y Fun Duels", "HandleShowFunDuelNames");

    menu_additem(FunDuels, "Night Crawler");
    menu_additem(FunDuels, "Shark");
    menu_additem(FunDuels, "Hide'N'Seek");
    //menu_additem(FunDuels, "Gun Toss");
    //menu_additem(FunDuels, "Shoot The Bomb");
    //menu_additem(FunDuels, "Spray");
    menu_additem(FunDuels, "Super Deagle");
    menu_additem(FunDuels, "Smoke Death Duel");
    menu_additem(FunDuels, "Soccer");
    menu_additem(FunDuels, "KZ");

    if(MapOkay)
        menu_additem(FunDuels, "Jump");

    menu_display(id, FunDuels);
}
public HandleShowFunDuelNames(id, FunDuels, item)
{
    if(item == MENU_EXIT) return;

    switch(item + 1)
    {
        case 1: DuelN[id] = "Fun | Night Crawler";

        case 2: DuelN[id] = "Fun | Shark";

        case 3: DuelN[id] = "Fun | HNS";

        case 4:	DuelN[id] = "Fun | Super Deagle";

        case 5:	DuelN[id] = "Fun | Smoke Death Duel";

        case 6:	DuelN[id] = "Fun | Soccer";

        case 7:  DuelN[id] = "Fun | KZ";

        case 8:  if(MapOkay) DuelN[id] = "Fun | Jump";
    }

    ShowAddTeleportMenu(id);
}
public ShowAutoDuelNames(id)
{
    new AutoDuels = menu_create("\y[Last Request]\w Choose teleportations for\y Auto Duels", "HandleShowAutoDuelNames");

    menu_additem(AutoDuels, "Shoot The Bomb");
    menu_additem(AutoDuels, "Spray");

    menu_display(id, AutoDuels);
}
public HandleShowAutoDuelNames(id, AutoDuels, item)
{
    if(item == MENU_EXIT) return;

    switch(item + 1)
    {
        case 1:	DuelN[id] = "Auto | Shoot The Bomb";

        case 2:	DuelN[id] = "Auto | Spray";
    }

    ShowAddTeleportMenu(id);
}
*/
public Action Event_PlayerDeath(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	if (!LRStarted)
	{
		CheckAnnounceLR();
		return Plugin_Continue;
	}

	// LRStarted

	int victim   = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(hEvent, "attacker"));

	bool victimct, norambo;

	if (GetClientTeam(victim) == CS_TEAM_CT) victimct = true;

	if (!Rambo && LRStarted) norambo = true;

	SetHudMessage(-1.0, -1.0, 5.0, 127, 255, 127);

	if (norambo)
	{
		if (GetPlayerCount() >= 5)
			SQL_AddClientLRWins(attacker);

		else
			UC_PrintToChat(attacker, "%s \x07LR \x01Wins are registered only with \x075 \x01players or above.", PREFIX);

		if (Gangs_HasGang(attacker) && GetPlayerCount() >= 5)
		{
			char GangName[64];
			Gangs_GetClientGangName(attacker, GangName, sizeof(GangName));

			Gangs_GiveGangCredits(GangName, 100);
			Gangs_AddClientDonations(attacker, 100);

			Gangs_PrintToChatGang(GangName, " \x05%N \x01has earned \x07100 \x01credits for his gang by winning an \x07LR!", attacker);
		}
	}

	ShowHudMessage(0, HUD_WIN, "%N\nhas won the duel against\n%N", victimct ? Prisoner : Guard, victimct ? Guard : Prisoner);
	UC_PrintToChatAll("%s \x05%N \x01has won the LR against \x07%N!", PREFIX, victimct ? Prisoner : Guard, victimct ? Guard : Prisoner);

	if (LRPart(victim) && norambo)
	{
		EndLR();

		if (victimct)
		{
			LRAnnounced = false;
			CheckAnnounceLR();

			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i))
					continue;

				SetClientGodmode(i);
			}
		}
	}

	return Plugin_Continue;
}

void CheckAnnounceLR()
{
	if (LRAnnounced)
		return;

	int T, CT, LastOne;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (!IsPlayerAlive(i))
			continue;

		switch (GetClientTeam(i))
		{
			case CS_TEAM_T:
			{
				LastOne = i;
				T++;
			}
			case CS_TEAM_CT:
			{
				CT++;
			}
		}
	}

	if (T == 1 && CT > 0)
	{
		Command_LR(LastOne, 0);
		
		if(g_fNextGiveLR <= GetGameTime())
		{
			if (TIMER_KILLCHOKINGROUND != INVALID_HANDLE)
			{
				CloseHandle(TIMER_KILLCHOKINGROUND);
				TIMER_KILLCHOKINGROUND = INVALID_HANDLE;
			}

			ChokeTimer = GetConVarInt(hcv_TimeMustBeginLR) + 1;
			TriggerTimer(TIMER_KILLCHOKINGROUND = CreateTimer(1.0, Timer_CheckChokeRound, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE), true);
		}

		if (!g_bLRSound)
		{
			PlaySoundToAll(LR_SOUNDS_DIRECTORY);
			g_bLRSound = true;
		}
	}
}

public Action Timer_CheckChokeRound(Handle hTimer)
{
	int client = GetRandomAlivePlayer(CS_TEAM_T);

	if(client == 0)
	{
		TIMER_KILLCHOKINGROUND = INVALID_HANDLE;

		return Plugin_Stop;
	}

	if(!LastRequest(client))
	{
		TIMER_KILLCHOKINGROUND = INVALID_HANDLE;

		return Plugin_Stop;
	}

	char Message[256];
	Call_StartForward(fw_CanStartLR);

	Call_PushCell(client);
	Call_PushStringEx(Message, sizeof(Message), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_PushCell(hTimer);

	Action Value;
	Call_Finish(Value);

	if (Value >= Plugin_Changed)
	{
		TIMER_KILLCHOKINGROUND = INVALID_HANDLE;

		return Plugin_Stop;
	}
	ChokeTimer--;

	if (ChokeTimer <= 0)
	{
		if(GetTeamClientCount(CS_TEAM_T) == 1)
		{
			PrintCenterTextAll("<font color='#FFFFFF'>Prisoner will be slayed immediately after another player joins.");

			return Plugin_Continue;
		}
		
		TIMER_KILLCHOKINGROUND = INVALID_HANDLE;

		Prisoner = GetRandomAlivePlayer(CS_TEAM_T);
		Guard    = GetRandomAlivePlayer(CS_TEAM_CT);

		if (Prisoner == 0 || Guard == 0)
			return Plugin_Stop;

		UC_PrintToChatAll("%s \x01Prisoner \x05%N \x01died for not starting \x07LR! ", PREFIX, Prisoner);

		LRStarted = true;

		FinishHim(Prisoner, Guard);

		LRStarted = false;

		return Plugin_Stop;
	}

	PrintCenterTextAll("<font color='#FFFFFF'>Prisoner must start LR within </font><font color='#FF0000'>%i</font> <font color='#FFFFFF'>seconds or he will die.</font><font color='#FF0000'></font>", ChokeTimer);

	return Plugin_Continue;
}

public Action Event_PlayerTeam(Handle hEvent, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));

	if (LRPart(client))
	{
		EndLR();
	}

	return Plugin_Continue;
}

public Action Event_PlayerHurt(Handle hEvent, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));

	if (LRPart(client))
	{
		// Blocks all forms of healing for both players ( Fresstyle is accounted here ).
		SetEntityMaxHealth(Guard, GetEntityHealth(Guard));
		SetEntityMaxHealth(Prisoner, GetEntityHealth(Prisoner));
	}

	return Plugin_Continue;
}

public void BitchSlapBackwards(int victim, int weapon, float strength)    // Stole the dodgeball tactic from https://forums.alliedmods.net/showthread.php?t=17116
{
	float origin[3], velocity[3];
	GetEntPropVector(weapon, Prop_Data, "m_vecOrigin", origin);
	GetVelocityFromOrigin(victim, origin, strength, velocity);
	velocity[2] = strength / 10.0;

	TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, velocity);
}

public Action Event_TakeDamageAlive(int victim, int& attacker, int& inflictor, float& damage, int& damagetype)
{
	if (!LRStarted)
		return Plugin_Continue;

	else if (BypassBlockers)
		return Plugin_Continue;

	else if (attacker == Prisoner && victim != Guard && GetClientTeam(victim) == CS_TEAM_CT && !Rambo && !LRPart(victim))
	{
		damage = 0.0;
		return Plugin_Changed;
	}
	
	bool suicide;

	if ((attacker != Guard && victim == Prisoner) || (attacker != Prisoner && victim == Guard)) suicide = true;    // Whether the player is killed by the guard or by himself, it is still okay to activate.

	if (suicide && LRPart(victim) && damage >= GetEntityHealth(victim) && (!IsPlayer(attacker) || attacker == victim))
	{
		if (Rambo && GetClientTeam(victim) == CS_TEAM_CT)
			Guard = victim;

		if (Guard == victim)
			FinishHim(victim, Prisoner);

		else
			FinishHim(victim, Guard);

		damage = 0.0;
		return Plugin_Changed;
	}

	if (!IsPlayer(attacker))
		return Plugin_Continue;

	if (LRPart(attacker) && LRPart(victim))
	{
		if (StrContains(DuelName, "Super Deagle") != -1)
			BitchSlapBackwards(victim, attacker, 5150.0);

		if (Dodgeball)
		{
			damage = 0.0;
			return Plugin_Changed;
		}

		if (Ring)
		{
			float Position[3], Angles[3];
			GetClientEyePosition(attacker, Position);
			GetClientEyeAngles(attacker, Angles);

			TR_TraceRayFilter(Position, Angles, MASK_SHOT, RayType_Infinite, Trace_HitVictimOnly, victim);    // Start the trace

			bool headshot = (TR_GetHitGroup() == 1);    // Get the hit group, 1 means headshot
			damage        = 0.0;

			if (headshot)
				BitchSlapBackwards(victim, attacker, 625.0);

			else
				BitchSlapBackwards(victim, attacker, 375.0);

			return Plugin_Changed;
		}
	}
	else if (!Rambo)
	{
		damage = 0.0;

		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public void Event_TakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype)
{
	if (!LRStarted)
		return;

	else if (!LRPart(victim))
		return;

	else if (!Bleed)
		return;

	else if (!IsPlayer(attacker) || attacker == victim)
		return;

	bool transfered = false;

	if(BleedTarget == attacker)
		transfered = true;

	SetEntityRenderMode(BleedTarget, RENDER_NORMAL);
	SetEntityRenderFx(BleedTarget, RENDERFX_NONE);

	SetEntityRenderColor(BleedTarget, 255, 255, 255, 255);

	if (victim == Guard)
		BleedTarget = Guard;

	else if (victim == Prisoner)
		BleedTarget = Prisoner;

	if(transfered)
		ClientCommand(BleedTarget, "play error");

	SetEntityRenderMode(BleedTarget, RENDER_GLOW);
	SetEntityRenderFx(BleedTarget, RENDERFX_GLOWSHELL);

	SetEntityRenderColor(BleedTarget, GetRandomInt(0, 255), GetRandomInt(0, 255), GetRandomInt(0, 255), 255);

	// Dealing damage for 700 whenever you shoot even if you're not bleeding is a feature, not a bug.
	TriggerTimer(TIMER_COUNTDOWN, true);

	return;
}

public Action LostDodgeball(Handle hTimer, int victim)
{
	if (!LRStarted)
		return Plugin_Continue;

	else if (!IsPlayerAlive(Prisoner) || !IsPlayerAlive(Guard))
		return Plugin_Continue;

	if (victim == Prisoner)
		FinishHim(Prisoner, Guard);

	else if (victim == Guard)
		FinishHim(Guard, Prisoner);

	return Plugin_Continue;
}

public Action Event_TraceAttack(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& ammotype, int hitbox, int hitgroup)
{
	if (!LRStarted)
		return Plugin_Continue;

	else if (!LRPart(attacker))
		return Plugin_Continue;

	int weapon = GetEntPropEnt(attacker, Prop_Data, "m_hActiveWeapon");

	char Classname[50];
	GetEdictClassname(weapon, Classname, sizeof(Classname));
	if (strncmp(Classname, "weapon_knife", 12) == 0)
	{
		if (damage < 69 && HeadShot)    // Knife should deal 76 max.
		{
			damage = 0.0;
			return Plugin_Changed;
		}
	}
	else if (hitgroup != 1 && HeadShot)
	{
		damage = 0.0;
		return Plugin_Changed;
	}

	return Plugin_Continue;
}

public bool Trace_HitVictimOnly(int entity, int contentsMask, int victim)
{
	return entity == victim;
}

public bool Trace_DontHitPlayers(int entity, int contentsMask)
{
	return !IsPlayer(entity);
}

public Action Event_ShouldInvisible(int client, int viewer)
{
	if (client == viewer)
		return Plugin_Continue;

	if (!LRStarted)
		return Plugin_Continue;

	else if (StrContains(DuelName, "Night Crawler") == -1)
		return Plugin_Continue;

	else if (GetClientTeam(client) == GetClientTeam(viewer))
		return Plugin_Continue;

	else if (Prisoner != client)
		return Plugin_Continue;

	return Plugin_Handled;
}
/*
public _Ham_TraceAttack(victim, attacker, Float:damage, Float:direction[3], traceresult, damagebits)
{

    if(get_tr2(traceresult, TR_iHitgroup) == HIT_HEAD || !HeadShot || !LRStarted)
        return HAM_IGNORED;

    return HAM_SUPERCEDE;
}
public _Ham_Touch(victim, attacker)
{
    if(!LRStarted)
        return HAM_IGNORED;

    else if(!pev_valid(victim) || !IsValidPlayer(attacker))
        return HAM_IGNORED;

    else if(!LRPart(attacker))
        return HAM_IGNORED;

    else if(!is_user_alive(attacker))
        return HAM_IGNORED;

    else if(GunToss)
        return HAM_SUPERCEDE;

    new Class[15];
    entity_get_string(victim, EV_SZ_classname, Class, sizeof(Class));
    if(equali(Class, "weaponbox"))
    {
        if(GetWeaponBoxWeaponType(victim) == SecNum || GetWeaponBoxWeaponType(victim) == PrimNum || GetWeaponBoxWeaponType(victim) == CSWeapon_C4)
            return HAM_IGNORED;
    }

    return HAM_SUPERCEDE;
}
*/
public void OnClientDisconnect(int client)
{
	if (LRPart(client))
		EndLR();
}

public void OnClientPostAdminCheck(int client)
{
	if (!IsFakeClient(client))
		SQL_GetClientLRWins(client);
}

public void OnClientPutInServer(int client)
{
	ShowMessage[client] = true;
	SDKHook(client, SDKHook_OnTakeDamageAlive, Event_TakeDamageAlive);
	SDKHook(client, SDKHook_OnTakeDamagePost, Event_TakeDamagePost);
	SDKHook(client, SDKHook_TraceAttack, Event_TraceAttack);
	SDKHook(client, SDKHook_SetTransmit, Event_ShouldInvisible);
	SDKHook(client, SDKHook_PreThink, Event_PlayerPreThink);
	SDKHook(client, SDKHook_PreThinkPost, Event_Think);
	SDKHook(client, SDKHook_PostThink, Event_Think);
	SDKHook(client, SDKHook_PostThinkPost, Event_Think);
	SDKHook(client, SDKHook_WeaponCanUse, Event_WeaponPickUp);
	SDKHook(client, SDKHook_WeaponEquipPost, Event_WeaponEquipPost);
	SDKHook(client, SDKHook_WeaponSwitch, Event_WeaponSwitch);
}

public void OnClientCookiesCached(int client)
{
	ShowMessage[client] = GetClientInfoMessage(client);
}

public Action Event_WeaponPickUp(int client, int weapon)
{
	if (!LRStarted)
		return Plugin_Continue;

	else if (!LRPart(client))
		return Plugin_Continue;

	else if(PrimNum == CSWeapon_MAX_WEAPONS)
		return Plugin_Continue;

	else if (Rambo)
		return Plugin_Continue;

	char WeaponName[32];
	GetEdictClassname(weapon, WeaponName, sizeof(WeaponName));

	if (StrEqual(WeaponName, "weapon_c4", true))
		return Plugin_Continue;
	/*
	if(StrEqual(WeaponName, "weapon_hkp2000", true))
	    WeaponName = "weapon_usp_silencer";
	if(StrEqual(WeaponName, "weapon_m4a1_silencer", true))
	    WeaponName = "weapon_m4a1";
	*/
	bool HNS;

	if (StrContains(DuelName, "HNS") != -1 || StrContains(DuelName, "Night Crawler") != -1 || StrContains(DuelName, "Shark") != -1) HNS = true;

	if (HNS && Prisoner == client && strncmp(WeaponName, "weapon_knife", 12) != 0)
	{
		AcceptEntityInput(weapon, "Kill");
		return Plugin_Handled;
	}
	if (HNS && client == Guard && strncmp(WeaponName, "weapon_knife", 12) == 0)
	{
		AcceptEntityInput(weapon, "Kill");
		return Plugin_Handled;
	}

	if (StrEqual(PrimWep, WeaponName, true) || StrEqual(SecWep, WeaponName, true))
	{
		if (!GunToss)
			return Plugin_Continue;

		else
		{
			if (GetClientButtons(client) & IN_USE || AllowGunTossPickup)
				return Plugin_Continue;

			return Plugin_Handled;
		}
	}

	int PrimDefIndex, SecDefIndex;

	if (PrimNum != CSWeapon_NONE) PrimDefIndex = CS_WeaponIDToItemDefIndex(PrimNum);
	if (SecNum != CSWeapon_NONE) SecDefIndex = CS_WeaponIDToItemDefIndex(SecNum);

	int WeaponDefIndex = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");

	if (PrimDefIndex == WeaponDefIndex || SecDefIndex == WeaponDefIndex)
	{
		if (!GunToss)
			return Plugin_Continue;

		else
		{
			if (GetClientButtons(client) & IN_USE || AllowGunTossPickup)
				return Plugin_Continue;

			return Plugin_Handled;
		}
	}
	AcceptEntityInput(weapon, "Kill");
	return Plugin_Handled;
}

public Action Event_WeaponEquipPost(int client, int weapon)    // This function is purely to solve !ws issues.
{
	if (!LRStarted)
		return Plugin_Continue;

	else if (!LRPart(client))
		return Plugin_Continue;

	char Classname[50];

	GetEntityClassname(weapon, Classname, sizeof(Classname));

	char WeaponName[32];
	GetEdictClassname(weapon, WeaponName, sizeof(WeaponName));

	if (StrEqual(WeaponName, "weapon_hkp2000", true))
		WeaponName = "weapon_usp_silencer";

	if (StrEqual(WeaponName, "weapon_m4a1_silencer", true))
		WeaponName = "weapon_m4a1";

	if (StrEqual(Classname, PrimWep))
	{
		if (Prisoner == client)
			PrisonerPrim = weapon;

		else
			GuardPrim = weapon;
	}

	else if (StrEqual(Classname, SecWep))
	{
		if (Prisoner == client)
			PrisonerSec = weapon;

		else
			GuardSec = weapon;
	}

	if (GunToss)
		DroppedDeagle[client] = false;

	return Plugin_Continue;
}

public Action Event_WeaponSwitch(int client, int weapon)    // This function is purely to solve !ws issues.
{
	// if(weapon == -1)
	// return Plugin_Continue;

	SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 1);

	return Plugin_Continue;
}

stock void EndLR(int EndTimers = true)
{
	int originalPrisoner = Prisoner;
	int originalGuard    = Guard;

	Prisoner     = -1;
	Guard        = -1;
	TruePrisoner = -1;
	TrueGuard    = -1;

	PrimWep  = "";
	PrimNum  = CSWeapon_NONE;
	SecWep   = "";
	SecNum   = CSWeapon_NONE;
	Zoom     = true;
	HeadShot = false;
	Duck     = true;
	Jump     = true;
	NoRecoil = false;

	noBeacon = false;

	if (EndTimers && LRStarted)
		FinishTimers(g_hTimer_Ignore);

	g_hTimer_Ignore = INVALID_HANDLE;

	firstwrites         = false;
	combo_started       = false;
	mathcontest         = false;
	opposite            = false;
	typestages          = false;
	firstwritesmoveable = false;
	combomoveable       = false;
	mathcontestmoveable = false;
	oppositemoveable    = false;
	typestagesmoveable  = false;
	// GuardSprayHeight = 0.0;
	// PrisonerSprayHeight = 0.0;
	Ring                = false;
	Dodgeball           = false;
	MostJumps           = false;
	mostjumpscountdown  = 0;
	mostjumpsmovable    = false;
	GuardJumps          = 0;
	PrisonerJumps       = 0;
	GunToss             = false;
	Bleed               = false;
	Race                = false;
	raceStartOrigin     = NULL_VECTOR;
	raceEndOrigin       = NULL_VECTOR;

	Rambo = false;

	GeneralTimer = 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (!IsPlayerAlive(i))
			continue;

		if (LRStarted)
		{
			SetEntityHealth(i, 100);
			SetEntityMaxHealth(i, 100);

			StripPlayerWeapons(i);
			GivePlayerItem(i, "weapon_knife");

			if (GetClientTeam(i) == CS_TEAM_CT)
				GivePlayerItem(i, "weapon_m4a1");
		}
		SetClientNoclip(i, false);
		SetClientGodmode(i, false);
		SetEntityGlow(i);

		JumpOrigin[i]   = NULL_VECTOR;
		AdjustedJump[i] = false;
		GroundHeight[i] = 0.0;
		CanSetHealth[i] = false;

		if (!IsFakeClient(i))
			SendConVarValue(i, hcv_NoSpread, "0");
	}

	ResetConVar(hcv_NoclipSpeed);

	BypassBlockers = false;

	LRStarted = false;

	if (originalPrisoner > 0 && originalGuard > 0)
	{
		int nullint;
		Call_StartForward(fw_LREnded);

		Call_PushCell(originalPrisoner);
		Call_PushCell(originalGuard);

		Call_Finish(nullint);
	}
}

void FinishTimers(Handle hTimer_Ignore = INVALID_HANDLE)
{
	if (TIMER_COUNTDOWN != INVALID_HANDLE && TIMER_COUNTDOWN != hTimer_Ignore)
	{
		CloseHandle(TIMER_COUNTDOWN);
		TIMER_COUNTDOWN = INVALID_HANDLE;
	}
	if (TIMER_INFOMSG != INVALID_HANDLE && TIMER_INFOMSG != hTimer_Ignore)
	{
		CloseHandle(TIMER_INFOMSG);
		TIMER_INFOMSG = INVALID_HANDLE;
	}

	for (int i = 1; i < MAXPLAYERS + 1; i++)
	{
		if (TIMER_BEACON[i] != INVALID_HANDLE && TIMER_BEACON[i] != hTimer_Ignore)
		{
			CloseHandle(TIMER_BEACON[i]);
			TIMER_BEACON[i] = INVALID_HANDLE;
		}
	}
	if (TIMER_FAILREACTION != INVALID_HANDLE && TIMER_FAILREACTION != hTimer_Ignore)
	{
		CloseHandle(TIMER_FAILREACTION);
		TIMER_FAILREACTION = INVALID_HANDLE;
	}
	if (TIMER_REACTION != INVALID_HANDLE && TIMER_REACTION != hTimer_Ignore)
	{
		CloseHandle(TIMER_REACTION);
		TIMER_REACTION = INVALID_HANDLE;
	}
	if (TIMER_SLAYALL != INVALID_HANDLE && TIMER_SLAYALL != hTimer_Ignore)
	{
		CloseHandle(TIMER_SLAYALL);
		TIMER_SLAYALL = INVALID_HANDLE;
	}
	if (TIMER_MOSTJUMPS != INVALID_HANDLE && TIMER_MOSTJUMPS != hTimer_Ignore)
	{
		CloseHandle(TIMER_MOSTJUMPS);
		TIMER_MOSTJUMPS = INVALID_HANDLE;
	}
	if (TIMER_100MILISECONDS != INVALID_HANDLE && TIMER_100MILISECONDS != hTimer_Ignore)
	{
		CloseHandle(TIMER_100MILISECONDS);
		TIMER_100MILISECONDS = INVALID_HANDLE;
	}
	if (TIMER_KILLCHOKINGROUND != INVALID_HANDLE && TIMER_KILLCHOKINGROUND != hTimer_Ignore)
	{
		CloseHandle(TIMER_KILLCHOKINGROUND);
		TIMER_KILLCHOKINGROUND = INVALID_HANDLE;
	}
}

public Action Command_LR(int client, int args)
{
	if (args > 0)
	{
		char Args[2][64];

		// This is to remove every character from the string.
		GetCmdArg(1, LRArguments[client], sizeof(LRArguments[]));

		GetCmdArg(2, Args[1], sizeof(Args[]));
		int iArg = StringToInt(Args[1]);
		IntToString(iArg, LRHealthArgument[client], sizeof(LRHealthArgument[]));
	}
	if (Eyal282_VoteCT_IsTreatedWarden(client))
	{
		int LastT, TCount;
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;

			else if (!IsPlayerAlive(i))
				continue;

			else if (GetClientTeam(i) != CS_TEAM_T)
				continue;

			LastT = i;
			TCount++;
		}

		if (TCount == 1)
		{
			int target = GetRandomAlivePlayer(CS_TEAM_T);
			if(LastRequest(target, false))
			{
				UC_PrintToChatAll("%s \x03%N\x01 has shown the last T the LR menu!", PREFIX, client);

				Command_LR(LastT, 0);
			}
			else
			{
				UC_PrintToChatAll("%s Error: LR cannot be started right now!", PREFIX, client);
			}
		}
	}
	if (LastRequest(client))
	{
		EndLR(false);

		FormatEx(SavedLRArguments[client], sizeof(SavedLRArguments[]), "");

		CanSetHealth[client] = false;

		if (LRArguments[client][0] != EOS)
		{
			char sDigit[16];

			FormatEx(sDigit, sizeof(sDigit), "%c", LRArguments[client][0]);
			int item = LR_GetItemFromString(sDigit);

			ReplaceStringEx(LRArguments[client], sizeof(LRArguments[]), sDigit, "");

			LR_MenuHandler(INVALID_HANDLE, MenuAction_Select, client, item);
		}
		else
		{
			Handle hMenu = CreateMenu(LR_MenuHandler);

			AddMenuItem(hMenu, "", "Fun Duels");
			AddMenuItem(hMenu, "", "Auto Duels");
			AddMenuItem(hMenu, "", "Freestyle");
			AddMenuItem(hMenu, "", "Freestyle Classic");
			AddMenuItem(hMenu, "", "Random");

			SetMenuTitle(hMenu, "%s Select your favorite duel!", MENU_PREFIX);

			SetMenuPagination(hMenu, MENU_NO_PAGINATION);
			SetMenuExitButton(hMenu, true);

			DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
		}
	}

	return Plugin_Handled;
}

public int LR_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	else if (action == MenuAction_Select)
	{
		if (!LastRequest(client))
		{
			hMenu = INVALID_HANDLE;
			return 0;
		}

		char sDigit[16];

		if (item >= 9)
			FormatEx(sDigit, sizeof(sDigit), "%c", EnglishLetters[item - 9]);

		else
			FormatEx(sDigit, sizeof(sDigit), "%i", item + 1);

		StrCat(SavedLRArguments[client], sizeof(SavedLRArguments[]), sDigit);

		switch (item + 1)
		{
			case 1: ShowFunMenu(client);

			case 2: ShowAutoMenu(client);

			case 3:
			{
				PrimWep = "";
				PrimNum  = CSWeapon_MAX_WEAPONS;
				SecWep = "weapon_knife";
				SecNum   = CSWeapon_KNIFE;
				HPamount = 100;
				BPAmmo   = -1;

				DuelName = "Freestyle";

				ChooseOpponent(client);
			}

			case 4:
			{
				PrimWep = "";
				PrimNum  = CSWeapon_MAX_WEAPONS;
				SecWep = "weapon_knife";
				SecNum   = CSWeapon_KNIFE;
				HPamount = 100;
				BPAmmo   = -1;

				DuelName = "Freestyle Classic";

				ChooseOpponent(client);
			}

			case 5:
			{
				LR_MenuHandler(INVALID_HANDLE, MenuAction_Select, client, GetRandomInt(0, 3));
			}
		}

		hMenu = INVALID_HANDLE;
	}

	return 0;
}

public void ShowWeaponMenu(int client)
{
	int Type;
	if (StrContains(DuelName, "S4S") != -1)
	{
		Type = 0;
	}
	else if (StrContains(DuelName, "Custom") != -1)
	{
		Type = 1;
	}
	char TempFormat[100];

	if (LRArguments[client][0] != EOS)
	{
		char sDigit[16];

		FormatEx(sDigit, sizeof(sDigit), "%c", LRArguments[client][0]);
		int item = LR_GetItemFromString(sDigit);

		ReplaceStringEx(LRArguments[client], sizeof(LRArguments[]), sDigit, "");

		Weapons_MenuHandler(INVALID_HANDLE, MenuAction_Select, client, item);
	}
	else
	{
		Handle hMenu = CreateMenu(Weapons_MenuHandler);

		AddMenuItem(hMenu, "", "Glock-18");
		AddMenuItem(hMenu, "", "USP");
		AddMenuItem(hMenu, "", "Dual Berretas");
		AddMenuItem(hMenu, "", "P250");
		AddMenuItem(hMenu, "", "Fiveseven");
		AddMenuItem(hMenu, "", "Tec-9");
		AddMenuItem(hMenu, "", "Deagle");
		AddMenuItem(hMenu, "", "Revolver");

		if (StrContains(DuelName, "Custom") != -1)
		{
			AddMenuItem(hMenu, "", "HE Grenade");
			AddMenuItem(hMenu, "", "Knife");
		}

		AddMenuItem(hMenu, "", "Random");

		Format(TempFormat, sizeof(TempFormat), "[Last Request] %s:", Type == 0 ? "Shot4Shot" : "Custom Duel");
		SetMenuTitle(hMenu, TempFormat);
		DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
	}
}

public int Weapons_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	else if (action == MenuAction_Select)
	{
		if (!LastRequest(client))
		{
			hMenu = INVALID_HANDLE;
			return 0;
		}
		int Type;    // S4S = 0, Custom = 1
		PrimNum = CSWeapon_NONE;
		SecNum  = CSWeapon_NONE;

		if (StrContains(DuelName, "S4S") != -1)
		{
			Type = 0;
		}
		else if (StrContains(DuelName, "Custom") != -1)
		{
			Type = 1;
		}

		char sDigit[16];

		if (item >= 9)
			FormatEx(sDigit, sizeof(sDigit), "%c", EnglishLetters[item - 9]);

		else
			FormatEx(sDigit, sizeof(sDigit), "%i", item + 1);

		StrCat(SavedLRArguments[client], sizeof(SavedLRArguments[]), sDigit);

		switch (item + 1)
		{
			case 1:
			{
				DuelName = "S4S | Glock-18";
				PrimWep  = "weapon_glock";
				PrimNum  = CSWeapon_GLOCK;
			}
			case 2:
			{
				DuelName = "S4S | USP";
				PrimWep  = "weapon_usp_silencer";
				PrimNum  = CSWeapon_USP_SILENCER;
			}
			case 3:
			{
				DuelName = "S4S | Dual-Berretas";
				PrimWep  = "weapon_elite";
				PrimNum  = CSWeapon_ELITE;
			}
			case 4:
			{
				DuelName = "S4S | P250";
				PrimWep  = "weapon_p250";
				PrimNum  = CSWeapon_P250;
			}
			case 5:
			{
				DuelName = "S4S | Fiveseven";
				PrimWep  = "weapon_fiveseven";
				PrimNum  = CSWeapon_FIVESEVEN;
			}
			case 6:
			{
				DuelName = "S4S | Tec-9";
				PrimWep  = "weapon_tec9";
				PrimNum  = CSWeapon_TEC9;
			}
			case 7:
			{
				DuelName = "S4S | Deagle";
				PrimWep  = "weapon_deagle";
				PrimNum  = CSWeapon_DEAGLE;
			}
			case 8:
			{
				DuelName = "S4S | Revolver";
				PrimWep  = "weapon_revolver";
				PrimNum  = CSWeapon_REVOLVER;
			}

			case 9:
			{
				if (Type == 1)
				{
					DuelName = "S4S | HE Grenade";
					PrimWep  = "weapon_hegrenade";
					PrimNum  = CSWeapon_HEGRENADE;
				}
				else
				{
					Weapons_MenuHandler(INVALID_HANDLE, MenuAction_Select, client, GetRandomInt(0, 7));
				}
			}

			case 10:
			{
				DuelName = "S4S | Knife";
				PrimWep  = "weapon_knife";
				PrimNum  = CSWeapon_KNIFE;
			}

			case 11:
			{
				Weapons_MenuHandler(INVALID_HANDLE, MenuAction_Select, client, GetRandomInt(0, 9));
			}
		}
		if (Type == 0)
		{
			HPamount = 100;
			BPAmmo   = 0;
			Vest     = 2;
			SecWep   = "weapon_knife";
			SecNum   = CSWeapon_KNIFE;
			ChooseRules(client);
		}
		else if (Type == 1)
		{
			ShowCustomMenu(client);
			if (PrimNum == CSWeapon_HEGRENADE)
				BPAmmo = 1;

			else
				BPAmmo = 10000;
		}
	}

	hMenu = INVALID_HANDLE;

	return 0;
}

public void ShowCustomMenu(int client)
{
	CanSetHealth[client] = true;

	if (LRHealthArgument[client][0] != EOS && StringToInt(LRHealthArgument[client]) > 0)
		HPamount = StringToInt(LRHealthArgument[client]);

	if (LRArguments[client][0] != EOS)
	{
		char sDigit[16];

		FormatEx(sDigit, sizeof(sDigit), "%c", LRArguments[client][0]);

		int item = LR_GetItemFromString(sDigit);

		ReplaceStringEx(LRArguments[client], sizeof(LRArguments[]), sDigit, "");

		Custom_MenuHandler(INVALID_HANDLE, MenuAction_Select, client, item);
	}
	else
	{
		char TempFormat[100], WeaponName[50];

		Handle hMenu = CreateMenu(Custom_MenuHandler);

		Format(TempFormat, sizeof(TempFormat), "Health: %i", HPamount);
		AddMenuItem(hMenu, "", TempFormat);

		Format(WeaponName, sizeof(WeaponName), DuelName);
		ReplaceString(WeaponName, sizeof(WeaponName), "S4S | ", "");

		Format(TempFormat, sizeof(TempFormat), "Weapon: %s", WeaponName);
		AddMenuItem(hMenu, "", TempFormat);

		AddMenuItem(hMenu, "", "Random Health");

		AddMenuItem(hMenu, "", "Begin duel!");

		SetMenuTitle(hMenu, "%s Custom Duel:", MENU_PREFIX);
		DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
	}
}

public int Custom_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	else if (action == MenuAction_Select)
	{
		if (!LastRequest(client))
		{
			hMenu = INVALID_HANDLE;
			return 0;
		}

		char sDigit[2];

		if (item >= 9)
			FormatEx(sDigit, sizeof(sDigit), "%c", EnglishLetters[item - 9]);

		else
			FormatEx(sDigit, sizeof(sDigit), "%i", item + 1);

		StrCat(SavedLRArguments[client], sizeof(SavedLRArguments[]), sDigit);

		switch (item + 1)
		{
			case 1:
			{
				UC_PrintToChat(client, "%s Please write in the chat the \x07amount \x01of health you want.", PREFIX);

				ShowCustomMenu(client);
			}

			case 2:
			{
				DuelName = "Custom | ";
				ShowWeaponMenu(client);
			}

			case 3:
			{
				HPamount = GetRandomInt(100, GetMaxHealthValue());
				ShowCustomMenu(client);
			}
			case 4:
			{
				ReplaceString(DuelName, sizeof(DuelName), "S4S | ", "Custom | ");

				Vest = 2;
				ChooseRules(client);
			}
		}

		if (item + 1 != 1)
			CanSetHealth[client] = false;
	}

	hMenu = INVALID_HANDLE;

	return 0;
}

public void ChooseRules(int client)
{
	if (LRArguments[client][0] != EOS)
	{
		char sDigit[16];

		FormatEx(sDigit, sizeof(sDigit), "%c", LRArguments[client][0]);
		int item = LR_GetItemFromString(sDigit);

		ReplaceStringEx(LRArguments[client], sizeof(LRArguments[]), sDigit, "");

		Rules_MenuHandler(INVALID_HANDLE, MenuAction_Select, client, item);
	}
	else
	{
		int Type;    // S4S = 0, Custom = 1

		if (StrContains(DuelName, "S4S") != -1)
		{
			Type = 0;
		}
		else if (StrContains(DuelName, "Custom") != -1)
		{
			Type = 1;
		}

		char TempFormat[100];

		Handle hMenu = CreateMenu(Rules_MenuHandler);

		Format(TempFormat, sizeof(TempFormat), "%s: %sllowed", PrimNum == CSWeapon_KNIFE ? "Right Stab" : "Zoom", Zoom ? "A" : "Disa");
		AddMenuItem(hMenu, "", TempFormat);

		switch (Vest)
		{
			case 0: Format(TempFormat, sizeof(TempFormat), "Vest: Nothing");
			case 1: Format(TempFormat, sizeof(TempFormat), "Vest: Yes");
			default: Format(TempFormat, sizeof(TempFormat), "Vest: And Helmet");
		}
		AddMenuItem(hMenu, "", TempFormat);

		Format(TempFormat, sizeof(TempFormat), "%s: %s", PrimNum == CSWeapon_KNIFE ? "Backstab" : "Headshot", !HeadShot ? "Free" : "Only");
		AddMenuItem(hMenu, "", TempFormat);

		if (Type == 1)
		{
			Format(TempFormat, sizeof(TempFormat), "Jump: %sllowed", Jump ? "A" : "Disa");
			AddMenuItem(hMenu, "", TempFormat);

			Format(TempFormat, sizeof(TempFormat), "Duck: %sllowed", Duck ? "A" : "Disa");
			AddMenuItem(hMenu, "", TempFormat);
		}

		AddMenuItem(hMenu, "", "Random Rules");

		AddMenuItem(hMenu, "", "Select Opponent");

		SetMenuTitle(hMenu, "%s Select battle rules:", MENU_PREFIX);
		DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
	}
}

public int Rules_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	int Type;    // S4S = 0, Custom = 1

	if (StrContains(DuelName, "S4S") != -1)
	{
		Type = 0;
	}
	else if (StrContains(DuelName, "Custom") != -1)
	{
		Type = 1;
	}
	else
		Type = 2;

	if (action == MenuAction_Select)
	{
		if (!LastRequest(client))
			return 0;

		char sDigit[16];

		if (item >= 9)
			FormatEx(sDigit, sizeof(sDigit), "%c", EnglishLetters[item - 9]);

		else
			FormatEx(sDigit, sizeof(sDigit), "%i", item + 1);

		StrCat(SavedLRArguments[client], sizeof(SavedLRArguments[]), sDigit);

		switch (item + 1)
		{
			case 1:
			{
				Zoom = !Zoom;

				if (HPamount > GetMaxHealthValue())
				{
					HPamount = GetMaxHealthValue();
					UC_PrintToChat(client, "%s Duel \x07HP \x01was set to \x05%i \x01to avoid never ending duel.", PREFIX, HPamount);
				}
			}
			case 2:
			{
				Vest++;

				if (Vest == 3)
					Vest = 0;
			}
			case 3:
			{
				HeadShot = !HeadShot;

				if (HPamount > GetMaxHealthValue())
				{
					HPamount = GetMaxHealthValue();
					UC_PrintToChat(client, "%s Duel \x07HP \x01was set to \x05%i to avoid never ending duel.", PREFIX, HPamount);
				}
			}
			case 4:
			{
				if (Type == 0)
				{
					SetRandomRules(Type);
				}
				else
				{
					Jump = !Jump;
				}
			}
			case 5:
			{
				if (Type == 0)
				{
					ChooseOpponent(client);
				}
				else
				{
					Duck = !Duck;
				}
			}
			case 6:
			{
				SetRandomRules(Type);
			}
			case 7: ChooseOpponent(client);
		}

		if ((Type == 0 && item + 1 != 5) || (Type == 1 && item + 1 != 7)) ChooseRules(client);    // This is to return to rules menu except when player decides to begin the duel.
	}

	return 0;
}

public void ShowFunMenu(int client)
{
	if (LRArguments[client][0] != EOS)
	{
		char sDigit[16];

		FormatEx(sDigit, sizeof(sDigit), "%c", LRArguments[client][0]);
		int item = LR_GetItemFromString(sDigit);

		ReplaceStringEx(LRArguments[client], sizeof(LRArguments[]), sDigit, "");

		Fun_MenuHandler(INVALID_HANDLE, MenuAction_Select, client, item);
	}
	else
	{
		Handle hMenu = CreateMenu(Fun_MenuHandler);

		AddMenuItem(hMenu, "S4S", "Shot4Shot Duels");
		AddMenuItem(hMenu, "Custom", "Custom War");
		AddMenuItem(hMenu, "Rambo", "RAMBO REBEL");
		AddMenuItem(hMenu, "NightCrawler", "Night Crawler ( Invisible )");
		AddMenuItem(hMenu, "HNS", "Hide'N'Seek");
		AddMenuItem(hMenu, "HNR", "Slow HnR");
		AddMenuItem(hMenu, "SuperDeagle", "Super Deagle");
		AddMenuItem(hMenu, "NegevNoSpread", "Negev No Spread");
		AddMenuItem(hMenu, "GunToss", "Gun Toss");
		AddMenuItem(hMenu, "Dodgeball", "Dodgeball");
		AddMenuItem(hMenu, "Backstabs", "Backstabs");

		if(LibraryExists("CrossbowAPI"))
			AddMenuItem(hMenu, "Crossbow", "Crossbow");

		AddMenuItem(hMenu, "Random", "Random");

		SetMenuTitle(hMenu, "%s Fun Duels:", MENU_PREFIX);
		DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
	}
}

public int Fun_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	else if (action == MenuAction_Select)
	{
		if (!LastRequest(client))
		{
			hMenu = INVALID_HANDLE;
			return 0;
		}
		PrimWep  = "";
		PrimNum  = CSWeapon_NONE;
		SecWep   = "";
		SecNum   = CSWeapon_NONE;
		Vest     = 0;
		Zoom     = true;
		HeadShot = false;
		Jump     = true;
		Duck     = true;
		NoRecoil = false;

		int T;

		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;

			if (GetClientTeam(i) == CS_TEAM_T)
				T++;
		}

		char sDigit[16];

		if (item >= 9)
			FormatEx(sDigit, sizeof(sDigit), "%c", EnglishLetters[item - 9]);

		else
			FormatEx(sDigit, sizeof(sDigit), "%i", item + 1);

		StrCat(SavedLRArguments[client], sizeof(SavedLRArguments[]), sDigit);

		char info[64];
		GetMenuItem(hMenu, item, info, sizeof(info));

		if(StrEqual(info, "S4S", false))
		{
			DuelName = "S4S";
			ShowWeaponMenu(client);
		}
		else if(StrEqual(info, "Custom", false))
		{
			PrimWep                       = "weapon_m4a1";
			PrimNum                       = CSWeapon_M4A1;
			Zoom                          = true;
			HeadShot                      = false;
			BPAmmo                        = 10000;
			HPamount                      = 1000;
			SavedLRHealthArgument[client] = "1000";
			Vest                          = 2;
			DuelName                      = "S4S | M4A1";
			ShowCustomMenu(client);
		}
		else if(StrEqual(info, "Rambo", false))
		{
			DuelName = "RAMBO REBEL";

			if (LastRequest(client))
			{
				if (T >= 3)
				{
					Prisoner  = client;
					LRStarted = true;
					Vest      = 2;

					// OpenAllCells();
					FinishTimers();
					StartRambo();

					// BAR COLOR!!!
					UC_PrintToChatAll("%s \x01%s \x07%N \x01vs \x07%N", PREFIX, DuelName, Prisoner, Guard);
					UC_PrintToChatAll("%s \x01%s \x07%N \x01vs \x07%N", PREFIX, DuelName, Prisoner, Guard);
					UC_PrintToChatAll("%s \x01%s \x07%N \x01vs \x07%N", PREFIX, DuelName, Prisoner, Guard);
				}
				else
					UC_PrintToChat(client, "%s You can only start Rambo when there are \x073 \x01or more total terror.", PREFIX);
			}

			return 0;
		}
		else if(StrEqual(info, "NightCrawler", false))
		{
			DuelName = "Fun | Night Crawler";
			PrimWep  = "weapon_m4a1";
			PrimNum  = CSWeapon_M4A1;
			SecWep   = "weapon_knife";
			SecNum   = CSWeapon_KNIFE;
			BPAmmo   = 10000;
			HPamount = 100;
		}
		else if(StrEqual(info, "HNS", false))
		{
			DuelName = "Fun | HNS";
			SecWep   = "weapon_knife";
			SecNum   = CSWeapon_KNIFE;

			noBeacon = true;
		}
		else if(StrEqual(info, "HNR", false))
		{
			DuelName = "Fun | Slow HnR";
			PrimWep  = "weapon_ssg08";
			PrimNum  = CSWeapon_SSG08;

			SecWep = "weapon_knife";
			SecNum = CSWeapon_KNIFE;

			HPamount = 30000;
			BPAmmo   = 10000;
		}
		else if(StrEqual(info, "SuperDeagle", false))
		{
			DuelName = "Fun | Super Deagle";
			HPamount = 500;
			BPAmmo   = 10000;
			PrimWep  = "weapon_deagle";
			PrimNum  = CSWeapon_DEAGLE;
		}
		else if(StrEqual(info, "NegevNoSpread", false))
		{
			DuelName = "Fun | Negev No Recoil";
			NoRecoil = true;
			HPamount = 1000;
			BPAmmo   = 10000;
			PrimWep  = "weapon_negev";
			PrimNum  = CSWeapon_NEGEV;
		}
		else if(StrEqual(info, "GunToss", false))
		{
			DuelName = "Fun | Gun Toss";
			HPamount = 100;
			PrimWep  = "weapon_deagle";
			PrimNum  = CSWeapon_DEAGLE;
			SecWep   = "weapon_knife";
			SecNum   = CSWeapon_KNIFE;
			BPAmmo   = 0;
		}
		else if(StrEqual(info, "Dodgeball", false))
		{
			DuelName = "Fun | Dodgeball";
			HPamount = 100;
			BPAmmo   = 1;
			PrimWep  = "weapon_decoy";
			PrimNum  = CSWeapon_DECOY;
		}
		else if(StrEqual(info, "Backstabs", false))
		{
			DuelName = "Fun | Backstabs";
			HPamount = 100;
			Vest     = 0;
			PrimWep  = "weapon_knife";
			PrimNum  = CSWeapon_KNIFE;
		}
		else if(StrEqual(info, "Race", false))
		{
			DuelName = "Fun | Race";
			HPamount = 100;
			PrimNum  = CSWeapon_NONE;

			noBeacon = true;
		}
		else if(StrEqual(info, "Crossbow", false))
		{
			DuelName = "Fun | Crossbow";
			HPamount = 750;
			BPAmmo = 10000;
			Vest     = 0;
			PrimWep  = "weapon_m4a1";
			PrimNum  = CSWeapon_M4A1;
			// The crossbow is given in "OnShouldPlayerHaveCrossbow"
		}
		else if(StrEqual(info, "Random", false))
		{
			int lastItem;

			while(GetMenuItem(hMenu, lastItem++, info, sizeof(info)))
			{
				// Do nothing here, just wait until last item.
			}

			Fun_MenuHandler(hMenu, MenuAction_Select, client, GetRandomInt(0, lastItem-1));
			return 0;
		}

		bool HNS;

		if (StrContains(DuelName, "HNS") != -1 || StrContains(DuelName, "Night Crawler") != -1 || StrContains(DuelName, "Shark") != -1) HNS = true;

		if (HNS)
			ChooseSeeker(client);    // Basically reversing Guard and Prisoner.

		else if (item + 1 > 3)
			ChooseOpponent(client);
	}

	hMenu = INVALID_HANDLE;

	return 0;
}
public void ChooseSeeker(int client)
{
	if (LRArguments[client][0] != EOS)
	{
		char sDigit[16];

		FormatEx(sDigit, sizeof(sDigit), "%c", LRArguments[client][0]);
		int item = LR_GetItemFromString(sDigit);

		ReplaceStringEx(LRArguments[client], sizeof(LRArguments[]), sDigit, "");

		Seeker_MenuHandler(INVALID_HANDLE, MenuAction_Select, client, item);
	}
	else
	{
		Handle hMenu = CreateMenu(Seeker_MenuHandler);

		AddMenuItem(hMenu, "", "You");

		AddMenuItem(hMenu, "", "Guard");

		AddMenuItem(hMenu, "", "Random");

		SetMenuTitle(hMenu, "%s Choose who will seek:", MENU_PREFIX);
		DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
	}
}

public int Seeker_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	if (action == MenuAction_Select)
	{
		if (!LastRequest(client))
		{
			hMenu = INVALID_HANDLE;
			return 0;
		}

		char sDigit[16];

		if (item >= 9)
			FormatEx(sDigit, sizeof(sDigit), "%c", EnglishLetters[item - 9]);

		else
			FormatEx(sDigit, sizeof(sDigit), "%i", item + 1);

		StrCat(SavedLRArguments[client], sizeof(SavedLRArguments[]), sDigit);

		if (item == 2)
			item = GetRandomInt(0, 1);

		TSeeker  = item == 0 ? true : false;
		PrimNum  = CSWeapon_NONE;
		SecNum   = CSWeapon_NONE;
		HPamount = 100;
		BPAmmo   = -1;

		ChooseOpponent(client);
	}

	hMenu = INVALID_HANDLE;

	return 0;
}

public void ChooseRaceCoords(int client)
{
	Handle hMenu = CreateMenu(Race_MenuHandler);

	AddMenuItem(hMenu, "", "Start Position");

	AddMenuItem(hMenu, "", "End Position");

	AddMenuItem(hMenu, "", "Choose Opponent");

	SetMenuTitle(hMenu, "%s Choose race positions:", MENU_PREFIX);
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public int Race_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	if (action == MenuAction_Select)
	{
		if (!LastRequest(client))
		{
			hMenu = INVALID_HANDLE;
			return 0;
		}

		switch (item)
		{
			case 0:
			{
				GetEntPropVector(client, Prop_Data, "m_vecOrigin", raceStartOrigin);

				ChooseRaceCoords(client);
			}

			case 1:
			{
				GetEntPropVector(client, Prop_Data, "m_vecOrigin", raceEndOrigin);

				ChooseRaceCoords(client);
			}

			case 2:
			{
				if (IsVectorEmpty(raceStartOrigin))
				{
					UC_PrintToChat(client, "Error: No start position found!");

					ChooseRaceCoords(client);
				}
				else if (IsVectorEmpty(raceEndOrigin))
				{
					UC_PrintToChat(client, "Error: No end position found!");

					ChooseRaceCoords(client);
				}
				else if (GetVectorDistance(raceStartOrigin, raceEndOrigin) < 256.0)
				{
					UC_PrintToChat(client, "Error: Start and End positions are too close!");

					ChooseRaceCoords(client);
				}
				else
					ChooseOpponent(client);
			}
		}
	}

	hMenu = INVALID_HANDLE;

	return 0;
}

public void ShowAutoMenu(int client)
{
	if (LRArguments[client][0] != EOS)
	{
		char sDigit[16];

		FormatEx(sDigit, sizeof(sDigit), "%c", LRArguments[client][0]);
		int item = LR_GetItemFromString(sDigit);

		ReplaceStringEx(LRArguments[client], sizeof(LRArguments[]), sDigit, "");

		Auto_MenuHandler(INVALID_HANDLE, MenuAction_Select, client, item);
	}
	else
	{
		Handle hMenu = CreateMenu(Auto_MenuHandler);

		AddMenuItem(hMenu, "FirstWrites", "First Writes");
		AddMenuItem(hMenu, "ComboContest", "Combo Contest");
		AddMenuItem(hMenu, "MathContest", "Math Contest");
		AddMenuItem(hMenu, "MostJumps", "Most Jumps");
		AddMenuItem(hMenu, "Race", "Race");
		AddMenuItem(hMenu, "Random", "Random");

		SetMenuTitle(hMenu, "%s Automatic Contests:", MENU_PREFIX);
		DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
	}
}

public int Auto_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	if (action == MenuAction_Select)
	{
		if (!LastRequest(client))
		{
			hMenu = INVALID_HANDLE;
			return 0;
		}
		EndLR(false);
		HPamount = GetMaxHealthValue();

		char info[32];
		GetMenuItem(hMenu, item, info, sizeof(info));

		char sDigit[16];

		if (item >= 9)
			FormatEx(sDigit, sizeof(sDigit), "%c", EnglishLetters[item - 9]);

		else
			FormatEx(sDigit, sizeof(sDigit), "%i", item + 1);

		StrCat(SavedLRArguments[client], sizeof(SavedLRArguments[]), sDigit);

		if(StrEqual(info, "FirstWrites", false))
		{
			DuelName = "Auto | First Writes";
		}
		else if(StrEqual(info, "ComboContest", false))
		{
			DuelName = "Auto | Combo Contest";
		}
		else if(StrEqual(info, "MathContest", false))
		{
			DuelName = "Auto | Math Contest";
		}
		else if(StrEqual(info, "MostJumps", false))
		{
			DuelName = "Auto | Most Jumps";
		}
		else if(StrEqual(info, "Race", false))
		{
			DuelName = "Auto | Race";
			ChooseRaceCoords(client);
			return 0;
		}
		else if(StrEqual(info, "Random", false))
		{
			int lastItem;

			while(GetMenuItem(hMenu, lastItem++, info, sizeof(info)))
			{
				// Do nothing here, just wait until last item.
			}

			Auto_MenuHandler(hMenu, MenuAction_Select, client, GetRandomInt(0, lastItem-1));
			return 0;
		}

		ChooseOpponent(client);
	}

	hMenu = INVALID_HANDLE;

	return 0;
}

public void ChooseOpponent(int client)
{
	if (HPamount > GetMaxHealthValue())
	{
		HPamount = GetMaxHealthValue();
		UC_PrintToChat(client, "%s Duel \x07HP \x01was set to \x05%i \x01to avoid never ending duel.", PREFIX, HPamount);
	}
	char   UID[20], Name[64];
	Handle hMenu = CreateMenu(Opponent_MenuHandler);

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (!IsPlayerAlive(i))
			continue;

		else if (GetClientTeam(i) != CS_TEAM_CT)
			continue;

		IntToString(GetClientUserId(i), UID, sizeof(UID));
		GetClientName(i, Name, sizeof(Name));
		AddMenuItem(hMenu, UID, Name);
	}

	SetMenuTitle(hMenu, "%s Select a Guard to battle against.", MENU_PREFIX);

	if (LRArguments[client][0] != EOS)
	{
		char sDigit[16];

		FormatEx(sDigit, sizeof(sDigit), "%c", LRArguments[client][0]);
		int item = LR_GetItemFromString(sDigit);

		ReplaceStringEx(LRArguments[client], sizeof(LRArguments[]), sDigit, "");

		Opponent_MenuHandler(hMenu, MenuAction_Select, client, item);

		CloseHandle(hMenu);
	}
	else
	{
		DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
	}
}

public int Opponent_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	if (action == MenuAction_Select)
	{
		if (!LastRequest(client))
		{
			hMenu = INVALID_HANDLE;
			return 0;
		}
		char UID[20];
		GetMenuItem(hMenu, item, UID, sizeof(UID));

		int target = GetClientOfUserId(StringToInt(UID));

		if (LastRequest(client) && target != 0)
		{
			char sDigit[16];

			if (item >= 9)
				FormatEx(sDigit, sizeof(sDigit), "%c", EnglishLetters[item - 9]);

			else
				FormatEx(sDigit, sizeof(sDigit), "%i", item + 1);

			StrCat(SavedLRArguments[client], sizeof(SavedLRArguments[]), sDigit);

			Guard = target;

			Prisoner = client;

			LRStarted = true;
			// OpenAllCells();
			FinishTimers();
			StartDuel();

			UC_PrintToChatAll("%s \x01%s \x07%N \x01vs \x07%N ", PREFIX, DuelName, Prisoner, Guard);
		}
		else ChooseOpponent(client);
	}

	hMenu = INVALID_HANDLE;

	return 0;
}

public void OpenAllCells()
{
	int ent = -1;

	while ((ent = FindEntityByClassname(ent, "func_button")) != INVALID_ENT_REFERENCE)
		AcceptEntityInput(ent, "Press");
}

public void StartRambo()
{
	Rambo = true;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (!IsPlayerAlive(i))
			continue;

		else if (GetClientTeam(i) != CS_TEAM_CT)
			continue;

		StripPlayerWeapons(i);
		SetEntityHealth(i, 100);
		SetClientArmor(i, Vest == 0 ? 0 : 100, Vest == 2 ? 1 : 0);
		int weapon = GivePlayerItem(i, "weapon_m4a1");
		SetClientAmmo(i, weapon, 999);
	}

	StripPlayerWeapons(Prisoner);
	int weapon = GivePlayerItem(Prisoner, "weapon_negev");

	SetClientAmmo(Prisoner, weapon, 999);
	SetEntityHealth(Prisoner, 250);

	SetClientArmor(Prisoner, Vest == 0 ? 0 : 100, Vest == 2 ? 1 : 0);

	TIMER_INFOMSG = CreateTimer(0.1, Timer_ShowToAll, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

	TIMER_SLAYALL = CreateTimer(420.0, SlayAllParts, _, TIMER_FLAG_NO_MAPCHANGE);

	UC_PrintToChatAll("%s All \x05participants \x01will be slayed in \x077 \x01minutes!", PREFIX);
}

public Action JBPack_OnShouldSpawnWeapons(int client) 
{
	if(!LRPart(client))
		return Plugin_Continue;

	else if(PrimNum == CSWeapon_MAX_WEAPONS)
		return Plugin_Continue;

	return Plugin_Handled;
}

public void StartDuel()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		ShowMessage[i] = true;
	}
	int ent = -1;

	while ((ent = FindEntityByClassname(ent, "player_weaponstrip")) != -1)
		AcceptEntityInput(ent, "Kill");

	AllowGunTossPickup = true;
	SetClientGodmode(Guard);
	SetClientNoclip(Guard);

	SetClientSpeed(Guard);
	SetClientSpeed(Prisoner);

	StripPlayerWeapons(Guard);
	StripPlayerWeapons(Prisoner);

	SetEntityHealth(Guard, HPamount);
	SetEntityHealth(Prisoner, HPamount);

	SetEntityMaxHealth(Guard, HPamount);
	SetEntityMaxHealth(Prisoner, HPamount);

	SetClientArmor(Guard, Vest == 0 ? 0 : 100, Vest == 2 ? 1 : 0);
	SetClientArmor(Prisoner, Vest == 0 ? 0 : 100, Vest == 2 ? 1 : 0);

	if (PrimNum != CSWeapon_NONE && PrimNum != CSWeapon_MAX_WEAPONS)    // ID 0 is also invalid.
	{
		do    // Don't fookin ask how I get these bugs, I just do
		{
			GuardPrim = GivePlayerItem(Guard, PrimWep);
		}
		while (GuardPrim == -1);

		do
		{
			PrisonerPrim = GivePlayerItem(Prisoner, PrimWep);
		}
		while (PrisonerPrim == -1);

		if (PrimNum != CSWeapon_KNIFE && PrimNum != CSWeapon_C4)
		{
			SetClientAmmo(Guard, GuardPrim, BPAmmo);
			SetClientAmmo(Prisoner, PrisonerPrim, BPAmmo);
		}
	}
	if (SecNum != CSWeapon_NONE)
	{
		GuardSec    = GivePlayerItem(Guard, SecWep);
		PrisonerSec = GivePlayerItem(Prisoner, SecWep);
		if (SecNum != CSWeapon_KNIFE && SecNum != CSWeapon_C4)
		{
			SetClientAmmo(Guard, GuardSec, BPAmmo);
			SetClientAmmo(Prisoner, PrisonerSec, BPAmmo);
		}
	}

	ContinueStartDuel();    // To make things more organized :)
}

public void ContinueStartDuel()
{
	if (NoRecoil)
	{
		SendConVarValue(Guard, hcv_NoSpread, "1");
		SendConVarValue(Prisoner, hcv_NoSpread, "1");
	}

	if (StrContains(DuelName, "Freestyle") != -1)
	{
		SetEntityMaxHealth(Guard, 1);
		SetEntityMaxHealth(Prisoner, 1000);

		UC_PrintToChatAll("Frestyle allows you to heal up to 1,000 HP and pick up weapons.");
		UC_PrintToChatAll("You will not be able to heal if take damage!");
	}
	else if (StrContains(DuelName, "S4S") != -1)
	{
		RequestFrame(ResetClipAndFrame, 0);

		PlaySoundToAll(LR_SOUNDS_BACKSTAB);
	}

	else if (StrContains(DuelName, "Dodgeball") != -1)
	{
		Dodgeball = true;

		SetEntProp(Guard, Prop_Data, "m_CollisionGroup", 5);
		SetEntProp(Prisoner, Prop_Data, "m_CollisionGroup", 5);
	}

	else if (StrContains(DuelName, "HNS") != -1)    // If the duel is HNS.
	{
		if (!TSeeker)    // If the terrorist doesn't seek reverse Guard and Prisoner
		{
			TrueGuard    = Guard;
			TruePrisoner = Prisoner;

			Prisoner = TrueGuard;
			Guard    = TruePrisoner;
		}

		GivePlayerItem(Prisoner, "weapon_knife");
		StripPlayerWeapons(Guard);

		SetEntityHealth(Guard, 100);
		SetEntityHealth(Prisoner, 100);

		GeneralTimer    = 60;
		TIMER_COUNTDOWN = CreateTimer(1.0, DecrementTimer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	}

	else if (StrContains(DuelName, "Slow HnR") != -1)
	{
		Bleed = true;

		BleedTarget = 0;

		UC_PrintToChatAll("Slow HnR has started. You must not be the last hit");

		TIMER_COUNTDOWN = CreateTimer(1.0, BleedTimer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

		TriggerTimer(TIMER_COUNTDOWN, true);
	}
	else if (StrContains(DuelName, "Night Crawler") != -1)
	{
		if (!TSeeker)    // If the terrorist doesn't seek reverse Guard and Prisoner
		{
			TrueGuard    = Guard;
			TruePrisoner = Prisoner;

			Prisoner = TrueGuard;
			Guard    = TruePrisoner;
		}

		StripPlayerWeapons(Prisoner);
		GivePlayerItem(Prisoner, "weapon_knife");

		int weapon = GivePlayerItem(Guard, "weapon_m4a1");
		SetClientAmmo(Guard, weapon, 10000);

		GeneralTimer    = 60;
		TIMER_COUNTDOWN = CreateTimer(1.0, DecrementTimer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	}

	else if (StrContains(DuelName, "Shark") != -1)
	{
		if (!TSeeker)    // If the terrorist doesn't seek reverse Guard and Prisoner
		{
			TrueGuard    = Guard;
			TruePrisoner = Prisoner;

			Prisoner = TrueGuard;
			Guard    = TruePrisoner;
		}

		GivePlayerItem(Prisoner, "weapon_knife");
		SetEntityHealth(Prisoner, 200);
		SetClientNoclip(Prisoner, true);

		int weapon = GivePlayerItem(Guard, "weapon_m4a1");
		SetClientAmmo(Guard, weapon, 10000);

		GeneralTimer = 60 + 1;

		SetConVarFloat(hcv_NoclipSpeed, 1.3);
		TIMER_COUNTDOWN = CreateTimer(1.0, DecrementTimer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	}

	else if (StrContains(DuelName, "Backstabs") != -1)
	{
		HeadShot = true;

		PlaySoundToAll(LR_SOUNDS_BACKSTAB);

		UC_PrintToChatAll("%s \x07Stab! Stab! Stab! ", PREFIX);
		UC_PrintToChatAll("%s \x07Stab! Stab! Stab! ", PREFIX);
		UC_PrintToChatAll("%s \x07Stab! Stab! Stab! ", PREFIX);
		UC_PrintToChatAll("%s \x07Stab! Stab! Stab! ", PREFIX);
	}

	else if (StrContains(DuelName, "Race") != -1)
	{
		Race = true;

		if(IsPlayerStuck(Prisoner, raceStartOrigin))
		{
			SetEntPropFloat(Prisoner, Prop_Send, "m_flDuckAmount", 1.0);
		}

		TeleportEntity(Prisoner, raceStartOrigin, NULL_VECTOR, view_as<float>({ 0.0, 0.0, -0.1 }));	


		// Perfect teleport to prevent very specific abuse where you make start point on crouch point to bug the guard.
		PerfectTeleport(Guard, Prisoner);

		StripPlayerWeapons(Prisoner);
		StripPlayerWeapons(Guard);

		GeneralTimer = 5 + 1;

		SetEntityMoveType(Prisoner, MOVETYPE_NONE);
		SetEntityMoveType(Guard, MOVETYPE_NONE);
		TIMER_COUNTDOWN = CreateTimer(1.0, DecrementTimer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

		FormatEx(SavedLRArguments[Prisoner], sizeof(SavedLRArguments[]), "");
	}

	else if (StrContains(DuelName, "Gun Toss") != -1)
	{
		SetWeaponClip(GuardPrim, 0);
		SetWeaponClip(PrisonerPrim, 0);

		LastDistance[Prisoner] = 0.0;
		LastDistance[Guard]    = 0.0;

		GunToss = true;

		BPAmmo = 0;

		DroppedDeagle[Prisoner] = false;
		DroppedDeagle[Guard]    = false;

		TIMER_100MILISECONDS = CreateTimer(0.1, DisallowGunTossPickup, _, TIMER_FLAG_NO_MAPCHANGE);

		UC_PrintToChatAll("Tip: Mutually holding R makes Guard teleport to Prisoner");
	}

	else if (StrContains(DuelName, "Shoot The Bomb") != -1)
	{
		PrisonerSec = GivePlayerItem(Prisoner, "weapon_c4");
		GuardSec    = GivePlayerItem(Guard, "weapon_c4");
	}

	else if (StrContains(DuelName, "First Writes") != -1)
	{
		StripPlayerWeapons(Prisoner);
		StripPlayerWeapons(Guard);

		firstwrites    = true;
		firstcountdown = 5;
		TIMER_REACTION = CreateTimer(1.0, FirstWritesCountDown, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	}

	else if (StrContains(DuelName, "Combo Contest") != -1)
	{
		StripPlayerWeapons(Prisoner);
		StripPlayerWeapons(Guard);

		combo_started  = true;
		combocountdown = 5;
		TIMER_REACTION = CreateTimer(1.0, ComboContestCountDown, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	}

	else if (StrContains(DuelName, "Math Contest") != -1)
	{
		StripPlayerWeapons(Prisoner);
		StripPlayerWeapons(Guard);

		mathcontest          = true;
		mathcontestcountdown = 5;
		TIMER_REACTION       = CreateTimer(1.0, MathContestCountDown, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	}

	else if (StrContains(DuelName, "Opposite Contest") != -1)
	{
		StripPlayerWeapons(Prisoner);
		StripPlayerWeapons(Guard);

		opposite          = true;
		oppositecountdown = 5;
		TIMER_REACTION    = CreateTimer(1.0, OppositeContestCountDown, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	}

	else if (StrContains(DuelName, "Type Stages") != -1)
	{
		StripPlayerWeapons(Prisoner);
		StripPlayerWeapons(Guard);

		typestages          = true;
		typestagescountdown = 5;
		TIMER_REACTION      = CreateTimer(1.0, TypeStagesCountDown, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	}
	if (StrContains(DuelName, "Most Jumps") != -1)
	{
		StripPlayerWeapons(Guard);
		StripPlayerWeapons(Prisoner);

		MostJumps = true;

		TIMER_MOSTJUMPS = CreateTimer(20.0, EndMostJumps, _, TIMER_FLAG_NO_MAPCHANGE);

		mostjumpscountdown = 5;
		TIMER_REACTION     = CreateTimer(1.0, MostJumpsCountDown, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

		UC_PrintToChatAll("%s All players have \x0715 \x01seconds to jump as much as they can!", PREFIX);

		// Guard teleports to Prisoner.
		PerfectTeleport(Guard, Prisoner);
	}
	else if (StrContains(DuelName, "Auto") != -1)
	{
		float Time = 20.0;

		if (StrContains(DuelName, "Type Stages") != -1)
			Time += 40.0;

		if (StrContains(DuelName, "Math") != -1)
			Time += 20.0;

		TIMER_FAILREACTION = CreateTimer(Time, FailReaction, _, TIMER_FLAG_NO_MAPCHANGE);

		UC_PrintToChatAll("%s A random \x05participant \x01will be killed in \x07%i \x01seconds!", PREFIX, RoundFloat(Time));
	}
	else
	{
		TIMER_SLAYALL = CreateTimer(GetConVarFloat(hcv_TimeMustEndLR), SlayAllParts, _, TIMER_FLAG_NO_MAPCHANGE);

		if(GetConVarInt(hcv_TimeMustEndLR) % 60 == 0)
			UC_PrintToChatAll("%s All \x05participants \x01will be slayed in \x07%.0f \x01minutes!", PREFIX, GetConVarFloat(hcv_TimeMustEndLR) / 60);

		else
			UC_PrintToChatAll("%s All \x05participants \x01will be slayed in \x07%.1f \x01minutes!", PREFIX, GetConVarFloat(hcv_TimeMustEndLR) / 60);
	}
	bool NC;

	NC            = StrContains(DuelName, "Night Crawler") != -1 ? true : false;
	TIMER_INFOMSG = CreateTimer(0.1, Timer_ShowToAll, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

	if (!noBeacon)
	{
		TIMER_BEACON[Prisoner] = CreateTimer(NC ? 7.5 : 1.0, BeaconPlayer, Prisoner, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		TIMER_BEACON[Guard]    = CreateTimer(1.0, BeaconPlayer, Guard, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	}


	if(!Bleed)
	{
		SetEntityGlow(Guard, true, 128, 0, 128);
		SetEntityGlow(Prisoner, true, 128, 0, 128);
	}

	int nullint;
	Call_StartForward(fw_LRStarted);

	Call_PushCell(Prisoner);
	Call_PushCell(Guard);

	Call_Finish(nullint);
	// set_task(NC ? 7.5 : 1.0, "Beacon", BEACON_TASKID);

	// Teleport();

	// UC_PrintToChat(TruePrisoner, "LR Sequence: !lr %s %s", SavedLRArguments[Prisoner], SavedLRHealthArgument[Prisoner][0] == EOS ? "" : SavedLRHealthArgument[Prisoner]);
}

public bool OnShouldPlayerHaveCrossbow(int client)
{
	if(LRPart(client) && StrContains(DuelName, "Crossbow", false) != -1)
		return true;

	return false;
}

public void DeleteAllGuns()
{
	if (!LRStarted)
		return;

	char Classname[50];
	int  entCount = GetEntityCount();
	for (int i = MaxClients + 1; i < entCount; i++)
	{
		if (!IsValidEntity(i))
			continue;

		else if (!IsValidEdict(i))
			continue;

		GetEdictClassname(i, Classname, sizeof(Classname));

		if (StrContains(Classname, "weapon_", true) == -1)
			continue;

		int owner = GetEntityOwner(i);

		if (owner != -1)
			continue;

		AcceptEntityInput(i, "Kill");
	}
}

public Action DisallowGunTossPickup(Handle hTimer)
{
	DeleteAllGuns();

	AllowGunTossPickup = false;

	TIMER_100MILISECONDS = INVALID_HANDLE;

	return Plugin_Continue;
}

public Action BeaconPlayer(Handle hTimer, int client)    // It is guaranteed that no way another player will be used instead of the client, no need for user id.
{
	if (!LRPart(client))
		return Plugin_Stop;

	else if (!IsPlayerAlive(client))
		return Plugin_Stop;

	float vec[3];
	GetClientAbsOrigin(client, vec);
	vec[2] += 10;

	int rgba[4] = { 255, 255, 255, 255 };

	for (int i = 0; i < 3; i++)
	{
		rgba[i] = GetRandomInt(0, 255);
	}

	TE_SetupBeamRingPoint(vec, 10.0, 375.0, g_RedBeamSprite, g_HaloSprite, 0, 10, 0.6, 10.0, 0.5, rgba, 10, 0);

	TE_SendToAll();

	GetClientEyePosition(client, vec);

	return Plugin_Continue;
}

public Action SlayAllParts(Handle hTimer)
{
	if (!LRStarted)
		return Plugin_Stop;

	int Pris = Prisoner;    // Slaying the Guard will wipe out the prisoner's integer
	int Guar = Guard;

	g_hTimer_Ignore = hTimer;
	EndLR();

	if (Guar != -1)
		ForcePlayerSuicide(Guar);

	if (Pris != -1)
		ForcePlayerSuicide(Pris);

	UC_PrintToChatAll("%s All \x07LR \x01Participants were slayed for taking too long.", PREFIX);
	TIMER_SLAYALL = INVALID_HANDLE;

	return Plugin_Stop;
}

public Action FailReaction(Handle hTimer)
{
	int target = Guard;    // Killer
	if (GetRandomInt(0, 1) == 1) target = Prisoner;

	g_hTimer_Ignore = hTimer;

	FinishHim(target == Guard ? Prisoner : Guard, target);

	if(!LRStarted)
	{
		TIMER_FAILREACTION = INVALID_HANDLE;
		return Plugin_Stop;
	}
	/*
	else
	{
	    if(GuardSprayHeight == 0.0 && PrisonerSprayHeight == 0.0)
	        target = target * 1;

	    else if(GuardSprayHeight == 0.0 && PrisonerSprayHeight != 0.0)
	        target = Prisoner;

	    else if(GuardSprayHeight != 0.0 && PrisonerSprayHeight == 0.0)
	        target = Guard;

	    else
	    {
	        UC_PrintToChatAll("Last Request error occured. Tell to Eyal282 ASAP please.");
	        SetFailState("Last request error");
	    }
	    FinishHim(target == Guard ? Prisoner : Guard, target);
	}
	*/
	UC_PrintToChatAll("%s Duel time has \x07expired! \x01Winner is \x05%N!", PREFIX, target);

	TIMER_FAILREACTION = INVALID_HANDLE;

	return Plugin_Continue;
}

public Action EndMostJumps(Handle hTimer)
{
	g_hTimer_Ignore = hTimer;

	if (GuardJumps > PrisonerJumps)
	{
		UC_PrintToChatAll("%s \x05%N \x01won the duel!", PREFIX, Guard);
		UC_PrintToChatAll("%s \x05%N \x01had \x07%i \x01jumps while \x05%N \x01had \x05%i \x01jumps", PREFIX, Guard, GuardJumps, Prisoner, PrisonerJumps);
		FinishHim(Prisoner, Guard);
	}
	else if (PrisonerJumps > GuardJumps)
	{
		UC_PrintToChatAll("%s \x05%N \x01won the duel!", PREFIX, Prisoner);
		UC_PrintToChatAll("%s \x05%N \x01had \x05%i \x01jumps while \x05%N \x01had \x05%i \x01jumps", PREFIX, Prisoner, PrisonerJumps, Guard, GuardJumps);
		FinishHim(Guard, Prisoner);
	}
	else
	{
		int winner, jumps, loser;

		if (GetRandomInt(0, 1) == 0)
		{
			winner = Guard;
			loser  = Prisoner;
		}
		else
		{
			winner = Prisoner;
			loser  = Guard;
		}

		jumps = PrisonerJumps;
		UC_PrintToChatAll("%s \x05%N \x01randomly won the duel!", PREFIX, winner);
		UC_PrintToChatAll("%s \x01Both players had \x05%i \x01jumps!", PREFIX, jumps);
		FinishHim(loser, winner);
	}

	TIMER_MOSTJUMPS = INVALID_HANDLE;

	return Plugin_Stop;
}
/*
public Action:OnCustomSpray_Post(client, Float:HeightFromGround, Cheater)
{
    if(!LRStarted)
        return Plugin_Continue;

    else if(!LRPart(client))
        return Plugin_Continue;

    else if(StrContains(DuelName, "Spray") == -1)
        return Plugin_Continue;

    if(Prisoner == client)
        PrisonerSprayHeight = HeightFromGround;

    else
        GuardSprayHeight = HeightFromGround;

    if(GuardSprayHeight != 0.0 && PrisonerSprayHeight != 0.0)
    {

        if(GuardSprayHeight > PrisonerSprayHeight)
        {
            UC_PrintToChatAll("\x01Guard\x03 %N\x01 wins the duel!", Guard);

            FinishHim(Prisoner, Guard);
        }

        else if(PrisonerSprayHeight > GuardSprayHeight)
        {

            UC_PrintToChatAll("\x01Prisoner\x03 %N\x01 wins the duel!", Prisoner);

            FinishHim(Guard, Prisoner);
        }

        else
        {
            SetEntPropFloat(Guard, Prop_Send, "m_flNextDecalTime", 0.0);
            SetEntPropFloat(Prisoner, Prop_Send, "m_flNextDecalTime", 0.0);
            UC_PrintToChatAll("\x01Spray heights are identical! Resetting spray timer for all players!");
        }

        GuardSprayHeight = 0.0;
        PrisonerSprayHeight = 0.0;
    }
    return Plugin_Continue;
}
*/
/*
public Teleport()
{
    new ReadFile[100], Token[3][200], TOrigin[200], CTOrigin[200], Duel[200], Line, Length;

    new DuelNameNeeded[50];
    formatex(DuelNameNeeded, sizeof(DuelNameNeeded), DuelName);

    if(equali(DuelName, "S4S", 3))
        formatex(DuelNameNeeded, sizeof(DuelNameNeeded), "S4S");
    while(read_file(TPDir, Line++, ReadFile, sizeof(ReadFile), Length))
    {
        if(!read_file(TPDir, Line, ReadFile, sizeof(ReadFile), Length))
        {
            break;
        }
        if(ReadFile[0] == ';' || strcmp(ReadFile, "") == 0) continue;

        strtok(ReadFile, TOrigin, 199, Token[0], 199, '=');
        strtok(Token[0], CTOrigin, 199, Duel, 199, '=');

        remove_quotes(Duel);
        if(strcmp(Duel, DuelNameNeeded) != 0) continue;

        new Origin[3];

        parse(TOrigin, Token[0], 199, Token[1], 199, Token[2], 199);

        for(new i;i < 3;i++)
            remove_quotes(Token[i]);

        Origin[0] = str_to_num(Token[0]);
        Origin[1] = str_to_num(Token[1]);
        Origin[2] = str_to_num(Token[2]);

        set_user_origin(Prisoner, Origin);

        Origin[2] += 100;
        parse(CTOrigin, Token[0], 199, Token[1], 199, Token[2], 199);

        for(new i;i < 3;i++)
            remove_quotes(Token[i]);

        Origin[0] = str_to_num(Token[0]);
        Origin[1] = str_to_num(Token[1]);
        Origin[2] = str_to_num(Token[2]);

        set_user_origin(Guard, Origin);

        Origin[2] += 100;
    }
}
*/
public Action ComboContestCountDown(Handle hTimer)
{
	if (combo_started)
	{
		if (combocountdown == 0)
		{
			ComboMoveAble();

			TIMER_REACTION = INVALID_HANDLE;
			return Plugin_Stop;
		}
		else if (combocountdown > 0)
		{
			SetHudMessage(-1.0, 0.35, 0.9, 0, 50, 255);
			ShowHudMessage(0, HUD_REACTION, "Combo contest will start in\n%i Second%s\n", combocountdown, combocountdown > 1 ? "s" : "");
			combocountdown--;
		}
	}

	return Plugin_Continue;
}

public void ComboMoveAble()
{
	if (!LRStarted || !combo_started)
		return;

	maxbuttons = 10;

	int iNumbers[12];
	for (int i; i < sizeof(iNumbers) - 1; i++)
	{
		iNumbers[i] = i;
	}

	SortCustom1D(iNumbers, 11, fnSortFunc);

	for (int i; i < maxbuttons; i++)
	{
		if (i > 0)
		{
			if (iNumbers[i] == g_combo[i - 1])
			{
				continue;
			}
		}
		g_combo[i] = iNumbers[i];
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		g_count[i] = 0;
	}

	g_buttons[0]  = IN_ATTACK;
	g_buttons[1]  = IN_JUMP;
	g_buttons[2]  = IN_DUCK;
	g_buttons[3]  = IN_FORWARD;
	g_buttons[4]  = IN_BACK;
	g_buttons[5]  = IN_USE;
	g_buttons[6]  = IN_MOVELEFT;
	g_buttons[7]  = IN_MOVERIGHT;
	g_buttons[8]  = IN_ATTACK2;
	g_buttons[9]  = IN_RELOAD;
	g_buttons[10] = IN_SCORE;

	combomoveable = true;
}

public int fnSortFunc(int elem1, int elem2, const int[] array, Handle hndl)
{
	int iNum = GetRandomInt(0, 60);

	if (iNum < 30)
	{
		return -1;
	}
	else if (iNum == 30)
	{
		return 0;
	}

	return 1;
}

public void Event_Think(int client)
{
	if (!LRStarted)
		return;

	else if (!LRPart(client))
		return;

	if (NoRecoil)
	{
		int ActiveWeapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");

		if (IsValidEdict(ActiveWeapon) && ActiveWeapon != -1)
		{
			SetEntPropFloat(ActiveWeapon, Prop_Send, "m_fAccuracyPenalty", 0.0);
		}
		SetEntPropVector(client, Prop_Send, "m_aimPunchAngle", NULL_VECTOR);
		SetEntPropVector(client, Prop_Send, "m_aimPunchAngleVel", NULL_VECTOR);
		SetEntPropVector(client, Prop_Send, "m_viewPunchAngle", NULL_VECTOR);
	}
}

public void Event_PlayerPreThink(int client)
{
	if (!LRStarted)
		return;

	else if (!LRPart(client))
		return;

	if (NoRecoil)
	{
		int ActiveWeapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");

		if (IsValidEdict(ActiveWeapon) && ActiveWeapon != -1)
		{
			SetEntPropFloat(ActiveWeapon, Prop_Send, "m_fAccuracyPenalty", 0.0);
		}

		SetEntPropVector(client, Prop_Send, "m_aimPunchAngle", NULL_VECTOR);
		SetEntPropVector(client, Prop_Send, "m_aimPunchAngleVel", NULL_VECTOR);
		SetEntPropVector(client, Prop_Send, "m_viewPunchAngle", NULL_VECTOR);
	}

	else if (GunToss)
	{
		if (GetEntityFlags(client) & FL_ONGROUND && !DroppedDeagle[client])
		{
			GetEntPropVector(client, Prop_Data, "m_vecOrigin", JumpOrigin[client]);
			if (FloatAbs(GetGroundHeight(client) - GroundHeight[client]) <= 25.0)
				GroundHeight[client] = GetGroundHeight(client);

			AdjustedJump[client] = false;    // This is to prevent resetting if it HAPPENS to be that the player jumps off a place, reaches air below 50 units and returns to it or something.
		}
		else
		{
			if (FloatAbs(GetGroundHeight(client) - GroundHeight[client]) <= 25.0 && !AdjustedJump[client])
			{
				float Origin[3];
				GetEntPropVector(client, Prop_Data, "m_vecOrigin", Origin);

				JumpOrigin[client][0] = Origin[0];
				JumpOrigin[client][1] = Origin[1];
				GroundHeight[client]  = GetGroundHeight(client);
			}
			else
			{
				AdjustedJump[client] = true;
			}
		}
	}

	if (!combo_started || !combomoveable)
		return;

	int iButton;
	iButton = GetClientButtons(client);

	if (g_count[client] >= maxbuttons)
	{
		combo_started = false;
		combomoveable = false;

		FinishHim(Prisoner == client ? Guard : Prisoner, client);

		g_count[client] = 0;
	}

	if (g_count[client] != 0)
	{
		if (iButton & g_buttons[g_combo[g_count[client] - 1]])
		{
			return;
		}
	}

	if (iButton & g_buttons[g_combo[g_count[client]]])
	{
		g_count[client]++;
	}
	else if (iButton)
	{
		g_count[client] = 0;
	}

	showcombo(client);
}

void showcombo(int client)
{
	SetHudMessage(-1.0, 0.2, 1.0, 0, 50, 255);

	char name[11][33];

	for (int i; i < maxbuttons; i++)
	{
		Format(name[i], 32, names[g_combo[i]]);
		if (i == g_count[client])
		{
			Format(name[i], 32, names[g_combo[i] + 11]);
		}
	}

	switch (maxbuttons)
	{
		case 5: ShowHudMessage(client, HUD_REACTION, css[maxbuttons], name[0], name[1], name[2], name[3], name[4]);
		case 6: ShowHudMessage(client, HUD_REACTION, css[maxbuttons], name[0], name[1], name[2], name[3], name[4], name[5]);
		case 7: ShowHudMessage(client, HUD_REACTION, css[maxbuttons], name[0], name[1], name[2], name[3], name[4], name[5], name[6]);
		case 8: ShowHudMessage(client, HUD_REACTION, css[maxbuttons], name[0], name[1], name[2], name[3], name[4], name[5], name[6], name[7]);
		case 9: ShowHudMessage(client, HUD_REACTION, css[maxbuttons], name[0], name[1], name[2], name[3], name[4], name[5], name[6], name[7], name[8]);
		case 10: ShowHudMessage(client, HUD_REACTION, css[maxbuttons], name[0], name[1], name[2], name[3], name[4], name[5], name[6], name[7], name[8], name[9]);
	}
}

public Action FirstWritesCountDown(Handle hTimer)
{
	char Number[21];
	IntToString(firstcountdown, Number, sizeof(Number));

	if (firstwrites)
	{
		if (firstcountdown == 0)
		{
			Format(firstchars, GetRandomInt(5, sizeof(firstchars)), "%i%i%i%i%i%i%i%i", GetRandomInt(0, 9), GetRandomInt(0, 9), GetRandomInt(0, 9), GetRandomInt(0, 9), GetRandomInt(0, 9), GetRandomInt(0, 9), GetRandomInt(0, 9), GetRandomInt(0, 9));

			firstwritesmoveable = true;

			TIMER_REACTION = INVALID_HANDLE;

			return Plugin_Stop;
		}
		else if (firstcountdown > 0)
		{
			SetHudMessage(-1.0, 0.35, 0.9, 0, 50, 255);
			ShowHudMessage(0, HUD_REACTION, "First Writes contest will start in\n %i Second%s", firstcountdown, firstcountdown > 1 ? "s" : "");
			firstcountdown--;
		}
	}

	return Plugin_Continue;
}

public Action MathContestCountDown(Handle hTimer)
{
	if (mathcontest)
	{
		if (mathcontestcountdown == 0)
		{
			mathplus   = GetRandomInt(0, 1) == 1 ? true : false;
			mathnum[1] = GetRandomInt(100, 1000);
			mathnum[0] = GetRandomInt(mathplus == true ? 100 : mathnum[1], mathplus == true ? 1000 : 1500);    // This is to prevent a case of nagative numbers, which are my sworn enemies.

			Format(mathresult, sizeof(mathresult), "%i", mathplus == true ? mathnum[0] + mathnum[1] : mathnum[0] - mathnum[1]);
			mathcontestmoveable = true;
			TIMER_REACTION      = INVALID_HANDLE;

			return Plugin_Stop;
		}
		else if (mathcontestcountdown > 0)
		{
			SetHudMessage(-1.0, 0.35, 0.9, 0, 50, 255);
			ShowHudMessage(0, HUD_REACTION, "Math contest will start in\n%i Second%s\n", mathcontestcountdown, mathcontestcountdown > 1 ? "s" : "");
			mathcontestcountdown--;
		}
	}

	return Plugin_Continue;
}

public Action OppositeContestCountDown(Handle hTimer)
{
	if (opposite)
	{
		if (oppositecountdown == 0)
		{
			oppositewords    = GetRandomInt(0, sizeof(OppositeWords1) - 1);
			oppositemoveable = true;
			TIMER_REACTION   = INVALID_HANDLE;

			return Plugin_Stop;
		}
		else if (oppositecountdown > 0)
		{
			SetHudMessage(-1.0, 0.35, 0.9, 0, 50, 255);
			ShowHudMessage(0, HUD_REACTION, "Opposite contest will start in\n%i Second%s\n", oppositecountdown, oppositecountdown > 1 ? "s" : "");
			oppositecountdown--;
		}
	}

	return Plugin_Continue;
}

public Action TypeStagesCountDown(Handle hTimer)
{
	if (typestages)
	{
		if (typestagescountdown == 0)
		{
			typestagesmaxstages = GetRandomInt(5, 10);
			for (int i = 0; i <= typestagesmaxstages; i++)
				Format(typeStagesChars[i], GetRandomInt(5, sizeof(typeStagesChars[])), "%i%i%i%i%i%i%i%i", GetRandomInt(0, 9), GetRandomInt(0, 9), GetRandomInt(0, 9), GetRandomInt(0, 9), GetRandomInt(0, 9), GetRandomInt(0, 9), GetRandomInt(0, 9), GetRandomInt(0, 9));

			typestagesmoveable = true;

			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i))
					continue;

				typestagescount[i] = 1;
			}
			TIMER_REACTION = INVALID_HANDLE;

			return Plugin_Stop;
		}
		else if (typestagescountdown > 0)
		{
			SetHudMessage(-1.0, 0.35, 0.9, 0, 50, 255);
			ShowHudMessage(0, HUD_REACTION, "Type Stages contest will start in\n%i Second%s\n", typestagescountdown, typestagescountdown > 1 ? "s" : "");
			typestagescountdown--;
		}
	}

	return Plugin_Continue;
}

public Action MostJumpsCountDown(Handle hTimer)
{
	if (MostJumps)
	{
		if (mostjumpscountdown == 0)
		{
			mostjumpsmovable = true;

			TIMER_REACTION = INVALID_HANDLE;

			return Plugin_Stop;
		}
		else if (mostjumpscountdown > 0)
		{
			SetHudMessage(-1.0, 0.35, 0.9, 0, 50, 255);
			ShowHudMessage(0, HUD_REACTION, "Most Jumps contest will start in\n %i Second%s", mostjumpscountdown, mostjumpscountdown > 1 ? "s" : "");
			mostjumpscountdown--;
		}
	}

	return Plugin_Continue;
}
/*
public Beacon() // I won't even pretend that I understand in message_begin function, absolutely stolen from somewhere.
{
    new bool:ct;
    new players[32], num;
    get_players(players, num, "ah");

    for(new id;id < num;id++)
    {
        new i = players[id];
        if(!LRPart(i))
            continue;

        ct = cs_get_user_team(i) == CS_TEAM_CT ? true : false;

        static origin[3];
        get_user_origin(i, origin);
        message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
        write_byte(TE_BEAMCYLINDER);	// TE id
        write_coord(origin[0]);	 	// x
        write_coord(origin[1]);		// y
        write_coord(origin[2]-20);	// z // Supposed to be origni[2] - 20
        write_coord(origin[0]);    	// x axis
        write_coord(origin[1]);    	// y axis
        write_coord(origin[2]+200);	// z axis
        write_short(beacon_sprite);	// sprite
        write_byte(0);			// startframe
        write_byte(1);			// framerate
        write_byte(6);			// life
        write_byte(50);  			// width
        write_byte(1);   			// noise
        write_byte(!ct ? 250 : 0);			// red
        write_byte(0);   			// green
        write_byte(ct ? 250 : 0); 			// blue
        write_byte(200);			// brightness
        write_byte(0);			// speed
        message_end();
    }
    new bool:NC;

    NC = StrContains(DuelName, "Night Crawler") != -1 ? true : false;
    set_task(NC ? 7.5 : 1.0, "Beacon", BEACON_TASKID);
}
*/
public void ResetClipAndFrame(int AlexaPlayDespacitoByToto)
{
	if (!LRStarted)
		return;

	RequestFrame(ResetClip, 0);
}

public void ResetClip(int AlexaPlayDespacitoByToto)
{
	if (!LRStarted)
		return;

	bool Type = false;
	if (PrimNum != CSWeapon_KNIFE) Type = true;

	if (GetRandomInt(0, 1) == 1)
	{
		SetWeaponClip(Type ? GuardPrim : GuardSec, 0);
		SetWeaponClip(Type ? PrisonerPrim : PrisonerSec, 1);
	}
	else
	{
		SetWeaponClip(Type ? GuardPrim : GuardSec, 1);
		SetWeaponClip(Type ? PrisonerPrim : PrisonerSec, 0);
	}

	SetClientAmmo(Guard, Type ? GuardPrim : GuardSec, 0);
	SetClientAmmo(Prisoner, Type ? PrisonerPrim : PrisonerSec, 0);
}

public Action Timer_ShowToAll(Handle hTimer)
{
	if (!LRStarted)
	{
		TIMER_INFOMSG = INVALID_HANDLE;
		return Plugin_Stop;
	}

	if(Bleed && BleedTarget != 0)
	{
		SetEntityRenderMode(BleedTarget, RENDER_GLOW);
		SetEntityRenderFx(BleedTarget, RENDERFX_GLOWSHELL);

		SetEntityRenderColor(BleedTarget, GetRandomInt(0, 255), GetRandomInt(0, 255), GetRandomInt(0, 255), 255);
	}

	bool HNS;

	if (StrContains(DuelName, "HNS") != -1 || StrContains(DuelName, "Night Crawler") != -1 || StrContains(DuelName, "Shark") != -1) HNS = true;

	bool isAuto = (StrContains(DuelName, "Auto") != -1);
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		if (HNS)
		{
			SetHudMessage(-1.0, -1.0, 1.0, 0, 50, 255);
			ShowHudMessage(i, HUD_TIMER, "Time Left: %i", GeneralTimer);
		}
		else if (GeneralTimer > 0)
		{
			SetHudMessage(-1.0, -1.0, 1.0, 0, 50, 255);
			ShowHudMessage(i, HUD_TIMER, "%i Seconds", GeneralTimer);
		}
		if (ShowMessage[i] || isAuto)
			ShowInfoMessage(i);
	}

	if (GunToss)
	{
		char GuardName[64], PrisonerName[64];

		GetClientName(Guard, GuardName, sizeof(GuardName));
		GetClientName(Prisoner, PrisonerName, sizeof(PrisonerName));

		ReplaceString(GuardName, sizeof(GuardName), "<", "");    // Hopefully this will be fixed in the future when using %N
		ReplaceString(GuardName, sizeof(GuardName), ">", "");

		ReplaceString(PrisonerName, sizeof(PrisonerName), "<", "");
		ReplaceString(PrisonerName, sizeof(PrisonerName), ">", "");

		PrintCenterTextAll("%s<font color='#FF0000'>%s dropped his deagle %.2f units.\n%s%s dropped his deagle %.2f units.</font>", LastDistance[Prisoner] > LastDistance[Guard] ? "<font color='#FFFFFF'>☆</font>" : "", PrisonerName, LastDistance[Prisoner], LastDistance[Prisoner] < LastDistance[Guard] ? "<font color='#FFFFFF'>☆</font>" : "", GuardName, LastDistance[Guard]);
	}
	return Plugin_Continue;
}

public Action Event_WeaponFire(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	if (!LRStarted)
		return Plugin_Continue;

	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));

	if (!LRPart(client))
		return Plugin_Continue;

	if (GunToss)
	{
		char Classname[50];
		GetEventString(hEvent, "weapon", Classname, sizeof(Classname));

		if (!IsKnifeClass(Classname))
		{
			if (Guard == client)
			{
				SetClientGodmode(Prisoner, true);
				FinishHim(Guard, Prisoner);
			}
			else
			{
				SetClientGodmode(Guard, true);
				FinishHim(Prisoner, Guard);
			}
		}
		return Plugin_Continue;
	}
	if (BPAmmo > 100 && StrContains(DuelName, "S4S") == -1)    // No clue why I need this check of s4s...
	{
		if (PrimNum != CSWeapon_NONE && PrimNum != CSWeapon_MAX_WEAPONS)
		{
			if (Prisoner == client && IsValidEntity(PrisonerPrim))
				SetClientAmmo(Prisoner, PrisonerPrim, BPAmmo);

			if (Guard == client && IsValidEntity(GuardPrim))
				SetClientAmmo(Guard, GuardPrim, BPAmmo);
		}
		if (SecNum != CSWeapon_NONE)
		{
			if (Prisoner == client && IsValidEntity(PrisonerSec))
				SetClientAmmo(Prisoner, PrisonerSec, BPAmmo);

			if (Guard == client && IsValidEntity(GuardSec))
				SetClientAmmo(Guard, GuardSec, BPAmmo);
		}
	}
	if (StrContains(DuelName, "S4S") == -1)
		return Plugin_Continue;

	char Classname[50];
	GetEventString(hEvent, "weapon", Classname, sizeof(Classname));

	if (IsKnifeClass(Classname))
		return Plugin_Continue;

	PrintCenterText(Guard == client ? Prisoner : Guard, "It's your turn to shoot!");

	int WeaponToUse;

	if (Guard == client)
	{
		WeaponToUse = PrimNum != CSWeapon_KNIFE ? PrisonerPrim : PrisonerSec;

		SetWeaponClip(WeaponToUse, 1);
		if (GetEntPropEnt(Prisoner, Prop_Data, "m_hActiveWeapon") != WeaponToUse)
		{
			SetEntPropEnt(Prisoner, Prop_Data, "m_hActiveWeapon", WeaponToUse);
			SetEntProp(Prisoner, Prop_Send, "m_bDrawViewmodel", 1);    // For the !lol command :D
		}
	}
	else
	{
		WeaponToUse = PrimNum != CSWeapon_KNIFE ? GuardPrim : GuardSec;
		SetWeaponClip(WeaponToUse, 1);

		if (GetEntPropEnt(Guard, Prop_Data, "m_hActiveWeapon") != WeaponToUse)
		{
			SetEntPropEnt(Guard, Prop_Data, "m_hActiveWeapon", WeaponToUse);
			SetEntProp(Guard, Prop_Send, "m_bDrawViewmodel", 1);    // For the !lol command :D
		}
	}

	return Plugin_Continue;
}

public Action Event_WeaponFireOnEmpty(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	if (!LRStarted)
		return Plugin_Continue;

	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));

	if (!LRPart(client))
		return Plugin_Continue;

	if (BPAmmo > 100)
	{
		if (PrimNum != CSWeapon_NONE && PrimNum != CSWeapon_MAX_WEAPONS)
			SetClientAmmo(client, client == Prisoner ? PrisonerPrim : GuardPrim, BPAmmo);

		if (SecNum != CSWeapon_NONE)
			SetClientAmmo(client, client == Prisoner ? PrisonerSec : GuardSec, BPAmmo);
	}
	if (StrContains(DuelName, "S4S") == -1)
		return Plugin_Continue;

	char Classname[50];
	GetEventString(hEvent, "weapon", Classname, sizeof(Classname));

	if (IsKnifeClass(Classname))
		return Plugin_Continue;

	int WeaponToUse;
	if (Guard == client)
	{
		WeaponToUse = PrimNum != CSWeapon_KNIFE ? PrisonerPrim : PrisonerSec;
		SetWeaponClip(WeaponToUse, 1);
	}
	else
	{
		WeaponToUse = PrimNum != CSWeapon_KNIFE ? GuardPrim : GuardSec;
		SetWeaponClip(WeaponToUse, 1);
	}

	return Plugin_Continue;
}

public Action Event_DecoyStarted(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	int entity = GetEventInt(hEvent, "entityid");

	char TargetName[50];

	GetEntPropString(entity, Prop_Data, "m_iName", TargetName, sizeof(TargetName));

	if (StrContains(TargetName, "Dodgeball", true) == -1)
		return Plugin_Continue;

	AcceptEntityInput(entity, "Kill");

	return Plugin_Continue;
}

public Action Event_PlayerJump(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	if (!LRStarted)
		return Plugin_Continue;

	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));

	if (!LRPart(client))
		return Plugin_Continue;

	else if (!MostJumps)
		return Plugin_Continue;

	else if (!mostjumpsmovable)
		return Plugin_Continue;

	if (Guard == client)
		GuardJumps++;

	else if (Prisoner == client)
		PrisonerJumps++;

	return Plugin_Continue;
}

public Action Event_Sound(int clients[64], int& numClients, char sample[PLATFORM_MAX_PATH], int& entity, int& channel, float& volume, int& level, int& pitch, int& flags)
{
	if (entity == 0 || !IsValidEntity(entity))
		return Plugin_Continue;

	char Classname[50];
	GetEdictClassname(entity, Classname, sizeof(Classname));

	if (!StrEqual(Classname, "decoy_projectile", true))
		return Plugin_Continue;

	char TargetName[50];

	GetEntPropString(entity, Prop_Data, "m_iName", TargetName, sizeof(TargetName));

	if (StrContains(TargetName, "Dodgeball", true) == -1 || StrContains(TargetName, "NoNoise", true) == -1)
		return Plugin_Continue;

	return Plugin_Handled;
}
/*
public Action:Event_HEGrenadeDetonate(Handle:event, const String:name[], bool:dontBroadcast)
{
    if(!LRStarted)
        return;

    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    if(!LRPart(client))
        return;


    if(PrimNum == CSWeapon_HEGRENADE || SecNum == CSWeapon_HEGRENADE)
        GivePlayerItem(client, "weapon_hegrenade");
}
public Action:Event_SmokeGrenadeDetonate(Handle:event, const String:name[], bool:dontBroadcast)
{
    if(!LRStarted)
        return;

    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    if(!LRPart(client))
        return;

    if(PrimNum == CSWeapon_SMOKEGRENADE || SecNum == CSWeapon_SMOKEGRENADE)
        GivePlayerItem(client, "weapon_smokegrenade");
}
*/
void ShowInfoMessage(int client)
{
	if (StrContains(DuelName, "Auto") != -1)
	{
		ShowReactionInfo(client);
		return;
	}

	Handle hStyleRadio = GetMenuStyleHandle(MenuStyle_Radio);

	Handle hPanel = CreatePanel(hStyleRadio);

	SetPanelCurrentKey(hPanel, 9);
	DrawPanelItem(hPanel, "Exit Forever");

	SetPanelKeys(hPanel, (1 << 0) | (1 << 1) | (1 << 2) | (1 << 3) | (1 << 4) | (1 << 8));

	char TempFormat[512];

	if (!Rambo)
		FormatEx(TempFormat, sizeof(TempFormat), "%s!\n \n%N HP: %i\n\n%N HP: %i\n \nRules:\n\n%s is %sabled\n%s Only is %sabled\nDuck is %sabled\nJump is %sabled\n \n",
		         DuelName, Prisoner, GetEntityHealth(Prisoner), Guard, GetEntityHealth(Guard), PrimNum == CSWeapon_KNIFE ? "Right stab" : "Zoom", Zoom ? "En" : "Dis", PrimNum == CSWeapon_KNIFE ? "Backstab" : "Headshot", HeadShot ? "En" : "Dis", Duck ? "En" : "Dis", Jump ? "En" : "Dis");

	else
		FormatEx(TempFormat, sizeof(TempFormat), "%N VS Guard - RAMBO REBEL!\n%N Health: %i", Prisoner, Prisoner, GetEntityHealth(Prisoner));

	SetPanelTitle(hPanel, TempFormat, false);

	SendPanelToClient(hPanel, client, PanelHandler_InfoMessage, 1);

	CloseHandle(hPanel);
}

public int PanelHandler_InfoMessage(Handle hPanel, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
	{
		CloseHandle(hPanel);

		return 0;
	}
	else if (action == MenuAction_Select)
	{
		if (item <= 5)
		{
			// Nasty hack that ignores double nades ( molotov and flashbang for example ) but I'll live for now...
			int weapon = GetPlayerWeaponSlot(client, item - 1);

			if (weapon != -1)
			{
				char Classname[64];

				GetEdictClassname(weapon, Classname, sizeof(Classname));

				FakeClientCommand(client, "use %s", Classname);
			}

			if(LRStarted)
				ShowInfoMessage(client);
		}
		if (item == 9)
		{
			ShowMessage[client] = false;
			EmitSoundToClient(client, MENU_EXIT_SOUND);    // Fauken panels...
		}
	}

	return 0;
}

public void ShowReactionInfo(int client)
{
	if (!LRPart(client) || !IsPlayerAlive(client))
		return;

	SetHudMessage(-1.0, 0.35, 1.0, 0, 50, 255);

	if (firstwritesmoveable)
		ShowHudMessage(client, HUD_REACTION, "First writes started, Answer:\n%s", firstchars);

	else if (typestagesmoveable)
	{
		char StageWord[50];

		GetUserStageWord(client, StageWord, sizeof(StageWord));
		ShowHudMessage(client, HUD_REACTION, "Type Stages contest started, Answer:\n%s\nStage:\n %i/%i", StageWord, typestagescount[client], typestagesmaxstages);
	}

	else if (mathcontestmoveable)
		ShowHudMessage(client, HUD_REACTION, "Math contest started, Question:\n%i %s %i = ?", mathnum[0], mathplus ? "+" : "-", mathnum[1]);

	else if (oppositemoveable)
		ShowHudMessage(client, HUD_REACTION, "Opposite contest started, Question:\nWhat Is The Opposite Of The Word\n%s", OppositeWords1[oppositewords]);

	else if (mostjumpsmovable)
		ShowHudMessage(client, HUD_REACTION, "Most Jumps contest started.\n%N Jumps: %i\n%N Jumps: %i", Prisoner, PrisonerJumps, Guard, GuardJumps);
}

public Action DecrementTimer(Handle hTimer)
{
	GeneralTimer--;

	if (GeneralTimer <= 0)
	{
		bool HNS;

		if (StrContains(DuelName, "HNS") != -1 || StrContains(DuelName, "Night Crawler") != -1 || StrContains(DuelName, "Shark") != -1) HNS = true;

		if (HNS)
			FinishHim(Prisoner, Guard);

		else
		{
			SetEntityMoveType(Prisoner, MOVETYPE_WALK);
			SetEntityMoveType(Guard, MOVETYPE_WALK);
		}

		TIMER_COUNTDOWN = INVALID_HANDLE;
		return Plugin_Stop;
	}

	return Plugin_Continue;
}


// The rainbow color appears in info message at "Timer_ShowToAll"
public Action BleedTimer(Handle hTimer)
{
	if (BleedTarget == 0)
	{
		PrintCenterText(Prisoner, "You are not infected. Hit the Guard last to infect him.");
		PrintCenterText(Guard, "You are not infected. Hit the Prisoner lastto infect him.");
		return Plugin_Continue;
	}
	else
	{
		if (BleedTarget == Prisoner)
		{
			g_hTimer_Ignore = hTimer;
			SDKHooks_TakeDamage(Prisoner, Guard, Guard, 700.0, DMG_POISON);

			if(!LRStarted)
			{
				TIMER_COUNTDOWN = INVALID_HANDLE;
				return Plugin_Stop;
			}

			PrintCenterText(Prisoner, "You are infected. Hit the Guard quickly before you die!");
			PrintCenterText(Guard, "You are not infected. Try not to get hit last");
		}
		else if (BleedTarget == Guard)
		{
			SDKHooks_TakeDamage(Guard, Prisoner, Prisoner, 700.0, DMG_POISON);
			
			if(!LRStarted)
			{
				TIMER_COUNTDOWN = INVALID_HANDLE;
				return Plugin_Stop;
			}

			PrintCenterText(Guard, "You are infected. Hit the Prisoner quickly before you die!");
			PrintCenterText(Prisoner, "You are not infected. Try not to get hit last");
		}
	}

	return Plugin_Continue;
}

/*
stock track_weapon(index)
{
    new WepName[32];
    get_weaponname(get_user_weapon(index), WepName, sizeof(WepName));

    new Ent = 1, Weapon=-1;
    while((Ent = find_ent_by_class(Ent, WepName)))
    {
        if(pev(Ent, pev_owner) == index) Weapon = Ent; break;
    }

    return Weapon;
}
*/
stock bool LastRequest(int client, bool message=true)
{
	int Guards, Prisoners;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (!IsPlayerAlive(i))
			continue;

		switch (GetClientTeam(i))
		{
			case CS_TEAM_T: Prisoners++;
			case CS_TEAM_CT: Guards++;
		}
	}

	if (GetClientTeam(client) != CS_TEAM_T)
	{
		if(message)
			UC_PrintToChat(client, "%s Only prisoners may use this \x07command!", PREFIX);
	}

	else if (!IsPlayerAlive(client))
	{
		if(message)
			UC_PrintToChat(client, "%s You must be alive to use this \x07command!", PREFIX);
	}

	else if (LRStarted)
	{
		if(message)
			UC_PrintToChat(client, "%s \x05LR \x01has already \x07started!", PREFIX);
	}

	else if (Prisoners != 1)
	{
		if(message)
			UC_PrintToChat(client, "%s You are not the last \x07prisoner!", PREFIX);
	}

	else if (Guards <= 0)
	{
		if(message)
			UC_PrintToChat(client, "%s There are no guards to play \x07with!", PREFIX);
	}

	else
	{
		char Message[256];
		Call_StartForward(fw_CanStartLR);

		Call_PushCell(client);
		Call_PushStringEx(Message, sizeof(Message), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);

		Action Value;
		Call_Finish(Value);

		if (Value > Plugin_Continue)
		{
			if(message)
				UC_PrintToChat(client, "%s %s", PREFIX, Message);

			return false;
		}

		return true;
	}
	return false;
}

stock bool LRPart(int client)    // = Participant in LR.
{
	return client == Guard || client == Prisoner ? true : false;
}

stock void GetUserStageWord(int client, char[] buffer, int length)
{
	Format(buffer, length, typeStagesChars[typestagescount[client]]);
}
/*
stock GetWeaponBoxWeaponType(ent)
{
    new weapon;
    for(new i = 1; i<= 5; i++)
    {
        weapon = get_pdata_cbase(ent, m_rgpPlayerItems_CWeaponBox[i], XoCWeaponBox);
        if( weapon > 0 )
        {
            return cs_get_weapon_id(weapon);
        }
    }

    return 0;
}
stock bool:is_user_surfing(id) // Who dafaq invented that stock?
{
    if( is_user_alive(id) )
    {
        new flags = entity_get_int(id, EV_INT_flags);
        if( flags & FL_ONGROUND )
        {
            return false;
        }
        new Float:origin[3], Float:dest[3];
        entity_get_vector(id, EV_VEC_origin, origin);

        dest[0] = origin[0];
        dest[1] = origin[1];
        dest[2] = origin[2] - 1.0;
        new ptr = create_tr2();
        engfunc(EngFunc_TraceHull, origin, dest, 0, flags & FL_DUCKING ? HULL_HEAD : HULL_HUMAN, id, ptr);
        new Float:flFraction;
        get_tr2(ptr, TR_flFraction, flFraction);
        if( flFraction >= 1.0 )
        {
            free_tr2(ptr);
            return false;
        }

        get_tr2(ptr, TR_vecPlaneNormal, dest);
        free_tr2(ptr);
        // which one ?
        // static Float:flValue = 0.0;
        // if( !flValue )
        // {
            // flValue = floatcos(45.0, degrees);
        // }
        // return dest[2] <= flValue;
        // return dest[2] < flValue;
        return dest[2] <= 0.7 ? true : false;
        // return dest[2] < 0.7;
    }

    return false;
}
*/
stock void FinishHim(int victim, int attacker)
{
	if (!IsClientInGame(victim) || !IsClientInGame(attacker))
		return;

	BypassBlockers = true;
	HeadShot       = false;
	Ring           = false;

	char weaponToGive[50];
	FindPlayerWeapon(attacker, weaponToGive, sizeof(weaponToGive));

	StripPlayerWeapons(victim);
	StripPlayerWeapons(attacker);

	int inflictor = GivePlayerItem(attacker, weaponToGive);
	SetEntityHealth(victim, 100);
	SetClientGodmode(victim);
	SetClientNoclip(victim);
	SDKHooks_TakeDamage(victim, inflictor, attacker, 32767.0, DMG_SLASH);

	BypassBlockers = false;
}

stock bool FindPlayerWeapon(int attacker, char[] buffer, int length)
{
	int weapon = -1;

	weapon = GetEntPropEnt(attacker, Prop_Data, "m_hActiveWeapon");

	if (weapon != -1)
	{
		GetEdictClassname(weapon, buffer, length);
		return true;
	}

	if (PrimNum != CSWeapon_NONE && PrimNum != CSWeapon_MAX_WEAPONS)
		Format(buffer, length, PrimWep);

	if (SecNum != CSWeapon_NONE)
		Format(buffer, length, SecWep);

	Format(buffer, length, "weapon_knife");
	return false;
}

stock bool IsPlayer(int client)
{
	if (client <= 0)
		return false;

	else if (client > MaxClients)
		return false;

	return true;
}

stock void SetEntityGlow(int entity, bool glow = false, int r = 0, int g = 0, int b = 0)
{
	if (glow)
	{
		SetEntityRenderMode(entity, RENDER_GLOW);
		SetEntityRenderColor(entity, r, g, b, 255);
	}
	else
	{
		SetEntityRenderMode(entity, RENDER_NORMAL);
		SetEntityRenderColor(entity, 255, 255, 255, 255);
	}
}

stock void SetHudMessage(float x = -1.0, float y = -1.0, float HoldTime = 6.0, int r = 255, int g = 0, int b = 0, int a = 255, int effects = 0, float fxTime = 12.0, float fadeIn = 0.0, float fadeOut = 0.0)
{
	SetHudTextParams(x, y, HoldTime, r, g, b, a, effects, fxTime, fadeIn, fadeOut);
}

stock void ShowHudMessage(int client, int channel = -1, char[] Message, any...)
{
	char VMessage[300];
	VFormat(VMessage, sizeof(VMessage), Message, 4);

	if (client != 0)
		ShowHudText(client, channel, VMessage);

	else
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i))
				ShowHudText(i, channel, VMessage);
		}
	}
}

stock bool StripGunByClassname(int client, char[] WeaponName)
{
	char Classname[50];

	for (int i = 0; i <= 4; i++)
	{
		int weapon = GetPlayerWeaponSlot(client, i);

		if (weapon != -1)
		{
			GetEdictClassname(weapon, Classname, sizeof(Classname));

			if (StrEqual(WeaponName, Classname, true))
			{
				AcceptEntityInput(weapon, "Kill");
				return true;
			}
		}
	}

	return false;
}

stock void StripPlayerWeapons(int client)
{
	if (!IsClientInGame(client))
		return;

	for (int i = 0; i <= 5; i++)
	{
		int weapon = GetPlayerWeaponSlot(client, i);

		if (weapon != -1)
		{
			RemovePlayerItem(client, weapon);
			AcceptEntityInput(weapon, "Kill");
			i--;
		}
	}
}

stock void SetClientGodmode(int client, bool godmode = false)
{
	if (godmode)
		SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);

	else
		SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
}

stock void SetClientNoclip(int client, bool noclip = false)
{
	if (noclip)
	{
		SetEntProp(client, Prop_Send, "movetype", MOVETYPE_NOCLIP, 1);
	}
	else
		SetEntProp(client, Prop_Send, "movetype", 1, 1);
}

stock void SetClientSpeed(int client, float speed = 1.0)
{
	SetEntPropFloat(client, Prop_Send, "m_flVelocityModifier", speed);
}
stock bool IsStringNumber(const char[] source)
{
	if (!IsCharNumeric(source[0]) && source[0] != '-')
		return false;

	for (int i = 1; i < strlen(source); i++)
	{
		if (!IsCharNumeric(source[i]))
			return false;
	}

	return true;
}

stock int GetEntityHealth(int entity)
{
	return GetEntProp(entity, Prop_Send, "m_iHealth");
}

stock void SetClientAmmo(int client, int weapon, int ammo)
{
	SetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount", ammo);    // set reserve to 0

	int ammotype = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
	if (ammotype == -1) return;

	SetEntProp(client, Prop_Send, "m_iAmmo", ammo, _, ammotype);
}

stock void SetWeaponClip(int weapon, int clip)
{
	SetEntProp(weapon, Prop_Data, "m_iClip1", clip);
}

stock bool StrEquali(char[] str1, char[] str2)
{
	return StrEqual(str1, str2, false);
}

stock void SetClientArmor(int client, int amount, int helmet = -1)    // helmet: -1 = unchanged, 0 = no helmet, 1 = yes helmet
{
	if (helmet != -1)
		SetEntProp(client, Prop_Send, "m_bHasHelmet", helmet);

	SetEntProp(client, Prop_Send, "m_ArmorValue", amount);
}

stock void SetRandomRules(int Type)
{
	Zoom     = view_as<bool>(GetRandomInt(0, 1));
	HeadShot = view_as<bool>(GetRandomInt(0, 1));
	Vest     = GetRandomInt(0, 2);

	if (Type == 1)
	{
		Duck = view_as<bool>(GetRandomInt(0, 1));
		Jump = view_as<bool>(GetRandomInt(0, 1));
	}
}

stock int GetMaxHealthValue()
{
	if (StrContains(DuelName, "Slow HnR") != -1)
		return 30000;

	bool Knife = (StrContains(DuelName, "Knife") != -1);
	if (HeadShot && Knife && !Zoom)
		return 150;

	else if (HeadShot && Knife)
		return 250;

	else if (Knife && !Zoom)
		return 500;

	else if (Knife)
		return 1000;

	else if (HeadShot && !Zoom)
		return 200;

	return 1500;
}

stock bool GetClientInfoMessage(int client)
{
	char strInfoMessage[50];
	GetClientCookie(client, cpInfoMsg, strInfoMessage, sizeof(strInfoMessage));

	if (strInfoMessage[0] == EOS)
	{
		SetClientInfoMessage(client, true);
		return true;
	}

	return view_as<bool>(StringToInt(strInfoMessage));
}

stock bool SetClientInfoMessage(int client, bool value)
{
	char strInfoMessage[50];

	IntToString(view_as<int>(value), strInfoMessage, sizeof(strInfoMessage));
	SetClientCookie(client, cpInfoMsg, strInfoMessage);

	return value;
}

stock int GetClientLRWins(int client)
{
	char strLRWins[50];
	GetClientCookie(client, cpLRWins, strLRWins, sizeof(strLRWins));

	if (strLRWins[0] == EOS)
	{
		SetClientCookie(client, cpLRWins, "0");
		return 0;
	}

	return StringToInt(strLRWins);
}

stock void AddClientLRWin(int client)
{
	char strLRWins[50];

	int TotalWins = GetClientLRWins(client) + 1;

	IntToString(TotalWins, strLRWins, sizeof(strLRWins));
	SetClientCookie(client, cpLRWins, strLRWins);
}

stock void SetClientLRWins(int client, int value)
{
	char strLRWins[50];

	IntToString(value, strLRWins, sizeof(strLRWins));

	SetClientCookie(client, cpLRWins, strLRWins);
}

// SM lib all the set sizes.

stock void Entity_SetRadius(int entity, float radius)
{
	SetEntPropFloat(entity, Prop_Data, "m_flRadius", radius);
}

stock void Entity_GetMinSize(int entity, float vec[3])
{
	GetEntPropVector(entity, Prop_Send, "m_vecMins", vec);
}

stock void Entity_SetMinSize(int entity, const float vecMins[3])
{
	SetEntPropVector(entity, Prop_Send, "m_vecMins", vecMins);
}

stock void Entity_GetMaxSize(int entity, float vec[3])
{
	GetEntPropVector(entity, Prop_Send, "m_vecMaxs", vec);
}

stock void Entity_SetMaxSize(int entity, const float vecMaxs[3])
{
	SetEntPropVector(entity, Prop_Send, "m_vecMaxs", vecMaxs);
}
stock void Entity_SetMinMaxSize(int entity, const float vecMins[3], const float vecMaxs[3])    // SM lib
{
	// Taken from hl2sdk-ob-valve\game\server\util.cpp SetMinMaxSize()
	// Todo: Replace this by a SDK call
	for (int i = 0; i < 3; i++)
	{
		if (vecMins[i] > vecMaxs[i])
		{
			ThrowError("Error: mins[%d] > maxs[%d] of entity %d", i, i, EntRefToEntIndex(entity));
		}
	}

	float m_vecMins[3], m_vecMaxs[3];
	Entity_GetMinSize(entity, m_vecMins);
	Entity_GetMaxSize(entity, m_vecMaxs);

	if (Math_VectorsEqual(m_vecMins, vecMins) && Math_VectorsEqual(m_vecMaxs, vecMaxs))
	{
		return;
	}

	Entity_SetMinSize(entity, vecMins);
	Entity_SetMaxSize(entity, vecMaxs);

	float vecSize[3];
	SubtractVectors(vecMaxs, vecMins, vecSize);
	Entity_SetRadius(entity, GetVectorLength(vecSize) * 0.5);

	Entity_MarkSurrBoundsDirty(entity);
}

stock void Entity_MarkSurrBoundsDirty(int entity)
{
	Entity_AddEFlags(entity, EFL_DIRTY_SURR_COLLISION_BOUNDS);
}

stock bool Math_VectorsEqual(const float vec1[3], const float vec2[3], const float tolerance = 0.0)
{
	float distance = GetVectorDistance(vec1, vec2, true);

	return distance <= (tolerance * tolerance);
}

stock void Entity_SetEFlags(int entity, Entity_Flags flags)
{
	SetEntProp(entity, Prop_Data, "m_iEFlags", flags);
}

stock Entity_Flags Entity_GetEFlags(int entity)
{
	return view_as<Entity_Flags>(GetEntProp(entity, Prop_Data, "m_iEFlags"));
}

stock void Entity_AddEFlags(int entity, Entity_Flags flags)
{
	Entity_Flags setFlags = Entity_GetEFlags(entity);
	setFlags |= flags;
	Entity_SetEFlags(entity, setFlags);
}

stock void GetVelocityFromOrigin(int ent, float fOrigin[3], float fSpeed, float fVelocity[3])    // Will crash server if fSpeed = -1.0
{
	float fEntOrigin[3];
	GetEntPropVector(ent, Prop_Data, "m_vecOrigin", fEntOrigin);

	// Velocity = Distance / Time

	float fDistance[3];
	fDistance[0] = fEntOrigin[0] - fOrigin[0];
	fDistance[1] = fEntOrigin[1] - fOrigin[1];
	fDistance[2] = fEntOrigin[2] - fOrigin[2];

	float fTime = (GetVectorDistance(fEntOrigin, fOrigin) / fSpeed);

	if (fTime == 0.0)
		fTime = 1 / (fSpeed + 1.0);

	fVelocity[0] = fDistance[0] / fTime;
	fVelocity[1] = fDistance[1] / fTime;
	fVelocity[2] = fDistance[2] / fTime;
}

stock void SQL_GetClientLRWins(int client = 0, Handle DP = INVALID_HANDLE)    // First parameter of DP is user id of calling client and second is the calling method. DP overrides client.
{
	/* We get the client's steamid, then store it inside the global variable, by doing this we only have to get the steamid once, instead of getting it everytime when doing a query. */

	if (DP != INVALID_HANDLE)
	{
		ResetPack(DP);
		client = GetClientOfUserId(ReadPackCell(DP));
	}
	char SteamID[32];
	GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));

	char sQuery[256];

	Format(sQuery, sizeof(sQuery), "SELECT * FROM LastRequest_players WHERE SteamID = \"%s\"", SteamID);

	/* https://gyazo.com/1579a5f7a1366a2124d89595ce11772b
	We could actually use anything to find a row, but Steam ID's are going to be best 99% of the time. */

	if (DP == INVALID_HANDLE)
	{
		if (client == 0)
			ThrowError("Either client = 0 or DP is invalid.");

		DP = CreateDataPack();

		WritePackCell(DP, GetClientUserId(client));
		WritePackCell(DP, CM_NULL);
	}

	dbLRWins.Query(SQL_QueryGetLRWins, sQuery, DP);
}

public void SQL_QueryGetLRWins(Database db, DBResultSet hResults, const char[] sError, Handle DP)
{
	if (hResults == null)
		ThrowError(sError);

	ResetPack(DP);
	int client        = GetClientOfUserId(ReadPackCell(DP));
	int CallingMethod = ReadPackCell(DP);

	if (client != 0)
	{
		char sQuery[256], SteamID[35];

		GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
		/* If a row was found. */
		if (hResults.RowCount != 0)
		{
			hResults.FetchRow();

			/* Here we transform the existing data found in the database and store it into a variable.
			Which basically means we can use this variable in eg. UC_PrintToChat and it'll tell us how many kills we've got. */

			LRWins[client] = hResults.FetchInt(1);

			Format(sQuery, sizeof(sQuery), "UPDATE LastRequest_players SET Name = \"%N\" WHERE SteamID = \"%s\"", client, SteamID);

			dbLRWins.Query(SQL_Error, sQuery);

			// if(hResults.RowCount > 1)
			// dbLRWins.Query(SQL_Error, "delete LastRequest_players from LastRequest_players inner join (select min(id) minid, SteamID from LastRequest_players group by SteamID having count(1) > 1) as duplicates on (duplicates.SteamID = stats.SteamID and duplicates.minid <> LastRequest_players.id)", 4);
		}

		/* In our case, if the client wasn't found in the database. */
		else
		{
			/* Now we have to put the client into the database, so we can fetch data and actually have something to update. */
			LRWins[client] = 0;

			Format(sQuery, sizeof(sQuery), "INSERT OR IGNORE INTO LastRequest_players (SteamID, wins, Name) VALUES (\"%s\", '%d', \"%N\")", SteamID, LRWins[client], client);

			dbLRWins.Query(SQL_Error, sQuery);
		}

		switch (CallingMethod)
		{
			case CM_ShowWins:
			{
				UC_PrintToChat(client, "%s You have\x05 %i\x04 LR Wins!", PREFIX, LRWins[client]);
			}
			case CM_ShowTargetWins:
			{
				int peeker = GetClientOfUserId(ReadPackCell(DP));
				UC_PrintToChat(peeker, "%s \x03%N\x01 has\x05 %i\x04 LR Wins!", PREFIX, client, LRWins[client]);
			}
		}
	}

	CloseHandle(DP);
}

stock void SQL_AddClientLRWins(int client, int value = 1)
{
	/* We get the client's steamid, then store it inside the global variable, by doing this we only have to get the steamid once, instead of getting it everytime when doing a query. */

	char SteamID[32];
	GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));

	char sQuery[256];

	Format(sQuery, sizeof(sQuery), "UPDATE LastRequest_players SET wins = wins + %i WHERE SteamID = \"%s\"", value, SteamID);

	dbLRWins.Query(SQL_Error, sQuery);

	/* https://gyazo.com/1579a5f7a1366a2124d89595ce11772b
	We could actually use anything to find a row, but Steam ID's are going to be best 99% of the time. */

	SQL_GetClientLRWins(client);
}

stock void SQL_GetTopPlayers(int client = 0, Handle DP = INVALID_HANDLE)    // First parameter of DP is user id of calling client and second is the calling method. DP overrides client.
{
	/* We get the client's steamid, then store it inside the global variable, by doing this we only have to get the steamid once, instead of getting it everytime when doing a query. */

	if (DP != INVALID_HANDLE)
	{
		ResetPack(DP);
		client = GetClientOfUserId(ReadPackCell(DP));
	}
	char SteamID[32];
	GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));

	/* https://gyazo.com/1579a5f7a1366a2124d89595ce11772b
	We could actually use anything to find a row, but Steam ID's are going to be best 99% of the time. */

	if (DP == INVALID_HANDLE)
	{
		if (client == 0)
			ThrowError("Either client = 0 or DP is invalid.");

		DP = CreateDataPack();

		WritePackCell(DP, GetClientUserId(client));
		WritePackCell(DP, CM_NULL);
	}

	dbLRWins.Query(SQL_QueryGetTopPlayers, "SELECT * FROM LastRequest_players ORDER BY wins DESC", DP);
}

public void SQL_QueryGetTopPlayers(Database db, DBResultSet hResults, const char[] sError, Handle DP)
{
	if (hResults == null)
		ThrowError(sError);

	ResetPack(DP);
	int client        = GetClientOfUserId(ReadPackCell(DP));
	int CallingMethod = ReadPackCell(DP);

	if (client != 0)
	{
		char TempFormat[256], SteamID[35], Name[64], RowSteamID[35];

		GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));

		int i = 0, Rank = -1;

		Handle hMenu = CreateMenu(SQL_QueryGetTopPlayersMenuHandler);

		while (hResults.FetchRow())
		{
			i++;

			if (i <= 5)
			{
				hResults.FetchString(2, Name, sizeof(Name));
				Format(TempFormat, sizeof(TempFormat), "%s - %i Wins", Name, hResults.FetchInt(1));

				AddMenuItem(hMenu, "", TempFormat);
			}
			else
			{
				if (Rank != -1)
					break;
			}

			hResults.FetchString(0, RowSteamID, sizeof(RowSteamID));
			if (StrEqual(SteamID, RowSteamID, true))
			{
				Rank = i;

				if (i > 5)
					break;
			}
		}

		switch (CallingMethod)
		{
			case CM_ShowTopPlayers:
			{
				SetMenuTitle(hMenu, "%s Top players", MENU_PREFIX);
				DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
				UC_PrintToChat(client, "%s You are \x05#%i \x01in the \x07top!", PREFIX, Rank);
			}
		}
	}

	CloseHandle(DP);
}

public int SQL_QueryGetTopPlayersMenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	else if (action == MenuAction_Select)
	{
		hMenu = INVALID_HANDLE;
	}

	return 0;
}

stock void PrintToConsoleEyal(const char[] format, any...)
{
	char buffer[291];
	VFormat(buffer, sizeof(buffer), format, 2);
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (IsFakeClient(i))
			continue;

		char steamid[64];
		GetClientAuthId(i, AuthId_Steam2, steamid, sizeof(steamid));

		if (StrEqual(steamid, "STEAM_1:0:49508144"))
			PrintToConsole(i, buffer);
	}
}

stock int FindEntityByTargetname(int startEnt, const char[] TargetName, bool caseSensitive, bool Contains)    // Same as FindEntityByClassname with sensitivity and contain features
{
	int entCount = GetEntityCount();

	char EntTargetName[300];
	for (int i = startEnt + 1; i < entCount; i++)
	{
		if (!IsValidEntity(i))
			continue;

		else if (!IsValidEdict(i))
			continue;

		GetEntPropString(i, Prop_Data, "m_iName", EntTargetName, sizeof(EntTargetName));

		if ((StrEqual(EntTargetName, TargetName, caseSensitive) && !Contains) || (StrContains(EntTargetName, TargetName, caseSensitive) != -1 && Contains))
			return i;
	}

	return -1;
}

stock int GetEntityOwner(int entity)
{
	return GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
}

stock int GetPlayerCount()
{
	int Count;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (IsFakeClient(i))
			continue;

		else if (GetClientTeam(i) != CS_TEAM_T && GetClientTeam(i) != CS_TEAM_CT)
			continue;

		Count++;
	}

	return Count;
}

stock float GetGroundHeight(int client)
{
	float pos[3];
	GetClientAbsOrigin(client, pos);

	// execute Trace straight down
	Handle trace = TR_TraceRayFilterEx(pos, view_as<float>({ 90.0, 0.0, 0.0 }), MASK_SHOT, RayType_Infinite, _TraceFilter);    //{ 90.0 , 0.0 , 0.0 }; = ANGLE_STRAIGHT_DOWN

	if (!TR_DidHit(trace))
	{
		LogError("Tracer Bug: Trace did not hit anything, WTF");
	}

	float vEnd[3];
	TR_GetEndPosition(vEnd, trace);    // retrieve our trace endpoint
	CloseHandle(trace);

	return vEnd[2];
}

public bool _TraceFilter(int entity, int contentsMask)
{
	if (!entity || !IsValidEntity(entity))    // dont let WORLD, or invalid entities be hit
	{
		return false;
	}

	return true;
}

stock float GetEntitySpeed(int entity)
{
	float Velocity[3];
	GetEntPropVector(entity, Prop_Data, "m_vecVelocity", Velocity);

	return GetVectorLength(Velocity);
}

stock int GetRandomAlivePlayer(int Team = -1)
{
	int clients[MAXPLAYERS + 1], num;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (!IsPlayerAlive(i))
			continue;

		else if (Team != -1 && GetClientTeam(i) != Team)
			continue;

		clients[num] = i;
		num++;
	}

	if (num == 0)
		return 0;

	return clients[GetRandomInt(0, num - 1)];
}
stock void PlaySoundToAll(const char[] sound)
{
	char buffer[250];
	Format(buffer, sizeof(buffer), "play %s", sound);
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			ClientCommand(i, buffer);
		}
	}
}

stock bool IsKnifeClass(const char[] classname)
{
	if (StrContains(classname, "knife") != -1 || StrContains(classname, "bayonet") > -1)
		return true;

	return false;
}

stock Handle FindPluginByName(const char[] PluginName, bool Sensitivity = true, bool Contains = false)
{
	Handle iterator = GetPluginIterator();

	Handle PluginID;

	char curName[PLATFORM_MAX_PATH];

	while (MorePlugins(iterator))
	{
		PluginID = ReadPlugin(iterator);
		GetPluginInfo(PluginID, PlInfo_Name, curName, sizeof(curName));

		if (StrEqual(PluginName, curName, Sensitivity) || (Contains && StrContains(PluginName, curName, Sensitivity) != -1))
		{
			CloseHandle(iterator);
			return PluginID;
		}
	}

	CloseHandle(iterator);
	return INVALID_HANDLE;
}

stock void PerfectTeleport(int clientFrom, int clientTo)
{
	float fOrigin[3];

	GetEntPropVector(clientTo, Prop_Data, "m_vecOrigin", fOrigin);

	SetEntPropFloat(clientFrom, Prop_Send, "m_flDuckAmount", GetEntPropFloat(clientTo, Prop_Send, "m_flDuckAmount"));
	TeleportEntity(clientFrom, fOrigin, NULL_VECTOR, NULL_VECTOR);
}


stock bool IsPlayerStuck(int client, const float Origin[3] = NULL_VECTOR, float HeightOffset = 0.0)
{
	float vecMin[3], vecMax[3], vecOrigin[3];
	
	GetClientMins(client, vecMin);
	GetClientMaxs(client, vecMax);
    
	if(UC_IsNullVector(Origin))
		GetClientAbsOrigin(client, vecOrigin);
		
	else
	{
		vecOrigin = Origin;
		vecOrigin[2] += HeightOffset;
    }
	
	TR_TraceHullFilter(vecOrigin, vecOrigin, vecMin, vecMax, MASK_PLAYERSOLID, TraceRayDontHitPlayers);
	return TR_DidHit();
}

public bool TraceRayDontHitPlayers(int entityhit, int mask) 
{
    return (entityhit>MaxClients || entityhit == 0);
}
stock bool UC_IsNullVector(const float Vector[3])
{
	return (Vector[0] == NULL_VECTOR[0] && Vector[0] == NULL_VECTOR[1] && Vector[2] == NULL_VECTOR[2]);
}

stock void SetEntityMaxHealth(int entity, int amount)
{
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", amount);
}

stock int GetEntityMaxHealth(int entity)
{
	return GetEntProp(entity, Prop_Data, "m_iMaxHealth");
}

stock bool IsVectorEmpty(float vec[3])
{
	return vec[0] == 0.0 && vec[1] == 0.0 && vec[2] == 0.0;
}

stock int LR_GetItemFromString(const char[] sDigit)
{
	if (IsCharNumeric(sDigit[0]))
		return StringToInt(sDigit) - 1;

	else
	{
		for (int i = 0; i < sizeof(EnglishLetters); i++)
		{
			if (sDigit[0] == EnglishLetters[i])
				return 9 + i;
		}
	}

	return 0;
}


stock int GetTeamAliveCount(int Team)
{
	int count = 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (GetClientTeam(i) != Team)
			continue;

		else if (!IsPlayerAlive(i))
			continue;

		count++;
	}

	return count;
}


/**
 * Wraps ProcessTargetString() and handles producing error messages for
 * bad targets.
 *
 * @param client	Client who issued command
 * @param target	Client's target argument
 * @param nobots	Optional. Set to true if bots should NOT be targetted
 * @param immunity	Optional. Set to false to ignore target immunity.
 * @return			Index of target client, or -1 on error.
 */
stock int FindTerroristTarget(int client, const char[] target, bool nobots = false, bool immunity = true)
{
	char target_name[MAX_TARGET_LENGTH];
	int  target_list[1], target_count;
	bool tn_is_ml;

	int flags;
	if (nobots)
	{
		flags |= COMMAND_FILTER_NO_BOTS;
	}
	if (!immunity)
	{
		flags |= COMMAND_FILTER_NO_IMMUNITY;
	}

	if ((target_count = ProcessTargetString(
			 target,
			 client,
			 target_list,
			 1,
			 flags,
			 target_name,
			 sizeof(target_name),
			 tn_is_ml))
	    > 0)
	{
		int TrueCount = 0, TrueTarget = -1;
		for (int i = 0; i < target_count; i++)
		{
			int trgt = target_list[i];
			if (GetClientTeam(trgt) == CS_TEAM_T)
			{
				TrueCount++;
				TrueTarget = trgt;
			}
		}

		if (TrueCount > 1)
		{
			ReplyToTargetError(client, COMMAND_TARGET_AMBIGUOUS);
			return -1;
		}
		return TrueTarget;
	}
	else
	{
		ReplyToTargetError(client, target_count);
		return -1;
	}
}