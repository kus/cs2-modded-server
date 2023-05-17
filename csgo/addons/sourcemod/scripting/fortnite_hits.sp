#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <clientprefs>
#include <regex>
#include <gamma_colors>

public Plugin myinfo = 
{
	name = "Fortnite player hits",
	author = "GAMMA CASE",
	description = "Shows damage like in fortnite",
	version = "1.2.0",
	url = "http://steamcommunity.com/id/_GAMMACASE_/"
}

#define INVALID_ADMIN_ID view_as<AdminFlag>(-1)
#define x 0
#define y 1
#define z 2

bool g_bIsFired[MAXPLAYERS + 1],
	g_bIsCrit[MAXPLAYERS + 1][MAXPLAYERS + 1],
	g_bIsFirstTime[MAXPLAYERS + 1],
	g_bState[MAXPLAYERS + 1],
	g_bHasAccess[MAXPLAYERS + 1];
int g_iTotalSGDamage[MAXPLAYERS + 1][MAXPLAYERS + 1];
float g_fPlayerPosLate[MAXPLAYERS + 1][3];

AdminFlag g_afPermission = INVALID_ADMIN_ID;

ConVar g_cvAllowForBots,
	g_cvReconnectPlayer,
	g_cvCommands,
	g_cvDistance,
	g_cvPermission;
Handle g_hCookie;

enum HitGroup
{
	HITGROUP_GENERIC = 0,
	HITGROUP_HEAD,
	HITGROUP_CHEST,
	HITGROUP_STOMACH,
	HITGROUP_LEFTARM,
	HITGROUP_RIGHTARM,
	HITGROUP_LEFTLEG,
	HITGROUP_RIGHTLEG
}

public void OnPluginStart()
{
	g_cvAllowForBots = CreateConVar("fortnite_hits_allowforbots", "1", "Allow bots to create hit particles (NOTE: Only will be visible when spectating a bot)", FCVAR_NONE, true, 0.0, true, 1.0);
	g_cvReconnectPlayer = CreateConVar("fortnite_hits_enableplayerreconnect", "1", "Enable this to force new players to reconnect to server, so they will see particle effects without need of waiting next map", FCVAR_NONE, true, 0.0, true, 1.0);
	g_cvCommands = CreateConVar("fortnite_hits_commandnames", "sm_fortnitehits;sm_hits;sm_damage;sm_fortnite;", "Set custom names here for toggle damage display command, don't add to many commands as it may overflow buffer. (NOTE: Write command names with \"sm_\" prefix, and don't use ! or any other symbol except A-Z and 0-9 and underline symbol \"_\", also server needs to be restarted to see changes!)", FCVAR_NONE);
	g_cvDistance = CreateConVar("fortnite_hits_distance", "50.0", "Distance between victim player and damage numbers (NOTE: Make that value lower to prevent numbers show up through the walls)", FCVAR_NONE, true, 0.0);
	g_cvPermission = CreateConVar("fortnite_hits_flag", "", "Set any flag here if you want to restrict use of that plugin only to certain flag (NOTE: Leave it empty to allow anyone to use this plugin)", FCVAR_NONE);
	AutoExecConfig();
	
	g_cvPermission.AddChangeHook(Cvar_Permission_ChangeHook);
	LoadTranslations("fortnite_hits.phrases");
	
	RegConsoleCommands();
	g_hCookie = RegClientCookie("fortnite_hits_state", "Is showing damage disabled/enabled for a specific client", CookieAccess_Protected);
	
	HookEvent("player_connect_full", ConnectedFull_Hook);
	HookEvent("player_hurt", PlayerHurt_Event);
	
	//late load
	for(int i = 1; i <= MaxClients; i++)
	{
		if(!IsValidClient(i))
			continue;
		
		if(AreClientCookiesCached(i))
			OnClientCookiesCached(i);
		
		SetAccess(i);
	}
}

public void Cvar_Permission_ChangeHook(ConVar convar, const char[] oldValue, const char[] newValue)
{
	CheckPermission(newValue);
}

public void OnMapStart()
{
	AddFileToDownloadsTable("particles/gammacase/hit_nums.pcf");
	AddFileToDownloadsTable("materials/gammacase/fortnite/hitnums/nums_bw.vmt");
	AddFileToDownloadsTable("materials/gammacase/fortnite/hitnums/nums_bw.vtf");
	PrecacheGeneric("particles/gammacase/hit_nums.pcf", true);
}

public void OnConfigsExecuted()
{
	char buff[8];
	g_cvPermission.GetString(buff, sizeof(buff));
	CheckPermission(buff);
}

public void CheckPermission(const char[] svalue)
{
	if(svalue[0] == '\0')
		g_afPermission = INVALID_ADMIN_ID;
	else
	{
		BitToFlag(ReadFlagString(svalue), g_afPermission);
		SetAccessAll();
	}
}

public void RegConsoleCommands()
{
	char buff[1024];
	g_cvCommands.GetString(buff, sizeof(buff));
	
	if(buff[0] == '\0')
		return;
	
	char error[64];
	RegexError ErrorCode;
	Regex reg = CompileRegex("[a-zA-Z_0-9]+", 0, error, sizeof(error), ErrorCode);
	if(error[0] != '\0')
		SetFailState("[RegConsoleCommands] Regex error: \"%s\",  with error code: %i", error, ErrorCode);
	
	int num = reg.MatchAll(buff, ErrorCode);
	if(ErrorCode != REGEX_ERROR_NONE)
		SetFailState("[RegConsoleCommands] Regex match error, error code: %i", ErrorCode);
	
	char sMatch[32];
	for(int i = 0; i < num; i++)
	{
		reg.GetSubString(0, sMatch, sizeof(sMatch), i);
		RegConsoleCmd(sMatch, ToggleHits, "Toggles hits display");
	}
}

public Action ToggleHits(int client, int args)
{
	if(g_bHasAccess[client])
	{
		char buff[4];
		
		g_bState[client] = !g_bState[client];
		IntToString(g_bState[client], buff, sizeof(buff));
		SetClientCookie(client, g_hCookie, buff);
		
		GCReplyToCommand(client, "%t", (g_bState[client] ? "display_toggle_on" : "display_toggle_off"));
	}
	else
		GCReplyToCommand(client, "%t", "no_access");
	
	return Plugin_Handled;
}

public void OnClientCookiesCached(int client)
{
	if(IsFakeClient(client))
		return;
	
	char buff[4];
	GetClientCookie(client, g_hCookie, buff, sizeof(buff));
	
	if(buff[0] == '\0')
	{
		SetClientCookie(client, g_hCookie, "1");
		g_bState[client] = true;
		g_bIsFirstTime[client] = true;
	}
	else
	{
		g_bState[client] = view_as<bool>(StringToInt(buff));
		g_bIsFirstTime[client] = false;
	}
}

public void OnRebuildAdminCache(AdminCachePart part)
{
	if(part == AdminCache_Admins)
		SetAccessAll();
}

public void OnClientPostAdminCheck(int client)
{
	if(!IsFakeClient(client))
		SetAccess(client);
}

public void ConnectedFull_Hook(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if(IsFakeClient(client))
		return;
	
	if(g_bIsFirstTime[client] && g_cvReconnectPlayer.BoolValue)
		ReconnectClient(client);
}

public void PlayerHurt_Event(Event event, const char[] name, bool dontBroadcast)
{
	static int attacker, client, damage;
	static HitGroup hitgroup;
	static char sWeapon[32];
	
	attacker = GetClientOfUserId(event.GetInt("attacker")),
	client = GetClientOfUserId(event.GetInt("userid")),
	damage = event.GetInt("dmg_health");
	hitgroup = view_as<HitGroup>(event.GetInt("hitgroup"));
	event.GetString("weapon", sWeapon, sizeof(sWeapon));
	
	if(attacker == client || attacker == 0 || client == 0)
		return;
	
	if(!g_cvAllowForBots.BoolValue && IsFakeClient(attacker))
		return;
	
	if(StrEqual(sWeapon, "xm1014") || StrEqual(sWeapon, "nova") || StrEqual(sWeapon, "mag7") || StrEqual(sWeapon, "sawedoff"))
	{
		if(!g_bIsFired[attacker])
		{
			CreateTimer(0.1, TimerHit_CallBack, GetClientUserId(attacker), TIMER_FLAG_NO_MAPCHANGE);
			
			g_bIsFired[attacker] = true;
			g_iTotalSGDamage[attacker][client] = damage;
		}
		else
			g_iTotalSGDamage[attacker][client] += damage;
		
		if(hitgroup == HITGROUP_HEAD)
			g_bIsCrit[attacker][client] = true;
		GetClientAbsOrigin(client, g_fPlayerPosLate[client]);
	}
	else
		ShowPRTDamage(attacker, client, damage, (hitgroup == HITGROUP_HEAD));
}

public Action TimerHit_CallBack(Handle timer, int userid)
{
	static int client;
	client = GetClientOfUserId(userid);
	
	if(client == 0)
		return Plugin_Stop;
	
	g_bIsFired[client] = false;
	for(int i = 1; i <= MaxClients; i++)
	{
		if(!IsValidClient(i, false))
			continue;
		
		if(g_iTotalSGDamage[client][i] != 0)
		{
			ShowPRTDamage(client, i, g_iTotalSGDamage[client][i], g_bIsCrit[client][i], true);
			g_iTotalSGDamage[client][i] = 0;
			g_bIsCrit[client][i] = false;
		}
	}
	
	return Plugin_Continue;
}

stock void ShowPRTDamage(int attacker, int client, int damage, bool crit, bool late = false)
{
	if(!IsValidClient(client, false))
		return;
	
	if(!IsValidClient(attacker, false))
		return;
	
	static float pos[3], pos2[3], ang[3], fwd[3], right[3], temppos[3], dist, d, dif;
	static int ent, l, count, dmgnums[8];
	static char buff[16];
	
	count = 0;
	
	while(damage > 0)
	{
		dmgnums[count++] = damage % 10;
		damage /= 10;
	}
	
	GetClientEyeAngles(attacker, ang);
	GetClientAbsOrigin(attacker, pos2);
	
	if(late)
		pos = g_fPlayerPosLate[client];
	else
		GetClientAbsOrigin(client, pos);
	
	GetAngleVectors(ang, fwd, right, NULL_VECTOR);
	
	l = RoundToCeil(float(count)/2.0);
	
	dist = GetVectorDistance(pos2, pos);
	if(dist > 700.0)
		d = dist / 700.0 * 6.0;
	else
		d = 6.0;
	
	pos[x] += right[x] * d * l * GetRandomFloat(-0.5, 1.0);
	pos[y] += right[y] * d * l * GetRandomFloat(-0.5, 1.0);
	if(GetEntProp(client, Prop_Send, "m_bDucked"))
		if(crit)
			pos[z] += 45.0 + GetRandomFloat(0.0, 10.0);
		else
			pos[z] += 25.0 + GetRandomFloat(0.0, 20.0);
	else
		if(crit)
			pos[z] += 60.0 + GetRandomFloat(0.0, 10.0);
		else
			pos[z] += 35.0 + GetRandomFloat(0.0, 20.0);
	
	dif = g_cvDistance.FloatValue;
	for(int i = count - 1; i >= 0; i--)
	{
		temppos = pos;
		
		temppos[x] -= fwd[x] * dif + right[x] * d * l;
		temppos[y] -= fwd[y] * dif + right[y] * d * l;
		
		ent = CreateEntityByName("info_particle_system");
		if(ent == -1)
			SetFailState("Error creating \"info_particle_system\" entity!");
		
		TeleportEntity(ent, temppos, ang, NULL_VECTOR);
		
		FormatEx(buff, sizeof(buff), "%s_num%i_f%s", (crit ? "crit" : "def"), dmgnums[i], (l-- > 0 ? "l" : "r"));
		
		DispatchKeyValue(ent, "effect_name", buff);
		DispatchKeyValue(ent, "start_active", "1");
		DispatchSpawn(ent);
		ActivateEntity(ent);
		
		SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", attacker);
		SDKHook(ent, SDKHook_SetTransmit, SetTransmit_Hook);
		
		SetVariantString("OnUser1 !self:kill::3:-1");
		AcceptEntityInput(ent, "AddOutput");
		AcceptEntityInput(ent, "FireUser1");
	}
}

public Action SetTransmit_Hook(int entity, int client)
{
	if(GetEdictFlags(entity) & FL_EDICT_ALWAYS)
		SetEdictFlags(entity, (GetEdictFlags(entity) ^ FL_EDICT_ALWAYS));
	
	if(g_bHasAccess[client] && g_bState[client] && (GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == client || (GetEntPropEnt(client, Prop_Send, "m_hObserverTarget") == GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") && (GetEntProp(client, Prop_Send, "m_iObserverMode") == 4 || GetEntProp(client, Prop_Send, "m_iObserverMode") == 5))))
		return Plugin_Continue;
	
	return Plugin_Stop;
}

public void SetAccessAll()
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(!IsValidClient(i))
			continue;
		
		SetAccess(i);
	}
}

public void SetAccess(int client)
{
	g_bHasAccess[client] = (g_afPermission == INVALID_ADMIN_ID || GetUserAdmin(client).HasFlag(g_afPermission));
}

stock bool IsValidClient(int client, bool botcheck = true)
{
	return (1 <= client && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && (botcheck ? !IsFakeClient(client) : true)); 
}