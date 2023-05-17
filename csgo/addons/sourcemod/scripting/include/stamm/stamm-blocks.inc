#if defined _stamm_blocks_included
	#endinput
#endif
#define _stamm_blocks_included




/**
 * Blocks are used to get information about when a player should get your feature.
 * It have to be a .txt file, named like the basename of your extension and you need to put it in cfg/stamm/levels.
 * You can set up to 100 blocks in the file.
 * A block structure is:
 *
 * "<name_of_the_block>" "<level_of_the_block>"
 *
 * The name you can define by yourself and retrieve it with the API. The level have to be set by the server admin.
 * The block id is the position number of a block in the block file, beginning from 1.
 *
 * E.g.:
 * "name1"     "Silver"      // This will be id 1
 * "name234"   "Gold"        // This will be id 2
 * "name9"     "Platinum"    // This will be id 3
 *
 * If you only have the name you should use the native STAMM_GetBlockOfName to get the id.
 */





/**
 * This will return the level the server admin wants for a block (TODO: No Buying).
 *
 * @param block         Block id to get level for.
 *
 * @return              The level need to get that block. TODO: -1 if block is for buying.
 * @error               Block or feature is invalid TODO: it's a shop feature.
 */
#pragma deprecated Use STAMM_GetBlockLevel instead!
native STAMM_GetLevel(block=1);


/**
 * This will return the level the server admin wants for a block (TODO: No Buying).
 *
 * @param block         Block id to get level for.
 *
 * @return              The level need to get that block. TODO: -1 if block is for buying.
 * @error               Block or feature is invalid TODO: it's a shop feature.
 */
native STAMM_GetBlockLevel(block=1);


/**
 * Will convert a block name to it's block id
 *
 * @param name          The name of the bock.
 *
 * @return              The id of the block.
 * @error               Feature is invalid.
 */
native STAMM_GetBlockOfName(const String:name[]);


/**
 * Returns the name you set up for a block.
 *
 * @param block         Block id to get name for.
 * @param name          String to store name in.
 * @param maxlength     Maxlength of the name.
 *
 * @noreturn
 * @error               Block or feature is invalid.
 */
native STAMM_GetBlockName(block=1, String:name[], maxlength);


/**
 * If you have more than one block this will return the highest block the client is in.
 * So if you have blocks with the levels "Bronze", "Silver" and "Gold", and the player is Gold VIP, it will return block 3.
 *
 * @param client        Client.

 * @return              0 = client is in no  block, x = block id.
 * @error               Client or feature is invalid.
 */
native STAMM_GetClientBlock(client);


/**
 * Returns the number of blocks found in the blocks file.
 *
 * @return              Number of blocks found.
 * @error               Feature is invalid.
 */
native STAMM_GetBlockCount();


/**
 * DEPRECATED! Does nothing. Use Forward STAMM_OnClientRequestFeatureInfo instead!
 *
 * This will convert the block to the level and add a text in the stamm menu
 * with information what the player will get on this level, so make this detailed!
 *
 * @param block         The block id you want to add a description to.
 * @param description   Description for this block.
 * @param ...           Format arguments.
 *
 * @return              Returns true on success, otherwise false.
 * @error               Block or feature is invalid.
 */
#pragma deprecated Does nothing. Use Forward STAMM_OnClientRequestFeatureInfo instead!
native bool:STAMM_AddBlockDescription(block=1, const String:description[], any:...);


/**
 * TODO: 
 * Returns the points needed to buy that block (Buying).
 *
 * @param block         Block to search for.
 * @return              Points to buy that block. -1 if level needed.
 * @error               Block or feature is invalid or it's a level feature.
 
native STAMM_GetPoints(block=1); */


/**
 * TODO: 
 * Returns whether the block is for buying or not.
 *
 * @param block         Block to check.
 * @return              true when the block needs to be bought, otherwise false.
 * @error               Block or feature is invalid.
 
native bool:STAMM_IsShop(block=1); */