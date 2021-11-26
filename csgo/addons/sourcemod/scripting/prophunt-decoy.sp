#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <smlib>
#include <csgocolors>
#include <soundlib>
#include <emitsoundany>
#include <prophunt>

#define LoopClients(%1) for(int %1 = 1; %1 <= MaxClients; %1++)

#define LoopIngameClients(%1) for(int %1=1;%1<=MaxClients;++%1)\
if(IsClientInGame(%1))

#define LoopIngamePlayers(%1) for(int %1=1;%1<=MaxClients;++%1)\
if(IsClientInGame(%1) && !IsFakeClient(%1))

#define LoopAlivePlayers(%1) for(int %1=1;%1<=MaxClients;++%1)\
if(IsClientInGame(%1) && IsPlayerAlive(%1))

#define PLUGIN_VERSION "1.0"

enum FX
{
	FxNone = 0,
	FxPulseFast,
	FxPulseSlowWide,
	FxPulseFastWide,
	FxFadeSlow,
	FxFadeFast,
	FxSolidSlow,
	FxSolidFast,
	FxStrobeSlow,
	FxStrobeFast,
	FxStrobeFaster,
	FxFlickerSlow,
	FxFlickerFast,
	FxNoDissipation,
	FxDistort,               // Distort/scale/translate flicker
	FxHologram,              // kRenderFxDistort + distance fade
	FxExplode,               // Scale up really big!
	FxGlowShell,             // Glowing Shell
	FxClampMinScale,         // Keep this sprite from getting very small (SPRITES only!)
	FxEnvRain,               // for environmental rendermode, make rain
	FxEnvSnow,               //  "        "            "    , make snow
	FxSpotlight,     
	FxRagdoll,
	FxPulseFastWider,
};

enum Render
{
	Normal = 0,     // src
	TransColor,     // c*a+dest*(1-a)
	TransTexture,    // src*a+dest*(1-a)
	Glow,        // src*a+dest -- No Z buffer checks -- Fixed size in screen space
	TransAlpha,      // src*srca+dest*(1-srca)
	TransAdd,      // src*a+dest
	Environmental,    // not drawn, used for environmental effects
	TransAddFrameBlend,  // use a fractional frame value to blend between animation frames
	TransAlphaAdd,    // src + dest*(1-a)
	WorldGlow,      // Same as kRenderGlow but not fixed size in screen space
	None,        // Don't render.
};

#define PREFIX "{magenta}[{lime}Prop{yellow}Hunt{darkred}X{magenta}] {yellow}"

public Plugin myinfo = 
{
	name = "Prophunt - Decoy",
	author = ".#Zipcore",
	description = "Allows hiders to place a decoy.",
	version = PLUGIN_VERSION,
	url = "zipcore.net"
};

ConVar g_cvPrice;
ConVar g_cvSort;
ConVar g_cvUnlock;

ConVar g_cvDecoyMax;

ConVar g_cvDecoyMinDmg;
ConVar g_cvDecoyMaxDmg;
ConVar g_cvDecoyMinRange;
ConVar g_cvDecoyMaxRange;

Handle g_OnDecoyHitSeeker;

ConVar g_cvDecoyCheckRange;
ConVar g_cvDecoyCheckFOV;

char g_sndDecoyBreak[255] = "phx/decoy_break.mp3";
char g_sndDecoyDeploy[255] = "phx/decoy_deploy.mp3";

Handle g_hDecoys[MAXPLAYERS+1] = {null, ...};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	g_OnDecoyHitSeeker = CreateGlobalForward("PH_OnDecoyHitSeeker", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Float, Param_Cell);
	
	RegPluginLibrary("prophunt-decoy");
	
	return APLRes_Success;
}

public void OnPluginStart()
{
	g_cvPrice = CreateConVar("ph_decoy_price", "80", "Decoy price.");
	g_cvSort = CreateConVar("ph_decoy_sort", "4", "Decoy shop item sort order.");
	g_cvUnlock = CreateConVar("ph_decoy_unlock", "35", "Decoy shop unlock cooldown.");
	
	g_cvDecoyMax = CreateConVar("ph_extreme_decoy_max", "5", "Max alive decoys per players.");
	
	g_cvDecoyMinDmg = CreateConVar("ph_decoy_dmg_min", "10", "Min decoy damage.");
	g_cvDecoyMaxDmg = CreateConVar("ph_decoy_dmg_max", "35", "Max decoy damage.");
	g_cvDecoyMinRange = CreateConVar("ph_decoy_range_min", "42.0", "Min decoy damage. (Max damage radius)");
	g_cvDecoyMaxRange = CreateConVar("ph_decoy_range_max", "600.0", "Min decoy damage (1 Dmg).");
	
	g_cvDecoyCheckRange = CreateConVar("ph_decoy_trigger_range", "128.0", "Decoy trigger range.");
	g_cvDecoyCheckFOV = CreateConVar("ph_decoy_trigger_fov", "90.0", "Decoy trigger check field of view (seeker).");
	
	AutoExecConfig(true, "prophunt-decoy");
	
	ResetDecoys();
}

public void OnLibraryAdded(const char[] name)
{
	if(StrEqual(name, "prophunt"))
		PH_RegisterShopItem("Decoy", CS_TEAM_T, g_cvPrice.IntValue, g_cvSort.IntValue, g_cvUnlock.IntValue, true);
}

public void OnMapStart()
{
	PH_RegisterShopItem("Decoy", CS_TEAM_T, g_cvPrice.IntValue, g_cvSort.IntValue, g_cvUnlock.IntValue, true);
	
	PrepareSound(g_sndDecoyBreak);
	PrepareSound(g_sndDecoyDeploy);
}

public Action PH_OnBuyShopItem(int iClient, char[] sName, int &iPoints)
{
	if(StrEqual(sName, "Decoy"))
	{
		int iCount = GetNumActiveDecoys(iClient);
		
		if(iCount >= g_cvDecoyMax.IntValue)
		{
			CPrintToChat(iClient, "%s {darkred}You have already too much alive decoys ( %i / %i ).", PREFIX, iCount, g_cvDecoyMax.IntValue);
			return Plugin_Continue;
		}
		
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public void PH_OnBuyShopItemPost(int iClient, char[] sName, int iPoints)
{
	if(StrEqual(sName, "Decoy"))
		SetDecoy(iClient);
}

public void PH_OnHiderSpawn(int iClient)
{
	ResetDecoys(iClient);
}

public void PH_OnSeekerSpawn(int iClient)
{
	ResetDecoys(iClient);
}

public void PH_OnSeekerUseWeapon(int iSeeker, int iWeapon, int iWeaponType, int &iTakeHealth)
{
	TriggerDecoys(iSeeker);
}

void AddDecoy(int client, int entity)
{
	// Init array
	if(g_hDecoys[client] == null)
		g_hDecoys[client] = CreateArray(1);
		
	// Push ent ref
	PushArrayCell(g_hDecoys[client], EntIndexToEntRef(entity));
}

// How much decoys a player has active
int GetNumActiveDecoys(int iClient)
{
	if(g_hDecoys[iClient] == null)
		return 0;
	
	// Cleanup list
	for (int i = 0; i < GetArraySize(g_hDecoys[iClient]); i++)
	{
		int iEntity = EntRefToEntIndex(GetArrayCell(g_hDecoys[iClient], i));
		
		if(iEntity <= 0 || !IsValidEntity(iEntity))
			RemoveFromArray(g_hDecoys[iClient], i);
	}
	
	return GetArraySize(g_hDecoys[iClient]);
}

// Trigger all decoys in range
void TriggerDecoys(int iClient)
{
	int iEntity = GetInRangeDecoy(iClient, g_cvDecoyCheckRange.FloatValue, g_cvDecoyCheckFOV.FloatValue);
	
	if(iEntity != -1)
	{
		HandleDecoyExplosion(iEntity);
		AcceptEntityInput(iEntity, "kill");
	}
}

// Get owning client of a decoy
int GetDecoyOwner(int iEntity)
{
	LoopIngameClients(i)
	{
		if(g_hDecoys[i] == null)
			continue;
		
		for (int j = 0; j < GetArraySize(g_hDecoys[i]); j++)
		{
			int ent = EntRefToEntIndex(GetArrayCell(g_hDecoys[i], j));
			
			// Cleanup list
			if(ent <= 0 || !IsValidEntity(ent))
			{
				RemoveFromArray(g_hDecoys[i], j);
				continue;
			}
			
			// Match
			if(iEntity == ent)
				return i;
		}
	}
	
	return -1;
}

// Get a decoy in range
int GetInRangeDecoy(int iClient, float range, float fov)
{
	if(iClient <= 0 || !Client_IsValid(iClient))
		return -1;
	
	LoopIngameClients(i)
	{
		if(g_hDecoys[i] == null)
			continue;
		
		// Lopp decoy list
		for (int j = 0; j < GetArraySize(g_hDecoys[i]); j++)
		{
			int iEntity = EntRefToEntIndex(GetArrayCell(g_hDecoys[i], j));
			
			// Cleanup
			if(iEntity <= 0 || !IsValidEntity(iEntity))
			{
				RemoveFromArray(g_hDecoys[i], j);
				continue;
			}
			
			// Check
			if(IsTargetInSightRange(iClient, iEntity, fov, range, true, false))
				return iEntity;
		}
	}
	
	return -1;
}

// Reset decoy per player or reset all
void ResetDecoys(int iClient = 0)
{
	// All
	if(iClient == 0)
	{
		LoopClients(i)
		{
			if(g_hDecoys[i] == null)
				g_hDecoys[i] = CreateArray(1);
			else ClearArray(g_hDecoys[i]);
		}
	}
	// Per player
	else
	{
		if(g_hDecoys[iClient] == null)
			g_hDecoys[iClient] = CreateArray(1);
		else ClearArray(g_hDecoys[iClient]);
	}
}

bool  SetDecoy(int iClient)
{
	if (!IsPlayerAlive(iClient))
		return false;
	
	if(GetClientTeam(iClient) != CS_TEAM_T)
		return false;
	
	int iModelTime = PH_CanChangeModel();
	
	if(iModelTime > 0)
	{
		CPrintToChat(iClient, "%s You {darkred}can't {yellow}place a decoy yet. Try again in {darkred}%is{yellow}.", PREFIX, iModelTime);
		return false;
	}
	
	if(!PH_IsFrozen(iClient))
	{
		CPrintToChat(iClient, "%s You have to {darkblue}freeze{yellow} before you can place a decoy.", PREFIX);
		return false;
	}
	
	// Spawn decoy
	
	int iFakeProp = PH_GetFakeProp(iClient);
	
	if(iFakeProp <= 0)
	{
		PrintToChat(iClient, "No child!");
		return false;
	}
	
	float fPos[3];
	Entity_GetAbsOrigin(iFakeProp, fPos);
	fPos[0] += 0.00001;
	fPos[1] += 0.00001;
	fPos[2] += 0.00001;
	
	float fAngles[3];
	Entity_GetAbsAngles(iFakeProp, fAngles);
	
	char sModel[PLATFORM_MAX_PATH];
	PH_GetClientModelPath(iClient, sModel);
	
	int iColor[4];
	PH_GetClientModelColor(iClient, iColor)
	
	int iSkin = PH_GetClientModelSkin(iClient);
	
	int iEntity = CreateEntityByName("prop_physics_override");
	if(!IsValidEntity(iEntity))
	{
		LogError("PropHuntX-Demons: Failed to create Decoy. Model: %s", sModel);
		return false;
	}
	
	SetEntityModel(iEntity, sModel);
	
	DispatchSpawn(iEntity);
	
	SetEntityRenderMode(iEntity, RENDER_TRANSCOLOR);
	
	SetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity", iClient);
	SetEntProp(iEntity, Prop_Data, "m_CollisionGroup", 1);
	SetEntProp(iEntity, Prop_Send, "m_usSolidFlags", 12);
	SetEntProp(iEntity, Prop_Send, "m_nSolidType", 6);
	SetEntityMoveType(iEntity, MOVETYPE_NONE);
	
	AddDecoy(iClient, iEntity);
	
	SetEntProp(iEntity, Prop_Data, "m_takedamage", DAMAGE_EVENTS_ONLY, 1);
	SDKHook(iEntity, SDKHook_OnTakeDamage, OnDamageDecoy);
	
	EmitSoundToClientAny(iClient, g_sndDecoyDeploy, iClient, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS,  SNDVOL_NORMAL,  SNDPITCH_NORMAL, iClient, NULL_VECTOR,  NULL_VECTOR, true,  0.0);
	
	SetEntProp(iEntity, Prop_Send, "m_nSkin", iSkin);
	
	FX_Render(iEntity, view_as<FX>(FxDistort), iColor[0], iColor[1], iColor[2], view_as<Render>(RENDER_TRANSADD), iColor[3]);
	
	TeleportEntity(iEntity, fPos, fAngles, NULL_VECTOR);
	
	return true;
}

public Action OnDamageDecoy(int iEntity, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	HandleDecoyExplosion(iEntity);
	AcceptEntityInput(iEntity, "kill");
	
	return Plugin_Handled;
}

void HandleDecoyExplosion(int iEntity)
{
	int iClient = GetDecoyOwner(iEntity);
	
	if(iClient < 1 || !IsClientInGame(iClient))
		return;
	
	float fPos[3];
	Entity_GetAbsOrigin(iEntity, fPos);
	fPos[2] += 8;
	
	EmitAmbientSoundAny(g_sndDecoyBreak, fPos, _, 120);
	
	int iCount;
	
	LoopClients(iTarget)
	{
		if(!IsClientInGame(iTarget) || !IsPlayerAlive(iTarget) || GetClientTeam(iTarget) != CS_TEAM_CT)
			continue;
		
		float fDistance = Entity_GetDistance(iEntity, iTarget);
		int iDmg = GetDamageByRange(fDistance, g_cvDecoyMinDmg.IntValue, g_cvDecoyMaxDmg.IntValue, g_cvDecoyMinRange.FloatValue, g_cvDecoyMaxRange.FloatValue);
		
		if(iDmg > 0)
		{
			Call_StartForward(g_OnDecoyHitSeeker);
			Call_PushCell(iTarget);
			Call_PushCell(iClient);
			Call_PushCell(iDmg);
			Call_PushFloat(fDistance);
			Call_PushCell(iEntity);
			Call_Finish();
			
			DealDamage(iTarget, iDmg, iClient, DMG_POISON, "weapon_decoy");
			
			iCount++;
		}
	}
}

stock void PrepareSound(char[] sound)
{
	char fileSound[PLATFORM_MAX_PATH];
	FormatEx(fileSound, PLATFORM_MAX_PATH, "sound/%s", sound);

	if (FileExists(fileSound, false))
	{
		PrecacheSoundAny(sound, true);
		AddFileToDownloadsTable(fileSound);
	}
	else if(FileExists(fileSound, true))
		PrecacheSound(sound, true);
	else LogMessage("File Not Found: %s", fileSound);
}

stock void FX_Render(int iClient, FX fx = FxNone, int r = 255, int g = 255, int b = 255, Render render = Normal, int alpha = 255)
{
	static int iOffRender = -1;
	
	if(iOffRender == -1)
		iOffRender = FindSendPropInfo("CBasePlayer", "m_clrRender");
	
	SetEntProp(iClient, Prop_Send, "m_nRenderFX", fx, 1);
	SetEntProp(iClient, Prop_Send, "m_nRenderMode", render, 1);  
	SetEntData(iClient, iOffRender, r, 1, true);
	SetEntData(iClient, iOffRender + 1, g, 1, true);
	SetEntData(iClient, iOffRender + 2, b, 1, true);
	SetEntData(iClient, iOffRender + 3, alpha, 1, true);  
}

stock int GetDamageByRange(float distance, int minDmg, int maxDmg, float startRange, float maxRange)
{
	if(distance > maxRange)
		return 0;
	
	if(distance < startRange)
		return maxDmg;
	
	int diffDmg = maxDmg - minDmg;
	
	if(diffDmg <= 0)
		return minDmg;
	
	return minDmg + RoundToFloor(float(diffDmg) * (1.0 - (distance - startRange) / (maxRange - startRange)));
}

stock void DealDamage(int nClientVictim, int nDamage, int nClientAttacker = 0, int nDamageType = DMG_GENERIC, char[] sWeapon = "")
{
	if(	nClientVictim > 0 &&
			IsValidEntity(nClientVictim) &&
			IsClientInGame(nClientVictim) &&
			IsPlayerAlive(nClientVictim) &&
			nDamage > 0)
	{
		int EntityPointHurt = CreateEntityByName("point_hurt");
		if(EntityPointHurt != 0)
		{
			char sDamage[16];
			IntToString(nDamage, sDamage, sizeof(sDamage));

			char sDamageType[32];
			IntToString(nDamageType, sDamageType, sizeof(sDamageType));

			DispatchKeyValue(nClientVictim,			"targetname",		"war3_hurtme");
			DispatchKeyValue(EntityPointHurt,		"DamageTarget",	"war3_hurtme");
			DispatchKeyValue(EntityPointHurt,		"Damage",				sDamage);
			DispatchKeyValue(EntityPointHurt,		"DamageType",		sDamageType);
			if(!StrEqual(sWeapon, ""))
				DispatchKeyValue(EntityPointHurt,	"classname",		sWeapon);
			DispatchSpawn(EntityPointHurt);
			AcceptEntityInput(EntityPointHurt,	"Hurt",					(nClientAttacker != 0) ? nClientAttacker : -1);
			DispatchKeyValue(EntityPointHurt,		"classname",		"point_hurt");
			DispatchKeyValue(nClientVictim,			"targetname",		"war3_donthurtme");

			RemoveEdict(EntityPointHurt);
		}
	}
}

stock bool IsTargetInSightRange(int client, int target, float angle = 90.0, float distance = 0.0, bool heightcheck = true, bool negativeangle = false)
{
	if(angle > 360.0)
		angle = 360.0;
		
	if(angle < 0.0)
		return false;
		
	float clientpos[3];
	float targetpos[3];
	float anglevector[3];
	float targetvector[3];
	float resultangle;
	float resultdistance;
	
	GetClientEyeAngles(client, anglevector);
	anglevector[0] = anglevector[2] = 0.0;
	GetAngleVectors(anglevector, anglevector, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(anglevector, anglevector);
	if(negativeangle)
		NegateVector(anglevector);

	Entity_GetAbsOrigin(client, clientpos);
	Entity_GetAbsOrigin(target, targetpos);
	
	if(heightcheck && distance > 0)
		resultdistance = GetVectorDistance(clientpos, targetpos);
		
	clientpos[2] = targetpos[2] = 0.0;
	MakeVectorFromPoints(clientpos, targetpos, targetvector);
	NormalizeVector(targetvector, targetvector);
	
	resultangle = RadToDeg(ArcCosine(GetVectorDotProduct(targetvector, anglevector)));
	
	if(resultangle <= angle/2)	
	{
		if(distance > 0)
		{
			if(!heightcheck)
				resultdistance = GetVectorDistance(clientpos, targetpos);
				
			if(distance >= resultdistance)
				return true;
			else return false;
		}
		else return true;
	}
	
	return false;
}