#include <cstrike>
#include <sdkhooks>
#include <sourcemod>

#define semicolon 1
#define newdecls  required

public Plugin myinfo =
{
	name        = "Damage Indicator",
	author      = "Eyal282",
	description = "Shows where you damage and who you damage and how much.",
	version     = "1.0",
	url         = "NULL"
};

public void OnPluginStart()
{
	HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Post);
}

public Action Event_PlayerHurt(Handle hEvent, char[] Name, bool dontBroadcast)
{
	/* hitgroup 0 = generic */
	/* hitgroup 1 = head */
	/* hitgroup 2 = chest */
	/* hitgroup 3 = stomach */
	/* hitgroup 4 = left arm */
	/* hitgroup 5 = right arm */
	/* hitgroup 6 = left leg */
	/* hitgroup 7 = right leg */
	int type = GetEventInt(hEvent, "type");

	if (type & DMG_FALL)
		return;

	int victim   = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(hEvent, "attacker"));
	int damage   = GetEventInt(hEvent, "dmg_health");

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		if (attacker == i || (!IsPlayerAlive(i) && GetEntPropEnt(i, Prop_Send, "m_hObserverTarget") == attacker))
			PrintCenterText(i, "<font color='#0000FF'>-%i HP</font>", damage);

		else if (victim == i || (!IsPlayerAlive(i) && GetEntPropEnt(i, Prop_Send, "m_hObserverTarget") == victim))
			PrintCenterText(i, "<font color='#FF0000'>-%i HP</font>", damage);
	}
}