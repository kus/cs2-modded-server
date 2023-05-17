/*
 * SourceMod Hosties Project
 * by: SourceMod Hosties Dev Team
 *
 * This file is part of the SM Hosties project.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <hosties>

new Handle:gH_Cvar_Strip_On_Slay = INVALID_HANDLE;
new Handle:gH_Cvar_Strip_On_Kick = INVALID_HANDLE;
new Handle:gH_Cvar_Strip_On_Ban = INVALID_HANDLE;

new bool:gShadow_Strip_On_Slay = false;
new bool:gShadow_Strip_On_Kick = false;
new bool:gShadow_Strip_On_Ban = false;

// for ban.sp menu mimic
new g_BanTarget[MAXPLAYERS+1];
new g_BanTargetUserId[MAXPLAYERS+1];
new g_BanTime[MAXPLAYERS+1];

GunSafety_OnPluginStart()
{
	LoadTranslations("basebans.phrases");
	LoadTranslations("plugin.basecommands");
	LoadTranslations("playercommands.phrases");

	gH_Cvar_Strip_On_Slay = CreateConVar("sm_hosties_strip_onslay", "1", "Enable or disable the stripping of weapons from anyone who is slain.", 0, true, 0.0, true, 1.0);
	gShadow_Strip_On_Slay = true;
	gH_Cvar_Strip_On_Kick = CreateConVar("sm_hosties_strip_onkick", "1", "Enable or disable the stripping of weapons from anyone who is kicked.", 0, true, 0.0, true, 1.0);
	gShadow_Strip_On_Kick = true;
	gH_Cvar_Strip_On_Ban = CreateConVar("sm_hosties_strip_onban", "1", "Enable or disable the stripping of weapons from anyone who is banned.", 0, true, 0.0, true, 1.0);
	gShadow_Strip_On_Ban = true;
	
	HookConVarChange(gH_Cvar_Strip_On_Slay, GunSafety_CvarChanged);
	HookConVarChange(gH_Cvar_Strip_On_Kick, GunSafety_CvarChanged);
	HookConVarChange(gH_Cvar_Strip_On_Ban, GunSafety_CvarChanged);
	
	AddCommandListener(Strip_Player_Weapons_Intercept, "sm_slay");
	AddCommandListener(Strip_Player_Weapons_Intercept, "sm_kick");
	AddCommandListener(Strip_Player_Weapons_Intercept, "sm_ban");
}

public Action:Strip_Player_Weapons_Intercept(client, const String:command[], iArgNumber)
{
	// let original command handle return text
	if (iArgNumber < 1)
	{
		return Plugin_Continue;
	}
	
	// check for proper admin permissions and cvars
	if (StrEqual(command, "sm_slay", false))
	{
		if (!gShadow_Strip_On_Slay)
		{
			return Plugin_Continue;
		}
	
		new AdminFlag:flag;
		if (!GetCommandOverride(command, Override_Command, _:flag))
		{
			flag = Admin_Slay;
		}
		
		if (client && !GetAdminFlag(GetUserAdmin(client), flag))
		{
			return Plugin_Continue;
		}
	}
	else if (StrEqual(command, "sm_kick", false))
	{
		if (!gShadow_Strip_On_Kick)
		{
			return Plugin_Continue;
		}
		
		new AdminFlag:flag;
		if (!GetCommandOverride(command, Override_Command, _:flag))
		{
			flag = Admin_Kick;
		}
		
		if (client && !GetAdminFlag(GetUserAdmin(client), flag))
		{
			return Plugin_Continue;
		}
	}
	else if (StrEqual(command, "sm_ban", false))
	{
		if (!gShadow_Strip_On_Ban)
		{
			return Plugin_Continue;
		}
		
		new AdminFlag:flag;
		if (!GetCommandOverride(command, Override_Command, _:flag))
		{
			flag = Admin_Ban;
		}
		
		if (client && !GetAdminFlag(GetUserAdmin(client), flag))
		{
			return Plugin_Continue;
		}
	}
		
	// process the command
	decl String:arg[65];
	GetCmdArg(1, arg, sizeof(arg));

	decl String:target_name[MAX_TARGET_LENGTH];
	decl target_list[MAXPLAYERS], target_count, bool:tn_is_ml;
	
	if ((target_count = ProcessTargetString(
			arg,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for (new i = 0; i < target_count; i++)
	{
		StripAllWeapons(target_list[i]);
	}
	
	return Plugin_Continue;
}

public GunSafety_CvarChanged(Handle:cvar, const String:oldValue[], const String:newValue[])
{
	if (cvar == gH_Cvar_Strip_On_Slay)
	{
		gShadow_Strip_On_Slay = bool:StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_Strip_On_Kick)
	{
		gShadow_Strip_On_Kick = bool:StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_Strip_On_Ban)
	{
		gShadow_Strip_On_Ban = bool:StringToInt(newValue);
	}
}

GunSafety_Menus(Handle:h_TopMenu, TopMenuObject:obj_Hosties)
{
	AddToTopMenu(h_TopMenu, "sm_hslay", TopMenuObject_Item, AdminMenu_Slay, obj_Hosties, "sm_slay", ADMFLAG_SLAY);
	AddToTopMenu(h_TopMenu, "sm_hkick", TopMenuObject_Item, AdminMenu_Kick, obj_Hosties, "sm_kick", ADMFLAG_KICK);
	AddToTopMenu(h_TopMenu, "sm_hban", TopMenuObject_Item, AdminMenu_Ban, obj_Hosties, "sm_ban", ADMFLAG_BAN);
	
	// Remove the other ones
	/*
	new TopMenuObject:menu = FindTopMenuCategory(h_TopMenu, "sm_slay");
	if (menu != INVALID_TOPMENUOBJECT)
	{
		RemoveFromTopMenu(h_TopMenu, menu);
	}
	menu = FindTopMenuCategory(h_TopMenu, "sm_kick");
	if (menu != INVALID_TOPMENUOBJECT)
	{
		RemoveFromTopMenu(h_TopMenu, menu);
	}
	menu = FindTopMenuCategory(h_TopMenu, "sm_ban");
	if (menu != INVALID_TOPMENUOBJECT)
	{
		RemoveFromTopMenu(h_TopMenu, menu);
	}*/
}

// from slay.sp
PerformSlay(client, target)
{
	LogAction(client, target, "\"%L\" slayed \"%L\"", client, target);
	StripAllWeapons(target);
	ForcePlayerSuicide(target);
}

DisplaySlayMenu(client)
{
	new Handle:menu = CreateMenu(MenuHandler_Slay);
	
	decl String:title[100];
	Format(title, sizeof(title), "%T:", "Slay player", client);
	SetMenuTitle(menu, title);
	SetMenuExitBackButton(menu, true);
	
	AddTargetsToMenu(menu, client, true, true);
	
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public AdminMenu_Slay(Handle:topmenu, 
					  TopMenuAction:action,
					  TopMenuObject:object_id,
					  param,
					  String:buffer[],
					  maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "%T", "Slay player", param);
	}
	else if (action == TopMenuAction_SelectOption)
	{
		DisplaySlayMenu(param);
	}
}

public MenuHandler_Slay(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && gH_TopMenu != INVALID_HANDLE)
		{
			DisplayTopMenu(gH_TopMenu, param1, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		decl String:info[32];
		new userid, target;
		
		GetMenuItem(menu, param2, info, sizeof(info));
		userid = StringToInt(info);

		if ((target = GetClientOfUserId(userid)) == 0)
		{
			PrintToChat(param1, "[SM] %t", "Player no longer available");
		}
		else if (!CanUserTarget(param1, target))
		{
			PrintToChat(param1, "[SM] %t", "Unable to target");
		}
		else if (!IsPlayerAlive(target))
		{
			ReplyToCommand(param1, "[SM] %t", "Player has since died");
		}
		else
		{
			decl String:name[32];
			GetClientName(target, name, sizeof(name));
			PerformSlay(param1, target);
			ShowActivity2(param1, "[SM] ", "%t", "Slayed target", "_s", name);
		}
		
		DisplaySlayMenu(param1);
	}
}

// from kick.sp
PerformKick(client, target, const String:reason[])
{
	LogAction(client, target, "\"%L\" kicked \"%L\" (reason \"%s\")", client, target, reason);

	StripAllWeapons(target);
	
	if (reason[0] == '\0')
	{
		KickClient(target, "%t", "Kicked by admin");
	}
	else
	{
		KickClient(target, "%s", reason);
	}
}

DisplayKickMenu(client)
{
	new Handle:menu = CreateMenu(MenuHandler_Kick);
	
	decl String:title[100];
	Format(title, sizeof(title), "%T:", "Kick player", client);
	SetMenuTitle(menu, title);
	SetMenuExitBackButton(menu, true);
	
	AddTargetsToMenu(menu, client, false, false);
	
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public AdminMenu_Kick(Handle:topmenu, 
					  TopMenuAction:action,
					  TopMenuObject:object_id,
					  param,
					  String:buffer[],
					  maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "%T", "Kick player", param);
	}
	else if (action == TopMenuAction_SelectOption)
	{
		DisplayKickMenu(param);
	}
}

public MenuHandler_Kick(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && gH_TopMenu != INVALID_HANDLE)
		{
			DisplayTopMenu(gH_TopMenu, param1, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		decl String:info[32];
		new userid, target;
		
		GetMenuItem(menu, param2, info, sizeof(info));
		userid = StringToInt(info);

		if ((target = GetClientOfUserId(userid)) == 0)
		{
			PrintToChat(param1, "[SM] %t", "Player no longer available");
		}
		else if (!CanUserTarget(param1, target))
		{
			PrintToChat(param1, "[SM] %t", "Unable to target");
		}
		else
		{
			decl String:name[MAX_NAME_LENGTH];
			GetClientName(target, name, sizeof(name));
			ShowActivity2(param1, "[SM] ", "%t", "Kicked target", "_s", name);
			PerformKick(param1, target, "");
		}
		
		/* Re-draw the menu if they're still valid */
		if (IsClientInGame(param1) && !IsClientInKickQueue(param1))
		{
			DisplayKickMenu(param1);
		}
	}
}

// from ban.sp
PrepareBan(client, target, time, const String:reason[])
{
	new originalTarget = GetClientOfUserId(g_BanTargetUserId[client]);

	if (originalTarget != target)
	{
		if (client == 0)
		{
			PrintToServer("[SM] %t", "Player no longer available");
		}
		else
		{
			PrintToChat(client, "[SM] %t", "Player no longer available");
		}

		return;
	}

	decl String:authid[64], String:name[32];
	GetClientAuthId(target, AuthId_Steam2, authid, sizeof(authid));
	GetClientName(target, name, sizeof(name));
	
	if (!time)
	{
		if (reason[0] == '\0')
		{
			ShowActivity(client, "%t", "Permabanned player", name);
		} else {
			ShowActivity(client, "%t", "Permabanned player reason", name, reason);
		}
	} else {
		if (reason[0] == '\0')
		{
			ShowActivity(client, "%t", "Banned player", name, time);
		} else {
			ShowActivity(client, "%t", "Banned player reason", name, time, reason);
		}
	}

	LogAction(client, target, "\"%L\" banned \"%L\" (minutes \"%d\") (reason \"%s\")", client, target, time, reason);
	
	StripAllWeapons(target);

	if (reason[0] == '\0')
	{
		if (g_bSBAvailable)
		{
			SBBanPlayer(client, target, time, "Banned");
		}
		else
		{
			BanClient(target, time, BANFLAG_AUTO, "Banned", "Banned", "sm_ban", client);
		}
	}
	else
	{
		if (g_bSBAvailable)
		{
			// avoid const-string tag mismatch
			new String:banreason[255];
			strcopy(banreason, sizeof(banreason), reason);
			SBBanPlayer(client, target, time, banreason);
		}
		else
		{
			BanClient(target, time, BANFLAG_AUTO, reason, reason, "sm_ban", client);
		}
	}
}

DisplayBanTargetMenu(client)
{
	new Handle:menu = CreateMenu(MenuHandler_BanPlayerList);

	decl String:title[100];
	Format(title, sizeof(title), "%T:", "Ban player", client);
	SetMenuTitle(menu, title);
	SetMenuExitBackButton(menu, true);

	AddTargetsToMenu2(menu, client, COMMAND_FILTER_NO_BOTS|COMMAND_FILTER_CONNECTED);

	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

DisplayBanTimeMenu(client)
{
	new Handle:menu = CreateMenu(MenuHandler_BanTimeList);

	decl String:title[100];
	Format(title, sizeof(title), "%T: %N", "Ban player", client, g_BanTarget[client]);
	SetMenuTitle(menu, title);
	SetMenuExitBackButton(menu, true);

	AddMenuItem(menu, "0", "Permanent");
	AddMenuItem(menu, "10", "10 Minutes");
	AddMenuItem(menu, "30", "30 Minutes");
	AddMenuItem(menu, "60", "1 Hour");
	AddMenuItem(menu, "240", "4 Hours");
	AddMenuItem(menu, "1440", "1 Day");
	AddMenuItem(menu, "10080", "1 Week");

	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

DisplayBanReasonMenu(client)
{
	new Handle:menu = CreateMenu(MenuHandler_BanReasonList);

	decl String:title[100];
	Format(title, sizeof(title), "%T: %N", "Ban reason", client, g_BanTarget[client]);
	SetMenuTitle(menu, title);
	SetMenuExitBackButton(menu, true);

	/* :TODO: we should either remove this or make it configurable */

	AddMenuItem(menu, "Abusive", "Abusive");
	AddMenuItem(menu, "Racism", "Racism");
	AddMenuItem(menu, "General cheating/exploits", "General cheating/exploits");
	AddMenuItem(menu, "Wallhack", "Wallhack");
	AddMenuItem(menu, "Aimbot", "Aimbot");
	AddMenuItem(menu, "Speedhacking", "Speedhacking");
	AddMenuItem(menu, "Mic spamming", "Mic spamming");
	AddMenuItem(menu, "Admin disrespect", "Admin disrespect");
	AddMenuItem(menu, "Camping", "Camping");
	AddMenuItem(menu, "Team killing", "Team killing");
	AddMenuItem(menu, "Unacceptable Spray", "Unacceptable Spray");
	AddMenuItem(menu, "Breaking Server Rules", "Breaking Server Rules");
	AddMenuItem(menu, "Other", "Other");

	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public AdminMenu_Ban(Handle:topmenu,
							  TopMenuAction:action,
							  TopMenuObject:object_id,
							  param,
							  String:buffer[],
							  maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "%T", "Ban player", param);
	}
	else if (action == TopMenuAction_SelectOption)
	{
		DisplayBanTargetMenu(param);
	}
}

public MenuHandler_BanReasonList(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && gH_TopMenu != INVALID_HANDLE)
		{
			DisplayTopMenu(gH_TopMenu, param1, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		decl String:info[64];

		GetMenuItem(menu, param2, info, sizeof(info));

		PrepareBan(param1, g_BanTarget[param1], g_BanTime[param1], info);
	}
}

public MenuHandler_BanPlayerList(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && gH_TopMenu != INVALID_HANDLE)
		{
			DisplayTopMenu(gH_TopMenu, param1, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		decl String:info[32], String:name[32];
		new userid, target;

		GetMenuItem(menu, param2, info, sizeof(info), _, name, sizeof(name));
		userid = StringToInt(info);

		if ((target = GetClientOfUserId(userid)) == 0)
		{
			PrintToChat(param1, "[SM] %t", "Player no longer available");
		}
		else if (!CanUserTarget(param1, target))
		{
			PrintToChat(param1, "[SM] %t", "Unable to target");
		}
		else
		{
			g_BanTarget[param1] = target;
			g_BanTargetUserId[param1] = userid;
			DisplayBanTimeMenu(param1);
		}
	}
}

public MenuHandler_BanTimeList(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && gH_TopMenu != INVALID_HANDLE)
		{
			DisplayTopMenu(gH_TopMenu, param1, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		decl String:info[32];

		GetMenuItem(menu, param2, info, sizeof(info));
		g_BanTime[param1] = StringToInt(info);

		DisplayBanReasonMenu(param1);
	}
}