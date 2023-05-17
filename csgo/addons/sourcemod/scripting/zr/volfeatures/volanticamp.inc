/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		   volanticamp.inc
 *  Type:		   Module
 *  Description:	Anti-camp handler.
 *
 *  Copyright (C) 2009-2013  Greyscale, Richard Helgeby
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * ============================================================================
 */

/**
 * Actions to do with players in anti-camp volumes.
 */
enum VolAnticampAction
{
	Anticamp_NoAction,	  /** Do nothing but give a warning. */
	Anticamp_Damage,		/** Give damage to player. */
	Anticamp_Slay,		  /** Slay player. */
	Anticamp_Drug,		  /** Drug player. */
	Anticamp_Ignite		 /** Ignite player. */
}

/**
 * Warning types.
 */
enum VolAnticampeWarningType
{
	Anticamp_NoWarning,	 /** No warning messages. */
	Anticamp_Chat,		  /** Print warning in chat area. */
	Anticamp_Center,		/** Print centered warning message. */
	Anticamp_Menu		   /** Print a menu-like warning message with close option. */
}

/**
 * Data structure for a anti-camp volume.
 */
enum VolTypeAnticamp
{
	bool:Anticamp_InUse,						 /** Specifies if the data index is used or not. */
	Float:Anticamp_Interval,					 /** How often to trigger an action. */
	Handle:Anticamp_Timer,					   /** Action timer handle. */
	
	VolAnticampAction:Anticamp_Action,		   /** What to do with players in anti-camp volumes */
	Float:Anticamp_Amount,					   /** Amount depending on action type. Usually time in seconds or damage amount. */
	
	VolAnticampeWarningType:Anticamp_Warning,	/** How to warn the player. */
	String:Anticamp_Message[256]				 /** Override warning message. Max 256 characters. */	
}

/**
 * Anti-camp data.
 */
int AnticampData[ZR_VOLUMES_MAX][VolTypeAnticamp];

/**
 * Event callback. Enables a anticamp volume.
 *
 * @param volumeIndex   The volume index.	
 */
void VolAnticampEnable(int volumeIndex)
{
	float interval;
	
	// Validate index.
	if (!VolIsValidIndex(volumeIndex))
	{
		return;
	}
	
	// Get data index.
	int dataindex = Volumes[volumeIndex][Vol_DataIndex];
	
	// Validate data index.
	if (!VolAnticampValidateIndex(dataindex))
	{
		return;
	}
	
	// Check if in use.
	if (AnticampData[dataindex][Anticamp_InUse])
	{
		// Kill timer if it exist.
		Handle timers = AnticampData[dataindex][Anticamp_Timer];
		if (timers != INVALID_HANDLE)
		{
			KillTimer(timers);
			AnticampData[dataindex][Anticamp_Timer] = INVALID_HANDLE;
		}
		
		// Get interval.
		interval = AnticampData[dataindex][Anticamp_Interval];
		
		// Validate interval.
		if (interval > 0.0)
		{
			AnticampData[dataindex][Anticamp_Timer] = CreateTimer(interval, Event_VolAnticampTrigger, volumeIndex, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			LogEvent(_, LogType_Normal, LOG_DEBUG, LogModule_Volfeatures, "Vol state", "Enabled anticamp volume %d.", volumeIndex);
		}
		else
		{
			LogEvent(_, LogType_Error, LOG_CORE_EVENTS, LogModule_Volfeatures, "Config Validation", "Warning: Invalid interval %.2f in anticamp volume %d.", interval, volumeIndex);
		}
	}
}

/**
 * Starts all existing anticamp timers.
 *
 * TODO: Reuse code! This is almost duplicate of VolAnticampEnable.
 */
stock void VolAnticampEnableAll()
{
	float interval;
	int dataindex;
	
	// Loop through all volumes.
	for (int volumeindex = 0; volumeindex < ZR_VOLUMES_MAX; volumeindex++)
	{
		// Check if unused.
		if (!VolInUse(volumeindex))
		{
			// Volume not in use, skip it.
			continue;
		}
		
		// Check if it's a anticamp volume.
		if (VolIsType(volumeindex, VolFeature_Anticamp))
		{
			// Get data index.
			dataindex = Volumes[volumeindex][Vol_DataIndex];
			
			// Kill timer if it exist.
			Handle timers = AnticampData[dataindex][Anticamp_Timer];
			if (timers != INVALID_HANDLE)
			{
				KillTimer(timers);
				AnticampData[dataindex][Anticamp_Timer] = INVALID_HANDLE;
			}
			
			// Get interval.
			interval = AnticampData[dataindex][Anticamp_Interval];
			
			// Validate interval.
			if (interval > 0.0)
			{
				AnticampData[dataindex][Anticamp_Timer] = CreateTimer(interval, Event_VolAnticampTrigger, volumeindex, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
				LogEvent(_, LogType_Normal, LOG_DEBUG, LogModule_Volfeatures, "Vol state", "Enabled anticamp volume %d.", volumeIndex);
			}
			else
			{
				LogEvent(_, LogType_Error, LOG_CORE_EVENTS, LogModule_Volfeatures, "Config Validation", "Warning: Invalid interval %.2f in anticamp volume %d.", interval, volumeIndex);
			}
		}
	}
}

/**
 * Event callback. Stops existing anticamp timer on a volume.
 */
void VolAnticampDisable(int volumeIndex)
{
	Handle timerbuffer;
	
	// Validate index.
	if (!VolIsValidIndex(volumeIndex))
	{
		return;
	}
	
	// Get data index.
	int dataindex = Volumes[volumeIndex][Vol_DataIndex];
	
	// Validate data index.
	if (!VolAnticampValidateIndex(dataindex))
	{
		return;
	}
	
	// Check if in use.
	if (AnticampData[dataindex][Anticamp_InUse])
	{
		// Stop timer.
		timerbuffer = AnticampData[dataindex][Anticamp_Timer];
		if (timerbuffer != INVALID_HANDLE)
		{
			KillTimer(timerbuffer);
			AnticampData[dataindex][Anticamp_Timer] = INVALID_HANDLE;
		}
		
		LogEvent(_, LogType_Normal, LOG_DEBUG, LogModule_Volfeatures, "Vol state", "Disabled anticamp volume %d.", volumeIndex);
	}
	
}

/**
 * Stops all existing anticamp timers.
 */
stock void VolAnticampDisableAll()
{
	Handle timerbuffer;
	
	// Loop through all volumes.
	for (int dataindex = 0; dataindex < ZR_VOLUMES_MAX; dataindex++)
	{
		// Check if in use.
		if (AnticampData[dataindex][Anticamp_InUse])
		{
			// Stop timer.
			timerbuffer = AnticampData[dataindex][Anticamp_Timer];
			if (timerbuffer != INVALID_HANDLE)
			{
				KillTimer(timerbuffer);
				AnticampData[dataindex][Anticamp_Timer] = INVALID_HANDLE;
			}
		}
	}
}

/**
 * Disables feature and resets data to defaults at the specified index.
 *
 * @param dataIndex	 Local data index.
 */
void VolAnticampReset(int dataIndex)
{
	AnticampData[dataIndex][Anticamp_InUse] = false;
	
	AnticampData[dataIndex][Anticamp_Interval] = 1.0;
	if (AnticampData[dataIndex][Anticamp_Timer] != INVALID_HANDLE)
	{
		KillTimer(AnticampData[dataIndex][Anticamp_Timer]);
		AnticampData[dataIndex][Anticamp_Timer] = INVALID_HANDLE;
	}
	
	AnticampData[dataIndex][Anticamp_Action] = Anticamp_Damage;
	AnticampData[dataIndex][Anticamp_Amount] = 5.0;
	
	AnticampData[dataIndex][Anticamp_Warning] = Anticamp_Chat;
	Format(view_as<char>(AnticampData[dataIndex][Anticamp_Message]), 256, "");
}

/**
 * Initialization event for anticamp feature.
 */
void VolAnticampInit()
{
	// Set default attributes.
	for (int dataindex = 0; dataindex < ZR_VOLUMES_MAX; dataindex++)
	{
		VolAnticampReset(dataindex);
	}
}

/**
 * Called when a player leave a anticamp volume.
 *
 * @param client		The client index.
 * @param volumeIndex   Index of volume the player left.
 */
void VolAnticampOnPlayerLeave(int client, int volumeIndex)
{
	int dataindex = Volumes[volumeIndex][Vol_DataIndex];
	
	switch (AnticampData[dataindex][Anticamp_Action])
	{
		case Anticamp_Drug:
		{
			// TODO: Un-drug player.
		}
		case Anticamp_Ignite:
		{
			ExtinguishEntity(client);
		}
	}
}

/**
 * Timer callback for anticamp volumes. Applies actions on players in volumes.
 */
public Action Event_VolAnticampTrigger(Handle timer, any volumeIndex)
{
	// Loop through all players.
	for (int client = 1; client <= MaxClients; client++)
	{
		// Validate client's connection state.
		if (!IsClientConnected(client) || !IsClientInGame(client) || !IsPlayerAlive(client))
		{
			continue;
		}
		
		// Check if the volume is unused.
		if (!VolInUse(volumeIndex))
		{
			continue;
		}
		
		// Check if the volume is disabled.
		if (!VolIsEnabled(volumeIndex))
		{
			continue;
		}
		
		// Check if it's a anticamp volume.
		if (VolIsType(volumeIndex, VolFeature_Anticamp))
		{
			// Check if player is in the volume.
			if (VolPlayerInVolume[client][volumeIndex])
			{
				// Apply action.
				VolAnticampApplyAction(client, Volumes[volumeIndex][Vol_DataIndex], volumeIndex);
			}
		}
	}
}

/**
 * Applies action on a client for the specified volume.
 *
 * @param client		The client index.
 * @param dataIndex	 Local data index.
 * @param volumeIndex   The volume index.
 */
void VolAnticampApplyAction(int client, int dataIndex, int volumeIndex)
{
	float amount = AnticampData[dataIndex][Anticamp_Amount];
	
	// Set client language.
	SetGlobalTransTarget(client);
	
	// Get player name.
	char name[64];
	GetClientName(client, name, sizeof(name));
	
	// Send warning message.
	VolAnticampWarnPlayer(client, dataIndex);
	
	switch (AnticampData[dataIndex][Anticamp_Action])
	{
		case Anticamp_NoAction:
		{
			// Do nothing.
		}
		case Anticamp_Damage:
		{
			// Give damage to player. Kill if zero HP or below.
			int damage = RoundToNearest(amount);
			int health = GetClientHealth(client) - damage;
			
			if (health > 0)
			{
				SetEntityHealth(client, health);
			}
			else
			{
				// Health is zero or below. Kill player.
				ForcePlayerSuicide(client);
				
				// Log event.
				LogEvent(false, LogType_Normal, LOG_GAME_EVENTS, LogModule_Volfeatures, "Anti-camp", "%t", "Vol Slay", name, volumeIndex);
			}
		}
		case Anticamp_Slay:
		{
			// Instantly kill the player.
			ForcePlayerSuicide(client);
			
			// Log event.
			LogEvent(false, LogType_Normal, LOG_GAME_EVENTS, LogModule_Volfeatures, "Anti-camp", "%t", "Vol Slay", name, volumeIndex);
		}
		case Anticamp_Drug:
		{
			// TODO: Trigger sm_drug on client some how.
		}
		case Anticamp_Ignite:
		{
			// Validate amount.
			if (amount > 0.0)
			{
				// Extinguish player first.
				ExtinguishEntity(client);
				
				// Ignite player for "amount" seconds.
				IgniteEntity(client, amount);
				
				// Log event.
				LogEvent(false, LogType_Normal, LOG_GAME_EVENTS, LogModule_Volfeatures, "Anti-camp", "%t", "Vol Ignite", name, volumeIndex);
			}
		}
	}
}

/**
 * Gives a warning to the specified player for the specified volume.
 *
 * @param client		The client index.
 * @param dataIndex	 Local data index.
 */
void VolAnticampWarnPlayer(int client, int dataIndex)
{
	char buffer[256];
	bool custommessage = (strlen(AnticampData[dataIndex][Anticamp_Message]) > 0) ? true : false;
	
	// Set language.
	SetGlobalTransTarget(client);
	
	// Format message.
	if (custommessage)
	{
		// Use custom message.
		strcopy(buffer, sizeof(buffer), AnticampData[dataIndex][Anticamp_Message]);
	}
	else
	{
		// Use default anticamp message in translations file.
		Format(buffer, sizeof(buffer), "%t", "Vol Anticamp Message");
	}
	
	switch (AnticampData[dataIndex][Anticamp_Warning])
	{
		case Anticamp_NoWarning:
		{
			// Do nothing.
		}
		case Anticamp_Chat:
		{
			// Apply ZR formatting and print chat message.
			TranslationPluginFormatString(buffer, sizeof(buffer));
			PrintToChat(client, buffer);
		}
		case Anticamp_Center:
		{
			// Print centered message.
			PrintCenterText(client, buffer);
		}
		case Anticamp_Menu:
		{
			// Display the message in a menu panel.
			Handle panel = CreatePanel();
			
			SetPanelTitle(panel, "Zombie:Reloaded");
			DrawPanelItem(panel, "", ITEMDRAW_SPACER);
			DrawPanelItem(panel, buffer);
			DrawPanelItem(panel, "", ITEMDRAW_SPACER);
			
			SetPanelCurrentKey(panel, 10);
			
			Format(buffer, sizeof(buffer), "%t", "Exit");
			DrawPanelItem(panel, buffer, ITEMDRAW_CONTROL);
			
			SendPanelToClient(panel, client, Handler_AnitcampDummy, 10);
			CloseHandle(panel);
		}
	}
}

/**
 * Dummy handler for panel messages.
 */
public int Handler_AnitcampDummy(Handle menu, MenuAction action, int param1, int param2)
{
	// Do nothing.
}

/**
 * Gets the first free anticamp data index.
 *
 * @return	  The first free anticamp data index if successful, or -1 if
 *			  there are no free volumes.
 */
int VolAnticampGetFreeIndex()
{
	// Loop through all indexes.
	for (int dataindex = 0; dataindex < ZR_VOLUMES_MAX; dataindex++)
	{
		// Check if it's free.
		if (!AnticampData[dataindex][Anticamp_InUse])
		{
			// Mark as in use.
			AnticampData[dataindex][Anticamp_InUse] = true;
			
			// Return the new index.
			return dataindex;
		}
	}
	
	// No free index found.
	return -1;
}

/**
 * Validates local data index.
 *
 * @param dataIndex	 Index to validate.
 * @return			  True if valid, false otherwise.
 */
bool VolAnticampValidateIndex(int dataIndex)
{
	if (dataIndex >= 0 && dataIndex < ZR_VOLUMES_MAX)
	{
		return true;
	}
	else
	{
		return false;
	}
}

/**
 * Dumps data to be used by zr_vol_list command.
 *
 * @param dataIndex	 Index in anticamp data array.
 * @param buffer		Destination string buffer.
 * @param maxlen		Size of destination buffer.
 * @return			  Number of cells written.
 */
int VolAnticampDumpData(int dataIndex, char[] buffer, int maxlen)
{
	char linebuffer[128];
	char valuebuffer[256];
	int anticampcache[VolTypeAnticamp];
	int cellswritten;
	
	// Validate index.
	if (!VolAnticampValidateIndex(dataIndex))
	{
		return 0;
	}
	
	// Initialize and clear buffer.
	buffer[0] = 0;
	
	// Cache data.
	anticampcache = AnticampData[dataIndex];
	
	Format(linebuffer, sizeof(linebuffer), "Interval:		   %.2f\n", anticampcache[Anticamp_Interval]);
	cellswritten += StrCat(buffer, maxlen, linebuffer);
	
	VolAnticampActionToString(anticampcache[Anticamp_Action], valuebuffer, sizeof(valuebuffer));
	Format(linebuffer, sizeof(linebuffer), "Action:			 %s\n", valuebuffer);
	cellswritten += StrCat(buffer, maxlen, linebuffer);
	
	Format(linebuffer, sizeof(linebuffer), "Action amount:	  %.2f\n", anticampcache[Anticamp_Amount]);
	cellswritten += StrCat(buffer, maxlen, linebuffer);
	
	VolAnticampWarningToString(anticampcache[Anticamp_Warning], valuebuffer, sizeof(valuebuffer));
	Format(linebuffer, sizeof(linebuffer), "Warning type:	   %s\n", valuebuffer);
	cellswritten += StrCat(buffer, maxlen, linebuffer);
	
	strcopy(valuebuffer, sizeof(valuebuffer), anticampcache[Anticamp_Message]);
	Format(linebuffer, sizeof(linebuffer), "Warning message:	\"%s\"\n", valuebuffer);
	cellswritten += StrCat(buffer, maxlen, linebuffer);
	
	return cellswritten;
}


/**************************************
 *									*
 *  CONVERTING FUNCTIONS			  *
 *									*
 **************************************/

/**
 * Converts a action type to a string.
 *
 * @param actionType	Action type to convert.
 * @param buffer		Destination string buffer.
 * @param maxlen		Size of destination buffer.
 * @param shortName	 Optional. Write short name or human readable name.
 *					  Default is human readable (false).
 * @return			  Number of cells written.
 */
int VolAnticampActionToString(VolAnticampAction actionType, char[] buffer, int maxlen, bool shortName = false)
{
	switch (actionType)
	{
		case Anticamp_NoAction:
		{
			return shortName ? strcopy(buffer, maxlen, "none") : strcopy(buffer, maxlen, "No action");
		}
		case Anticamp_Damage:
		{
			return shortName ? strcopy(buffer, maxlen, "damage") : strcopy(buffer, maxlen, "Damage player");
		}
		case Anticamp_Slay:
		{
			return shortName ? strcopy(buffer, maxlen, "slay") : strcopy(buffer, maxlen, "Kill player");
		}
		case Anticamp_Drug:
		{
			return shortName ? strcopy(buffer, maxlen, "drug") : strcopy(buffer, maxlen, "Drug player ");
		}
		case Anticamp_Ignite:
		{
			return shortName ? strcopy(buffer, maxlen, "ignite") : strcopy(buffer, maxlen, "Ignite player");
		}
	}
	
	return 0;
}

/**
 * Converts a action string type to a action type.
 *
 * @param action	Action string type to convert.
 * @return		  Action type or Anticamp_NoAction if failed.
 */
stock VolAnticampAction VolAnticampStringToAction(const char[] action)
{
	// Check if empty.
	if (strlen(action) == 0)
	{
		return Anticamp_NoAction;
	}
	
	if (StrEqual(action, "none", false))
	{
		return Anticamp_NoWarning;
	}
	else if (StrEqual(action, "damage", false))
	{
		return Anticamp_Damage;
	}
	else if (StrEqual(action, "slay", false))
	{
		return Anticamp_Slay;
	}
	else if (StrEqual(action, "drug", false))
	{
		return Anticamp_Drug;
	}
	else if (StrEqual(action, "ignite", false))
	{
		return Anticamp_Ignite;
	}
	
	// No match.
	return Anticamp_NoAction;
}

/**
 * Converts a warning type to a string.
 *
 * @param warningType   Warning type to convert.
 * @param buffer		Destination string buffer.
 * @param maxlen		Size of destination buffer.
 * @param shortName	 Optional. Write short name or human readable name.
 *					  Default is human readable (false).
 * @return			  Number of cells written.
 */
int VolAnticampWarningToString(VolAnticampeWarningType warningType, char[] buffer, int maxlen, bool shortName = false)
{
	switch (warningType)
	{
		case Anticamp_NoWarning:
		{
			return shortName ? strcopy(buffer, maxlen, "none") : strcopy(buffer, maxlen, "No warning");
		}
		case Anticamp_Chat:
		{
			return shortName ? strcopy(buffer, maxlen, "chat") : strcopy(buffer, maxlen, "Chat area");
		}
		case Anticamp_Center:
		{
			return shortName ? strcopy(buffer, maxlen, "center") : strcopy(buffer, maxlen, "Centered message");
		}
		case Anticamp_Menu:
		{
			return shortName ? strcopy(buffer, maxlen, "menu") : strcopy(buffer, maxlen, "Message in menu panel");
		}
	}
	
	return 0;
}

/**
 * Converts a warning string type to a warning type.
 *
 * @param warning   Warning string type to convert.
 * @return		  Warning type, or Anticamp_NoWarning if failed.
 */
stock VolAnticampeWarningType VolAnticampStringToWarning(const char[] warning)
{
	// Check if empty.
	if (strlen(warning) == 0)
	{
		return Anticamp_NoWarning;
	}
	
	if (StrEqual(warning, "none", false))
	{
		return Anticamp_NoWarning;
	}
	else if (StrEqual(warning, "chat", false))
	{
		return Anticamp_Chat;
	}
	else if (StrEqual(warning, "center", false))
	{
		return Anticamp_Center;
	}
	else if (StrEqual(warning, "menu", false))
	{
		return Anticamp_Menu;
	}
	
	// No match.
	return Anticamp_NoWarning;
}


/**************************************
 *									*
 *  ATTRIBUTE FUNCTIONS			   *
 *									*
 **************************************/

/**
 * Sets anticamp spesific attributes on a anticamp volume.
 *
 * @param dataIndex	 Local data index.
 * @param attribName	Attribute to modify.
 * @param attribVlue	Attribute value to set.
 * @return			  True if successfully set, false otherwise.
 */
bool VolAnticampSetAttribute(int dataIndex, const char[] attribName, const char[] attribValue)
{
	// Validate data index.
	if (!VolAnticampValidateIndex(dataIndex))
	{
		return false;
	}
	
	// Check attribute names.
	if (StrEqual(attribName, "interval", false))
	{
		if (VolAnticampSetIntervalString(dataIndex, attribValue))
		{
			return true;
		}
	}
	else if (StrEqual(attribName, "action", false))
	{
		if (VolAnticampSetActionString(dataIndex, attribValue))
		{
			return true;
		}
	}
	else if (StrEqual(attribName, "amount", false))
	{
		if (VolAnticampSetAmountString(dataIndex, attribValue))
		{
			return true;
		}
	}
	else if (StrEqual(attribName, "warning", false))
	{
		if (VolAnticampSetWarningString(dataIndex, attribValue))
		{
			return true;
		}
	}
	else if (StrEqual(attribName, "message", false))
	{
		// Unsupported because of technical limits in command parser. Spaces
		// and quoted strings aren't supported yet.
	}
	
	return false;
}

/**
 * Parses a interval string value and applies it to the specified volume.
 *
 * @param dataIndex	 Local data index.
 * @param interval	  Interval to set. A floating point number formatted as a
 *					  string. 
 * @return			  True if successfully set, false otherwise.
 */
bool VolAnticampSetIntervalString(int dataIndex, const char[] interval)
{
	float anticampinterval;
	
	// Check if string value is empty.
	if (strlen(interval) == 0)
	{
		return false;
	}
	
	// Convert value.
	anticampinterval = StringToFloat(interval);
	
	// Apply value.
	AnticampData[dataIndex][Anticamp_Interval] = anticampinterval;
	return true;
}

/**
 * Parses a action type string value and applies it to the specified volume.
 *
 * @param dataIndex	 Local data index.
 * @param action		Action type to set.
 * @return			  True if successfully set, false otherwise.
 */
bool VolAnticampSetActionString(int dataIndex, const char[] action)
{
	// Check if string value is empty.
	if (strlen(action) == 0)
	{
		return false;
	}
	
	// Check effect string values and apply them to the volume.
	if (StrEqual(action, "none", false))
	{
		AnticampData[dataIndex][Anticamp_Action] = Anticamp_NoAction;
		return true;
	}
	else if (StrEqual(action, "damage", false))
	{
		AnticampData[dataIndex][Anticamp_Action] = Anticamp_Damage;
		return true;
	}
	else if (StrEqual(action, "slay", false))
	{
		AnticampData[dataIndex][Anticamp_Action] = Anticamp_Slay;
		return true;
	}
	else if (StrEqual(action, "drug", false))
	{
		AnticampData[dataIndex][Anticamp_Action] = Anticamp_Drug;
		return true;
	}
	else if (StrEqual(action, "ignite", false))
	{
		AnticampData[dataIndex][Anticamp_Action] = Anticamp_Ignite;
		return true;
	}
	
	// The string value didn't match any valid action types.
	return false;
}

/**
 * Parses a action amount string value and applies it to the specified volume.
 *
 * @param dataIndex	 Local data index.
 * @param amount		Amount to set. A floating point number formatted as a
 *					  string. 
 * @return			  True if successfully set, false otherwise.
 */
bool VolAnticampSetAmountString(int dataIndex, const char[] amount)
{
	float actionamount;
	
	// Check if string value is empty.
	if (strlen(amount) == 0)
	{
		return false;
	}
	
	// Convert value.
	actionamount = StringToFloat(amount);
	
	// Apply value.
	AnticampData[dataIndex][Anticamp_Amount] = actionamount;
	return true;
}

/**
 * Parses a warning type string value and applies it to the specified volume.
 *
 * @param dataIndex	 Local data index.
 * @param warning	   warning type to set.
 * @return			  True if successfully set, false otherwise.
 */
bool VolAnticampSetWarningString(int dataIndex, const char[] warning)
{
	
	// Check if string value is empty.
	if (strlen(warning) == 0)
	{
		return false;
	}
	
	// Check effect string values and apply them to the volume.
	if (StrEqual(warning, "none", false))
	{
		AnticampData[dataIndex][Anticamp_Warning] = Anticamp_NoWarning;
		return true;
	}
	else if (StrEqual(warning, "chat", false))
	{
		AnticampData[dataIndex][Anticamp_Warning] = Anticamp_Chat;
		return true;
	}
	else if (StrEqual(warning, "center", false))
	{
		AnticampData[dataIndex][Anticamp_Warning] = Anticamp_Center;
		return true;
	}
	else if (StrEqual(warning, "menu", false))
	{
		AnticampData[dataIndex][Anticamp_Warning] = Anticamp_Menu;
		return true;
	}
	
	// The string value didn't match any valid action types.
	return false;
}
