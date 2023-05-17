stock String:GetConfigValue(client=0, Handle:Keys, Handle:Values, String:searchkey[], bool:bIsDetailedSearch=false, bool:bIsFloat=false) {
	
	decl String:text[512];
	decl String:value[512];
	if (!bIsFloat) Format(text, sizeof(text), "-1");
	else Format(text, sizeof(text), "-1.0");

	new size			= GetArraySize(Keys);

	for (new i = 0; i < size; i++) {

		GetArrayString(Handle:Keys, i, value, sizeof(value));

		if (StrEqual(value, searchkey)) {

			GetArrayString(Handle:Values, i, value, sizeof(value));
			if (client > 0 && bIsDetailedSearch) {

				Format(value, sizeof(value), "%T", value, client);
				if (StrEqual(text, "-1", false)) Format(text, sizeof(text), "%s", value);
				else Format(text, sizeof(text), "%s\n\t%s", text, value);
				continue;
			}
			Format(text, sizeof(text), "%s", value);
			return text;
		}
	}
	//if (bIsDetailedSearch) PrintToChatAll("%s", text);
	return text;
}

stock SetConfigValue(Handle:Keys, Handle:Values, String:searchkey[], String:newValue[]) {
	
	decl String:value[64];

	new size			= GetArraySize(Keys);

	for (new i = 0; i < size; i++) {

		GetArrayString(Handle:Keys, i, value, sizeof(value));
		if (StrEqual(value, searchkey)) {

			SetArrayString(Handle:Values, i, newValue);
			return 0;
		}
	}
	return -1;
}

stock String:GetVendorName(pos) {

	new Handle:v_Keys = CreateArray(64);
	new Handle:v_Values = CreateArray(64);
	decl String:vendorName[64];
	v_Keys		= GetArrayCell(a_Vendors, pos, 1);
	v_Values	= GetArrayCell(a_Vendors, pos, 2);

	Format(vendorName, sizeof(vendorName), "%s", GetConfigValue(_, v_Keys, v_Values, "vendor name?"));
	//ClearArray(v_Keys);
	//ClearArray(v_Values);
	return vendorName;
}

stock String:GetVendorValue(String:vendorName[], String:searchString[]) {

	new Handle:v_Keys = CreateArray(64);
	new Handle:v_Values = CreateArray(64);
	decl String:t_VendorName[64];
	decl String:t_Value[64];
	Format(t_Value, sizeof(t_Value), "-1.0");

	new size = GetArraySize(a_Vendors);
	for (new i = 0; i < size; i++) {

		v_Keys = GetArrayCell(a_Vendors, i, 1);
		v_Values = GetArrayCell(a_Vendors, i, 2);
		Format(t_VendorName, sizeof(t_VendorName), "%s", GetConfigValue(_, v_Keys, v_Values, "vendor name?"));
		if (!StrEqual(vendorName, t_VendorName, false)) continue;	// not the vendor we're looking for.
		Format(t_Value, sizeof(t_Value), "%s", GetConfigValue(_, v_Keys, v_Values, searchString));
		break;
	}
	return t_Value;
}

public OnEventSearch(String:EventName[]) {

	decl String:SearchName[64];
	new Handle:a_NameOfEvent = CreateArray(8);

	for (new i = 0; i < GetArraySize(a_Events); i++) {

		a_NameOfEvent = GetArrayCell(a_Events, i, 0);
		GetArrayString(Handle:a_NameOfEvent, 0, SearchName, sizeof(SearchName));
		if (StrEqual(EventName, SearchName)) {

			ClearArray(a_NameOfEvent);
			return i;
		}
	}
	ClearArray(a_NameOfEvent);
	return -1;
}

stock GetClientOfUserIdEx(Handle:event, Handle:Keys, Handle:Values, String:searchkey[]) {

	new result = -1;
	decl String:value[64];
	for (new i = 0; i < GetArraySize(Keys); i++) {

		GetArrayString(Handle:Keys, i, value, sizeof(value));
		if (StrEqual(value, searchkey)) {

			GetArrayString(Handle:Values, i, value, sizeof(value));
			result = GetClientOfUserId(GetEventInt(event, value));
			break;
		}
	}
	return result;
}

stock GetEventInfo(Handle:event, Handle:Keys, Handle:Values, String:searchkey[], bool:IsEventBool=false) {

	new result = -1;
	decl String:value[64];
	for (new i = 0; i < GetArraySize(Keys); i++) {

		GetArrayString(Handle:Keys, i, value, sizeof(value));
		if (StrEqual(value, searchkey)) {

			GetArrayString(Handle:Values, i, value, sizeof(value));
			if (IsEventBool) result = GetEventBool(event, value);
			else result = GetEventInt(event, value);
			break;
		}
	}
	return result;
}

stock bool:IsClient(client) {

	if (client > 0 && IsClientConnected(client) && IsClientInGame(client)) return true;
	return false;
}

stock String:AddCommasToString(value) 
{
	new String:buffer[128];
	new String:separator[1];
	separator = ",";
	buffer[0] = '\0'; 
	new divisor = 1000; 
	
	while (value >= 1000 || value <= -1000)
	{
		new offcut = value % divisor;
		value = RoundToFloor(float(value) / float(divisor));
		Format(buffer, sizeof(buffer), "%s%03.d%s", separator, offcut, buffer); 
	}
	
	Format(buffer, sizeof(buffer), "%d%s", value, buffer);
	return buffer;
}