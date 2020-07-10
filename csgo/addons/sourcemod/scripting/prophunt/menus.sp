
#include "prophunt/include/phclient.inc"

public int Menu_Group(Handle menu, MenuAction action, int _client, int param2) {
    PHClient client = GetPHClient(_client);

    if (client && client.team == CS_TEAM_T && g_bAllowModelChange[client.index]) {
        if (action == MenuAction_Select) {
            char info[100], info2[100], sModelPath[100];
            bool found = GetMenuItem(menu, param2, info, sizeof(info), _, info2, sizeof(info2));
            if (found) {

                if (StrEqual(info, "random")) {
                    SetRandomModel(client.index);
                } else {
                    strcopy(sModelPath, sizeof(sModelPath), info);

                    SetEntityModel(client.index, sModelPath);
                    Client_ReCreateFakeProp(client);

                    PrintToChat(client.index, "%s%t \x01%s.", PREFIX, "Model Changed", info2);
                }
                g_iModelChangeCount[client.index]++;
            }
        } else if (action == MenuAction_Cancel) {
            PrintToChat(client.index, "%s%t", PREFIX, "Type !hide");
        }

        // display the help menu on first spawn
        if (GetConVarBool(cvar_ShowHelp) && g_bFirstSpawn[client.index]) {
            Cmd_DisplayHelp(client.index, 0);
            g_bFirstSpawn[client.index] = false;
        }
    }
}

// Display the different help menus
public int Menu_Help(Handle menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select) {
        char info[32];
        GetMenuItem(menu, param2, info, sizeof(info));
        int iInfo = StringToInt(info);
        switch (iInfo) {
            case 1:
                {
                    // Available Commands
                    Handle menu2 = new Menu(Menu_Dummy);
                    char buffer[512];
                    Format(buffer, sizeof(buffer), "%T", "Available Commands", param1);
                    SetMenuTitle(menu2, buffer);
                    SetMenuExitBackButton(menu2, true);

                    Format(buffer, sizeof(buffer), "/hide, /hidemenu - %T", "cmd hide", param1);
                    AddMenuItem(menu2, "", buffer, ITEMDRAW_DISABLED);
                    Format(buffer, sizeof(buffer), "/tp, /third, /thirdperson - %T", "cmd tp", param1);
                    AddMenuItem(menu2, "", buffer, ITEMDRAW_DISABLED);
                    if (GetConVarBool(cvar_Whistle)) {
                        Format(buffer, sizeof(buffer), "/whistle - %T", "cmd whistle", param1);
                        AddMenuItem(menu2, "", buffer, ITEMDRAW_DISABLED);
                    }
                    if (GetConVarInt(cvar_HiderFreezeMode)) {
                        Format(buffer, sizeof(buffer), "/freeze - %T", "cmd freeze", param1);
                        AddMenuItem(menu2, "", buffer, ITEMDRAW_DISABLED);
                    }
                    Format(buffer, sizeof(buffer), "/whoami - %T", "cmd whoami", param1);
                    AddMenuItem(menu2, "", buffer, ITEMDRAW_DISABLED);
                    Format(buffer, sizeof(buffer), "/hidehelp - %T", "cmd hidehelp", param1);
                    AddMenuItem(menu2, "", buffer, ITEMDRAW_DISABLED);

                    DisplayMenu(menu2, param1, MENU_TIME_FOREVER);
                }
            case 2:
                {
                    // Howto CT
                    Handle menu2 = new Menu(Menu_Dummy);
                    char buffer[512];
                    Format(buffer, sizeof(buffer), "%T", "Howto CT", param1);
                    SetMenuTitle(menu2, buffer);
                    SetMenuExitBackButton(menu2, true);

                    Format(buffer, sizeof(buffer), "%T", "Instructions CT 1", param1);
                    AddMenuItem(menu2, "", buffer, ITEMDRAW_DISABLED);

                    AddMenuItem(menu2, "", "", ITEMDRAW_SPACER);

                    Format(buffer, sizeof(buffer), "%T", "Instructions CT 2", param1, GetConVarInt(cvar_HPSeekerDec));
                    AddMenuItem(menu2, "", buffer, ITEMDRAW_DISABLED);

                    Format(buffer, sizeof(buffer), "%T", "Instructions CT 3", param1, GetConVarInt(cvar_HPSeekerInc), GetConVarInt(cvar_HPSeekerBonus));
                    AddMenuItem(menu2, "", buffer, ITEMDRAW_DISABLED);

                    DisplayMenu(menu2, param1, MENU_TIME_FOREVER);
                }
            case 3:
                {
                    // Howto T
                    Handle menu2 = new Menu(Menu_Dummy);
                    char buffer[512];
                    Format(buffer, sizeof(buffer), "%T", "Howto T", param1);
                    SetMenuTitle(menu2, buffer);
                    SetMenuExitBackButton(menu2, true);

                    Format(buffer, sizeof(buffer), "%T", "Instructions T 1", param1);
                    AddMenuItem(menu2, "", buffer, ITEMDRAW_DISABLED);

                    Format(buffer, sizeof(buffer), "%T", "Instructions T 2", param1);
                    AddMenuItem(menu2, "", buffer, ITEMDRAW_DISABLED);

                    DisplayMenu(menu2, param1, MENU_TIME_FOREVER);
                }
        }
    } else if (action == MenuAction_End) {
        CloseHandle(menu);
    }
}

public int Menu_Dummy(Handle menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Cancel && param2 != MenuCancel_Exit) {
        if (IsClientInGame(param1))
            Cmd_DisplayHelp(param1, 0);
    } else if (action == MenuAction_End) {
        CloseHandle(menu);
    }
}

stock void BuildMainMenu() {
    PrintToServer("Debug: BuildMainMenu");
    g_iTotalModelsAvailable = 0;

    g_hMenuKV = CreateKeyValues("Models");
    KeyValues defaultKV = new KeyValues("Models");
    char mapFile[256], defFile[256], map[64], title[64], finalOutput[100];

    GetCurrentMap(map, sizeof(map));

    BuildPath(Path_SM, mapFile, 255, "%s/%s.cfg", MAP_CONFIG_PATH,  map);
    BuildPath(Path_SM, defFile, 255, "%s/default.cfg", MAP_CONFIG_PATH);

    bool fileExists = FileToKeyValues(g_hMenuKV, mapFile);

    if (GetConVarBool(cvar_IncludeDefaultModels) || !fileExists) {
        FileToKeyValues(defaultKV, defFile);
        KvMerge(g_hMenuKV, defaultKV);
    }

    //KeyValuesToFile(g_hMenuKV, "kvdump_pre.txt");
    KvAddIncludes(g_hMenuKV);
    //KeyValuesToFile(g_hMenuKV, "kvdump.txt");

    char name[30];
    char path[100];
    int index = 0;

    KvGotoFirstSubKey(g_hMenuKV, false);
    do {
        KvGetSectionName(g_hMenuKV, path, sizeof(path));
        if (StrEqual("#include", path))
            continue;

        // get the model path and precache it
        KvGetString(g_hMenuKV, NULL_STRING, name, sizeof(name));
        FormatEx(finalOutput, sizeof(finalOutput), "models/%s.mdl", path);
        PrecacheModel(finalOutput, true);

        //PrintToServer("Debug: key: %s value: %s", path, name);
        if (strlen(name) > 0) {
            if (g_hModelMenu == INVALID_HANDLE) {
                PrintToServer("set menu");
                g_hModelMenu = new Menu(Menu_Group);
                Format(title, sizeof(title), "%T:", "Title Select Model", LANG_SERVER);

                SetMenuTitle(g_hModelMenu, title);
                SetMenuExitButton(g_hModelMenu, true);

                // Add random option
                Format(title, sizeof(title), "%T", "random", LANG_SERVER);
                AddMenuItem(g_hModelMenu, "random", title);
            }

            AddMenuItem(g_hModelMenu, finalOutput, name);
        }

        g_iTotalModelsAvailable++;
        index++;
    } while (KvGotoNextKey(g_hMenuKV, false));
    KvRewind(g_hMenuKV);

    delete defaultKV;

    if (g_iTotalModelsAvailable == 0)
        SetFailState("No models parsed in %s.cfg", map);
}

public Action ShowSelectModelMenu(int client, int args) {
    if (g_hModelMenu == INVALID_HANDLE) {
        return Plugin_Stop;
    }

    if (GetClientTeam(client) == CS_TEAM_T) {
        int changeLimit = GetConVarInt(cvar_ChangeLimit);
        if (g_bAllowModelChange[client] && (changeLimit == 0 || g_iModelChangeCount[client] < (changeLimit + 1))) {
            if (GetConVarBool(cvar_AutoChoose))
                SetRandomModel(client);
            else
                DisplayMenu(g_hModelMenu, client, RoundToFloor(GetConVarFloat(cvar_ChangeLimittime)));
        } else
            PrintToChat(client, "%s%t", PREFIX, "Modelmenu Disabled");
    } else {
        PrintToChat(client, "%s%t", PREFIX, "Only terrorists can select models");
    }

    return Plugin_Continue;
}

public Action DisableModelMenu(Handle timer, int client) {
    g_hAllowModelChangeTimer[client] = INVALID_HANDLE;

    if (!IsClientInGame(client))
        return Plugin_Stop;

    g_bAllowModelChange[client] = false;

    if (IsPlayerAlive(client))
        PrintToChat(client, "%s%t", PREFIX, "Modelmenu Disabled");

    // didnt he chose a model?
    if (GetClientTeam(client) == CS_TEAM_T && g_iModelChangeCount[client] == 0) {
        // give him a random one.
        PrintToChat(client, "%s%t", PREFIX, "Did not choose model");
        SetRandomModel(client);
    }

    return Plugin_Continue;
}


