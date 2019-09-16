#include <sourcemod>
#include <sdktools>

#define SHIELD_COST 2200
#define EXO_COST 3000
#define MINE_COST 1000

#define OPTION_NAME_LENGTH 128

public Plugin:myinfo =
{
	name = "Buy Danger Zone Items",
	author = "Kus",
	description = "Allows players to buy items from Danger Zone by typing !buydz",
	version = "0.1",
	url = "http://www.steamcommunity.com/id/kus"
}

new bool:RequireBuyZone = true;
new bool:Enabled = true;
Handle BuyStartRoundTimer;

public OnPluginStart()
{
	RegAdminCmd("sm_dz_items", Command_Enable, ADMFLAG_BAN);
	RegConsoleCmd("sm_buydz", Command_Menu);
	RegConsoleCmd("sm_buyshield", Command_Buy_Shield);
	RegConsoleCmd("sm_buyexo", Command_Buy_Exo);
	RegConsoleCmd("sm_buymine", Command_Buy_Mine);
	HookEvent("round_prestart", Event_RoundPreStart);
}

public Action Command_Enable(int client, int args) 
{
	if(args < 1) // Not enough parameters
	{
		ReplyToCommand(client, "[SM] Use: sm_dz_items <0-1>");
		return Plugin_Handled;
	}

	char strEnable[32]; GetCmdArg(1, strEnable, sizeof(strEnable)); 
	
	int enable = StringToInt(strEnable);
	
	if(enable > 1 || enable < 0)
	{
		ReplyToCommand(client, "[SM] Use: sm_dz_items <0-1>");
	}
	else if (enable == 1)
	{
		Enabled = true;
		ReplyToCommand(client, "[SM]: sm_dz_items enabled");
	}
	else if (enable == 0)
	{
		Enabled = false;
		ReplyToCommand(client, "[SM]: sm_dz_items disabled");
	}

	return Plugin_Handled;
}

public Action Command_Buy_Shield(int client, int args) 
{
	if(!Enabled) {
		return Plugin_Handled;
	}
	if(RequireBuyZone)
	{
		new bool:InBuyZone = view_as<bool>(GetEntProp(client, Prop_Send, "m_bInBuyZone"));
		if(!InBuyZone)
		{
			PrintToChat(client, "Sorry you're not in a Buy Zone.");
			return Plugin_Handled;
		}
		if (BuyStartRoundTimer == null)
		{
			PrintToChat(client, "The buy time has expired for this round.")
			return Plugin_Handled;
		}
	}
	
	new account = GetEntProp(client, Prop_Send, "m_iAccount");
	if(account < SHIELD_COST)
	{
		PrintToChat(client, "Sorry you don't have $%d to buy the shield.", SHIELD_COST);
		return Plugin_Handled;
	}
	
	new weaponIdx = GetPlayerWeaponSlot(client, 11);
	if(weaponIdx != -1)
	{
		if(IsValidEdict(weaponIdx) && IsValidEntity(weaponIdx))
		{
			decl String:className[128];
			GetEntityClassname(weaponIdx, className, sizeof(className));
			
			if(StrEqual("weapon_shield", className))
			{
				PrintToChat(client, "You are already carrying a shield.");
				return Plugin_Handled;
			}
		}
	}
	
	SetEntProp(client, Prop_Send, "m_iAccount", account - SHIELD_COST);
	GivePlayerItem(client, "weapon_shield");
	PrintToChat(client, "You've bought a shield.");
	
	return Plugin_Handled;
}

bool GetClientExojump(int client)
{
	return view_as<bool>(GetEntProp(client, Prop_Send, "m_passiveItems", 1, 1));
}

bool SetClientExojump(int client, bool status)
{
	SetEntProp(client, Prop_Send, "m_passiveItems", status, 1, 1);
	return GetClientExojump(client);
}

public Action Command_Buy_Exo(int client, int args) 
{
	if(!Enabled) {
		return Plugin_Handled;
	}
	if(RequireBuyZone)
	{
		new bool:InBuyZone = view_as<bool>(GetEntProp(client, Prop_Send, "m_bInBuyZone"));
		if(!InBuyZone)
		{
			PrintToChat(client, "Sorry you're not in a Buy Zone.");
			return Plugin_Handled;
		}
		if (BuyStartRoundTimer == null)
		{
			PrintToChat(client, "The buy time has expired for this round.")
			return Plugin_Handled;
		}
	}

	if (GetClientExojump(client))
	{
		PrintToChat(client, "You are already carrying exo boots.");
		return Plugin_Handled;
	}
	
	new account = GetEntProp(client, Prop_Send, "m_iAccount");
	if(account < EXO_COST)
	{
		PrintToChat(client, "Sorry you don't have $%d to buy the exo boots.", EXO_COST);
		return Plugin_Handled;
	}
	
	SetEntProp(client, Prop_Send, "m_iAccount", account - EXO_COST);
	SetClientExojump(client, true);
	PrintToChat(client, "You've bought exo boots.");
	
	return Plugin_Handled;
}

public Action Command_Buy_Mine(int client, int args) 
{
	if(!Enabled) {
		return Plugin_Handled;
	}
	if(RequireBuyZone)
	{
		new bool:InBuyZone = view_as<bool>(GetEntProp(client, Prop_Send, "m_bInBuyZone"));
		if(!InBuyZone)
		{
			PrintToChat(client, "Sorry you're not in a Buy Zone.");
			return Plugin_Handled;
		}
		if (BuyStartRoundTimer == null)
		{
			PrintToChat(client, "The buy time has expired for this round.")
			return Plugin_Handled;
		}
	}
	
	new account = GetEntProp(client, Prop_Send, "m_iAccount");
	if(account < MINE_COST)
	{
		PrintToChat(client, "Sorry you don't have $%d to buy a mine.", MINE_COST);
		return Plugin_Handled;
	}
	
	new weaponIdx = GetPlayerWeaponSlot(client, 11);
	if(weaponIdx != -1)
	{
		if(IsValidEdict(weaponIdx) && IsValidEntity(weaponIdx))
		{
			decl String:className[128];
			GetEntityClassname(weaponIdx, className, sizeof(className));
			
			if(StrEqual("weapon_bumpmine", className))
			{
				PrintToChat(client, "You are already carrying a mine.");
				return Plugin_Handled;
			}
		}
	}
	
	SetEntProp(client, Prop_Send, "m_iAccount", account - MINE_COST);
	GivePlayerItem(client, "weapon_bumpmine");
	PrintToChat(client, "You've bought a mine.");
	
	return Plugin_Handled;
}

public Event_RoundPreStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	new Float:BuyTime = 45.0;
	ConVar cvarBuyTime = FindConVar("mp_buytime");
	
	if(cvarBuyTime != null)
		BuyTime = float(cvarBuyTime.IntValue);
		
	if (BuyStartRoundTimer != null)
	{
		KillTimer(BuyStartRoundTimer);
		BuyStartRoundTimer = null;
	}
	
	BuyStartRoundTimer = CreateTimer(BuyTime, StopBuying);
}


public Action StopBuying(Handle timer, any client)
{
	BuyStartRoundTimer = null;
	
	return Plugin_Stop;
}

public Action Command_Menu(int client, int args)
{
	if(!Enabled) {
		return Plugin_Handled;
	}
	Menu menu = new Menu(MenuHandler);
	menu.SetTitle(" Danger Zone Items");

	menu.AddItem("shield", "Ballistic Shield");
	menu.AddItem("exo", "ExoJump Boots");
	menu.AddItem("mine", "Bump Mines");

	menu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public int MenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		int client = param1;
		char buffer[OPTION_NAME_LENGTH];
		menu.GetItem(param2, buffer, sizeof(buffer));

		if (StrEqual(buffer, "shield"))
		{
			Command_Buy_Shield(client, 0);
		}
		else if (StrEqual(buffer, "exo"))
		{
			Command_Buy_Exo(client, 0);
		}
		else if (StrEqual(buffer, "mine"))
		{
			Command_Buy_Mine(client, 0);
		}

		Command_Menu(client, 0);
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}

	return 0;
}
