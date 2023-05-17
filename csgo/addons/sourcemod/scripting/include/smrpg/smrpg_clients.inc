#if defined _smrpg_clients_included
  #endinput
#endif
#define _smrpg_clients_included

#include <smrpg>

/**
 * Gets a client's current RPG level.
 *
 * @param client         The client
 * @return The client's rpg level (level start at 1)
 * @error Invalid client index
 */
native int SMRPG_GetClientLevel(int client);

/**
 * Sets a client's RPG level to another level.
 *
 * @param client         The client
 * @param level          The new level of the client
 * @return True, if the level was set successfully, false if some plugin blocked it in the SMRPG_OnClientLevel forward.
 * @error Invalid client index
 */
native bool SMRPG_SetClientLevel(int client, int level);

/**
 * Gets a client's current RPG credits.
 *
 * @param client         The client
 * @return The client's rpg credits.
 * @error Invalid client index
 */
native int SMRPG_GetClientCredits(int client);

/**
 * Sets a client's RPG credits.
 *
 * @param client         The client
 * @param level          The new credits of the client
 * @return True, if the credits were set successfully, false if some plugin blocked it in the SMRPG_OnClientCredits forward.
 * @error Invalid client index
 */
native bool SMRPG_SetClientCredits(int client, int credits);

/**
 * Gets a client's current RPG experience.
 *
 * @param client         The client
 * @return The client's rpg experience
 * @error Invalid client index
 */
native int SMRPG_GetClientExperience(int client);

/**
 * Sets a client's RPG experience.
 * Doesn't level up the client, if he gets more experience than he'd need for a next level.
 * Use SMRPG_AddClientExperience for that.
 *
 * @param client         The client
 * @param level          The new experience of the client
 * @return True, if the experience were set successfully, false if some plugin blocked it in the SMRPG_OnClientExperience forward.
 * @error Invalid client index
 */
native bool SMRPG_SetClientExperience(int client, int exp);

/**
 * Gets the rpg rank of a player.
 * The returned rank is a cached value and the current rank is fetched afterwards.
 *
 * @param client        The client
 * @return The client's rpg rank or -1 if the rank wasn't fetched yet or for bots.
 * @error Invalid client index
 */
native int SMRPG_GetClientRank(int client);

/**
 * Get the total number of ranked players in the database.
 * The returned value is from the cache and the cache is updated afterwards.
 *
 * @return Total number of ranked players.
 */
native int SMRPG_GetRankCount();

/**
 * Get the top 10 players.
 * The owner handle in the callback is always null just to not leak the database handle :)
 * The query returned is
 *    SELECT name, level, experience, credits FROM ..
 *
 * @param callback    The default threaded sql callback. The query Handle will be in "hndl".
 * @param data        Optional custom data passed to the callback.
 */
native void SMRPG_GetTop10Players(SQLQueryCallback callback, any data=0);

/**
 * Resets a clients complete rpg stats including all bought upgrades.
 * CANNOT BE UNDONE!
 *
 * @param client				The client index
 * @error Invalid client index
 */
native void SMRPG_ResetClientStats(int client);

/**
 * Get the time when a client's rpg stats were last reset. Returns the time the player first joined, if his stats were never reset in between.
 *
 * @param client				The client index
 * @return						The unix timestamp when the client was last reset.
 * @error Invalid client index
 */
native int SMRPG_GetClientLastResetTime(int client);

/**
 * Get the time when the client was last active on the server.
 *
 * @param client				The client index
 * @return						The unix timestamp when the client was last saved on the server.
 * @error Invalid client index
 */
native int SMRPG_GetClientLastSeenTime(int client);

/**
 * Check if a client is away from keyboard.
 * This is done by saving the player's last position regularly and see if it is still the same later.
 * Shooting resets the timer.
 *
 * @param client				The client index
 * @return	True if player afk, false otherwise.
 * @error Invalid client index
 */
native bool SMRPG_IsClientAFK(int client);

/**
 * Check if a client just spawned and hasn't pressed any buttons yet.
 *
 * @param client				The client index
 * @return	True if player just spawned, false otherwise.
 * @error Invalid client index
 */
native bool SMRPG_IsClientSpawnProtected(int client);

/**
 * Called when the core wants a reason string to be translated so it's displayed in the recent added experience panel.
 * Should look like
 *   15 exp. for killing (name of [other])
 *   100 exp. for winning the round
 *
 * @param client        The client who got experience and in which language the reason should be translated.
 * @param reason        The reason string passed in SMRPG_AddClientExperience
 * @param iExperience   The amount of experience added.
 * @param other         Optionally the index of the other client involved in the reason for this experience. -1 if no other entity involved.
 * @param buffer        The buffer to store the translated reason string in.
 * @param maxlen        The maximal length of the translation buffer.
 */
typedef SMRPG_ExpTranslationCb = function void (int client, const char[] reason, int iExperience, int other, char[] buffer, int maxlen);

/**
 * Adds experience to a client.
 * If he gets enough experience to level up, he levels up.
 *
 * @param client         The client index.
 * @param level          The experience to add. Changed to the actual amount given, if some other plugin altered it in the SMRPG_OnAddExperience forward.
 * @param reason         The reason this experience was added.
 * @param bHideNotice    Set to true, if you want a notification displayed in the HintText area on the client's screen, telling him the amount of experience he just earned, or to false if not.
 * @param other          Optional index of other client involved in the reason for this experience. e.g. the victim which was hurt. Set to -1 if no other particular entity was involved.
 * @param callback       Optional translation callback to translate the reason into a human readable format. (See SMRPG_ExpTranslationCb)
 * @return               True if the experience was added, false otherwise.
 * @error Invalid client index
 */
native bool SMRPG_AddClientExperience(int client, int &exp, const char[] reason, bool bHideNotice, int other=-1, SMRPG_ExpTranslationCb callback=view_as<SMRPG_ExpTranslationCb>(INVALID_FUNCTION));

/**
 * Calculate the amount of experience needed to reach the next level.
 * Level start at 1.
 * 
 * @return The amount of experience needed to reach iLevel+1.
 */
native int SMRPG_LevelToExperience(int iLevel);

/**
 * Called when a client's upgrade levels were loaded from the database.
 * 
 * @param client         The client who's levels were just loaded.
 */
forward void SMRPG_OnClientLoaded(int client);

/**
 * Called when the level of a client changes.
 * You can stop that from happening by returning Plugin_Handled.
 *
 * @param client         The client, who's level is going to be changed.
 * @param oldlevel       The old, current level of the client.
 * @param newlevel       The new level the client is going to be set to.
 * @return >= Plugin_Handled to block, Plugin_Continue to let it pass.
 */
forward Action SMRPG_OnClientLevel(int client, int oldlevel, int newlevel);

/**
 * Called after the level of a client changed.
 *
 * @param client         The client, who's level has changed.
 * @param oldlevel       The old level of the client.
 * @param newlevel       The new, current level of the client.
 */
forward void SMRPG_OnClientLevelPost(int client, int oldlevel, int newlevel);

/**
 * Called when the experience of a client changes.
 * You can stop that from happening by returning Plugin_Handled.
 *
 * @param client         The client, who's experience is going to be changed.
 * @param oldexp         The old, current experience of the client.
 * @param newexp         The new experience the client is going to be set to.
 * @return >= Plugin_Handled to block, Plugin_Continue to let it pass.
 */
forward Action SMRPG_OnClientExperience(int client, int oldexp, int newexp);

/**
 * Called after the experience of a client changed.
 *
 * @param client         The client, who's experience has changed.
 * @param oldexp         The old experience of the client.
 * @param newexp         The new, current experience of the client.
 */
forward void SMRPG_OnClientExperiencePost(int client, int oldexp, int newexp);

/**
 * Called when the credits of a client changes.
 * You can stop that from happening by returning Plugin_Handled.
 *
 * @param client         The client, who's credits is going to be changed.
 * @param oldcredits     The old, current credits of the client.
 * @param newcredits     The new credits the client is going to be set to.
 * @return >= Plugin_Handled to block, Plugin_Continue to let it pass.
 */
forward Action SMRPG_OnClientCredits(int client, int oldcredits, int newcredits);

/**
 * Called after the credits of a client changed.
 *
 * @param client         The client, who's credits have changed.
 * @param oldcredits     The old credits of the client.
 * @param newcredits     The new, current credits of the client.
 */
forward void SMRPG_OnClientCreditsPost(int client, int oldcredits, int newcredits);

/**
 * List of default reasons the core plugin adds experience to clients for.
 */
#define ExperienceReason_PlayerHurt "def_playerhurt" // Give experience to the attacker when he hurt an enemy
#define ExperienceReason_PlayerKill "def_playerkill" // Give experience to the attacker when he killed an enemy
#define ExperienceReason_RoundEnd "def_roundend" // Give experience to the winning team
#define ExperienceReason_Admin "def_admin" // An admin gave experience through commands or admin menu

/**
 * Called when we are about to give a client some experience.
 * You can modify the experience or block it all together.
 * The core calls this with the above defined reasons. This is useful, if you want to add more game specific experience handling which override the default ones.
 *
 * @param client         The client, which is about to get some experience.
 * @param reason         The reason why this client gets experience.
 * @param iExperience    By reference. The experience to give to the player. You can change it to whatever you like.
 * @param other          The other entity which was involved in adding this experience. e.g. the victim which was hurt. -1 if no other particular entity was involved.
 * @return >= Plugin_Handled to block it, Plugin_Continue to pass, Plugin_Changed if you modified iExperience.
 */
forward Action SMRPG_OnAddExperience(int client, const char[] reason, int &iExperience, int other);

/**
 * Called after a client received some experience.
 * The core calls this with the above defined reasons.
 *
 * @param client         The client, which got some experience.
 * @param reason         The reason why this client got experience.
 * @param iExperience    The experience to given to the player.
 * @param other          The other entity which was involved in adding this experience. e.g. the victim which was hurt. -1 if no other particular entity was involved.
 */
forward void SMRPG_OnAddExperiencePost(int client, const char[] reason, int iExperience, int other);

/**
 * Types of experience multipliers that can be set individually per weapon.
 */
enum WeaponExperienceType {
	WeaponExperience_Damage, // The experience for hurting an enemy multiplied by the damage done.
	WeaponExperience_Kill, // The experience for a kill multiplied by the victim's level.
	WeaponExperience_Bonus // Extra experience to give on top of the regular experience on a kill. (Default 0)
};

/**
 * Returns the settings for the weapon as set in configs/smrpg/weapon_experience.cfg.
 * If there is no entry for this weapon in the config file or the selected type isn't changed,
 * it defaults back to the global settings of the smrpg_exp_damage and smrpg_exp_kill convars.
 * The bonus is 0 by default if not specified otherwise in the config file.
 *
 * @param sWeapon		The full weapon classname of the weapon to check for individual experience settings.
 * @param type			The type of the experience multiplier to get. (See WeaponExperienceType)
 *
 * @return The experience multiplier for the selected type for this weapon.
 */
native float SMRPG_GetWeaponExperience(const char[] sWeapon, WeaponExperienceType type);

/**
 * Calculate the ratio of team1:team2.
 * This is e.g. used to lower the amount of experience earned, when a winning team has more players than the other.
 * 
 * @param iTeam          The team index of the player which is about to get experience.
 * @return The teammember amount ratio of iTeam : otherTeam.
 */
stock float SMRPG_TeamRatio(int iTeam)
{
	if(iTeam <= 1)
		return 0.0;
	
	static ConVar hUseTeamRatio = null;
	if(hUseTeamRatio == null)
		hUseTeamRatio = FindConVar("smrpg_exp_use_teamratio");
	
	// Server is configured to ignore team ratio?
	if(hUseTeamRatio != null && !hUseTeamRatio.BoolValue)
		return 1.0;
	
	float fTeamRatio;
	
	if(iTeam == 2)
		fTeamRatio = float(GetTeamClientCount(2)) / float(GetTeamClientCount(3));
	else
		fTeamRatio = float(GetTeamClientCount(3)) / float(GetTeamClientCount(2));
	return fTeamRatio;
}