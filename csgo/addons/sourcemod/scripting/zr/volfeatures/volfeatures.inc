/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		   volfeatures.inc
 *  Type:		   Module
 *  Description:	Volumetric feature manager.
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
 * Total volumes that can be created in a map.
 */
#define ZR_VOLUMES_MAX 32

/**
 * Represent a rectangular volume.
 */
enum VolumeAttributes
{
	/* General */
	bool:Vol_Enabled,				   /** Volume state. */
	bool:Vol_InUse,					 /** Marks if the volume is used. */
	
	/* Location */
	Float:Vol_xMin,					 /** Minimum x position. */
	Float:Vol_xMax,					 /** Maximum x position. */
	
	Float:Vol_yMin,					 /** Minimum y position. */
	Float:Vol_yMax,					 /** Maximum y position. */
	
	Float:Vol_zMin,					 /** Minimum z position. */
	Float:Vol_zMax,					 /** Maximum z position. */
	
	/* Style */
	VolumeEffects:Vol_Effect,		   /** Visual effect to apply on the volume. */
	Vol_EffectColor[3],				 /** Render color of the effect. RGB colors. */
	
	/* Data */
	VolumeFeatureTypes:Vol_Type,		/** The volumetric feature type. */
	Vol_DataIndex,					  /** Index in remote feature array. */
	
	/* Behaviour */
	VolumeTeamFilters:Vol_TeamFilter,   /** Team filtering. Trigger by certain teams, or all. */
	Float:Vol_TriggerDelay,			 /** Trigger delay. How many seconds players have to stay to trigger volume events. */
	VolumeConflictActions:Vol_ConflictAction,	   /** What to do if volumes of same type overlap. */
	Vol_Priority,					   /** Volume priority. */
}

/**
 * Available volumetric feature types.
 */
enum VolumeFeatureTypes
{
	VolFeature_Invalid = 0,
	VolFeature_Anticamp,
	VolFeature_ClassEdit
}

/**
 * Effects that can be applied on a volume. (Currently no effects.)
 */
enum VolumeEffects
{
	VolEffect_None = 0,
	VolEffect_Wireframe,
	VolEffect_Smoke
}

/**
 * Available team filter settings.
 */
enum VolumeTeamFilters
{
	VolTeam_All = 0,
	VolTeam_Humans,
	VolTeam_Zombies
}

/**
 * Conflict actions. What to do with overlapping volumes of same type.
 */
enum VolumeConflictActions
{
	VolPriority = 0,	/** Use the volume with highest priority, ignore others. */
	VolMerge			/** Try to merge volume settings/attributes, or use priority if there's a merge conflict. */
}

/**
 * Volumes.
 */
int Volumes[ZR_VOLUMES_MAX][VolumeAttributes];

/**
 * Total number of volumes.
 */
int VolumeCount;

/**
 * List of player locations. Updated by a timer.
 */
float VolPlayerLoc[MAXPLAYERS + 1][3];

/**
 * Cache that specifies if a player is in a volume or not.
 */
bool VolPlayerInVolume[MAXPLAYERS + 1][ZR_VOLUMES_MAX];

/**
 * Specifies whether the volumetric features module is enabled or not. Synced
 * with zr_vol CVAR.
 */
bool VolEnabled;

/**
 * Counter for trigger delay.
 */
float VolPlayerCountDown[MAXPLAYERS + 1][ZR_VOLUMES_MAX];

/**
 * The handle for a timer that updates player locations. This is the main timer
 * and any feature events can't be updated faster than this interval.
 *
 * Note: Some features may have its own timer for actions on players.
 */
Handle hVolUpdateTimer = INVALID_HANDLE;

/**
 * The handle for a timer that do count down on trigger delays.
 */
Handle hVolTriggerTimer = INVALID_HANDLE;

/**
 * Cached interval value for trigger timer.
 */
float VolTriggerInterval;

#include "zr/volfeatures/voltools"
#include "zr/volfeatures/volevents"
#include "zr/volfeatures/volgenericattributes"
#include "zr/volfeatures/volcommands"

// Sub features.
#include "zr/volfeatures/volanticamp"
#include "zr/volfeatures/volclassedit"


/**
 * Initialize volumetric features.
 */
void VolInit()
{
	// Clear all volumes.
	VolClearAll();
	
	// Initialize sub features.
	VolAnticampInit();
	VolClassEditInit();
} 

/**
 * Initialize volumetric feature settings.
 */
void VolLoad()
{
	// Cache CVAR value.
	VolEnabled = GetConVarBool(g_hCvarsList[CVAR_VOL]);
}

/**
 * Function alias for fully stopping volumetric features.
 */
void VolDisable()
{
	VolEnabled = false;
	VolStopUpdateTimer();
	VolDisableVolumes();
	
	LogEvent(_, LogType_Normal, LOG_DEBUG, LogModule_Volfeatures, "Disabled", "Volfeatures disabled.");
}

/**
 * Function alias for starting volumetric features.
 */
void VolEnable()
{
	VolEnabled = true;
	VolStartUpdateTimer();
	VolEnableVolumes();
	
	LogEvent(_, LogType_Normal, LOG_DEBUG, LogModule_Volfeatures, "Enabled", "Volfeatures enabled.");
}

/**
 * Disables all enabled volumes.
 */
void VolDisableVolumes()
{
	// Trigger disable event on all enabled volumes in use.
	for (int volindex = 0; volindex < ZR_VOLUMES_MAX; volindex++)
	{
		if (Volumes[volindex][Vol_InUse] && Volumes[volindex][Vol_Enabled])
		{
			// Mark as disabled.
			Volumes[volindex][Vol_Enabled] = false;
			
			// Trigger player left volume event if inside a volume.
			for (int client = 1; client <= MaxClients; client++)
			{
				// Validate client's connection state.
				if (!IsClientConnected(client) || !IsClientInGame(client))
				{
					continue;
				}
				
				// Check if player is inside the volume.
				if (VolPlayerInVolume[client][volindex])
				{
					// Mark as not in the volume and trigger event.
					VolPlayerInVolume[client][volindex] = false;
					VolOnPlayerLeave(client, volindex);
				}
			}
			
			// Trigger disabled event.
			VolOnDisabled(volindex);
		}
	}
}

/**
 * Enables all disabled volumes.
 */
void VolEnableVolumes()
{
	// Trigger enable event on all volumes in use.
	for (int volindex = 0; volindex < ZR_VOLUMES_MAX; volindex++)
	{
		if (Volumes[volindex][Vol_InUse] && !Volumes[volindex][Vol_Enabled])
		{
			Volumes[volindex][Vol_Enabled] = true;
			VolOnEnabled(volindex);
		}
	}
}

/**
 * Starts the update timer.
 *
 * @return	  True if timer is started, false otherwise.
 */
bool VolStartUpdateTimer()
{
	// Check if volumetric features is enabled.
	if (!VolEnabled)
	{
		// Volumetric features disabled.
		return false;
	}
	
	// Stop timer if it exist.
	VolStopUpdateTimer();
	
	// Get update interval.
	float interval = GetConVarFloat(g_hCvarsList[CVAR_VOL_UPDATE_INTERVAL]);
	
	// Validate interval.
	if (interval > 0.0)
	{
		// Create a new timer.
		hVolUpdateTimer = CreateTimer(interval, Event_VolUpdateTimer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		
		// Also start the trigger delay timer.
		VolStartTriggerTimer();
		
		// Volumetric features started.
		return true;
	}
	else
	{
		// Volumetric features disabled.
		LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Volfeatures, "Config Validation", "Warning: Console variable \"zr_vol_update_interval\" is zero or negative. Must be positive.");
		return false;
	}
}

/**
 * Kills the update timer if it exists.
 */
void VolStopUpdateTimer()
{
	// Kill the timer if it's running.
	if (hVolUpdateTimer != INVALID_HANDLE)
	{
		KillTimer(hVolUpdateTimer);
		hVolUpdateTimer = INVALID_HANDLE;
	}
	
	// Also stop trigger delay timer.
	VolStopTriggerTimer();
	
	// Reset all trigger delay counters.
	VolResetCountDown();
}

/**
 * Starts the update timer if it exists.
 *
 * @return	  True if timer is started, false otherwise.
 */
bool VolStartTriggerTimer()
{
	// Make sure existing timer is killed.
	VolStopTriggerTimer();
	
	// Get trigger interval and cache it.
	VolTriggerInterval = GetConVarFloat(g_hCvarsList[CVAR_VOL_TRIGGER_INTERVAL]);
	
	// Validate interval.
	if (VolTriggerInterval > 0.0)
	{
		// Start the timer.
		hVolTriggerTimer = CreateTimer(VolTriggerInterval, Event_VolTriggerTimer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		
		// Trigger timer started.
		return true;
	}
	else
	{
		// Trigger timer not running. Either disabled or invalid interval.
		LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Volfeatures, "Config Validation", "Warning: Console variable \"zr_vol_trigger_interval\" is zero or negative. Must be positive.");
		return false;
	}
}

/**
 * Kills the trigger delay timer if it exists.
 */
void VolStopTriggerTimer()
{
	// Kill the timer if it's running.
	if (hVolTriggerTimer != INVALID_HANDLE)
	{
		KillTimer(hVolTriggerTimer);
		hVolTriggerTimer = INVALID_HANDLE;
	}
}

/**
 * Resets volume trigger delay counters on one or more players.
 *
 * @param client	Optional. Specifies a single player to reset. Default is
 *				  -1, all players.
 */
void VolResetCountDown(int client = -1)
{
	// Check if a client is specified.
	if (client > -1)
	{
		// Reset volume counters.
		for (int iVolumeIndex = 0; iVolumeIndex < ZR_VOLUMES_MAX; iVolumeIndex++)
		{
			VolPlayerCountDown[client][iVolumeIndex] = -1.0;
		}
	}
	else
	{
		// Reset all volume counters.
		for (int clientIndex = 0; clientIndex < MAXPLAYERS + 1; clientIndex++)
		{
			for (int iVolumeIndex = 0; iVolumeIndex < ZR_VOLUMES_MAX; iVolumeIndex++)
			{
				VolPlayerCountDown[clientIndex][iVolumeIndex] = -1.0;
			}
		}
	}
}

/**
 * Updates all player locations. Used for initialization.
 *
 * Note: If a client is specified, it's NOT validated. This function assumes
 *	   the specified client is in game and alive.
 *
 * @param client	Optional. Specify single client to be updated. Default is
 *				  -1.
 */
void VolUpdatePlayerLocation(int client = -1)
{
	if (client > 0)
	{
		// Assume the client is valid and save location in array.
		GetClientAbsOrigin(client, VolPlayerLoc[client]);
	}
	else
	{
		for (client = 1; client <= MaxClients; client++)
		{
			// Validate client's connection state.
			if (!IsClientConnected(client) || !IsClientInGame(client) || !IsPlayerAlive(client))
			{
				continue;
			}
			
			// Save location in array.
			GetClientAbsOrigin(client, VolPlayerLoc[client]);
		}
	}
}

/**
 * Updates player locations and trigger events for each player that enter or
 * leave a volume.
 */
void VolUpdatePlayerChanges()
{
	bool volumeStates[ZR_VOLUMES_MAX];
	bool volumeNewStates[ZR_VOLUMES_MAX];
	
	bool newState;
	bool oldState;
	
	float trigger_delay;
	
	// Loop through all players.
	for (int client = 1; client <= MaxClients; client++)
	{
		// Validate client's connection state.
		if (!IsClientConnected(client) || !IsClientInGame(client) || !IsPlayerAlive(client))
		{
			// Skip client.
			continue;
		}
		
		// Get the current volume states based on player location cache.
		VolGetPlayerStates(client, volumeStates, sizeof(volumeStates));
		
		// Update player location cache.
		GetClientAbsOrigin(client, VolPlayerLoc[client]);
		
		// Get new volume states.
		VolGetPlayerStates(client, volumeNewStates, sizeof(volumeNewStates));
		
		// Loop through each volume and compare states.
		for (int iVolumeIndex = 0; iVolumeIndex < ZR_VOLUMES_MAX; iVolumeIndex++)
		{
			// Check if the volume is disabled and unused.
			if (!VolInUse(iVolumeIndex) || !VolIsEnabled(iVolumeIndex))
			{
				// Skip volume.
				continue;
			}
			
			// Check team filtering on the volume.
			if (!VolTeamFilterMatch(client, iVolumeIndex))
			{
				// Team filter mismatch.
				continue;
			}
			
			newState = volumeNewStates[iVolumeIndex];
			oldState = volumeStates[iVolumeIndex];
			
			// Check for no change.
			if (newState == oldState)
			{
				// No change. Skip to next volume.
				continue;
			}
			
			// Check if client entered the volume.
			if (newState && !oldState)
			{
				// Get trigger delay value.
				trigger_delay = Volumes[iVolumeIndex][Vol_TriggerDelay];
				
				// Check if the volume has a trigger delay.
				if (trigger_delay > 0.0)
				{
					// Set count down value.
					VolPlayerCountDown[client][iVolumeIndex] = trigger_delay;
				}
				else
				{
					// Update cache.
					VolPlayerInVolume[client][iVolumeIndex] = true;
					
					// No trigger delay, trigger event instantly.
					VolOnPlayerEnter(client, iVolumeIndex);
				}
			}
			
			// Check if client left the volume.
			else if (!newState && oldState)
			{
				// Make sure count down value is reset.
				VolPlayerCountDown[client][iVolumeIndex] = -1.0;
				
				// Only trigger left volume event if player already is in the
				// volume, so volumes with trigger delay won't get a left event
				// before the enter event.
				if (VolPlayerInVolume[client][iVolumeIndex])
				{
					// Update cache.
					VolPlayerInVolume[client][iVolumeIndex] = false;
					
					// Trigger event.
					VolOnPlayerLeave(client, iVolumeIndex);
				}
			}
		}
	}
}

/**
 * Callback for update timer. This is the main timer in volumetric features.
 */
public Action Event_VolUpdateTimer(Handle timer)
{
	VolUpdatePlayerChanges();
}

/**
 * Callback for trigger delay timer.
 */
public Action Event_VolTriggerTimer(Handle timer)
{
	float countDown;
	
	// Loop through all players.
	for (int client = 1; client <= MaxClients; client++)
	{
		// Loop through all volumes.
		for (int iVolumeIndex = 0; iVolumeIndex < ZR_VOLUMES_MAX; iVolumeIndex++)
		{
			// Check if volume is in use and enabled.
			if (!VolInUse(iVolumeIndex) || !VolIsEnabled(iVolumeIndex))
			{
				// Not in use or enabled, skip volume.
				continue;
			}
			
			// Get count down value.
			countDown = VolPlayerCountDown[client][iVolumeIndex];
			
			// Check if volume trigger delay is enabled.
			if (countDown > 0.0)
			{
				// Substract by trigger interval.
				countDown -= VolTriggerInterval;
				
				// Check if time is up.
				if (countDown <= 0.0)
				{
					// Update cache.
					VolPlayerInVolume[client][iVolumeIndex] = true;
					
					// Trigger volume enter event.
					VolOnPlayerEnter(client, iVolumeIndex);
					
					// Reset count down value.
					VolPlayerCountDown[client][iVolumeIndex] = -1.0;
				}
				
				// Update count down value and continue.
				VolPlayerCountDown[client][iVolumeIndex] = countDown;
			}
		}
	}
}

/**
 * Called when zr_vol CVAR is changed.
 */
public void VolEnabledChanged(Handle cvar, const char[] oldvalue, const char[] newvalue)
{
	bool isEnabled = view_as<bool>(StringToInt(newvalue));
	
	if (isEnabled)
	{
		// Volumetric features is enabled.
		VolEnable();
	}
	else
	{
		// Volumetric features is disabled.
		VolDisable();
	}
}
