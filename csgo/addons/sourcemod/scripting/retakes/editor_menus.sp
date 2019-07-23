stock void GiveEditorMenu(int client, int menuPosition=-1) {
    Menu menu = new Menu(EditorMenuHandler);
    menu.ExitButton = true;
    menu.SetTitle("Retakes spawn editor");
    AddMenuOption(menu, "end_edit", "Exit edit mode");
    AddMenuOption(menu, "change_site", "Showing bombsite: %s", SITESTRING(g_EditingSite));
    AddMenuOption(menu, "add_spawn", "Add a spawn");
    AddMenuOption(menu, "goto_nearest_spawn", "Go to nearest spawn");
    AddMenuOption(menu, "delete_nearest_spawn", "Delete nearest spawn");
    AddMenuOption(menu, "save_spawns", "Save spawns");
    AddMenuOption(menu, "delete_map_spawns", "Delete all map spawns");
    AddMenuOption(menu, "reload_spawns", "Reload map spawns (discard current changes)");

    if (menuPosition == -1) {
        DisplayMenu(menu, client, MENU_TIME_FOREVER);
    } else {
        DisplayMenuAtItem(menu, client, menuPosition, MENU_TIME_FOREVER);
    }
}

public int EditorMenuHandler(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select) {
        int client = param1;
        char choice[64];
        GetMenuItem(menu, param2, choice, sizeof(choice));
        int menuPosition = GetMenuSelectionPosition();

        if (StrEqual(choice, "end_edit")) {
            Retakes_MessageToAll("Exiting edit mode.");
            g_EditMode = false;
            ServerCommand("mp_warmup_end");

        } else if (StrEqual(choice, "add_spawn")) {
            GiveNewSpawnMenu(client);

        } else if (StrEqual(choice, "change_site")) {
            ShowSpawns(GetOtherSite(g_EditingSite));
            GiveEditorMenu(client, menuPosition);

        } else if (StrEqual(choice, "goto_nearest_spawn")) {
            int spawn = FindClosestSpawn(client);
            if (IsValidSpawn(spawn)) {
                MoveToSpawnInEditor(client, spawn);
            } else {
                Retakes_Message(client, "No spawns found");
            }
            GiveEditorMenu(client, menuPosition);

        }else if (StrEqual(choice, "delete_nearest_spawn")) {
            DeleteClosestSpawn(client);
            GiveEditorMenu(client, menuPosition);

        } else if (StrEqual(choice, "delete_map_spawns")) {
            DeleteMapSpawns();
            GiveEditorMenu(client, menuPosition);

        } else if (StrEqual(choice, "save_spawns")) {
            SaveSpawns();
            GiveEditorMenu(client, menuPosition);

        }  else if (StrEqual(choice, "reload_spawns")) {
            ReloadSpawns();
            GiveEditorMenu(client, menuPosition);

        } else {
            LogError("unknown menu info string = %s", choice);
        }
    } else if (action == MenuAction_End) {
        delete menu;
    }
}

public void GiveNewSpawnMenu(int client) {
    Menu menu = new Menu(GiveNewSpawnMenuHandler);
    menu.SetTitle("Add a spawn");
    AddMenuOption(menu, "finish", "Finish spawn");
    AddMenuOption(menu, "team", "Team: %s", TEAMSTRING(g_EditingSpawnTeams[client]));
    AddMenuOption(menu, "site", "Bombsite: %s", SITESTRING(g_EditingSite));

    char typeString[128];
    if (g_EditingSpawnTypes[client] == SpawnType_Normal) {
        Format(typeString, sizeof(typeString), "Normal");
    } else if (g_EditingSpawnTypes[client] == SpawnType_OnlyWithBomb) {
        Format(typeString, sizeof(typeString), "Bomb-carrier only");
    } else {
        Format(typeString, sizeof(typeString), "Never bomb-carrier");
    }
    if (g_EditingSpawnTeams[client] == CS_TEAM_CT) {
        AddMenuOptionDisabled(menu, "type", "Spawn type: %s", typeString);
    } else {
        AddMenuOption(menu, "type", "T spawn type: %s", typeString);
    }

    menu.ExitButton = false;
    menu.ExitBackButton = true;

    DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int GiveNewSpawnMenuHandler(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select) {
        int client = param1;
        char choice[64];
        GetMenuItem(menu, param2, choice, sizeof(choice));
        if (StrEqual(choice, "finish")) {
            AddSpawn(client);
            GiveNewSpawnMenu(client);
        } else if (StrEqual(choice, "team")) {
            g_EditingSpawnTeams[client] = GetOtherTeam(g_EditingSpawnTeams[client]);
            GiveNewSpawnMenu(client);
        } else if (StrEqual(choice, "site")) {
            g_EditingSite = GetOtherSite(g_EditingSite);
            GiveNewSpawnMenu(client);
        } else if (StrEqual(choice, "type")) {
            g_EditingSpawnTypes[client] = NextSpawnType(g_EditingSpawnTypes[client]);
            GiveNewSpawnMenu(client);
        } else {
            LogError("unknown menu info string = %s", choice);
        }
    } else if (action == MenuAction_Cancel && param2 == MenuCancel_ExitBack) {
        int client = param1;
        GiveEditorMenu(client);
    } else if (action == MenuAction_End) {
        delete menu;
    }
}

public SpawnType NextSpawnType(SpawnType type) {
    if (type == SpawnType_Normal) {
        return SpawnType_OnlyWithBomb;
    } else if (type == SpawnType_OnlyWithBomb) {
        return SpawnType_NeverWithBomb;
    } else {
        return SpawnType_Normal;
    }
}
