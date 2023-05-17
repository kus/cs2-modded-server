//Roleplay Stocks v1.0 by Joe 'Pinkfairie' Maley

//Variable:
static Float:GameTime[64];

new bool:g_knife = false;

/*
 * Set's up for RP
 * @param DesiredMap Name of the map you play on
 */
stock FixMap(const String:DesiredMap[255])
{

	//Declare:
	//decl Teamplay;
	decl String:MapName[64];

	//Initialize:
	GetCurrentMap(MapName, 64);
	//Teamplay = GetConVarInt(FindConVar("mp_teamplay"));

	//OMGCity
	if(StrEqual(DesiredMap, MapName))
	{

		//Remove:
		//RemoveEdict(189);
		//RemoveEdict(163);
		//RemoveEdict(1246);
		//RemoveEdict(185);
		//RemoveEdict(177);
		//RemoveEdict(174);
	}

	//Check:
	//if(!StrEqual(DesiredMap, MapName) || Teamplay == 0)
	if(!StrEqual(DesiredMap, MapName))
	{

		//Print:
		//if(Teamplay == 0) PrintToConsole(0, "[RP] Restarting map to enable teamplay");
		if(!StrEqual(DesiredMap, MapName)) PrintToConsole(0, "[RP] Changing map to %s", DesiredMap);

		//Change:
		//ServerCommand("mp_teamplay 1");
		ServerCommand("sm_map %s", DesiredMap);
	}
}

/*
 * Set's a clients speed
 * @param Client Player to use
 * @param Speed Speed to use
 */
stock SetSpeed(Client, Float:Speed)
{

	//Declare:
	decl SpeedOffset;
	
	//Initialize:
	SpeedOffset = FindSendPropOffs(OFFSET_PLAYER, "m_flMaxspeed");

	//Set Speed:
	if(SpeedOffset > 0) SetEntData(Client, SpeedOffset, Speed, 4, true);
}

/*
 * Print's the robbery abortion message
 * @param Client Player's name to use
 */
stock PrintRobberyAbort(Client)
{

	//Declare:
	decl MaxPlayers;

	//Initialize:
	MaxPlayers = GetMaxClients();

	//Loop:
	for(new Y = 1; Y < MaxPlayers; Y++)
	{

		//Connected:
		if(IsClientConnected(Y) && IsClientInGame(Y))
		{

			//Declare:
			decl String:PlayerName[32];

			//Initialize:
			GetClientName(Client, PlayerName, 32);

			//Print:
			SetHudTextParams(-1.0, 0.015, 10.0, 255, 255, 255, 255, 0, 6.0, 0.1, 0.2);
			ShowHudText(Y, -1, "\n\nATTENTION: %s is getting away!", PlayerName);
		}
	}
}

/*
 * Saves an integer
 * @param Vault Handle to the text file
 * @param Key The keyvalue name to use
 * @param SteamId The authid of the client
 * @param Variable Integer to store
 */
stock SaveInteger(Handle:Vault, const String:Key[32], const String:SaveKey[255], Variable)
{

	//Delete:
	if(Variable <= 0)
	{

		//Jump:
		KvJumpToKey(Vault, Key, false);

		//Delete:
		KvDeleteKey(Vault, SaveKey);

		//Rewind:
		KvRewind(Vault);
	}
	else
	{

		//Jump:
		KvJumpToKey(Vault, Key, true);

		//Save:
		KvSetNum(Vault, SaveKey, Variable);
	
		//Rewind:
		KvRewind(Vault);
	}
}

/*
 * Saves a string
 * @param Vault Handle to the text file
 * @param Key The keyvalue name to use
 * @param SteamId The authid of the client
 * @param Variable String to store
 */
stock SaveString(Handle:Vault, const String:Key[32], const String:SaveKey[255], const String:Variable[255])
{

	//Jump:
	KvJumpToKey(Vault, Key, true);

	//Save:
	KvSetString(Vault, SaveKey, Variable);

	//Rewind:
	KvRewind(Vault);
}

/*
 * Loads an integer
 * @param Vault Handle to the text file
 * @param Key The keyvalue name to use
 * @param SteamId The authid of the client
 * @param DefaultValue Integer to return if key not found
 */
stock LoadInteger(Handle:Vault, const String:Key[32], const String:SaveKey[255], DefaultValue)
{

	//Declare:
	decl Variable;

	//Jump:
	KvJumpToKey(Vault, Key, false);

	//Money:
	Variable = KvGetNum(Vault, SaveKey, DefaultValue);

	//Rewind:
	KvRewind(Vault);

	//Return:
	return Variable;
}

stock LoadInteger2(Handle:Vault, const String:Key[255], const String:SaveKey[255], DefaultValue)
{

	//Declare:
	decl Variable;

	//Jump:
	KvJumpToKey(Vault, Key, false);

	//Money:
	Variable = KvGetNum(Vault, SaveKey, DefaultValue);

	//Rewind:
	KvRewind(Vault);

	//Return:
	return Variable;
}

/*
 * Loads a string
 * @param Vault Handle to the text file
 * @param Key The keyvalue name to use
 * @param SteamId The authid of the client
 * @param DefaultValue String to return if key not found
 * @param Reference String to return through reference
 */
stock LoadString(Handle:Vault, const String:Key[32], const String:SaveKey[255], const String:DefaultValue[255], String:Reference[255])
{

	//Jump:
	KvJumpToKey(Vault, Key, false);
	
	//Load:
	KvGetString(Vault, SaveKey, Reference, 255, DefaultValue);

	//Rewind:
	KvRewind(Vault);
}

stock LoadString2(Handle:Vault, const String:Key[255], const String:SaveKey[255], const String:DefaultValue[255], String:Reference[255])
{

	//Jump:
	KvJumpToKey(Vault, Key, false);
	
	//Load:
	KvGetString(Vault, SaveKey, Reference, 255, DefaultValue);

	//Rewind:
	KvRewind(Vault);
}

stock LoadString3(Handle:Vault, const String:Key[255], const String:SaveKey[255], const String:DefaultValue[255], String:Reference[1000])
{

	//Jump:
	KvJumpToKey(Vault, Key, false);
	
	//Load:
	KvGetString(Vault, SaveKey, Reference, 255, DefaultValue);

	//Rewind:
	KvRewind(Vault);
}

/*
 * Prints NPC info
 * @param Client Player to print to
 * @param Vault Keyvalue handle to use
 * @param Header Header to use
 * @param Key Subkey to find inside the vault
 * @param MaxNPCs Maximum number of NPCs
 */
stock PrintNPC(Client, Handle:Vault, const String:Header[255], const String:Key[32], MaxNPCs)
{

	//Declare:
	decl String:NPCId[255], String:Props[255];

	//Print:
	PrintToConsole(Client, Header);
	for(new X = 0; X < MaxNPCs; X++)
	{

		//Convert:
		IntToString(X, NPCId, 255);
	
		//Load:
		LoadString(Vault, Key, NPCId, "Null", Props);

		//Found in DB:
		if(StrContains(Props, "Null", false) == -1) PrintToConsole(Client, "--%s: %s", NPCId, Props);	
	}
}

/*
 * Prints job info
 * @param Client Player to print to
 * @param Vault Keyvalue handle to use
 * @param Header Header to use
 * @param Key Subkey to find inside the vault
 * @param MaxNPCs Maximum number of Jobs
 */
stock PrintJob(Client, Handle:Vault, const String:Header[255], const String:Key[32], MaxJobs)
{

	//Declare:
	decl String:JobId[255], String:JobTitle[255];

	//Print:
	PrintToConsole(Client, Header);
	for(new X = 0; X < MaxJobs; X++)
	{

		//Convert:
		IntToString(X, JobId, 255);
	
		//Load:
		LoadString(Vault, Key, JobId, "Null", JobTitle);

		//Found in DB:
		if(StrContains(JobTitle, "Null", false) == -1) PrintToConsole(Client, "--%s: %s", JobId, JobTitle);	
	}
}

/*
 * Message used to prevent spam
 * @param Client Player to print to
 * @param Conents Message to print
 */
stock OverflowMessage(Client, const String:Contents[255])
{

	//Anti-Spam:
	if(GameTime[Client] <= (GetGameTime() - 10))
	{

		//Print:
		PrintToChat(Client, Contents);

		//Save:
		GameTime[Client] = GetGameTime();
	}
}

stock bool:PrintKeyHintText(Client, const String:format[], any:...)
{
	new Handle:userMessage = StartMessageOne("KeyHintText", Client);
	
	if (userMessage == INVALID_HANDLE) {
		return false;
	}

	decl String:buffer[254];

	SetGlobalTransTarget(Client);
	VFormat(buffer, sizeof(buffer), format, 3);

	BfWriteByte(userMessage, 1); 
	BfWriteString(userMessage, buffer); 

	EndMessage();
	
	return true;
}

stock GetReserveAmmo(client)
{
    new weapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
    if(weapon < 1) return -1;
    
    new ammotype = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
    if(ammotype == -1) return -1;
    
    return GetEntProp(client, Prop_Send, "m_iAmmo", _, ammotype);
}

stock SetReserveAmmo(client, ammo)
{
    new weapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
    if(weapon < 1) return;
    
    new ammotype = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
    if(ammotype == -1) return;
    
    SetEntProp(client, Prop_Send, "m_iAmmo", ammo, _, ammotype);
} 

stock EasPrintSilentChat(Client, String:ClientName[32], Player, String:Arg[255])
{
	CPrintToChat(Client, "{green}(PM) %s : %s", ClientName, Arg);
	CPrintToChat(Player, "{green}(PM) %s : %s", ClientName, Arg);
}
