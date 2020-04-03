int pressingSprint[MAXPLAYERS + 1];
int usingSprintCommand[MAXPLAYERS + 1];
float sprintLimit = 192.0;
float sprintPoints[MAXPLAYERS + 1];

// ************************************************************************************************************
// ************************************************** EVENTS **************************************************
// ************************************************************************************************************
public void SprintOnPluginStart()
{
    SprintSetLimit();
}

public void SprintOnClientPutInServer(int client)
{
    pressingSprint[client] = 0;
    usingSprintCommand[client] = 0;
    sprintPoints[client] = 0.0;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
    if (sprintEnabled && currentMapAllowed)
    {
        if (usingSprintCommand[client])
        {
            if (!matchPaused) sprintPoints[client] += 1.0;

            if (sprintPoints[client] >= sprintLimit)
            {
                usingSprintCommand[client] = 0;
                SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
                sprintPoints[client] = sprintLimit + (gameTickRate / 10);
            }

            SetPlayerArmor(client);
        }
        else
        {
            if (buttons & IN_SPEED && (buttons & IN_FORWARD || buttons & IN_BACK || buttons & IN_MOVELEFT || buttons & IN_MOVERIGHT))
            {
                if (!matchPaused) sprintPoints[client] += 1.0;

                if (!pressingSprint[client])
                {
                    pressingSprint[client] = 1;
                    if (sprintPoints[client] < sprintLimit) SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", sprintSpeed);
                }

                if (sprintPoints[client] >= sprintLimit)
                {
                    SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
                    sprintPoints[client] = sprintLimit + (gameTickRate / 10);
                }

                SetPlayerArmor(client);

                buttons &= ~IN_SPEED;
                return Plugin_Changed;
            }
            else
            {
                if (!matchPaused && !matchUnpausing) sprintPoints[client] -= sprintRefillSpeed;
                if (sprintPoints[client] < 0) sprintPoints[client] = 0.0;

                if (pressingSprint[client])
                {
                    pressingSprint[client] = 0;
                    SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
                }

                SetPlayerArmor(client);
            }
        }
    }

    return Plugin_Continue;
}

// *********************************************************************************************************************
// ************************************************** CLIENT COMMANDS **************************************************
// *********************************************************************************************************************
public void ClientCommandSprint(int client)
{
    if (usingSprintCommand[client])
    {
        SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);

        usingSprintCommand[client] = 0;
    }
    else
    {
        SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", sprintSpeed);

        usingSprintCommand[client] = 1;
    }
}

// ***************************************************************************************************************
// ************************************************** FUNCTIONS **************************************************
// ***************************************************************************************************************
public void SetPlayerArmor(int client)
{
    if (sprintPoints[client] <= sprintLimit) SetEntProp(client, Prop_Send, "m_ArmorValue", RoundToNearest(100.0 - ((sprintPoints[client] / sprintLimit) * 100)));
    else SetEntProp(client, Prop_Send, "m_ArmorValue", 0);
}

public void SprintSetLimit()
{
    gameTickRate = 1.0 / GetTickInterval();
    sprintLimit = sprintLength * gameTickRate;
}