public Action MsgHook_AdjustMoney(UserMsg msg_id, Handle msg, const int[] players, int playersNum, bool reliable, bool init)
{
	if(!Ready())
		return Plugin_Continue;
	
	char buffer[64];
	PbReadString(msg, "params", buffer, sizeof(buffer), 0);
	
	if (StrContains(buffer, "Cash_Award") != -1)
		return Plugin_Handled; // Block cash award messsages
	
	if (StrContains(buffer, "Point_Award") != -1)
		return Plugin_Handled; // Block point award messsages
		
	return Plugin_Continue;
}