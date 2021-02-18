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

const int MAX_LANG = 40;

Database db = null;

char configPath[PLATFORM_MAX_PATH];

ConVar g_Cvar_DBConnection;
char g_DBConnection[32];
char g_DBConnectionOld[32];

ConVar g_Cvar_TablePrefix;
char g_TablePrefix[10];

ConVar g_Cvar_ChatPrefix;
char g_ChatPrefix[32];

ConVar g_Cvar_FloatIncrementSize;
float g_fFloatIncrementSize;
int g_iFloatIncrementPercentage;

ConVar g_Cvar_EnableFloat;
int g_iEnableFloat;

ConVar g_Cvar_EnableWorldModel;
int g_iEnableWorldModel;

int g_iGroup[MAXPLAYERS+1][4];
int g_iGloves[MAXPLAYERS+1][4];
float g_fFloatValue[MAXPLAYERS+1][4];
char g_CustomArms[MAXPLAYERS+1][4][256];
int g_iTeam[MAXPLAYERS+1] = { 0, ... };
Handle g_FloatTimer[MAXPLAYERS+1] = { INVALID_HANDLE, ... };
int g_iSteam32[MAXPLAYERS+1] = { 0, ... };

char g_Language[MAX_LANG][32];
int g_iClientLanguage[MAXPLAYERS+1];
Menu menuGlovesGroup[MAX_LANG][4];
Menu menuGloves[MAX_LANG][4][9];

StringMap g_smGlovesGroupIndex;
StringMap g_smLanguageIndex;
