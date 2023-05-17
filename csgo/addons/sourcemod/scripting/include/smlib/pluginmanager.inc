/*****************************************************************


	SMLib's PluginManager (Alpha release)


*****************************************************************/
#include <smlib>

/*****************************************************************


		D O U B L E   I N C L U D E   P R E V E N T I O N


*****************************************************************/
#if defined _smlib_pluginmanager_included
  #endinput
#endif
#define _smlib_pluginmanager_included

/*****************************************************************


		D E F I N E S


*****************************************************************/
#define MAX_CONVAR_LENGTH 256

#define MAX_PLUGIN_NAME_LENGTH 128
#define MAX_PLUGIN_SHORTNAME_LENGTH 128
#define MAX_PLUGIN_TAG_LENGTH 16
#define MAX_PLUGIN_FILENAME_LENGTH 128

#define MAX_VERSION_INFO_LENGTH 512

/*****************************************************************


		G L O B A L   V A R S


*****************************************************************/
// ConVar Handles
new Handle:g_cvarVersion 									= INVALID_HANDLE;
new Handle:g_cvarEnable 									= INVALID_HANDLE;
new Handle:g_cvarDebug 										= INVALID_HANDLE;
new Handle:g_cvarDeveloper_Flag 							= INVALID_HANDLE;

//ConVar Runtime optimizer
new g_iPlugin_Enable 										= 0;
new g_iPlugin_Debug 										= 0;
new AdminFlag:g_afPlugin_Developer_Flag 					= Admin_Root;

//Plugin Info
new String:g_sPlugin_Name[MAX_PLUGIN_NAME_LENGTH];
new String:g_sPlugin_Short_Name[MAX_PLUGIN_SHORTNAME_LENGTH];
new String:g_sPlugin_Tag[MAX_PLUGIN_TAG_LENGTH];
new String:g_sPlugin_File_Name[MAX_PLUGIN_FILENAME_LENGTH];

/*****************************************************************


		F O R W A R D   P U B L I C S


*****************************************************************/
/**
 * SMLib Init function to take care of version, enable, debug and developerflag convars.
 *
 * @param name
 * @param tag
 * @param version
 * @param author
 * @param description
 * @param url
 * @noreturn
 */
stock SMLib_OnPluginStart(const String:name[],const String:tag[], const String:version[], const String:author[], const String:description[], const String:url[]){
	
	//Name
	strcopy(g_sPlugin_Name,sizeof(g_sPlugin_Name),name);
	
	//Shortname out of name
	strcopy(g_sPlugin_Short_Name,sizeof(g_sPlugin_Short_Name),name);
	ReplaceString(g_sPlugin_Short_Name,sizeof(g_sPlugin_Short_Name)," ","",false);
	String_ToLower(g_sPlugin_Short_Name,g_sPlugin_Short_Name,sizeof(g_sPlugin_Short_Name));
	
	//Tag
	strcopy(g_sPlugin_Tag,sizeof(g_sPlugin_Tag),tag);
	
	//Filename
	GetPluginFilename(INVALID_HANDLE,g_sPlugin_File_Name,sizeof(g_sPlugin_File_Name));
	
	//Version
	decl String:cvarVersionInfo[MAX_VERSION_INFO_LENGTH];
	Format(cvarVersionInfo,sizeof(cvarVersionInfo),"\n  || %s ('%s') v%s\n  || Builddate:'%s - %s'\n  || Author(s):'%s'\n  || URL:'%s'\n  || Description:'%s'\n",g_sPlugin_Name,g_sPlugin_File_Name,version,__TIME__,__DATE__,author,url,description);
	//needed if plugin has some late load:
	g_cvarVersion = CreateConVarEx("version", version, cvarVersionInfo, FCVAR_PLUGIN|FCVAR_DONTRECORD|FCVAR_NOTIFY);
	SetConVarString(g_cvarVersion,version);
	
	//Cvars
	g_cvarEnable = CreateConVarEx("enable", "1", "Enables or Disables this plugin (1=Enable|0=Disable)",FCVAR_PLUGIN|FCVAR_NOTIFY,true,0.0);
	g_cvarDebug = CreateConVarEx("debug", "0", "Enables or Disables debug mode of this plugin (3=ignore who is dev|2=SendToClient|1=Enable|0=Disabled)",FCVAR_PLUGIN|FCVAR_DONTRECORD,true,0.0,true,3.0);
	g_cvarDeveloper_Flag = CreateConVarEx("developerflag", "z", "what admin flag is required to be an developer for this plugin",FCVAR_PLUGIN|FCVAR_DONTRECORD);
	
	//Cvar Runtime optimizer
	g_iPlugin_Enable = GetConVarInt(g_cvarEnable);
	g_iPlugin_Debug = GetConVarInt(g_cvarDebug);
	decl String:tempFlag[2];
	GetConVarString(g_cvarDeveloper_Flag,tempFlag,sizeof(tempFlag));
	g_afPlugin_Developer_Flag = Admin_GetFlagByChar(tempFlag);
	
	//ConVar Hooks
	HookConVarChange(g_cvarEnable,SMLib_ConVarChange);
	HookConVarChange(g_cvarDebug,SMLib_ConVarChange);
	HookConVarChange(g_cvarDeveloper_Flag,SMLib_ConVarChange);
	
	Server_PrintDebug(cvarVersionInfo);
}

/****************************************************************


		C A L L B A C K   F U N C T I O N S


****************************************************************/
public SMLib_ConVarChange(Handle:cvar, const String:oldVal[], const String:newVal[]){
	

	//Setting runtime optimizer
	//SMLib ConVars (don't remove)
	if(cvar == g_cvarEnable){
		g_iPlugin_Enable = StringToInt(newVal);
	}
	
	else if(cvar == g_cvarDebug){
		g_iPlugin_Debug = StringToInt(newVal);
	}
	
	else if(cvar == g_cvarDeveloper_Flag){
		g_afPlugin_Developer_Flag = Admin_GetFlagByChar(newVal);
	}
	
	//Error Handling (don't remove)
	else {
		
		decl String:cvarName[64];
		GetConVarName(cvar,cvarName,sizeof(cvarName));
		LogError("SMLib_ConVarChange was called because cvar '%s' changed from '%s' to '%s', but there isn't an runtime optimizer!",cvarName,oldVal,newVal);
	}
}


/*****************************************************************


		F U N C T I O N S


*****************************************************************/
Handle:CreateConVarEx(const String:name[], const String:defaultValue[], const String:description[]="", flags=0, bool:hasMin=false, Float:min=0.0, bool:hasMax=false, Float:max=0.0){
	
	new String:format[MAX_CONVAR_LENGTH];
	
	//if we got no tag, then we dont want a _ (underscore) before our cvar
	if(g_sPlugin_Tag[0] == '\0'){
		
		Format(format,sizeof(format),"%s_%s",g_sPlugin_Short_Name,name);
	}
	else {
		
		Format(format,sizeof(format),"%s_%s_%s",g_sPlugin_Tag,g_sPlugin_Short_Name,name);
	}
	
	return CreateConVar(format,defaultValue,description,flags,hasMin,min,hasMax,max);
}

enum IsDeveloper{
	
	IsDeveloper_Pending = -1,
	IsDeveloper_NotDeveloper = 0,
	IsDeveloper_Developer = 1
};

/**
 * Checks if the client is a developer.
 *
 * @param client		client index.
 * @return 				true if client is developer.
 */
stock IsDeveloper:Client_IsDeveloper(client){
	
	if(((g_iPlugin_Enable == 0)) || (g_iPlugin_Debug == 0)){
		return IsDeveloper_Pending;
	}
	
	static IsDeveloper:ls_idIsDeveloper[MAXPLAYERS+1] = {IsDeveloper_Pending,...};
	static ls_iClientUserId[MAXPLAYERS+1] = {-1,...};
	static AdminFlag:ls_afLastDevFlag[MAXPLAYERS+1] = {AdminFlag:-1,...};
	
	if(ls_afLastDevFlag[client] == g_afPlugin_Developer_Flag){
		
		if(GetClientOfUserId(ls_iClientUserId[client]) == client){
			
			return ls_idIsDeveloper[client];
		}
	}
	
	ls_afLastDevFlag[client] = g_afPlugin_Developer_Flag;
	
	if(!IsClientAuthorized(client)){
		
		return IsDeveloper_Pending;
	}
	
	new AdminId:adminid = GetUserAdmin(client);
	ls_iClientUserId[client] = GetClientUserId(client);
	
	if(adminid == INVALID_ADMIN_ID){
		
		//PrintToChat(client,"you are not admin at all");
		//PrintToServer("client: %N is not admin at all",client);
		return ls_idIsDeveloper[client] = IsDeveloper_NotDeveloper;
	}
	else if(GetAdminFlag(adminid,g_afPlugin_Developer_Flag)){
		
		//PrintToServer("client: %N is in developermode now (g_afPlugin_Developer_Flag: %d)",client,g_afPlugin_Developer_Flag);
		return ls_idIsDeveloper[client] = IsDeveloper_Developer;
	}
	
	//PrintToChat(client,"you don't have permission to be developer");
	//PrintToServer("client: %N has not the permission to be developer (g_afPlugin_Developer_Flag: %d)",client,g_afPlugin_Developer_Flag);
	return ls_idIsDeveloper[client] = IsDeveloper_NotDeveloper;
}
/**
 * Prints a message to the server console if debug mode is on.
 *
 * @param format		Formatting rules.
 * @param ...			Variable number of format parameters.
 * @noreturn
 */
stock Server_PrintDebug(const String:format[],any:...){
	
	if(g_iPlugin_Enable == 0){
		return;
	}
	
	switch(g_iPlugin_Debug){
		
		case 1:{
			decl String:vformat[1024];
			VFormat(vformat, sizeof(vformat), format, 2);
			PrintToServer(vformat);
		}
		case 2:{
			decl String:vformat[1024];
			VFormat(vformat, sizeof(vformat), format, 2);
			PrintToServer(vformat);
			ClientAll_PrintDebug(vformat);
		}
		case 3:{
			decl String:vformat[1024];
			VFormat(vformat, sizeof(vformat), format, 2);
			PrintToServer(vformat);
			PrintToChatAll(vformat);
		}
	}
}
/**
 * Prints a message to all developers if debug mode is on.
 *
 * @param format		Formatting rules.
 * @param ...			Variable number of format parameters.
 * @noreturn
 */
stock ClientAll_PrintDebug(const String:format[],any:...){
	
	if(g_iPlugin_Enable == 0){
		return;
	}
	
	switch(g_iPlugin_Debug){
		
		case 1,2:{
			
			decl String:vformat[1024];
			VFormat(vformat, sizeof(vformat), format, 2);
			
			for(new client=1;client<=MaxClients;client++){
				
				if(!IsClientInGame(client)){
					continue;
				}
				
				Client_PrintDebug(client,vformat);
			}
		}
		case 3: {
			
			decl String:vformat[1024];
			VFormat(vformat, sizeof(vformat), format, 2);
			
			for(new client=1;client<=MaxClients;client++){
				
				if(!IsClientInGame(client)){
					continue;
				}
				
				PrintToChat(client,vformat);
			}
		}
	}
}
/**
 * Prints a message to the developer if debug mode is on.
 *
 * @param client		Client index.
 * @param format		Formatting rules.
 * @param ...			Variable number of format parameters.
 * @noreturn
 */
stock Client_PrintDebug(client,const String:format[],any:...){
	
	if(g_iPlugin_Enable == 0){
		return;
	}
	
	switch(g_iPlugin_Debug){
		
		case 1,2:{
			
			if(!Client_IsDeveloper(client)){
				return;
			}
			
			decl String:vformat[1024];
			VFormat(vformat, sizeof(vformat), format, 3);
			PrintToChat(client,vformat);
		}
		case 3:{
			
			decl String:vformat[1024];
			VFormat(vformat, sizeof(vformat), format, 3);
			PrintToChat(client,vformat);
		}
	}
}

stock AdminFlag:Admin_GetFlagByChar(const String:c[]){
	
	new AdminFlag:admflag;
	
	//PrintToChatAll("getflagbychar: input: %s",c);
	
	if(FindFlagByChar(c[0],admflag)){
		
		//PrintToChatAll("getflagbychar: output: %d",admflag);
		return admflag;
	}
	//PrintToChatAll("getflagbychar: output: -1");
	return AdminFlag:-1; 
}

