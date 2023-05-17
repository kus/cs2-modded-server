public RoleplayPrefSelected(Client, CookieMenuAction:action, any:info, String:buffer[], maxlen)
{
	if(action == CookieMenuAction_SelectOption)
	{
		ShowRoleplayMenu(Client);
	}
}
ShowRoleplayMenu(Client)
{
	new Handle:RoleplayMenuHandle = CreateMenu(RoleplayMenu);
	SetMenuTitle(RoleplayMenuHandle, "Roleplay Settings: \nShow/Hide from Region: \nToggles your name from being \nshown to near players. \nEnable/Disable Phone: \nToggles ability to receive calls. \nDuring a call, only friends \non Phone will hear your Microphone. \nSame on Team Chat. \nGlobal/Region Voice: \nCan all hear Microphone \nor only near players? \nNote: Team Chat is only sent \nto near players if you \naren't on Phone. \n© 2014 AdRiAnIlloO");
	if(hideRegion[Client] == 1) AddMenuItem(RoleplayMenuHandle, "regionshow", "Show in Region");
	else AddMenuItem(RoleplayMenuHandle, "regionhide", "Hide from Region");
	if(phoneStatus[Client] == 0) AddMenuItem(RoleplayMenuHandle, "enablephone", "Enable Phone");
	else AddMenuItem(RoleplayMenuHandle, "disablephone", "Disable Phone");
	if(regionVoiceTalk[Client] == 1) AddMenuItem(RoleplayMenuHandle, "globaltalk", "Global Voice");
	else AddMenuItem(RoleplayMenuHandle, "regiontalk", "Region Voice Only");
	SetMenuExitButton(RoleplayMenuHandle, true);
	DisplayMenu(RoleplayMenuHandle, Client, 20);
}
public RoleplayMenu(Handle:RoleplayMenuHandle, MenuAction:action, Client, param2)
{
	if(action == MenuAction_Select)
	{
		new String:info[255];
		GetMenuItem(RoleplayMenuHandle, param2, info, sizeof(info));
		if(StrEqual(info, "regionshow")) hideRegion[Client] = 0;
		else if (StrEqual(info, "regionhide")) hideRegion[Client] = 1;
		else if(StrEqual(info, "enablephone")) phoneStatus[Client] = 1;
		else if(StrEqual(info, "disablephone")) phoneStatus[Client] = 0;
		else if(StrEqual(info, "globaltalk")) regionVoiceTalk[Client] = 0;
		else if(StrEqual(info, "regiontalk")) regionVoiceTalk[Client] = 1;
		decl String:buffer[5], String:buffer2[5], String:buffer3[5];
		IntToString(hideRegion[Client], buffer, 5);
		IntToString(phoneStatus[Client], buffer2, 5);
		IntToString(regionVoiceTalk[Client], buffer3, 5);
		SetClientCookie(Client, cookieHideRegion, buffer);
		SetClientCookie(Client, cookiePhoneStatus, buffer2);
		SetClientCookie(Client, cookieRegionVoiceTalk, buffer3);
		ShowRoleplayMenu(Client);
	}
	else if(action == MenuAction_End) CloseHandle(RoleplayMenuHandle);
}
loadClientCookiesFor(Client)
{
	decl String:buffer[5], String:buffer2[5], String:buffer3[5];
	GetClientCookie(Client, cookieHideRegion, buffer, 5);
	GetClientCookie(Client, cookiePhoneStatus, buffer2, 5);
	GetClientCookie(Client, cookieRegionVoiceTalk, buffer3, 5);
	if(!StrEqual(buffer, "")) hideRegion[Client] = StringToInt(buffer);
	if(!StrEqual(buffer2, "")) phoneStatus[Client] = StringToInt(buffer2);
	if(!StrEqual(buffer3, "")) regionVoiceTalk[Client] = StringToInt(buffer3);
}
public OnClientCookiesCached(Client)
{
	if(IsClientInGame(Client) && !IsFakeClient(Client)) loadClientCookiesFor(Client);	
}
public Action:DisplayHud(Handle:Timer, any:Client)
{
	if(IsClientInGame(Client))
	{
		if(!IsPlayerAlive(Client))
		{	
			//Retry:
			CreateTimer(HUDTICK, DisplayHud, Client);
			return Plugin_Handled;
		}
		new String:HUDPhones[MAXPLAYERS+1][255], String:Regions[MAXPLAYERS+1][255], String:Jump[2][16];
		decl Float:ClientOrigin[3], Float:NearPlayerOrigin[3], Float:Dist;
		new NearPeopleCount[MAXPLAYERS+1];

		decl XHP;
		GetClientAbsOrigin(Client, ClientOrigin);

		for(new X = 1; X <= MaxClients; X++)
		{
			if(IsClientInGame(X))
			{
				GetClientAbsOrigin(X, NearPlayerOrigin);
				Dist = GetVectorDistance(ClientOrigin, NearPlayerOrigin);
				XHP = GetClientHealth(X);
				
				if(PhonePeopleCount[Client] > 0 && !Answered[Client][X]) SetListenOverride(X, Client, Listen_No);
				else if(Answered[Client][X])
				{
					SetListenOverride(X, Client, Listen_Yes);
					Format(HUDPhones[Client], 255, "%dHP - %N\n%s", XHP, X, HUDPhones[Client]);
					Format(Jump[0], sizeof(Jump[]), "\n%s", Jump[0]); 
				}
				else if(Dist <= 500.0 && Client != X)
				{
					SetListenOverride(X, Client, Listen_Yes);
					if(hideRegion[Client] == 0 && hideRegion[X] == 0)
					{
						NearPeopleCount[Client]++;
						if(NearPeopleCount[Client] < 7)
						{
							Format(Regions[Client], 255, "%N\n%s", X, Regions[Client]);
							Format(Jump[1], sizeof(Jump[]), "\n%s", Jump[1]);
						}
					}
				}
				else if(Client != X && regionVoiceTalk[Client] == 0 && regionVoiceTalk[X] == 0) SetListenOverride(X, Client, Listen_Yes);
				else if(Client != X) SetListenOverride(X, Client, Listen_No);
			}
		}
		if(PhonePeopleCount[Client] > 0)
		{
			//Orange (player list):
			SetHudTextParams(0.82, 1.0, HUDTICK, 255, 100, 0, 255);
			ShowHudText(Client, -1, "%s\n\n", HUDPhones[Client]);
			//Yellow (header):
			SetHudTextParams(0.82, 1.0, HUDTICK, 255, 255, 0, 255);
			ShowHudText(Client, -1, "Phone-VoiceList:\n%s\n\n", Jump[0]);
		}
		if(NearPeopleCount[Client] > 0)
		{
			//Pink-red:
			SetHudTextParams(0.82, 1.0, HUDTICK, 255, 60, 60, 255);
			if(PhonePeopleCount[Client] > 0)
			{
				ShowHudText(Client, -1, "%s\n%s\n\n", Regions[Client], HUDPhones[Client]);
				SetHudTextParams(0.82, 1.0, HUDTICK, 255, 128, 128, 255);
				if(NearPeopleCount[Client] > 6) ShowHudText(Client, -1, "Region-VoiceList (6+):\n%s\n%s\n\n", Jump[1], Jump[0]);
				else ShowHudText(Client, -1, "Region-VoiceList:\n%s\n%s\n\n", Jump[1], Jump[0]);
			}
			else
			{
				ShowHudText(Client, -1, "%s\n\n", Regions[Client]);
				SetHudTextParams(0.82, 1.0, HUDTICK, 255, 128, 128, 255);
				ShowHudText(Client, -1, "Region-VoiceList:\n%s\n\n", Jump[1]);
			}
		}
		CreateTimer(HUDTICK, DisplayHud, Client);	
		return Plugin_Handled;	
	}
	return Plugin_Handled;
}
//Initation:
public OnPluginStart()
{
	

	
}

//Map Start:
public OnMapStart()
{
	GetCurrentMap(MapName, sizeof(MapName));
	if(StrContains(MapName, "rp_ice_icity") != -1 || StrContains(MapName, "rp_cg_gtown") != -1)
	{
		ReplaceString(MapName, sizeof(MapName), "_day", "");
		ReplaceString(MapName, sizeof(MapName), "_night", "");
		ReplaceString(MapName, sizeof(MapName), "_dotv01", "");
	}
	
}

//In-Game:
public OnClientPutInServer(Client)
{
	if(!IsFakeClient(Client) && IsClientConnected(Client))
	{
		hideRegion[Client] = 0;
		phoneStatus[Client] = 1;
		regionVoiceTalk[Client] = 0;
		if (AreClientCookiesCached(Client))
		{
			loadClientCookiesFor(Client);
		}
		//Default:
		PhonePeopleCount[Client] = 0;
		for(new X = 1; X <= MaxClients; X++)
		{
			if(IsClientInGame(X))
			{
				Connected[Client][X] = false;
				Answered[Client][X] = false;
				Connected[X][Client] = false;
				Answered[X][Client] = false;
				TimeOut[Client][X] = 0;
			}
		}
	}
}

//Disconnect:
public OnClientDisconnect(Client)
{
	if(!IsClientInGame(Client)) return false;
	for(new X = 1; X <= MaxClients; X++)
	{
		if(Connected[Client][X])
		{
			if(IsClientInGame(X))
			{
				CPrintToChat(X, "{green}[RP] {deepblue}You have lost phone connection with {green}%N", Client);
				if(Answered[Client][X]) PhonePeopleCount[X]--;
			}
		}
	}
	PhonePeopleCount[Client] = 0;
	return true;
}



public Action:CallMenu(Client)
{
	CPrintToChat(Client, "{green}[RP] {deepblue}Press <escape> to access the phone menu.");

	new Handle:menu = CreateMenu(PhoneMenu);
	SetMenuTitle(menu, "Phone Menu");

	decl String:name[65], String:ID[25];
	for(new i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
			{
				continue;
			}
			GetClientName(i, name, sizeof(name));
			IntToString(i, ID, sizeof(ID));
			AddMenuItem(menu, ID, name);
		}
	SetMenuPagination(menu, 7);
	DisplayMenu(menu, Client, 20);
 
	return Plugin_Handled;

}

public PhoneMenu(Handle:menu, MenuAction:action, Client, param2)
{
	if (action == MenuAction_Select)
	{
		new String:info[64], Player;
		GetMenuItem(menu, param2, info, sizeof(info));
		Player = StringToInt(info);

		if(Player == -1)
		{
			CPrintToChat(Client, "{green}[RP] {deepblue}Could not find client.");
		}
		else if(Player == Client)
		{
			CPrintToChat(Client, "{green}[RP] {deepblue}You cannot call yourself.");
		}
		else if(!IsPlayerAlive(Player))
		{
			CPrintToChat(Client, "{green}[RP] {deepblue}Can't call a dead player.");
		}
		else if(phoneStatus[Player] == 0)
		{
			CPrintToChat(Client, "{green}[RP] {deepblue}This player has phone disabled! Try again later.");
		}
		else
		{
			Call(Client, Player);
		}
	}
}

//Prethink:
public OnGameFrame()
{
	//Loop:
	for(new Client = 1; Client <= MaxClients; Client++)
	{
		//Connected:
		if(IsClientInGame(Client))
		{
			//Alive:
			if(IsPlayerAlive(Client))
			{
				//E Key:
				if(GetClientButtons(Client) & IN_USE)
				{

					//Overflow:
					if(!PrethinkBuffer[Client])
					{
						//Action:
						CommandUse(Client);

						//UnHook:
						PrethinkBuffer[Client] = true;
					}
				}
				else
				{
					PrethinkBuffer[Client] = false;
				}
			}
		}
	}
}

public Action:CommandCall(Client, Args)
{
	decl String:PlayerName[255], String:Name[32];
	new Player = -1;
	GetCmdArg(1, PlayerName, sizeof(PlayerName));
	if(Args < 1)
	{
		CPrintToChat(Client, "{green}[RP] {deepblue}Usage: sm_call <Player>");
		return Plugin_Handled;
	}
	for(new X = 1; X <= MaxClients; X++)
	{
		if(!IsClientConnected(X)) continue;
		GetClientName(X, Name, sizeof(Name));
		if(StrContains(Name, PlayerName, false) != -1) Player = X;
	}
	if(Player == -1)
	{
		CPrintToChat(Client, "{green}[RP] {deepblue}Could not find client.");
	}
	else if(Player == Client)
	{
		CPrintToChat(Client, "{green}[RP] {deepblue}You cannot call yourself.");
	}
	else if(!IsPlayerAlive(Player))
	{
		CPrintToChat(Client, "{green}[RP] {deepblue}Cannot call a dead player.");
	}
	else if(phoneStatus[Player] == 0)
	{
		CPrintToChat(Client, "{green}[RP] {deepblue}This player has phone disabled! Try again later.");
	}
	else
	{
		Call(Client, Player);
	}
	return Plugin_Handled;
}

//Calling:
stock Call(Client, Player)
{
	//World:
	if(Client != 0 && Player != 0)
	{
		//Not Connected:
		if(!Connected[Client][Player] && PhonePeopleCount[Client] < 5)
		{
			Connected[Client][Player] = true;
			CPrintToChat(Client, "{green}[RP] {deepblue}You call {green}%N{deepblue}...", Player);
			ReceiveCall(Player);
			TimeOut[Client][Player] = 40;
			CreateTimer(1.0, TimeOutCall, Client);
		}
		else if(Connected[Client][Player]) CPrintToChat(Client, "{green}[RP] %N {deepblue}is already on the phone.", Player);
		else if(PhonePeopleCount[Client] >= 5) CPrintToChat(Client, "{green}[RP] {deepblue}You can't call more players if 5 are on your phone!");
	}
}

//Receive:
stock ReceiveCall(Client)
{
	//Sound:
	EmitSoundToClient(Client, "roleplay/ring.wav", SOUND_FROM_PLAYER, 5);

	//Print:
	CPrintToChat(Client, "{green}[RP] {deepblue}Your phone is ringing. Type /answer or !answer to receive the call.");

	//Send:
	for(new X = 1; X <= MaxClients; X++) TimeOut[Client][X] = 40;
	CreateTimer(1.0, TimeOutReceive, Client);
}

//Answer:
stock Answer(Client)
{
	for(new X = 1; X <= MaxClients; X++)
	{
		if(IsClientInGame(X))
		{
			if(!Answered[Client][X] && Connected[X][Client] && PhonePeopleCount[Client] < 5)
			{
				CPrintToChat(Client, "{green}[RP] {deepblue}You answer the phone.");
				CPrintToChat(X, "{green}[RP] %N {deepblue}answered his phone.", Client);
				Answered[Client][X] = true;
				Answered[X][Client] = true;
				Connected[Client][X] = true;
				PhonePeopleCount[Client]++;
				PhonePeopleCount[X]++;
				StopSound(Client, 5, "roleplay/ring.wav");
			}
		}
	}
	if(PhonePeopleCount[Client] >= 5) CPrintToChat(Client, "{green}[RP] {deepblue}You already answered the phone to 5 players.");
	else if(phoneStatus[Client] == 0) CPrintToChat(Client, "{green}[RP] {deepblue}Your phone is disabled! Enable it with /settings");
	else if(PhonePeopleCount[Client] < 1) CPrintToChat(Client, "{green}[RP] {deepblue}No one is calling you!");
}

//Hang Up:
stock HangUp(Client)
{
	decl String:PhonePlayers[255];
	for(new X = 1; X <= MaxClients; X++)
	{
		if(IsClientInGame(X))
		{
			if(Connected[Client][X])
			{
				Format(PhonePlayers, 255, "%N, %s", X, PhonePlayers);
				CPrintToChat(X, "{green}[RP] %N {deepblue}hung up on you.", Client);
				Connected[Client][X] = false;
				Answered[Client][X] = false;
				Connected[X][Client] = false;
				Answered[X][Client] = false;
				StopSound(Client, 5, "roleplay/ring.wav");
				PhonePeopleCount[X]--;
			}
		}
	}
	if(PhonePeopleCount[Client] < 1) CPrintToChat(Client, "{green}[RP] {deepblue}You are not on the phone.");
	else CPrintToChat(Client, "{green}[RP] {deepblue}You hang up on {green}%s{deepblue}.", PhonePlayers);
	PhonePeopleCount[Client] = 0;
}

//Time Out (Calling):
public Action:TimeOutCall(Handle:Timer, any:Client)
{
	for(new X = 1; X <= MaxClients; X++)
	{
		if(TimeOut[Client][X] > 0) TimeOut[Client][X] -= 1;
		if(!Connected[Client][X]) TimeOut[Client][X] = 0;
		if(!Answered[Client][X] && TimeOut[Client][X] == 1)
		{
			if(IsClientInGame(X)) CPrintToChat(Client, "{green}[RP] %N {deepblue}didn't answer his phone at time.", X);
			Answered[Client][X] = false;
			Connected[Client][X] = false;
		}
		if(TimeOut[Client][X] > 0)
		{

			CreateTimer(1.0, TimeOutCall, Client);
		}
	}
}

//Time Out (Receive):
public Action:TimeOutReceive(Handle:Timer, any:Client)
{
	for(new X = 1; X <= MaxClients; X++)
	{
		if(TimeOut[Client][X] > 0) TimeOut[Client][X] -= 1;
		if(!Connected[Client][X]) TimeOut[Client][X] = 0;
		if(!Answered[Client][X] && TimeOut[Client][X] == 1)
		{
			CPrintToChat(Client, "{green}[RP] {deepblue}Your phone has stopped ringing.");
			Answered[Client][X] = false;
			Connected[Client][X] = false;
		}
		if(TimeOut[Client][X] > 0)
		{
			CreateTimer(1.0, TimeOutReceive, Client);
		}
	}
}

//Handle Chat:
public Action:CommandSay(Client, Arguments)
{
	//World:
	if(Client == 0) return Plugin_Handled;

	//Declare:
	decl String:Arg[255];

	//Initialize:
	GetCmdArgString(Arg, sizeof(Arg));

	//Clean:
	StripQuotes(Arg);
	TrimString(Arg);
	
	if(StrContains(Arg, "/enablephone") == 0 || StrContains(Arg, "!enablephone") == 0)
	{
		phoneStatus[Client] = 1;
		SetClientCookie(Client, cookiePhoneStatus, "1");
		return Plugin_Handled;
	}
	
	if(StrContains(Arg, "/disablephone") == 0 || StrContains(Arg, "!disablephone") == 0)
	{
		phoneStatus[Client] = 0;
		SetClientCookie(Client, cookiePhoneStatus, "0");
		return Plugin_Handled;
	}
	
	//Answer:
	if(StrContains(Arg, "/answer", false) == 0 || StrContains(Arg, "!answer", false) == 0)
	{
		//Answer:
		Answer(Client);
		return Plugin_Handled;
	}

	//Hangup:
	if(StrContains(Arg, "/hangup", false) == 0 || StrContains(Arg, "!hangup", false) == 0)
	{
		//Call:
		HangUp(Client);
		return Plugin_Handled;
	}

	//Close:
	return Plugin_Handled;
}

public Action:CommandSayTeam(Client, Arguments)
{
	//World:
	if(Client == 0) return Plugin_Handled;

	//Declare:
	decl String:Arg[255];

	//Initialize:
	GetCmdArgString(Arg, sizeof(Arg));

	//Clean:
	StripQuotes(Arg);
	TrimString(Arg);
	
	if(StrContains(Arg, "/disablephone") == 0 || StrContains(Arg, "!disablephone") == 0)
	{
		phoneStatus[Client] = 1;
		SetClientCookie(Client, cookiePhoneStatus, "1");
		return Plugin_Handled;
	}
	
	if(StrContains(Arg, "/enablephone") == 0 || StrContains(Arg, "!enablephone") == 0)
	{
		phoneStatus[Client] = 0;
		SetClientCookie(Client, cookiePhoneStatus, "0");
		return Plugin_Handled;
	}
	
	//Answer:
	if(StrContains(Arg, "/answer", false) == 0 || StrContains(Arg, "!answer", false) == 0)
	{
		Answer(Client);
		return Plugin_Handled;
	}

	//Hangup:
	else if(StrContains(Arg, "/hangup", false) == 0 || StrContains(Arg, "!hangup", false) == 0)
	{
		HangUp(Client);
		return Plugin_Handled;
	}
	
	//To admins or possible command:
	if(StrContains(Arg, "@") == 0 || StrContains(Arg, "/") == 0) return Plugin_Handled;

	//Phone:
	decl Float:Dist, Float:ClientOrigin[3], Float:NearPlayerOrigin[3], String:ClientName[32];
	GetClientName(Client, ClientName, sizeof(ClientName));
	CRemoveTags(ClientName, sizeof(ClientName));
	CRemoveTags(Arg, sizeof(Arg));
	for(new X = 1; X <= MaxClients; X++)
	{
		if(!IsClientInGame(X)) continue;
		if(Answered[Client][X])
		{
			//Print:
			CPrintToChatEx(X, Client, "{yellow}(Phone) {teamcolor}%s {default}: %s", ClientName, Arg);
		}

		//Region:
		else if(PhonePeopleCount[Client] < 1)
		{
			GetClientAbsOrigin(Client, ClientOrigin);
			GetClientAbsOrigin(X, NearPlayerOrigin);	
			Dist = GetVectorDistance(ClientOrigin, NearPlayerOrigin);
			if(Dist <= 500.0)
			{
				CPrintToChatEx(X, Client, "{orange}(Region) {teamcolor}%s {default}: %s", ClientName, Arg);
				if(Client == X) LogAction(Client, X, "(Region) %N : %s", Client, Arg);
			}
		}
	}
	if(PhonePeopleCount[Client] > 0)
	{
		CPrintToChatEx(Client, Client, "{yellow}(Phone) {teamcolor}%s {default}: %s", ClientName, Arg);
		LogAction(Client, Client, "(Phone) %N : %s", Client, Arg);
	}
	return Plugin_Handled;
}