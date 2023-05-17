#if defined _ct_bans_included
 #endinput
#endif
#define _ct_bans_included


native bool:CTB_IsClientBanned(iClient);
native CTB_SendClientBanInfoMenu(iClient);


public SharedPlugin:__pl_ct_bans= 
{
	name = "ct_bans",
	file = "CT_Bans.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_ct_bans_SetNTVOptional()
{
	MarkNativeAsOptional("CTB_IsClientBanned");
}
#endif
