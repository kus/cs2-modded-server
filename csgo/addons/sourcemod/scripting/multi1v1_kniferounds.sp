/**
 * This plugin is intended to provide a simple example of how to add round types via the natives
 * provided.
 * If you really only wanted knife rounds, it would be simpler to only modify the
 * configs/multi1v1_customrounds.cfg
 * file.
 */

#include "include/multi1v1.inc"
#include "multi1v1/version.sp"
#include <smlib>
#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required


// clang-format off
public Plugin myinfo = {
  name = "CS:GO Multi1v1: knife round addon",
  author = "splewis",
  description = "Adds an unranked knife round-type",
  version = PLUGIN_VERSION,
  url = "https://github.com/splewis/csgo-multi-1v1"
};
// clang-format on

public void Multi1v1_OnRoundTypesAdded() {
  Multi1v1_AddRoundType("Knife", "knife", KnifeHandler, true, false, "", true);
}

public void KnifeHandler(int client) {
  Client_SetArmor(client, 100);
  GivePlayerItem(client, "weapon_knife");
}
