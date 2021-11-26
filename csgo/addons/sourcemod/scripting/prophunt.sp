#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <clientprefs>
#include <cstrike>

#include <smlib> // https://github.com/bcserv/smlib
#include <soundlib> // https://forums.alliedmods.net/showthread.php?t=105816
#include <csgocolors> // https://gitlab.com/Zipcore/CSGO-Colors
#include <zstocks> // https://gitlab.com/Zipcore/zStocks/tree/master
#include <speedrules> // https://gitlab.com/Zipcore/speedrules
#include <emitsoundany> // https://forums.alliedmods.net/showthread.php?t=237045

#define PLUGIN_VERSION "3.0.0"

public Plugin myinfo = 
{
	name = "Prop Hunt",
	author = ".#Zipcore, Credits: statistician, selax & peacemaker",
	description = "3rd generation Prop Hunt (aka. Hide & Seek) for CS:GO.",
	version = PLUGIN_VERSION,
	url = "zipcore.net"
};

#pragma newdecls required

#include <prophunt>

#include "prophunt/globals.sp" // Global variables
#include "prophunt/stocks.sp" // Various functions
#include "prophunt/convars.sp" // ConVars

#include "prophunt/commands.sp" // Player commands

#include "prophunt/events_client.sp" // Client events
#include "prophunt/events_map.sp" // Map events
#include "prophunt/events_round.sp" // Round events
#include "prophunt/events_team.sp" // Team events

#include "prophunt/teams.sp" // Team queue, balancer, etc.

#include "prophunt/model_fakeprop.sp" // Manages the client's fake model
#include "prophunt/model_hit.sp" // Fake model hit detection
#include "prophunt/model_freeze.sp" // Client freeze handler
#include "prophunt/model_menu.sp" // Model selection menu
#include "prophunt/model_admin.sp" // Admin menu to test and adjust models

#include "prophunt/seeker_freeze.sp" // Blind and freeze CTs

#include "prophunt/mapmodels.sp" // Loads and spawns props around the map
#include "prophunt/mapcleaner.sp" // Removed unwanted stuff from the maps
#include "prophunt/health.sp" // Seeker health system
#include "prophunt/noblock.sp" // Player collision
#include "prophunt/noblood.sp" // Removes blood
#include "prophunt/taunt.sp" // Tauntsounds / -Packs
#include "prophunt/usermessages.sp" // Usermessage hooks
#include "prophunt/shop.sp" // Shop
#include "prophunt/shop_items.sp" // Shop Items
#include "prophunt/api.sp" // Natives
#include "prophunt/hud.sp" // HUD

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if(late)
	{
		InitConVars();
		UpdateTeams(); 
	}
	
	CreateForwards(); // Create forwards
	CreateNatives(); // Handle native callbacks
	CreateShopList(); // Create shop arrays
	
	RegPluginLibrary("prophunt");
	
	return APLRes_Success;
}

public void OnPluginStart()
{
	LoadTranslations("plugin.prophunt");
	
	CreateConVar("ph_version", PLUGIN_VERSION, "PropHunt version", FCVAR_SPONLY | FCVAR_REPLICATED | FCVAR_NOTIFY | FCVAR_DONTRECORD);
	
	InitConVars(); // Create ConVars
	RegisterCommands(); // Create commands
	
	HookEvent("player_spawn", Event_OnPlayerSpawn);
	HookEvent("player_death", Event_OnPlayerDeath);
	HookEvent("player_death", Event_OnPlayerDeath_Pre, EventHookMode_Pre);
	
	HookEvent("weapon_fire", Event_OnWeaponFire);
	
	HookEvent("round_prestart", Event_OnRoundPreStart);
	HookEvent("round_start", Event_OnRoundStart);
	HookEvent("round_poststart", Event_OnRoundPostStart);
	
	HookEvent("round_end", Event_OnRoundEnd);
	HookEvent("round_end", Event_OnRoundEnd_Pre, EventHookMode_Pre);
	
	HookEvent("player_team", Event_OnPlayerTeam);
	HookEvent("player_team", Event_OnPlayerTeam_Pre, EventHookMode_Pre);
	
	HookEvent("item_equip", Event_ItemEquip); // Update weapon type and stats
	
	AddCommandListener(Hook_OnWeaponDrop, "drop"); // Used as binding
	
	AddCommandListener(Command_Say, "say"); 
	AddCommandListener(Command_Say, "say_team");
	
	HookUserMessage(GetUserMessageId("TextMsg"), MsgHook_AdjustMoney, true); // Remove money HUD & messages
	
	AddCommandListener(Hook_ChangeTeamChange, "jointeam"); // Balance teams
	
	AddTempEntHook("EffectDispatch", TE_OnEffectDispatch); // Used to remove effects
	AddTempEntHook("World Decal", TE_OnWorldDecal); // Used to remove effects
	
	/* Cookies */
	
	g_hCookieTauntPack = RegClientCookie("ph_taunt_pack", "ph_taunt_pack", CookieAccess_Public);
	g_hCookieHudMode = RegClientCookie("ph_hud_mode", "ph_hud_mode", CookieAccess_Public);
	
	/* Late load */
	
	LoopIngameClients(iClient)
	{
		OnClientCookiesCached(iClient);
		OnClientPutInServer(iClient);
	}
	
	StartBlindTimer(); // This timer checks which players should be blind during hide time
	StartPointsTimer(); // Give player points based on different rules like being frozen or not
	StartHUDTimer(); // Update HUD
	StartTauntOverloadTimer(); // Check taunt overload
}

public void OnConfigsExecuted()
{
	RegisterItems(); // Add shop items or update them
}

bool Ready()
{
	return g_bLoaded && g_cvEnabled.BoolValue;
}