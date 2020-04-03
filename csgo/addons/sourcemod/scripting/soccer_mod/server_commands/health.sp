bool healthGodmode  = true;
int healthAmount    = 250;

public void RegisterServerCommandsHealth()
{
    RegServerCmd
    (
        "soccer_mod_health_godmode",
        ServerCommandsHealth,
        "Enables or disables godmode - values: 0/1, default: 1"
    );
    RegServerCmd
    (
        "soccer_mod_health_amount",
        ServerCommandsHealth,
        "Sets the players health to this amount on spawn and when hurt - values: 1-500, default: 250"
    );
}

public Action ServerCommandsHealth(int args)
{
    char serverCommand[32], cmdArg1[8];
    GetCmdArg(0, serverCommand, sizeof(serverCommand));
    GetCmdArg(1, cmdArg1, sizeof(cmdArg1));

    if (StrEqual(serverCommand, "soccer_mod_health_godmode"))
    {
        if (StringToInt(cmdArg1))
        {
            healthGodmode = true;
            PrintToServer("%s Godmode enabled", PREFIX);
            PrintToChatAll("%s Godmode enabled", PREFIX);
        }
        else
        {
            healthGodmode = false;
            PrintToServer("%s Godmode disabled", PREFIX);
            PrintToChatAll("%s Godmode disabled", PREFIX);
        }
    }
    else if (StrEqual(serverCommand, "soccer_mod_health_amount"))
    {
        int value = StringToInt(cmdArg1);

        if (1 <= value <= 500) healthAmount = value;
        else if (value > 500) healthAmount = 500;
        else healthAmount = 1;

        PrintToServer("%s Player health set to %i", PREFIX, healthAmount);
        PrintToChatAll("%s Player health set to %i", PREFIX, healthAmount);
    }

    return Plugin_Handled;
}