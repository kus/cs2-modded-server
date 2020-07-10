
stock void LoadWhistles() {
    g_WhistleSounds = new ArrayList(MAX_WHISTLE_LENGTH);
    char path[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, path, sizeof(path), WHISTLE_CONFIG_PATH);

    Handle file = OpenFile(path, "r"); 
    char line[MAX_WHISTLE_LENGTH];

    while (!IsEndOfFile(file) && ReadFileLine(file, line, sizeof(line))) {
        TrimString(line);
        if (!StrEqual(line, "")) {
            g_WhistleSounds.PushString(line);
        }
    }

    CloseHandle(file);
}
