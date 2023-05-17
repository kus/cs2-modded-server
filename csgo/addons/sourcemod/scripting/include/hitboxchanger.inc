/**
 * Extension Include for HitboxChanger.ext.2.csgo
 * Interface for changing hitboxes on a playermodel
 * Author: PikaJew
 * Website: https://cascadeservers.net/
 * 
 * Example:
 * To emulate the solution to lag in this thread: https://forums.alliedmods.net/showthread.php?t=288277
 * Simply set the first 2 hitboxes to have the attributes of the feet hitboxes and set the num hitboxes to 2\
 * CHECKME: Do you need any hitboxes for this ??? Why keep feet ???
 *
 * Default Left Foot:	bone: 67, group: 6, bbmin: [ -2.5, -3.8, -2.8 ], bbmax: [ 10.4, -0.2, 2.0 ], angle: [ 0.0, 24.1, 0.0 ], radius: -1
 * Default Right Foot:	bone: 74, group: 7, bbmin: [ -10.4, 0.3, -2.0 ], bbmax: [ 2.6,   4.0, 2.8 ], angle: [ 0.0, 24.5, 0.0 ], radius: -1
 * 
 * leftFoot.CopyToModel(mIndex, 0);
 * rightFoot.CopyToModel(mIndex, 1);
 * SetNumHitboxes(mIndex, 2);
 *
 * With no need to recompile your models :)
 * 
 * 
 * CALL GET NUM HITBOXES FIRST, MODIFY THE EXISTING ONES DONT MAKE NEW ONES
 * HITBOXES CAN ONLY BE ATTACHED TO BONES WITH HITBOX FLAG SET BECAUSE I CANT FIGURE OUT HOW TO SET IT MYSELF
 * I CAN CHECK FOR FLAGS THOUGH, SO AS LONG AS YOU USE A VALID HITBOX INDEX YOU WILL BE OKAY
 * 
 */

/**
 * Print all the hitboxes in the models hitbox set
 *
 * @param modelIndex	Model index from precache
 * @return				1 on success, 0 on failure
 */
native int HitboxInfo(int modelIndex);

/**
 * Print all the bones in the model
 *
 * @param modelIndex	Model index from precache
 * @return				1 on success, 0 on failure
 */
native int BoneInfo(int modelIndex);

/**
 * Set a hitbox's attributes for a model
 *
 * @param modelIndex	Model index from precache
 * @param hitboxIndex	Index of hitbox to change
 * @param bone			Index of bone to attach to
 * @param group			Hitbox group of hitbox (used for damage)
 * @param min			Min point of hitbox
 * @param max			Max point of hitbox
 * @param angle			Valve QAngle of hitbox
 * @param radius		Radius if capsule, < 0 for box
 * @return				1 on success, 0 on failure
 */
native int SetHitbox(int modelIndex, int hitboxIndex, int bone, int group, const float min[3], const float max[3], const float angle[3], const float radius);

/**
 * Get a hitbox's attributes for a model
 *
 * @param modelIndex	Model index from precache
 * @param hitboxIndex	Index of hitbox to change
 * @param bone			Index of bone to attach to
 * @param group			Hitbox group of hitbox (used for damage)
 * @param min			Min point of hitbox
 * @param max			Max point of hitbox
 * @param angle			Valve QAngle of hitbox
 * @param radius		Radius if capsule, < 0 for box
 * @return				1 on success, 0 on failure
 */
native int GetHitbox(int modelIndex, int hitboxIndex, int &bone, int &group, float min[3], float max[3], float angle[3], float &radius);

/**
 * Set the number of hitboxes in a hitbox set
 * DO NOT SET THIS GREATER THAN DEFAULT AMOUNT, Negative seems fine though
 *
 * @param modelIndex	Model index from precache
 * @param num			What to set numhitboxes to
 * @return				1 on success, 0 on failure
 */
native int SetNumHitboxes(int modelIndex, int num);

/**
 * Get the number of hitboxes in a hitbox set
 * YOU SHOULD CALL THIS FIRST YOU WILL PROBABLY CRASH IF YOU TRY TO ADD AN EXTRA HITBOX
 * JUST CHANGE THE ONES THE MODEL HAS BY DEFAULT AND KEEP NUMHITBOXES LESS THAN OR EQUAL
 * TO THE ORIGINAL VALUE
 *
 * @param modelIndex	Model index from precache
 * @return				Amount on success, -1 on failure
 */
native int GetNumHitboxes(int modelIndex);

/**
 * Get bone index from bone name
 *
 * @param boneName		Name of bone to find
 * @param modelIndex	Model index from precache
 * @return				Bone index on success, -1 on failure
 */
native int FindBone(const char[] boneName, int modelIndex);

/**
 * Print a list of bones with the hitbox flag set
 *
 * @param modelIndex	Model index from precache
 * @return				1 on success, 0 on failure
 */
native int FindValidBones(int modelIndex);

public Extension __ext_hitboxchanger = 
{
	name = "HitboxChanger",
	file = "HitboxChanger.ext",
#if defined AUTOLOAD_EXTENSIONS
	autoload = 1,
#else
	autoload = 0,
#endif
#if defined REQUIRE_EXTENSIONS
	required = 1,
#else
	required = 0,
#endif
};