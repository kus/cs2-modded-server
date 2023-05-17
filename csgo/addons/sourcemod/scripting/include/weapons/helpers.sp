/*  CS:GO Weapons&Knives SourceMod Plugin
 *
 *  Copyright (C) 2017 Kağan 'kgns' Üstüngel
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */

stock void StripHtml(const char[] source, char[] output, int size)
{
	int start, end;
	strcopy(output, size, source);
	while((start = StrContains(output, ">")) > 0)
	{
		strcopy(output, size, output[start+1]);
		if((end = StrContains(output, "<")) > 0)
		{
			output[end] = '\0';
		}
	}
}

stock void CleanNameTag(char[] nameTag, int size)
{
	ReplaceString(nameTag, size, "%", "％");
	while(StrContains(nameTag, "  ") > -1)
	{
		ReplaceString(nameTag, size, "  ", " ");
	}
	StripQuotes(nameTag);
}

stock int GetRandomSkin(int client, int index)
{
	int max = menuWeapons[g_iClientLanguage[client]][index].ItemCount;
	int random = GetRandomInt(2, max);
	char idStr[4];
	menuWeapons[g_iClientLanguage[client]][index].GetItem(random, idStr, sizeof(idStr));
	return StringToInt(idStr);
}

stock bool IsValidClient(int client)
{
    if (!(1 <= client <= MaxClients) || !IsClientInGame(client) || IsFakeClient(client) || IsClientSourceTV(client) || IsClientReplay(client))
    {
        return false;
    }
    return true;
}

stock int GetWeaponIndex(int entity)
{
	char class[32];
	if(GetWeaponClass(entity, class, sizeof(class)))
	{
		int index;
		if(g_smWeaponIndex.GetValue(class, index))
		{
			return index;
		}
	}
	return -1;
}

stock bool GetWeaponClass(int entity, char[] weaponClass, int size)
{
	int id = GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex");
	return ClassByDefIndex(id, weaponClass, size);
}

stock bool IsKnifeClass(const char[] classname)
{
	if ((StrContains(classname, "knife") > -1 && strcmp(classname, "weapon_knifegg") != 0) || StrContains(classname, "bayonet") > -1)
		return true;
	return false;
}

stock bool IsKnife(int entity)
{
	char classname[32];
	if(GetWeaponClass(entity, classname, sizeof(classname)))
		return IsKnifeClass(classname);
	return false;
}

stock int DefIndexByClass(char[] class)
{
	if (StrEqual(class, "weapon_knife"))
	{
		return 42;
	}
	if (StrEqual(class, "weapon_knife_t"))
	{
		return 59;
	}
	int index;
	g_smWeaponDefIndex.GetValue(class, index);
	if(index > -1)
		return index;
	return 0;
}

stock void RemoveWeaponPrefix(char[] source, char[] output, int size)
{
	strcopy(output, size, source[7]);
}

stock bool ClassByDefIndex(int index, char[] class, int size)
{
	switch(index)
	{
		case 42:
		{
			FormatEx(class, size, "weapon_knife");
			return true;
		}
		case 59:
		{
			FormatEx(class, size, "weapon_knife_t");
			return true;
		}
		default:
		{
			for(int i = 0; i < sizeof(g_iWeaponDefIndex); i++)
			{
				if(g_iWeaponDefIndex[i] == index)
				{
					FormatEx(class, size, g_WeaponClasses[i]);
					return true;
				}
			}
		}
	}
	return false;
}

stock bool IsValidWeapon(int weaponEntity)
{
	if (weaponEntity > 4096 && weaponEntity != INVALID_ENT_REFERENCE) {
		weaponEntity = EntRefToEntIndex(weaponEntity);
	}
	
	if (!IsValidEdict(weaponEntity) || !IsValidEntity(weaponEntity) || weaponEntity == -1) {
		return false;
	}
	
	char weaponClass[64];
	GetEdictClassname(weaponEntity, weaponClass, sizeof(weaponClass));
	
	return StrContains(weaponClass, "weapon_") == 0;
}

stock void FirstCharUpper(char[] string)
{
	if (strlen(string) > 0)
	{
		string[0] = CharToUpper(string[0]);
	}
}

stock int GetTotalKnifeStatTrakCount(int client)
{
	int count = 0;
	for (int i = 0; i < sizeof(g_WeaponClasses); i++)
	{
		if (IsKnifeClass(g_WeaponClasses[i]))
		{
			count += g_iStatTrakCount[client][i];
		}
	}
	return count;
}

stock int GetRemainingGracePeriodSeconds(int client)
{
	if(g_iGracePeriod == 0 || g_iRoundStartTime == 0 || (IsClientInGame(client) && !IsPlayerAlive(client)))
	{
		return MENU_TIME_FOREVER;
	}
	else
	{
		int remaining = g_iRoundStartTime + g_iGracePeriod - GetTime();
		return remaining > 0 ? remaining : -1;
	}
}
