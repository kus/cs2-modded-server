

// Based on gokz-replays.

#define RP_DIRECTORY "data/gokz-replays" // In Path_SM
#define RP_DIRECTORY_CHEATERS "data/gokz-replays/_cheaters" // In Path_SM
#define RP_FILE_EXTENSION "replay"
#define RP_MAGIC_NUMBER 0x676F6B7A
#define RP_FORMAT_VERSION 0x01
#define RP_MAX_CHEATER_REPLAY_LENGTH (128 * 60 * 2) // 2 minutes on 128 tick.
#define RP_TICK_DATA_BLOCKSIZE 7

static int recordingIndex[MAXPLAYERS + 1];
static ArrayList recordedTickData[MAXPLAYERS + 1];

enum struct TickData
{
	float origin[3];
	float angles[2];
	int buttons;
	int flags;
}

void OnMapStart_Cheaterreplays()
{
	CreateReplaysDirectory();
}

void OnClientPutInServer_Cheaterreplays(int client)
{
	if (recordedTickData[client] == null)
	{
		recordedTickData[client] = new ArrayList(RP_TICK_DATA_BLOCKSIZE, 0);
	}
	
	RestartRecording(client);
}

void OnMacroBan_Cheaterreplays(int client)
{
	SaveRecordingOfCheater(client);
}

void OnPlayerRunCmdPost_Cheaterreplays(int client, int buttons)
{
	if (!IsValidClient(client) || IsFakeClient(client) || !IsPlayerAlive(client) || g_bPause[client])
	{
		return;
	}
	
	int tick = recordedTickData[client].Length;
	if (tick < RP_MAX_CHEATER_REPLAY_LENGTH)
	{
		recordedTickData[client].Resize(tick + 1);
	}
	tick = recordingIndex[client];
	recordingIndex[client] = (recordingIndex[client] + 1) % RP_MAX_CHEATER_REPLAY_LENGTH;
	
	float origin[3], angles[3];
	GetClientAbsOrigin(client, origin);
	GetClientEyeAngles(client, angles);
	int flags = GetEntityFlags(client);
	
	recordedTickData[client].Set(tick, origin[0], 0);
	recordedTickData[client].Set(tick, origin[1], 1);
	recordedTickData[client].Set(tick, origin[2], 2);
	recordedTickData[client].Set(tick, angles[0], 3);
	recordedTickData[client].Set(tick, angles[1], 4);
	// Don't bother tracking eye angle roll (angles[2]) - not used
	recordedTickData[client].Set(tick, buttons, 5);
	recordedTickData[client].Set(tick, flags, 6);
}

// =====[ PRIVATE ]=====

static void RestartRecording(int client)
{
	if (IsFakeClient(client))
	{
		return;
	}
	
	recordedTickData[client].Clear();
	recordingIndex[client] = 0;
}

static bool SaveRecordingOfCheater(int client)
{
	// Prepare data
	int mode = 2; // KZTimer
	int style = 0;
	
	// Setup file path and file
	int replayNumber = 0;
	char path[PLATFORM_MAX_PATH];
	do
	{
		BuildPath(Path_SM, path, sizeof(path), 
			"%s/%d_%d.%s", 
			RP_DIRECTORY_CHEATERS, GetSteamAccountID(client), replayNumber, RP_FILE_EXTENSION);
		replayNumber++;
	}
	while (FileExists(path));
	
	File file = OpenFile(path, "wb");
	if (file == null)
	{
		LogError("Failed to create/open replay file to write to: \"%s\".", path);
		return false;
	}
	
	// Prepare more data
	char steamID2[24], ip[16], alias[MAX_NAME_LENGTH];
	GetClientAuthId(client, AuthId_Steam2, steamID2, sizeof(steamID2));
	GetClientIP(client, ip, sizeof(ip));
	GetClientName(client, alias, sizeof(alias));
	int tickCount = recordedTickData[client].Length;
	char currentMap[64];
	GetCurrentMapDisplayName(currentMap, sizeof(currentMap));
	
	// Write header
	file.WriteInt32(RP_MAGIC_NUMBER);
	file.WriteInt8(RP_FORMAT_VERSION);
	file.WriteInt8(strlen("KZTimer "...VERSION));
	file.WriteString("KZTimer "...VERSION, false);
	file.WriteInt8(strlen(currentMap));
	file.WriteString(currentMap, false);
	file.WriteInt32(-1);
	file.WriteInt32(mode);
	file.WriteInt32(style);
	file.WriteInt32(view_as<int>(float(-1)));
	file.WriteInt32(-1);
	file.WriteInt32(GetSteamAccountID(client));
	file.WriteInt8(strlen(steamID2));
	file.WriteString(steamID2, false);
	file.WriteInt8(strlen(ip));
	file.WriteString(ip, false);
	file.WriteInt8(strlen(alias));
	file.WriteString(alias, false);
	file.WriteInt32(tickCount);
	
	// Write tick data
	any tickData[RP_TICK_DATA_BLOCKSIZE];
	for (int tick = 0; tick < recordedTickData[client].Length; tick++)
	{
		// Recording is done on a rolling basis.
		// So if we reach the end of the array, that's not necessarily the end of the replay.
		int index = (recordingIndex[client] + tick) % recordedTickData[client].Length;
		recordedTickData[client].GetArray(index, tickData, RP_TICK_DATA_BLOCKSIZE);
		file.Write(tickData, RP_TICK_DATA_BLOCKSIZE, 4);
	}
	delete file;
	
	return true;
}

static void CreateReplaysDirectory()
{
	char path[PLATFORM_MAX_PATH];
	
	// Create parent replay directory
	BuildPath(Path_SM, path, sizeof(path), RP_DIRECTORY);
	if (!DirExists(path))
	{
		CreateDirectory(path, 511);
	}
	
	// Create cheaters replay directory
	BuildPath(Path_SM, path, sizeof(path), "%s", RP_DIRECTORY_CHEATERS);
	if (!DirExists(path))
	{
		CreateDirectory(path, 511);
	}
}

static void GetCurrentMapDisplayName(char[] buffer, int maxlength)
{
	char map[PLATFORM_MAX_PATH];
	GetCurrentMap(map, sizeof(map));
	GetMapDisplayName(map, map, sizeof(map));
	String_ToLower(map, buffer, maxlength);
}
