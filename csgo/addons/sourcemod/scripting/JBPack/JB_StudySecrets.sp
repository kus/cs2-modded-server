#include <basecomm>
#include <cstrike>
#include <eyal-jailbreak>
#include <sdkhooks>
#include <sdktools>
#include <smlib>
#include <sourcemod>

#define PLUGIN_VERSION "1.0"

#pragma semicolon 1
#pragma newdecls  required


#define DISPLAY_TYPE_FULL 0

#define DEFAULT_MODELINDEX "materials/sprites/laserbeam.vmt"
#define DEFAULT_HALOINDEX  "materials/sprites/halo.vmt"

int g_LaserIndex, g_HaloIdx;

public Plugin myinfo =
{
	name        = "JailBreak Study Secrets",
	author      = "Eyal282",
	description = "Commands to figure out map secrets",
	version     = PLUGIN_VERSION,
	url         = ""
};

char   PREFIX[256];
char   MENU_PREFIX[64];
Handle hcv_Prefix     = INVALID_HANDLE;
Handle hcv_MenuPrefix = INVALID_HANDLE;

bool g_bStudy[MAXPLAYERS+1] = { false, ... };


public void OnPluginStart()
{
	LoadTranslations("common.phrases.txt");    // Fixing errors in target, something skyler didn't do haha.

	RegConsoleCmd("sm_study", Command_Study, "Allows you to study map secrets");
}

public void OnClientConnected(int client)
{
	g_bStudy[client] = false;
}
public Action Command_Study(int client, int args)
{
	g_bStudy[client] = !g_bStudy[client];

	if(g_bStudy[client])
	{
		PrintToChat(client, "Working buttons are green, locked buttons are red, working portals are blue.");
		PrintToChat(client, "Some buttons or portals will appear after finding the right button...");
	}
	else
	{
		PrintToChat(client, "Secret Study mode is disabled");
	}

	return Plugin_Handled;
}

public void OnAllPluginsLoaded()
{
	hcv_Prefix = FindConVar("sm_prefix_cvar");

	GetConVarString(hcv_Prefix, PREFIX, sizeof(PREFIX));
	HookConVarChange(hcv_Prefix, cvChange_Prefix);

	hcv_MenuPrefix = FindConVar("sm_menu_prefix_cvar");

	GetConVarString(hcv_MenuPrefix, MENU_PREFIX, sizeof(MENU_PREFIX));
	HookConVarChange(hcv_MenuPrefix, cvChange_MenuPrefix);

}

public void cvChange_Prefix(Handle convar, const char[] oldValue, const char[] newValue)
{
	FormatEx(PREFIX, sizeof(PREFIX), newValue);
}

public void cvChange_MenuPrefix(Handle convar, const char[] oldValue, const char[] newValue)
{
	FormatEx(MENU_PREFIX, sizeof(MENU_PREFIX), newValue);
}

public void OnMapStart()
{
	g_LaserIndex = PrecacheModel(DEFAULT_MODELINDEX, true);
	g_HaloIdx = PrecacheModel(DEFAULT_HALOINDEX, true);

	CreateTimer(0.4, Timer_DisplaySecrets, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
}

public Action Timer_DisplaySecrets(Handle hTimer)
{
	for(int i=1;i <= MaxClients;i++)
	{
		if(!g_bStudy[i])
			continue;

		if(!IsClientInGame(i))
			continue;

		else if(!IsPlayerAlive(i))
			continue;

		int entity = -1;

		float iOrigin[3];
		GetClientAbsOrigin(i, iOrigin);

		while((entity = FindEntityByClassname(entity, "*")) != -1)
		{
			char sClassname[64];
			GetEntityClassname(entity, sClassname, sizeof(sClassname));

			int colors[4];
			if(StrEqual(sClassname, "func_button"))
			{
				colors = {0, 255, 0, 255};

				if(GetEntProp(entity, Prop_Data, "m_bLocked"))
					colors = {255, 0, 0, 255};
			}
			else if(StrEqual(sClassname, "trigger_teleport"))
			{
				// Disabled teleports are out of the equation.
				if(GetEntProp(entity, Prop_Data, "m_bDisabled"))
					continue;

				colors = {0, 0, 255, 255};
			}
			else
				continue;

			float fOrigin[3];

			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", fOrigin);

			if(GetVectorDistance(fOrigin, iOrigin) > 700.0)
				continue;

			float fMins[3], fMaxs[3];

			GetEntPropVector(entity, Prop_Data, "m_vecMins", fMins);
			GetEntPropVector(entity, Prop_Data, "m_vecMaxs", fMaxs);

			AddVectors(fMins, fOrigin, fMins);
			AddVectors(fMaxs, fOrigin, fMaxs);

			TE_DrawBeamBoxToClient(i, fMaxs, fMins, g_LaserIndex, g_HaloIdx, 0, 0, 0.4, 2.0, 2.0, 1, 0.0, colors, 15, DISPLAY_TYPE_FULL); 

			// Diagonal shape across the shape to ensure visibility.
			TE_SetupBeamPoints(fMaxs, fMins, g_LaserIndex, g_HaloIdx, 0, 0, 0.4, 2.0, 2.0, 1, 0.0, colors, 15); 
			TE_SendToClient(i, 0.0);
		}
	}

	return Plugin_Continue;
}

void TE_DrawBeamBoxToClient(int client, float bottomCorner[3], float upperCorner[3], int modelIndex, int haloIndex, int startFrame, int frameRate, float life, float width, float endWidth, int fadeLength, float amplitude, const int color[4], int speed, int displayType)
{
	int clients[1];
	clients[0] = client;
	TE_DrawBeamBox(clients, 1, bottomCorner, upperCorner, modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, color, speed, displayType);
}

stock void TE_DrawBeamBoxToAll(float bottomCorner[3], float upperCorner[3], int modelIndex, int haloIndex, int startFrame, int frameRate, float life, float width, float endWidth, int fadeLength, float amplitude, const int color[4], int speed, int displayType)
{
	int[] clients = new int[MaxClients];
	int numClients;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			clients[numClients++] = i;
		}
	}

	TE_DrawBeamBox(clients, numClients, bottomCorner, upperCorner, modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, color, speed, displayType);
}

void TE_DrawBeamBox(int[] clients, int numClients, float bottomCorner[3], float upperCorner[3], int modelIndex, int haloIndex, int startFrame, int frameRate, float life, float width, float endWidth, int fadeLength, float amplitude, const int color[4], int speed, int displayType)
{
	float corners[8][3];

	if (upperCorner[2] < bottomCorner[2])
	{
		float buffer[3];
		buffer       = bottomCorner;
		bottomCorner = upperCorner;
		upperCorner  = buffer;
	}

	for (int i = 0; i < 4; i++)
	{
		Array_Copy(bottomCorner, corners[i], 3);
		Array_Copy(upperCorner, corners[i + 4], 3);
	}

	corners[1][0] = upperCorner[0];
	corners[2][0] = upperCorner[0];
	corners[2][1] = upperCorner[1];
	corners[3][1] = upperCorner[1];
	corners[4][0] = bottomCorner[0];
	corners[4][1] = bottomCorner[1];
	corners[5][1] = bottomCorner[1];
	corners[7][0] = bottomCorner[0];

	for (int i = 0; i < 4; i++)
	{
		int j = (i == 3 ? 0 : i + 1);
		TE_SetupBeamPoints(corners[i], corners[j], modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, color, speed);
		TE_Send(clients, numClients);
	}

	if (displayType == DISPLAY_TYPE_FULL)
	{
		for (int i = 4; i < 8; i++)
		{
			int j = (i == 7 ? 4 : i + 1);
			TE_SetupBeamPoints(corners[i], corners[j], modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, color, speed);
			TE_Send(clients, numClients);
		}

		for (int i = 0; i < 4; i++)
		{
			TE_SetupBeamPoints(corners[i], corners[i + 4], modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, color, speed);
			TE_Send(clients, numClients);
		}
	}
}