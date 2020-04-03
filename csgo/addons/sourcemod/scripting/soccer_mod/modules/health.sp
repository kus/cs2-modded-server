// ********************************************************************************************************************
// ************************************************** ENTITY OUTPUTS **************************************************
// ********************************************************************************************************************
public void HealthOnStartTouch(int caller, int activator)
{
    for (int client = 1; client <= MaxClients; client++)
    {
        if (IsClientInGame(client) && IsClientConnected(client) && IsPlayerAlive(client)) SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
    }
}

// ************************************************************************************************************
// ************************************************** EVENTS **************************************************
// ************************************************************************************************************
public void HealthEventPlayerSpawn(Event event)
{
    int userid = event.GetInt("userid");
    int client = GetClientOfUserId(userid);
    int team = GetClientTeam(client);

    if (team > 1)
    {
        if (healthGodmode) SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
        else SetEntProp(client, Prop_Send, "m_iHealth", healthAmount);
    }
}

public void HealthEventPlayerHurt(Event event)
{
    if (!healthGodmode && !capFightStarted)
    {
        int userid = event.GetInt("userid");
        int client = GetClientOfUserId(userid);
        int team = GetClientTeam(client);

        if (team > 1)
        {
            SetEntProp(client, Prop_Send, "m_iHealth", healthAmount);

            int attacker = event.GetInt("attacker");
            if (attacker) SetEntPropFloat(client, Prop_Send, "m_flVelocityModifier", 1.0);
        }
    }
}