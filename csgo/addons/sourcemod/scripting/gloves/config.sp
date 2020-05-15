/*  CS:GO Gloves SourceMod Plugin
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

public void ReadConfig()
{
	if(g_smGlovesGroupIndex != null) delete g_smGlovesGroupIndex;
	g_smGlovesGroupIndex = new StringMap();
	if(g_smLanguageIndex != null) delete g_smLanguageIndex;
	g_smLanguageIndex = new StringMap();
	
	int langCount = GetLanguageCount();
	int langCounter = 0;
	for (int i = 0; i < langCount; i++)
	{
		char code[4];
		char language[32];
		GetLanguageInfo(i, code, sizeof(code), language, sizeof(language));
		
		BuildPath(Path_SM, configPath, sizeof(configPath), "configs/gloves/gloves_%s.cfg", language);
		
		if(!FileExists(configPath)) continue;
		
		g_smLanguageIndex.SetValue(language, langCounter);
		FirstCharUpper(language);
		strcopy(g_Language[langCounter], 32, language);
		
		KeyValues kv = CreateKeyValues("Gloves");
		FileToKeyValues(kv, configPath);
		
		if (!KvGotoFirstSubKey(kv))
		{
			SetFailState("CFG File not found: %s", configPath);
			CloseHandle(kv);
		}
		
		for (int k = CS_TEAM_T; k <= CS_TEAM_CT; k++)
		{
			if(menuGlovesGroup[langCounter][k] != null)
			{
				delete menuGlovesGroup[langCounter][k];
			}
			menuGlovesGroup[langCounter][k] = new Menu(GloveMainMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_DisplayItem);
			menuGlovesGroup[langCounter][k].SetTitle("%T", "GloveMenuTitle", LANG_SERVER);
			menuGlovesGroup[langCounter][k].AddItem("0", "Default");
			menuGlovesGroup[langCounter][k].AddItem("-1", "Random");
			menuGlovesGroup[langCounter][k].ExitBackButton = true;
		}
		
		int counter = 1;
		do {
			char name[64];
			char index[10];
			char group[10];
			char team[32];
			char temp[1];
			char buffer[20];
			
			KvGetSectionName(kv, name, sizeof(name));
			KvGetString(kv, "index", group, sizeof(group));
			g_smGlovesGroupIndex.SetValue(group, counter);
			KvGotoFirstSubKey(kv);
			for (int k = CS_TEAM_T; k <= CS_TEAM_CT; k++)
			{
				IntToString(counter, index, sizeof(index));
				menuGlovesGroup[langCounter][k].AddItem(index, name);
				
				if(menuGloves[langCounter][k][counter] != null)
				{
					delete menuGloves[langCounter][k][counter];
				}
				menuGloves[langCounter][k][counter] = new Menu(GloveMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_DisplayItem);
				menuGloves[langCounter][k][counter].SetTitle(name);
				Format(buffer, sizeof(buffer), "%s;-1", group);
				menuGloves[langCounter][k][counter].AddItem(buffer, "Random");
				
				menuGloves[langCounter][k][counter].ExitBackButton = true;
			}
			do {
				KvGetSectionName(kv, name, sizeof(name));
				KvGetString(kv, "index", index, sizeof(index));
				KvGetString(kv, "team", team, sizeof(team));
				for (int k = CS_TEAM_T; k <= CS_TEAM_CT; k++)
				{
					IntToString(k, temp, sizeof(temp));
					
					if(StrContains(team, temp) > -1)
					{
						Format(buffer, sizeof(buffer), "%s;%s", group, index);
						menuGloves[langCounter][k][counter].AddItem(buffer, name);
					}
				}
			} while (KvGotoNextKey(kv));
			KvGoBack(kv);
			counter++;
		} while (KvGotoNextKey(kv));
		
		CloseHandle(kv);
		
		langCounter++;
	}
	
	if(langCounter == 0)
	{
		SetFailState("Could not find a config file for any languages.");
	}
}
