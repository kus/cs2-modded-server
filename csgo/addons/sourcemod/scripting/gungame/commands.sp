OnCreateCommand()
{
    // ConsoleCmd
    RegConsoleCmd("level", _CmdLevel);
    RegConsoleCmd("rules", _CmdRules);
    RegConsoleCmd("score", _CmdScore);
    RegConsoleCmd("weapons", _CmdWeapons);
    RegConsoleCmd("commands", _CmdCommand);
    RegConsoleCmd("leader", _CmdLeader);

    RegConsoleCmd("gg_version", _CmdVersion);
    RegConsoleCmd("gg_status", _CmdStatus);
    RegAdminCmd("gg_restart", CmdReset, GUNGAME_ADMINFLAG, "Restarts the whole game from the beginning.");
    RegAdminCmd("gg_enable", _CmdEnable, GUNGAME_ADMINFLAG, "Turn off gungame and restart the game.");
    RegAdminCmd("gg_disable", _CmdDisable, GUNGAME_ADMINFLAG, "Turn on gungame and restart the game.");

    /**
     * Add any ES GunGame command if there is any.
     */
}

public Action:_CmdEnable(client, args)
{
    if(!IsActive)
    {
        ReplyToCommand(client, "[GunGame] Turning on GunGame:SM");
        CPrintToChatAll("%t", "GunGame has been enabled");

        SetConVarInt(gungame_enabled, 1);

        Call_StartForward(FwdStart);
        Call_PushCell(true);
        Call_Finish();

        SetConVarInt(mp_restartgame, 1);
    } else {
        ReplyToCommand(client, "[GunGame] is already enabled");
    }
    return Plugin_Handled;
}

public Action:_CmdDisable(client, args)
{
    if(IsActive)
    {
        ReplyToCommand(client, "[GunGame] Turning off GunGame:SM");
        CPrintToChatAll("%t", "GunGame has been disabled");

        SetConVarInt(gungame_enabled, 0);

        Call_StartForward(FwdShutdown);
        Call_PushCell(true);
        Call_Finish();

        SetConVarInt(mp_restartgame, 1);
    } else {
        ReplyToCommand(client, "[GunGame] is already disabled");
    }
    return Plugin_Handled;
}

public Action:_CmdLevel(client, args)
{
    if ( IsActive )
    {
        CreateLevelPanel(client);
    }
    return Plugin_Handled;
}

public Action:_CmdLeader(client, args)
{
    if ( IsActive )
    {
        ShowLeaderMenu(client);
    }
    return Plugin_Handled;
}

public Action:_CmdRules(client, args)
{
    if(IsActive)
    {
        ShowRulesMenu(client);
    }
    return Plugin_Handled;
}

public Action:_CmdScore(client, args)
{
    if(IsActive)
    {
        ShowPlayerLevelMenu(client);
    }
    return Plugin_Handled;
}

public Action:_CmdWeapons(client, args)
{
    if(IsActive)
    {
        ShowWeaponLevelPanel(client);
    }
    return Plugin_Handled;
}

public Action:_CmdCommand(client, args)
{
    if(IsActive)
    {
        ShowCommandPanel(client);
    }
    return Plugin_Handled;
}

public Action:_CmdVersion(client, args)
{
    if(GetCmdReplySource() == SM_REPLY_TO_CHAT)
    {
        CPrintToChat(client, "%t", "Please view your console for more information");
    }

    PrintToConsole(client, "Gun Game Information:\n   Version: %s\n   Author: %s", GUNGAME_VERSION, GUNGAME_AUTHOR);
    PrintToConsole(client, "   Website: http://www.sourcemod.net\n   Compiled Time: %s %s", DATE, TIME);
    PrintToConsole(client, "\n   Idea and concepts of Gun Game was\n   originally made by cagemonkey\n   @ http://www.cagemonkey.org");

    return Plugin_Handled;
}

public Action:CmdReset(client, args)
{
    if(IsActive)
    {
        /* Reset the game and start over */
        for(new i = 1; i <= MaxClients; i++)
        {
            PlayerLevel[i] = 0;
            UTIL_UpdatePlayerScoreLevel(i);
        }

        SetConVarInt(mp_restartgame, 1);
    }

    return Plugin_Handled;
}

public Action:_CmdStatus(client, args)
{
    /**
     * Add a command called gg_status this will tell the state of the current game.
     * If the game is still in warmup round, warmup round has start/not started, If game is started
     * or not and if started it will state the leader level and gun.
     */

    if(IsActive)
    {
        ReplyToCommand(client, "[GunGame] Currently not implmented");
    }

    return Plugin_Handled;
}