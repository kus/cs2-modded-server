char radioSoundAffirmative[50]      = "player/vo/fbihrt/radiobotreponsepositive03.wav";
char radioSoundCheer[50]            = "player/vo/fbihrt/radiobotcheer02.wav";
char radioSoundCompliment[50]       = "player/vo/fbihrt/radiobotniceshot01.wav";
char radioSoundCoverMe[50]          = "player/vo/fbihrt/coverme01.wav";
char radioSoundEnemyDown[50]        = "player/vo/fbihrt/radiobotkill07.wav";
char radioSoundEnemySpotted[50]     = "player/vo/fbihrt/radiobottarget01.wav";
char radioSoundFallback[50]         = "player/vo/fbihrt/radiobotfallback01.wav";
char radioSoundFollowMe[50]         = "player/vo/fbihrt/radiobotfollowme01.wav";
char radioSoundGetOut[50]           = "player/vo/fbihrt/radiobotgo03.wav";
char radioSoundGo[50]               = "player/vo/fbihrt/radiobotgo01.wav";
char radioSoundHoldPosition[50]     = "player/vo/fbihrt/radiobothold01.wav";
char radioSoundInPosition[50]       = "player/vo/fbihrt/inposition01.wav";
char radioSoundNeedBackup[50]       = "player/vo/fbihrt/radiobotunderfire11.wav";
char radioSoundNegative[50]         = "player/vo/fbihrt/radiobotreponsenegative03.wav";
char radioSoundRegroup[50]          = "player/vo/fbihrt/radiobotregroup01.wav";
char radioSoundReport[50]           = "player/vo/fbihrt/radiobotreport01.wav";
char radioSoundReportingIn[50]      = "player/vo/fbihrt/reportingin01.wav";
char radioSoundSectorClear[50]      = "player/vo/fbihrt/radiobotclear01.wav";
char radioSoundStickTogether[50]    = "player/vo/fbihrt/radiobotregroup02.wav";
char radioSoundTakePoint[50]        = "player/vo/fbihrt/radiobotfollowyou01.wav";
char radioSoundTakingFire[50]       = "player/vo/fbihrt/radiobotunderfire07.wav";
char radioSoundThanks[50]           = "player/vo/fbihrt/radiobotreponsepositive17.wav";

int usedRadioCommand[MAXPLAYERS + 1];
Handle radioCommandDelay[MAXPLAYERS + 1];

public void LoadRadioCommandsFix()
{
    if (StrEqual(game, "csgo"))
    {
        AddCommandListener(RadioCommandListener, "go");
        AddCommandListener(RadioCommandListener, "fallback");
        AddCommandListener(RadioCommandListener, "sticktog");
        AddCommandListener(RadioCommandListener, "holdpos");
        AddCommandListener(RadioCommandListener, "followme");
        AddCommandListener(RadioCommandListener, "roger");
        AddCommandListener(RadioCommandListener, "negative");
        AddCommandListener(RadioCommandListener, "cheer");
        AddCommandListener(RadioCommandListener, "compliment");
        AddCommandListener(RadioCommandListener, "thanks");
        AddCommandListener(RadioCommandListener, "enemyspot");
        AddCommandListener(RadioCommandListener, "needbackup");
        AddCommandListener(RadioCommandListener, "takepoint");
        AddCommandListener(RadioCommandListener, "sectorclear");
        AddCommandListener(RadioCommandListener, "inposition");
        AddCommandListener(RadioCommandListener, "getout");
        AddCommandListener(RadioCommandListener, "enemydown");
        AddCommandListener(RadioCommandListener, "takingfire");
        AddCommandListener(RadioCommandListener, "coverme");
        AddCommandListener(RadioCommandListener, "regroup");
        AddCommandListener(RadioCommandListener, "reportingin");
        AddCommandListener(RadioCommandListener, "report");
    }
}

public void RadioCommandsOnClientPutInServer(int client)
{
    radioCommandDelay[client] = null;
    usedRadioCommand[client] = 0;
}

public void RadioCommandsOnClientDisconnect(int client)
{
    if (radioCommandDelay[client] != null)
    {
        KillTimer(radioCommandDelay[client]);
        radioCommandDelay[client] = null;
    }
}

public Action RadioCommandListener(int client, const char[] command, int argc)
{
    if (currentMapAllowed)
    {
        if (IsPlayerAlive(client) && !usedRadioCommand[client])
        {
            usedRadioCommand[client] = 1;
            radioCommandDelay[client] = CreateTimer(2.0, DelayPressedRadioCommand, client);

            int team = GetClientTeam(client);

            for (int player = 1; player <= MaxClients; player++)
            {
                if (IsClientInGame(player) && IsClientConnected(player) && GetClientTeam(player) == team)
                {
                    if (StrEqual(command, "go"))                PlayRadioMessage(client, player, "Go go go!",                           radioSoundGo);
                    else if (StrEqual(command, "fallback"))     PlayRadioMessage(client, player, "Team, fall back!",                    radioSoundFallback);
                    else if (StrEqual(command, "sticktog"))     PlayRadioMessage(client, player, "Stick together, team.",               radioSoundStickTogether);
                    else if (StrEqual(command, "holdpos"))      PlayRadioMessage(client, player, "Hold This position.",                 radioSoundHoldPosition);
                    else if (StrEqual(command, "followme"))     PlayRadioMessage(client, player, "Follow Me.",                          radioSoundFollowMe);
                    else if (StrEqual(command, "roger"))        PlayRadioMessage(client, player, "Affirmative.",                        radioSoundAffirmative);
                    else if (StrEqual(command, "negative"))     PlayRadioMessage(client, player, "Negative.",                           radioSoundNegative);
                    else if (StrEqual(command, "cheer"))        PlayRadioMessage(client, player, "Cheer!",                              radioSoundCheer);
                    else if (StrEqual(command, "compliment"))   PlayRadioMessage(client, player, "Nice!",                               radioSoundCompliment);
                    else if (StrEqual(command, "thanks"))       PlayRadioMessage(client, player, "Thanks!",                             radioSoundThanks);
                    else if (StrEqual(command, "enemyspot"))    PlayRadioMessage(client, player, "Enemy spotted.",                      radioSoundEnemySpotted);
                    else if (StrEqual(command, "needbackup"))   PlayRadioMessage(client, player, "Need backup.",                        radioSoundNeedBackup);
                    else if (StrEqual(command, "takepoint"))    PlayRadioMessage(client, player, "You take the point.",                 radioSoundTakePoint);
                    else if (StrEqual(command, "sectorclear"))  PlayRadioMessage(client, player, "Sector clear.",                       radioSoundSectorClear);
                    else if (StrEqual(command, "inposition"))   PlayRadioMessage(client, player, "I'm in position.",                    radioSoundInPosition);
                    else if (StrEqual(command, "getout"))       PlayRadioMessage(client, player, "Get out of there, it's gonna blow!",  radioSoundGetOut);
                    else if (StrEqual(command, "enemydown"))    PlayRadioMessage(client, player, "Enemy down.",                         radioSoundEnemyDown);
                    else if (StrEqual(command, "takingfire"))   PlayRadioMessage(client, player, "Taking fire...need assistance!",      radioSoundTakingFire);
                    else if (StrEqual(command, "coverme"))      PlayRadioMessage(client, player, "Cover Me!",                           radioSoundCoverMe);
                    else if (StrEqual(command, "regroup"))      PlayRadioMessage(client, player, "Regroup Team.",                       radioSoundRegroup);
                    else if (StrEqual(command, "reportingin"))  PlayRadioMessage(client, player, "Reporting in.",                       radioSoundReportingIn);
                    else if (StrEqual(command, "report"))       PlayRadioMessage(client, player, "Report in, team.",                    radioSoundReport);
                }
            }
        }

        return Plugin_Handled;
    }

    return Plugin_Continue;
}

public void PlayRadioMessage(int sender, int receiver, char message[64], char sound[50])
{
    PrintToChat(receiver, "\x09%N (RADIO): %s", sender, message);
    if (!IsModelPrecached(sound)) PrecacheSound(sound);
    EmitSoundToClient(receiver, sound, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
}

public Action DelayPressedRadioCommand(Handle timer, any client)
{
    radioCommandDelay[client] = null;
    usedRadioCommand[client] = 0;
}