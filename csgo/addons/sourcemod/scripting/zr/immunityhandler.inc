/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  immunityhandler.inc
 *  Type:		  Core module
 *  Description:   Manages infection immunity modes for every player.
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
 * Maximum delay of infection.
 */
#define IMMUNITY_MAX_DELAY		  300

/**
 * Maximum shield duration.
 */
#define IMMUNITY_MAX_SHIELD_TIME	300

/**
 * Timers for handling timed immunity actions.
 */
Handle PlayerImmunityTimer[MAXPLAYERS + 1] = {INVALID_HANDLE, ...};

/**
 * Remaining time of timed immunity actions.
 */
int PlayerImmunityDuration[MAXPLAYERS + 1] = {-1, ...};

/**
 * Cached attacker index for delayed infections, if available.
 */
int PlayerImmunityAttacker[MAXPLAYERS + 1] = {0, ...};

/**
 * Timestamp of last action. Usage depends on mode (cooldown, etc).
 */
int PlayerImmunityLastUse[MAXPLAYERS + 1] = {0, ...};

/**
 * Whether the player has passed a threshold (infect mode).
 */
bool PlayerImmunityThresholdPassed[MAXPLAYERS + 1] = {false, ...};

/*____________________________________________________________________________*/

/**
 * Console commands are being created.
 */
void ImmunityOnCommandsCreate()
{
	RegConsoleCmd(SAYHOOKS_KEYWORD_ZSHIELD, Command_DeployShield, "Deploy the shield, if available.");
}

/*____________________________________________________________________________*/

/** 
 * Client executed the deploy shield command.
 *
 * @param client	Client index.
 * @param argc	  Number of arguments.
 */
public Action Command_DeployShield(int client, int argc)
{
	// Block console.
	if (ZRIsConsole(client))
	{
		TranslationPrintToServer("Must be player");
		return Plugin_Handled;
	}
	
	// Attempt to deploy shield.
	ImmunityDeployShield(client);
	
	return Plugin_Handled;
}

/*____________________________________________________________________________*/

/**
 * Handles immunity when a client is about to be infected. This function may
 * delay or block infection according to the immunity mode class settings.
 *
 * @param client	Client that's being infected.
 * @param attacker  Attacker client (zombie).
 *
 * @return		  True if infection will be handled by this module, false if
 *				  infection can be applied instantly.
 */
bool ImmunityOnClientInfect(int client, int attacker)
{
	// Get immunity mode from client class.
	ImmunityMode mode = ClassGetImmunityMode(client);
	
	// Check mode.
	switch(mode)
	{
		case Immunity_None:
		{
			// Instant infection.
			return false;
		}
		case Immunity_Kill:
		{
			// Block infection. Damage is increased in ImmunityOnClientDamage.
			return true;
		}
		case Immunity_Full:
		{
			// Full immunity, do nothing.
			return true;
		}
		case Immunity_Infect:
		{
			return ImmunityInfectModeHandler(client);
		}
		case Immunity_Delay:
		{
			return ImmunityDelayModeHandler(client, attacker);
		}
		case Immunity_Shield:
		{
			return ImmunityShieldModeHandler(client);
		}
	}
	
	// Current mode doesn't apply to infection.
	return false;
}

/*____________________________________________________________________________*/

/**
 * TraceAttack hook.
 *
 * Returns whether attacker damage should be blocked. If damage is blocked this
 * module will handle it.
 *
 * @param client	Client index.
 * @param attacker  Attacker client, if any.
 * @param damage	Damage received by client.
 * @param hitgroup  Hitgroup receiving damage.
 *
 * @return		  True if damage should be blocked, false otherwise.
 */
bool ImmunityOnClientTraceAttack(int client, int attacker, float damage, int hitgroup, int damageType)
{
	// Check if there is no attacker (world damage).
	if (!ZRIsClientValid(attacker))
	{
		// Allow damage.
		return false;
	}
	
	// Get immunity mode from client class.
	ImmunityMode mode = ClassGetImmunityMode(client);
	
	// Check mode.
	switch(mode)
	{
		case Immunity_Full:
		{
			// Block damage (implies blocking knock back on zombies).
			return true;
		}
		case Immunity_Infect:
		{
			// Client must be human.
			if (InfectIsClientInfected(client))
			{
				// Allow damage.
				return false;
			}
			
			// Check if damage give HP below the infection threshold.
			if (ImmunityBelowInfectThreshold(client, damage))
			{
				PlayerImmunityThresholdPassed[client] = true;
			}
			else
			{
				PlayerImmunityThresholdPassed[client] = false;
			}
		}
		case Immunity_Damage:
		{
			// Client must be zombie.
			if (!InfectIsClientInfected(client))
			{
				// Allow damage.
				return false;
			}
			
			// Get attacker weapon.
			char weapon[32];
			weapon[0] = 0;
			if (damageType == DMG_BLAST)
			{
				// Most likely a HE grenade. GetClientWeapon can't be used if
				// the attacker throw grenades. The attacker may switch weapon
				// before the grenade explodes.
				strcopy(weapon, sizeof(weapon), "hegrenade");
			}
			else
			{
				GetClientWeapon(attacker, weapon, sizeof(weapon));
			}
			
			// Since damage is blocked, trigger knock back hurt event manually.
			KnockbackOnClientHurt(client, attacker, weapon, hitgroup, RoundToNearest(damage));
			
			// Block damage from attacker.
			return true;
		}
		case Immunity_Shield:
		{
			// Client must be human.
			if (InfectIsClientInfected(client))
			{
				// Allow damage.
				return false;
			}
			
			// Check if shield is active.
			if (PlayerImmunityTimer[client] != INVALID_HANDLE)
			{
				// Block damage for humans with shield enabled (preventing
				// zombies from stabbing them to death).
				return true;
			}
		}
	}
	
	// Allow damage.
	return false;
}

/*____________________________________________________________________________*/

/**
 * TakeDamage hook.
 *
 * Blocks or modifies damage in certain situations.
 *
 * @param client	Client index.
 * @param attacker  Attacker client, if any.
 * @param damage	Damage received by client.
 * @param weapon	Weapon entity.
 *
 * @return		  Plugin_Handled if damage was blocked, Plugin_Changed if
 *				  damage was modified, Plugin_Continue otherwise.
 */
Action ImmunityOnClientDamage(int client, int attacker, float &damage)
{
	// Check if there is no attacker (world damage).
	if (!ZRIsClientValid(attacker))
	{
		// Allow damage.
		return Plugin_Continue;
	}
	
	// Check if spawn protection is on.
	if (bInfectImmune[client])
	{
		// Block damage.
		return Plugin_Handled;
	}
	
	// Get immunity mode from client class.
	ImmunityMode mode = ClassGetImmunityMode(client);
	
	switch(mode)
	{
		case Immunity_Kill:
		{
			// Client must be human and attacker must be zombie.
			if (InfectIsClientInfected(client)
				|| !InfectIsClientInfected(attacker))
			{
				// Don't modify damage.
				return Plugin_Continue;
			}
			
			// A zombie is attacking a human in kill immunity mode. Increase
			// damage so human will be instantly killed. (Using a high damage
			// value in case the human class has a lot of HP.)
			damage = 60000.0;
			
			// Update score and health gain.
			InfectUpdateScore(attacker, client);
			
			// Damage was changed.
			return Plugin_Changed;
		}
		case Immunity_Infect:
		{
			// Prevent humans with low HP from dying when a zombie is
			// attacking, and stab to death is disabled (threshold above zero).
			if (ImmunityBelowInfectThreshold(client, damage))
			{
				// Fake hurt event because it's not triggered when the damage
				// was removed (because no one is actually hurt).
				InfectOnClientHurt(client, attacker, "knife");
				
				// Block damage to prevent player from dying.
				return Plugin_Handled;
			}
		}
		case Immunity_Delay:
		{
			// Fake hurt event because it's not triggered when the damage
			// was removed (because no one is actually hurt). This event must
			// still be triggered so that subsequent attacks are registered,
			// without dealing any damage.
			InfectOnClientHurt(client, attacker, "knife");
			
			// Block damage to prevent player from dying.
			return Plugin_Handled;
		}
	}
	
	// Allow damage.
	return Plugin_Continue;
}

/*____________________________________________________________________________*/

/**
 * Handles infect mode immunity.
 *
 * Allow humans to receive damage from zombies until HP is below a certain
 * threshold. If the threshold is zero, never infect.
 *
 * @param client	Client that's being infected.
 * @param attacker  Attacker client (zombie).
 *
 * @return		  True if infection will be handled by this module, false if
 *				  infection can be applied instantly.
 */
bool ImmunityInfectModeHandler(int client)
{
	// Note: ImmunityOnClientDamage and ImmunityOnClientTraceAttack hook into
	//	   the damage module to prevent humans with low HP from dying when
	//	   they're not supposed to.
	
	int threshold = ClassGetImmunityAmount(client);
	// Check if infection is disabled.
	if (threshold == 0)
	{
		// Infection is handled here: blocked.
		return true;
	}
	
	if (PlayerImmunityThresholdPassed[client])
	{
		// Client HP below threshold, allow instant infection.
		return false;
	}
	
	return true;
}

/*____________________________________________________________________________*/

/**
 * Handles delayed infections.
 *
 * @param client	Client that's being infected.
 *
 * @return		  True if infection will be handled by this module, false if
 *				  infection can be applied instantly.
 */
bool ImmunityDelayModeHandler(int client, int attacker)
{
	// Check if an infection is in progress
	if (PlayerImmunityTimer[client] != INVALID_HANDLE)
	{
		// Additional attacks while a delayed infection is in progress will
		// speedup the infection.
		
		// Get reduction amount for subsequent zombie attack.
		int reduction = ClassGetImmunityCooldown(client);
		if (reduction > 0)
		{
			// Reduce duration. Add one because the timer handler itself reduce
			// duration by one.
			PlayerImmunityDuration[client] -= reduction + 1;
			
			// Note: This feature can be used to trigger an instant infection
			//	   when a human receive a second attack, by setting the
			//	   reduction value high enough.
			
			// Trigger timer event to reduce delay and infect faster.
			ImmunityDelayTimerHandler(PlayerImmunityTimer[client], client);
		}
		
		// Block infection.
		return true;
	}
	
	// Start a delayed infection. Initialize duration and attacker.
	PlayerImmunityDuration[client] = ClassGetImmunityAmount(client);
	PlayerImmunityAttacker[client] = attacker;
	
	// Create repated 1-second timer for handling the countdown.
	PlayerImmunityTimer[client] = CreateTimer(1.0, ImmunityDelayTimerHandler, client, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
	
	// Block infection.
	return true;
}

/*____________________________________________________________________________*/

/**
 * Delayed infection timer handler. Handles countdown and infection when time
 * is up.
 */
public Action ImmunityDelayTimerHandler(Handle timer, any client)
{
	// Verify that client is still connected and alive.
	if (!IsClientInGame(client) || !IsPlayerAlive(client))
	{
		// Client disconnected or died. Abort immunity action.
		ImmunityAbortHandler(client);
		return Plugin_Stop;
	}
	
	// Reduce duration.
	PlayerImmunityDuration[client] -= 1;
	
	// Check if time is up.
	if (PlayerImmunityDuration[client] <= 0)
	{
		// Get attacker before cleaning up.
		int attacker = PlayerImmunityAttacker[client];
		
		// Time is up. Reset data.
		PlayerImmunityDuration[client] = 0;
		ImmunityAbortHandler(client);
		
		// Infect client. Give credit to the stored attacker.
		InfectHumanToZombie(client, attacker);
		
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

/*____________________________________________________________________________*/

/**
 * Handles shield mode immunity when client is about to become infected.
 *
 * Zombies will get a shield against knock back, while humans become immune of
 * infections.
 *
 * @param client	Client deploying shield.
 *
 * @return		  True if infection will be handled by this module, false if
 *				  infection can be applied instantly.
 */
bool ImmunityShieldModeHandler(int client)
{
	// Check if shield is active.
	if (PlayerImmunityTimer[client] != INVALID_HANDLE)
	{
		// Block infection.
		return true;
	}
	
	// Shield is not active, allow infection.
	return false;
}

/*____________________________________________________________________________*/

/**
 * Attempts to deploy the shield.
 *
 * @param client	Client index.
 */
void ImmunityDeployShield(int client)
{
	// Check if shield is available.
	if (!ImmunityCanDeployShield(client))
	{
		// Not available.
		return;
	}
	
	// Deploy the shield.
	PlayerImmunityDuration[client] = ClassGetImmunityAmount(client);
	PlayerImmunityLastUse[client] = GetTime();
	PlayerImmunityTimer[client] = CreateTimer(1.0, ImmunityShieldTimerHandler, client, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
	
	// Trigger initial countdown.
	ImmunityShieldTimerHandler(PlayerImmunityTimer[client], client);
}

/*____________________________________________________________________________*/

/**
 * Shield timer handler. Handles countdown and shield removal when time is up.
 */
public Action ImmunityShieldTimerHandler(Handle timer, any client)
{
	// Verify that client is still connected and alive.
	if (!IsClientInGame(client) || !IsPlayerAlive(client))
	{
		// Client disconnected or died. Abort immunity action.
		ImmunityAbortHandler(client);
		return Plugin_Stop;
	}
	
	// Reduce duration.
	PlayerImmunityDuration[client] -= 1;
	
	// Print remaining shield time.
	TranslationPrintCenterText(client, "Immunity Shield Time Left", PlayerImmunityDuration[client]);
	
	// Check if time is up.
	if (PlayerImmunityDuration[client] <= 0)
	{
		// Time is up. Reset data, but not last use timestamp.
		ImmunityAbortHandler(client, false);
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

/*____________________________________________________________________________*/

/**
 * Aborts any immunity mode in action (shields, delays, etc.). Resets values.
 *
 * @param client		Client that's aborting immunity mode actions.
 * @param resetLastUse  Reset timestamp of last use. This will reset cooldown.
 */
void ImmunityAbortHandler(int client, bool resetLastUse = true)
{
	// Stop timer, if running.
	ZREndTimer(PlayerImmunityTimer[client]);
	
	// Reset data.
	PlayerImmunityDuration[client] = -1;
	PlayerImmunityAttacker[client] = 0;
	PlayerImmunityThresholdPassed[client] = false;
	
	if (resetLastUse)
	{
		PlayerImmunityLastUse[client] = 0;
	}
}

/*____________________________________________________________________________*/

/**
 * Aborts all immunity modes in action.
 *
 * @param resetLastUse  Reset timestamp of last use. This will reset cooldown.
 */
void ImmunityAbortAll(bool resetLastUse = true)
{
	for (int client = 0; client < MAXPLAYERS + 1; client++)
	{
		ImmunityAbortHandler(resetLastUse);
	}
}

/*____________________________________________________________________________*/

/**
 * Client is about to receive knock back.
 *
 * @param	   Client that's receiving knock back.
 *
 * @return	  True if knock back should be blocked, false otherwise.
 */
bool ImmunityOnClientKnockBack(int client)
{
	// Knock back filter is currently only used in shield mode.
	if (ClassGetImmunityMode(client) == Immunity_Shield)
	{
		// Client must be zombie. (In case a future change allow knock back
		// on humans.)
		if (!InfectIsClientInfected(client))
		{
			// Client is human, allow knock back.
			return false;
		}
		
		// Block knock back if shield is deployed.
		if (PlayerImmunityTimer[client] != INVALID_HANDLE)
		{
			// Block knock back.
			return true;
		}
	}
	
	// Allow knock back.
	return false;
}

/*____________________________________________________________________________*/

/**
 * Client was infected.
 */
void ImmunityOnClientInfected(int client)
{
	// In case client was infected through an admin command or mother zombie
	// selection, abort other actions in progress.
	ImmunityAbortHandler(client);
}

/*____________________________________________________________________________*/

/**
 * Client was turned back into a human.
 */
void ImmunityOnClientHuman(int client)
{
	ImmunityAbortHandler(client);
}

/*____________________________________________________________________________*/

/**
 * Client died.
 */
void ImmunityOnClientDeath(int client)
{
	ImmunityAbortHandler(client, false);
}

/*____________________________________________________________________________*/

/**
 * Client connected to the server.
 */
void ImmunityClientInit(int client)
{
	ImmunityAbortHandler(client);
}

/*____________________________________________________________________________*/

/**
 * Client spawned.
 */
void ImmunityClientSpawn(int client)
{
	ImmunityAbortHandler(client, false);
}

/*____________________________________________________________________________*/

/**
 * Client disconnected.
 */
void ImmunityOnClientDisconnect(int client)
{
	ImmunityAbortHandler(client);
	
	// Loop through attacker cache and remove client (set to 0).
	for (int victim = 0; victim < sizeof(PlayerImmunityAttacker); victim++)
	{
		if (PlayerImmunityAttacker[victim] == client)
		{
			// The victim was attacked by this client, but the client is
			// disconnecting now. Reset the attacker index to the world index.
			PlayerImmunityAttacker[victim] = 0;
		}
	}
}

/*____________________________________________________________________________*/

/**
 * Client changed team.
 */
void ImmunityOnClientTeam(int client)
{
	ImmunityAbortHandler(client);
}

/*____________________________________________________________________________*/

/**
 * Round ended.
 */
void ImmunityOnRoundEnd()
{
	ImmunityAbortAll();
}

/*____________________________________________________________________________*/

/**
 * Map ended.
 */
void ImmunityOnMapEnd()
{
	ImmunityAbortAll();
}

/*____________________________________________________________________________*/

/**
 * Returns whether the specified damage will take a client's HP below the
 * infection threshold. Only used by "infect" immunity mode.
 *
 * If threshold is disabled (zero) this function will always return false.
 *
 * @param client	Client index.
 * @param damage	Damage applied to client.
 *
 * @return		  True if client HP go below threshold (immunity_amount) when
 *				  applying damage, false if above threshold or if threshold
 *				  is disabled (zero).
 */
bool ImmunityBelowInfectThreshold(int client, float damage)
{
	int threshold = ClassGetImmunityAmount(client);
	int clientHP = GetClientHealth(client);
	int dmg = RoundToNearest(damage);
	
	// Check if the damage go below the HP threshold. Client can only go below
	// threshold when threshold is enabled (above zero).
	if (clientHP - dmg <= threshold && threshold > 0)
	{
		return true;
	}
	
	return false;
}

/*____________________________________________________________________________*/

/**
 * Converts a string to an immunity mode.
 *
 * @param mode	  String to convert.
 *
 * @return		  Immunity mode or Immunity_Invalid on error.
 */
ImmunityMode ImmunityStringToMode(const char[] mode)
{
	if (strlen(mode) == 0)
	{
		return Immunity_Invalid;
	}
	
	if (StrEqual(mode, "none", false))
	{
		return Immunity_None;
	}
	if (StrEqual(mode, "kill", false))
	{
		return Immunity_Kill;
	}
	else if (StrEqual(mode, "full", false))
	{
		return Immunity_Full;
	}
	else if (StrEqual(mode, "infect", false))
	{
		return Immunity_Infect;
	}
	else if (StrEqual(mode, "damage", false))
	{
		return Immunity_Damage;
	}
	else if (StrEqual(mode, "delay", false))
	{
		return Immunity_Delay;
	}
	else if (StrEqual(mode, "shield", false))
	{
		return Immunity_Shield;
	}
	
	return Immunity_Invalid;
}

/*____________________________________________________________________________*/

/**
 * Converts an immunity mode to a string.
 *
 * @param mode	  Mode to convert.
 * @param buffer	Destination string buffer.
 * @param maxlen	Size of buffer.
 *
 * @return		  Number of cells written.
 */
int ImmunityModeToString(ImmunityMode mode, char[] buffer, int maxlen)
{
	if (mode == Immunity_Invalid)
	{
		return 0;
	}
	
	switch (mode)
	{
		case Immunity_None:
		{
			return strcopy(buffer, maxlen, "none");
		}
		case Immunity_Kill:
		{
			return strcopy(buffer, maxlen, "kill");
		}
		case Immunity_Full:
		{
			return strcopy(buffer, maxlen, "full");
		}
		case Immunity_Infect:
		{
			return strcopy(buffer, maxlen, "infect");
		}
		case Immunity_Damage:
		{
			return strcopy(buffer, maxlen, "damage");
		}
		case Immunity_Delay:
		{
			return strcopy(buffer, maxlen, "delay");
		}
		case Immunity_Shield:
		{
			return strcopy(buffer, maxlen, "shield");
		}
	}
	
	return 0;
}

/*____________________________________________________________________________*/

/**
 * Returns whether the amount value is valid for the specified mode.
 *
 * @param mode	  Immunity mode to validate against.
 * @param amount	Amount value to test.
 *
 * @return		  True if valid, false otherwise.
 */
bool ImmunityIsValidAmount(ImmunityMode mode, int amount)
{
	switch (mode)
	{
		case Immunity_Invalid:
		{
			return false;
		}
		case Immunity_None:
		{
			// Immunity mode disabled, amount ignored.
			return true;
		}
		case Immunity_Kill:
		{
			// Amount isn't used in this mode.
			return true;
		}
		case Immunity_Full:
		{
			// Amount isn't used in this mode.
			return true;
		}
		case Immunity_Infect:
		{
			// Check if HP threshold is negative.
			if (amount < 0)
			{
				return false;
			}
			
			// There's no upper limit. If the value is too high it will
			// overflow and become negative.
		}
		case Immunity_Damage:
		{
			// Amount isn't used in this mode.
			return true;
		}
		case Immunity_Delay:
		{
			if (amount <= 0 || amount > IMMUNITY_MAX_DELAY)
			{
				return false;
			}
		}
		case Immunity_Shield:
		{
			if (amount <= 0 || amount > IMMUNITY_MAX_SHIELD_TIME)
			{
				return false;
			}
		}
		default:
		{
			// Invalid mode.
			return false;
		}
	}
	
	// Passed.
	return true;
}

/*____________________________________________________________________________*/

/**
 * Returns whether the cooldown value is valid for the specified mode.
 *
 * @param mode	  Immunity mode to validate against.
 * @param cooldown  Cooldown value to test.
 *
 * @return		  True if valid, false otherwise.
 */
bool ImmunityIsValidCooldown(ImmunityMode mode, int cooldown)
{
	switch (mode)
	{
		case Immunity_Invalid:
		{
			return false;
		}
		case Immunity_None:
		{
			// Immunity mode disabled, amount ignored.
			return true;
		}
		case Immunity_Kill:
		{
			// Cooldown isn't used in this mode.
			return true;
		}
		case Immunity_Full:
		{
			// Cooldown isn't used in this mode.
			return true;
		}
		case Immunity_Infect:
		{
			// Cooldown isn't used in this mode.
			return true;
		}
		case Immunity_Damage:
		{
			// Cooldown isn't used in this mode.
			return true;
		}
		case Immunity_Delay:
		{
			if (cooldown < 0)
			{
				return false;
			}
			
			// No upper limit. It may be intentional to use a high value so that
			// the section attack will remove all delay and infect instantly.
		}
		case Immunity_Shield:
		{
			if (cooldown < 0)
			{
				return false;
			}
			
			// No upper limit. It may be intentional to use a high value so that
			// the shield can only be used once per life.
		}
		default:
		{
			// Invalid mode.
			return false;
		}
	}
	
	// Passed.
	return true;
}

/*____________________________________________________________________________*/

/**
 * Returns whether the client is allowed to deploy a shield now. Tests whether
 * the client has shield immunity mode and whether cooldown is done, or a shield
 * is already active.
 *
 * @param client			Client index.
 * @param printResponse	 Whether a response message is printed on the
 *						  client's screen.
 *
 * @return				  True if shield can be deployed, false otherwise.
 */
bool ImmunityCanDeployShield(int client, bool printResponse = true)
{
	// Check immunity mode.
	if (ClassGetImmunityMode(client) != Immunity_Shield)
	{
		if (printResponse)
		{
			TranslationPrintToChat(client, "Immunity Shield Not Available");
		}
		return false;
	}
	
	// Check if cooldown is still in progress.
	int cooldown = ClassGetImmunityCooldown(client);
	int timeLeft = PlayerImmunityLastUse[client] + cooldown - GetTime();
	if (timeLeft > 0)
	{
		if (printResponse)
		{
			TranslationPrintToChat(client, "Immunity Shield Cooldown", timeLeft);
		}
		return false;
	}
	
	// Check if a shield is already deployed.
	if (PlayerImmunityTimer[client] != INVALID_HANDLE)
	{
		return false;
	}
	
	// Humans cannot deploy shield before first zombie.
	if (!g_bZombieSpawned)
	{
		return false;
	}
	
	return true;
}
