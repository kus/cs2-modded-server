#define SR_Base 0 // Base speed
#define SR_Max 1 // Max speed (final)
#define SR_Min 2 // Min speed (final)
#define SR_Add 3 // Add speed (applied after mul.)
#define SR_Sub 4 // Sub speed (applied after mul.)
#define SR_Mul 5 // Multi. base speed

native bool SpeedRules_Reset(); // Removes all rules from all players
native bool SpeedRules_ResetTemp(); // Removes all temorary rules from all players
native bool SpeedRules_ResetType(int iType); // Removes all rules for this type from all players
native bool SpeedRules_ResetName(char[] sName); // Removes all rules sharing this name from all players
native bool SpeedRules_ClientReset(int iClient); // Removes all rules from target player
native bool SpeedRules_ClientResetTemp(int iClient); // Removes all temporary rules from target player
native bool SpeedRules_ClientResetType(int iClient, int iType); // Removes all rules for this type from target player
native bool SpeedRules_ClientResetName(int iClient, char[] sName); // Removes all rules sharing this name from target player
native bool SpeedRules_ClientRemove(int iClient, int iIndex); // Remove target rule
native bool SpeedRules_ClientAdd(int iClient, char sName[32], int iType, float fAmount, float fTTL, int iPriority); // Adds a new rule
native int SpeedRules_ClientGetCount(int iClient); // Get rule count including inactive ones
native int SpeedRules_ClientGetActive(int iClient, int iType); // Get active rule by type
native int SpeedRules_ClientFind(int iClient, int iType, char sName[32]); // Find rule by type and name
native bool SpeedRules_ClientGetInfo(int iClient, int iIndex, char sName[32], int &iType, float &fAmount, float &fTime, int &iPriority); // Get all info about target rule
native float SpeedRules_ClientGetTime(int iClient, int iIndex); // Get game time only
native float SpeedRules_ClientGetSpeed(int iClient, bool clear); // Get current speed, if clear is set to true it will sort out expired rules first

forward void SpeedRules_OnClientReset(int iClient); // Triggered when all rules got removed by native
forward Action SpeedRules_OnClientAdd(int iClient, char[] sName, int iType, float &fAmount, float &fTTL, int &iPriority); // Return Plugin_Handled or Plugin_Stop to block or Plugin_Changed to modify
forward void SpeedRules_OnClientAddPost(int iClient, char[] sName, int iType, float fAmount, float fTTL, int iPriority); // New rule has been applied
forward void SpeedRules_OnClientRemoved(int iClient, char[] sName, int iType, float fAmount, int iPriority); // Triggered when a rule got removed by native
forward void SpeedRules_OnClientExpired(int iClient, char[] sName, int iType, float fAmount, int iPriority); // Triggered when a rule expired by TTL
