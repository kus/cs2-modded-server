#include <sourcemod>
#include <sdktools>
#include <eyal-jailbreak>

#undef REQUIRE_PLUGIN
#undef REQUIRE_EXTENSIONS
#tryinclude < updater>    // Comment out this line to remove updater support by force.
#define REQUIRE_PLUGIN
#define REQUIRE_EXTENSIONS

#define UPDATE_URL "https://raw.githubusercontent.com/eyal282/csgo-jailbreak-package/master/addons/sourcemod/updatefile.txt"
#define UPDATE_URL2 "https://raw.githubusercontent.com/eyal282/sm_muted_indicator/master/addons/sourcemod/updatefile.txt"

#pragma semicolon 1
#pragma newdecls  required

public Plugin myinfo =
{
	name        = "JailBreak Core",
	author      = "Eyal282",
	description = "Core JailBreak Plugin",
	version     = "1.0",
	url         = ""
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	RegPluginLibrary("JB_Core");

	return APLRes_Success;
}
public void OnPluginStart()
{
	//RegConsoleCmd("sm_rebeltest", Command_Test);
	CreateDirectory("cfg/sourcemod/JBPack", FPERM_ULTIMATE);

	SetFilePermissions("cfg/sourcemod/JBPack", FPERM_ULTIMATE);

	AutoExecConfig_SetFile("JB_Core", "sourcemod/JBPack");

	UC_CreateConVar("sm_prefix_cvar", "[{RED}JBPack{NORMAL}] {NORMAL}", "List of colors: NORMAL, RED, GREEN, LIGHTGREEN, OLIVE, LIGHTRED, GRAY, YELLOW, ORANGE, BLUE, PINK");
	UC_CreateConVar("sm_menu_prefix_cvar", "[JBPack]");

	AutoExecConfig_ExecuteFile();

	AutoExecConfig_CleanFile();

#if defined _updater_included

	if (LibraryExists("updater"))
	{
		Updater_AddPlugin(UPDATE_URL);
		Updater_AddPlugin(UPDATE_URL2);
		
	}

#endif
}
/*
public Action Command_Test(int client, int args)
{
	int ent = -1;

	int count;

	int weapon = -1;
	int teleport = -1;

	ArrayList weapons = new ArrayList(1);
	ArrayList teleports = new ArrayList(1);

	while((weapon = FindEntityByClassname(weapon, "weapon_*")) != -1)
	{
		if(!HasEntProp(weapon, Prop_Send, "m_zoomLevel"))
			continue;

		// Weapon is an illusion and cannot be picked up.
		else if(!GetEntProp(weapon, Prop_Data, "m_bCanBePickedUp"))
			continue;

		weapons.Push(weapon);
	}

	while((teleport = FindEntityByClassname(teleport, "trigger_teleport")) != -1)
	{
		if(GetEntProp(teleport, Prop_Data, "m_bDisabled"))
			continue;

		teleports.Push(teleport);
	}

	while((ent = FindEntityByClassname(ent, "info_player_terrorist")) != -1)
	{
		bool found = false;

		float fOrigin[3], fCeilOrigin[3];

		GetEntPropVector(ent, Prop_Data, "m_vecAbsOrigin", fOrigin);
		GetCeilOrigin(ent, fCeilOrigin);

		for(int i=0;i < weapons.Length;i++)
		{
			weapon = weapons.Get(i);
			float fWeaponOrigin[3];
			GetEntPropVector(weapon, Prop_Data, "m_vecAbsOrigin", fWeaponOrigin);


			if(GetVectorDistance(fOrigin, fWeaponOrigin) <= 256.0)
			{
				fWeaponOrigin[2] += 16.0;
				TeleportEntity(weapon, fWeaponOrigin, NULL_VECTOR, NULL_VECTOR);
				TR_TraceRayFilter(fCeilOrigin, fWeaponOrigin, MASK_SOLID_BRUSHONLY, RayType_EndPoint, TraceRayHitTargetOrWorld, weapon);
				fWeaponOrigin[2] -= 16.0;
				TeleportEntity(weapon, fWeaponOrigin, NULL_VECTOR, NULL_VECTOR);

				int BeamIndex   = PrecacheModel("materials/sprites/laserbeam.vmt");
				int HaloIdx     = PrecacheModel("materials/sprites/glow01.vmt");

				TE_SetupBeamPoints(fCeilOrigin, fWeaponOrigin, BeamIndex, 0, 0, 0, 5.0, 1.0, 1.0, 1, 3.0, {255, 255, 255, 255}, 0);
				TE_SendToAll();

				if(TR_DidHit())
				{

					if(TR_GetEntityIndex() == weapon && !found)
					{
						found = true;
						weapons.Erase(i);
						i--;
						count++;
					}
				}
			}
		}

		for(int i=0;i < teleports.Length;i++)
		{
			teleport = teleports.Get(i);
			float fTeleportOrigin[3];
			GetEntPropVector(teleport, Prop_Data, "m_vecAbsOrigin", fTeleportOrigin);

			if(GetVectorDistance(fOrigin, fTeleportOrigin) <= 256.0)
			{
				TR_TraceRayFilter(fCeilOrigin, fTeleportOrigin, CONTENTS_SOLID, RayType_EndPoint, TraceRayHitWorld);

				float fEndPos[3];
				TR_GetEndPosition(fEndPos);

				float fDistance = GetVectorDistance(fCeilOrigin, fEndPos);

				Handle DP = CreateDataPack();

				WritePackCell(DP, teleport);
				WritePackFloat(DP, fDistance);
				WritePackFloat(DP, fCeilOrigin[0]);
				WritePackFloat(DP, fCeilOrigin[1]);
				WritePackFloat(DP, fCeilOrigin[2]);

				TR_EnumerateEntities(fCeilOrigin, fTeleportOrigin, PARTITION_TRIGGER_EDICTS, RayType_EndPoint, EnumerateHitTarget, DP);

				CloseHandle(DP);

				int BeamIndex   = PrecacheModel("materials/sprites/laserbeam.vmt");

				TE_SetupBeamPoints(fCeilOrigin, fTeleportOrigin, BeamIndex, 0, 0, 0, 5.0, 1.0, 1.0, 1, 3.0, {255, 255, 255, 255}, 0);
				TE_SendToAll();

				if(TR_DidHit())
				{

					if(TR_GetEntityIndex() == teleport && !found)
					{
						found = true;
						teleports.Erase(i);
						i--;
						count++;
					}
				}
			}
		}
	}

	PrintToChatAll("%i", count);
}
*/

// return true to continue enumerating, or false to stop
public bool EnumerateHitTarget(int entity, Handle DP)
{
	ResetPack(DP);

	int target = ReadPackCell(DP);
	float fDistance = ReadPackFloat(DP);

	float fCeilOrigin[3];

	fCeilOrigin[0] = ReadPackFloat(DP);
	fCeilOrigin[1] = ReadPackFloat(DP);
	fCeilOrigin[2] = ReadPackFloat(DP);

	if(!IsValidEdict(entity))
		return true;


	if(entity == target)
	{
		float fOrigin[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", fOrigin);

		PrintToChatAll("%.2f %.2f", fDistance, GetVectorDistance(fOrigin, fCeilOrigin));
		if(GetVectorDistance(fOrigin, fCeilOrigin) <= fDistance)
		{
			TR_ClipCurrentRayToEntity(MASK_ALL, entity);

			int BeamIndex   = PrecacheModel("materials/sprites/laserbeam.vmt");

			TE_SetupBeamPoints(fCeilOrigin, fOrigin, BeamIndex, 0, 0, 0, 5.0, 1.0, 1.0, 1, 3.0, {255, 0, 0, 255}, 0);
			TE_SendToAll();
			PrintToChatAll("%i", entity);

			return false;
		}
	}
	
	return true;
}

public void OnMapStart()
{

}


stock void GetCeilOrigin(int entity, float fOrigin[3])
{
	
	GetEntPropVector(entity, Prop_Data, "m_vecOrigin", fOrigin);

	float fFakeOrigin[3];

	fFakeOrigin = fOrigin;

	fFakeOrigin[2] = 2147483647.0;

	TR_TraceRayFilter(fOrigin, fFakeOrigin, MASK_PLAYERSOLID, RayType_EndPoint, TraceRayHitWorld);

	TR_GetEndPosition(fOrigin);
}

public bool TraceRayHitWorld(int entity, int contentsMask)
{
	if(entity == 0)
		return true;

	return false;
}


public bool TraceRayHitTargetOrWorld(int entity, int contentsMask, int target)
{
	if(entity == 0 || entity == target)
		return true;

	return false;
}
public void OnLibraryAdded(const char[] name)
{
#if defined _updater_included

	if (StrEqual(name, "updater"))
	{
		Updater_AddPlugin(UPDATE_URL);
		Updater_AddPlugin(UPDATE_URL2);
	}

#endif
}

/**
 * Adds an informational string to the server's public "tags".
 * This string should be a short, unique identifier.
 *
 *
 * @param tag            Tag string to append.
 * @noreturn
 */
stock void AddServerTag2(const char[] tag)
{
	Handle hTags = INVALID_HANDLE;
	hTags        = FindConVar("sv_tags");

	if (hTags != INVALID_HANDLE)
	{
		int flags = GetConVarFlags(hTags);

		SetConVarFlags(hTags, flags & ~FCVAR_NOTIFY);

		char tags[50];    // max size of sv_tags cvar
		GetConVarString(hTags, tags, sizeof(tags));
		if (StrContains(tags, tag, true) > 0) return;
		if (strlen(tags) == 0)
		{
			Format(tags, sizeof(tags), tag);
		}
		else
		{
			Format(tags, sizeof(tags), "%s,%s", tags, tag);
		}
		SetConVarString(hTags, tags, true);

		SetConVarFlags(hTags, flags);
	}
}

/**
 * Removes a tag previously added by the calling plugin.
 *
 * @param tag            Tag string to remove.
 * @noreturn
 */
stock void RemoveServerTag2(const char[] tag)
{
	Handle hTags = INVALID_HANDLE;
	hTags        = FindConVar("sv_tags");

	if (hTags != INVALID_HANDLE)
	{
		int flags = GetConVarFlags(hTags);

		SetConVarFlags(hTags, flags & ~FCVAR_NOTIFY);

		char tags[50];    // max size of sv_tags cvar
		GetConVarString(hTags, tags, sizeof(tags));
		if (StrEqual(tags, tag, true))
		{
			Format(tags, sizeof(tags), "");
			SetConVarString(hTags, tags, true);
			return;
		}

		int pos = StrContains(tags, tag, true);
		int len = strlen(tags);
		if (len > 0 && pos > -1)
		{
			bool found;
			char taglist[50][50];
			ExplodeString(tags, ",", taglist, sizeof(taglist[]), sizeof(taglist));
			for (int i = 0; i < sizeof(taglist[]); i++)
			{
				if (StrEqual(taglist[i], tag, true))
				{
					Format(taglist[i], sizeof(taglist), "");
					found = true;
					break;
				}
			}
			if (!found) return;
			ImplodeStrings(taglist, sizeof(taglist[]), ",", tags, sizeof(tags));
			if (pos == 0)
			{
				tags[0] = 0x20;
			}
			else if (pos == len - 1)
			{
				Format(tags[strlen(tags) - 1], sizeof(tags), "");
			}
			else
			{
				ReplaceString(tags, sizeof(tags), ",,", ",");
			}

			SetConVarString(hTags, tags, true);

			SetConVarFlags(hTags, flags);
		}
	}
}