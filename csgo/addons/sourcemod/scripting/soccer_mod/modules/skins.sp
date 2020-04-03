char skinsKeygroup[PLATFORM_MAX_PATH];

// *********************************************************************************************************************
// ************************************************** CLIENT COMMANDS **************************************************
// *********************************************************************************************************************
public void ClientCommandSetGoalkeeperSkin(int client)
{
    int team = GetClientTeam(client);

    if (skinsIsGoalkeeper[client])
    {
        skinsIsGoalkeeper[client] = 0;

        if (team == 2 && FileExists(skinsModelT, true)) SetEntityModel(client, skinsModelT);
        else if (team == 3 && FileExists(skinsModelCT, true)) SetEntityModel(client, skinsModelCT);

        PrintToChat(client, "[Soccer Mod]\x04 %t", "Goalkeeper skin disabled");
    }
    else
    {
        skinsIsGoalkeeper[client] = 1;

        if (team == 2 && FileExists(skinsModelTGoalkeeper, true)) SetEntityModel(client, skinsModelTGoalkeeper);
        else if (team == 3 && FileExists(skinsModelCTGoalkeeper, true)) SetEntityModel(client, skinsModelCTGoalkeeper);

        PrintToChat(client, "[Soccer Mod]\x04 %t", "Goalkeeper skin enabled");
    }
}

// ************************************************************************************************************
// ************************************************** EVENTS **************************************************
// ************************************************************************************************************
public void SkinsOnPluginStart()
{
    BuildPath(Path_SM, skinsKeygroup, sizeof(skinsKeygroup), "configs/soccer_mod_skins.txt");

    if (StrEqual(game, "cstrike"))
    {
        skinsModelCT            = "models/player/soccer_mod/termi/2011/away/ct_urban.mdl";
        skinsModelT             = "models/player/soccer_mod/termi/2011/home/ct_urban.mdl";
        skinsModelCTGoalkeeper  = "models/player/soccer_mod/termi/2011/gkaway/ct_urban.mdl";
        skinsModelTGoalkeeper   = "models/player/soccer_mod/termi/2011/gkhome/ct_urban.mdl";
    }
}

public void SkinsOnMapStart()
{
    if (!IsModelPrecached(skinsModelCT))            PrecacheModel(skinsModelCT);
    if (!IsModelPrecached(skinsModelT))             PrecacheModel(skinsModelT);
    if (!IsModelPrecached(skinsModelCTGoalkeeper))  PrecacheModel(skinsModelCTGoalkeeper);
    if (!IsModelPrecached(skinsModelTGoalkeeper))   PrecacheModel(skinsModelTGoalkeeper);
}

public void SkinsOnClientPutInServer(int client)
{
    skinsIsGoalkeeper[client] = 0;
}

public void SkinsEventPlayerSpawn(Event event)
{
    int userid = event.GetInt("userid");
    int client = GetClientOfUserId(userid);
    int team = GetClientTeam(client);

    if (team == 2)
    {
        if (skinsIsGoalkeeper[client])
        {
            if (FileExists(skinsModelTGoalkeeper, true))
            {
                SetEntityModel(client, skinsModelTGoalkeeper);
                DispatchKeyValue(client, "skin", skinsModelTGoalkeeperNumber);
            }
        }
        else
        {
            if (FileExists(skinsModelT, true))
            {
                SetEntityModel(client, skinsModelT);
                DispatchKeyValue(client, "skin", skinsModelTNumber);
            }
        }
    }
    else if (team == 3)
    {
        if (skinsIsGoalkeeper[client])
        {
            if (FileExists(skinsModelCTGoalkeeper, true))
            {
                SetEntityModel(client, skinsModelCTGoalkeeper);
                DispatchKeyValue(client, "skin", skinsModelCTGoalkeeperNumber);
            }
        }
        else
        {
            if (FileExists(skinsModelCT, true))
            {
                SetEntityModel(client, skinsModelCT);
                DispatchKeyValue(client, "skin", skinsModelCTNumber);
            }
        }
    }
}

// ***********************************************************************************************************
// ************************************************** MENUS **************************************************
// ***********************************************************************************************************
public void OpenSkinsMenu(int client)
{
    Menu menu = new Menu(SkinsMenuHandler);

    char langString[64], langString1[64], langString2[64], langString3[64];
    Format(langString1, sizeof(langString1), "%T", "Admin", client);
    Format(langString2, sizeof(langString2), "%T", "Settings", client);
    Format(langString3, sizeof(langString3), "%T", "Skins", client);
    Format(langString, sizeof(langString), "Soccer Mod - %s - %s - %s", langString1, langString2, langString3);
    menu.SetTitle(langString);

    menu.AddItem("CT", "CT");
    menu.AddItem("T", "T");

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int SkinsMenuHandler(Menu menu, MenuAction action, int client, int choice)
{
    if (action == MenuAction_Select)
    {
        char menuItem[32];
        menu.GetItem(choice, menuItem, sizeof(menuItem));

        OpenSkinsSelectionMenu(client, menuItem);
    }
    else if (action == MenuAction_Cancel && choice == -6)   OpenMenuSettings(client);
    else if (action == MenuAction_End)                      menu.Close();
}

public void OpenSkinsSelectionMenu(int client, char type[32])
{
    Menu menu;
    if (StrEqual(type, "CT")) menu = new Menu(SkinsCTSelectionMenuHandler);
    else menu = new Menu(SkinsTSelectionMenuHandler);

    char langString[128], langString1[64], langString2[64], langString3[64];
    Format(langString1, sizeof(langString1), "%T", "Admin", client);
    Format(langString2, sizeof(langString2), "%T", "Settings", client);
    Format(langString3, sizeof(langString3), "%T", "Skins", client);
    Format(langString, sizeof(langString), "Soccer Mod - %s - %s - %s - %s", langString1, langString2, langString3, type);
    menu.SetTitle(langString);

    KeyValues keygroup = new KeyValues("skins");
    keygroup.ImportFromFile(skinsKeygroup);

    keygroup.GotoFirstSubKey();

    char name[32];
    char path[PLATFORM_MAX_PATH];

    do
    {
        keygroup.GetSectionName(name, sizeof(name));
        keygroup.GetString(type, path, sizeof(path));

        menu.AddItem(path, name);
    }
    while (keygroup.GotoNextKey());

    keygroup.Rewind();
    keygroup.Close();

    menu.ExitBackButton = true;
    menu.Display(client, 0);
}

public int SkinsCTSelectionMenuHandler(Menu menu, MenuAction action, int client, int choice)
{
    if (action == MenuAction_Select)
    {
        char menuItem[128];
        menu.GetItem(choice, menuItem, sizeof(menuItem));

        char number[4] = "0";
        SkinsServerCommandModelCT(menuItem, number);

        OpenSkinsMenu(client);
    }
    else if (action == MenuAction_Cancel && choice == -6)   OpenSkinsMenu(client);
    else if (action == MenuAction_End)                      menu.Close();
}

public int SkinsTSelectionMenuHandler(Menu menu, MenuAction action, int client, int choice)
{
    if (action == MenuAction_Select)
    {
        char menuItem[128];
        menu.GetItem(choice, menuItem, sizeof(menuItem));

        char number[4] = "0";
        SkinsServerCommandModelT(menuItem, number);

        OpenSkinsMenu(client);
    }
    else if (action == MenuAction_Cancel && choice == -6)   OpenSkinsMenu(client);
    else if (action == MenuAction_End)                      menu.Close();
}