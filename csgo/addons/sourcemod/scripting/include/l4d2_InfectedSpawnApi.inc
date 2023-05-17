/* (c) Infected Spawn API by V10 aka maldersoft (http://sourcemod.V10.name).
* This API written for l4d2 plugin writers to correct spawn infected bosses with more options (owner,ghost, startorigin, etc).
* Also plugin implement easy utils functions (stocks).
* Put InfectedAPI.txt to addons\sourcemod\gamedata folder!
*/ 

/* ChangeLog: 
* 1.6.1
* - Fixed spawn command from z_spawn to z_spawn_old.
* 1.6
* - Added array g_iMaxInfectedCounts[]
* - Removed GetMaxInfectedCounts()
* - Added InitInfectedSpawnAPI() you must call this in Plugin_Start()
* - Removed all checks for alive and other checks. Now plugin must use it.
* - Some optimizations
* 1.5
* - Added function StringToClass
* - Improved small optimizations
* - Added check player claws entity id to prevent errors
* 1.4
* - updated InfectedAPI.txt: added offset RefEHandleOffset
* - simple changes in GenerateZombieId
* - fixed all MAXPLAYERS to MaxClients
* - disable use function InfectedForceGhostFinale
* - Added second try to spawn if first fail
* - updated InfectedAPI.txt: changed sign OnEnterGhostState (thanks to AtomicStryker)
* 1.3
* - Allow ghost mode for class TANK also (check removed)
* - Added config file gamedata\InfectedAPI.txt
* - Added bGhostFinale parameter to function SpawnInfectedBoss
* - Temporary removed InfectedAPI_mm (no needed now)
* - Added function InfectedForceGhost to correct spawn ghost and ghost in finale without any exstensions (l4dtoolz, etc)
* - Removed InitializeAsGhost (is not a reliable function)
* - Added function to correct generate random infected class 
* - Added function to correct change infected class (based on SDK)
* - Added new consts for classes,also fixed bug with TANK (ZC_WITCH=7, ZC_TANK=8, ZC_NOT_INFECTED=9)
* - Changed g_sBossNames
* - Changed array in GetInfectedCounts() to Array[ZC_NOT_INFECTED], also now return TANK count
* - Added function GetInfectedClass
* - Added debug log to file.
* 1.2
* - Added metamod plugin for spawn ghost in finale (cvar z_ghost_finale).
* - Added detect l4dtoolz for spawning ghost in finale.
* - Removed fGhostFinale (not needed).
* - Removed function InitializeInfectedAPI (not needed).
* - Added param Velocity to function SpawnInfectedBoss.
* - Added counter to prevent infinite loop on try spawn ghost.
* - Fixed some bugs.
* 1.1
* - Added function GetInfectedCounts.
* - Added function GetMaxInfectedCounts.
* 1.0
* - Initial release.
* 
*/

#if defined _infectedapi_included
#endinput
#endif
#define _infectedapi_included

#include <sourcemod>
#include <sdktools>

#define InfectedApiVersion1_5 1
#define InfectedApiVersion1_6 1
#define InfectedAPIDebug 0

#define TEAM_SURVIVOR 2
#define TEAM_INFECTED 3

#define STATE_GHOST 8

#define ZC_SMOKER 1
#define ZC_BOOMER 2
#define ZC_HUNTER 3
#define ZC_SPITTER 4
#define ZC_JOCKEY 5
#define ZC_CHARGER 6
#define ZC_WITCH 7
#define ZC_TANK 8
#define ZC_NOT_INFECTED 9     //survivor

new String:g_sBossNames[ZC_NOT_INFECTED+1][10]={"","smoker","boomer","hunter","spitter","jockey","charger","witch","tank","survivor"};

#if InfectedAPIDebug
new String:g_ISAPI_slogPath[256];

#endif
new g_iMaxInfectedCounts[ZC_TANK];

new bool:g_ISAPIInited=false;
new g_ISAPI_propinfo_isAlive = -1;
new g_ISAPI_propinfoghost = -1;
new g_ISAPI_propinfo_zombieClass = -1;
new g_ISAPI_propinfo_customAbility = -1;
//new g_ISAPI_propinfo_lifeState = -1;
new g_ISAPI_propinfo_isCulling = -1;
new g_ISAPI_propinfo_vecVelocity0 = -1;

new g_ISAPI_WindowsOrLinux = 0;
new  Handle:g_ISAPI_fhZombieAbortControl = INVALID_HANDLE;
new Handle:g_ISAPI_fhCreateAbility = INVALID_HANDLE;
new Handle:g_ISAPI_fhSetClass = INVALID_HANDLE;
new g_ISAPI_iRefEHandleOffset = -1;


InitInfectedSpawnAPI()
{
#if InfectedAPIDebug
	BuildPath(Path_SM, g_ISAPI_slogPath, sizeof(g_ISAPI_slogPath), "logs/l4d2_InfectedAPI.log");	
#endif

	g_ISAPI_propinfo_isAlive = FindSendPropInfo("CTransitioningPlayer", "m_isAlive");
	g_ISAPI_propinfoghost = FindSendPropInfo("CTerrorPlayer", "m_isGhost");
	g_ISAPI_propinfo_zombieClass = FindSendPropInfo("CTerrorPlayer", "m_zombieClass");
	g_ISAPI_propinfo_customAbility = FindSendPropInfo("CTerrorPlayer", "m_customAbility");
	//g_ISAPI_propinfo_lifeState = FindSendPropInfo("CTerrorPlayer", "m_lifeState");
	g_ISAPI_propinfo_isCulling = FindSendPropInfo("CTerrorPlayer", "m_isCulling");
	g_ISAPI_propinfo_vecVelocity0 = FindSendPropInfo("CTerrorPlayer", "m_vecVelocity[0]");

	
	new Handle:gConf = LoadGameConfigFile("InfectedAPI");

	g_ISAPI_WindowsOrLinux = GameConfGetOffset(gConf, "WindowsOrLinux");
	g_ISAPI_iRefEHandleOffset = GameConfGetOffset(gConf, "RefEHandleOffset"); //from CBaseEntity::GetRefEHandle
	
	//CTerrorPlayer::PlayerZombieAbortControl(client,float=0)
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gConf, SDKConf_Signature, "ZombieAbortControl");
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	g_ISAPI_fhZombieAbortControl = EndPrepSDKCall();
	if (g_ISAPI_fhZombieAbortControl == INVALID_HANDLE){
		SetFailState("Infected API can't get ZombieAbortControl SDKCall!");
		return;
	}			
	
	//CBaseAbility::CreateForPlayer(client)
	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(gConf, SDKConf_Signature, "CreateAbility");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
	g_ISAPI_fhCreateAbility = EndPrepSDKCall();

	//CTerrorPlayer::SetClass(client,class)
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gConf, SDKConf_Signature, "SetClass");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	g_ISAPI_fhSetClass = EndPrepSDKCall();
	if (g_ISAPI_fhSetClass == INVALID_HANDLE || g_ISAPI_fhCreateAbility == INVALID_HANDLE || g_ISAPI_iRefEHandleOffset == -1){
		SetFailState("Infected API can't get CreateAbility or SetClass SDKCall or RefEHandleOffset!");
		return;
	}			

	
	CloseHandle(gConf);

	__InitMaxInfectedCount(true);

	g_ISAPIInited=true;
}

public __ISAPI_ConVarChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	__InitMaxInfectedCount();
}

stock __InitMaxInfectedCount(bool:regchangecallback = false)
{
	for (new i=ZC_SMOKER; i<=ZC_CHARGER; i++){ 
		new String:CVarName[50];
		Format(CVarName,sizeof(CVarName),"z_versus_%s_limit",g_sBossNames[i]);
		new Handle:cvar=FindConVar(CVarName);
		g_iMaxInfectedCounts[i]=GetConVarInt(cvar);
		if (regchangecallback)
			HookConVarChange(cvar, __ISAPI_ConVarChanged);
	}
}

/**
* Spawn the specified zombie boss
*
* @param client				Client index.
* @param Class				Class of boss (see constants ZC_ in top of this file)
* @param bGhost				True = spawned as ghost, False= spawned as alived..
* @param bGhostFinale		True = spawned as ghost in finale, False= spawned as alived.in finale
* @param bAuto				Use director auto position? True = use, False = spawn in eye direction (if param Origin not set)
* @param Origin 			Set position new zombie
* @param Angles 			Set angles new zombie
* @param Velocity			Set velocitys new zombie
* @return					True if successfully spawn, false otherwise.
* @error			Invalid handle, or bounds error.
* 					Invalid infected class
* 					Client is alive
* 					Client is not in game
* 					Client is not infected team
* 					Can't get open config file (gamedata\InfectedAPI.txt) (FAILSTATE FOR PLUGIN)
* 					Can't get offsets (FAILSTATE FOR PLUGIN)
*/


stock SpawnInfectedBoss(client, Class, bool:bGhost=false, bool:bAuto=true, bool:bGhostFinale=false ,const Float:Origin[3]=NULL_VECTOR,const Float:Angles[3]=NULL_VECTOR,const Float:Velocity[3]=NULL_VECTOR)
{
	if  (!g_ISAPIInited)
		InitInfectedSpawnAPI();
	new bool:resetGhostState[MaxClients+1];
	new bool:resetIsAlive[MaxClients+1];
	new bool:resetLifeState[MaxClients+1];
	decl String:options[30];
//	if (Class<ZC_SMOKER || Class>ZC_TANK) return false;
//	if (GetClientTeam(client) != TEAM_INFECTED) return false;
	if (!IsClientInGame(client)) return false;
	if (IsPlayerAlive(client) && Class != ZC_WITCH) return false;
	
	if (Class != ZC_WITCH)
	{
		for (new i=1; i<=MaxClients; i++){ 
			if (i == client) continue; //dont disable the chosen one
			if (!IsClientInGame(i)) continue; //not ingame? skip
			if (GetClientTeam(i) != TEAM_INFECTED) continue; //not infected? skip
			if (IsFakeClient(i)) continue; //a bot? skip
			
			if (IsPlayerGhost(i)){
				resetGhostState[i] = true;
				SetPlayerGhostStatus(i, false);
				resetIsAlive[i] = true; 
				SetPlayerIsAlive(i, true);
			}
			else if (!IsPlayerAlive(i)){
				resetLifeState[i] = true;
				SetPlayerLifeState(i, false);
			}
		}
	}

	//spawn zombie
	Format(options,sizeof(options),"%s%s",g_sBossNames[Class],(bAuto?" auto":""));
	#if InfectedAPIDebug
	InfAPIDebugPrint("Spawn zombie: %s",options);
	#endif
	CheatCommand(client, "z_spawn_old",options );
	if (Class == ZC_WITCH) return true;
	
	//Second try
	if (!IsPlayerAlive(client))
		CheatCommand(client, "z_spawn_old",options );
	
	// We restore the player's status
	for (new i=1; i<=MaxClients; i++){
		if (resetGhostState[i]) SetPlayerGhostStatus(i, true);
		if (resetIsAlive[i]) SetPlayerIsAlive(i, false);
		if (resetLifeState[i]) SetPlayerLifeState(i, true);
	}
	
	if (Origin[0]!=0.0)	TeleportEntity(client, Origin, Angles,Velocity);
	if (bGhost) return InfectedForceGhost(client,true,bGhostFinale);
	return IsPlayerAlive(client);
}

/**
* Force infected to full ghost state
* 
* @param client			Client index.
* @param SavePos		True = save position, False = spawn in director pos
* @param inFinaleAlso	True = ghost in finale, False = return false in finale
* @return				True if successfully , false otherwise.
* @error				Invalid handle, or bounds error.
* 						Client is alive
* 						Client is already ghost
* 						Client is not in game
* 						Client is not infected team
* 						Can't get open config file (gamedata\InfectedAPI.txt) (FAILSTATE FOR PLUGIN)
*  						Can't get offsets (FAILSTATE FOR PLUGIN)
*
*  Notice: Function detect l4dtoolz and if sv_force_normal_respawn==1 to spawn ghost in finales, ignore inFinaleAlso
*/

stock bool:InfectedForceGhost(client, SavePos=false, inFinaleAlso=false){
	decl Float:AbsOrigin[3];
	decl Float:EyeAngles[3];
	decl Float:Velocity[3];
	
//	if (!IsClientInGame(client)) return false;
//	if (GetClientTeam(client) != TEAM_INFECTED) return false;
//	if (!IsPlayerAlive(client)) return false;
	if (IsPlayerGhost(client)) return false;
//	if (IsFakeClient(client)) return false;
	
	if (SavePos){
		GetClientAbsOrigin(client, AbsOrigin);
		GetClientEyeAngles(client, EyeAngles);
		//GetEntDataVector(client, g_ISAPI_propinfo_vecVelocity0, Velocity);
		Velocity[0] = GetEntDataFloat(client, g_ISAPI_propinfo_vecVelocity0);
		Velocity[1] = GetEntDataFloat(client, g_ISAPI_propinfo_vecVelocity0 + 4);
		Velocity[2] = GetEntDataFloat(client, g_ISAPI_propinfo_vecVelocity0 + 8);	
	}
	//if (IsFinale() && !inFinaleAlso && !isGhostsFinale()) return false;
	
	/*if (IsFinale() && !isGhostsFinale()) {
		new bool:result=InfectedForceGhostFinale(client);
		if (result && SavePos) TeleportEntity(client, AbsOrigin, EyeAngles, Velocity);	
		return result;
	}*/
	
	SetEntData(client, g_ISAPI_propinfo_isCulling, 1, 1);
	SDKCall(g_ISAPI_fhZombieAbortControl, client, 0.0);
	if (SavePos) TeleportEntity(client, AbsOrigin, EyeAngles, Velocity);
	return true;
}


/**
* Change infected zombie class
* 
* @param client			Client index.
* @param newclass		New class for zombie
* @return				True if successfully , false otherwise.
* @error				Invalid handle, or bounds error.
* 						Client is alive
* 						Client is already ghost
* 						Client is not in game
* 						Client is not infected team
* 						Can't get open config file (gamedata\InfectedAPI.txt) (FAILSTATE FOR PLUGIN)
*  						Can't get offsets (FAILSTATE FOR PLUGIN)
*/

stock InfectedChangeClass(client,newclass){
	// Remove old claw
	new  ClawEnt=GetPlayerWeaponSlot(client, 0);
	if (IsValidEntity(ClawEnt))
		RemovePlayerItem(client, ClawEnt);
	// Change class
	SDKCall(g_ISAPI_fhSetClass, client,newclass);
	//Destroy old ability
	
//	AcceptEntityInput(GetEntPropEnt(client, Prop_Send, "m_customAbility"),"Kill");//MakeCompatEntRef(
	AcceptEntityInput(GetEntDataEnt2(client, g_ISAPI_propinfo_customAbility),"Kill");
	//Create new ability
	SetEntData(client, g_ISAPI_propinfo_customAbility, GetEntData(SDKCall(g_ISAPI_fhCreateAbility,client),g_ISAPI_iRefEHandleOffset));

	return true;
}

/**
* Correctly generate new zombie class id for spawn, change, etc
* 
* @param client			Client index.
* @param lastClass		Last used class (for exlude same class)
* @return				Corectry randomed new class id
*/

stock GenerateZombieId(lastClass, bool:checkmax=true)
{	
	new ZombieId=GetRandomInt(ZC_SMOKER,ZC_CHARGER);
	
	if (checkmax) {
		//get counts
		decl Zombies[ZC_NOT_INFECTED];  Zombies=GetInfectedCounts();
	
		//calc random
		new bool:Randoms[ZC_TANK];
		new RandomCount;
		for (new i=ZC_SMOKER; i<=ZC_CHARGER; i++){ 
			if (lastClass==i) continue;
			if (g_iMaxInfectedCounts[i]>Zombies[i]){
				Randoms[i]=true;
				RandomCount++;			
			}
		}
		if (RandomCount > 0){
			for (new i=1; i<=10; i++){ 
				ZombieId=GetRandomInt(ZC_SMOKER,ZC_CHARGER);
				#if defined DEBUG_GENERATOR
					InfAPIDebugPrint("Generate zombie. cycle=%d ZombieId=%d [t=%d,c=%d]",i,ZombieId,RandomCount,Randoms[ZombieId]);
				#endif
				if (!Randoms[ZombieId])  continue;
				if (ZombieId != lastClass)  return ZombieId;
			}
		}
	}
	if (ZombieId == lastClass){
		while (ZombieId == lastClass) { ZombieId = GetRandomInt(ZC_SMOKER,ZC_CHARGER); }
	}
	return ZombieId;
}


/**
* Get all infected boss counts
* 
* @return			Array longs from ZC_SMOKER to ZC_TANK (Array[ZC_NOT_INFECTED])
* Notice:			This function not return wiches count
*/
stock GetInfectedCounts(){
	new ZombieCounts[ZC_NOT_INFECTED];
	for (new i=1; i<=MaxClients; i++){ 
		if (!IsClientInGame(i)) continue; 
		if (!IsPlayerAlive(i)) continue;
		new ZClass = GetInfectedClass(i);
		if (ZClass<ZC_NOT_INFECTED) 
			ZombieCounts[ZClass]++;
	}
	return ZombieCounts;
}

/**
* Get Player class 
* 
* @param client	Client index.
* @return			player class
* 
*/
stock GetInfectedClass(client){ return GetEntData(client, g_ISAPI_propinfo_zombieClass);}

stock SetPlayerIsAlive(client, bool:alive)
{
	if (alive) SetEntData(client, g_ISAPI_propinfo_isAlive, 1, 1, true);
	else SetEntData(client, g_ISAPI_propinfo_isAlive, 0, 1, true);
}

stock StringToClass(const String:zclass[])
{
	if (!strcmp(zclass,g_sBossNames[ZC_SMOKER]) return ZC_SMOKER;
	if (!strcmp(zclass,g_sBossNames[ZC_BOOMER]) return ZC_BOOMER;
	if (!strcmp(zclass,g_sBossNames[ZC_HUNTER]) return ZC_HUNTER;
	if (!strcmp(zclass,g_sBossNames[ZC_SPITTER]) return ZC_SPITTER;
	if (!strcmp(zclass,g_sBossNames[ZC_JOCKEY]) return ZC_JOCKEY;
	if (!strcmp(zclass,g_sBossNames[ZC_CHARGER]) return ZC_CHARGER;
	if (!strcmp(zclass,g_sBossNames[ZC_WITCH]) return ZC_WITCH;
	if (!strcmp(zclass,g_sBossNames[ZC_TANK]) return ZC_TANK;
}

/*
stock bool:IsPlayerGhost(client)
{
	if (GetEntData(client, g_ISAPI_propinfoghost, 1)) return true;
	return false;
}
*/
stock SetPlayerGhostStatus(client, bool:ghost)
{
	if(ghost)
		SetEntData(client, g_ISAPI_propinfoghost, 1, 1)
	else
		SetEntData(client, g_ISAPI_propinfoghost, 0, 1)	
}
/*
stock SetPlayerLifeState(client, bool:ready)
{
//	if (ready) SetEntProp(client, Prop_Data, "m_lifeState", 1, 1);
//	else SetEntProp(client, Prop_Data, "m_lifeState", 0, 1);
	if (ready) SetEntData(client, g_ISAPI_propinfo_lifeState, 1, 1);
	else SetEntData(client, g_ISAPI_propinfo_lifeState, 0, 1);
}

*/

stock CheatCommand(client, const String:command[], const String:arguments[]="")
{
	if (!client) return;
	new admindata = GetUserFlagBits(client);
	SetUserFlagBits(client, ADMFLAG_ROOT);
	new flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s", command, arguments);
	SetCommandFlags(command, flags);
	SetUserFlagBits(client, admindata);
}

stock bool:isWin32() { return g_ISAPI_WindowsOrLinux==1; }

#if InfectedAPIDebug
InfAPIDebugPrint(const String:format[], any:...)
{
	if  (!g_ISAPIInited)
		ThrowError("!Infected Spawn API not inited");
	decl String:buffer[300];
	VFormat(buffer, sizeof(buffer), format, 2);
	LogToFileEx(g_ISAPI_slogPath,buffer);
}
#endif
