#if defined _jumpstats_natives_
  #endinput
#endif
#define _jumpstats_natives_

/**
 * @brief Interrupts a player's current jump stats recording.
 *
 * @param client    The target player.
 * @return          True if the jump was successfully interrupted, false otherwise.
 */
native JumpStats_InterruptJump(client);
