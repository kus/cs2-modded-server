bool sprintEnabled          = true;
float sprintLength          = 3.0;
float sprintRefillSpeed     = 0.25;
float sprintSpeed           = 1.25;

public void RegisterServerCommandsSprint()
{
    RegServerCmd
    (
        "soccer_mod_sprint_enabled",
        ServerCommandsSprint,
        "Enables or disables sprint - values: 0/1, default: 1"
    );
    RegServerCmd
    (
        "soccer_mod_sprint_speed",
        ServerCommandsSprint,
        "Sets the sprint speed - values: 0.1-10, default: 1.25"
    );
    RegServerCmd
    (
        "soccer_mod_sprint_length",
        ServerCommandsSprint,
        "Sets the sprint length (in seconds) - values: 0.1-60, default: 3"
    );
    RegServerCmd
    (
        "soccer_mod_sprint_refill_speed",
        ServerCommandsSprint,
        "Sets how fast sprint refills (0.25 is 25% the sprint use speed) - values: 0.1-1, default: 0.25"
    );
}

public Action ServerCommandsSprint(int args)
{
    char serverCommand[50], cmdArg1[32];
    GetCmdArg(0, serverCommand, sizeof(serverCommand));
    GetCmdArg(1, cmdArg1, sizeof(cmdArg1));

    if (StrEqual(serverCommand, "soccer_mod_sprint_enabled"))
    {
        if (StringToInt(cmdArg1))
        {
            sprintEnabled = true;
            PrintToServer("%s Sprint enabled", PREFIX);
            PrintToChatAll("%s Sprint enabled", PREFIX);
        }
        else
        {
            sprintEnabled = false;
            PrintToServer("%s Sprint disabled", PREFIX);
            PrintToChatAll("%s Sprint disabled", PREFIX);
        }
    }
    else if (StrEqual(serverCommand, "soccer_mod_sprint_speed"))
    {
        float value = StringToFloat(cmdArg1);

        if (0.1 <= value <= 10) sprintSpeed = value;
        else if (value > 10) sprintSpeed = 10.0;
        else sprintSpeed = 0.1;

        PrintToServer("%s Sprint speed set to %.2f", PREFIX, sprintSpeed);
        PrintToChatAll("%s Sprint speed set to %.2f", PREFIX, sprintSpeed);
    }
    else if (StrEqual(serverCommand, "soccer_mod_sprint_length"))
    {
        float value = StringToFloat(cmdArg1);

        if (0.1 <= value <= 60) sprintLength = value;
        else if (value > 60) sprintLength = 60.0;
        else sprintLength = 0.1;

        SprintSetLimit();

        PrintToServer("%s Sprint length set to %.1f", PREFIX, sprintLength);
        PrintToChatAll("%s Sprint length set to %.1f", PREFIX, sprintLength);
    }
    else if (StrEqual(serverCommand, "soccer_mod_sprint_refill_speed"))
    {
        float value = StringToFloat(cmdArg1);

        if (0.1 <= value <= 1) sprintRefillSpeed = value;
        else if (value > 1) sprintRefillSpeed = 1.0;
        else sprintRefillSpeed = 0.1;

        PrintToServer("%s Sprint refill speed set to %.2f", PREFIX, sprintRefillSpeed);
        PrintToChatAll("%s Sprint refill speed set to %.2f", PREFIX, sprintRefillSpeed);
    }

    return Plugin_Handled;
}