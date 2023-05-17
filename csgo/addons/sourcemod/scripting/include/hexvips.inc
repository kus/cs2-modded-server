/*
 * HexVips - API (Include) Plugin.
 * by: Hexer10
 * https://github.com/Hexer10/HexVips
 * 
 * Copyright (C) 2016-2018 Mattia (Hexer10 | Hexah | Papero)
 *
 * This file is part of the HexVips SourceMod Plugin.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 */
 
#if defined _vipbonus_included_
	#endinput
#endif
#define _vipbonus_included_

#pragma deprecated Use HexVips_IsClientVip instead.
native bool Vip_IsClientVip(int client);

#pragma deprecated Use HexVips_ResetItems instead.
native void Vip_ResetItems(int client);

/**
 * Return if a certain player is VIP or not
 * @param client		Client Index.
 *
 * @return 				True if a client has VipAccess, false otherwise.
 */
native bool HexVips_IsClientVip(int client);

/**
 * Reset all the VipMenu Items of a certain player 
 * @param client		Client Index.
 * @noreturn
 */
native void HexVips_ResetItems(int client);

/**
 * Sets a client's VIP Status
 * @param client		Client Index.
 * @param status		True to make player VIP, false otherwise.
 * @noreturn
 */
native void HexVips_SetVipStatus(int client, bool status);

/**
 * Called when the Vips are assigned to a client.
 * @param client		Client Index.
 * @return 				Plugin_Handled to block or Plugin_Continue to allow.
 */
forward Action HexVips_OnBonusSet(int client);

/**
 * Called when a VipStatus is updated.
 * @param client		Client Index.
 * @param status		True if the client is VIP, false otherwise.
 * @noreturn
 */
forward void HexVips_VipStatusUpdated(int client, bool status);

/**
 * Called when a client uses the VipMenu
 * @param client		Client Index.
 * @param item			Item Used
 * @noreturn
 */
forward void HexVips_OnPlayerUseMenu(int client, const char[] item);


public SharedPlugin __pl_hexvips =
{
	name = "hexvips",
	file = "hexvips.smx",
	
	#if defined REQUIRE_PLUGIN
	required = 1,
	#else
	required = 0,
	#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_hexvips_SetNTVOptional()
{
	MarkNativeAsOptional("Vip_IsClientVip");
	MarkNativeAsOptional("Vip_ResetItems");
	MarkNativeAsOptional("HexVips_IsClientVip");
	MarkNativeAsOptional("HexVips_ResetItems");
	MarkNativeAsOptional("HexVips_SetVipStatus");
	
}
#endif