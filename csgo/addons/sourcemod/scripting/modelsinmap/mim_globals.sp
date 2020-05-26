int g_iPlayerSelectedBlock[MAXPLAYERS + 1];
int g_iPlayerNewEntity[MAXPLAYERS + 1];
int g_iPlayerPrevButtons[MAXPLAYERS + 1];
float g_fPlayerSelectedBlockDistance[MAXPLAYERS + 1];
bool g_OnceStopped[MAXPLAYERS + 1];

bool g_bCanMoveModels[MAXPLAYERS + 1];

char g_sModelConfig[PLATFORM_MAX_PATH];
char g_sModelConfig2[PLATFORM_MAX_PATH];

#define LoopAllPlayers(%1) for(int %1=1;%1<=MaxClients;++%1)\
if(IsClientInGame(%1))