/* 
		Server Startup Configuration
		
		 		   by
		 -=( TFN | Pieface>.< )=-

-----------------------------------------
->				Details
-----------------------------------------
CVars
=====
sm_startup_active 	<1|0> 			This enables/disables the plugin
sm_startup_file 	MyConfig.cfg 	This is the full file path of your config
sm_startup			<1|0>			This is a system CVar used to decide whether to execute the script or not. DO NOT CHANGE!!

Installation
============
Put the .sp file and .smx files into the proper folders in the sourcemod directory and add
sm_startup_file "YourScriptName" into your server.cfg file. This needs to be the full file
path to the file else the operation will fail.

-----------------------------------------
->				Notes
-----------------------------------------
ChangeLog
=========
0.1.5 - This was the first full version but overly complicated
0.2.0 - This is the recode of the plugin. Easier to use and configure to users own end. BETA.
0.2.1 - Various compiler errors fixed. Fixed bug in file execution.
0.2.2 - Fixed a bug with the name of the file printing as a number over letters

*/

/************************************************************
->	-------------------  Pre-Amble ----------------------
************************************************************/
/* Includes */
#include <sourcemod>
/* Definitions */
#define PLUGIN_VERSION "0.2.2"
/* Handles */
new Handle:g_Startup 	= INVALID_HANDLE;
new Handle:g_Config 	= INVALID_HANDLE;
new Handle:g_Active		= INVALID_HANDLE;
/* Other */
new String:szConfig[128];

/************************************************************
->	-------------------  Main Code ----------------------
************************************************************/
public Plugin:myinfo = 
{
	name = "Server Startup Configuration",
	author = "-=( TFN | Pieface )=-",
	description = "This will run a config at server startup",
	version = PLUGIN_VERSION,
	url = "http://clantfn.counter-strike.com",	
};

public OnPluginStart()
{
	g_Active = CreateConVar("sm_startup_active", "1", "This enables/disables the plugin", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY);
	g_Startup = CreateConVar("sm_startup", "0", "This checks to see if the plugin is booting up", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY);	
	g_Config = CreateConVar("sm_startup_file", "", "This is the file to be run on startup", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY);
	CreateConVar("sm_startup_version", PLUGIN_VERSION, "This is the plugins version", FCVAR_PLUGIN);
}

public OnConfigsExecuted()
{
	GetConVarString(g_Config, szConfig, sizeof(szConfig));
	new IsActive = GetConVarInt(g_Active);
 	new IsStartup = GetConVarInt(g_Startup);
 	if(IsActive == 1 && IsStartup == 0){
	 	ServerCommand("exec \"%s\"", szConfig);
	 	SetConVarInt(g_Startup, 1, false, true);
	 	LogMessage("The file \"%s\" was sucessfully run on startup", szConfig);
 	} 	
}