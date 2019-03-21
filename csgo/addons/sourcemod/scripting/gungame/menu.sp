/**
 * Menu
 */

public CommandPanelHandler(Handle:menu, MenuAction:action, client, param2)
{
    if (action == MenuAction_Select)
    {
        switch(param2)
        {
            case 1: /* !level */
                CreateLevelPanel(client);
            case 2: /* !weapons */
                ShowWeaponLevelPanel(client);
            case 3: /* !score */
                ShowPlayerLevelMenu(client);
            case 4: /* !top */
            {
                if ( StatsEnabled ) 
                {
                    GG_DisplayTop(client); /* HINT: gungame_stats */
                }
                else
                {
                    CPrintToChat(client, "%t", "GunGame Stats is disabled");
                }
            }
            case 5: /* !leader */
                ShowLeaderMenu(client);
            case 6: /* !rank */
            {
                if ( StatsEnabled ) 
                {
                    GG_ShowRank(client); /* HINT: gungame_stats */
                }
                else
                {
                    CPrintToChat(client, "%t", "GunGame Stats is disabled");
                }
            }
            case 7: /* !rules */
                ShowRulesMenu(client);
        }
    }
}

public ScoreCommandPanelHandler(Handle:menu, MenuAction:action, client, param2)
{
    if (action == MenuAction_Select)
    {
        switch(param2)
        {
            case 2: /* !top */
            {
                if ( StatsEnabled ) 
                {
                    GG_DisplayTop(client); /* HINT: gungame_stats */
                }
            }
            case 3: /* !leader */
                ShowLeaderMenu(client);
            case 4: /* !score */
                ShowPlayerLevelMenu(client);
        }
    }
}

public EmptyPanelHandler(Handle:menu, MenuAction:action, param1, param2)
{
    /* Don't care what they pressed. */
}

CreateLevelPanel(client)
{
    SetGlobalTransTarget(client);
    decl String:text[256];
    decl String:subtext[64];

    new Handle:LevelPanel = CreatePanel();
    Format(text, sizeof(text), "%t", "LevelPanel: Level Information");
    SetPanelTitle(LevelPanel, text);
    DrawPanelItem(LevelPanel, BLANK, ITEMDRAW_SPACER|ITEMDRAW_RAWLINE);

    new Level = PlayerLevel[client], 
        killsPerLevel = UTIL_GetCustomKillPerLevel(Level);

    Format(text, sizeof(text), "%t", "LevelPanel: Level");
    DrawPanelItem(LevelPanel, text);
    Format(text, sizeof(text), "%t", "LevelPanel: You are on level",
        Level + 1, WeaponOrderName[Level], CurrentKillsPerWeap[client], killsPerLevel);
    DrawPanelText(LevelPanel, text);

    if ( CurrentLeader == client )
    {
        Format(text, sizeof(text), "%t", "LevelPanel: You are currently the leader");
        DrawPanelText(LevelPanel, text);
        DrawPanelText(LevelPanel, BLANK_SPACE);
    } else {
        DrawPanelItem(LevelPanel, BLANK, ITEMDRAW_SPACER|ITEMDRAW_RAWLINE);
    }

    Format(text, sizeof(text), "%t", "LevelPanel: Wins");
    DrawPanelItem(LevelPanel, text);

    if ( StatsEnabled )
    {
        FormatLanguageNumberTextEx(client, subtext, sizeof(subtext), 
            GG_GetClientWins(client), /* HINT: gungame_stats */
            "times"
        );
        Format(text, sizeof(text), "%t", "LevelPanel: You have won times", subtext);
        DrawPanelText(LevelPanel, text);
    }
    else
    {
        Format(text, sizeof(text), "%t", "GunGame Stats is disabled");
        CRemoveTags(text, sizeof(text));
        DrawPanelText(LevelPanel, text);
    }
    DrawPanelText(LevelPanel, BLANK_SPACE);

    Format(text, sizeof(text), "%t", "LevelPanel: Leader");
    DrawPanelItem(LevelPanel, text);

    if ( CurrentLeader && IsClientInGame(CurrentLeader) )
    {
        new level = PlayerLevel[CurrentLeader];

        if ( level )
        {
            decl String:Name[64];
            GetClientName(CurrentLeader, Name, sizeof(Name));
            Format(text, sizeof(text), "%t", "LevelPanel: The current leader is on level", Name, level + 1, WeaponOrderName[level]);
            DrawPanelText(LevelPanel, text);
            if ( CurrentLeader != client )
            {
                if ( level == Level )
                {
                    Format(text, sizeof(text), "%t", "LevelPanel: You have tied with the leader");
                    DrawPanelText(LevelPanel, text);
                }
                else if ( level > Level )
                {
                    FormatLanguageNumberTextEx(client, subtext, sizeof(subtext), level - Level, "levels");
                    CRemoveTags(subtext, sizeof(subtext));
                    Format(text, sizeof(text), "%t", "LevelPanel: You are levels from the leader", subtext);
                    DrawPanelText(LevelPanel, text);
                }
            }
        } else {
            Format(text, sizeof(text), "%t", "LevelPanel: There is currently no leader");
            DrawPanelText(LevelPanel, text);
        }
    } else {
        Format(text, sizeof(text), "%t", "LevelPanel: There is currently no leader");
        DrawPanelText(LevelPanel, text);
    }

    DrawPanelItem(LevelPanel, BLANK, ITEMDRAW_SPACER|ITEMDRAW_RAWLINE);
    SetPanelCurrentKey(LevelPanel, 4);
    Format(text, sizeof(text), "%t", "LevelPanel: Scores");
    DrawPanelItem(LevelPanel, text, ITEMDRAW_CONTROL);
    Format(text, sizeof(text), "%t", "LevelPanel: Press 4 to show scores");
    DrawPanelText(LevelPanel, text);
    
    DrawPanelItem(LevelPanel, BLANK, ITEMDRAW_SPACER|ITEMDRAW_RAWLINE);
    SetPanelCurrentKey(LevelPanel, 9);
    Format(text, sizeof(text), "%t", "Panel: Exit");
    DrawPanelItem(LevelPanel, text, ITEMDRAW_CONTROL);

    SendPanelToClient(LevelPanel, client, ScoreCommandPanelHandler, GUNGAME_MENU_TIME);
    CloseHandle(LevelPanel);
}

ShowPlayerLevelMenu(client)
{
    SetGlobalTransTarget(client);
    decl String:text[256];
    decl String:subtext[64];

    new Handle:menu = CreateMenu(EmptyMenuHandler);
    decl String:Name[64];

    Format(text, sizeof(text), "%t", "PlayersLevelPanel: Players level information");
    SetMenuTitle(menu, text);
    SetGlobalTransTarget(client);

    new counter = -1;
    for ( new i = 1; i <= MaxClients; i++ )
    {
        if ( IsClientInGame(i) )
        {
            GetClientName(i, Name, sizeof(Name));
            if ( StatsEnabled )
            {
                FormatLanguageNumberTextEx(client, subtext, sizeof(subtext), 
                    GG_GetClientWins(i), /* HINT: gungame_stats */
                    "wins"
                );
                Format(text, sizeof(text), "%t", "PlayersLevelPanel: Level Wins Name", PlayerLevel[i] + 1, subtext, Name, WeaponOrderName[PlayerLevel[i]]);
            }
            else
            {
                Format(text, sizeof(text), "%t", "PlayersLevelPanel: Level Name", PlayerLevel[i] + 1, Name, WeaponOrderName[PlayerLevel[i]]);
            }
            AddMenuItem(menu, BLANK, text, ++counter%7? ITEMDRAW_DISABLED: ITEMDRAW_DEFAULT);
        }
    }

    DisplayMenu(menu, client, GUNGAME_MENU_TIME);
}

ShowLeaderMenu(client)
{
    SetGlobalTransTarget(client);
    decl String:text[256];

    new Handle:menu = CreateMenu(EmptyMenuHandler);
    decl String:Name[64];

    if ( CurrentLeader ) {
        Format(text, sizeof(text), "%t%t", "LeaderMenu: Leaders", "LeaderMenu: Leader level and weapon", PlayerLevel[CurrentLeader] + 1, WeaponOrderName[PlayerLevel[CurrentLeader]]);
    } else {
        Format(text, sizeof(text), "%t", "LeaderMenu: Leaders");
    }
    SetMenuTitle(menu, text);
    SetGlobalTransTarget(client);

    new counter = -1;
    if ( CurrentLeader )
    {
        new level = PlayerLevel[CurrentLeader];
        for ( new i = 1; i <= MaxClients; i++ )
        {
            if ( IsClientInGame(i) && PlayerLevel[i] == level )
            {
                GetClientName(i, Name, sizeof(Name));
                AddMenuItem(menu, BLANK, Name, ++counter%7? ITEMDRAW_DISABLED: ITEMDRAW_DEFAULT);
            }
        }
    }
    else
    {
        Format(text, sizeof(text), "%t", "LeaderMenu: No leaders");
        AddMenuItem(menu, BLANK, text, ++counter%7? ITEMDRAW_DISABLED: ITEMDRAW_DEFAULT);
    }
        
    DisplayMenu(menu, client, GUNGAME_MENU_TIME);
}

public EmptyMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
    if ( action == MenuAction_End )
    {
        CloseHandle(menu);
    }
}


/* Move into a real menu */
ShowJoinMsgPanel(client)
{
    SetGlobalTransTarget(client);
    decl String:text[256];
    new Handle:faluco = CreatePanel(), Count;

    Format(text, sizeof(text), "%t", "JoinPanel: This server is running the GunGame:SM");
    SetPanelTitle(faluco, text);
    DrawPanelText(faluco, BLANK_SPACE);

    if(BotCanWin)
    {
        Format(text, sizeof(text), "%t", "JoinPanel: Bots can win the game is ENABLED!!");
        DrawPanelText(faluco, text);
        Count++;
    }

    if(TurboMode)
    {
        Format(text, sizeof(text), "%t", "JoinPanel: Turbo Mode is ENABLED!!");
        DrawPanelText(faluco, text);
        Count++;
    }

    if(KnifePro)
    {
        Format(text, sizeof(text), "%t", "JoinPanel: Knife Pro is ENABLED!!");
        DrawPanelText(faluco, text);
        Count++;
    }

    if(KnifeElite)
    {
        Format(text, sizeof(text), "%t", "JoinPanel: Knife Elite is ENABLED!!");
        DrawPanelText(faluco, text);
        Count++;
    }

    if(MinKillsPerLevel > 1)
    {
        Format(text, sizeof(text), "%t", "JoinPanel: Multikill Mode is ENABLED!!");
        DrawPanelText(faluco, text);
        Count++;
    }

    if(Count)
    {
        DrawPanelText(faluco, BLANK_SPACE);
    }

    Format(text, sizeof(text), "%t", "JoinPanel: Type !rules for instructions on how to play");
    DrawPanelText(faluco, text);
    Format(text, sizeof(text), "%t", "JoinPanel: Type !level to get your level info and who is leading");
    DrawPanelText(faluco, text);
    Format(text, sizeof(text), "%t", "JoinPanel: Type !score to get a list of all players scores and winnings");
    DrawPanelText(faluco, text);
    Format(text, sizeof(text), "%t", "JoinPanel: Type !commands to get a full list of gungame commands");
    DrawPanelText(faluco, text);

    DrawPanelText(faluco, BLANK_SPACE);
    Format(text, sizeof(text), "%t", "Panel: Exit");
    DrawPanelItem(faluco, text, ITEMDRAW_CONTROL);
    
    SendPanelToClient(faluco, client, EmptyPanelHandler, GUNGAME_MENU_TIME);
    CloseHandle(faluco);
}

ShowCommandPanel(client)
{
    SetGlobalTransTarget(client);
    decl String:text[256];
    new Handle:Ham = CreatePanel();
    Format(text, sizeof(text), "%t", "CommandPanel: [GunGame] Command list information");
    SetPanelTitle(Ham, text);
    DrawPanelText(Ham, BLANK_SPACE);
    Format(text, sizeof(text), "%t", "CommandPanel: !level to see your current level and who is winning");
    DrawPanelItem(Ham, text);
    Format(text, sizeof(text), "%t", "CommandPanel: !weapons to see the weapon order");
    DrawPanelItem(Ham, text);
    Format(text, sizeof(text), "%t", "CommandPanel: !score to see all player current scores");
    DrawPanelItem(Ham, text);
    Format(text, sizeof(text), "%t", "CommandPanel: !top to see the top winners on the server");
    DrawPanelItem(Ham, text);
    Format(text, sizeof(text), "%t", "CommandPanel: !leader to see current leaders");
    DrawPanelItem(Ham, text);
    Format(text, sizeof(text), "%t", "CommandPanel: !rank to see your place in stats");
    DrawPanelItem(Ham, text);
    Format(text, sizeof(text), "%t", "CommandPanel: !rules to see the rules and how to play");
    DrawPanelItem(Ham, text);
    DrawPanelItem(Ham, BLANK, ITEMDRAW_SPACER);

    SetPanelCurrentKey(Ham, 9);
    Format(text, sizeof(text), "%t", "Panel: Exit");
    DrawPanelItem(Ham, text);

    SendPanelToClient(Ham, client, CommandPanelHandler, GUNGAME_MENU_TIME);
    CloseHandle(Ham);
}

ShowWeaponLevelPanel(client)
{
    ClientOnPage[client] = 0;
    DisplayWeaponLevelPanel(client);
}

DisplayWeaponLevelPanel(client)
{
    SetGlobalTransTarget(client);
    decl String:text[256];
    new Handle:Ham = CreatePanel();

    Format(text, sizeof(text), "%t", "WeaponLevelPanel: [GunGame] Weapon Levels");
    SetPanelTitle(Ham, text);
    DrawPanelText(Ham, BLANK_SPACE);

    for ( new i = ClientOnPage[client] * 7, end = i + 7; i < end; i++ )
    {
        if ( i < WeaponOrderCount )
        {
            Format(text, sizeof(text), "%t", "WeaponLevelPanel: Order Weapon Kills", i + 1, WeaponOrderName[i], UTIL_GetCustomKillPerLevel(i));
            DrawPanelText(Ham, text);
        }
    }

    DrawPanelText(Ham, BLANK_SPACE);
    SetPanelCurrentKey(Ham, 7);

    Format(text, sizeof(text), "%t", "Panel: Back");
    DrawPanelItem(Ham, text, ITEMDRAW_CONTROL);
    Format(text, sizeof(text), "%t", "Panel: Next");
    DrawPanelItem(Ham, text, ITEMDRAW_CONTROL);
    Format(text, sizeof(text), "%t", "Panel: Exit");
    DrawPanelItem(Ham, text, ITEMDRAW_CONTROL);

    SendPanelToClient(Ham, client, WeaponMenuHandler, GUNGAME_MENU_TIME);
    CloseHandle(Ham);
}

public WeaponMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
    if(action == MenuAction_Select)
    {
        switch(param2)
        {
            case 7:
            {
                if(--ClientOnPage[param1] < 0)
                {
                    ClientOnPage[param1] = WeaponLevelPages - 1;
                }

                DisplayWeaponLevelPanel(param1);
            }
            case 8:
            {
                if(++ClientOnPage[param1] >= WeaponLevelPages)
                {
                    ClientOnPage[param1] = 0;
                }

                DisplayWeaponLevelPanel(param1);
            }
        }
    }
}

ShowRulesMenu(client)
{
    ClientOnPage[client] = 0;
    DisplayRulesMenu(client);
}

public RulesMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
    if(action == MenuAction_Select)
    {
        switch(param2)
        {
            case 7:
            {
                --ClientOnPage[param1];
                DisplayRulesMenu(param1);
            }
            case 8:
            {
                ++ClientOnPage[param1];
                DisplayRulesMenu(param1);
            }
        }
    }
}

DisplayRulesMenu(client)
{
    SetGlobalTransTarget(client);
    decl String:text[256];
    decl String:subtext[64];
    
    new Handle:menu = CreatePanel();
    Format(text, sizeof(text), "%t", "RulesPanel: [GunGame] Rules information");
    SetPanelTitle(menu, text);
    DrawPanelText(menu, BLANK_SPACE);

    new itemsCount = 4;
    if ( ObjectiveBonus )       itemsCount++;
    if ( AutoFriendlyFire )     itemsCount++;
    if ( MaxLevelPerRound > 1 ) itemsCount++;
    if ( KnifePro )             itemsCount++;
    if ( KnifeElite )           itemsCount++;
    if ( TurboMode )            itemsCount++;
    if ( CommitSuicide )        itemsCount++;
    
    new itemsOnPage = 3;
    new pagesCount  = (itemsCount - 1)/itemsOnPage + 1;
    
    if ( ClientOnPage[client] < 0 )             ClientOnPage[client] = pagesCount - 1;
    if ( ClientOnPage[client] >= pagesCount )   ClientOnPage[client] = 0;
    new itemStart   = ClientOnPage[client] * itemsOnPage + 1;
    new itemEnd     = itemStart + itemsOnPage - 1;
        
    Format(text, sizeof(text), "%t", "RulesPanel: Page", ClientOnPage[client] + 1, pagesCount);
    DrawPanelText(menu, text);
    DrawPanelText(menu, BLANK_SPACE);
    
    new item = 0;
    if ( (++item >= itemStart) && (itemEnd <= itemEnd) ) {
        FormatLanguageNumberTextEx(client, subtext, sizeof(subtext), MinKillsPerLevel, "points");
        CRemoveTags(subtext, sizeof(subtext));
        Format(text, sizeof(text), "%t", "RulesPanel: You must get kills with your current weapon to level up", subtext);
        DrawPanelText(menu, text);
    }
            
    if ( (++item >= itemStart) && (itemEnd <= itemEnd) ) {
        Format(text, sizeof(text), "%t", "RulesPanel: If you get a kill with a weapon out of order. It does not count towards your level");
        DrawPanelText(menu, text);
    }

    /**
     * How to propertly explain Custom Weapon Level to the player?
     * If a custom minimum kill has been set for a perticular weapon. You need to need to kill x number of players with that weapon before you can level.
     * To wordy? Bad Sentence? Think of a shorter and clearer sentence.
     */

    if ( ObjectiveBonus && (++item >= itemStart) && (item <= itemEnd) ) {
        FormatLanguageNumberTextEx(client, subtext, sizeof(subtext), ObjectiveBonus, "levels");
        CRemoveTags(subtext, sizeof(subtext));
        if ( g_Cfg_ObjectiveBonusExplode ) {
            Format(text, sizeof(text), "%t", "RulesPanel: You can gain level by EXPLODING or DEFUSING the bomb", subtext);
        } else {
            Format(text, sizeof(text), "%t", "RulesPanel: You can gain level by PLANTING or DEFUSING the bomb", subtext);
        }
        DrawPanelText(menu, text);
    }

    if ( AutoFriendlyFire && (++item >= itemStart) && (item <= itemEnd) ) {
        Format(text, sizeof(text), "%t", "RulesPanel: Friendly Fire is automatically turned ON when someone reaches GRENADE level");
        DrawPanelText(menu, text);
    }
    
    if ( (MaxLevelPerRound > 1) && (++item >= itemStart) && (item <= itemEnd) ) {
        Format(text, sizeof(text), "%t", "RulesPanel: You CAN gained more than one level per round");
        DrawPanelText(menu, text);
    }

    if ( KnifePro && (++item >= itemStart) && (item <= itemEnd) ) {
        Format(text, sizeof(text), "%t", "RulesPanel: You can steal a level from an opponent by knifing them");
        DrawPanelText(menu, text);
    }

    if ( KnifeElite && (++item >= itemStart) && (item <= itemEnd) ) {
        Format(text, sizeof(text), "%t", "RulesPanel: After you levelup, you will only have a knife until the next round starts");
        DrawPanelText(menu, text);
    }

    if ( TurboMode && (++item >= itemStart) && (item <= itemEnd) ) {
        Format(text, sizeof(text), "%t", "RulesPanel: You will receive your next weapon immediately when you level up");
        DrawPanelText(menu, text);
    }
    
    if ( CommitSuicide && (++item >= itemStart) && (item <= itemEnd) ) {
        
        FormatLanguageNumberTextEx(client, subtext, sizeof(subtext), CommitSuicide, "levels");
        CRemoveTags(subtext, sizeof(subtext));
        Format(text, sizeof(text), "%t", "RulesPanel: If you commit suicide you will lose levels", subtext);
        DrawPanelText(menu, text);
    }

    if ( (++item >= itemStart) && (item <= itemEnd) ) {
        Format(text, sizeof(text), "%t", "RulesPanel: There is a grace period at the end of each round to allow players to switch teams");
        DrawPanelText(menu, text);
    }

    if ( (++item >= itemStart) && (item <= itemEnd) ) {
        Format(text, sizeof(text), "%t", "RulesPanel: Type !commands to see the list of gungame commands");
        DrawPanelText(menu, text);
    }
    
    DrawPanelText(menu, BLANK_SPACE);
    SetPanelCurrentKey(menu, 7);

    Format(text, sizeof(text), "%t", "Panel: Back");
    DrawPanelItem(menu, text, ITEMDRAW_CONTROL);
    Format(text, sizeof(text), "%t", "Panel: Next");
    DrawPanelItem(menu, text, ITEMDRAW_CONTROL);
    Format(text, sizeof(text), "%t", "Panel: Exit");
    DrawPanelItem(menu, text, ITEMDRAW_CONTROL);

    SendPanelToClient(menu, client, RulesMenuHandler, GUNGAME_MENU_TIME);
    CloseHandle(menu);
}

