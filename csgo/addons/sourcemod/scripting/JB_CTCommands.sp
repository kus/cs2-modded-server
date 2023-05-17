#include <basecomm>
#include <cstrike>
#include <eyal-jailbreak>
#include <sdkhooks>
#include <sdktools>
#include <smlib>
#include <sourcemod>
#include <emitsoundany>

#define MAX_MARKERS 5

#define PLUGIN_VERSION "1.0"

#pragma semicolon 1
#pragma newdecls  required

native int Eyal282_VoteCT_GetChosenUserId();
native bool Eyal282_VoteCT_IsChosen(int client);
native bool Eyal282_VoteCT_IsTreatedWarden(int client);
native bool Eyal282_VoteCT_IsPreviewRound();
native bool JailBreakDays_IsDayActive();
native bool LR_isActive();

public Plugin myinfo =
{
	name        = "JailBreak CT Commands",
	author      = "Eyal282, merged Skyler's JailAddons into this",
	description = "The most important and basic commands for CT.",
	version     = PLUGIN_VERSION,
	url         = ""
};

char   PREFIX[256];
char   MENU_PREFIX[64];
Handle hcv_Prefix     = INVALID_HANDLE;
Handle hcv_MenuPrefix = INVALID_HANDLE;

bool IsVIP[MAXPLAYERS + 1];
bool g_bSpeaking[MAXPLAYERS+1];

float g_fStartBreakOpen[MAXPLAYERS+1];
float g_fNextBreakOpen[MAXPLAYERS+1];
float g_fNextDamagePlayer[MAXPLAYERS+1];
float g_fNextDamageBreakable[MAXPLAYERS+1];

int BeamIndex, HaloIdx;    // HaloIndex is stolen by an include.

Handle hcv_TeammatesAreEnemies = INVALID_HANDLE;
Handle hcv_CKHealthPerT        = INVALID_HANDLE;
Handle hcv_VoicePriorityMode = INVALID_HANDLE;
ConVar hcv_MuteTTime;
ConVar hcv_MinTMute;
ConVar hcv_MedicCooldown;
ConVar hcv_Laser;
ConVar hcv_LaserDistance;
ConVar hcv_LaserCrack;
ConVar hcv_TimeToCrack;
ConVar hcv_LaserDamageToPlayers;
ConVar hcv_LaserDamageToVents;

Handle hTimer_Beacon          = INVALID_HANDLE;
bool   nospam[MAXPLAYERS + 1] = { false, ... };

float g_fMuteEnd;

Handle hcv_DeadTalk = INVALID_HANDLE;

Handle hTimer_ExpireMute = INVALID_HANDLE;

bool CKEnabled = false;

bool bCanZoom[MAXPLAYERS + 1] = { true, ... }, bHasSilencer[MAXPLAYERS + 1] = { true, ... }, bWrongWeapon[MAXPLAYERS + 1] = { true, ... };

ArrayList aMarkers = null;

enum enDoorState
{
	STATE_INVALID = -1,
	STATE_CLOSED = 0,
	STATE_OPENING = 1,
	STATE_OPENED = 2,
	STATE_CLOSING = 3
}
enum enPropDoorState
{
	PROP_STATE_CLOSED = 0,
	PROP_STATE_OPENING = 1,
	PROP_STATE_OPENED = 2,
	PROP_STATE_CLOSING = 3
}


enum enFuncDoorState
{
	FUNC_STATE_OPENED = 0,
	FUNC_STATE_CLOSED = 1,
	FUNC_STATE_OPENING = 2,
	FUNC_STATE_CLOSING = 3
}

int g_iLaserColors[8][4] = 
{
	{255, 255, 255, 255}, // white
	{255, 0, 0, 255}, // red
	{20, 255, 20, 255}, // green
	{0, 65, 255, 255}, // blue
	{255, 255, 0, 255}, // yellow
	{0, 255, 255, 255}, // cyan
	{255, 0, 255, 255}, // magenta
	{255, 80, 0, 255}  // orange
};

enum struct markerEntry
{
	float origin[3];
	float radius;
}
public void OnPluginStart()
{
	LoadTranslations("common.phrases.txt");    // Fixing errors in target, something skyler didn't do haha.

	RegConsoleCmd("sm_box", Command_Box, "Enables friendlyfire for the terrorists");
	RegConsoleCmd("sm_ff", Command_Box, "Enables friendlyfire for the terrorists");
	RegConsoleCmd("sm_fd", Command_FD, "Turns on glow on a player");
	RegConsoleCmd("sm_ck", Command_CK, "Turns on CK for the rest of the vote CT");
	//RegConsoleCmd("sm_sort", Command_Sort, "Randomly sorts every T.");

	RegConsoleCmd("sm_medic", Command_Medic, "");
	RegConsoleCmd("sm_deagle", Command_Deagle, "");

	RegAdminCmd("sm_silentstopck", Command_SilentStopCK, ADMFLAG_ROOT, "Turns off CK silently");

	hcv_TeammatesAreEnemies = FindConVar("mp_teammates_are_enemies");
	hcv_DeadTalk            = FindConVar("sm_deadtalk");

	if(hcv_DeadTalk == INVALID_HANDLE)
		hcv_DeadTalk = CreateConVar("sm_deadtalk", "0", "Can players hear dead players?");

	AutoExecConfig_SetFile("JB_CTCommands", "sourcemod/JBPack");

	hcv_CKHealthPerT = UC_CreateConVar("jbpack_ck_health_per_t", "20", "Amount of health a CT gains per T. Formula: 100 + ((cvar * tcount) / ctcount)");
	hcv_VoicePriorityMode    = UC_CreateConVar("jbpack_voice_priority", "2", "0 - No Voice Priority.\n1 - Voice Priority of CT over T.\n2 - Voice Priority of CT over T, AND Voice Priority of Chosen CT over CT");
	hcv_MuteTTime    = UC_CreateConVar("jbpack_t_mute_time", "30.0", "Set the mute timer on round start, or set to -1 to prevent T from talking entirely");
	hcv_MedicCooldown = UC_CreateConVar("jbpack_medic_cooldown", "60", "Cooldown for sm_medic");
	hcv_MinTMute       = UC_CreateConVar("jbpack_min_t_mute", "2", "Minimum amount of T before round start mute occurs");
	hcv_Laser = UC_CreateConVar("jbpack_ct_laser", "1", "Enable CT laser in E");
	hcv_LaserDistance = UC_CreateConVar("jbpack_ct_laser_distance", "350.0", "Distance at which laser special effects activate");
	hcv_LaserCrack = UC_CreateConVar("jbpack_ct_laser_crack_doors", "1", "CT Laser can crack open doors");
	hcv_TimeToCrack = UC_CreateConVar("jbpack_ct_laser_crack_time", "5.0", "Time for CT Laser to crack open doors");
	hcv_LaserDamageToPlayers = UC_CreateConVar("jbpack_ct_laser_damage_to_players", "-25.0", "Damage dealt to players each second. Negative damage heals");
	hcv_LaserDamageToVents = UC_CreateConVar("jbpack_ct_laser_damage_to_vents", "250.0", "Damage dealt to vents each second");

	AutoExecConfig_ExecuteFile();

	AutoExecConfig_CleanFile();


	HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
	HookEvent("item_equip", Event_ItemEquip, EventHookMode_Post);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_team", Event_PlayerTeamNoCopy, EventHookMode_PostNoCopy);

	aMarkers = CreateArray(sizeof(markerEntry));

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		OnClientPutInServer(i);
	}
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

public void cvChange_Prefix(Handle convar, const char[] oldValue, const char[] newValue)
{
	FormatEx(PREFIX, sizeof(PREFIX), newValue);
}

public void cvChange_MenuPrefix(Handle convar, const char[] oldValue, const char[] newValue)
{
	FormatEx(MENU_PREFIX, sizeof(MENU_PREFIX), newValue);
}

enum struct g_message
{
    char message[512];
    // In seconds
    int timeleft;
}


public Action OnMuteIndicate(int client, bool realtime, ArrayList messages)
{
	switch(CheckVoicePriority(client))
	{
		case 1:
		{
			if(GetClientTeam(client) == CS_TEAM_T)
			{
				g_message msg;
				FormatEx(msg.message, sizeof(g_message::message), "You are muted as T.");
				msg.timeleft = -4;
				messages.PushArray(msg);
			}

		}
		case 2:
		{
			if(GetClientTeam(client) == CS_TEAM_T)
			{
				g_message msg;
				FormatEx(msg.message, sizeof(g_message::message), "You are muted as T.\nYou will be unmuted in %.1f seconds", g_fMuteEnd - GetGameTime());
				msg.timeleft = RoundToCeil(g_fMuteEnd - GetGameTime());

				messages.PushArray(msg);
			}
		}
		case 3:
		{
			if(GetClientTeam(client) == CS_TEAM_T)
			{
				g_message msg;
				FormatEx(msg.message, sizeof(g_message::message), "You are muted while CT is talking.");
				msg.timeleft = -4;
				messages.PushArray(msg);
			}
		}
		case 4:
		{
			g_message msg;

			if(GetClientTeam(client) == CS_TEAM_CT)
				FormatEx(msg.message, sizeof(g_message::message), "You are muted while Chosen CT is talking.");

			else
				FormatEx(msg.message, sizeof(g_message::message), "You are muted while CT is talking.");
			
			
			msg.timeleft = -4;
			messages.PushArray(msg);
		}
		default: return Plugin_Continue;
	}
	return Plugin_Changed;
}
public void OnClientSpeaking(int client)
{
	if(!g_bSpeaking[client])
	{
		g_bSpeaking[client] = true;

		CheckVoicePriority();
	}
}

public void OnClientSpeakingEnd(int client)
{
	if(g_bSpeaking[client])
	{
		g_bSpeaking[client] = false;

		CheckVoicePriority();
	}
}


// 0 for generic priority.
// 1 for generic T mute.
// 2 for mute by time.
// 3 for Mute by talking CT.
// 4 for Mute by talking Chosen CT.
stock int CheckVoicePriority(int client=0)
{	
	if(client == 0 || GetClientTeam(client) == CS_TEAM_T)
	{
		if(hcv_MuteTTime.FloatValue < 0.0)
			return 1;

		else if(hTimer_ExpireMute != INVALID_HANDLE)
			return 2;
	}

	else if(GetTeamClientCount(CS_TEAM_T) < GetConVarInt(hcv_MinTMute))
		return 0;

	switch(GetConVarInt(hcv_VoicePriorityMode))
	{
		case 1:
		{
			if(hTimer_ExpireMute != INVALID_HANDLE)
				return 2;

			bool priority = false;

			for(int i=1;i <= MaxClients;i++)
			{
				if(!IsClientInGame(i))
					continue;

				else if(!g_bSpeaking[i])
					continue;
					
				else if(GetClientTeam(i) != CS_TEAM_CT)
					continue;
					
				else if(!IsPlayerAlive(i))
					continue;
					
				priority = true;
				break;
			}

			if(priority)
			{
				for(int i=1;i <= MaxClients;i++)
				{		
					if(!IsClientInGame(i))
						continue;

					else if(GetClientTeam(i) == CS_TEAM_CT && IsPlayerAlive(i))
						continue;
						
					else if(CheckCommandAccess(i, "sm_admin", ADMFLAG_GENERIC))
						continue;

					SetClientListeningFlags(i, VOICE_MUTED);
				}

				return 3;
			}
			else
			{
				RestoreTalkingRights();
				return 0;
			}
		}

		case 2:
		{
			int chosen = GetClientOfUserId(Eyal282_VoteCT_GetChosenUserId());

			if(chosen != 0)
			{
				if(g_bSpeaking[chosen])
				{
					for(int i=1;i <= MaxClients;i++)
					{		
						if(chosen == i)
							continue;

						else if(!IsClientInGame(i))
							continue;

						else if(CheckCommandAccess(i, "sm_admin", ADMFLAG_GENERIC))
							continue;

						SetClientListeningFlags(i, VOICE_MUTED);
					}

					return 4;
				}
			}

			if(hTimer_ExpireMute != INVALID_HANDLE)
				return 2;

			bool priority = false;

			for(int i=1;i <= MaxClients;i++)
			{
				if(!IsClientInGame(i))
					continue;

				else if(!g_bSpeaking[i])
					continue;
					
				else if(GetClientTeam(i) != CS_TEAM_CT)
					continue;
					
				else if(!IsPlayerAlive(i))
					continue;
					
				priority = true;
				break;
			}

			if(priority)
			{
				for(int i=1;i <= MaxClients;i++)
				{
					if(!IsClientInGame(i))
						continue;

					else if(GetClientTeam(i) == CS_TEAM_CT && IsPlayerAlive(i))
						continue;
						
					else if(CheckCommandAccess(i, "sm_admin", ADMFLAG_GENERIC))
						continue;

					SetClientListeningFlags(i, VOICE_MUTED);
				}

				return 3;
			}
			
			RestoreTalkingRights();
			return 0;
		}

		default:
		{
			if(hTimer_ExpireMute != INVALID_HANDLE)
				return 2;

			return 0;
		}
	}
}
// cmd = Were the cells opened by command or with button.
// note: This forward will fire if sm_open was used in any way.
// note: This forward will NOT fire if the cells were opened without being assigned.
public void SmartOpen_OnCellsOpened(bool cmd)
{
	if (cmd && hTimer_ExpireMute != INVALID_HANDLE && hcv_MuteTTime.FloatValue > 0.0)
	{
		CloseHandle(hTimer_ExpireMute);
		hTimer_ExpireMute = INVALID_HANDLE;
		UC_PrintToChatAll("%s The \x02terrorists \x01got unmuted through\x05 sm_open", PREFIX);

		RestoreTalkingRights();
	}
}

public void OnMapStart()
{
	for(int i=0;i <= MAXPLAYERS;i++)
	{
		g_bSpeaking[i] = false;
		g_fStartBreakOpen[i] = -1.0;
		g_fNextBreakOpen[i] = -1.0;
		g_fNextDamagePlayer[i] = -1.0;
		g_fNextDamageBreakable[i] = -1.0;
	}

	BeamIndex   = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	HaloIdx     = PrecacheModel("materials/sprites/glow01.vmt", true);

	PrecacheSoundAny("buttons/button11.wav", true);
	PrecacheSoundAny("items/medshot4.wav", true);
	PrecacheSoundAny("hostage/hpain/hpain6.wav", true);
	PrecacheSoundAny("*buttons/button11.wav", true);
	PrecacheSoundAny("*items/medshot4.wav", true);
	PrecacheSoundAny("*hostage/hpain/hpain6.wav", true);

	CKEnabled = false;

	hTimer_ExpireMute = INVALID_HANDLE;
	hTimer_Beacon     = INVALID_HANDLE;
	g_fMuteEnd = 0.0;

	if (!JailBreakDays_IsDayActive())
		SetConVarBool(hcv_TeammatesAreEnemies, false);

	CreateTimer(0.5, Timer_DrawMarkers, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
}

public Action Timer_DrawMarkers(Handle hTimer)
{
	for (int i = 0; i < GetArraySize(aMarkers); i++)
	{
		markerEntry entry;

		GetArrayArray(aMarkers, i, entry);

		float Origin[3], Radius;

		Origin = entry.origin;
		Radius = entry.radius;

		int colors[4] = { 0, 0, 255, 255 };
		TE_SetupBeamRingPoint(Origin, Radius, Radius + 0.1, BeamIndex, HaloIdx, 0, 10, 0.51, 5.0, 0.0, colors, 10, 0);
		TE_SendToAll();
	}

	return Plugin_Continue;
}

#define MAX_BUTTONS 26

int   g_LastButtons[MAXPLAYERS + 1];
float g_fPressTime[MAXPLAYERS + 1][MAX_BUTTONS + 1];

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	if (buttons & IN_USE)
	{
		if(Eyal282_VoteCT_IsTreatedWarden(client) && IsPlayerAlive(client) && !LR_isActive() && GetConVarBool(hcv_Laser))
		{
			// true Target is the actual target in your aim, ignoring parenting. This is for GetAimDistanceFromTarget
			int trueTarget;
			int target = JB_GetClientAimTarget(client, trueTarget);

			if(target != -1)
			{
				if(GetAimDistanceFromTarget(client, trueTarget) <= GetConVarFloat(hcv_LaserDistance))
				{
					char Classname[64];
					GetEdictClassname(target, Classname, sizeof(Classname));

					if(StrEqual(Classname, "func_door") || StrEqual(Classname, "prop_door_rotating"))
					{
						float fVelocity[3];

						GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);

						if(GetVectorLength(fVelocity) == 0.0 && GetConVarBool(hcv_LaserCrack))
						{
							if(GetDoorState(target) == STATE_CLOSED)
							{
								if(g_fNextBreakOpen[client] == -1.0)
								{
									FireLaserBeam(client);

									g_fNextBreakOpen[client] = GetGameTime() + GetConVarFloat(hcv_TimeToCrack);
									g_fStartBreakOpen[client] = GetGameTime();
								}
								else if(g_fNextBreakOpen[client] <= GetGameTime())
								{
									PrintCenterText(client, "Cracking open door...\nProgress: 100%%");
									g_fNextBreakOpen[client] = -1.0;

									int bLocked = GetEntProp(target, Prop_Data, "m_bLocked");

									AcceptEntityInput(target, "Unlock");
									AcceptEntityInput(target, "Open");

									if(bLocked)
										AcceptEntityInput(target, "Lock");
								}
								else
								{
									PrintCenterText(client, "Cracking open door...\nProgress: %i%%", RoundToFloor(100.0 - ((((g_fNextBreakOpen[client] - GetGameTime()) / GetConVarFloat(hcv_TimeToCrack)) * 100.0))));

									FireLaserBeam(client);
								}
							}
							else
							{
								FireLaserBeam(client);

								g_fNextBreakOpen[client] = -1.0;
							}
						}
						else
						{
							FireLaserBeam(client);

							g_fNextBreakOpen[client] = -1.0;
						}

					}
					else
					{
						if(!StrEqual(Classname, "func_button"))
						{
							if(g_fNextDamageBreakable[client] <= GetGameTime() && StrEqual(Classname, "func_breakable") && GetConVarFloat(hcv_LaserDamageToVents) >= 0.0)
							{
								g_fNextDamageBreakable[client] = GetGameTime() + 1.0;
								SDKHooks_TakeDamage(target, client, client, GetConVarFloat(hcv_LaserDamageToVents), DMG_BULLET, _, _, _, false);
							}

							// IsPlayer instead of IsClientInGame because we're checking if the object is in range of 
							else if(g_fNextDamagePlayer[client] <= GetGameTime() && IsPlayer(target) && GetClientTeam(target) == CS_TEAM_T && GetConVarFloat(hcv_LaserDamageToPlayers) != 0.0)
							{
								g_fNextDamagePlayer[client] = GetGameTime() + 1.0;
								
								if(GetConVarFloat(hcv_LaserDamageToPlayers) > 0.0)
								{
									SDKHooks_TakeDamage(target, client, client, GetConVarFloat(hcv_LaserDamageToPlayers), DMG_BURN, _, _, _, false);

									float fOrigin[3];
									GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", fOrigin);

									EmitSoundByDistanceAny(512.0, "hostage/hpain/hpain6.wav", -2, 0, 75, 0, 1.0, 100, -1, fOrigin, NULL_VECTOR, true, 0.0);
								}

								else
								{
									if(GetEntityHealth(target) >= GetEntityMaxHealth(target))
									{
										ClientCommand(client, "play buttons/button11.wav");
									}
									else
									{
										// Double minus is plus. This thing heals.
										SetEntityHealth(target, GetEntityHealth(target) - GetConVarInt(hcv_LaserDamageToPlayers));

										if(GetEntityHealth(target) > GetEntityMaxHealth(target))
											SetEntityHealth(target, GetEntityMaxHealth(target));

										float fOrigin[3];
										GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", fOrigin);

										EmitSoundByDistanceAny(512.0, "items/medshot4.wav", -2, 0, 75, 0, 1.0, 100, -1, fOrigin, NULL_VECTOR, true, 0.0);
									}
								}
							}

							FireLaserBeam(client);
						}

						g_fNextBreakOpen[client] = -1.0;
					}
				}
				else
				{
					FireLaserBeam(client);

					g_fNextBreakOpen[client] = -1.0;
					
				}
			}
			else
			{
				FireLaserBeam(client);
			}
		}
	}

	if(IsPlayerAlive(client))
	{
		for (int i = 0; i < MAX_BUTTONS; i++)
		{
			int button = (1 << i);

			if ((buttons & button))
			{
				if (!(g_LastButtons[client] & button))
				{
					g_fPressTime[client][i] = GetGameTime();
					OnButtonPress(client, button);
				}
			}
			else if ((g_LastButtons[client] & button))
			{
				OnButtonRelease(client, button, GetGameTime() - g_fPressTime[client][i]);
			}
		}
	}

	g_LastButtons[client] = buttons;

	return Plugin_Continue;
}

public void OnButtonPress(int client, int button)
{
}

public void OnButtonRelease(int client, int button, float holdTime)
{
	if(button != IN_ATTACK2)
		return;

	else if (bWrongWeapon[client] || bCanZoom[client] || bHasSilencer[client])
		return;

	else if (!Eyal282_VoteCT_IsTreatedWarden(client))
		return;

	else if (LR_isActive())
		return;

	// Releasing without hold = create marker.
	// Releasing with a short hold could be a regret of action.
	// Releasing with a second hold = delete marker.
	if (holdTime < 0.2)
	{
		CreateMarker(client);

		if (GetArraySize(aMarkers) == 1)
			UC_PrintToChat(client, "Hint: Hold +attack2 for a second to clear all marks.");
	}
	else if (holdTime >= 1.0)
	{
		DeleteAllMarkers();
	}
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_TraceAttack, Hook_TraceAttack);
	SDKHook(client, SDKHook_OnTakeDamage, Hook_OnTakeDamage);
	SDKHook(client, SDKHook_WeaponCanUse, Hook_WeaponCanUse);
}

public Action Hook_OnTakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype)
{
	int    dummy_value1, dummy_value2, dummy_value3;
	Action rtn = Hook_TraceAttack(victim, attacker, inflictor, damage, damagetype, dummy_value1, dummy_value2, dummy_value3);
	return rtn;
}

public Action Hook_TraceAttack(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& ammotype, int hitbox, int hitgroup)
{
	if (!IsEntityPlayer(attacker))
		return Plugin_Continue;

	else if (JailBreakDays_IsDayActive())
		return Plugin_Continue;

	else if (LR_isActive())
		return Plugin_Continue;

	else if (GetClientTeam(victim) != GetClientTeam(attacker))
		return Plugin_Continue;

	// Team killing...
	else if (GetClientTeam(victim) == CS_TEAM_CT)
	{
		damage = 0.0;
		return Plugin_Stop;
	}

	char sClassname[64];
	GetEdictClassname(inflictor, sClassname, sizeof(sClassname));
	// Grenade damage in box...
	if (!StrEqual(sClassname, "player"))
	{
		damage = 0.0;
		return Plugin_Stop;
	}

	sClassname[0] = EOS;

	int weapon = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon");

	if (weapon != -1)
		GetEdictClassname(weapon, sClassname, sizeof(sClassname));

	// Trying to shoot teammates? Cringe.
	if (GetConVarInt(hcv_TeammatesAreEnemies) > 0 && GetConVarInt(hcv_TeammatesAreEnemies) < 3 && strncmp(sClassname, "weapon_knife", 12) != 0)
	{
		damage = 0.0;
		return Plugin_Stop;
	}

	sClassname[0] = EOS;

	weapon = GetEntPropEnt(victim, Prop_Send, "m_hActiveWeapon");

	if (weapon != -1)
		GetEdictClassname(weapon, sClassname, sizeof(sClassname));

	// Trying to stab rebels? Cringe.
	if (GetConVarInt(hcv_TeammatesAreEnemies) > 0 && GetConVarInt(hcv_TeammatesAreEnemies) < 3 && strncmp(sClassname, "weapon_knife", 12) != 0)
	{
		damage = 0.0;
		return Plugin_Stop;
	}

	// Damage is less than 69 if not a backstab.
	else if (GetConVarInt(hcv_TeammatesAreEnemies) == 2 && damage < 69)
	{
		damage = 0.0;
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public Action Hook_WeaponCanUse(int client, int weapon)
{
	if (!CKEnabled || GetTeamPlayerCount(CS_TEAM_T, true) == 1)
		return Plugin_Continue;

	char Classname[15];
	GetEdictClassname(weapon, Classname, sizeof(Classname));

	if (StrEqual(Classname, "weapon_knife"))
		return Plugin_Continue;

	AcceptEntityInput(weapon, "Kill");
	return Plugin_Handled;
}

public Action Event_RoundStart(Event hEvent, const char[] Name, bool dontBroadcast)
{
	SetConVarBool(hcv_TeammatesAreEnemies, false);

	if (CKEnabled)
	{
		int Count = GetEntityCount();
		for (int i = MaxClients; i < Count; i++)
		{
			if (!IsValidEntity(i))
				continue;

			char Classname[15];
			GetEntityClassname(i, Classname, sizeof(Classname));

			if (strncmp(Classname, "weapon_", 7) != 0)
				continue;

			else if (StrEqual(Classname, "weapon_knife"))
				continue;

			AcceptEntityInput(i, "Kill");
		}
	}

	DeleteAllMarkers();

	ServerCommand("mp_forcecamera 1");
	ServerCommand("sm_silentcvar sv_full_alltalk 1");

	if (GetTeamAliveCount(CS_TEAM_T) < hcv_MinTMute.IntValue)
	{
		if (hTimer_ExpireMute != INVALID_HANDLE)
		{
			CloseHandle(hTimer_ExpireMute);
			hTimer_ExpireMute = INVALID_HANDLE;
		}

		UC_PrintToChatAll("%s The \x02terrorist \x01are not muted, they can talk now.", PREFIX);
		return Plugin_Continue;
	}

	if (hTimer_ExpireMute != INVALID_HANDLE)
	{
		CloseHandle(hTimer_ExpireMute);
		hTimer_ExpireMute = INVALID_HANDLE;
	}

	if(hcv_MuteTTime.FloatValue > 0)
	{
		hTimer_ExpireMute = CreateTimer(hcv_MuteTTime.FloatValue, MuteHandler);
		g_fMuteEnd = GetGameTime() + hcv_MuteTTime.FloatValue;

		RestoreTalkingRights();

		UC_PrintToChatAll("%s The \x02terrorist \x01have been muted, they will be able to speak in \x05%d \x01seconds", PREFIX, hcv_MuteTTime.IntValue);
	}
	else if(hcv_MuteTTime.FloatValue <= 0)
	{
		RestoreTalkingRights();
	}

	return Plugin_Continue;
}

public Action Event_PlayerSpawn(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));

	IsVIP[client] = false;
	SetEntityRenderMode(client, RENDER_NORMAL);
	SetEntityRenderFx(client, RENDERFX_NONE);
	SetEntityRenderColor(client, 255, 255, 255, 255);

	if (CKEnabled)
		CreateTimer(0.2, AddHealthCT, GetEventInt(hEvent, "userid"));

	RestoreTalkingRights();

	return Plugin_Continue;
}

// Shamelessly stolen from MyJailBreak, Shanapu
public Action Event_ItemEquip(Event event, const char[] Name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	bCanZoom[client]     = event.GetBool("canzoom");
	bHasSilencer[client] = event.GetBool("hassilencer");
	bWrongWeapon[client] = false;

	int wepType = event.GetInt("weptype");

	if (wepType == 0 || wepType == 9)
	{
		bWrongWeapon[client] = true;
	}

	return Plugin_Continue;
}

public Action AddHealthCT(Handle hTimer, int UserId)
{
	int client = GetClientOfUserId(UserId);

	if (client == 0)
		return Plugin_Continue;

	else if (GetClientTeam(client) != CS_TEAM_CT)
		return Plugin_Continue;

	else if (!IsPlayerAlive(client))
		return Plugin_Continue;

	int health = GetEntProp(client, Prop_Send, "m_iHealth");

	// Cannot divide by zero here, because the current client must be a living ct.
	health += ((GetConVarInt(hcv_CKHealthPerT) * GetTeamPlayerCount(CS_TEAM_T)) / GetTeamPlayerCount(CS_TEAM_CT));

	SetEntityHealth(client, health);

	return Plugin_Continue;
}

public void OnClientDisconnect_Post(int client)
{
	if (GetTeamPlayerCount(CS_TEAM_T, true) < 2 || (GetTeamPlayerCount(CS_TEAM_CT, true) == 0 && !JailBreakDays_IsDayActive()))
		SetConVarBool(hcv_TeammatesAreEnemies, false);
}

public Action Event_PlayerDeath(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	if (GetTeamPlayerCount(CS_TEAM_T, true) < 2 || (GetTeamPlayerCount(CS_TEAM_CT, true) == 0 && !JailBreakDays_IsDayActive()))
		SetConVarBool(hcv_TeammatesAreEnemies, false);

	RestoreTalkingRights();

	// int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int talive;
	talive = GetTeamAliveCount(CS_TEAM_T);
	if (talive == 1)    // lastrequest time
	{
		ServerCommand("mp_teammates_are_enemies 0");
		for (int i = 1; i <= MaxClients; i++)
			if (IsClientInGame(i))
				UC_PrintToChat(i, "%s the friendly fire turned off automatically!", PREFIX);

		if (hTimer_ExpireMute != INVALID_HANDLE)
			TriggerTimer(hTimer_ExpireMute, true);
	}

	return Plugin_Continue;
}

public Action Command_FD(int client, int args)
{
	if ((GetClientTeam(client) != CS_TEAM_CT || !IsPlayerAlive(client)) && !CheckCommandAccess(client, "sm_admin", ADMFLAG_GENERIC))
	{
		UC_ReplyToCommand(client, "You don't have access to this command");

		return Plugin_Handled;
	}

	else if (args == 0)
	{
		UC_ReplyToCommand(client, "Usage: sm_fd <target>");
		return Plugin_Handled;
	}
	char Arg[64];
	GetCmdArgString(Arg, sizeof(Arg));

	int target = FindTerroristTarget(client, Arg, false, false);

	if (target == -1)
		return Plugin_Handled;

	IsVIP[target] = !IsVIP[target];

	UC_PrintToChatAll(" %s \x05%N \x01%s \x10Freeday \x01%s \x05%N ", PREFIX, client, IsVIP[target] ? "Gave" : "Took", IsVIP[target] ? "To" : "From", target);

	SetEntityRenderColor(target, 0, 128, 128, 255);

	if (IsVIP[target])
	{
		SetEntityRenderMode(target, RENDER_GLOW);
		SetEntityRenderFx(target, RENDERFX_GLOWSHELL);

		if (hTimer_Beacon == INVALID_HANDLE)
		{
			hTimer_Beacon = CreateTimer(0.3, Timer_BeaconVIP, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
		}
	}
	else
	{
		SetEntityRenderMode(target, RENDER_NORMAL);
		SetEntityRenderFx(target, RENDERFX_NONE);
	}

	return Plugin_Handled;
}

public Action Timer_BeaconVIP(Handle hTimer)
{
	bool AnyVIP = false;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (!IsVIP[i])
			continue;

		// Stolen from eylonap vote ct since I refuse to waste my time checking these stuff lol.
		float pos[3];
		int   rgba[4];
		GetClientAbsOrigin(i, pos);
		pos[2] += 9;
		rgba[0] = GetRandomInt(10, 250);
		rgba[1] = GetRandomInt(10, 250);
		rgba[2] = GetRandomInt(10, 250);
		rgba[3] = 250;
		SetEntityRenderColor(i, rgba[0], rgba[1], rgba[2], rgba[3]);
		TE_SetupBeamRingPoint(pos, 5.0, 70.0, BeamIndex, HaloIdx, 0, 32, 0.45, 3.0, 0.0, rgba, 6, 0);
		TE_SendToAll();
		AnyVIP = true;
	}

	if (!AnyVIP)
	{
		hTimer_Beacon = INVALID_HANDLE;
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public Action Command_Box(int client, int args)
{
	g_bSpeaking[client] = true;
	if (JailBreakDays_IsDayActive())
		return Plugin_Handled;

	else if (GetClientTeam(client) != CS_TEAM_CT && !CheckCommandAccess(client, "sm_admin", ADMFLAG_GENERIC))
	{
		UC_PrintToChat(client, "%s \x05You \x01must be in the guards team to use this \x07command!", PREFIX);
		return Plugin_Handled;
	}
	else if (!IsPlayerAlive(client) && !CheckCommandAccess(client, "sm_admin", ADMFLAG_GENERIC))
	{
		UC_PrintToChat(client, "%s \x5You \x01must be alive to use this \x07command!", PREFIX);
		return Plugin_Handled;
	}

	else if(!Eyal282_VoteCT_IsTreatedWarden(client))
	{
		UC_PrintToChat(client, "%s \x5You \x01must be warden to use this \x07command!", PREFIX);
		return Plugin_Handled;
	}

	Handle hMenu = CreateMenu(Box_MenuHandler);

	switch (GetConVarInt(hcv_TeammatesAreEnemies))
	{
		case 0: SetMenuTitle(hMenu, "%s Box status: OFF", MENU_PREFIX);
		case 1: SetMenuTitle(hMenu, "%s Box status: ON", MENU_PREFIX);
		case 2: SetMenuTitle(hMenu, "%s Box status: Backstabs", MENU_PREFIX);
		case 3: SetMenuTitle(hMenu, "%s Box status: Gunfights", MENU_PREFIX);
	}

	AddMenuItem(hMenu, "", "ON");
	AddMenuItem(hMenu, "", "OFF");
	AddMenuItem(hMenu, "", "Backstabs");
	AddMenuItem(hMenu, "", "Gunfights");

	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

public int Box_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	else if (action == MenuAction_Select)
	{
		if (JailBreakDays_IsDayActive())
			return 0;

		else if (GetClientTeam(client) != CS_TEAM_CT && !CheckCommandAccess(client, "sm_admin", ADMFLAG_GENERIC))
			return 0;

		switch (item)
		{
			case 0:
			{
				SetConVarInt(hcv_TeammatesAreEnemies, 1);
				UC_PrintToChatAll(" %s \x05%N \x01set \x02box\x01 status to\x03 ON! ", PREFIX, client);
			}
			case 1:
			{
				SetConVarInt(hcv_TeammatesAreEnemies, 0);
				UC_PrintToChatAll(" %s \x05%N \x01set \x02box\x01 status to\x03 OFF! ", PREFIX, client);
			}
			case 2:
			{
				SetConVarInt(hcv_TeammatesAreEnemies, 2);
				UC_PrintToChatAll(" %s \x05%N \x01set \x02box\x01 status to\x03 Backstabs! ", PREFIX, client);
			}

			case 3:
			{
				SetConVarInt(hcv_TeammatesAreEnemies, 3);
				UC_PrintToChatAll(" %s \x05%N \x01set \x02box\x01 status to\x03 Gunfights! ", PREFIX, client);
			}
		}
	}

	return 0;
}

public Action Command_CK(int client, int args)
{
	if ((GetClientTeam(client) != CS_TEAM_CT || !Eyal282_VoteCT_IsChosen(client)) && !CheckCommandAccess(client, "sm_admin", ADMFLAG_GENERIC))
	{
		UC_ReplyToCommand(client, "You don't have access to this command");

		return Plugin_Handled;
	}

	else if (CKEnabled)
	{
		UC_ReplyToCommand(client, "CK is already running");

		return Plugin_Handled;
	}

	else if (!Eyal282_VoteCT_IsPreviewRound() && !CheckCommandAccess(client, "sm_admin", ADMFLAG_GENERIC))
	{
		UC_ReplyToCommand(client, " \x07CK \x01can only be \x07started \x01in \x07Preview Round. ");

		return Plugin_Handled;
	}

	Handle hMenu = CreateMenu(CK_MenuHandler);

	AddMenuItem(hMenu, "", "Start CK", CKEnabled ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	AddMenuItem(hMenu, "", "Stop CK", !CKEnabled ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

	SetMenuTitle(hMenu, "%s CK", MENU_PREFIX);

	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

public int CK_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	else if (action == MenuAction_Select)
	{
		if (!CheckCommandAccess(client, "sm_admin", ADMFLAG_GENERIC))
			return 0;

		switch (item)
		{
			case 0:
			{
				CKEnabled = true;
			}

			case 1:
			{
				CKEnabled = false;
			}
		}

		ServerCommand("mp_restartgame 1");
	}

	return 0;
}

public Action Command_SilentStopCK(int client, int args)
{
	CKEnabled = false;

	return Plugin_Handled;
}

/*
public Action Command_Sort(int client, int args)
{
	if ((GetClientTeam(client) != CS_TEAM_CT && !CheckCommandAccess(client, "sm_admin", ADMFLAG_GENERIC))
	{
		UC_ReplyToCommand(client, "You don't have access to this command");

		return Plugin_Handled;
	}


	return Plugin_Handled;
}
*/
public void Eyal282_VoteCT_OnVoteCTStart(int ChosenUserId)
{
	CKEnabled = false;
}

stock int GetTeamPlayerCount(int Team, bool onlyAlive = false)
{
	int count = 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (onlyAlive && !IsPlayerAlive(i))
			continue;

		else if (GetClientTeam(i) == Team)
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

stock bool IsEntityPlayer(int entity)
{
	if (entity <= 0)
		return false;

	else if (entity > MaxClients)
		return false;

	return true;
}

stock void DeleteAllMarkers()
{
	ClearArray(aMarkers);
}

stock void CreateMarker(int client)
{
	markerEntry entry;

	GetClientAimTargetPos(client, entry.origin);

	entry.origin[2] += 5.0;
	entry.radius = 128.0;

	if (GetArraySize(aMarkers) >= 1)
	{
		ShiftArrayUp(aMarkers, 0);
		SetArrayArray(aMarkers, 0, entry);
	}
	else
		PushArrayArray(aMarkers, entry);

	if (GetArraySize(aMarkers) >= MAX_MARKERS)
		ResizeArray(aMarkers, MAX_MARKERS);
}

// Shamelessly stolen from Shanapu MyJB.
int GetClientAimTargetPos(int client, float g_fPos[3])
{
	if (client < 1)
		return -1;

	float vAngles[3];
	float vOrigin[3];

	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);

	TR_TraceRayFilter(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceFilterAllEntities, client);

	TR_GetEndPosition(g_fPos);
	g_fPos[2] += 5.0;

	int entity = TR_GetEntityIndex();

	return entity;
}

public bool TraceFilterAllEntities(int entity, int contentsMask, int client)
{
	if (entity == client)
		return false;

	if (entity > MaxClients)
		return false;

	if (!IsClientInGame(entity))
		return false;

	if (!IsPlayerAlive(entity))
		return false;

	return true;
}


int JB_GetClientAimTarget(int client, int &trueTarget)
{
	float vAngles[3];
	float vOrigin[3];

	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);

	TR_TraceRayFilter(vOrigin, vAngles, MASK_PLAYERSOLID, RayType_Infinite, TraceFilterDontHitSelf, client);
	
	if(!TR_DidHit())
		return -1;

	int entity = TR_GetEntityIndex();

	if(entity == -1 || entity == 0)
		return -1;

	trueTarget = entity;

	while(GetEntPropEnt(entity, Prop_Send, "moveparent") != -1)
	{
		entity = GetEntPropEnt(entity, Prop_Send, "moveparent");
	}

	return entity;
}

public bool TraceFilterDontHitSelf(int entity, int contentsMask, int client)
{
	if (entity == client)
		return false;

	return true;
}
// Shamelessly stolen from Shanapu MyJB.
float GetAimDistanceFromTarget(int client, int target)
{
	float vAngles[3];
	float vOrigin[3];
	float g_fPos[3];

	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);

	TR_TraceRayFilter(vOrigin, vAngles, MASK_ALL, RayType_Infinite, TraceFilterHitTarget, target);

	TR_GetEndPosition(g_fPos);

	return GetVectorDistance(vOrigin, g_fPos, false);
}
public bool TraceFilterHitTarget(int entity, int contentsMask, int target)
{
	if (entity == target)
		return true;

	return false;
}

// Start of Skyler
public Action Command_Medic(int client, int args)
{
	if (IsPlayerAlive(client) && GetClientTeam(client) == CS_TEAM_T)
	{
		/*
		if (hp >= 100)
		{
		    UC_PrintToChat(client, "%s you cant call a medic because you have \x02100 HP!", PREFIX);
		    return Plugin_Handled;
		}
		*/
		if (nospam[client])
		{
			UC_PrintToChat(client, "%s you cant call a medic because you still have \x02%d \x05cooldown!", PREFIX, hcv_MedicCooldown.IntValue);
			return Plugin_Handled;
		}
		if (!nospam[client])
		{
			nospam[client] = true;
			UC_PrintToChatAll("%s \x05%N\x01 wants a \x07medic!", PREFIX, client);
			CreateTimer(hcv_MedicCooldown.FloatValue, medicHandler, GetClientUserId(client));
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public Action medicHandler(Handle timer, any UserId)
{
	int client = GetClientOfUserId(UserId);

	if(client == 0)
		return Plugin_Continue;

	if (nospam[client])
	{
		nospam[client] = false;
		KillTimer(timer);    // pervent memory leak
	}

	return Plugin_Continue;
}

public Action Command_Deagle(int client, int args)
{
	if(client == 0 || JailBreakDays_IsDayActive())
		return Plugin_Handled;

	if (GetClientTeam(client) != CS_TEAM_CT && !CheckCommandAccess(client, "sm_admin", ADMFLAG_GENERIC))
	{
		UC_PrintToChat(client, "%s \x05You \x01must be in the guards team to use this \x07command!", PREFIX);
		return Plugin_Handled;
	}
	else if (!IsPlayerAlive(client) && !CheckCommandAccess(client, "sm_admin", ADMFLAG_GENERIC))
	{
		UC_PrintToChat(client, "%s \x5You \x01must be alive to use this \x07command!", PREFIX);
		return Plugin_Handled;
	}

	else if(!Eyal282_VoteCT_IsTreatedWarden(client))
	{
		UC_PrintToChat(client, "%s \x5You \x01must be warden to use this \x07command!", PREFIX);
		return Plugin_Handled;
	}

	UC_PrintToChatAll("%s \x01All \x07terrorist \x01alive got a empty \x05deagle! \x01Have Fun", PREFIX);

	for (int i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i))
			continue;
			
		else if(!IsPlayerAlive(i))
			continue;
			
		else if(GetClientTeam(i) != CS_TEAM_T)
			continue;

		Client_GiveWeaponAndAmmo(i, "weapon_deagle", _, 0, _, 0);
		GivePlayerItem(i, "weapon_knife");
	}
	return Plugin_Continue;
}

public Action MuteHandler(Handle timer, any client)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			UC_PrintToChat(i, "%s The \x02terrorists \x01can talk right \x05now!", PREFIX);
		}
	}

	hTimer_ExpireMute = INVALID_HANDLE;

	RestoreTalkingRights();

	return Plugin_Continue;
}

public Action Event_PlayerTeamNoCopy(Event event, char[] name, bool dontBroadcast)
{
	CreateTimer(0.1, CheckDeathOnJoin, _, TIMER_FLAG_NO_MAPCHANGE);

	return Plugin_Continue;
}

public Action CheckDeathOnJoin(Handle hTimer)
{
	RestoreTalkingRights();

	return Plugin_Continue;
}

stock void RemoveAllWeapons(int client)
{
	int iWeapon;
	for (int k = 0; k <= 6; k++)
	{
		iWeapon = GetPlayerWeaponSlot(client, k);

		if (IsValidEdict(iWeapon))
		{
			RemovePlayerItem(client, iWeapon);
			RemoveEdict(iWeapon);
		}
	}
}

stock int GetPlayerCount()
{
	int count;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (GetClientTeam(i) != CS_TEAM_CT && GetClientTeam(i) != CS_TEAM_T)
			continue;

		count++;
	}

	return count;
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

stock void RestoreTalkingRights()
{
	for(int i=1;i <= MaxClients;i++)
	{
		if (!IsClientInGame(i))
			continue;
		
		if(GetTeamAliveCount(CS_TEAM_T) < hcv_MinTMute.IntValue)
		{
			if(!IsPlayerAlive(i) && !GetConVarBool(hcv_DeadTalk) && !CheckCommandAccess(i, "sm_admin", ADMFLAG_GENERIC))
				SetClientListeningFlags(i, VOICE_MUTED);

			else
				SetClientListeningFlags(i, VOICE_NORMAL);
		}
		else if(hTimer_ExpireMute != INVALID_HANDLE || hcv_MuteTTime.FloatValue < 0.0)
		{
			if(!IsPlayerAlive(i) && !GetConVarBool(hcv_DeadTalk) && !CheckCommandAccess(i, "sm_admin", ADMFLAG_GENERIC))
				SetClientListeningFlags(i, VOICE_MUTED);

			else if(BaseComm_IsClientMuted(i) || GetClientTeam(i) == CS_TEAM_T)
				SetClientListeningFlags(i, VOICE_MUTED);

			else
				SetClientListeningFlags(i, VOICE_NORMAL);
		}
		else
		{
			if(!IsPlayerAlive(i) && !GetConVarBool(hcv_DeadTalk) && !CheckCommandAccess(i, "sm_admin", ADMFLAG_GENERIC))
				SetClientListeningFlags(i, VOICE_MUTED);

			else if(BaseComm_IsClientMuted(i))
				SetClientListeningFlags(i, VOICE_MUTED);

			else
				SetClientListeningFlags(i, VOICE_NORMAL);
		}
	}
}

// Stolen from MyJailBreak
void GetClientSightEnd(int client, float out[3])
{
	float m_fEyes[3];
	float m_fAngles[3];

	GetClientEyePosition(client, m_fEyes);
	GetClientEyeAngles(client, m_fAngles);
	TR_TraceRayFilter(m_fEyes, m_fAngles, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitPlayers);
	if (TR_DidHit())
	{
		TR_GetEndPosition(out);
	}
}

public bool TraceRayDontHitPlayers(int entity, int mask, int data)
{
	if (0 < entity <= MaxClients)
		return false;

	return true;
}

stock enDoorState GetDoorState(int entity)
{
	
	if(HasEntProp(entity, Prop_Data, "m_eDoorState"))
	{
		return view_as<enDoorState>(GetEntProp(entity, Prop_Data, "m_eDoorState"));
	}

	else if(HasEntProp(entity, Prop_Data, "m_toggle_state"))
	{
		switch(GetEntProp(entity, Prop_Data, "m_toggle_state"))
		{
			case FUNC_STATE_CLOSED: 	{ return STATE_CLOSED; }
			case FUNC_STATE_OPENED: 	{ return STATE_OPENED; }
			case FUNC_STATE_CLOSING:	{ return STATE_CLOSING; }
			case FUNC_STATE_OPENING:	{ return STATE_OPENING; }
		}
	}
		
	return STATE_INVALID;
}

stock void FireLaserBeam(int client)
{
	float m_fOrigin[3], m_fImpact[3];

	GetClientEyePosition(client, m_fOrigin);
	GetClientSightEnd(client, m_fImpact);
	TE_SetupBeamPoints(m_fOrigin, m_fImpact, BeamIndex, 0, 0, 0, 0.1, 0.12, 0.0, 1, 0.0, g_iLaserColors[GetRandomInt(0, 6)], 0);
	TE_SendToAll();
	TE_SetupGlowSprite(m_fImpact, HaloIdx, 0.1, 0.25, g_iLaserColors[1][3]);
	TE_SendToAll();
}

stock bool IsPlayer(int client)
{
	if (client <= 0)
		return false;

	else if (client > MaxClients)
		return false;

	return true;
}

stock int GetEntityHealth(int entity)
{
	return GetEntProp(entity, Prop_Send, "m_iHealth");
}

stock int GetEntityMaxHealth(int entity)
{
	return GetEntProp(entity, Prop_Data, "m_iMaxHealth");
}



stock void EmitSoundByDistanceAny(float distance, const char[] sample, int entity = SOUND_FROM_PLAYER, int channel = SNDCHAN_AUTO, int level = SNDLEVEL_NORMAL,
int flags = SND_NOFLAGS, float volume = SNDVOL_NORMAL, int pitch = SNDPITCH_NORMAL, int speakerentity = -1, const float origin[3], const float dir[3] = NULL_VECTOR, 
bool updatePos = true, float soundtime = 0.0)
{
	if(IsNullVector(origin))
	{
		ThrowError("Origin must not be null!");
	}
	
	int clients[MAXPLAYERS+1], count;
	
	for(int i=1;i <= MaxClients;i++)
	{
		if(!IsClientInGame(i))
			continue;
			
		float iOrigin[3];
		GetEntPropVector(i, Prop_Data, "m_vecOrigin", iOrigin);
		
		if(GetVectorDistance(origin, iOrigin, false) < distance)
			clients[count++] = i;
	}
	
	EmitSoundAny(clients, count, sample, entity, channel, level, flags, volume, pitch, speakerentity, origin, dir, updatePos, soundtime);
}