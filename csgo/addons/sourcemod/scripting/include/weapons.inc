#if defined _weapons_included_
  #endinput
#endif
#define _weapons_included_

//Retrieves and stores client's knife entity name in 'sKnife'. returns 'weapon_knife' if selection is 'OwnKnife'.
native void Weapons_GetClientKnife(int client, char[] sKnife, int Size);

//Sets client's knife to what is stored in 'sKnife'. Throws Native Error if knife name isn't valid. Update = Store the 'sKnife' in client's mysql table?
native void Weapons_SetClientKnife(int client, char[] sKnife, bool update);

//Called before client selects a knife from !knife. return Plugin_Handled to block.
forward Action Weapons_OnClientKnifeSelectPre(int client, int knifeId, char[] knifeName);

//Called after client selects a knife from !knife.
forward void Weapons_OnClientKnifeSelectPost(int client, int knifeId, char[] knifeName);
