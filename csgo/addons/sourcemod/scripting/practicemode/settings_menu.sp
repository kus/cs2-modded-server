public void RegisterUserSetting(UserSetting setting, const char[] cookieName, bool defaultSetting,
                         const char[] display) {
  g_UserSettingCookies[setting] = RegClientCookie(cookieName, "", CookieAccess_Public);
  g_UserSettingDefaults[setting] = defaultSetting;
  strcopy(g_UserSettingDisplayName[setting], USERSETTING_DISPLAY_LENGTH, display);
}

public bool GetSetting(int client, UserSetting setting) {
  if (!IsPlayer(client)) {
    return g_UserSettingDefaults[setting];
  }

  return GetCookieBool(client, g_UserSettingCookies[setting], g_UserSettingDefaults[setting]);
}

public void SetSetting(int client, UserSetting setting, bool value) {
  SetCookieBool(client, g_UserSettingCookies[setting], value);
}

public void ToggleSetting(int client, UserSetting setting) {
  SetSetting(client, setting, !GetSetting(client, setting));
}

public Action Command_Settings(int client, int args) {
  GiveSettingsMenu(client);
  return Plugin_Handled;
}

public void GiveSettingsMenu(int client) {
  Menu menu = new Menu(SettingsMenuHandler);
  menu.SetTitle("User settings:");

  for (int i = 0; i < view_as<int>(UserSetting_NumSettings); i++) {
    char buffer[128];
    Format(buffer, sizeof(buffer), "%s: %s", g_UserSettingDisplayName[i],
           GetSetting(client, view_as<UserSetting>(i)) ? "enabled" : "disabled");
    AddMenuInt(menu, i, buffer);
  }

  menu.Display(client, MENU_TIME_FOREVER);
}

public int SettingsMenuHandler(Menu menu, MenuAction action, int param1, int param2) {
  if (action == MenuAction_Select && g_InPracticeMode) {
    int client = param1;
    UserSetting setting = view_as<UserSetting>(GetMenuInt(menu, param2));
    ToggleSetting(client, setting);
    GiveSettingsMenu(client);

  } else if (action == MenuAction_End) {
    delete menu;
  }
}
