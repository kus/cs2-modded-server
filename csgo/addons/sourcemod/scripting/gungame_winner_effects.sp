#pragma semicolon 1

/*----------------------------------------------------------------------+
| INÑLUDES                                                              |
+----------------------------------------------------------------------*/
#include <sourcemod>
#include <sdktools>
#include <gungame_const>
#include <gungame_config>
#include "gungame/stock.sp"

/*----------------------------------------------------------------------+
| PLUGIN INFO                                                           |
+----------------------------------------------------------------------*/
public Plugin:myinfo = {
    name        = "GunGame:SM Winner Effects",
    author      = GUNGAME_AUTHOR,
    description = "Show winner effects on gungame win",
    version     = GUNGAME_VERSION,
    url         = GUNGAME_URL
};

/*----------------------------------------------------------------------+
| INIT VARS                                                             |
+----------------------------------------------------------------------*/
#define SPRITE_CSGO     "sprites/ledglow.vmt"
#define SPRITE_CSS      "sprites/orangeglow1.vmt"

new State:g_ConfigState     = CONFIG_STATE_NONE;
new g_Cfg_WinnerEffect      = 0;
new g_GlowSprite            = -1;
new GameName:g_GameName     = GameName:None;
new g_winner                = 0;

/*----------------------------------------------------------------------+
| LOAD CONFIG                                                           |
+----------------------------------------------------------------------*/
public GG_ConfigNewSection(const String:NewSection[]) {
    if (strcmp(NewSection, "Config", false) == 0) {
        g_ConfigState = CONFIG_STATE_CONFIG;
    }
}

public GG_ConfigKeyValue(const String:key[], const String:value[]) {
    if (g_ConfigState == CONFIG_STATE_CONFIG) {
        if  (strcmp("WinnerEffect", key, false) == 0) {
            g_Cfg_WinnerEffect = StringToInt(value);
        }
    }
}

public GG_ConfigParseEnd() {
    g_ConfigState = CONFIG_STATE_NONE;
}

/*----------------------------------------------------------------------+
| PUBLIC EVENTS                                                         |
+----------------------------------------------------------------------*/
public OnMapStart() {
    g_winner = 0;

    if (g_GameName == GameName:Csgo) {
        g_GlowSprite = PrecacheModel(SPRITE_CSGO);
    } else {
        g_GlowSprite = PrecacheModel(SPRITE_CSS);
    }
}

public OnPluginStart() {
    g_GameName = DetectGame();
    if (g_GameName == GameName:None) {
        SetFailState("ERROR: Unsupported game. Please contact the author.");
    }

    HookEvent("player_spawn", Event_PlayerSpawn);
}

public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast) {
    if (!g_Cfg_WinnerEffect) {
        return;
    }

    if (!g_winner) {
        return;
    }

    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    if (!client) {
        return;
    }

    WinnerEffectsStartOne(g_winner, client);
}

/*----------------------------------------------------------------------+
| GUNGAME EVENTS                                                        |
+----------------------------------------------------------------------*/
public GG_OnStartup(bool:Command) {
    if (!g_Cfg_WinnerEffect) {
        return;
    }

    g_winner = 0;
}

public GG_OnWinner(client, const String:Weapon[], victim) {
    if (!g_Cfg_WinnerEffect) {
        return;
    }

    g_winner = client;
    WinnerEffectsStart(client);
}

/*----------------------------------------------------------------------+
| WINNER EFFECTS                                                        |
+----------------------------------------------------------------------*/
WinnerEffectsStart(winner) {
    if (g_Cfg_WinnerEffect == 1) {
        WinnerEffect(winner);
    }
}

WinnerEffectsStartOne(winner, client) {
    if (g_Cfg_WinnerEffect == 1) {
        WinnerEffectOne(winner, client);
    }
}

WinnerEffect(winner) {
    for (new i=1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && IsPlayerAlive(i)) {
            WinnerEffectOne(winner, i);
        }
    }
}

WinnerEffectOne(winner, client) {
    SetPlayerWinnerEffectAll(client);
    if (winner==client) {
        SetPlayerWinnerEffectWinner(client);
    }
}

SetPlayerWinnerEffectAll(client) {
    // fly
    SetEntityGravity(client, 0.001);

    SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);

    new Float:pos[3], Float:vel[3];
    GetClientEyePosition(client, pos);

    vel[0] = GetRandomFloat(-10.0, 10.0);
    vel[1] = GetRandomFloat(-10.0, 10.0);
    vel[2] = GetRandomFloat(70.0, 120.0);

    TeleportEntity(client, pos, NULL_VECTOR, vel);
}

SetPlayerWinnerEffectWinner(client) {
    //CreateLight(client);
    SetPlayerWinnerEffectWinnerRepeate(client);
}

SetPlayerWinnerEffectWinnerRepeate(client) {
    CreateTimer(0.1, Timer_SetPlayerWinnerEffectWinner, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action:Timer_SetPlayerWinnerEffectWinner(Handle:timer, any:data) {
    if (!IsClientInGame(data)||!IsPlayerAlive(data)) {
        return Plugin_Stop;
    }
    SetPlayerWinnerEffectWinnerReal(data);
    return Plugin_Continue;
}

SetPlayerWinnerEffectWinnerReal(client) {
    // shine    
    new Float:vec[3];
    GetClientAbsOrigin(client, vec);
    vec[2] += 40;

    TE_SetupGlowSprite(vec, g_GlowSprite, 0.5, 4.0, 70);
    TE_SendToAll();
}

// TODO: test it
stock CreateLight(client) {
    new Float:clientposition[3];
    GetClientAbsOrigin(client, clientposition);
    clientposition[2] += 40.0;

    new GLOW_ENTITY = CreateEntityByName("env_glow");

    SetEntProp(GLOW_ENTITY, Prop_Data, "m_nBrightness", 70, 4);

    //new String:model[100];
    //FormatEx(model, sizeof(model), "materials/%s", g_GameName == GameName:Csgo?SPRITE_CSGO:SPRITE_CSS);
    //DispatchKeyValue(GLOW_ENTITY, "model", model);
    DispatchKeyValue(GLOW_ENTITY, "model", g_GameName == GameName:Csgo?SPRITE_CSGO:SPRITE_CSS);

    DispatchKeyValue(GLOW_ENTITY, "rendermode", "3");
    DispatchKeyValue(GLOW_ENTITY, "renderfx", "14");
    DispatchKeyValue(GLOW_ENTITY, "scale", "4.0");
    DispatchKeyValue(GLOW_ENTITY, "renderamt", "255");
    DispatchKeyValue(GLOW_ENTITY, "rendercolor", "255 255 255 255");
    DispatchSpawn(GLOW_ENTITY);
    AcceptEntityInput(GLOW_ENTITY, "ShowSprite");
    TeleportEntity(GLOW_ENTITY, clientposition, NULL_VECTOR, NULL_VECTOR);

    new String:target[20];
    FormatEx(target, sizeof(target), "glowclient_%d", client);
    DispatchKeyValue(client, "targetname", target);
    SetVariantString(target);
    AcceptEntityInput(GLOW_ENTITY, "SetParent");
    AcceptEntityInput(GLOW_ENTITY, "TurnOn");
}    
