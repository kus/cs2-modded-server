int trainingCannonBallIndex     = -1;
bool trainingGoalsEnabled       = true;
float trainingCannonFireRate    = 2.5;
float trainingCannonPower       = 10000.0;
float trainingCannonRandomness  = 0.0;
Handle trainingCannonTimer      = null;

float trainingCannonAim[3];
float trainingCannonPosition[3];

// ***********************************************************************************************************************
// ************************************************** COMMAND LISTENERS **************************************************
// ***********************************************************************************************************************
public void TrainingCannonSet(int client, char type[32], float number, float min, float max)
{
    if (number >= min && number <= max)
    {
        char steamid[32];
        GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));

        if (StrEqual(type, "randomness"))
        {
            trainingCannonRandomness = number;

            for (int player = 1; player <= MaxClients; player++)
            {
                if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "$player has set the cannon randomness to $number", client, number);
            }

            LogMessage("%N <%s> has set the cannon randomness to %.0f", client, steamid, number);
        }
        else if (StrEqual(type, "fire_rate"))
        {
            trainingCannonFireRate = number;

            for (int player = 1; player <= MaxClients; player++)
            {
                if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "$player has set the cannon fire rate to $number", client, number);
            }

            LogMessage("%N <%s> has set the cannon fire rate to %.1f", client, steamid, number);
        }
        else if (StrEqual(type, "power"))
        {
            trainingCannonPower = number;

            for (int player = 1; player <= MaxClients; player++)
            {
                if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "$player has set the cannon power to $number", client, number);
            }

            LogMessage("%N <%s> has set the cannon power to %.3f", client, steamid, number);
        }

        changeSetting[client] = "";
        OpenTrainingCannonSettingsMenu(client);
    }
    else PrintToChat(client, "[Soccer Mod]\x04 %t", "Type a value between $min and $max", min, max);
}

// ************************************************************************************************************
// ************************************************** EVENTS **************************************************
// ************************************************************************************************************
public void TrainingOnPluginStart()
{
    if (StrEqual(game, "cstrike")) trainingModelBall = "models/soccer_mod/ball_2011.mdl";
}

public void TrainingOnMapStart()
{
    trainingCannonBallIndex     = -1;
    trainingGoalsEnabled        = true;

    KillTrainingCannonTimer();
}

public void TrainingEventRoundStart(Event event)
{
    if (matchStarted) KillTrainingCannonTimer();
    else if (!trainingGoalsEnabled)
    {
        int index;
        while ((index = FindEntityByClassname(index, "trigger_once")) != INVALID_ENT_REFERENCE) AcceptEntityInput(index, "Kill");
    }
}

// *******************************************************************************************************************
// ************************************************** TRAINING MENU **************************************************
// *******************************************************************************************************************
public void OpenTrainingMenu(int client)
{
    Menu menu = new Menu(TrainingMenuHandler);

    char langString[64], langString1[64], langString2[64];
    Format(langString1, sizeof(langString1), "%T", "Admin", client);
    Format(langString2, sizeof(langString2), "%T", "Training", client);
    Format(langString, sizeof(langString), "Soccer Mod - %s - %s", langString1, langString2);
    menu.SetTitle(langString);

    Format(langString, sizeof(langString), "%T", "Cannon", client);
    menu.AddItem("cannon", langString);

    Format(langString, sizeof(langString), "%T", "Disable goals", client);
    menu.AddItem("disable_goals", langString);

    Format(langString, sizeof(langString), "%T", "Enable goals", client);
    menu.AddItem("enable_goals", langString);

    Format(langString, sizeof(langString), "%T", "Spawn/remove ball", client);
    menu.AddItem("spawn", langString);

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int TrainingMenuHandler(Menu menu, MenuAction action, int client, int choice)
{
    if (action == MenuAction_Select)
    {
        if (!matchStarted)
        {
            char menuItem[32];
            menu.GetItem(choice, menuItem, sizeof(menuItem));

            if (StrEqual(menuItem, "disable_goals"))
            {
                TrainingDisableGoals(client);
                OpenTrainingMenu(client);
            }
            else if (StrEqual(menuItem, "enable_goals"))
            {
                TrainingEnableGoals(client);
                OpenTrainingMenu(client);
            }
            else if (StrEqual(menuItem, "spawn"))
            {
                TrainingSpawnBall(client);
                OpenTrainingMenu(client);
            }
            else if (StrEqual(menuItem, "cannon")) OpenTrainingCannonMenu(client);
        }
        else
        {
            PrintToChat(client, "[Soccer Mod]\x04 %t", "You can not use this option during a match");
            OpenTrainingMenu(client);
        }
    }
    else if (action == MenuAction_Cancel && choice == -6)   OpenMenuAdmin(client);
    else if (action == MenuAction_End)                      menu.Close();
}

// **************************************************************************************************************************
// ************************************************** TRAINING CANNON MENU **************************************************
// **************************************************************************************************************************
public void OpenTrainingCannonMenu(int client)
{
    Menu menu = new Menu(TrainingCannonMenuHandler);

    char langString[64], langString1[64], langString2[64], langString3[64];
    Format(langString1, sizeof(langString1), "%T", "Admin", client);
    Format(langString2, sizeof(langString2), "%T", "Training", client);
    Format(langString3, sizeof(langString3), "%T", "Cannon", client);
    Format(langString, sizeof(langString), "Soccer Mod - %s - %s - %s", langString1, langString2, langString3);
    menu.SetTitle(langString);

    Format(langString, sizeof(langString), "%T", "Set cannon position", client);
    menu.AddItem("position", langString);

    Format(langString, sizeof(langString), "%T", "Set cannon aim", client);
    menu.AddItem("aim", langString);

    Format(langString, sizeof(langString), "%T", "Cannon on", client);
    menu.AddItem("on", langString);

    Format(langString, sizeof(langString), "%T", "Cannon off", client);
    menu.AddItem("off", langString);

    Format(langString, sizeof(langString), "%T", "Settings", client);
    menu.AddItem("settings", langString);

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int TrainingCannonMenuHandler(Menu menu, MenuAction action, int client, int choice)
{
    if (action == MenuAction_Select)
    {
        char menuItem[32];
        menu.GetItem(choice, menuItem, sizeof(menuItem));

        if (StrEqual(menuItem, "off"))
        {
            TrainingCannonOff(client);
            OpenTrainingCannonMenu(client);
        }
        else
        {
            if (!matchStarted)
            {
                if (StrEqual(menuItem, "position"))
                {
                    TrainingCannonPosition(client);
                    OpenTrainingCannonMenu(client);
                }
                else if (StrEqual(menuItem, "aim"))
                {
                    TrainingCannonAimPosition(client);
                    OpenTrainingCannonMenu(client);
                }
                else if (StrEqual(menuItem, "on")) TrainingCannonOn(client);
                else if (StrEqual(menuItem, "settings")) OpenTrainingCannonSettingsMenu(client);
            }
            else
            {
                PrintToChat(client, "[Soccer Mod]\x04 %t", "You can not use this option during a match");
                OpenTrainingCannonMenu(client);
            }
        }

    }
    else if (action == MenuAction_Cancel && choice == -6)   OpenTrainingMenu(client);
    else if (action == MenuAction_End)                      menu.Close();
}

public void OpenTrainingCannonSelectBallMenu(int client, int count, int[] numbers)
{
    Menu menu = new Menu(TrainingChooseBallMenuHandler);

    char langString[64], langString1[64], langString2[64], langString3[64], langString4[64];
    Format(langString1, sizeof(langString1), "%T", "Admin", client);
    Format(langString2, sizeof(langString2), "%T", "Training", client);
    Format(langString3, sizeof(langString3), "%T", "Cannon", client);
    Format(langString4, sizeof(langString4), "%T", "Select ball", client);
    Format(langString, sizeof(langString), "Soccer Mod - %s - %s - %s - %s", langString1, langString2, langString3, langString4);
    menu.SetTitle(langString);

    for (int i = 0; i < count; i++)
    {
        char entPropString[64];
        GetEntPropString(numbers[i], Prop_Data, "m_iName", entPropString, sizeof(entPropString));

        char menuString[64];
        Format(menuString, sizeof(menuString), "%i", numbers[i]);

        menu.AddItem(menuString, entPropString);
    }

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int TrainingChooseBallMenuHandler(Menu menu, MenuAction action, int client, int choice)
{
    if (action == MenuAction_Select)
    {
        char menuItem[32];
        menu.GetItem(choice, menuItem, sizeof(menuItem));
        trainingCannonBallIndex = StringToInt(menuItem);

        KillTrainingCannonTimer();
        trainingCannonTimer = CreateTimer(0.0, TrainingCannonShoot);

        for (int player = 1; player <= MaxClients; player++)
        {
            if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "$player has turned the cannon on", client);
        }

        char steamid[32];
        GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
        LogMessage("%N <%s> has turned the cannon on", client, steamid);

        OpenTrainingCannonMenu(client);
    }
    else if (action == MenuAction_Cancel && choice == -6)   OpenTrainingCannonMenu(client);
    else if (action == MenuAction_End)                      menu.Close();
}

public void OpenTrainingCannonSettingsMenu(int client)
{
    Menu menu = new Menu(TrainingCannonSettingsMenuHandler);

    char langString[64], langString1[64], langString2[64], langString3[64], langString4[64];
    Format(langString1, sizeof(langString1), "%T", "Admin", client);
    Format(langString2, sizeof(langString2), "%T", "Training", client);
    Format(langString3, sizeof(langString3), "%T", "Cannon", client);
    Format(langString4, sizeof(langString4), "%T", "Settings", client);
    Format(langString, sizeof(langString), "Soccer Mod - %s - %s - %s - %s", langString1, langString2, langString3, langString4);
    menu.SetTitle(langString);

    char menuString[32];
    Format(langString, sizeof(langString), "%T", "Randomness", client);
    Format(menuString, sizeof(menuString), "%s: %.0f", langString, trainingCannonRandomness);
    menu.AddItem("randomness", menuString);

    Format(langString, sizeof(langString), "%T", "Fire rate", client);
    Format(menuString, sizeof(menuString), "%s: %.1f", langString, trainingCannonFireRate);
    menu.AddItem("fire_rate", menuString);

    Format(langString, sizeof(langString), "%T", "Power", client);
    Format(menuString, sizeof(menuString), "%s: %.3f", langString, trainingCannonPower);
    menu.AddItem("power", menuString);

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int TrainingCannonSettingsMenuHandler(Menu menu, MenuAction action, int client, int choice)
{
    if (action == MenuAction_Select)
    {
        char menuItem[32];
        menu.GetItem(choice, menuItem, sizeof(menuItem));

        if (StrEqual(menuItem, "randomness"))
        {
            PrintToChat(client, "[Soccer Mod]\x04 %t", "Type a value between $min and $max", 0.0, 500.0);
            changeSetting[client] = "randomness";
        }
        else if (StrEqual(menuItem, "fire_rate"))
        {
            PrintToChat(client, "[Soccer Mod]\x04 %t", "Type a value between $min and $max", 0.5, 10.0);
            changeSetting[client] = "fire_rate";
        }
        else if (StrEqual(menuItem, "power"))
        {
            PrintToChat(client, "[Soccer Mod]\x04 %t", "Type a value between $min and $max", 0.001, 10000.0);
            changeSetting[client] = "power";
        }
    }
    else if (action == MenuAction_Cancel && choice == -6)   OpenTrainingCannonMenu(client);
    else if (action == MenuAction_End)                      menu.Close();
}

// ************************************************************************************************************
// ************************************************** TIMERS **************************************************
// ************************************************************************************************************
public Action TrainingCannonShoot(Handle timer)
{
    if (IsValidEntity(trainingCannonBallIndex))
    {
        float vec[3];
        MakeVectorFromPoints(trainingCannonPosition, trainingCannonAim, vec);

        vec[0] = vec[0] + (trainingCannonRandomness / 2.0) - (trainingCannonRandomness * GetRandomFloat());
        vec[1] = vec[1] + (trainingCannonRandomness / 2.0) - (trainingCannonRandomness * GetRandomFloat());
        vec[2] = vec[2] + (trainingCannonRandomness / 2.0) - (trainingCannonRandomness * GetRandomFloat());

        ScaleVector(vec, trainingCannonPower);
        TeleportEntity(trainingCannonBallIndex, trainingCannonPosition, NULL_VECTOR, vec);

        trainingCannonTimer = CreateTimer(trainingCannonFireRate, TrainingCannonShoot);
    }
    else
    {
        trainingCannonBallIndex = -1;
        KillTrainingCannonTimer()

        for (int player = 1; player <= MaxClients; player++)
        {
            if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "Ball cannon entity is invalid");
        }
    }
}

// ***************************************************************************************************************
// ************************************************** FUNCTIONS **************************************************
// ***************************************************************************************************************
public void KillTrainingCannonTimer()
{
    if (trainingCannonTimer != null)
    {
        KillTimer(trainingCannonTimer);
        trainingCannonTimer = null;
    }
}

public void TrainingDisableGoals(int client)
{
    if (trainingGoalsEnabled)
    {
        trainingGoalsEnabled = false;

        int index;
        while ((index = FindEntityByClassname(index, "trigger_once")) != INVALID_ENT_REFERENCE) AcceptEntityInput(index, "Kill");

        for (int player = 1; player <= MaxClients; player++)
        {
            if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "$player has disabled the goals", client);
        }

        char steamid[32];
        GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
        LogMessage("%N <%s> has disabled the goals", client, steamid);
    }
    else PrintToChat(client, "[Soccer Mod]\x04 %t", "Goals are already disabled");
}

public void TrainingEnableGoals(int client)
{
    if (!trainingGoalsEnabled)
    {
        trainingGoalsEnabled = true;
        ServerCommand("mp_restartgame 1");

        for (int player = 1; player <= MaxClients; player++)
        {
            if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "$player has enabled the goals", client);
        }

        char steamid[32];
        GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
        LogMessage("%N <%s> has enabled the goals", client, steamid);
    }
    else PrintToChat(client, "[Soccer Mod]\x04 %t", "Goals are already enabled");
}

public void TrainingSpawnBall(int client)
{
    if (FileExists(trainingModelBall, true))
    {
        char entityName[32];
        Format(entityName, sizeof(entityName), "soccer_mod_training_ball_%i", client);

        int index;
        bool ballSpawned = false;

        while ((index = FindEntityByClassname(index, "prop_physics")) != INVALID_ENT_REFERENCE)
        {
            char entPropString[32];
            GetEntPropString(index, Prop_Data, "m_iName", entPropString, sizeof(entPropString));

            if (StrEqual(entPropString, entityName))
            {
                ballSpawned = true;
                AcceptEntityInput(index, "Kill");
            }
        }

        if (!ballSpawned)
        {
            index = CreateEntityByName("prop_physics");
            if (index)
            {
                if (!IsModelPrecached(trainingModelBall)) PrecacheModel(trainingModelBall);

                DispatchKeyValue(index, "targetname", entityName);
                DispatchKeyValue(index, "model", trainingModelBall);

                float aimPosition[3];
                GetAimOrigin(client, aimPosition);
                DispatchKeyValueVector(index, "origin", aimPosition);

                DispatchSpawn(index);
            }
        }
    }
    else PrintToChat(client, "[Soccer Mod]\x04 %t", "Cant spawn model $model", trainingModelBall);
}

public void TrainingCannonOn(int client)
{
    if (trainingCannonTimer == null)
    {
        char steamid[32];
        GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));

        if (!IsValidEntity(trainingCannonBallIndex))
        {
            int count = 0;
            int numbers[64];
            int index;

            while ((index = FindEntityByClassname(index, "func_physbox")) != INVALID_ENT_REFERENCE)
            {
                char entPropString[64];
                GetEntPropString(index, Prop_Data, "m_iName", entPropString, sizeof(entPropString));

                if (entPropString[0])
                {
                    numbers[count] = index;
                    count++;
                }
            }

            while ((index = FindEntityByClassname(index, "prop_physics")) != INVALID_ENT_REFERENCE)
            {
                char entPropString[64];
                GetEntPropString(index, Prop_Data, "m_iName", entPropString, sizeof(entPropString));

                if (entPropString[0])
                {
                    numbers[count] = index;
                    count++;
                }
            }

            if (count > 1)
            {
                PrintToChat(client, "[Soccer Mod]\x04 %t", "More than one possible ball found");
                OpenTrainingCannonSelectBallMenu(client, count, numbers);
            }
            else
            {
                trainingCannonBallIndex = numbers[0];
                KillTrainingCannonTimer();
                trainingCannonTimer = CreateTimer(0.0, TrainingCannonShoot);

                for (int player = 1; player <= MaxClients; player++)
                {
                    if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "$player has turned the cannon on", client);
                }

                LogMessage("%N <%s> has turned the cannon on", client, steamid);
                OpenTrainingCannonMenu(client);
            }
        }
        else
        {
            KillTrainingCannonTimer();
            trainingCannonTimer = CreateTimer(0.0, TrainingCannonShoot);

            for (int player = 1; player <= MaxClients; player++)
            {
                if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "$player has turned the cannon on", client);
            }

            LogMessage("%N <%s> has turned the cannon on", client, steamid);
            OpenTrainingCannonMenu(client);
        }
    }
    else
    {
        PrintToChat(client, "[Soccer Mod]\x04 %t", "Cannon is already on");
        OpenTrainingCannonMenu(client);
    }
}

public void TrainingCannonOff(int client)
{
    if (trainingCannonTimer != null)
    {
        KillTrainingCannonTimer();

        for (int player = 1; player <= MaxClients; player++)
        {
            if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "$player has turned the cannon off", client);
        }

        char steamid[32];
        GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
        LogMessage("%N <%s> has turned the cannon off", client, steamid);
    }
    else PrintToChat(client, "[Soccer Mod]\x04 %t", "Cannon is already off");
}

public void TrainingCannonPosition(int client)
{
    GetAimOrigin(client, trainingCannonPosition);
    trainingCannonPosition[2] += 15;

    for (int player = 1; player <= MaxClients; player++)
    {
        if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "$player has set the cannon position", client);
    }

    char steamid[32];
    GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
    LogMessage("%N <%s> has set the cannon position", client, steamid);
}

public void TrainingCannonAimPosition(int client)
{
    GetAimOrigin(client, trainingCannonAim);

    for (int player = 1; player <= MaxClients; player++)
    {
        if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "$player has set the cannon aim position", client);
    }

    char steamid[32];
    GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
    LogMessage("%N <%s> has set the cannon aim position", client, steamid);
}