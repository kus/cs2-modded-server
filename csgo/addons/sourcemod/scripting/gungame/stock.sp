
stock GameName:DetectGame() {
    decl String:gameName[30];
    GetGameFolderName(gameName, sizeof(gameName));
    if (StrEqual(gameName, "cstrike", false)) {
        return GameName:Css;
    } else if (StrEqual(gameName, "csgo", false)) {
        return GameName:Csgo;
    } else {
        LogError("ERROR: Unsupported game %s. Please contact the author.", gameName);
        return GameName:None;
    }
}
