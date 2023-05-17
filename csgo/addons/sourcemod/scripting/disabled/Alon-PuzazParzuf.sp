#include <sourcemod>
#include <sdktools>
#include <clientprefs>

#define semicolon 1
#define newdecls required

#define SOUND_NAME "adp_sounds/adp_headshot.mp3"

Handle cpPuzaz = INVALID_HANDLE;
Handle cpPuzazVolume = INVALID_HANDLE;

public void OnMapStart()
{
	PrecacheSound(SOUND_NAME);
}

public void OnPluginStart()
{
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
	
	cpPuzaz = RegClientCookie("PuzazParzuf_Enabled", "Should you enable headshot sound?", CookieAccess_Public);
	cpPuzazVolume = RegClientCookie("PuzazParzuf_Volume", "Volume of headshot sound", CookieAccess_Public);
	
	SetCookieMenuItem(PuzazCookieMenu, 0, "Headshot Sound");
}

public int PuzazCookieMenu(int client, CookieMenuAction action, int info, char[] buffer, int maxlen)
{
	ShowPuzazMenu(client);
} 

public void ShowPuzazMenu(int client)
{
	Handle hMenu = CreateMenu(PuzazMenu_Handler);
	
	bool puzaz = GetClientPuzaz(client);
	char TempFormat[50];
	
	Format(TempFormat, sizeof(TempFormat), "Headshot Sound: %s", puzaz ? "Enabled" : "Disabled");
	AddMenuItem(hMenu, "", TempFormat);
	
	char strPuzazVolume[50];
	GetClientPuzazVolume(client, strPuzazVolume, sizeof(strPuzazVolume));
	Format(TempFormat, sizeof(TempFormat), "Headshot Volume: %s", strPuzazVolume);
	AddMenuItem(hMenu, "", TempFormat);


	SetMenuExitBackButton(hMenu, true);
	SetMenuExitButton(hMenu, true);
	DisplayMenu(hMenu, client, 30);
}


public int PuzazMenu_Handler(Handle hMenu, MenuAction action, int client, int item)
{
	if(action == MenuAction_DrawItem)
	{
		return ITEMDRAW_DEFAULT;
	}
	else if(item == MenuCancel_ExitBack)
	{
		ShowCookieMenu(client);
	}
	else if(action == MenuAction_Select)
	{
		switch(item)
		{
			case 0:
			{
				SetClientPuzaz(client, !GetClientPuzaz(client));
				ShowPuzazMenu(client);
			}
			case 1:
			{
				const float Difference = 0.05;
				char strPuzazVolume[50];
				GetClientPuzazVolume(client, strPuzazVolume, sizeof(strPuzazVolume));
				
				
				float Volume = StringToFloat(strPuzazVolume) + Difference;
				
				if(Volume > 1.0)
					Volume = Difference;
					
				SetClientPuzazVolume(client, Volume);
				
				ShowPuzazMenu(client);
			}
		}
		CloseHandle(hMenu);
	}
	return 0;
}

public Action Event_PlayerDeath(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	int victim = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	
	if(!IsValidPlayer(victim))
		return;
		
	else if(!GetClientPuzaz(victim))
		return;
		
	else if(!GetEventBool(hEvent, "headshot"))
		return;
		
	int attacker = GetClientOfUserId(GetEventInt(hEvent, "attacker"));
	
	if(!IsValidPlayer(attacker))
		return;
	
	/*
	char WeaponName[50];
	GetEventString(hEvent, "weapon", WeaponName, sizeof(WeaponName));
	
	if(IsKnifeClass(WeaponName))
		return;
	*/
	else if(!IsValidPlayer(victim))
		return;

	char strPuzazVolume[50];
	GetClientPuzazVolume(victim, strPuzazVolume, sizeof(strPuzazVolume));
	PlaySoundToClient(victim, SOUND_NAME, strPuzazVolume);
}

stock void PlaySoundToClient(int client, const char[] sound, char[] Volume = "1.0")
{
	float Origin[3];
	GetEntPropVector(client, Prop_Data, "m_vecOrigin", Origin);
	EmitSoundToClient(client, SOUND_NAME, client, _, _, _, StringToFloat(Volume), _, _, Origin);

	
}
stock bool IsValidPlayer(int client)
{
	if(client <= 0)
		return false;
		
	else if(client > MaxClients)
		return false;
		
	return IsClientInGame(client);
}

stock bool GetClientPuzaz(int client)
{
	char strPuzaz[50];
	GetClientCookie(client, cpPuzaz, strPuzaz, sizeof(strPuzaz));
	
	if(strPuzaz[0] == EOS)
	{
		SetClientPuzaz(client, true);
		return true;
	}
	
	return view_as<bool>(StringToInt(strPuzaz));
}

stock bool SetClientPuzaz(int client, bool value)
{
	char strPuzaz[50];
	
	IntToString(view_as<int>(value), strPuzaz, sizeof(strPuzaz));
	SetClientCookie(client, cpPuzaz, strPuzaz);
	
	return value;
}

stock void GetClientPuzazVolume(int client, char[] buffer, int length) // Because coding is retarded.
{
	char strPuzazVolume[50];
	GetClientCookie(client, cpPuzazVolume, strPuzazVolume, sizeof(strPuzazVolume));
	
	if(strPuzazVolume[0] == EOS)
	{
		SetClientPuzazVolume(client, 1.0);
		Format(buffer, length, "1.0");
		return;
	}
	if(StringToFloat(strPuzazVolume) > 1.0)
		SetClientPuzazVolume(client, 1.0);
	
	FixDecimal(strPuzazVolume);
	Format(buffer, length, strPuzazVolume);
}

stock void FixDecimal(char[] buffer, int Precision=2)
{
	for(int i=0;i < strlen(buffer);i++)
	{
		if(buffer[i] != '.')
			continue;
			
		buffer[i+1+Precision] = EOS;
		return;
	}
}

stock float SetClientPuzazVolume(int client, float value)
{
	char strPuzazVolume[50];
	
	FloatToString(value, strPuzazVolume, sizeof(strPuzazVolume));
	SetClientCookie(client, cpPuzazVolume, strPuzazVolume);
	
	return value;
}

stock bool IsKnifeClass(const char[] classname)
{
	if(StrContains(classname, "knife") != -1 || StrContains(classname, "bayonet") > -1)
		return true;
		
	return false;
}
