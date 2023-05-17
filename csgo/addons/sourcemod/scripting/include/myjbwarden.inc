/*
 * MyJailbreak - Warden Include File.
 * by: shanapu
 * https://github.com/shanapu/MyJailbreak/
 *
 * This file is part of the MyJailbreak SourceMod Plugin.
 * 
 * Copyright (C) 2016-2017 Thomas Schmidt (shanapu)
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

#if defined _myjbwarden_included
  #endinput
#endif
#define _myjbwarden_included


public SharedPlugin __pl_myjbwarden =
{
	name = "warden",
	file = "warden.smx",

	#if defined REQUIRE_PLUGIN
	required = 1,
	#else
	required = 0,
	#endif
};


#if !defined REQUIRE_PLUGIN
public __pl_myjbwarden_SetNTVOptional()
{
	MarkNativeAsOptional("warden_enable");
	MarkNativeAsOptional("warden_isenabled");
	
	MarkNativeAsOptional("warden_get");
	MarkNativeAsOptional("warden_getlast");

	MarkNativeAsOptional("warden_deputy_exist");
	MarkNativeAsOptional("warden_deputy_isdeputy");
	MarkNativeAsOptional("warden_deputy_set");
	MarkNativeAsOptional("warden_deputy_remove");
	MarkNativeAsOptional("warden_deputy_get");
	MarkNativeAsOptional("warden_deputy_getlast");

	MarkNativeAsOptional("warden_handcuffs_givepaperclip");
	MarkNativeAsOptional("warden_handcuffs_iscuffed");

	MarkNativeAsOptional("warden_freeday_set");
	MarkNativeAsOptional("warden_freeday_has");
}
#endif



/*********************************************************
 * Called when a client trys to set/become warden
 * By player, admin, randomchoose...
 *
 * @param client		The client who try to become warden
 * @param caller		The client who called the set or become warden command
 * @return 				Return Plugin_Handled to block & Plugin_Continue to pass the client.
 *********************************************************/
forward Action warden_OnWardenCreate(int client, int caller);


/*********************************************************
 * Called when a client become new warden
 *
 * @param client		The client who is new warden
 * @NoReturn
 *********************************************************/
forward void warden_OnWardenCreatedByUser(int client);


/*********************************************************
 * Called when a admin set a new warden
 *
 * @param client		The client is new warden
 * @NoReturn
 *********************************************************/
forward void warden_OnWardenCreatedByAdmin(int client);


/*********************************************************
 * Called when a the warden was removed by an admin
 *
 * @param client		The admin who removed the warden
 * @NoReturn
 *********************************************************/
forward void warden_OnWardenRemovedByAdmin(int client);


/*********************************************************
 * Called when a the warden retire hisself
 *
 * @param client		The client who was warden
 * @NoReturn
 *********************************************************/
forward void warden_OnWardenRemovedBySelf(int client);


/*********************************************************
 * Called when a the warden disconnect
 *
 * @param client		The client who disconnected
 * @NoReturn
 *********************************************************/
forward void warden_OnWardenDisconnected(int client);


/*********************************************************
 * Called when a the warden dies
 *
 * @param client		The client who was warden
 * @NoReturn
 *********************************************************/
forward void warden_OnWardenDeath(int client);



/*********************************************************
 * Called everytime the deputy position become free.
 * On depury dead, disconnect, removed, move to warden...
 * 
 * @param client		The client who was deputy
 * @NoReturn
 *********************************************************/
forward void warden_OnDeputyRemoved(int client);


/*********************************************************
 * Called when a client trys to become deputy
 * By player, admin, randomchoose...
 *
 * @param client		The client who try to become deputy
 * @NoReturn
 *********************************************************/
forward void warden_OnDeputyCreated(int client);



/*********************************************************
 * Disable & enable warden plugin
 *
 * @param status		true = enabled, false = disabled
 * @Return
 *********************************************************/
native void warden_enable(bool status);


/*********************************************************
 * get the current status of warden plugin
 *
 * 	
 * @Return				true = enabled, false = disabled
 *********************************************************/
native bool warden_isenabled();


/*********************************************************
 * get the current warden if he exists
 *
 *
 * @Return				Client Index of warden
 *********************************************************/
native int warden_get();


/*********************************************************
 * get the last warden if he exist
 *
 *
 * @Return				Client Index of last warden
 *********************************************************/
native int warden_getlast();



/*********************************************************
 * Checks if any Deputy exist
 *
 *
 * @Return				true on match, false if not
 *********************************************************/
native bool warden_deputy_exist();


/*********************************************************
 * returns if client is Deputy
 *
 * @param client		The client to run the check on
 * @Return 				true on match, false if not
 *********************************************************/
native bool warden_deputy_isdeputy(int client);


/*********************************************************
 * Set a client as Deputy
 *
 * @param client		The client to set as Deputy
 * @NoReturn
 *********************************************************/
native void warden_deputy_set(int client);


/*********************************************************
 * Removes the current Deputy if he exists
 *
 * @param client		The Deputy client to remove
 * @NoReturn
 *********************************************************/
native void warden_deputy_remove(int client);


/*********************************************************
 * get the current Deputy if he exists
 *
 *
 * @Return				Client index of deputy
 *********************************************************/
native int warden_deputy_get();


/*********************************************************
 * get the last deputy if he exists
 *
 *
 * @Return				Client Index of last deputy
 *********************************************************/
native int warden_deputy_getlast();



/*********************************************************
 * Give a client a amount of paperclips
 *
 * @param client		The client to give the paperclips
 * @param amount		The amount of paperclips
 * @NoReturn
 *********************************************************/
native void warden_handcuffs_givepaperclip(int client, int amount);


/*********************************************************
 * returns if client is in handcuffs
 *
 * @param client		The client to run the check on
 * @Retrun 				true on match, false if not
 *********************************************************/
native bool warden_handcuffs_iscuffed(int client);



/*********************************************************
 * Set the client get a freeday
 *
 * @param client		The client to run the check on
 * @NoReturn
 *********************************************************/
native void warden_freeday_set(int client);


/*********************************************************
 * returns if client has a freeday now
 *
 * @param client		The client to run the check on
 * @Return 				true on match, false if not
 *********************************************************/
native bool warden_freeday_has(int client);