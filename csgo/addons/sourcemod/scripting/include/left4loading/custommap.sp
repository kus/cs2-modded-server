/*
 * ============================================================================
 *
 *  Left 4 Loading
 *
 *  File:			custommap.sp
 *  Type:			Module
 *  Description:	Reads keyfile to spawn custom end checkpoint doors or 
 *					fences.
 *
 *  Copyright (C) 2010  Mr. Zero <mrzerodk@gmail.com>
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * ============================================================================
 */

// --------------------
//       Private
// --------------------

static	const	String:	FENCE_MODEL_64[]		= "models/props_urban/fence001_64.mdl";
static	const	String:	FENCE_MODEL_128[]		= "models/props_urban/fence001_128.mdl";
static	const	String:	FENCE_MODEL_256[]		= "models/props_urban/fence001_256.mdl";

static	const	String:	PROP_CHECKPOINT[]		= "prop_door_rotating_checkpoint";
static	const	String:	CHECKPOINT_MODEL[]		= "models/props_doors/checkpoint_door_01.mdl";

static	const	String:	KEY_CHECKPOINT[]		= "checkpoint";
static	const	String:	KEY_FENCE[]				= "fence";
static	const	String:	KEY_ORIGIN[]			= "origin";
static	const	String:	KEY_ANGLES[]			= "angles";
static	const	String:	KEY_FADE[]				= "autofade";
static	const	String:	KEY_SIZE[]				= "size";
static	const	String:	KEY_INVISIBLE[]			= "invisible";
static	const	String:	KEY_FREEZE[]			= "freeze";

static	const			MAX_ALPHA				= 255;
static	const			FADE_STEP				= 8;
static	const	Float:	FADE_INTERVAL			= 0.1;

static	const	Float:	CHECK_DOOR_STATUS		= 2.0;

static			String:	g_sKeyFilePath[256]		= "";

static			Handle:	g_hFenceArray			= INVALID_HANDLE;

static					g_iCheckpointDoorRef	= -1;
static			bool:	g_bFadeCheckpoint		= false;

// **********************************************
//                   Forwards
// **********************************************

/**
 * On plugin start.
 *
 * @noreturn
 */
public _CustomMap_OnPluginStart()
{
	BuildPath(Path_SM, g_sKeyFilePath, sizeof(g_sKeyFilePath), "configs/%s/custommap.cfg", PLUGIN_SHORTNAME);
	g_hFenceArray = CreateArray(32);

	HookReadyUpEvent(READYUP_EVENT_END, _CM_OnReadyUpEnd);
	HookReadyUpEvent(READYUP_EVENT_START, _CM_OnReadyUpStart);

	#if defined DEBUG
	RegAdminCmdEx("debug_makesaferoom", _CM_CreateSaferoom_Command, ADMFLAG_ROOT, "Creates the saferoom");
	RegAdminCmdEx("debug_removesaferoom", _CM_RemoveSaferoom_Command, ADMFLAG_ROOT, "Removes the saferoom");
	#endif
}

/**
 * On plugin end.
 *
 * @noreturn
 */
public _CustomMap_OnPluginEnd()
{
	if (GetArraySize(g_hFenceArray) > 0)
	{
		for (new i = 0; i < GetArraySize(g_hFenceArray); i++)
		{
			RemoveEdict(GetArrayCell(g_hFenceArray, i));
		}
		ClearArray(g_hFenceArray);
	}
	new door = EntRefToEntIndex(g_iCheckpointDoorRef);
	if (door > 0 && door <= MAX_ENTITIES && IsValidEntity(door))
	{
		RemoveEdict(door);
	}
}

/**
 * On ready up start.
 *
 * @noreturn
 */
public _CM_OnReadyUpStart()
{
	CreateCustomCheckpoint();
}

/**
 * On ready up end.
 *
 * @noreturn
 */
public _CM_OnReadyUpEnd()
{
	if (GetArraySize(g_hFenceArray) > 0)
	{
		for (new i = 0; i < GetArraySize(g_hFenceArray); i++)
		{
			RemoveEdict(GetArrayCell(g_hFenceArray, i));
		}
		ClearArray(g_hFenceArray);
	}
	new door = EntRefToEntIndex(g_iCheckpointDoorRef);
	if (door > 0 && door <= MAX_ENTITIES && IsValidEntity(door))
	{
		CreateTimer(CHECK_DOOR_STATUS, _CM_CheckCheckpointDoor_Timer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	}
}

/**
 * Called when check checkpoint door interval has elapsed.
 * 
 * @param timer			Handle to the timer object.
 * @noreturn
 */
public Action:_CM_CheckCheckpointDoor_Timer(Handle:timer)
{
	if (!g_bFadeCheckpoint) return Plugin_Stop;

	new door = EntRefToEntIndex(g_iCheckpointDoorRef);
	if (!HasAnySurvivorLeftSafeArea() || IsCheckpointDoorLocked(door)) return Plugin_Continue;
	if (door < 1 || door > MAX_ENTITIES || !IsValidEntity(door)) return Plugin_Stop;

	SetEntityRenderMode(door, RENDER_TRANSCOLOR);
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, MAX_ALPHA);
	CreateTimer(FADE_INTERVAL, _CM_FadeCheckpointDoor, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);
	return Plugin_Stop;
}

/**
 * Called when fade checkpoint door interval has elapsed.
 * 
 * @param timer			Handle to the timer object.
 * @param pack			Handle to datapack.
 * @noreturn
 */
public Action:_CM_FadeCheckpointDoor(Handle:timer, any:pack)
{
	ResetPack(pack);
	new door = EntRefToEntIndex(g_iCheckpointDoorRef);

	if (!IsValidEntity(door)) return Plugin_Stop;

	new alpha = ReadPackCell(pack) - FADE_STEP;
	if (alpha < 0)
	{
		RemoveEdict(door);
		return Plugin_Stop;
	}

	SetEntityRenderColor(door, _, _, _, alpha);
	ResetPack(pack, true);
	WritePackCell(pack, alpha);
	return Plugin_Continue;
}

#if defined DEBUG

public Action:_CM_CreateSaferoom_Command(client, args)
{
	if (GetArraySize(g_hFenceArray) > 0)
	{
		for (new i = 0; i < GetArraySize(g_hFenceArray); i++)
		{
			RemoveEdict(GetArrayCell(g_hFenceArray, i));
		}
		ClearArray(g_hFenceArray);
	}
	new door = EntRefToEntIndex(g_iCheckpointDoorRef);
	if (door > 0  && IsValidEntity(door))
	{
		RemoveEdict(door);
	}

	CreateCustomCheckpoint();
	return Plugin_Handled;
}

public Action:_CM_RemoveSaferoom_Command(client, args)
{
	if (GetArraySize(g_hFenceArray) > 0)
	{
		for (new i = 0; i < GetArraySize(g_hFenceArray); i++)
		{
			RemoveEdict(GetArrayCell(g_hFenceArray, i));
		}
		ClearArray(g_hFenceArray);
	}
	new door = EntRefToEntIndex(g_iCheckpointDoorRef);
	if (door > 0  && IsValidEntity(door))
	{
		RemoveEdict(door);
	}
	return Plugin_Handled;
}

#endif

// **********************************************
//                 Private API
// **********************************************

/**
 * Precaches models needed for custom checkpoint.
 *
 * @noreturn
 */
static PrecacheModels()
{
	PrecacheModel(FENCE_MODEL_64, true);
	PrecacheModel(FENCE_MODEL_128, true);
	PrecacheModel(FENCE_MODEL_256, true);
	PrecacheModel(CHECKPOINT_MODEL, true);
}

/**
 * Creates custom checkpoint and fences from trie
 *
 * @noreturn
 */
static CreateCustomCheckpoint()
{
	PrecacheModels();
	ClearArray(g_hFenceArray);
	new Handle:trie = CreateTrie();
	if (!ReadKeyFile(trie))
	{
		CloseHandle(trie);
		return;
	}

	decl String:value[128], String:key[128], Float:origin[3], Float:angles[3], entity;
	new bool:foundOrigin = true, bool:foundAngles = true;
	for (new i = 0; i < 3; i++)
	{
		Format(key, sizeof(key), "checkpoint_origin_%i", i);
		if (!GetTrieString(trie, key, value, sizeof(value)))
		{
			foundOrigin = false;
			break;
		}
		origin[i] = StringToFloat(value);
	}
	if (foundOrigin)
	{
		foundAngles = true;
		for (new i = 0; i < 3; i++)
		{
			Format(key, sizeof(key), "checkpoint_angles_%i", i);
			if (!GetTrieString(trie, key, value, sizeof(value)))
			{
				foundAngles = false;
				break;
			}
			angles[i] = StringToFloat(value);
		}

		if (foundAngles)
		{
			g_iCheckpointDoorRef = EntIndexToEntRef(CreateCheckpointDoor(origin, angles));
			new buffer;
			if (!GetTrieValue(trie, "checkpoint_fade", buffer) || !buffer)
			{
				g_bFadeCheckpoint = false;
			}
			else
			{
				g_bFadeCheckpoint = true;
			}
		}
	}
	new freeze;
	if (GetTrieValue(trie, "checkpoint_freeze", freeze))
	{
		ForceFreezeSurvivors(bool:freeze);
	}

	new fenceCounter = 0, fenceSize = 0, bool:foundSize, fenceInvisible;
	Format(key, sizeof(key), "fence%i_origin_0", fenceCounter);
	while (GetTrieString(trie, key, value, sizeof(value)))
	{
		foundOrigin = true;
		for (new i = 0; i < 3; i++)
		{
			Format(key, sizeof(key), "fence%i_origin_%i", fenceCounter, i);
			if (!GetTrieString(trie, key, value, sizeof(value)))
			{
				foundOrigin = false;
				break;
			}
			origin[i] = StringToFloat(value);
		}
		if (foundOrigin)
		{
			foundAngles = true;
			for (new i = 0; i < 3; i++)
			{
				Format(key, sizeof(key), "fence%i_angles_%i", fenceCounter, i);
				if (!GetTrieString(trie, key, value, sizeof(value)))
				{
					foundAngles = false;
					break;
				}
				angles[i] = StringToFloat(value);
			}
			if (foundAngles)
			{
				foundSize = true;
				Format(key, sizeof(key), "fence%i_size", fenceCounter);
				if (!GetTrieValue(trie, key, fenceSize))
				{
					foundSize = false;
				}
			}
		}

		if (foundOrigin && foundAngles && foundSize)
		{
			entity = CreateFence(origin, angles, fenceSize);
			if (entity != -1)
			{
				PushArrayCell(g_hFenceArray, entity);

				Format(key, sizeof(key), "fence%i_invisible", fenceCounter);
				if (GetTrieValue(trie, key, fenceInvisible) && fenceInvisible)
				{
					SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
					SetEntityRenderColor(entity, _, _, _, 0);
				}
			}
		}

		fenceCounter++;
		Format(key, sizeof(key), "fence%i_origin_0", fenceCounter);
	}

	CloseHandle(trie);
}

/**
 * Reads the key file into provided trie.
 *
 * @return				True if read into trie, false otherwise.
 */
static bool:ReadKeyFile(&Handle:trie)
{
	ClearTrie(trie);

	if (!FileExists(g_sKeyFilePath))
	{
		return false;
	}

	new String:name[] = PLUGIN_FULLNAME;
	new Handle:kv = CreateKeyValues(name);

	if (!FileToKeyValues(kv, g_sKeyFilePath)) 
	{
		CloseHandle(kv);
		return false;
	}

	if (!KvGotoFirstSubKey(kv, true)) 
	{
		CloseHandle(kv);
		return false;
	}

	decl String:section[128], String:map[128];
	new bool:foundMap = false;
	GetCurrentMap(map, sizeof(map));
	do
	{
		KvGetSectionName(kv, section, sizeof(section));
		if (StrEqual(map, section))
		{
			foundMap = true;
			break;
		}
	} 
	while (KvGotoNextKey(kv));

	if (!foundMap)
	{
		CloseHandle(kv);
		return false;
	}

	decl String:value[1024], String:origin[3][128], String:angles[3][128], String:key[32], fenceSize, fenceInvisible;
	if (KvJumpToKey(kv, KEY_CHECKPOINT, false))
	{

		KvGetString(kv, KEY_ORIGIN, value, sizeof(value), "");
		if (strlen(value) != 0)
		{
			ExplodeString(value, " ", origin, 3, 128);
			for (new i = 0; i < 3; i++)
			{
				Format(key, sizeof(key), "checkpoint_origin_%i", i);
				SetTrieString(trie, key, origin[i], true);
			}
		}

		KvGetString(kv, KEY_ANGLES, value, sizeof(value), "");
		if (strlen(value) != 0)
		{
			ExplodeString(value, " ", angles, 3, 128);
			for (new i = 0; i < 3; i++)
			{
				Format(key, sizeof(key), "checkpoint_angles_%i", i);
				SetTrieString(trie, key, angles[i], true);
			}
		}

		if (KvGetNum(kv, KEY_FADE, 0))
		{
			SetTrieValue(trie, "checkpoint_fade", 1, true);
		}

		if (KvGetNum(kv, KEY_FREEZE, 0))
		{
			SetTrieValue(trie, "checkpoint_freeze", 1, true);
		}

		KvGoBack(kv);
	}

	if (!KvGotoFirstSubKey(kv, true)) 
	{
		CloseHandle(kv);
		return false;
	}

	new fenceCounter = 0;
	do
	{
		KvGetSectionName(kv, section, sizeof(section));
		if (!StrEqual(KEY_FENCE, section)) continue;

		KvGetString(kv, KEY_ORIGIN, value, sizeof(value), "");
		if (strlen(value) == 0) continue;

		ExplodeString(value, " ", origin, 3, 128);
		for (new i = 0; i < 3; i++)
		{
			Format(key, sizeof(key), "fence%i_origin_%i", fenceCounter, i);
			SetTrieString(trie, key, origin[i], true);
		}

		KvGetString(kv, KEY_ANGLES, value, sizeof(value), "");
		if (strlen(value) == 0) continue;

		ExplodeString(value, " ", angles, 3, 128);
		for (new i = 0; i < 3; i++)
		{
			Format(key, sizeof(key), "fence%i_angles_%i", fenceCounter, i);
			SetTrieString(trie, key, angles[i], true);
		}

		fenceSize = KvGetNum(kv, KEY_SIZE, 0);
		if (fenceSize == 0) continue;
		Format(key, sizeof(key), "fence%i_size", fenceCounter);
		SetTrieValue(trie, key, fenceSize, true);

		fenceInvisible = KvGetNum(kv, KEY_INVISIBLE, -1);
		if (fenceInvisible == -1) continue;
		Format(key, sizeof(key), "fence%i_invisible", fenceCounter);
		SetTrieValue(trie, key, fenceInvisible, true);

		fenceCounter++;
	} 
	while (KvGotoNextKey(kv));

	CloseHandle(kv);
	return true;
}

/**
 * Creates a checkpoint door.
 *
 * @param origin		Origin of checkpoint door.
 * @param angles		Angles of checkpoint door.
 * @return				Entity index, or -1 on error.
 */
static CreateCheckpointDoor(const Float:origin[3], const Float:angles[3])
{
	decl String:buffer[1024], Handle:array;
	array = CreateArray(1024);
	if (array == INVALID_HANDLE) 
	{
		return -1;
	}

	new entity = CreateEntityByName(PROP_CHECKPOINT);
	if (entity == -1)
	{
		CloseHandle(array);
		return -1;
	}

	PushArrayString(array, "ajarangles");
	PushArrayString(array, "0 0 0");

	new String:finalizedAngles[256];
	for (new i = 0; i < 3; i++)
	{
		FloatToString(angles[i], buffer, sizeof(buffer));
		Format(finalizedAngles, sizeof(finalizedAngles), "%s %s", finalizedAngles, buffer);
	}
	TrimString(finalizedAngles);
	PushArrayString(array, "angles");
	PushArrayString(array, finalizedAngles);

	new String:finalizedOrigin[256];
	for (new i = 0; i < 3; i++)
	{
		FloatToString(origin[i], buffer, sizeof(buffer));
		Format(finalizedOrigin, sizeof(finalizedOrigin), "%s %s", finalizedOrigin, buffer);
	}
	TrimString(finalizedOrigin);

	PushArrayString(array, "origin");
	PushArrayString(array, finalizedOrigin);

	Format(finalizedOrigin, sizeof(finalizedOrigin), "%s, %s", finalizedOrigin, finalizedOrigin);
	PushArrayString(array, "axis");
	PushArrayString(array, finalizedOrigin);

	PushArrayString(array, "body");
	PushArrayString(array, "1");

	PushArrayString(array, "disableshadows");
	PushArrayString(array, "1");

	PushArrayString(array, "distance");
	PushArrayString(array, "90");

	PushArrayString(array, "glowstate");
	PushArrayString(array, "0");

	// Shows up in hammer but unable to set it
	//PushArrayString(array, "dmg");
	//PushArrayString(array, "0");

	PushArrayString(array, "fademindist");
	PushArrayString(array, "-1");

	PushArrayString(array, "fadescale");
	PushArrayString(array, "1");

	// Shows up in hammer but unable to set it
	//PushArrayString(array, "forcedclosed");
	//PushArrayString(array, "0");

	PushArrayString(array, "glowcolor");
	PushArrayString(array, "0 0 0");

	PushArrayString(array, "glowrange");
	PushArrayString(array, "0");

	PushArrayString(array, "targetname");
	PushArrayString(array, "checkpoint_exit");

	PushArrayString(array, "hardware");
	PushArrayString(array, "1");

	PushArrayString(array, "speed");
	PushArrayString(array, "200");

	PushArrayString(array, "health");
	PushArrayString(array, "0");

	PushArrayString(array, "spawnpos");
	PushArrayString(array, "0");

	PushArrayString(array, "model");
	PushArrayString(array, CHECKPOINT_MODEL);

	PushArrayString(array, "spawnflags");
	PushArrayString(array, "8192");

	PushArrayString(array, "opendir");
	PushArrayString(array, "0");

	PushArrayString(array, "skin");
	PushArrayString(array, "0");

	PushArrayString(array, "rendercolor");
	PushArrayString(array, "255 255 255");

	PushArrayString(array, "returndelay");
	PushArrayString(array, "-1");

	decl String:key[1024];
	new bool:setValueFail = false;
	for (new i = 0; i < GetArraySize(array); i += 2)
	{
		GetArrayString(array, i, key, sizeof(key));
		GetArrayString(array, i + 1, buffer, sizeof(buffer));
		if (!DispatchKeyValue(entity, key, buffer))
		{
			setValueFail = true;
			break;
		}
	}

	if (setValueFail || !DispatchSpawn(entity))
	{
		RemoveEdict(entity);
		entity = -1;
	}

	CloseHandle(array);
	return entity;
}

/**
 * Creates a fence that survivors can't go through but infected can.
 *
 * @param origin		Origin of the fence.
 * @param angles		Angles of the fence.
 * @param size			Size of the fence.
 * @return 				Entity index, or -1 on error.
 */
static CreateFence(const Float:origin[3], const Float:angles[3], const size)
{
	decl String:buffer[1024], Handle:array;
	array = CreateArray(1024);
	if (array == INVALID_HANDLE) 
	{
		return -1;
	}

	new entity = CreateEntityByName(PROP_CHECKPOINT);
	if (entity == -1)
	{
		CloseHandle(array);
		return -1;
	}

	new String:finalizedAngles[256];
	for (new i = 0; i < 3; i++)
	{
		FloatToString(angles[i], buffer, sizeof(buffer));
		Format(finalizedAngles, sizeof(finalizedAngles), "%s %s", finalizedAngles, buffer);
	}
	TrimString(finalizedAngles);
	PushArrayString(array, "angles");
	PushArrayString(array, finalizedAngles);

	new String:finalizedOrigin[256];
	for (new i = 0; i < 3; i++)
	{
		FloatToString(origin[i], buffer, sizeof(buffer));
		Format(finalizedOrigin, sizeof(finalizedOrigin), "%s %s", finalizedOrigin, buffer);
	}
	TrimString(finalizedOrigin);

	PushArrayString(array, "origin");
	PushArrayString(array, finalizedOrigin);

	PushArrayString(array, "disableshadows");
	PushArrayString(array, "1");

	PushArrayString(array, "solid");
	PushArrayString(array, "2");

	PushArrayString(array, "model");
	PushArrayString(array, (size == 256 ? FENCE_MODEL_256 : (size == 128 ? FENCE_MODEL_128 : FENCE_MODEL_64)));

	PushArrayString(array, "spawnflags");
	PushArrayString(array, "32768");

	decl String:key[1024];
	new bool:setValueFail = false;
	for (new i = 0; i < GetArraySize(array); i += 2)
	{
		GetArrayString(array, i, key, sizeof(key));
		GetArrayString(array, i + 1, buffer, sizeof(buffer));
		if (!DispatchKeyValue(entity, key, buffer))
		{
			setValueFail = true;
			break;
		}
	}

	if (setValueFail || !DispatchSpawn(entity))
	{
		RemoveEdict(entity);
		entity = -1;
	}

	CloseHandle(array);
	return entity;
}