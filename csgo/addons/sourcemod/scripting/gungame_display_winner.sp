#pragma semicolon 1

#include <sourcemod>
#include <gungame_const>
#include <gungame>
#include <gungame_stats>
#include <gungame_config>
#include <url>

new String:g_looserName[MAXPLAYERS+1][MAX_NAME_SIZE];
new String:g_winnerName[MAX_NAME_SIZE];
new bool:g_showWinnerOnRankUpdate = false;
new g_winner;

new State:ConfigState;
new g_Cfg_DisplayWinnerMotd = 0;
new String:g_Cfg_DisplayWinnerUrl[256];
new g_Cfg_ShowPlayerRankOnWin = 1;

public Plugin:myinfo =
{
    name = "GunGame:SM Display Winner",
    description = "Shows a MOTD window with the winner's information when the game is won.",
    author = "bl4nk, Otstrel.ru Team",
    version = GUNGAME_VERSION,
    url = "http://forums.alliedmods.net, http://otstrel.ru"
};

public OnPluginStart()
{
    HookEvent("player_death", Event_PlayerDeath);
}

public Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
    if ( !g_Cfg_DisplayWinnerMotd )
    {
        return;
    }
    new victim = GetClientOfUserId(GetEventInt(event, "userid"));
    new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
    GetClientName(victim, g_looserName[attacker], sizeof(g_looserName[]));
}

public GG_OnWinner(client, const String:weapon[], victim)
{
    if ( ( !g_Cfg_DisplayWinnerMotd && !g_Cfg_ShowPlayerRankOnWin ) || IsFakeClient(client) )
    {
        return;
    }
    GetClientName(client, g_winnerName, sizeof(g_winnerName));
    g_showWinnerOnRankUpdate = true;
    g_winner = client;
}

public GG_OnLoadRank()
{
    if ( ( !g_Cfg_DisplayWinnerMotd && !g_Cfg_ShowPlayerRankOnWin ) || !g_showWinnerOnRankUpdate )
    {
        return;
    }
    g_showWinnerOnRankUpdate = false;

    if ( !IsClientInGame(g_winner) )
    {
        return;
    }
    
    if ( g_Cfg_ShowPlayerRankOnWin && IsClientInGame(g_winner) )
    {
        GG_ShowRank(g_winner);                  /* HINT: gungame_stats */
    }
    if ( g_Cfg_DisplayWinnerMotd )
    {
        decl String:url[128+sizeof(g_Cfg_DisplayWinnerUrl)];
        decl String:winnerNameUrlEncoded[sizeof(g_winnerName)*3+1];
        decl String:looserNameUrlEncoded[sizeof(g_looserName[])*3+1];
        url_encode(g_winnerName, sizeof(g_winnerName), winnerNameUrlEncoded, sizeof(winnerNameUrlEncoded));
        url_encode(g_looserName[g_winner], sizeof(g_looserName[]), looserNameUrlEncoded, sizeof(looserNameUrlEncoded));

        new bool:urlHasParams = (StrContains(g_Cfg_DisplayWinnerUrl, "?", true) != -1);

        Format(url, sizeof(url), "%s%swinnerName=%s&loserName=%s&wins=%i&place=%i&totalPlaces=%i", 
            g_Cfg_DisplayWinnerUrl, 
            urlHasParams? "&": "?",
            winnerNameUrlEncoded, 
            looserNameUrlEncoded, 
            GG_GetClientWins(g_winner),         /* HINT: gungame_stats */
            GG_GetPlayerPlaceInStat(g_winner),  /* HINT: gungame_stats */
            GG_CountPlayersInStat()             /* HINT: gungame_stats */
        );
        for ( new i = 1; i <= MaxClients; i++ )
        {
            if ( IsClientInGame(i) )
            {
                ShowMOTDPanel(i, "", url, MOTDPANEL_TYPE_URL);
            }
        }
    }
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
        if ( strcmp("DisplayWinnerMotd", key, false) == 0 ) {
            g_Cfg_DisplayWinnerMotd = StringToInt(value);
        } else if ( strcmp("DisplayWinnerUrl", key, false) == 0 ) {
            strcopy(g_Cfg_DisplayWinnerUrl, sizeof(g_Cfg_DisplayWinnerUrl), value);
        } else if ( strcmp("ShowPlayerRankOnWin", key, false) == 0 ) {
            g_Cfg_ShowPlayerRankOnWin = StringToInt(value);
        }
    }
}

public GG_ConfigParseEnd()
{
    ConfigState = CONFIG_STATE_NONE;
}

public OnMapEnd()
{
    g_showWinnerOnRankUpdate = false;
}

