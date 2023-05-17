#if defined _hidetrails_included
  #endinput
#endif
#define _hidetrails_included

 native HideTrails_ShouldHide(client);
 
/**
Shared plugin information
**/
public SharedPlugin:_pl_hidetrails = 
{
	name = "hidetrails",
	file = "hidetrails.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};

public _pl_hidetrails_SetNTVOptional()
{
	MarkNativeAsOptional("HideTrails_ShouldHide");
}