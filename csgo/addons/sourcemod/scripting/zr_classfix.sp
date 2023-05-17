#include <sourcemod>
#include <sdktools>
#include <zombiereloaded>

public Plugin:myinfo =
{
	name = "ZR Class Fix",
	author = "Franc1sco franug",
	description = "Class Fix",
	version = "3.4",
	url = "http://steamcommunity.com/id/franug"
};


new Handle:kv;
new Handle:hPlayerClasses, String:sClassPath[PLATFORM_MAX_PATH] = "configs/zr/playerclasses.txt";

new Handle:array_classes;

enum struct zrClasses
{
	int Index;
	int health;
	char model[128];
}

public OnPluginStart()
{
	array_classes = CreateArray(130);
	RegConsoleCmd("sm_testzrfix", Test);
}

public Action:Test(client,args)
{
	zrClasses Items;
	for(new i=0;i<GetArraySize(array_classes);++i)
	{
		GetArrayArray(array_classes, i, Items);
		ReplyToCommand(client, "Zombie Class index %i with health %i and model %s", Items.Index,Items.health,Items.model);
	} 
	
	return Plugin_Handled;
}

public OnAllPluginsLoaded()
{
	if (hPlayerClasses != INVALID_HANDLE)
	{
		UnhookConVarChange(hPlayerClasses, OnClassPathChange);
		CloseHandle(hPlayerClasses);
	}
	if ((hPlayerClasses = FindConVar("zr_config_path_playerclasses")) == INVALID_HANDLE)
	{
		SetFailState("Zombie:Reloaded is not running on this server");
	}
	HookConVarChange(hPlayerClasses, OnClassPathChange);
}

public OnClassPathChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	strcopy(sClassPath, sizeof(sClassPath), newValue);
	OnConfigsExecuted();
}

public OnConfigsExecuted()
{
	CreateTimer(0.2, OnConfigsExecutedPost);
}

public Action:OnConfigsExecutedPost(Handle:timer)
{
	if (kv != INVALID_HANDLE)
	{
		CloseHandle(kv);
	}
	kv = CreateKeyValues("classes");
	
	decl String:buffer[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, buffer, sizeof(buffer), "%s", sClassPath);
	
	if (!FileToKeyValues(kv, buffer))
	{
		SetFailState("Class data file \"%s\" not found", buffer);
	}
	
	
	if (KvGotoFirstSubKey(kv))
	{
		ClearArray(array_classes);
		decl String:name[64], String:enable[32], String:defaultclass[32], String:SMflags[32];
		zrClasses Items;

		do
		{
			KvGetString(kv, "enabled", enable, 32);
			KvGetString(kv, "team_default", defaultclass, 32);
			KvGetString(kv, "sm_flags", SMflags, 32);
			
			// check if is a enabled zombie class and no admin class and it's default class
			if(StrEqual(enable, "yes") && StrEqual(defaultclass, "yes") && KvGetNum(kv, "team") == 0 && KvGetNum(kv, "flags") == 0 && !SMflags[0])
			{
				KvGetString(kv, "name", name, sizeof(name));
				Items.Index = ZR_GetClassByName(name);
				Items.health = KvGetNum(kv, "health", 5000);
				KvGetString(kv, "model_path", Items.model, 128);
				PushArrayArray(array_classes, Items); // save all info in the array
			}
			
		} while (KvGotoNextKey(kv));
	}
	KvRewind(kv);
}

public ZR_OnClientInfected(client, attacker, bool:motherInfect, bool:respawnOverride, bool:respawn)
{
	new vida = GetClientHealth(client);
	if(vida < 300)
	{
		CreateTimer(0.5, Timer_SetDefaultClass, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action:Timer_SetDefaultClass(Handle:timer, any:userid)
{
	int client = GetClientOfUserId(userid);
	
	if(client && IsClientInGame(client) && IsPlayerAlive(client) && ZR_IsClientZombie(client)) 
		SetDefaultClass(client);
}

SetDefaultClass(client)
{
	zrClasses Items;
	new randomnum = GetRandomInt(0, GetArraySize(array_classes)-1); // random value in the array
	GetArrayArray(array_classes, randomnum, Items); // get class info from the array
	
	ZR_SelectClientClass(client, Items.Index, true, true); // set a valid class
	SetEntityHealth(client, Items.health); // apply health of the class selected
	if(strlen(Items.model) > 2 && IsModelPrecached(Items.model)) // check if model is valid and is precached
		SetEntityModel(client, Items.model); // then apply it
}