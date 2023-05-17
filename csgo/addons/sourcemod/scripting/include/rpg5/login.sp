/*		If a player is connected to the server, pull their database information.	*/

public OnClientPostAdminCheck(client)
{
	// After we clear data, we try to load their data. We clear in case they join
	// and take over someone elses playerID.
	if (!IsHuman(client)) return;
	ClearData(client);
}

public Action:SavePlayerData(Handle:timer, any:client)
{
	if (!IsHuman(client)) return Plugin_Stop;
	if (PhysicalLevel[client] > 0 && PhysicalNextLevel[client] > 0 && 
		InfectedLevel[client] > 0 && InfectedNextLevel[client] > 0)
	{
		SaveData(client);
	}
	return Plugin_Stop;
}

/*		If a player is human, when they disconnect from the server, save their data.	*/
/*		BUT only save their data if their levels are > 0 (i.e. if they've loaded data)	*/

public OnClientDisconnect(client)
{
	if (IsClientInGame(client))
	{
		if (IsPlayerAlive(client) && GetClientTeam(client) == 3 && ClassTank[client]) TankCount--;
		decl String:clientName[256];
		GetClientName(client, clientName, sizeof(clientName));
		if (StrContains(clientName, "`", false) > -1 || StrContains(clientName, "'", false) > -1) return;
		if (PhysicalLevel[client] > 0 && PhysicalNextLevel[client] > 0 && 
			InfectedLevel[client] > 0 && InfectedNextLevel[client] > 0)
		{
			SaveData(client);
		}
	}
}

/*		Clear player data, and then attempt to load correct data.		*/
ClearData(client)
{
	Ensnared[client] = false;
	LocationSaved[client] = false;
	showpoints[client] = true;
	PistolExperience[client] = 0;
	PistolLevel[client] = 0;
	PistolNextLevel[client] = 0;
	MeleeExperience[client] = 0;
	MeleeLevel[client] = 0;
	MeleeNextLevel[client] = 0;
	UziExperience[client] = 0;
	UziLevel[client] = 0;
	UziNextLevel[client] = 0;
	ShotgunExperience[client] = 0;
	ShotgunLevel[client] = 0;
	ShotgunNextLevel[client] = 0;
	SniperExperience[client] = 0;
	SniperLevel[client] = 0;
	SniperNextLevel[client] = 0;
	RifleExperience[client] = 0;
	RifleLevel[client] = 0;
	RifleNextLevel[client] = 0;
	GrenadeExperience[client] = 0;
	GrenadeLevel[client] = 0;
	GrenadeNextLevel[client] = 0;
	ItemExperience[client] = 0;
	ItemLevel[client] = 0;
	ItemNextLevel[client] = 0;
	PhysicalExperience[client] = 0;
	PhysicalLevel[client] = 0;
	PhysicalNextLevel[client] = 0;

	// Infected XP Levels
	HunterExperience[client] = 0;
	HunterLevel[client] = 0;
	HunterNextLevel[client] = 0;
	SmokerExperience[client] = 0;
	SmokerLevel[client] = 0;
	SmokerNextLevel[client] = 0;
	BoomerExperience[client] = 0;
	BoomerLevel[client] = 0;
	BoomerNextLevel[client] = 0;
	JockeyExperience[client] = 0;
	JockeyLevel[client] = 0;
	JockeyNextLevel[client] = 0;
	ChargerExperience[client] = 0;
	ChargerLevel[client] = 0;
	ChargerNextLevel[client] = 0;
	SpitterExperience[client] = 0;
	SpitterLevel[client] = 0;
	SpitterNextLevel[client] = 0;
	TankExperience[client] = 0;
	TankLevel[client] = 0;
	TankNextLevel[client] = 0;
	InfectedExperience[client] = 0;
	InfectedLevel[client] = 0;
	InfectedNextLevel[client] = 0;

	// Set the Preset strings to none
	PrimaryPreset1[client] = "none";
	SecondaryPreset1[client] = "none";
	Option1Preset1[client] = "none";
	Option2Preset1[client] = "none";

	PrimaryPreset2[client] = "none";
	SecondaryPreset2[client] = "none";
	Option1Preset2[client] = "none";
	Option2Preset2[client] = "none";

	PrimaryPreset3[client] = "none";
	SecondaryPreset3[client] = "none";
	Option1Preset3[client] = "none";
	Option2Preset3[client] = "none";

	SkyPoints[client] = 0;
	XPMultiplierTime[client] = 0;
	
	/*	Try to Load Their Data	*/
	decl String:clientName[256];
	GetClientName(client, clientName, sizeof(clientName));
	if (StrContains(clientName, "`", false) > -1 || StrContains(clientName, "'", false) > -1) return;
	LoadData(client);
}