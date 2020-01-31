/*  SM Buy Danger Zone Items
 *
 *  Copyright (C) 2019 Kus
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */

#include <sourcemod>
#include <sdktools>

#define OPTION_NAME_LENGTH 128

public Plugin:myinfo = {
	name = "Buy Danger Zone Items",
	author = "Kus",
	description = "Allows players to buy items from Danger Zone by typing !buydz",
	version = "0.2",
	url = "http://www.steamcommunity.com/id/kus"
}

Handle BuyStartRoundTimer;
bool RequireBuyZone = true;
bool ShieldEnabled = true;
int ShieldCost = 2200;
bool ExoJumpEnabled = true;
int ExoJumpCost = 3000;
bool MinesEnabled = true;
int MinesCost = 1800;
bool MediShotEnabled = true;
int MediShotCost = 2000;
bool BreachChargeEnabled = true;
int BreachChargeCost = 3000;

public OnPluginStart() {
	RegAdminCmd("sm_danger_zone_items", Command_Admin_Help, ADMFLAG_BAN);
	RegAdminCmd("sm_danger_zone_items_buy_zone", Command_Admin_Buy_Zone, ADMFLAG_BAN);
	RegAdminCmd("sm_danger_zone_items_enabled", Command_Admin_Enabled, ADMFLAG_BAN);
	RegAdminCmd("sm_danger_zone_items_shield_cost", Command_Admin_Shield_Cost, ADMFLAG_BAN);
	RegAdminCmd("sm_danger_zone_items_shield_enabled", Command_Admin_Shield_Enabled, ADMFLAG_BAN);
	RegAdminCmd("sm_danger_zone_items_exojump_cost", Command_Admin_ExoJump_Cost, ADMFLAG_BAN);
	RegAdminCmd("sm_danger_zone_items_exojump_enabled", Command_Admin_ExoJump_Enabled, ADMFLAG_BAN);
	RegAdminCmd("sm_danger_zone_items_mines_cost", Command_Admin_Mines_Cost, ADMFLAG_BAN);
	RegAdminCmd("sm_danger_zone_items_mines_enabled", Command_Admin_Mines_Enabled, ADMFLAG_BAN);
	RegAdminCmd("sm_danger_zone_items_medishot_cost", Command_Admin_MediShot_Cost, ADMFLAG_BAN);
	RegAdminCmd("sm_danger_zone_items_medishot_enabled", Command_Admin_MediShot_Enabled, ADMFLAG_BAN);
	RegAdminCmd("sm_danger_zone_items_breachcharge_cost", Command_Admin_BreachCharge_Cost, ADMFLAG_BAN);
	RegAdminCmd("sm_danger_zone_items_breachcharge_enabled", Command_Admin_BreachCharge_Enabled, ADMFLAG_BAN);
	RegConsoleCmd("sm_buydz", Command_Menu);
	RegConsoleCmd("sm_buyshield", Command_Buy_Shield);
	RegConsoleCmd("sm_buyexojump", Command_Buy_ExoJump);
	RegConsoleCmd("sm_buymines", Command_Buy_Mines);
	RegConsoleCmd("sm_buymedishot", Command_Buy_MediShot);
	RegConsoleCmd("sm_buybreachcharge", Command_Buy_BreachCharge);
	HookEvent("round_prestart", Event_RoundPreStart);
}

public Action Command_Admin_Help(int client, int args) {
	ReplyToCommand(client, "[SM] Availble commands:\nsm_buydz\nsm_danger_zone_items_buy_zone <0-1>\nsm_danger_zone_items_enabled <0-1>\nsm_danger_zone_items_shield_cost <0-16000>\nsm_danger_zone_items_shield_enabled <0-1>\nsm_danger_zone_items_exojump_cost <0-16000>\nsm_danger_zone_items_exojump_enabled <0-1>\nsm_danger_zone_items_mines_cost <0-16000>\nsm_danger_zone_items_mines_enabled <0-1>\nsm_danger_zone_items_medishot_cost <0-16000>\nsm_danger_zone_items_medishot_enabled <0-1>\nsm_danger_zone_items_breachcharge_cost <0-16000>\nsm_danger_zone_items_breachcharge_enabled <0-1>");
	return Plugin_Handled;
}

public Action Command_Admin_Buy_Zone(int client, int args) {
	if (args < 1) {
		ReplyToCommand(client, "\"sm_danger_zone_items_buy_zone\" = \"%d\"", RequireBuyZone == true ? 1 : 0);
		return Plugin_Handled;
	}
	char strEnable[32];
	GetCmdArg(1, strEnable, sizeof(strEnable)); 
	int enable = StringToInt(strEnable);
	if (enable > 1 || enable < 0) {
		ReplyToCommand(client, "[SM] Use: sm_danger_zone_items_buy_zone <0-1>");
	} else if (enable == 1) {
		RequireBuyZone = true;
	} else if (enable == 0) {
		RequireBuyZone = false;
	}
	return Plugin_Handled;
}

public Action Command_Admin_Enabled(int client, int args) {
	if (args < 1) {
		ReplyToCommand(client, "[SM] Use: sm_danger_zone_items_enabled <0-1>");
		return Plugin_Handled;
	}
	char strEnable[32];
	GetCmdArg(1, strEnable, sizeof(strEnable)); 
	int enable = StringToInt(strEnable);
	if (enable > 1 || enable < 0) {
		ReplyToCommand(client, "[SM] Use: sm_danger_zone_items_enabled <0-1>");
	} else if (enable == 1) {
		ShieldEnabled = true;
		ExoJumpEnabled = true;
		MinesEnabled = true;
		MediShotEnabled = true;
		BreachChargeEnabled = true;
	} else if (enable == 0) {
		ShieldEnabled = false;
		ExoJumpEnabled = false;
		MinesEnabled = false;
		MediShotEnabled = false;
		BreachChargeEnabled = false;
	}
	return Plugin_Handled;
}

public Action Command_Admin_Shield_Cost(int client, int args) {
	if (args < 1) {
		ReplyToCommand(client, "\"sm_danger_zone_items_shield_cost\" = \"%d\"", ShieldCost);
		return Plugin_Handled;
	}
	char strCost[32];
	GetCmdArg(1, strCost, sizeof(strCost)); 
	int cost = StringToInt(strCost);
	if (cost > 16000 || cost < 0) {
		ReplyToCommand(client, "[SM] Use: sm_danger_zone_items_shield_cost <0-16000>");
	} else {
		ShieldCost = cost;
	}
	return Plugin_Handled;
}

public Action Command_Admin_Shield_Enabled(int client, int args) {
	if (args < 1) {
		ReplyToCommand(client, "\"sm_danger_zone_items_shield_enabled\" = \"%d\"", ShieldEnabled == true ? 1 : 0);
		return Plugin_Handled;
	}
	char strEnable[32];
	GetCmdArg(1, strEnable, sizeof(strEnable)); 
	int enable = StringToInt(strEnable);
	if (enable > 1 || enable < 0) {
		ReplyToCommand(client, "[SM] Use: sm_danger_zone_items_shield_enabled <0-1>");
	} else if (enable == 1) {
		ShieldEnabled = true;
	} else if (enable == 0) {
		ShieldEnabled = false;
	}
	return Plugin_Handled;
}

public Action Command_Admin_ExoJump_Cost(int client, int args) {
	if (args < 1) {
		ReplyToCommand(client, "\"sm_danger_zone_items_exojump_cost\" = \"%d\"", ExoJumpCost);
		return Plugin_Handled;
	}
	char strCost[32];
	GetCmdArg(1, strCost, sizeof(strCost)); 
	int cost = StringToInt(strCost);
	if (cost > 16000 || cost < 0) {
		ReplyToCommand(client, "[SM] Use: sm_danger_zone_items_exojump_cost <0-16000>");
	} else {
		ExoJumpCost = cost;
	}
	return Plugin_Handled;
}

public Action Command_Admin_ExoJump_Enabled(int client, int args) {
	if (args < 1) {
		ReplyToCommand(client, "\"sm_danger_zone_items_exojump_enabled\" = \"%d\"", ExoJumpEnabled == true ? 1 : 0);
		return Plugin_Handled;
	}
	char strEnable[32];
	GetCmdArg(1, strEnable, sizeof(strEnable)); 
	int enable = StringToInt(strEnable);
	if (enable > 1 || enable < 0) {
		ReplyToCommand(client, "[SM] Use: sm_danger_zone_items_exojump_enabled <0-1>");
	} else if (enable == 1) {
		ExoJumpEnabled = true;
	} else if (enable == 0) {
		ExoJumpEnabled = false;
	}
	return Plugin_Handled;
}

public Action Command_Admin_Mines_Cost(int client, int args) {
	if (args < 1) {
		ReplyToCommand(client, "\"sm_danger_zone_items_mines_cost\" = \"%d\"", MinesCost);
		return Plugin_Handled;
	}
	char strCost[32];
	GetCmdArg(1, strCost, sizeof(strCost)); 
	int cost = StringToInt(strCost);
	if (cost > 16000 || cost < 0) {
		ReplyToCommand(client, "[SM] Use: sm_danger_zone_items_mines_cost <0-16000>");
	} else {
		MinesCost = cost;
	}
	return Plugin_Handled;
}

public Action Command_Admin_Mines_Enabled(int client, int args) {
	if (args < 1) {
		ReplyToCommand(client, "\"sm_danger_zone_items_mines_enabled\" = \"%d\"", MinesEnabled == true ? 1 : 0);
		return Plugin_Handled;
	}
	char strEnable[32];
	GetCmdArg(1, strEnable, sizeof(strEnable)); 
	int enable = StringToInt(strEnable);
	if (enable > 1 || enable < 0) {
		ReplyToCommand(client, "[SM] Use: sm_danger_zone_items_mines_enabled <0-1>");
	} else if (enable == 1) {
		MinesEnabled = true;
	} else if (enable == 0) {
		MinesEnabled = false;
	}
	return Plugin_Handled;
}

public Action Command_Admin_MediShot_Cost(int client, int args) {
	if (args < 1) {
		ReplyToCommand(client, "\"sm_danger_zone_items_medishot_cost\" = \"%d\"", MediShotCost);
		return Plugin_Handled;
	}
	char strCost[32];
	GetCmdArg(1, strCost, sizeof(strCost)); 
	int cost = StringToInt(strCost);
	if (cost > 16000 || cost < 0) {
		ReplyToCommand(client, "[SM] Use: sm_danger_zone_items_medishot_cost <0-16000>");
	} else {
		MediShotCost = cost;
	}
	return Plugin_Handled;
}

public Action Command_Admin_MediShot_Enabled(int client, int args) {
	if (args < 1) {
		ReplyToCommand(client, "\"sm_danger_zone_items_medishot_enabled\" = \"%d\"", MediShotEnabled == true ? 1 : 0);
		return Plugin_Handled;
	}
	char strEnable[32];
	GetCmdArg(1, strEnable, sizeof(strEnable)); 
	int enable = StringToInt(strEnable);
	if (enable > 1 || enable < 0) {
		ReplyToCommand(client, "[SM] Use: sm_danger_zone_items_medishot_enabled <0-1>");
	} else if (enable == 1) {
		MediShotEnabled = true;
	} else if (enable == 0) {
		MediShotEnabled = false;
	}
	return Plugin_Handled;
}

public Action Command_Admin_BreachCharge_Cost(int client, int args) {
	if (args < 1) {
		ReplyToCommand(client, "\"sm_danger_zone_items_breachcharge_cost\" = \"%d\"", BreachChargeCost);
		return Plugin_Handled;
	}
	char strCost[32];
	GetCmdArg(1, strCost, sizeof(strCost)); 
	int cost = StringToInt(strCost);
	if (cost > 16000 || cost < 0) {
		ReplyToCommand(client, "[SM] Use: sm_danger_zone_items_breachcharge_cost <0-16000>");
	} else {
		BreachChargeCost = cost;
	}
	return Plugin_Handled;
}

public Action Command_Admin_BreachCharge_Enabled(int client, int args) {
	if (args < 1) {
		ReplyToCommand(client, "\"sm_danger_zone_items_breachcharge_enabled\" = \"%d\"", BreachChargeEnabled == true ? 1 : 0);
		return Plugin_Handled;
	}
	char strEnable[32];
	GetCmdArg(1, strEnable, sizeof(strEnable)); 
	int enable = StringToInt(strEnable);
	if (enable > 1 || enable < 0) {
		ReplyToCommand(client, "[SM] Use: sm_danger_zone_items_breachcharge_enabled <0-1>");
	} else if (enable == 1) {
		BreachChargeEnabled = true;
	} else if (enable == 0) {
		BreachChargeEnabled = false;
	}
	return Plugin_Handled;
}

public Action Command_Buy_Shield(int client, int args) {
	if (!ShieldEnabled) {
		return Plugin_Handled;
	}
	if (RequireBuyZone) {
		new bool:InBuyZone = view_as<bool>(GetEntProp(client, Prop_Send, "m_bInBuyZone"));
		if (!InBuyZone) {
			PrintToChat(client, "Sorry you're not in a Buy Zone");
			return Plugin_Handled;
		}
		if (BuyStartRoundTimer == null) {
			PrintToChat(client, "The buy time has expired for this round");
			return Plugin_Handled;
		}
	}
	new account = GetEntProp(client, Prop_Send, "m_iAccount");
	if (account < ShieldCost) {
		PrintToChat(client, "Sorry you don't have $%d to buy the Ballistic Shield", ShieldCost);
		return Plugin_Handled;
	}
	new weaponIdx = GetPlayerWeaponSlot(client, 11);
	if (weaponIdx != -1) {
		if (IsValidEdict(weaponIdx) && IsValidEntity(weaponIdx)) {
			decl String:className[128];
			GetEntityClassname(weaponIdx, className, sizeof(className));
			if (StrEqual("weapon_shield", className)) {
				PrintToChat(client, "You are already carrying the Ballistic Shield");
				return Plugin_Handled;
			}
		}
	}
	SetEntProp(client, Prop_Send, "m_iAccount", account - ShieldCost);
	GivePlayerItem(client, "weapon_shield");
	PrintToChat(client, "You've bought a Ballistic Shield");
	return Plugin_Handled;
}

bool GetClientExoJump(int client) {
	return view_as<bool>(GetEntProp(client, Prop_Send, "m_passiveItems", 1, 1));
}

bool SetClientExoJump(int client, bool status) {
	SetEntProp(client, Prop_Send, "m_passiveItems", status, 1, 1);
	return GetClientExoJump(client);
}

public Action Command_Buy_ExoJump(int client, int args) {
	if (!ExoJumpEnabled) {
		return Plugin_Handled;
	}
	if (RequireBuyZone) {
		new bool:InBuyZone = view_as<bool>(GetEntProp(client, Prop_Send, "m_bInBuyZone"));
		if (!InBuyZone) {
			PrintToChat(client, "Sorry you're not in a Buy Zone");
			return Plugin_Handled;
		}
		if (BuyStartRoundTimer == null) {
			PrintToChat(client, "The buy time has expired for this round")
			return Plugin_Handled;
		}
	}
	if (GetClientExoJump(client)) {
		PrintToChat(client, "You already have ExoJump Boots equipped");
		return Plugin_Handled;
	}
	new account = GetEntProp(client, Prop_Send, "m_iAccount");
	if (account < ExoJumpCost) {
		PrintToChat(client, "Sorry you don't have $%d to buy the ExoJump Boots", ExoJumpCost);
		return Plugin_Handled;
	}
	SetEntProp(client, Prop_Send, "m_iAccount", account - ExoJumpCost);
	SetClientExoJump(client, true);
	PrintToChat(client, "You've bought ExoJump Boots");
	return Plugin_Handled;
}

public Action Command_Buy_Mines(int client, int args) {
	if (!MinesEnabled) {
		return Plugin_Handled;
	}
	if (RequireBuyZone) {
		new bool:InBuyZone = view_as<bool>(GetEntProp(client, Prop_Send, "m_bInBuyZone"));
		if (!InBuyZone) {
			PrintToChat(client, "Sorry you're not in a Buy Zone");
			return Plugin_Handled;
		}
		if (BuyStartRoundTimer == null) {
			PrintToChat(client, "The buy time has expired for this round")
			return Plugin_Handled;
		}
	}
	new account = GetEntProp(client, Prop_Send, "m_iAccount");
	if (account < MinesCost) {
		PrintToChat(client, "Sorry you don't have $%d to buy Bump Mines", MinesCost);
		return Plugin_Handled;
	}
	int weaponIdx;
	char className[128]; 
	int size = GetEntPropArraySize(client, Prop_Send, "m_hMyWeapons"); 
	for (int i = 0; i < size; ++i) { 
		if ( (weaponIdx = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", i)) != -1 ) { 
			GetEntityClassname(weaponIdx, className, sizeof(className));
			if (StrEqual("weapon_bumpmine", className)) {
				PrintToChat(client, "You are already carrying Bump Mines");
				return Plugin_Handled;
			}
		}
	}
	SetEntProp(client, Prop_Send, "m_iAccount", account - MinesCost);
	GivePlayerItem(client, "weapon_bumpmine");
	PrintToChat(client, "You've bought Bump Mines");
	return Plugin_Handled;
}

public Action Command_Buy_MediShot(int client, int args) {
	if (!MediShotEnabled) {
		return Plugin_Handled;
	}
	if (RequireBuyZone) {
		new bool:InBuyZone = view_as<bool>(GetEntProp(client, Prop_Send, "m_bInBuyZone"));
		if (!InBuyZone) {
			PrintToChat(client, "Sorry you're not in a Buy Zone");
			return Plugin_Handled;
		}
		if (BuyStartRoundTimer == null) {
			PrintToChat(client, "The buy time has expired for this round")
			return Plugin_Handled;
		}
	}
	new account = GetEntProp(client, Prop_Send, "m_iAccount");
	if (account < MediShotCost) {
		PrintToChat(client, "Sorry you don't have $%d to buy a Medi-Shot", MediShotCost);
		return Plugin_Handled;
	}
	int weaponIdx;
	char className[128]; 
	int size = GetEntPropArraySize(client, Prop_Send, "m_hMyWeapons"); 
	for (int i = 0; i < size; ++i) { 
		if ( (weaponIdx = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", i)) != -1 ) { 
			GetEntityClassname(weaponIdx, className, sizeof(className));
			if (StrEqual("weapon_healthshot", className)) {
				PrintToChat(client, "You are already carrying a Medi-Shot");
				return Plugin_Handled;
			}
		}
	}
	SetEntProp(client, Prop_Send, "m_iAccount", account - MediShotCost);
	GivePlayerItem(client, "weapon_healthshot");
	PrintToChat(client, "You've bought a Medi-Shot");
	return Plugin_Handled;
}

public Action Command_Buy_BreachCharge(int client, int args) {
	if (!BreachChargeEnabled) {
		return Plugin_Handled;
	}
	if (RequireBuyZone) {
		new bool:InBuyZone = view_as<bool>(GetEntProp(client, Prop_Send, "m_bInBuyZone"));
		if (!InBuyZone) {
			PrintToChat(client, "Sorry you're not in a Buy Zone");
			return Plugin_Handled;
		}
		if (BuyStartRoundTimer == null) {
			PrintToChat(client, "The buy time has expired for this round")
			return Plugin_Handled;
		}
	}
	new account = GetEntProp(client, Prop_Send, "m_iAccount");
	if (account < BreachChargeCost) {
		PrintToChat(client, "Sorry you don't have $%d to buy Breach Charges", BreachChargeCost);
		return Plugin_Handled;
	}
	int weaponIdx;
	char className[128]; 
	int size = GetEntPropArraySize(client, Prop_Send, "m_hMyWeapons"); 
	for (int i = 0; i < size; ++i) { 
		if ( (weaponIdx = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", i)) != -1 ) { 
			GetEntityClassname(weaponIdx, className, sizeof(className));
			if (StrEqual("weapon_breachcharge", className)) {
				PrintToChat(client, "You are already carrying Breach Charges");
				return Plugin_Handled;
			}
		}
	}
	SetEntProp(client, Prop_Send, "m_iAccount", account - BreachChargeCost);
	GivePlayerItem(client, "weapon_breachcharge");
	PrintToChat(client, "You've bought Breach Charges");
	return Plugin_Handled;
}

public Event_RoundPreStart(Handle:event, const String:name[], bool:dontBroadcast) {
	new Float:BuyTime = 20.0;
	ConVar cvarBuyTime = FindConVar("mp_buytime");
	if (cvarBuyTime != null) {
		BuyTime = float(cvarBuyTime.IntValue);
	}
	if (BuyStartRoundTimer != null) {
		KillTimer(BuyStartRoundTimer);
		BuyStartRoundTimer = null;
	}
	BuyStartRoundTimer = CreateTimer(BuyTime, StopBuying);
	if (ShieldEnabled || ExoJumpEnabled || MinesEnabled || MediShotEnabled || BreachChargeEnabled) {
		PrintToChatAll("Buy Danger Zone items with: !buydz in chat or sm_buydz in console");
	}
}

public Action StopBuying(Handle timer, any client) {
	BuyStartRoundTimer = null;
	return Plugin_Stop;
}

public Action Command_Menu(int client, int args) {
	if (!ShieldEnabled && !ExoJumpEnabled && !MinesEnabled && !MediShotEnabled && !BreachChargeEnabled) {
		return Plugin_Handled;
	}
	if (RequireBuyZone) {
		new bool:InBuyZone = view_as<bool>(GetEntProp(client, Prop_Send, "m_bInBuyZone"));
		if (!InBuyZone) {
			PrintToChat(client, "Sorry you're not in a Buy Zone");
			return Plugin_Handled;
		}
		if (BuyStartRoundTimer == null) {
			PrintToChat(client, "The buy time has expired for this round")
			return Plugin_Handled;
		}
	}
	Menu menu = new Menu(MenuHandler);
	menu.SetTitle("Danger Zone Items");
	char buffer[128];
	if (ShieldEnabled) {
		Format(buffer, sizeof(buffer), "Ballistic Shield - $%d", ShieldCost);
		menu.AddItem("shield", buffer);
	}
	if (ExoJumpEnabled) {
		Format(buffer, sizeof(buffer), "ExoJump Boots - $%d", ExoJumpCost);
		menu.AddItem("exojump", buffer);
	}
	if (MinesEnabled) {
		Format(buffer, sizeof(buffer), "Bump Mines - $%d", MinesCost);
		menu.AddItem("mines", buffer);
	}
	if (MediShotEnabled) {
		Format(buffer, sizeof(buffer), "Medi-Shot - $%d", MediShotCost);
		menu.AddItem("medishot", buffer);
	}
	if (BreachChargeEnabled) {
		Format(buffer, sizeof(buffer), "Breach Charges - $%d", BreachChargeCost);
		menu.AddItem("breachcharge", buffer);
	}
	menu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public int MenuHandler(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		int client = param1;
		char buffer[OPTION_NAME_LENGTH];
		menu.GetItem(param2, buffer, sizeof(buffer));
		if (StrEqual(buffer, "shield")) {
			Command_Buy_Shield(client, 0);
		} else if (StrEqual(buffer, "exojump")) {
			Command_Buy_ExoJump(client, 0);
		} else if (StrEqual(buffer, "mines")) {
			Command_Buy_Mines(client, 0);
		} else if (StrEqual(buffer, "medishot")) {
			Command_Buy_MediShot(client, 0);
		} else if (StrEqual(buffer, "breachcharge")) {
			Command_Buy_BreachCharge(client, 0);
		}
		Command_Menu(client, 0);
	} else if (action == MenuAction_End) {
		delete menu;
	}
	return 0;
}
