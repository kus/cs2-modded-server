
#if defined _gameutils_included
    #endinput
#endif
#define _gameutils_included

#define WEAPON_SHOTGUN  4

stock void ReadySound(char[] relPath) {
    char fullPath[128];
    Format(fullPath, sizeof(fullPath), "sound/%s", relPath);

    char buffer[128];
    Format(buffer, sizeof(buffer), "*/%s", relPath);
    AddFileToDownloadsTable(fullPath);
    AddToStringTable(FindStringTable("soundprecache"), buffer);
}

stock void UnsetHandle(Handle &handle) {
    if (handle != INVALID_HANDLE) {
        CloseHandle(handle);
        handle = INVALID_HANDLE;
    }
}
