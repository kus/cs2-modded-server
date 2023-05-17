#if defined _ArmsFix_Include_
    #endinput
#endif

#define _ArmsFix_Include_

public SharedPlugin __pl_arms_fix =
{
	name = "ArmsFix",
	file = "ArmsFix.smx",
#if !defined REQUIRE_PLUGIN
    required = 0
#else
    required = 1
#endif
};

native bool ArmsFix_ModelSafe(int client); // True = Arms has been fixed

// Called when spawn model.
// Plugin_Continue = Set client model and arms to default - ctm_st6 for CTs, tm_phoenix for Ts.
// Plugin_Changed = Set client model and arms to custom model.
// Plugin_Handled = Nothing happen -> Fix directly.
// Plugin_Stop = Nothing happen -> Fix directly
// Attention!!! This call only run at the end of exec !!!
forward Action ArmsFix_OnSpawnModel(int client, char[] model, int modelLen, char[] arms, int armsLen);

// Called on when arms fixed.
forward void ArmsFix_OnArmsFixed(int client);