#pragma semicolon 1

#include <sourcemod>
#include <gungame_const>
#include <gungame>
#include <gungame_config>
#include <colors>

new State:ConfigState;
new bool:g_Cfg_AllowUpByKnifeBot;
new bool:g_Cfg_AllowUpByExplodeBot;
new bool:g_Cfg_AllowUpByKnifeBotNoH;
new bool:g_Cfg_AllowUpByExplodeBotNoH;

public Plugin:myinfo =
{
    name = "GunGame:SM Bot Protection",
    author = GUNGAME_AUTHOR,
    description = "Does not allow players to win on bots",
    version = GUNGAME_VERSION,
    url = GUNGAME_URL
};

public OnPluginStart()
{
    LoadTranslations("gungame_bot");
}

public Action:GG_OnClientDeath(Killer, Victim, WeaponId, bool:TeamKilled)
{
    if ( TeamKilled || !IsFakeClient(Victim) || IsFakeClient(Killer) ) {
        return Plugin_Continue;
    }

    if (GG_IsWeaponKnife(WeaponId)) {
        if ( g_Cfg_AllowUpByKnifeBot ) {
            return Plugin_Continue;
        }

        if ( g_Cfg_AllowUpByKnifeBotNoH ) {
            if ( IsThereAnyHuman() ) {
                CPrintToChat(Killer, "%t", "You can not level up on bot with knife if there is other human");
                return Plugin_Handled;
            } else {
                return Plugin_Continue;
            }
        }

        CPrintToChat(Killer, "%t", "You can not level up on bot with knife");
        return Plugin_Handled;
    } else if ( WeaponId == GG_GetWeaponIdHegrenade() ) {
        if ( g_Cfg_AllowUpByExplodeBot ) {
            return Plugin_Continue;
        }

        if ( g_Cfg_AllowUpByExplodeBotNoH ) {
            if ( IsThereAnyHuman() ) {
                CPrintToChat(Killer, "%t", "You can not level up on bot with hegrenade if there is other human");
                return Plugin_Handled;
            } else {
                return Plugin_Continue;
            }
        }

        CPrintToChat(Killer, "%t", "You can not level up on bot with hegrenade");
        return Plugin_Handled;
    }

    return Plugin_Continue;
}

public GG_ConfigNewSection(const String:name[])
{
    if ( strcmp("Config", name, false) == 0 )
    {
        ConfigState = CONFIG_STATE_CONFIG;
    }
}

public GG_ConfigKeyValue(const String:key[], const String:value[])
{
    if ( ConfigState == CONFIG_STATE_CONFIG )
    {
        if ( strcmp("AllowLevelUpByKnifeBot", key, false) == 0 ) {
            g_Cfg_AllowUpByKnifeBot = bool:StringToInt(value);
        } else if ( strcmp("AllowLevelUpByExplodeBot", key, false) == 0 ) {
            g_Cfg_AllowUpByExplodeBot = bool:StringToInt(value);
        } else if ( strcmp("AllowLevelUpByKnifeBotIfNoHuman", key, false) == 0 ) {
            g_Cfg_AllowUpByKnifeBotNoH = bool:StringToInt(value);
        } else if ( strcmp("AllowLevelUpByExplodeBotIfNoHuman", key, false) == 0 ) {
            g_Cfg_AllowUpByExplodeBotNoH = bool:StringToInt(value);
        }

    }
}

public GG_ConfigParseEnd()
{
    ConfigState = CONFIG_STATE_NONE;
}

bool:IsThereAnyHuman() {
    new humans = 0;
    new team;
    for (new i = 1; i < MaxClients; i++) {
        if ( IsClientInGame(i) && !IsFakeClient(i) ) {
            team = GetClientTeam(i);
            if ( team == TEAM_T || team == TEAM_CT ) {
                humans++;
                if ( humans > 1 ) {
                    return true;
                }
            }
        }
    }
    return humans > 1;
}
