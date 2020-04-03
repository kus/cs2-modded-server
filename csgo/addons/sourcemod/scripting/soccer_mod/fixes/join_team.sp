public void LoadJoinTeamFix()
{
    AddCommandListener(JoinTeamCommandListener, "jointeam");
}

public Action JoinTeamCommandListener(int client, const char[] command, int argc)
{
    if (currentMapAllowed)
    {
        if (!client) return Plugin_Continue;

        char cmdArgString[4];
        GetCmdArgString(cmdArgString, sizeof(cmdArgString));

        int team = StringToInt(cmdArgString);
        if (1 <= team <= 3)
        {
            ChangeClientTeam(client, team);
            return Plugin_Handled;
        }
    }

    return Plugin_Continue;
}