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

char g_WeaponClasses[][] = {
/* 0*/ "weapon_awp", /* 1*/ "weapon_ak47", /* 2*/ "weapon_m4a1", /* 3*/ "weapon_m4a1_silencer", /* 4*/ "weapon_deagle", /* 5*/ "weapon_usp_silencer", /* 6*/ "weapon_hkp2000", /* 7*/ "weapon_glock", /* 8*/ "weapon_elite", 
/* 9*/ "weapon_p250", /*10*/ "weapon_cz75a", /*11*/ "weapon_fiveseven", /*12*/ "weapon_tec9", /*13*/ "weapon_revolver", /*14*/ "weapon_nova", /*15*/ "weapon_xm1014", /*16*/ "weapon_mag7", /*17*/ "weapon_sawedoff", 
/*18*/ "weapon_m249", /*19*/ "weapon_negev", /*20*/ "weapon_mp9", /*21*/ "weapon_mac10", /*22*/ "weapon_mp7", /*23*/ "weapon_ump45", /*24*/ "weapon_p90", /*25*/ "weapon_bizon", /*26*/ "weapon_famas", /*27*/ "weapon_galilar", 
/*28*/ "weapon_ssg08", /*29*/ "weapon_aug", /*30*/ "weapon_sg556", /*31*/ "weapon_scar20", /*32*/ "weapon_g3sg1", /*33*/ "weapon_knife_karambit", /*34*/ "weapon_knife_m9_bayonet", /*35*/ "weapon_bayonet", 
/*36*/ "weapon_knife_survival_bowie", /*37*/ "weapon_knife_butterfly", /*38*/ "weapon_knife_flip", /*39*/ "weapon_knife_push", /*40*/ "weapon_knife_tactical", /*41*/ "weapon_knife_falchion", /*42*/ "weapon_knife_gut",
/*43*/ "weapon_knife_ursus", /*44*/ "weapon_knife_gypsy_jackknife", /*45*/ "weapon_knife_stiletto", /*46*/ "weapon_knife_widowmaker", /*47*/ "weapon_mp5sd", /*48*/ "weapon_knife_css", /*49*/ "weapon_knife_cord", 
/*50*/ "weapon_knife_canis", /*51*/ "weapon_knife_outdoor", /*52*/ "weapon_knife_skeleton"
};

int g_iWeaponDefIndex[] = {
/* 0*/ 9, /* 1*/ 7, /* 2*/ 16, /* 3*/ 60, /* 4*/ 1, /* 5*/ 61, /* 6*/ 32, /* 7*/ 4, /* 8*/ 2, 
/* 9*/ 36, /*10*/ 63, /*11*/ 3, /*12*/ 30, /*13*/ 64, /*14*/ 35, /*15*/ 25, /*16*/ 27, /*17*/ 29, 
/*18*/ 14, /*19*/ 28, /*20*/ 34, /*21*/ 17, /*22*/ 33, /*23*/ 24, /*24*/ 19, /*25*/ 26, /*26*/ 10, /*27*/ 13, 
/*28*/ 40, /*29*/ 8, /*30*/ 39, /*31*/ 38, /*32*/ 11, /*33*/ 507, /*34*/ 508, /*35*/ 500, 
/*36*/ 514, /*37*/ 515, /*38*/ 505, /*39*/ 516, /*40*/ 509, /*41*/ 512, /*42*/ 506,
/*43*/ 519, /*44*/ 520, /*45*/ 522, /*46*/ 523, /*47*/ 23, /*48*/ 503, /*49*/ 517,
/*50*/ 518, /*51*/ 521, /*52*/ 525
};

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

ConVar g_Cvar_KnifeStatTrakMode;
int g_iKnifeStatTrakMode;

ConVar g_Cvar_EnableFloat;
bool g_bEnableFloat;

ConVar g_Cvar_EnableNameTag;
bool g_bEnableNameTag;

ConVar g_Cvar_EnableStatTrak;
bool g_bEnableStatTrak;

ConVar g_Cvar_EnableSeed;
bool g_bEnableSeed;

ConVar g_Cvar_EnableWeaponOverwrite;
bool g_bOverwriteEnabled;

ConVar g_Cvar_GracePeriod;
int g_iGracePeriod;

ConVar g_Cvar_InactiveDays;
int g_iGraceInactiveDays;

int g_iSkins[MAXPLAYERS+1][sizeof(g_WeaponClasses)];
int g_iStatTrak[MAXPLAYERS+1][sizeof(g_WeaponClasses)];
int g_iStatTrakCount[MAXPLAYERS+1][sizeof(g_WeaponClasses)];
int g_iWeaponSeed[MAXPLAYERS+1][sizeof(g_WeaponClasses)];
char g_NameTag[MAXPLAYERS+1][sizeof(g_WeaponClasses)][128];
float g_fFloatValue[MAXPLAYERS+1][sizeof(g_WeaponClasses)];

int g_iIndex[MAXPLAYERS+1] = { 0, ... };
Handle g_FloatTimer[MAXPLAYERS+1] = { INVALID_HANDLE, ... };

bool g_bWaitingForNametag[MAXPLAYERS+1] = { false, ... };
bool g_bWaitingForSeed[MAXPLAYERS+1] = { false, ... };
int g_iSeedRandom[MAXPLAYERS+1][sizeof(g_WeaponClasses)];

int g_iKnife[MAXPLAYERS+1] = { 0, ... };

int g_iRoundStartTime = 0;

int g_iDatabaseState = 0;
int g_iMigrationStep = 0;
char g_MigrationWeapons[][] = {
	"knife_ursus",
	"knife_gypsy_jackknife",
	"knife_stiletto",
	"knife_widowmaker",
	"mp5sd",
	"knife_css",
	"knife_cord",
	"knife_canis",
	"knife_outdoor",
	"knife_skeleton"
};

char g_Language[MAX_LANG][32];
int g_iClientLanguage[MAXPLAYERS+1];
Menu menuWeapons[MAX_LANG][sizeof(g_WeaponClasses)];

StringMap g_smWeaponIndex;
StringMap g_smWeaponDefIndex;
StringMap g_smLanguageIndex;

GlobalForward g_hOnKnifeSelect_Pre;
GlobalForward g_hOnKnifeSelect_Post;