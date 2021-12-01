
// enforce semicolons after each code statement
#pragma semicolon 1

#include <sourcemod>
#include <soundlib>

#define VERSION "0.9"



/*****************************************************************


			P L U G I N   I N F O


*****************************************************************/

public Plugin:myinfo = {
	name = "soundlib test",
	author = "Berni",
	description = "Plugin by Berni",
	version = VERSION,
	url = "http://forums.alliedmods.net"
}



/*****************************************************************


			G L O B A L   V A R S


*****************************************************************/





/*****************************************************************


			F O R W A R D   P U B L I C S


*****************************************************************/

public OnPluginStart() {
	RegAdminCmd("sm_soundinfo", Command_SoundInfo, ADMFLAG_GENERIC);
}



/****************************************************************


			C A L L B A C K   F U N C T I O N S


****************************************************************/

public Action:Command_SoundInfo(client, args) {

	decl String:path[PLATFORM_MAX_PATH];
	
	GetCmdArg(1, path, sizeof(path));

	new Handle:soundfile = OpenSoundFile(path);
	
	if (soundfile == INVALID_HANDLE) {
		PrintToServer("Invalid handle !");
		
		return Plugin_Handled;
	}
	
	decl String:artist[64];
	decl String:title[64];
	decl String:album[64];
	decl String:comment[64];
	decl String:genre[64];
	
	GetSoundArtist(soundfile, artist, sizeof(artist));
	GetSoundTitle(soundfile, title, sizeof(title));
	GetSoundAlbum(soundfile, album, sizeof(album));
	GetSoundComment(soundfile, comment, sizeof(comment));
	GetSoundGenre(soundfile, genre, sizeof(genre));
	
	ReplyToCommand(client, "Song Info %s", path);
	ReplyToCommand(client, "Sound Length: %d", GetSoundLength(soundfile));
	ReplyToCommand(client, "Sound Length (float): %f", GetSoundLengthFloat(soundfile));
	ReplyToCommand(client, "Birate: %d", GetSoundBitRate(soundfile));
	ReplyToCommand(client, "Sampling Rate: %d", GetSoundSamplingRate(soundfile));
	ReplyToCommand(client, "Artist: %s", artist);
	ReplyToCommand(client, "Title: %s", title);
	ReplyToCommand(client, "Num %d", GetSoundNum(soundfile));
	ReplyToCommand(client, "Album: %s", album);
	ReplyToCommand(client, "Year: %d",GetSoundYear(soundfile));
	ReplyToCommand(client, "Comment: %s", comment);
	ReplyToCommand(client, "Genre: %s", genre);
	
	CloseHandle(soundfile);
	
	return Plugin_Handled;
}



/*****************************************************************


			P L U G I N   F U N C T I O N S


*****************************************************************/

