/**
 * =============================================================================
 * Left 4 Dead Stocks Library (C)2011-2012 Buster "Mr. Zero" Nielsen
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it 
 * under the terms of the GNU General Public License, version 3.0, as 
 * published by the Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along 
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2,"
 * the "Source Engine," the "SourcePawn JIT," and any Game MODs that run on 
 * software by the Valve Corporation.  You must obey the GNU General Public
 * License in all respects for all other code used.  Additionally, 
 * AlliedModders LLC grants this exception to all derivative works.  
 * AlliedModders LLC defines further exceptions, found in LICENSE.txt 
 * (as of this writing, version JULY-31-2007), or 
 * <http://www.sourcemod.net/license.php>.
 */

#if defined _l4d_stocks_included
 #endinput
#endif
#define _l4d_stocks_included

#include <sdktools>
#include <l4d_weapon_stocks>

/* Spawn state bit flags */
#define L4D_SPAWNFLAG_CANSPAWN          (0 << 0)
#define L4D_SPAWNFLAG_DISABLED          (1 << 0)
#define L4D_SPAWNFLAG_WAITFORSURVIVORS  (1 << 1)
#define L4D_SPAWNFLAG_WAITFORFINALE     (1 << 2)
#define L4D_SPAWNFLAG_WAITFORTANKTODIE  (1 << 3)
#define L4D_SPAWNFLAG_SURVIVORESCAPED   (1 << 4)
#define L4D_SPAWNFLAG_DIRECTORTIMEOUT   (1 << 5)
#define L4D_SPAWNFLAG_WAITFORNEXTWAVE   (1 << 6)
#define L4D_SPAWNFLAG_CANBESEEN         (1 << 7)
#define L4D_SPAWNFLAG_TOOCLOSE          (1 << 8)
#define L4D_SPAWNFLAG_RESTRICTEDAREA    (1 << 9)
#define L4D_SPAWNFLAG_BLOCKED           (1 << 10)

/* Weapon upgrade bit flags */
#define L4D2_WEPUPGFLAG_NONE            (0 << 0)
#define L4D2_WEPUPGFLAG_INCENDIARY      (1 << 0)
#define L4D2_WEPUPGFLAG_EXPLOSIVE       (1 << 1)
#define L4D2_WEPUPGFLAG_LASER           (1 << 2)

/* Instructor Hint bit flags */
#define L4D2_IHFLAG_NONE                (0 << 0)
#define L4D2_IHFLAG_PULSE_SLOW          (1 << 0)
#define L4D2_IHFLAG_PULSE_FAST          (1 << 1)
#define L4D2_IHFLAG_PULSE_URGENT        (1 << 2)
#define L4D2_IHFLAG_ALPHA_SLOW          (1 << 3)
#define L4D2_IHFLAG_ALPHA_FAST          (1 << 4)
#define L4D2_IHFLAG_ALPHA_URGENT        (1 << 5)
#define L4D2_IHFLAG_SHAKE_NARROW        (1 << 6)
#define L4D2_IHFLAG_SHAKE_WIDE          (1 << 7)
#define L4D2_IHFLAG_STATIC              (1 << 8)

/* Survivor intensity -- Equal or less */
#define L4D_SURVIVORINTENSITY_MILD      0.25
#define L4D_SURVIVORINTENSITY_MODERATE  0.50
#define L4D_SURVIVORINTENSITY_HIGH      0.75
#define L4D_SURVIVORINTENSITY_EXTREME   1.00

enum L4DTeam
{
    L4DTeam_Unassigned              = 0,
    L4DTeam_Spectator               = 1,
    L4DTeam_Survivor                = 2,
    L4DTeam_Infected                = 3
}

enum L4DWeaponSlot
{
    L4DWeaponSlot_Primary           = 0,
    L4DWeaponSlot_Secondary         = 1,
    L4DWeaponSlot_Grenade           = 2,
    L4DWeaponSlot_FirstAid          = 3,
    L4DWeaponSlot_Pills             = 4
}

enum L4D2GlowType
{
    L4D2Glow_None                   = 0,
    L4D2Glow_OnUse                  = 1,
    L4D2Glow_OnLookAt               = 2,
    L4D2Glow_Constant               = 3
}

enum L4D1ZombieClassType
{
    L4D1ZombieClass_Smoker          = 1,
    L4D1ZombieClass_Boomer          = 2,
    L4D1ZombieClass_Hunter          = 3,
    L4D1ZombieClass_Witch           = 4,
    L4D1ZombieClass_Tank            = 5,
    L4D1ZombieClass_NotInfected     = 6
}

enum L4D2ZombieClassType
{
    L4D2ZombieClass_Smoker          = 1,
    L4D2ZombieClass_Boomer          = 2,
    L4D2ZombieClass_Hunter          = 3,
    L4D2ZombieClass_Spitter         = 4,
    L4D2ZombieClass_Jockey          = 5,
    L4D2ZombieClass_Charger         = 6,
    L4D2ZombieClass_Witch           = 7,
    L4D2ZombieClass_Tank            = 8,
    L4D2ZombieClass_NotInfected     = 9
}

enum L4D2UseAction
{
    L4D2UseAction_None              = 0, // No use action active
    L4D2UseAction_Healing           = 1, // Includes healing yourself or a teammate.
    L4D2UseAction_Defibing          = 4, // When defib'ing a dead body.
    L4D2UseAction_GettingDefibed    = 5, // When comming back to life from a dead body.
    L4D2UseAction_PouringGas        = 8, // Pouring gas into a generator
    L4D2UseAction_Cola              = 9, // For Dead Center map 2 cola event, when handing over the cola to whitalker.
    L4D2UseAction_Button            = 10 // Such as buttons, timed buttons, generators, etc.
    /* List is not fully done, these are just the ones I have found so far */
}

enum L4DResourceType
{
    L4DResource_Ping,
    L4DResource_Score,
    L4DResource_TankTickets,
    L4DResource_Deaths,
    L4DResource_MaxHealth,
    L4DResource_WantsToPlay,
    L4DResource_TankTickets2
}

static const String:L4DResourceName[L4DResourceType][] =
{
    "m_iPing",
    "m_iScore",
    "m_iTankTickets",
    "m_iDeaths",
    "m_maxHealth",
    "m_wantsToPlay",
    "m_tankTickets"
};

/**
 * Returns zombie player L4D1 zombie class.
 *
 * @param client        Player's index.
 * @return              Current L4D1ZombieClassTypes of player.
 * @error               Invalid client index.
 */
stock L4D1ZombieClassTypes:L4D1_GetPlayerZombieClass(client)
{
    return L4D1ZombieClassType:GetEntProp(client, Prop_Send, "m_zombieClass");
}

/**
 * Set zombie player L4D1 zombie class.
 *
 * @param client        Player's index.
 * @param class         L4D1ZombieClassTypes class symbol.
 * @noreturn
 * @error               Invalid client index.
 */
stock L4D1_SetPlayerZombieClass(client, L4D1ZombieClassTypes:class)
{
    SetEntProp(client, Prop_Send, "m_zombieClass", _:class);
}

/**
 * Returns zombie player L4D2 zombie class.
 *
 * @param client        Player's index.
 * @return              Current L4D2ZombieClassTypes of player.
 * @error               Invalid client index.
 */
stock L4D2ZombieClassType:L4D2_GetPlayerZombieClass(client)
{
    return L4D2ZombieClassType:GetEntProp(client, Prop_Send, "m_zombieClass");
}

/**
 * Set zombie player L4D2 zombie class.
 *
 * @param client        Player's index.
 * @param class         L4D2ZombieClassTypes class symbol.
 * @noreturn
 * @error               Invalid client index.
 */
stock L4D2_SetPlayerZombieClass(client, L4D2ZombieClassType:class)
{
    SetEntProp(client, Prop_Send, "m_zombieClass", _:class);
}

/**
 * Returns ghost state of zombie player.
 *
 * @param client        Player index.
 * @return              True if player is ghost, false otherwise.
 * @error               Invalid client index.
 */
stock bool:L4D_IsPlayerGhost(client)
{
    return bool:GetEntProp(client, Prop_Send, "m_isGhost", 1);
}

/**
 * Sets ghost state of zombie player.
 *
 * @param client        Player index.
 * @param isGhost       Sets ghost status.
 * @noreturn
 * @error               Invalid client index.
 */
stock L4D_SetPlayerGhostState(client, bool:isGhost)
{
    SetEntProp(client, Prop_Send, "m_isGhost", isGhost, 1);
}

/**
 * Returns ghost spawn state of zombie player.
 *
 * @param client        Player index.
 * @return              Player's spawn state bits.
 * @error               Invalid client index.
 */
stock L4D_GetPlayerGhostSpawnState(client)
{
    return GetEntProp(client, Prop_Send, "m_ghostSpawnState");
}

/**
 * Set zombie player's ghost spawn state bits.
 *
 * Note: The game updates spawn state bits every frame.
 *
 * @param client        Player index.
 * @param bits          Ghost spawn state bits.
 * @noreturn
 * @error               Invalid client index.
 */
stock L4D_SetPlayerGhostSpawnState(client, bits)
{
    SetEntProp(client, Prop_Send, "m_ghostSpawnState", bits);
}

/**
 * Returns whether zombie player is culling.
 *
 * @param client        Player index.
 * @return              True if player is culling, false otherwise.
 */
stock L4D_IsPlayerCulling(client)
{
    return bool:GetEntProp(client, Prop_Send, "m_isCulling", 1);
}

/**
 * Set culling state of zombie player.
 *
 * @param client        Player index.
 * @param isCulling     Whether player is culling.
 * @noreturn
 * @error               Invalid client index.
 */
stock L4D_SetPlayerCullingState(client, bool:isCulling)
{
    SetEntProp(client, Prop_Send, "m_isCulling", isCulling, 1);
}

/**
 * Returns whether player is incapacitated.
 *
 * Note: A tank player will return true when in dying animation.
 *
 * @param client        Player index.
 * @return              True if incapacitated, false otherwise.
 * @error               Invalid client index.
 */
stock bool:L4D_IsPlayerIncapacitated(client)
{
    return bool:GetEntProp(client, Prop_Send, "m_isIncapacitated", 1);
}

/**
 * Set player's incapacitated state.
 *
 * @param client        Player index.
 * @param isIncapacitated Whether the player is incapacitated.
 * @noreturn
 * @error               Invalid client index.
 */
stock L4D_SetPlayerIncapacitatedState(client, bool:isIncapacitated)
{
    SetEntProp(client, Prop_Send, "m_isIncapacitated", isIncapacitated, 1);
}

/**
 * Returns survivor player shove penalty.
 *
 * @param client        Player index.
 * @return              Current shove penalty of player.
 */
stock L4D_GetPlayerShovePenalty(client)
{
    return GetEntProp(client, Prop_Send, "m_iShovePenalty");
}

/**
 * Set survivor player shove penalty.
 *
 * @param client        Player index.
 * @param shovePenalty  Shove penalty.
 * @noreturn
 * @error               Invalid client index.
 */
stock L4D_SetPlayerShovePenalty(client, shovePenalty)
{
    SetEntProp(client, Prop_Send, "m_iShovePenalty", shovePenalty);
}

/**
 * Returns tank player's frustration.
 *
 * @param client        Player index.
 * @return              How frustrated tank player is.
 * @error               Invalid client index.
 */
stock L4D_GetTankFrustration(client)
{
    return GetEntProp(client, Prop_Send, "m_frustration");
}

/**
 * Set tank player's frustration.
 *
 * @param client        Player index.
 * @param frustration   How frustrated tank player is.
 * @noreturn
 * @error               Invalid client index.
 */
stock L4D_SetTankFrustration(client, frustration)
{
    SetEntProp(client, Prop_Send, "m_frustration", frustration);
}

/**
 * Returns whether survivor player is idle.
 *
 * @param               Player index.
 * @return              True if idle, false otherwise.
 */
stock bool:L4D_IsPlayerIdle(client)
{
    return L4D_GetBotOfIdlePlayer(client) > -1;
}

/**
 * Returns survivor bot of idle survivor player.
 *
 * @param client        Player index.
 * @return              Player index of the bot, -1 if not found.
 */
stock L4D_GetBotOfIdlePlayer(client)
{
    new idleClient;
    new offset;
    decl String:netclass[128];

    for (new bot = 1; bot <= MaxClients; bot++)
    {
        if (!IsClientInGame(bot) || 
            !IsFakeClient(bot) ||
            L4DTeam:GetClientTeam(bot) != L4DTeam_Survivor ||
            !IsPlayerAlive(bot) ||
            GetClientHealth(bot) < 1)
        {
            continue;
        }

        GetEntityNetClass(bot, netclass, 128);
        offset = FindSendPropInfo(netclass, "m_humanSpectatorUserID");

        if (offset < 1)
        {
            continue;
        }

        idleClient = GetClientOfUserId(GetEntProp(bot, Prop_Send, "m_humanSpectatorUserID"));

        if (idleClient == client)
        {
            return bot;
        }
    }

    return -1;
}

/**
 * Returns idle survivor player of survivor bot.
 *
 * @param bot           Player index of bot.
 * @return              Player index of idle client, 0 if not found.
 * @error               Invalid client index.
 */
stock L4D_GetIdlePlayerOfBot(bot)
{
    return GetClientOfUserId(GetEntProp(bot, Prop_Send, "m_humanSpectatorUserID"));
}

/**
 * Returns resource entity.
 *
 * @return              Entity index of resource entity, -1 if not found.
 */
stock L4D_GetResourceEntity()
{
    return FindEntityByClassname(-1, "terror_player_manager");
}

/**
 * Retrieves client data from the resource entity.
 *
 * @param client        Player's index.
 * @param type          ResourceType constant
 * @return              Value or -1 on failure.
 * @error               Invalid client index, client not in game or failed to find resource entity.
 */
stock L4D_GetPlayerResourceData(client, L4DResourceType:type)
{
    if (!IsClientConnected(client))
    {
        return -1;
    }

    new offset = FindSendPropInfo("CTerrorPlayerResource", L4DResourceName[type]);

    if (offset < 1)
    {
        return -1;
    }

    new entity = L4D_GetResourceEntity();

    if (entity == -1)
    {
        return -1;
    }

    return GetEntData(entity, offset + (client * 4));
}

/**
 * Sets client data in the resource entity.
 *
 * Note: The game overwrites these values every frame, so changing them will have very little effect.
 *
 * @param client        Player's index.
 * @param type          ResourceType constant
 * @param value         Value to set.
 * @return              Value or -1 on failure.
 * @error               Invalid client index, client not in game or failed to find resource entity.
 */
stock bool:L4D_SetPlayerResourceData(client, L4DResourceType:type, any:value)
{
    if (!IsClientConnected(client))
    {
        return false;
    }

    new offset = FindSendPropInfo("CTerrorPlayerResource", L4DResourceName[type]);

    if (offset < 1)
    {
        return false;
    }

    new entity = L4D_GetResourceEntity();

    if (entity == -1)
    {
        return false;
    }

    SetEntData(entity, offset + (client * 4), value);

    return true;
}

/**
 * Removes the weapon from a client's weapon slot
 *
 * @param client        Player's index.
 * @param slot          Slot index.
 * @noreturn
 * @error               Invalid client or lack of mod support.
 */
stock L4D_RemoveWeaponSlot(client, L4DWeaponSlot:slot)
{
    new weaponIndex;
    while ((weaponIndex = GetPlayerWeaponSlot(client, _:slot)) != -1)
    {
        RemovePlayerItem(client, weaponIndex);
        RemoveEdict(weaponIndex);
    }
}

/**
 * Removes all weapons from a client
 *
 * @param client        Player's index.
 * @noreturn
 * @error               Invalid client or lack of mod support.
 */
stock L4D_RemoveAllWeapons(client)
{
    for (new i = 0; i <= 4; i++)
    {
        L4D_RemoveWeaponSlot(client, L4DWeaponSlot:i);
    }
}

/**
 * Returns whether the finale is active.
 *
 * Note: Finales can also be on other maps than just the finale map. A perfect
 * example of this is the Swamp Fever map 1 crescendo event. This event is 
 * defined as a finale by Valve for some reason.
 *
 * @return              True if finale is active, false otherwise.
 */
stock bool:L4D_IsFinaleActive()
{
    new entity = L4D_GetResourceEntity();

    if (entity == -1)
    {
        return false;
    }

    return bool:GetEntProp(entity, Prop_Send, "m_isFinale", 1);
}

/**
 * Returns whether any survivor have left the safe area.
 *
 * @return              True if any survivor have left safe area, false 
 *                      otherwise.
 */
stock bool:L4D_HasAnySurvivorLeftSafeArea()
{
    new entity = L4D_GetResourceEntity();

    if (entity == -1)
    {
        return false;
    }

    return bool:GetEntProp(entity, Prop_Send, "m_hasAnySurvivorLeftSafeArea", 1);
}

/**
 * Returns pending tank player.
 *
 * @return              Player index of pending tank player, -1 if not found.
 */
stock L4D_GetPendingTankPlayer()
{
    new entity = L4D_GetResourceEntity();

    if (entity == -1)
    {
        return -1;
    }

    return GetEntProp(entity, Prop_Send, "m_pendingTankPlayerIndex");
}

/**
 * Set entity glow. This is consider safer and more robust over setting each glow
 * property on their own because glow offset will be check first.
 *
 * @param entity        Entity index.
 * @parma type          Glow type.
 * @param range         Glow max range, 0 for unlimited.
 * @param minRange      Glow min range.
 * @param colorOverride Glow color, RGB.
 * @param flashing      Whether the glow will be flashing.
 * @return              True if glow was set, false if entity does not support
 *                      glow.
 */
stock bool:L4D2_SetEntityGlow(entity, L4D2GlowType:type, range, minRange, colorOverride[3], bool:flashing)
{
    if (!IsValidEntity(entity))
    {
        return false;
    }

    decl String:netclass[128];
    GetEntityNetClass(entity, netclass, 128);

    new offset = FindSendPropInfo(netclass, "m_iGlowType");

    if (offset < 1)
    {
        return false;    
    }

    L4D2_SetEntityGlow_Type(entity, type);
    L4D2_SetEntityGlow_Range(entity, range);
    L4D2_SetEntityGlow_MinRange(entity, minRange);
    L4D2_SetEntityGlow_Color(entity, colorOverride);
    L4D2_SetEntityGlow_Flashing(entity, flashing);
    return true;
}

/**
 * Set entity glow type.
 *
 * @param entity        Entity index.
 * @parma type          Glow type.
 * @noreturn
 * @error               Invalid entity index or entity does not support glow.
 */
stock L4D2_SetEntityGlow_Type(entity, L4D2GlowType:type)
{
    SetEntProp(entity, Prop_Send, "m_iGlowType", _:type);
}

/**
 * Set entity glow range.
 *
 * @param entity        Entity index.
 * @parma range         Glow range.
 * @noreturn
 * @error               Invalid entity index or entity does not support glow.
 */
stock L4D2_SetEntityGlow_Range(entity, range)
{
    SetEntProp(entity, Prop_Send, "m_nGlowRange", range);
}

/**
 * Set entity glow min range.
 *
 * @param entity        Entity index.
 * @parma minRange      Glow min range.
 * @noreturn
 * @error               Invalid entity index or entity does not support glow.
 */
stock L4D2_SetEntityGlow_MinRange(entity, minRange)
{
    SetEntProp(entity, Prop_Send, "m_nGlowRangeMin", minRange);
}

/**
 * Set entity glow color.
 *
 * @param entity        Entity index.
 * @parma colorOverride Glow color, RGB.
 * @noreturn
 * @error               Invalid entity index or entity does not support glow.
 */
stock L4D2_SetEntityGlow_Color(entity, colorOverride[3])
{
    SetEntProp(entity, Prop_Send, "m_glowColorOverride", colorOverride[0] + (colorOverride[1] * 256) + (colorOverride[2] * 65536));
}

/**
 * Set entity glow flashing state.
 *
 * @param entity        Entity index.
 * @parma flashing      Whether glow will be flashing.
 * @noreturn
 * @error               Invalid entity index or entity does not support glow.
 */
stock L4D2_SetEntityGlow_Flashing(entity, bool:flashing)
{
    SetEntProp(entity, Prop_Send, "m_bFlashing", _:flashing);
}

/**
 * Returns entity glow type.
 *
 * @param entity        Entity index.
 * @return              L4D2 glow type.
 * @error               Invalid entity index or entity does not support glow.
 */
stock L4D2GlowType:L4D2_GetEntityGlow_Type(entity)
{
    return L4D2GlowType:GetEntProp(entity, Prop_Send, "m_iGlowType");
}

/**
 * Returns entity glow range.
 *
 * @param entity        Entity index.
 * @return              Glow range.
 * @error               Invalid entity index or entity does not support glow.
 */
stock L4D2_GetEntityGlow_Range(entity)
{
    return GetEntProp(entity, Prop_Send, "m_nGlowRange");
}

/**
 * Returns entity glow min range.
 *
 * @param entity        Entity index.
 * @return              Glow min range.
 * @error               Invalid entity index or entity does not support glow.
 */
stock L4D2_GetEntityGlow_MinRange(entity)
{
    return GetEntProp(entity, Prop_Send, "m_nGlowRangeMin");
}

/**
 * Returns entity glow flashing state.
 *
 * @param entity        Entity index.
 * @return              Glow flashing state.
 * @error               Invalid entity index or entity does not support glow.
 */
stock bool:L4D2_GetEntityGlow_Flashing(entity)
{
    return bool:GetEntProp(entity, Prop_Send, "m_bFlashing");
}

/**
 * Removes entity glow.
 *
 * @param entity        Entity index.
 * @return              True if glow was removed, false if entity does not
 *                      support glow or entity have no glow set.
 */
stock bool:L4D2_RemoveEntityGlow(entity)
{
    if (!IsValidEntity(entity))
    {
        return false;
    }

    decl String:netclass[128];
    GetEntityNetClass(entity, netclass, 128);

    new offset = FindSendPropInfo(netclass, "m_iGlowType");

    if (offset < 1)
    {
        return false;    
    }

    L4D2_SetEntityGlow_Type(entity, L4D2Glow_None);
    return true;
}

/**
 * Removes entity glow override color.
 *
 * Note: This only removes the override color and reset it to the default glow
 * color.
 *
 * @param entity        Entity index.
 * @noreturn
 * @error               Invalid entity index or entity does not support glow.
 */
stock L4D2_RemoveEntityGlow_Color(entity)
{
    L4D2_SetEntityGlow_Color(entity, {0, 0, 0});
}

/**
 * Whether survivor glow for player is enabled.
 *
 * @param client        Client index.
 * @return              True if survivor glow is enabled, false otherwise.
 * @error               Invalid client index.
 */
stock bool:L4D2_IsPlayerSurvivorGlowEnable(client)
{
    return bool:GetEntProp(client, Prop_Send, "m_bSurvivorGlowEnabled");
}

/**
 * Set survivor glow state for player.
 *
 * @param client        Client index.
 * @param enabled       Whether survivor glow is enabled.
 * @noreturn
 * @error               Invalid client index.
 */
stock L4D2_SetPlayerSurvivorGlowState(client, bool:enabled)
{
    SetEntProp(client, Prop_Send, "m_bSurvivorGlowEnabled", _:enabled);
}

/**
 * Return player current revive count.
 *
 * @param client        Client index.
 * @return              Survivor's current revive count.
 * @error               Invalid client index.
 */
stock L4D_GetPlayerReviveCount(client)
{
    return GetEntProp(client, Prop_Send, "m_currentReviveCount");
}

/**
 * Set player revive count.
 *
 * @param client        Client index.
 * @param count         Revive count.
 * @noreturn
 * @error               Invalid client index.
 */
stock L4D_SetPlayerReviveCount(client, count)
{
    SetEntProp(client, Prop_Send, "m_currentReviveCount", count);
}

/**
 * Return player intensity.
 *
 * Note: Its percentage. 0.0 - Player is calm, 1.0 - Player is stressed.
 *
 * @param client        Client index.
 * @return              Intensity.
 * @error               Invalid client index.
 */
stock Float:L4D_GetPlayerIntensity(client)
{
    /* This format is used to keep consistency with the Director which also
     * uses 0.0 for calm and 1.0 for stressed */
    return float(GetEntProp(client, Prop_Send, "m_clientIntensity")) / 100.0;
}

/**
 * Returns average survivor intensity.
 *
 * Note: Its percentage. 0.0 - All survivors is calm, 1.0 - All survivors is
 * stressed.
 *
 * @return              Average intensity level for survivors.
 */
stock Float:L4D_GetAvgSurvivorIntensity()
{
    new intensityTotal = 0;
    new intensityMaxTotal = 0;

    for (new client = 1; client <= MaxClients; client++)
    {
        if (!IsClientInGame(client) ||
            L4DTeam:GetClientTeam(client) != L4DTeam_Survivor ||
            !IsPlayerAlive(client) ||
            GetClientHealth(client) < 1)
        {
            continue;
        }

        intensityMaxTotal += 100;
        intensityTotal += GetEntProp(client, Prop_Send, "m_clientIntensity");
    }

    /* This format is used to keep consistency with the Director which also
     * uses 0.0 for calm and 1.0 for stressed */
    return float(intensityTotal) / float(intensityMaxTotal);
}

/**
 * Set player intensity.
 *
 * Note: Its percentage. 0.0 - Player is calm, 1.0 - Player is stressed.
 *
 * @param client        Client index.
 * @param intensity     Intensity.
 * @noreturn
 * @error               Invalid client index.
 */
stock L4D_SetPlayerIntensity(client, Float:intensity)
{
    SetEntProp(client, Prop_Send, "m_clientIntensity", RoundToNearest(intensity * 100.0);
}

/**
 * Returns whether player is calm.
 *
 * Note: Player is calm means that the player have not taken damage or
 * fired their weapon for a while. Survivor bots always return false.
 *
 * @param client        Client index.
 * @return              True if player is calm, false otherwise.
 * @error               Invalid client index.
 */
stock bool:L4D_IsPlayerCalm(client)
{
    return bool:GetEntProp(client, Prop_Send, "m_isCalm");
}

/**
 * Set player is calm state.
 *
 * Note: Player is calm means that the player have not taken damage or
 * fired their weapon for a while.
 *
 * @param client        Client index.
 * @param isCalm        Whether player is calm.
 * @noreturn
 * @error               Invalid client index.
 */
stock L4D_SetPlayerCalmState(client, bool:isCalm)
{
    SetEntProp(client, Prop_Send, "m_isCalm", _:isCalm);
}

/**
 * Returns whether player is on third strike.
 *
 * @param client        Client index.
 * @return              True if on third strike, false otherwise.
 * @error               Invalid client index.
 */
stock bool:L4D_IsPlayerOnThirdStrike(client)
{
    return bool:GetEntProp(client, Prop_Send, "m_bIsOnThirdStrike");
}

/**
 * Set player third strike state.
 *
 * @param client        Client index.
 * @param onThirdStrike Whether survivor is on third strike.
 * @noreturn
 * @error               Invalid client index.
 */
stock L4D_SetPlayerThirdStrikeState(client, bool:onThirdStrike)
{
    SetEntProp(client, Prop_Send, "m_bIsOnThirdStrike", _:onThirdStrike);
}

/**
 * Returns whether player is going to die.
 *
 * Note: This is not the same as is player on third strike. While on third
 * strike defines whether player should die next time they get incapacitated,
 * this defines whether the survivor should limp when they hit 1hp and make
 * the character vocalize their "I dont think I'm gonna make it" lines.
 *
 * @param client        Client index.
 * @return              True if player is going to die, false otherwise.
 * @error               Invalid client index.
 */
stock bool:L4D_IsPlayerGoingToDie(client)
{
    return bool:GetEntProp(client, Prop_Send, "m_isGoingToDie");
}

/**
 * Set player is going to die state.
 *
 * @param client        Client index.
 * @param isGoingToDie  Whether player is going to die.
 * @noreturn
 * @error               Invalid client index.
 */
stock L4D_SetPlayerIsGoingToDie(client, bool:isGoingToDie)
{
    SetEntProp(client, Prop_Send, "m_isGoingToDie", _:isGoingToDie);
}

/**
 * Returns whether weapon is upgrade compatible.
 *
 * @param weapon        Weapon entity index.
 * @return              True if compatiable with upgrades, false otherwise.
 * @error               Invalid entity index.
 */
stock bool:L4D2_IsWeaponUpgradeCompatible(weapon)
{
    decl String:netclass[128];
    GetEntityNetClass(weapon, netclass, 128);
    return FindSendPropInfo(netclass, "m_upgradeBitVec") > 0;
}

/**
 * Returns upgraded ammo count for weapon.
 *
 * @param weapon        Weapon entity index.
 * @return              Upgraded ammo count.
 * @error               Invalid entity index.
 */
stock L4D2_GetWeaponUpgradeAmmoCount(weapon)
{
    return GetEntProp(weapon, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded");
}

/**
 * Set upgraded ammo count in weapon.
 *
 * @param weapon        Weapon entity index.
 * @param count         Upgraded ammo count.
 * @noreturn
 * @error               Invalid entity index.
 */
stock L4D2_SetWeaponUpgradeAmmoCount(weapon, count)
{
    SetEntProp(weapon, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded", count);
}

/**
 * Returns weapon upgrades of weapon.
 *
 * @param weapon        Weapon entity index.
 * @return              Weapon upgrade bits.
 * @error               Invalid entity index.
 */
stock L4D2_GetWeaponUpgrades(weapon)
{
    return GetEntProp(weapon, Prop_Send, "m_upgradeBitVec");
}

/**
 * Set weapon upgrades for weapon.
 *
 * @param weapon        Weapon entity index.
 * @param upgrades      Weapon upgrade bits.
 * @noreturn
 * @error               Invalid entity index.
 */
stock L4D2_SetWeaponUpgrades(weapon, upgrades)
{
    SetEntProp(weapon, Prop_Send, "m_upgradeBitVec", upgrades);
}

/**
 * Returns infected attacker of survivor victim.
 *
 * Note: Infected attacker means the infected player that is currently
 * pinning down the survivor. Such as hunter, smoker, charger and jockey.
 *
 * @param client        Survivor client index.
 * @return              Infected attacker index, -1 if not found.
 * @error               Invalid client index.
 */
stock L4D2_GetInfectedAttacker(client)
{
    new attacker;

    /* Charger */
    attacker = GetEntPropEnt(client, Prop_Send, "m_pummelAttacker");
    if (attacker > 0)
    {
        return attacker;
    }

    attacker = GetEntPropEnt(client, Prop_Send, "m_carryAttacker");
    if (attacker > 0)
    {
        return attacker;
    }

    /* Hunter */
    attacker = GetEntPropEnt(client, Prop_Send, "m_pounceAttacker");
    if (attacker > 0)
    {
        return attacker;
    }

    /* Smoker */
    attacker = GetEntPropEnt(client, Prop_Send, "m_tongueOwner");
    if (attacker > 0)
    {
        return attacker;
    }

    /* Jockey */
    attacker = GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker");
    if (attacker > 0)
    {
        return attacker;
    }

    return -1;
}

/**
 * Returns survivor victim of infected attacker.
 *
 * Note: Survivor victim means the survivor player that is currently pinned
 * down by an attacker. Such as hunter, smoker, charger and jockey.
 *
 * @param client        Infected client index.
 * @return              Survivor victim index, -1 if not found.
 * @error               Invalid client index.
 */
stock L4D2_GetSurvivorVictim(client)
{
    new victim;

    /* Charger */
    victim = GetEntPropEnt(client, Prop_Send, "m_pummelVictim");
    if (victim > 0)
    {
        return victim;
    }

    victim = GetEntPropEnt(client, Prop_Send, "m_carryVictim");
    if (victim > 0)
    {
        return victim;
    }

    /* Hunter */
    victim = GetEntPropEnt(client, Prop_Send, "m_pounceVictim");
    if (victim > 0)
    {
        return victim;
    }

    /* Smoker */
    victim = GetEntPropEnt(client, Prop_Send, "m_tongueVictim");
    if (victim > 0)
    {
        return victim;
    }

    /* Jockey */
    victim = GetEntPropEnt(client, Prop_Send, "m_jockeyVictim");
    if (victim > 0)
    {
        return victim;
    }

    return -1;
}

/**
 * Returns whether survivor client was present at survival start.
 *
 * @param client        Client index.
 * @return              True if survivor was present at survival start, false
 *                      otherwise.
 * @error               Invalid client index.
 */
stock bool:L4D2_WasPresentAtSurvivalStart(client)
{
    return bool:GetEntProp(client, Prop_Send, "m_bWasPresentAtSurvivalStart");
}

/**
 * Sets whether player was present at survival start.
 *
 * @param client        Client index.
 * @param wasPresent    Whether survivor was present at survival start.
 * @noreturn
 * @error               Invalid client index.
 */
stock L4D2_SetPresentAtSurvivalStart(client, bool:wasPresent)
{
    SetEntProp(client, Prop_Send, "m_bWasPresentAtSurvivalStart", _:wasPresent);
}

/**
 * Returns whether player is using a mounted weapon.
 *
 * @param client        Client index.
 * @return              True if using a mounted weapon, false otherwise.
 * @error               Invalid client index.
 */
stock bool:L4D_IsPlayerUsingMountedWeapon(client)
{
    return bool:GetEntProp(client, Prop_Send, "m_usingMountedWeapon");
}

/**
 * Returns player temporarily health.
 *
 * Note: This will not work with mutations or campaigns that alters the decay
 * rate through vscript'ing. If you want to be sure that it works no matter
 * the mutation, you will have to detour the OnGetScriptValueFloat function.
 * Doing so you are able to capture the altered decay rate and calulate the
 * temp health the same way as this function does.
 *
 * @param client        Client index.
 * @return              Player's temporarily health, -1 if unable to get.
 * @error               Invalid client index or unable to find
 *                      pain_pills_decay_rate cvar.
 */
stock L4D_GetPlayerTempHealth(client)
{
    static Handle:painPillsDecayCvar = INVALID_HANDLE;
    if (painPillsDecayCvar == INVALID_HANDLE)
    {
        painPillsDecayCvar = FindConVar("pain_pills_decay_rate");
        if (painPillsDecayCvar == INVALID_HANDLE)
        {
            return -1;
        }
    }

    new tempHealth = RoundToCeil(GetEntPropFloat(client, Prop_Send, "m_healthBuffer") - ((GetGameTime() - GetEntPropFloat(client, Prop_Send, "m_healthBufferTime")) * GetConVarFloat(painPillsDecayCvar))) - 1;
    return tempHealth < 0 ? 0 : tempHealth;
}

/**
 * Set players temporarily health.
 *
 * @param client        Client index.
 * @param tempHealth    Temporarily health.
 * @noreturn
 * @error               Invalid client index.
 */
stock L4D_SetPlayerTempHealth(client, tempHealth)
{
    SetEntPropFloat(client, Prop_Send, "m_healthBuffer", float(tempHealth));
    SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
}

/**
 * Returns player use action.
 *
 * @param client        Client index.
 * @return              Use action.
 * @error               Invalid client index.
 */
stock L4D2UseAction:L4D2_GetPlayerUseAction(client)
{
    return L4D2UseAction:GetEntProp(client, Prop_Send, "m_iCurrentUseAction");
}

/**
 * Returns player use action target.
 *
 * @param client        Client index.
 * @return              Entity index.
 * @error               Invalid client index.
 */
stock L4D2_GetPlayerUseActionTarget(client)
{
    return GetEntPropEnt(client, Prop_Send, "m_useActionTarget");
}

/**
 * Returns player use action owner.
 *
 * @param client        Client index.
 * @return              Entity index.
 * @error               Invalid client index.
 */
stock L4D2_GetPlayerUseActionOwner(client)
{
    return GetEntPropEnt(client, Prop_Send, "m_useActionOwner");
}

/**
 * Creates an instructor hint.
 *
 * Note: Both infected and survivor players will see hint. No more than one at
 * a time can be shown. The "newest" hint will override the old no matter the
 * timeout and range. This instructor hint will not be shown if the given
 * player is dead.
 *
 * @param name          Instructor hint name.
 * @param target        Entity index of target.
 * @param caption       Caption of hint.
 * @param color         Color of the caption. RGB format.
 * @param iconOnScreen  Icon when hint is on screen.
 * @param iconOffScreen Icon when hint is off screen.
 * @param binding       Key binding to show.
 * @param iconOffset    Height offset for icon from target entity's origin.
 * @param range         Display range of hint. 0 for unlimited range.
 * @param timeout       Timeout out for hint. 0 will persist until stopped
 *                      with L4D2_EndInstructorHint.
 * @param allowNoDrawTarget Whether hint will work with targets that have 
 *                      nodraw set.
 * @param noOffScreen   Whether when hint is off screen it will show an arrow 
 *                      pointing to target.
 * @param forceCaption  Whether the hint and icon will show even when occluded
 *                      a wall.
 * @param flags         Instructor hint bit flags. See L4D2_IHFLAG_* defines.
 * @return              True if send, false otherwise.
 */
stock bool:L4D2_CreateInstructorHint(const String:name[], 
                                    target = 0,
                                    const String:caption[],
                                    color[3] = {255, 255, 255},
                                    const String:iconOnScreen[] = "icon_tip",
                                    const String:iconOffScreen[] = "icon_tip",
                                    const String:binding[] = "",
                                    Float:iconOffset = 0.0,
                                    Float:range = 0.0,
                                    timeout = 0,
                                    bool:allowNoDrawTarget = true,
                                    bool:noOffScreen = false,
                                    bool:forceCaption = false,
                                    flags = L4D2_IHFLAG_STATIC)
{
    new Handle:event = CreateEvent("instructor_server_hint_create", true);
    if (event == INVALID_HANDLE)
    {
        return false;
    }

    decl String:finalizedColor[16];
    Format(finalizedColor, 16, "%d,%d,%d", color[0], color[1], color[2]);

    SetEventString(event, "hint_name", name);
    SetEventInt(event, "hint_target", target);
    SetEventString(event, "hint_caption", caption);
    SetEventString(event, "hint_color", finalizedColor);
    SetEventString(event, "hint_icon_onscreen", iconOnScreen);
    SetEventString(event, "hint_icon_offscreen", iconOffScreen);
    SetEventString(event, "hint_binding", binding);
    SetEventFloat(event, "hint_icon_offset", iconOffset);
    SetEventFloat(event, "hint_range", range);
    SetEventInt(event, "hint_timeout", timeout);
    SetEventBool(event, "hint_allow_nodraw_target", allowNoDrawTarget);
    SetEventBool(event, "hint_nooffscreen", noOffScreen);
    SetEventBool(event, "hint_forcecaption", forceCaption);
    SetEventInt(event, "hint_flags", flags);
    FireEvent(event);
    return true;
}

/**
 * Stops all instructor hints with name.
 *
 * @param name          Name of instructor hint to stop.
 * @return              True if send, false otherwise.
 */
stock bool:L4D2_StopInstructorHint(const String:name[])
{
    new Handle:event = CreateEvent("instructor_server_hint_stop", true);
    if (event == INVALID_HANDLE)
    {
        return false;
    }

    SetEventString(event, "hint_name", name);
    FireEvent(event);
    return true;
}

/**
 * Returns whether shotgun needs to be pumped.
 *
 * @parma weapon        Weapon entity index.
 * @return              True if shotgun needs to be pumped, false otherwise.
 */
stock L4D1_GetShotgunNeedPump(weapon)
{
    return GetEntProp(weapon, Prop_Send, "m_needPump");
}

/**
 * Sets whether shotgun needs to be pumped.
 *
 * @parma weapon        Weapon entity index.
 * @parma needPump      Whether shotgun needs to be pumped.
 * @noreturn
 */
stock L4D1_SetShotgunNeedPump(weapon, bool:needPump)
{
    return SetEntProp(weapon, Prop_Send, "m_needPump", _:needPump);
}