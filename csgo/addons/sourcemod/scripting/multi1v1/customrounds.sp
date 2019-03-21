public void AddCustomRounds() {
  char path[PLATFORM_MAX_PATH];
  BuildPath(Path_SM, path, sizeof(path), "configs/multi1v1_customrounds.cfg");
  KeyValues kv = new KeyValues("CustomRoundTypes");

  if (kv.ImportFromFile(path) && kv.GotoFirstSubKey()) {
    do {
      char internalName[ROUND_TYPE_NAME_LENGTH];
      char displayName[ROUND_TYPE_NAME_LENGTH];
      char ratingFieldName[ROUND_TYPE_NAME_LENGTH];

      kv.GetSectionName(internalName, sizeof(internalName));
      kv.GetString("name", displayName, sizeof(displayName));
      kv.GetString("ratingFieldName", ratingFieldName, sizeof(ratingFieldName));
      bool ranked = !!kv.GetNum("ranked", 0);
      bool optional = !!kv.GetNum("optional", 1);
      bool enabled = !!kv.GetNum("enabled", 1);

      int roundType = Multi1v1_AddRoundType(displayName, internalName, CustomWeaponHandler,
                                            optional, ranked, ratingFieldName, enabled);

      bool armor = !!kv.GetNum("armor", 1);
      bool helmet = !!kv.GetNum("helmet", 1);
      int health = kv.GetNum("health", 100);
      g_RoundTypeKevlar[roundType] = armor;
      g_RoundTypeHelmet[roundType] = helmet;
      g_RoundTypeHealth[roundType] = health;

      g_RoundTypeWeaponLists[roundType].Clear();
      if (kv.JumpToKey("weapons")) {
        if (kv.GotoFirstSubKey(false)) {
          do {
            char weapon[WEAPON_NAME_LENGTH];
            kv.GetSectionName(weapon, sizeof(weapon));
            g_RoundTypeWeaponLists[roundType].PushString(weapon);
          } while (kv.GotoNextKey(false));
          kv.GoBack();
        }
        kv.GoBack();
      }

    } while (kv.GotoNextKey());

    kv.GoBack();
  }

  delete kv;
}

public void CustomWeaponHandler(int client) {
  int arena = g_Ranking[client];
  int roundType = g_roundTypes[arena];
  ArrayList weapons = g_RoundTypeWeaponLists[roundType];

  for (int i = 0; i < weapons.Length; i++) {
    char weapon[WEAPON_NAME_LENGTH];
    weapons.GetString(i, weapon, sizeof(weapon));
    if (StrEqual(weapon, "rifle_preference")) {
      GiveWeapon(client, g_PrimaryWeapon[client]);
    } else if (StrEqual(weapon, "pistol_preference")) {
      GiveWeapon(client, g_SecondaryWeapon[client]);
    } else {
      GiveWeapon(client, weapon);
    }
  }

  Client_SetArmor(client, g_RoundTypeKevlar[roundType] ? 100 : 0);
  Client_SetHelmet(client, g_RoundTypeHelmet[roundType]);
  Entity_SetHealth(client, g_RoundTypeHealth[roundType], true);
}
