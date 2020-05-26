void RemoveBomb_PlayerSpawn(int client)
{
	CreateTimer(0.1, RemoveBombTmr, client);
}

public Action RemoveBombTmr(Handle tmr, any client)
{
	int bomb = GetPlayerWeaponSlot(client, CS_SLOT_C4);
	if(bomb > 0 && IsValidEntity(bomb))
	{
		CS_DropWeapon(client, bomb, false, false);
		AcceptEntityInput(bomb, "Kill");
	}
}