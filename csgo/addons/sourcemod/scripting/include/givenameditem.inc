#if defined _givenameditem_included
 #endinput
#endif
#define _givenameditem_included

const int INVALID_PAINTKIT = -1;
const int PAINTKIT_PLAYERS = 0;
const int PAINTKIT_VANILLA = 9001;

/*
 * Called before a named item is created for a player
 *
 * @param client			The client index of the player receiving the named item
 * @param classname			The classname of the item to be created
 * @noreturn
*/
forward void OnGiveNamedItemEx(int client, const char[] classname);

native GiveNamedItem_SetClassname(const char[] classname);

native GiveNamedItem_GetDefinitionIndex();
native GiveNamedItem_SetDefinitionIndex(int value);

native bool GiveNamedItem_GetInUse();

native GiveNamedItem_GetPaintkit();
native GiveNamedItem_SetPaintkit(int value);

native GiveNamedItem_GetSeed();
native GiveNamedItem_SetSeed(int value);

native GiveNamedItem_GetWear();
native GiveNamedItem_SetWear(float value);

native GiveNamedItem_GetKills();
native GiveNamedItem_SetKills(int value);

native GiveNamedItem_GetEntityQuality();
native GiveNamedItem_SetEntityQuality(int value);

native bool GiveNamedItem_GetTeamSwitch();
native GiveNamedItem_SetTeamSwitch(bool value);

native GiveNamedItem_GetAccountID();
native GiveNamedItem_SetAccountID(int value);
native GiveNamedItem_SetNameTag(char[] nametag);

native int GiveNamedItem_GetItemDefinitionByClassname(const char[] classname);
native bool GiveNamedItem_GetClassnameByItemDefinition(int itemdefinition, char[] buffer, int length);
native bool GiveNamedItem_IsItemDefinitionKnife(int itemdefinition);
native bool GiveNamedItem_IsClassnameKnife(const char[] classname);

native GiveNamedItem_GiveKnife(client, int itemdefinition);

native GetNamedItem_GetWeaponTeamByItemDefinition(int itemdefinition);

#if defined _givenameditem_server
 #endinput
#endif

methodmap GiveNamedItem_ClientHook
{
	public GiveNamedItem_ClientHook()
	{
		return view_as<GiveNamedItem_ClientHook>(1);
	}
	
	property bool InUse
	{
		public get() { return GiveNamedItem_GetInUse(); }
	}
	
	property int ItemDefinition
	{
		public get() { return GiveNamedItem_GetDefinitionIndex(); }
		public set(int value) { GiveNamedItem_SetDefinitionIndex(value); }
	}
	
	property int Paintkit
	{
		public get() { return GiveNamedItem_GetPaintkit(); }
		public set(int value) { GiveNamedItem_SetPaintkit(value); }
	}
	
	property int Seed
	{
		public get() { return GiveNamedItem_GetSeed(); }
		public set(int value) { GiveNamedItem_SetSeed(value); }
	}
	
	property float Wear
	{
		public get() { return view_as<float>(GiveNamedItem_GetWear()); }
		public set(float value) { GiveNamedItem_SetWear(value); }
	}
	
	property int Kills
	{
		public get() { return GiveNamedItem_GetKills(); }
		public set(int value) { GiveNamedItem_SetKills(value); }
	}
	
	property int EntityQuality
	{
		public get() { return GiveNamedItem_GetEntityQuality(); }
		public set(int value) { GiveNamedItem_SetEntityQuality(value); }
	}
	
	property bool TeamSwitch
	{
		public get() { return GiveNamedItem_GetTeamSwitch(); }
		public set(bool value) { GiveNamedItem_SetTeamSwitch(value); }
	}
	
	property int AccountID
	{
		public get() { return GiveNamedItem_GetAccountID(); }
		public set(int value) { GiveNamedItem_SetAccountID(value); }
	}
	
	public bool SetClassname(const char[] classname)
	{
		GiveNamedItem_SetClassname(classname);
	}
	
	public int GetItemDefinitionByClassname(const char[] classname)
	{
		return GiveNamedItem_GetItemDefinitionByClassname(classname);
	}
	
	public bool GetClassnameByItemDefinition(int itemdefinition, char[] buffer, int length)
	{
		return GiveNamedItem_GetClassnameByItemDefinition(itemdefinition, buffer, length);
	}
	
	public bool IsItemDefinitionKnife(int itemdefinition)
	{
		return GiveNamedItem_IsItemDefinitionKnife(itemdefinition);
	}
	
	public bool IsClassnameKnife(const char[] classname)
	{
		return GiveNamedItem_IsClassnameKnife(classname);
	}
	
	public int GetWeaponTeamByItemDefinition(int itemdefinition)
	{
		return GetNamedItem_GetWeaponTeamByItemDefinition(itemdefinition);
	}
}

GiveNamedItem_ClientHook GiveNamedItemEx = view_as<GiveNamedItem_ClientHook>(1);