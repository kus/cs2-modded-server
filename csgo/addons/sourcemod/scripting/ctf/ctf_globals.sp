#define 	FLAGMODEL	"models/mapmodels/flags.mdl"
#define		POLEMODEL	"models/props/pole.mdl"

#define LoopAllPlayers(%1) for(int %1=1;%1<=MaxClients;++%1)\
if(IsClientInGame(%1))

char PrimaryWeapon[23][50] = {
    "weapon_m4a1", "weapon_m4a1_silencer", "weapon_ak47", "weapon_aug", "weapon_awp", "weapon_bizon", "weapon_famas", 
    "weapon_G3SG1", "weapon_galilar", "weapon_m249", "weapon_mac10",
    "weapon_mag7", "weapon_mp7", "weapon_mp9", "weapon_negev", "weapon_nova", "weapon_p90", "weapon_sawedoff", "weapon_scar20",
    "weapon_sg556", "weapon_ssg08", "weapon_ump45", "weapon_xm1014"
};

char SecondaryWeapon[9][50] =  { 
	"weapon_deagle", "weapon_elite", "weapon_fiveseven" , "weapon_glock", "weapon_hkp2000", 
	"weapon_usp_silencer", "weapon_tec9", "weapon_p250", "weapon_cz75a"
};

Handle h_MaxFlags;
Handle h_RoundTime;
Handle h_RespawnTime;

Handle g_OnFlagTaken;
Handle g_OnFlagDropped;
Handle g_OnFlagScore;

int MaxFlags;
int RoundTime;
int RespawnTime;

int t_Flag = -1;
int ct_Flag = -1;
int t_Pole = -1;
int ct_Pole = -1;
int g_roundStartedTime;
int i_RespawnTime[MAXPLAYERS + 1];

char g_CTFconfig[PLATFORM_MAX_PATH + 1];

bool b_FlagCarrier[MAXPLAYERS + 1];
bool b_DefusingFlag[MAXPLAYERS + 1];
bool b_JustEnded = false;
bool b_AutoGiveWeapons[MAXPLAYERS + 1];

float f_TflagSpawnPos[3];
float f_CTflagSpawnPos[3];

char c_ctFlagPlace[50];
char c_tFlagPlace[50];
char g_LastPrimaryWeapon[MAXPLAYERS + 1][50];
char g_LastSecondaryWeapon[MAXPLAYERS + 1][50];

Handle DefuseTimer[MAXPLAYERS + 1];
Handle RespawnTimers[MAXPLAYERS + 1];

public void OnConfigsExecuted()
{
	BuildPath(Path_SM, g_CTFconfig, sizeof(g_CTFconfig), "configs/ctf/flags.txt");
	PrecacheModel(POLEMODEL);
	PrecacheModel(FLAGMODEL);
	DownloadPrecache_OnConfigsExecuted();
	BombSite_LocationChange();
	SetCvars();
	
}

public void OnClientPutInServer(int client)
{
	b_FlagCarrier[client] = false;
	b_DefusingFlag[client] = false;
	b_AutoGiveWeapons[client] = false;
	SDKHook(client, SDKHook_PostThink, Radar);
}

void DownloadPrecache_OnConfigsExecuted()
{

	
	//FLAGS
	AddFileToDownloadsTable("models/mapmodels/flags.mdl");
	AddFileToDownloadsTable("models/mapmodels/flags.dx80.vtx");
	AddFileToDownloadsTable("models/mapmodels/flags.dx90.vtx");
	AddFileToDownloadsTable("models/mapmodels/flags.sw.vtx");
	AddFileToDownloadsTable("models/mapmodels/flags.vvd");
	AddFileToDownloadsTable("materials/models/mapmodels/flags/axisflag.vmt");
	AddFileToDownloadsTable("materials/models/mapmodels/flags/axisflag.vtf");
	AddFileToDownloadsTable("materials/models/mapmodels/flags/neutralflag.vmt");
	AddFileToDownloadsTable("materials/models/mapmodels/flags/neutralflag.vtf");
	
	//Pole
	AddFileToDownloadsTable("models/props/pole.dx80.vtx");
	AddFileToDownloadsTable("models/props/pole.dx90.vtx");
	AddFileToDownloadsTable("models/props/pole.mdl");
	AddFileToDownloadsTable("models/props/pole.phy");
	AddFileToDownloadsTable("models/props/pole.sw.vtx");
	AddFileToDownloadsTable("models/props/pole.vvd");
	AddFileToDownloadsTable("materials/models/props/pole/gray.vmt");
	AddFileToDownloadsTable("materials/editor/gray.vtf");
	AddFileToDownloadsTable("materials/editor/gray.vmt");
	
	//Sounds
	AddFileToDownloadsTable("sound/ctf/blue_flag_dropped.mp3");
	AddFileToDownloadsTable("sound/ctf/blue_flag_returned.mp3");
	AddFileToDownloadsTable("sound/ctf/blue_flag_taken.mp3");
	AddFileToDownloadsTable("sound/ctf/blue_team_scores.mp3");
	
	AddFileToDownloadsTable("sound/ctf/red_flag_dropped.mp3");
	AddFileToDownloadsTable("sound/ctf/red_flag_returned.mp3");
	AddFileToDownloadsTable("sound/ctf/red_flag_taken.mp3");
	AddFileToDownloadsTable("sound/ctf/red_team_scores.mp3");

	
	PrecacheSoundAny("weapons/party_horn_01.wav");
	PrecacheSoundAny("ctf/blue_flag_dropped.mp3");
	PrecacheSoundAny("ctf/blue_flag_returned.mp3");
	PrecacheSoundAny("ctf/blue_flag_taken.mp3");
	PrecacheSoundAny("ctf/blue_team_scores.mp3");
	
	PrecacheSoundAny("ctf/red_flag_dropped.mp3");
	PrecacheSoundAny("ctf/red_flag_returned.mp3");
	PrecacheSoundAny("ctf/red_flag_taken.mp3");
	PrecacheSoundAny("ctf/red_team_scores.mp3");
	
}