/*	Database Definitions	*/
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
new Handle:hDatabase = INVALID_HANDLE;

// Damage Carrier
new PistolDamage[MAXPLAYERS + 1][MAXPLAYERS + 1];
new MeleeDamage[MAXPLAYERS + 1][MAXPLAYERS + 1];
new UziDamage[MAXPLAYERS + 1][MAXPLAYERS + 1];
new ShotgunDamage[MAXPLAYERS + 1][MAXPLAYERS + 1];
new SniperDamage[MAXPLAYERS + 1][MAXPLAYERS + 1];
new RifleDamage[MAXPLAYERS + 1][MAXPLAYERS + 1];

new NextXPCost[MAXPLAYERS + 1];

// Survivor XP Levels
new PistolExperience[MAXPLAYERS + 1];
new PistolLevel[MAXPLAYERS + 1];
new PistolNextLevel[MAXPLAYERS + 1];
new MeleeExperience[MAXPLAYERS + 1];
new MeleeLevel[MAXPLAYERS + 1];
new MeleeNextLevel[MAXPLAYERS + 1];
new UziExperience[MAXPLAYERS + 1];
new UziLevel[MAXPLAYERS + 1];
new UziNextLevel[MAXPLAYERS + 1];
new ShotgunExperience[MAXPLAYERS + 1];
new ShotgunLevel[MAXPLAYERS + 1];
new ShotgunNextLevel[MAXPLAYERS + 1];
new SniperExperience[MAXPLAYERS + 1];
new SniperLevel[MAXPLAYERS + 1];
new SniperNextLevel[MAXPLAYERS + 1];
new RifleExperience[MAXPLAYERS + 1];
new RifleLevel[MAXPLAYERS + 1];
new RifleNextLevel[MAXPLAYERS + 1];
new GrenadeExperience[MAXPLAYERS + 1];
new GrenadeLevel[MAXPLAYERS + 1];
new GrenadeNextLevel[MAXPLAYERS + 1];
new ItemExperience[MAXPLAYERS + 1];
new ItemLevel[MAXPLAYERS + 1];
new ItemNextLevel[MAXPLAYERS + 1];
new PhysicalExperience[MAXPLAYERS + 1];
new PhysicalLevel[MAXPLAYERS + 1];
new PhysicalNextLevel[MAXPLAYERS + 1];

// Infected XP Levels
new HunterExperience[MAXPLAYERS + 1];
new HunterLevel[MAXPLAYERS + 1];
new HunterNextLevel[MAXPLAYERS + 1];
new SmokerExperience[MAXPLAYERS + 1];
new SmokerLevel[MAXPLAYERS + 1];
new SmokerNextLevel[MAXPLAYERS + 1];
new BoomerExperience[MAXPLAYERS + 1];
new BoomerLevel[MAXPLAYERS + 1];
new BoomerNextLevel[MAXPLAYERS + 1];
new JockeyExperience[MAXPLAYERS + 1];
new JockeyLevel[MAXPLAYERS + 1];
new JockeyNextLevel[MAXPLAYERS + 1];
new ChargerExperience[MAXPLAYERS + 1];
new ChargerLevel[MAXPLAYERS + 1];
new ChargerNextLevel[MAXPLAYERS + 1];
new SpitterExperience[MAXPLAYERS + 1];
new SpitterLevel[MAXPLAYERS + 1];
new SpitterNextLevel[MAXPLAYERS + 1];
new TankExperience[MAXPLAYERS + 1];
new TankLevel[MAXPLAYERS + 1];
new TankNextLevel[MAXPLAYERS + 1];
new InfectedExperience[MAXPLAYERS + 1];
new InfectedLevel[MAXPLAYERS + 1];
new InfectedNextLevel[MAXPLAYERS + 1];

// Presettings
new String:PrimaryPreset1[MAXPLAYERS + 1][64];
new String:SecondaryPreset1[MAXPLAYERS + 1][64];
new String:Option1Preset1[MAXPLAYERS + 1][64];
new String:Option2Preset1[MAXPLAYERS + 1][64];

new String:PrimaryPreset2[MAXPLAYERS + 1][64];
new String:SecondaryPreset2[MAXPLAYERS + 1][64];
new String:Option1Preset2[MAXPLAYERS + 1][64];
new String:Option2Preset2[MAXPLAYERS + 1][64];

new String:PrimaryPreset3[MAXPLAYERS + 1][64];
new String:SecondaryPreset3[MAXPLAYERS + 1][64];
new String:Option1Preset3[MAXPLAYERS + 1][64];
new String:Option2Preset3[MAXPLAYERS + 1][64];

new String:PrimaryPreset4[MAXPLAYERS + 1][64];
new String:SecondaryPreset4[MAXPLAYERS + 1][64];
new String:Option1Preset4[MAXPLAYERS + 1][64];
new String:Option2Preset4[MAXPLAYERS + 1][64];

new String:PrimaryPreset5[MAXPLAYERS + 1][64];
new String:SecondaryPreset5[MAXPLAYERS + 1][64];
new String:Option1Preset5[MAXPLAYERS + 1][64];
new String:Option2Preset5[MAXPLAYERS + 1][64];
new bool:DatabaseLoaded;

new Preset4[MAXPLAYERS + 1];
new Preset5[MAXPLAYERS + 1];


// Infected XP Levels

_Database_OnPluginStart()
{
	// So we only initialize it once.
	if (!DatabaseLoaded)
	{
		MySQL_Init();
		DatabaseLoaded = true;
	}
}

MySQL_Init()
{
	new String:Error[255];
	//SQL_TConnect(hDatabase, "usepoints5");
	//hDatabase = SQL_DefConnect(Error, sizeof(Error));
	hDatabase = SQL_Connect("rpg5", false, Error, sizeof(Error));
	
	if (hDatabase == INVALID_HANDLE)
	{
		PrintToServer("Failed To Connect To Database: %s", Error);
		LogError("Failed To Connect To Database: %s", Error);
	}
	decl String:TQuery[512];
	
	/*	Player STEAM_ID (How we identify the user)	*/
	
	Format(TQuery, sizeof(TQuery), "CREATE TABLE IF NOT EXISTS `multiplier_cat` (`steam_id` varchar(32) NOT NULL, PRIMARY KEY (`steam_id`)) TYPE=MyISAM;");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "CREATE TABLE IF NOT EXISTS `nemesis_cat` (`steam_id` varchar(32) NOT NULL, PRIMARY KEY (`steam_id`)) TYPE=MyISAM;");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "CREATE TABLE IF NOT EXISTS `sky_store_cat` (`steam_id` varchar(32) NOT NULL, PRIMARY KEY (`steam_id`)) TYPE=MyISAM;");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "CREATE TABLE IF NOT EXISTS `survivor_preset1` (`steam_id` varchar(32) NOT NULL, PRIMARY KEY (`steam_id`)) TYPE=MyISAM;");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "CREATE TABLE IF NOT EXISTS `survivor_preset2` (`steam_id` varchar(32) NOT NULL, PRIMARY KEY (`steam_id`)) TYPE=MyISAM;");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "CREATE TABLE IF NOT EXISTS `survivor_preset3` (`steam_id` varchar(32) NOT NULL, PRIMARY KEY (`steam_id`)) TYPE=MyISAM;");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "CREATE TABLE IF NOT EXISTS `survivor_preset4` (`steam_id` varchar(32) NOT NULL, PRIMARY KEY (`steam_id`)) TYPE=MyISAM;");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "CREATE TABLE IF NOT EXISTS `survivor_preset5` (`steam_id` varchar(32) NOT NULL, PRIMARY KEY (`steam_id`)) TYPE=MyISAM;");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "CREATE TABLE IF NOT EXISTS `map_records` (`map_name` varchar(32) NOT NULL, PRIMARY KEY (`map_name`)) TYPE=MyISAM;");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "CREATE TABLE IF NOT EXISTS `player_cat` (`steam_id` varchar(32) NOT NULL, PRIMARY KEY (`steam_id`)) TYPE=MyISAM;");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "CREATE TABLE IF NOT EXISTS `pistol_cat` (`steam_id` varchar(32) NOT NULL, PRIMARY KEY (`steam_id`)) TYPE=MyISAM;");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "CREATE TABLE IF NOT EXISTS `melee_cat` (`steam_id` varchar(32) NOT NULL, PRIMARY KEY (`steam_id`)) TYPE=MyISAM;");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "CREATE TABLE IF NOT EXISTS `uzi_cat` (`steam_id` varchar(32) NOT NULL, PRIMARY KEY (`steam_id`)) TYPE=MyISAM;");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "CREATE TABLE IF NOT EXISTS `shotgun_cat` (`steam_id` varchar(32) NOT NULL, PRIMARY KEY (`steam_id`)) TYPE=MyISAM;");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "CREATE TABLE IF NOT EXISTS `sniper_cat` (`steam_id` varchar(32) NOT NULL, PRIMARY KEY (`steam_id`)) TYPE=MyISAM;");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "CREATE TABLE IF NOT EXISTS `rifle_cat` (`steam_id` varchar(32) NOT NULL, PRIMARY KEY (`steam_id`)) TYPE=MyISAM;");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "CREATE TABLE IF NOT EXISTS `grenade_cat` (`steam_id` varchar(32) NOT NULL, PRIMARY KEY (`steam_id`)) TYPE=MyISAM;"); 
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "CREATE TABLE IF NOT EXISTS `item_cat` (`steam_id` varchar(32) NOT NULL, PRIMARY KEY (`steam_id`)) TYPE=MyISAM;");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "CREATE TABLE IF NOT EXISTS `physical_cat` (`steam_id` varchar(32) NOT NULL, PRIMARY KEY (`steam_id`)) TYPE=MyISAM;");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "CREATE TABLE IF NOT EXISTS `hunter_cat` (`steam_id` varchar(32) NOT NULL, PRIMARY KEY (`steam_id`)) TYPE=MyISAM;");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "CREATE TABLE IF NOT EXISTS `smoker_cat` (`steam_id` varchar(32) NOT NULL, PRIMARY KEY (`steam_id`)) TYPE=MyISAM;");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "CREATE TABLE IF NOT EXISTS `boomer_cat` (`steam_id` varchar(32) NOT NULL, PRIMARY KEY (`steam_id`)) TYPE=MyISAM;");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "CREATE TABLE IF NOT EXISTS `jockey_cat` (`steam_id` varchar(32) NOT NULL, PRIMARY KEY (`steam_id`)) TYPE=MyISAM;");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "CREATE TABLE IF NOT EXISTS `charger_cat` (`steam_id` varchar(32) NOT NULL, PRIMARY KEY (`steam_id`)) TYPE=MyISAM;");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "CREATE TABLE IF NOT EXISTS `spitter_cat` (`steam_id` varchar(32) NOT NULL, PRIMARY KEY (`steam_id`)) TYPE=MyISAM;");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "CREATE TABLE IF NOT EXISTS `tank_cat` (`steam_id` varchar(32) NOT NULL, PRIMARY KEY (`steam_id`)) TYPE=MyISAM;");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "CREATE TABLE IF NOT EXISTS `infected_cat` (`steam_id` varchar(32) NOT NULL, PRIMARY KEY (`steam_id`)) TYPE=MyISAM;");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	
	/*	Survivor Persistent Information		*/

	Format(TQuery, sizeof(TQuery), "ALTER TABLE `multiplier_cat` ADD `xp_timer` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `nemesis_cat` ADD `nemesis_steamid` varchar(32) NOT NULL DEFAULT 'none';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `survivor_preset1` ADD `mainweapon1` varchar(32) NOT NULL DEFAULT 'none';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `survivor_preset1` ADD `secondaryweapon1` varchar(32) NOT NULL DEFAULT 'none';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `survivor_preset1` ADD `healthitem1` varchar(32) NOT NULL DEFAULT 'none';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `survivor_preset1` ADD `grenadeitem1` varchar(32) NOT NULL DEFAULT 'none';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `survivor_preset2` ADD `mainweapon2` varchar(32) NOT NULL DEFAULT 'none';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `survivor_preset2` ADD `secondaryweapon2` varchar(32) NOT NULL DEFAULT 'none';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `survivor_preset2` ADD `healthitem2` varchar(32) NOT NULL DEFAULT 'none';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `survivor_preset2` ADD `grenadeitem2` varchar(32) NOT NULL DEFAULT 'none';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `survivor_preset3` ADD `mainweapon3` varchar(32) NOT NULL DEFAULT 'none';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `survivor_preset3` ADD `secondaryweapon3` varchar(32) NOT NULL DEFAULT 'none';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `survivor_preset3` ADD `healthitem3` varchar(32) NOT NULL DEFAULT 'none';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `survivor_preset3` ADD `grenadeitem3` varchar(32) NOT NULL DEFAULT 'none';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);

	Format(TQuery, sizeof(TQuery), "ALTER TABLE `survivor_preset4` ADD `mainweapon4` varchar(32) NOT NULL DEFAULT 'none';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `survivor_preset4` ADD `secondaryweapon4` varchar(32) NOT NULL DEFAULT 'none';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `survivor_preset4` ADD `healthitem4` varchar(32) NOT NULL DEFAULT 'none';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `survivor_preset4` ADD `grenadeitem4` varchar(32) NOT NULL DEFAULT 'none';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `survivor_preset4` ADD `unlocked4` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);

	Format(TQuery, sizeof(TQuery), "ALTER TABLE `survivor_preset5` ADD `mainweapon5` varchar(32) NOT NULL DEFAULT 'none';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `survivor_preset5` ADD `secondaryweapon5` varchar(32) NOT NULL DEFAULT 'none';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `survivor_preset5` ADD `healthitem5` varchar(32) NOT NULL DEFAULT 'none';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `survivor_preset5` ADD `grenadeitem5` varchar(32) NOT NULL DEFAULT 'none';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `survivor_preset5` ADD `unlocked5` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);

	Format(TQuery, sizeof(TQuery), "ALTER TABLE `map_records` ADD `best_kills` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `map_records` ADD `player_name` varchar(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `map_records` ADD `best_headshots` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `map_records` ADD `best_headshots_name` varchar(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `map_records` ADD `best_survivor_dmg` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `map_records` ADD `best_survivor_dmg_name` varchar(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `map_records` ADD `best_infected_damage` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `map_records` ADD `infected_name` varchar(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `map_records` ADD `best_healing` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `map_records` ADD `healing_name` varchar(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `map_records` ADD `best_rescuer` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `map_records` ADD `rescuer_name` varchar(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `sky_store_cat` ADD `sky_points` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `player_cat` ADD `last_name_used` varchar(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `player_cat` ADD `micro_menu` int(32) NOT NULL DEFAULT '1';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `player_cat` ADD `points_display` int(32) NOT NULL DEFAULT '1';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `pistol_cat` ADD `xp` int(16) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `pistol_cat` ADD `next_xp` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `pistol_cat` ADD `lvl` int(16) NOT NULL DEFAULT '1';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `melee_cat` ADD `xp` int(16) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `melee_cat` ADD `next_xp` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `melee_cat` ADD `lvl` int(16) NOT NULL DEFAULT '1';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `uzi_cat` ADD `xp` int(16) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `uzi_cat` ADD `next_xp` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `uzi_cat` ADD `lvl` int(16) NOT NULL DEFAULT '1';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `shotgun_cat` ADD `xp` int(16) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `shotgun_cat` ADD `next_xp` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `shotgun_cat` ADD `lvl` int(16) NOT NULL DEFAULT '1';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `sniper_cat` ADD `xp` int(16) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `sniper_cat` ADD `next_xp` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `sniper_cat` ADD `lvl` int(16) NOT NULL DEFAULT '1';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `rifle_cat` ADD `xp` int(16) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `rifle_cat` ADD `next_xp` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `rifle_cat` ADD `lvl` int(16) NOT NULL DEFAULT '1';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `grenade_cat` ADD `xp` int(16) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `grenade_cat` ADD `next_xp` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `grenade_cat` ADD `lvl` int(16) NOT NULL DEFAULT '1';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `item_cat` ADD `xp` int(16) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `item_cat` ADD `next_xp` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `item_cat` ADD `lvl` int(16) NOT NULL DEFAULT '1';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `physical_cat` ADD `xp` int(16) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `physical_cat` ADD `next_xp` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `physical_cat` ADD `lvl` int(16) NOT NULL DEFAULT '1';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	
	
	/*	Infected Table Stuff	*/
	
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `hunter_cat` ADD `xp` int(16) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `hunter_cat` ADD `next_xp` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `hunter_cat` ADD `lvl` int(16) NOT NULL DEFAULT '1';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `smoker_cat` ADD `xp` int(16) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `smoker_cat` ADD `next_xp` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `smoker_cat` ADD `lvl` int(16) NOT NULL DEFAULT '1';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `boomer_cat` ADD `xp` int(16) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `boomer_cat` ADD `next_xp` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `boomer_cat` ADD `lvl` int(16) NOT NULL DEFAULT '1';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `jockey_cat` ADD `xp` int(16) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `jockey_cat` ADD `next_xp` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `jockey_cat` ADD `lvl` int(16) NOT NULL DEFAULT '1';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `charger_cat` ADD `xp` int(16) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `charger_cat` ADD `next_xp` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `charger_cat` ADD `lvl` int(16) NOT NULL DEFAULT '1';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `spitter_cat` ADD `xp` int(16) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `spitter_cat` ADD `next_xp` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `spitter_cat` ADD `lvl` int(16) NOT NULL DEFAULT '1';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `tank_cat` ADD `xp` int(16) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `tank_cat` ADD `next_xp` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `tank_cat` ADD `lvl` int(16) NOT NULL DEFAULT '1';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `infected_cat` ADD `xp` int(16) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `infected_cat` ADD `next_xp` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `infected_cat` ADD `lvl` int(16) NOT NULL DEFAULT '1';");
	SQL_TQuery(hDatabase, QueryCreateTable, TQuery);
}

public QueryCreateTable( Handle:owner, Handle:hndl, const String:error[], any:data)
{ 
	if ( hndl == INVALID_HANDLE )
	{
		LogError( "%s", error ); 
		
		return;
	} 
}

public QuerySetData( Handle:owner, Handle:hndl, const String:error[], any:data)
{ 
	if ( hndl == INVALID_HANDLE )
	{
		LogError( "%s", error ); 
		
		return;
	} 
}

public QueryPistolData( Handle:owner, Handle:hndl, const String:error[], any:data)
{ 
	if ( hndl != INVALID_HANDLE )
	{
		while ( SQL_FetchRow(hndl) ) 
		{
			PistolExperience[data] = SQL_FetchInt(hndl, 0);
			PistolNextLevel[data] = SQL_FetchInt(hndl, 1);
			PistolLevel[data] = SQL_FetchInt(hndl, 2);
		}
	} 
	else
	{
		LogError( "%s", error ); 
		
		return;
	}
}

public QueryMeleeData( Handle:owner, Handle:hndl, const String:error[], any:data)
{ 
	if ( hndl != INVALID_HANDLE )
	{
		while ( SQL_FetchRow(hndl) ) 
		{
			MeleeExperience[data] = SQL_FetchInt(hndl, 0);
			MeleeNextLevel[data] = SQL_FetchInt(hndl, 1);
			MeleeLevel[data] = SQL_FetchInt(hndl, 2);
		}
	} 
	else
	{
		LogError( "%s", error ); 
		
		return;
	}
}

public QueryUziData( Handle:owner, Handle:hndl, const String:error[], any:data)
{ 
	if ( hndl != INVALID_HANDLE )
	{
		while ( SQL_FetchRow(hndl) ) 
		{
			UziExperience[data] = SQL_FetchInt(hndl, 0);
			UziNextLevel[data] = SQL_FetchInt(hndl, 1);
			UziLevel[data] = SQL_FetchInt(hndl, 2);
		}
	} 
	else
	{
		LogError( "%s", error ); 
		
		return;
	}
}

public QueryShotgunData( Handle:owner, Handle:hndl, const String:error[], any:data)
{ 
	if ( hndl != INVALID_HANDLE )
	{
		while ( SQL_FetchRow(hndl) ) 
		{
			ShotgunExperience[data] = SQL_FetchInt(hndl, 0);
			ShotgunNextLevel[data] = SQL_FetchInt(hndl, 1);
			ShotgunLevel[data] = SQL_FetchInt(hndl, 2);
		}
	} 
	else
	{
		LogError( "%s", error ); 
		
		return;
	}
}

public QuerySniperData( Handle:owner, Handle:hndl, const String:error[], any:data)
{ 
	if ( hndl != INVALID_HANDLE )
	{
		while ( SQL_FetchRow(hndl) ) 
		{
			SniperExperience[data] = SQL_FetchInt(hndl, 0);
			SniperNextLevel[data] = SQL_FetchInt(hndl, 1);
			SniperLevel[data] = SQL_FetchInt(hndl, 2);
		}
	} 
	else
	{
		LogError( "%s", error ); 
		
		return;
	}
}

public QueryRifleData( Handle:owner, Handle:hndl, const String:error[], any:data)
{ 
	if ( hndl != INVALID_HANDLE )
	{
		while ( SQL_FetchRow(hndl) ) 
		{
			RifleExperience[data] = SQL_FetchInt(hndl, 0);
			RifleNextLevel[data] = SQL_FetchInt(hndl, 1);
			RifleLevel[data] = SQL_FetchInt(hndl, 2);
		}
	} 
	else
	{
		LogError( "%s", error ); 
		
		return;
	}
}

public QueryGrenadeData( Handle:owner, Handle:hndl, const String:error[], any:data)
{ 
	if ( hndl != INVALID_HANDLE )
	{
		while ( SQL_FetchRow(hndl) ) 
		{
			GrenadeExperience[data] = SQL_FetchInt(hndl, 0);
			GrenadeNextLevel[data] = SQL_FetchInt(hndl, 1);
			GrenadeLevel[data] = SQL_FetchInt(hndl, 2);
		}
	} 
	else
	{
		LogError( "%s", error ); 
		
		return;
	}
}

public QueryItemData( Handle:owner, Handle:hndl, const String:error[], any:data)
{ 
	if ( hndl != INVALID_HANDLE )
	{
		while ( SQL_FetchRow(hndl) ) 
		{
			ItemExperience[data] = SQL_FetchInt(hndl, 0);
			ItemNextLevel[data] = SQL_FetchInt(hndl, 1);
			ItemLevel[data] = SQL_FetchInt(hndl, 2);
		}
	} 
	else
	{
		LogError( "%s", error ); 
		
		return;
	}
}

public QueryPhysicalData( Handle:owner, Handle:hndl, const String:error[], any:data)
{ 
	if ( hndl != INVALID_HANDLE )
	{
		while ( SQL_FetchRow(hndl) ) 
		{
			PhysicalExperience[data] = SQL_FetchInt(hndl, 0);
			PhysicalNextLevel[data] = SQL_FetchInt(hndl, 1);
			PhysicalLevel[data] = SQL_FetchInt(hndl, 2);
		}
	} 
	else
	{
		LogError( "%s", error ); 
		
		return;
	}
}

public QueryHunterData( Handle:owner, Handle:hndl, const String:error[], any:data)
{ 
	if ( hndl != INVALID_HANDLE )
	{
		while ( SQL_FetchRow(hndl) ) 
		{
			HunterExperience[data] = SQL_FetchInt(hndl, 0);
			HunterNextLevel[data] = SQL_FetchInt(hndl, 1);
			HunterLevel[data] = SQL_FetchInt(hndl, 2);
		}
	} 
	else
	{
		LogError( "%s", error ); 
		
		return;
	}
}

public QuerySmokerData( Handle:owner, Handle:hndl, const String:error[], any:data)
{ 
	if ( hndl != INVALID_HANDLE )
	{
		while ( SQL_FetchRow(hndl) ) 
		{
			SmokerExperience[data] = SQL_FetchInt(hndl, 0);
			SmokerNextLevel[data] = SQL_FetchInt(hndl, 1);
			SmokerLevel[data] = SQL_FetchInt(hndl, 2);
		}
	} 
	else
	{
		LogError( "%s", error ); 
		
		return;
	}
}

public QueryBoomerData( Handle:owner, Handle:hndl, const String:error[], any:data)
{ 
	if ( hndl != INVALID_HANDLE )
	{
		while ( SQL_FetchRow(hndl) ) 
		{
			BoomerExperience[data] = SQL_FetchInt(hndl, 0);
			BoomerNextLevel[data] = SQL_FetchInt(hndl, 1);
			BoomerLevel[data] = SQL_FetchInt(hndl, 2);
		}
	} 
	else
	{
		LogError( "%s", error ); 
		
		return;
	}
}

public QueryJockeyData( Handle:owner, Handle:hndl, const String:error[], any:data)
{ 
	if ( hndl != INVALID_HANDLE )
	{
		while ( SQL_FetchRow(hndl) ) 
		{
			JockeyExperience[data] = SQL_FetchInt(hndl, 0);
			JockeyNextLevel[data] = SQL_FetchInt(hndl, 1);
			JockeyLevel[data] = SQL_FetchInt(hndl, 2);
		}
	} 
	else
	{
		LogError( "%s", error ); 
		
		return;
	}
}

public QueryChargerData( Handle:owner, Handle:hndl, const String:error[], any:data)
{ 
	if ( hndl != INVALID_HANDLE )
	{
		while ( SQL_FetchRow(hndl) ) 
		{
			ChargerExperience[data] = SQL_FetchInt(hndl, 0);
			ChargerNextLevel[data] = SQL_FetchInt(hndl, 1);
			ChargerLevel[data] = SQL_FetchInt(hndl, 2);
		}
	} 
	else
	{
		LogError( "%s", error ); 
		
		return;
	}
}

public QuerySpitterData( Handle:owner, Handle:hndl, const String:error[], any:data)
{ 
	if ( hndl != INVALID_HANDLE )
	{
		while ( SQL_FetchRow(hndl) ) 
		{
			SpitterExperience[data] = SQL_FetchInt(hndl, 0);
			SpitterNextLevel[data] = SQL_FetchInt(hndl, 1);
			SpitterLevel[data] = SQL_FetchInt(hndl, 2);
		}
	} 
	else
	{
		LogError( "%s", error ); 
		
		return;
	}
}

public QueryTankData( Handle:owner, Handle:hndl, const String:error[], any:data)
{ 
	if ( hndl != INVALID_HANDLE )
	{
		while ( SQL_FetchRow(hndl) ) 
		{
			TankExperience[data] = SQL_FetchInt(hndl, 0);
			TankNextLevel[data] = SQL_FetchInt(hndl, 1);
			TankLevel[data] = SQL_FetchInt(hndl, 2);
		}
	} 
	else
	{
		LogError( "%s", error ); 
		
		return;
	}
}

public QueryInfectedData( Handle:owner, Handle:hndl, const String:error[], any:data)
{ 
	if ( hndl != INVALID_HANDLE )
	{
		while ( SQL_FetchRow(hndl) ) 
		{
			InfectedExperience[data] = SQL_FetchInt(hndl, 0);
			InfectedNextLevel[data] = SQL_FetchInt(hndl, 1);
			InfectedLevel[data] = SQL_FetchInt(hndl, 2);
		}
	} 
	else
	{
		LogError( "%s", error ); 
		
		return;
	}
}

public QueryMapData( Handle:owner, Handle:hndl, const String:error[], any:data)
{ 
	if ( hndl != INVALID_HANDLE )
	{
		while ( SQL_FetchRow(hndl) ) 
		{
			MapBestKills = SQL_FetchInt(hndl, 0);
			SQL_FetchString(hndl, 1, MapBestKillsName, sizeof(MapBestKillsName));
			MapBestSurvivorHS = SQL_FetchInt(hndl, 2);
			SQL_FetchString(hndl, 3, MapBestSurvivorHSName, sizeof(MapBestSurvivorHSName));
			MapBestSurvivorDamage = SQL_FetchInt(hndl, 4);
			SQL_FetchString(hndl, 5, MapBestSurvivorDamageName, sizeof(MapBestSurvivorDamageName));
			MapBestInfectedDamage = SQL_FetchInt(hndl, 6);
			SQL_FetchString(hndl, 7, MapBestInfectedDamageName, sizeof(MapBestInfectedDamageName));
			MapBestHealing = SQL_FetchInt(hndl, 8);
			SQL_FetchString(hndl, 9, MapBestHealingName, sizeof(MapBestHealingName));
			MapBestRescuer = SQL_FetchInt(hndl, 10);
			SQL_FetchString(hndl, 11, MapBestHealingName, sizeof(MapBestRescuerName));
			
		}
	} 
	else
	{
		LogError( "%s", error ); 
		
		return;
	}
}

public QuerySkyData( Handle:owner, Handle:hndl, const String:error[], any:data)
{ 
	if ( hndl != INVALID_HANDLE )
	{
		while ( SQL_FetchRow(hndl) ) 
		{
			decl String:Name[MAX_NAME_LENGTH];
			SQL_FetchString(hndl, 0, Name, sizeof(Name));
			//SetClientInfo(data, "name", Name);
			showinfo[data] = SQL_FetchInt(hndl, 1);
			showpoints[data] = SQL_FetchInt(hndl, 2);
		}
	} 
	else
	{
		LogError( "%s", error ); 
		
		return;
	}
}

public QuerySkyPointsData( Handle:owner, Handle:hndl, const String:error[], any:data)
{ 
	if ( hndl != INVALID_HANDLE )
	{
		while ( SQL_FetchRow(hndl) ) 
		{
			SkyPoints[data] = SQL_FetchInt(hndl, 0);
		}
	} 
	else
	{
		LogError( "%s", error ); 
		
		return;
	}
}

public QueryMultiplierData( Handle:owner, Handle:hndl, const String:error[], any:data)
{ 
	if ( hndl != INVALID_HANDLE )
	{
		while ( SQL_FetchRow(hndl) ) 
		{
			XPMultiplierTime[data] = SQL_FetchInt(hndl, 0);
		}
	} 
	else
	{
		LogError( "%s", error ); 
		
		return;
	}
}

public QueryPreset1Data( Handle:owner, Handle:hndl, const String:error[], any:data)
{ 
	if ( hndl != INVALID_HANDLE )
	{
		while ( SQL_FetchRow(hndl) ) 
		{
			decl String:DataInput[64];
			SQL_FetchString(hndl, 0, DataInput, sizeof(DataInput));
			PrimaryPreset1[data] = DataInput;

			SQL_FetchString(hndl, 1, DataInput, sizeof(DataInput));
			SecondaryPreset1[data] = DataInput;

			SQL_FetchString(hndl, 2, DataInput, sizeof(DataInput));
			Option1Preset1[data] = DataInput;

			SQL_FetchString(hndl, 3, DataInput, sizeof(DataInput));
			Option2Preset1[data] = DataInput;
		}
	} 
	else
	{
		LogError( "%s", error ); 
		
		return;
	}
}

public QueryPreset2Data( Handle:owner, Handle:hndl, const String:error[], any:data)
{ 
	if ( hndl != INVALID_HANDLE )
	{
		while ( SQL_FetchRow(hndl) ) 
		{
			decl String:DataInput[64];
			SQL_FetchString(hndl, 0, DataInput, sizeof(DataInput));
			PrimaryPreset2[data] = DataInput;

			SQL_FetchString(hndl, 1, DataInput, sizeof(DataInput));
			SecondaryPreset2[data] = DataInput;

			SQL_FetchString(hndl, 2, DataInput, sizeof(DataInput));
			Option1Preset2[data] = DataInput;

			SQL_FetchString(hndl, 3, DataInput, sizeof(DataInput));
			Option2Preset2[data] = DataInput;
		}
	} 
	else
	{
		LogError( "%s", error ); 
		
		return;
	}
}

public QueryPreset3Data( Handle:owner, Handle:hndl, const String:error[], any:data)
{ 
	if ( hndl != INVALID_HANDLE )
	{
		while ( SQL_FetchRow(hndl) ) 
		{
			decl String:DataInput[64];
			SQL_FetchString(hndl, 0, DataInput, sizeof(DataInput));
			PrimaryPreset3[data] = DataInput;

			SQL_FetchString(hndl, 1, DataInput, sizeof(DataInput));
			SecondaryPreset3[data] = DataInput;

			SQL_FetchString(hndl, 2, DataInput, sizeof(DataInput));
			Option1Preset3[data] = DataInput;

			SQL_FetchString(hndl, 3, DataInput, sizeof(DataInput));
			Option2Preset3[data] = DataInput;
		}
	} 
	else
	{
		LogError( "%s", error ); 
		
		return;
	}
}

public QueryPreset4Data( Handle:owner, Handle:hndl, const String:error[], any:data)
{ 
	if ( hndl != INVALID_HANDLE )
	{
		while ( SQL_FetchRow(hndl) ) 
		{
			decl String:DataInput[64];
			SQL_FetchString(hndl, 0, DataInput, sizeof(DataInput));
			PrimaryPreset4[data] = DataInput;

			SQL_FetchString(hndl, 1, DataInput, sizeof(DataInput));
			SecondaryPreset4[data] = DataInput;

			SQL_FetchString(hndl, 2, DataInput, sizeof(DataInput));
			Option1Preset4[data] = DataInput;

			SQL_FetchString(hndl, 3, DataInput, sizeof(DataInput));
			Option2Preset4[data] = DataInput;

			Preset4[data] = SQL_FetchInt(hndl, 4);
		}
	} 
	else
	{
		LogError( "%s", error ); 
		
		return;
	}
}

public QueryPreset5Data( Handle:owner, Handle:hndl, const String:error[], any:data)
{ 
	if ( hndl != INVALID_HANDLE )
	{
		while ( SQL_FetchRow(hndl) ) 
		{
			decl String:DataInput[64];
			SQL_FetchString(hndl, 0, DataInput, sizeof(DataInput));
			PrimaryPreset5[data] = DataInput;

			SQL_FetchString(hndl, 1, DataInput, sizeof(DataInput));
			SecondaryPreset5[data] = DataInput;

			SQL_FetchString(hndl, 2, DataInput, sizeof(DataInput));
			Option1Preset5[data] = DataInput;

			SQL_FetchString(hndl, 3, DataInput, sizeof(DataInput));
			Option2Preset5[data] = DataInput;

			Preset5[data] = SQL_FetchInt(hndl, 4);
		}
	} 
	else
	{
		LogError( "%s", error ); 
		
		return;
	}
}

public QueryNemesisData( Handle:owner, Handle:hndl, const String:error[], any:data)
{ 
	if ( hndl != INVALID_HANDLE )
	{
		while ( SQL_FetchRow(hndl) ) 
		{
			decl String:DataInput[64];
			SQL_FetchString(hndl, 0, DataInput, sizeof(DataInput));
			Nemesis[data] = DataInput;
			decl String:Query[256];
			Format(Query, sizeof(Query), "SELECT `last_name_used` FROM `player_cat` WHERE (`steam_id` = '%s');", Nemesis[data]);
			SQL_TQuery(hDatabase, QueryNemesisNameData, Query, data);
		}
	} 
	else
	{
		LogError( "%s", error ); 
		
		return;
	}
}

public QueryNemesisNameData( Handle:owner, Handle:hndl, const String:error[], any:data)
{ 
	if ( hndl != INVALID_HANDLE )
	{
		while ( SQL_FetchRow(hndl) ) 
		{
			decl String:DataInput[256];
			SQL_FetchString(hndl, 0, DataInput, sizeof(DataInput));
			NemesisName[data] = DataInput;
		}
	} 
	else
	{
		LogError( "%s", error ); 
		
		return;
	}
}

SaveSkyPoints(client)
{
	decl String:Query[256];
	decl String:Key[64];
	decl String:Name[256];
	GetClientAuthString(client, Key, 65);
	GetClientName(client, Name, 257);
	if (StrEqual(Key, "BOT")) return;
	Format(Query, sizeof(Query), "REPLACE INTO `sky_store_cat` (`steam_id`, `sky_points`) VALUES ('%s', '%d');", Key, SkyPoints[client]);
	SQL_TQuery(hDatabase, QuerySetData, Query, client);
}

SaveData(client)
{
	decl String:Query[256];
	decl String:Key[64];
	decl String:Name[256];
	GetClientAuthString(client, Key, 65);
	GetClientName(client, Name, 257);
	if (StrEqual(Key, "BOT")) return;		// BOT. Don't allow.
	Format(Query, sizeof(Query), "REPLACE INTO `multiplier_cat` (`steam_id`, `xp_timer`) VALUES ('%s', '%d');", Key, XPMultiplierTime[client]);
	SQL_TQuery(hDatabase, QuerySetData, Query, client);
	Format(Query, sizeof(Query), "REPLACE INTO `nemesis_cat` (`steam_id`, `nemesis_steamid`) VALUES ('%s', '%s');", Key, Nemesis[client]);
	SQL_TQuery(hDatabase, QuerySetData, Query, client);
	Format(Query, sizeof(Query), "REPLACE INTO `player_cat` (`steam_id`, `last_name_used`, `micro_menu`, `points_display`) VALUES ('%s', '%s', '%d', '%d');", Key, Name, showinfo[client], showpoints[client]);
	SQL_TQuery(hDatabase, QuerySetData, Query, client);
	Format(Query, sizeof(Query), "REPLACE INTO `pistol_cat` (`steam_id`, `xp`, `next_xp`, `lvl`) VALUES ('%s', '%d', '%d', '%d');", Key, PistolExperience[client], PistolNextLevel[client], PistolLevel[client]);
	SQL_TQuery(hDatabase, QuerySetData, Query, client);
	Format(Query, sizeof(Query), "REPLACE INTO `melee_cat` (`steam_id`, `xp`, `next_xp`, `lvl`) VALUES ('%s', '%d', '%d', '%d');", Key, MeleeExperience[client], MeleeNextLevel[client], MeleeLevel[client]);
	SQL_TQuery(hDatabase, QuerySetData, Query, client);
	Format(Query, sizeof(Query), "REPLACE INTO `uzi_cat` (`steam_id`, `xp`, `next_xp`, `lvl`) VALUES ('%s', '%d', '%d', '%d');", Key, UziExperience[client], UziNextLevel[client], UziLevel[client]);
	SQL_TQuery(hDatabase, QuerySetData, Query, client);
	Format(Query, sizeof(Query), "REPLACE INTO `shotgun_cat` (`steam_id`, `xp`, `next_xp`, `lvl`) VALUES ('%s', '%d', '%d', '%d');", Key, ShotgunExperience[client], ShotgunNextLevel[client], ShotgunLevel[client]);
	SQL_TQuery(hDatabase, QuerySetData, Query, client);
	Format(Query, sizeof(Query), "REPLACE INTO `sniper_cat` (`steam_id`, `xp`, `next_xp`, `lvl`) VALUES ('%s', '%d', '%d', '%d');", Key, SniperExperience[client], SniperNextLevel[client], SniperLevel[client]);
	SQL_TQuery(hDatabase, QuerySetData, Query, client);
	Format(Query, sizeof(Query), "REPLACE INTO `rifle_cat` (`steam_id`, `xp`, `next_xp`, `lvl`) VALUES ('%s', '%d', '%d', '%d');", Key, RifleExperience[client], RifleNextLevel[client], RifleLevel[client]);
	SQL_TQuery(hDatabase, QuerySetData, Query, client);
	Format(Query, sizeof(Query), "REPLACE INTO `grenade_cat` (`steam_id`, `xp`, `next_xp`, `lvl`) VALUES ('%s', '%d', '%d', '%d');", Key, GrenadeExperience[client], GrenadeNextLevel[client], GrenadeLevel[client]);
	SQL_TQuery(hDatabase, QuerySetData, Query, client);
	Format(Query, sizeof(Query), "REPLACE INTO `item_cat` (`steam_id`, `xp`, `next_xp`, `lvl`) VALUES ('%s', '%d', '%d', '%d');", Key, ItemExperience[client], ItemNextLevel[client], ItemLevel[client]);
	SQL_TQuery(hDatabase, QuerySetData, Query, client);
	Format(Query, sizeof(Query), "REPLACE INTO `physical_cat` (`steam_id`, `xp`, `next_xp`, `lvl`) VALUES ('%s', '%d', '%d', '%d');", Key, PhysicalExperience[client], PhysicalNextLevel[client], PhysicalLevel[client]);
	SQL_TQuery(hDatabase, QuerySetData, Query, client);
	Format(Query, sizeof(Query), "REPLACE INTO `hunter_cat` (`steam_id`, `xp`, `next_xp`, `lvl`) VALUES ('%s', '%d', '%d', '%d');", Key, HunterExperience[client], HunterNextLevel[client], HunterLevel[client]);
	SQL_TQuery(hDatabase, QuerySetData, Query, client);
	Format(Query, sizeof(Query), "REPLACE INTO `smoker_cat` (`steam_id`, `xp`, `next_xp`, `lvl`) VALUES ('%s', '%d', '%d', '%d');", Key, SmokerExperience[client], SmokerNextLevel[client], SmokerLevel[client]);
	SQL_TQuery(hDatabase, QuerySetData, Query, client);
	Format(Query, sizeof(Query), "REPLACE INTO `boomer_cat` (`steam_id`, `xp`, `next_xp`, `lvl`) VALUES ('%s', '%d', '%d', '%d');", Key, BoomerExperience[client], BoomerNextLevel[client], BoomerLevel[client]);
	SQL_TQuery(hDatabase, QuerySetData, Query, client);
	Format(Query, sizeof(Query), "REPLACE INTO `jockey_cat` (`steam_id`, `xp`, `next_xp`, `lvl`) VALUES ('%s', '%d', '%d', '%d');", Key, JockeyExperience[client], JockeyNextLevel[client], JockeyLevel[client]);
	SQL_TQuery(hDatabase, QuerySetData, Query, client);
	Format(Query, sizeof(Query), "REPLACE INTO `charger_cat` (`steam_id`, `xp`, `next_xp`, `lvl`) VALUES ('%s', '%d', '%d', '%d');", Key, ChargerExperience[client], ChargerNextLevel[client], ChargerLevel[client]);
	SQL_TQuery(hDatabase, QuerySetData, Query, client);
	Format(Query, sizeof(Query), "REPLACE INTO `spitter_cat` (`steam_id`, `xp`, `next_xp`, `lvl`) VALUES ('%s', '%d', '%d', '%d');", Key, SpitterExperience[client], SpitterNextLevel[client], SpitterLevel[client]);
	SQL_TQuery(hDatabase, QuerySetData, Query, client);
	Format(Query, sizeof(Query), "REPLACE INTO `tank_cat` (`steam_id`, `xp`, `next_xp`, `lvl`) VALUES ('%s', '%d', '%d', '%d');", Key, TankExperience[client], TankNextLevel[client], TankLevel[client]);
	SQL_TQuery(hDatabase, QuerySetData, Query, client);
	Format(Query, sizeof(Query), "REPLACE INTO `infected_cat` (`steam_id`, `xp`, `next_xp`, `lvl`) VALUES ('%s', '%d', '%d', '%d');", Key, InfectedExperience[client], InfectedNextLevel[client], InfectedLevel[client]);
	SQL_TQuery(hDatabase, QuerySetData, Query, client);
	Format(Query, sizeof(Query), "REPLACE INTO `survivor_preset1` (`steam_id`, `mainweapon1`, `secondaryweapon1`, `healthitem1`, `grenadeitem1`) VALUES ('%s', '%s', '%s', '%s', '%s');", Key, PrimaryPreset1[client], SecondaryPreset1[client], Option1Preset1[client], Option2Preset1[client]);
	SQL_TQuery(hDatabase, QuerySetData, Query, client);
	Format(Query, sizeof(Query), "REPLACE INTO `survivor_preset2` (`steam_id`, `mainweapon2`, `secondaryweapon2`, `healthitem2`, `grenadeitem2`) VALUES ('%s', '%s', '%s', '%s', '%s');", Key, PrimaryPreset2[client], SecondaryPreset2[client], Option1Preset2[client], Option2Preset2[client]);
	SQL_TQuery(hDatabase, QuerySetData, Query, client);
	Format(Query, sizeof(Query), "REPLACE INTO `survivor_preset3` (`steam_id`, `mainweapon3`, `secondaryweapon3`, `healthitem3`, `grenadeitem3`) VALUES ('%s', '%s', '%s', '%s', '%s');", Key, PrimaryPreset3[client], SecondaryPreset3[client], Option1Preset3[client], Option2Preset3[client]);
	SQL_TQuery(hDatabase, QuerySetData, Query, client);
	Format(Query, sizeof(Query), "REPLACE INTO `survivor_preset4` (`steam_id`, `mainweapon4`, `secondaryweapon4`, `healthitem4`, `grenadeitem4`, `unlocked4`) VALUES ('%s', '%s', '%s', '%s', '%s', '%d');", Key, PrimaryPreset4[client], SecondaryPreset4[client], Option1Preset4[client], Option2Preset4[client], Preset4[client]);
	SQL_TQuery(hDatabase, QuerySetData, Query, client);
	Format(Query, sizeof(Query), "REPLACE INTO `survivor_preset5` (`steam_id`, `mainweapon5`, `secondaryweapon5`, `healthitem5`, `grenadeitem5`, `unlocked5`) VALUES ('%s', '%s', '%s', '%s', '%s', '%d');", Key, PrimaryPreset5[client], SecondaryPreset5[client], Option1Preset5[client], Option2Preset5[client], Preset5[client]);
	SQL_TQuery(hDatabase, QuerySetData, Query, client);
	
	/*		Notify the player that we saved their data		*/
}

Load_MapRecords()
{
	decl String:MapName[256];
	decl String:Query[1024];
	GetCurrentMap(MapName, sizeof(MapName));
	Format(Query, sizeof(Query), "SELECT `best_kills`, `player_name`, `best_headshots`, `best_headshots_name`, `best_survivor_dmg`, `best_survivor_dmg_name`, `best_infected_damage`, `infected_name`, `best_healing`, `healing_name`, `best_rescuer`, `rescuer_name` FROM `map_records` WHERE (`map_name` = '%s');", MapName);
	SQL_TQuery(hDatabase, QueryMapData, Query, 0);
}

Save_MapRecords()
{
	// A map record has been beaten. Let's save it.
	
	decl String:MapName[256];
	decl String:Query[1024];
	GetCurrentMap(MapName, sizeof(MapName));
	Format(Query, sizeof(Query), "REPLACE INTO `map_records` (`map_name`, `best_kills`, `player_name`, `best_headshots`, `best_headshots_name`, `best_survivor_dmg`, `best_survivor_dmg_name`, `best_infected_damage`, `infected_name`, `best_healing`, `healing_name`, `best_rescuer`, `rescuer_name` ) VALUES ('%s', '%d', '%s', '%d', '%s', '%d', '%s', '%d', '%s', '%d', '%s', '%d', '%s');", MapName, MapBestKills, MapBestKillsName, MapBestSurvivorHS, MapBestSurvivorHSName, MapBestSurvivorDamage, MapBestSurvivorDamageName, MapBestInfectedDamage, MapBestInfectedDamageName, MapBestHealing, MapBestHealingName, MapBestRescuer, MapBestRescuerName);
	SQL_TQuery(hDatabase, QuerySetData, Query, 0);
}

AnnounceMapRecord()
{
	PrintToChatAll("%s \x04New Map Challenges \x03are now posted \x01on your menu's \x05Challenge Board\x01!", INFO);
}

LoadData(client)
{
	if (IsClientIndexOutOfRange(client) || !IsClientInGame(client) || IsFakeClient(client)) return;
	decl String:Query[256];
	decl String:Key[64];
	GetClientAuthString(client, Key, 65);
	
	/*		LOAD SURVIVOR DATA		*/

	Format(Query, sizeof(Query), "SELECT `nemesis_steamid` FROM `nemesis_cat` WHERE (`steam_id` = '%s');", Key);
	SQL_TQuery(hDatabase, QueryNemesisData, Query, client);
	Format(Query, sizeof(Query), "SELECT `mainweapon1`, `secondaryweapon1`, `healthitem1`, `grenadeitem1` FROM `survivor_preset1` WHERE (`steam_id` = '%s');", Key);
	SQL_TQuery(hDatabase, QueryPreset1Data, Query, client);
	Format(Query, sizeof(Query), "SELECT `mainweapon2`, `secondaryweapon2`, `healthitem2`, `grenadeitem2` FROM `survivor_preset2` WHERE (`steam_id` = '%s');", Key);
	SQL_TQuery(hDatabase, QueryPreset2Data, Query, client);
	Format(Query, sizeof(Query), "SELECT `mainweapon3`, `secondaryweapon3`, `healthitem3`, `grenadeitem3` FROM `survivor_preset3` WHERE (`steam_id` = '%s');", Key);
	SQL_TQuery(hDatabase, QueryPreset3Data, Query, client);
	Format(Query, sizeof(Query), "SELECT `mainweapon4`, `secondaryweapon4`, `healthitem4`, `grenadeitem4`, `unlocked4` FROM `survivor_preset4` WHERE (`steam_id` = '%s');", Key);
	SQL_TQuery(hDatabase, QueryPreset4Data, Query, client);
	Format(Query, sizeof(Query), "SELECT `mainweapon5`, `secondaryweapon5`, `healthitem5`, `grenadeitem5`, `unlocked5` FROM `survivor_preset5` WHERE (`steam_id` = '%s');", Key);
	SQL_TQuery(hDatabase, QueryPreset5Data, Query, client);

	Format(Query, sizeof(Query), "SELECT `xp_timer` FROM `multiplier_cat` WHERE (`steam_id` = '%s');", Key);
	SQL_TQuery(hDatabase, QueryMultiplierData, Query, client);
	Format(Query, sizeof(Query), "SELECT `sky_points` FROM `sky_store_cat` WHERE (`steam_id` = '%s');", Key);
	SQL_TQuery(hDatabase, QuerySkyPointsData, Query, client);
	Format(Query, sizeof(Query), "SELECT `last_name_used`, `micro_menu`, `points_display` FROM `player_cat` WHERE (`steam_id` = '%s');", Key);
	SQL_TQuery(hDatabase, QuerySkyData, Query, client);
	Format(Query, sizeof(Query), "SELECT `xp`, `next_xp`, `lvl` FROM `pistol_cat` WHERE (`steam_id` = '%s');", Key);
	SQL_TQuery(hDatabase, QueryPistolData, Query, client);
	Format(Query, sizeof(Query), "SELECT `xp`, `next_xp`, `lvl` FROM `melee_cat` WHERE (`steam_id` = '%s');", Key);
	SQL_TQuery(hDatabase, QueryMeleeData, Query, client);
	Format(Query, sizeof(Query), "SELECT `xp`, `next_xp`, `lvl` FROM `uzi_cat` WHERE (`steam_id` = '%s');", Key);
	SQL_TQuery(hDatabase, QueryUziData, Query, client);
	Format(Query, sizeof(Query), "SELECT `xp`, `next_xp`, `lvl` FROM `shotgun_cat` WHERE (`steam_id` = '%s');", Key);
	SQL_TQuery(hDatabase, QueryShotgunData, Query, client);
	Format(Query, sizeof(Query), "SELECT `xp`, `next_xp`, `lvl` FROM `sniper_cat` WHERE (`steam_id` = '%s');", Key);
	SQL_TQuery(hDatabase, QuerySniperData, Query, client);
	Format(Query, sizeof(Query), "SELECT `xp`, `next_xp`, `lvl` FROM `rifle_cat` WHERE (`steam_id` = '%s');", Key);
	SQL_TQuery(hDatabase, QueryRifleData, Query, client);
	Format(Query, sizeof(Query), "SELECT `xp`, `next_xp`, `lvl` FROM `grenade_cat` WHERE (`steam_id` = '%s');", Key);
	SQL_TQuery(hDatabase, QueryGrenadeData, Query, client);
	Format(Query, sizeof(Query), "SELECT `xp`, `next_xp`, `lvl` FROM `item_cat` WHERE (`steam_id` = '%s');", Key);
	SQL_TQuery(hDatabase, QueryItemData, Query, client);
	Format(Query, sizeof(Query), "SELECT `xp`, `next_xp`, `lvl` FROM `physical_cat` WHERE (`steam_id` = '%s');", Key);
	SQL_TQuery(hDatabase, QueryPhysicalData, Query, client);
	Format(Query, sizeof(Query), "SELECT `xp`, `next_xp`, `lvl` FROM `hunter_cat` WHERE (`steam_id` = '%s');", Key);
	SQL_TQuery(hDatabase, QueryHunterData, Query, client);
	Format(Query, sizeof(Query), "SELECT `xp`, `next_xp`, `lvl` FROM `smoker_cat` WHERE (`steam_id` = '%s');", Key);
	SQL_TQuery(hDatabase, QuerySmokerData, Query, client);
	Format(Query, sizeof(Query), "SELECT `xp`, `next_xp`, `lvl` FROM `boomer_cat` WHERE (`steam_id` = '%s');", Key);
	SQL_TQuery(hDatabase, QueryBoomerData, Query, client);
	Format(Query, sizeof(Query), "SELECT `xp`, `next_xp`, `lvl` FROM `jockey_cat` WHERE (`steam_id` = '%s');", Key);
	SQL_TQuery(hDatabase, QueryJockeyData, Query, client);
	Format(Query, sizeof(Query), "SELECT `xp`, `next_xp`, `lvl` FROM `charger_cat` WHERE (`steam_id` = '%s');", Key);
	SQL_TQuery(hDatabase, QueryChargerData, Query, client);
	Format(Query, sizeof(Query), "SELECT `xp`, `next_xp`, `lvl` FROM `spitter_cat` WHERE (`steam_id` = '%s');", Key);
	SQL_TQuery(hDatabase, QuerySpitterData, Query, client);
	Format(Query, sizeof(Query), "SELECT `xp`, `next_xp`, `lvl` FROM `tank_cat` WHERE (`steam_id` = '%s');", Key);
	SQL_TQuery(hDatabase, QueryTankData, Query, client);
	Format(Query, sizeof(Query), "SELECT `xp`, `next_xp`, `lvl` FROM `infected_cat` WHERE (`steam_id` = '%s');", Key);
	SQL_TQuery(hDatabase, QueryInfectedData, Query, client);

	if (XPMultiplierTime[client] > 0 && !XPMultiplierTimer[client])
	{
		XPMultiplierTimer[client] = true;
		CreateTimer(1.0, DeductMultiplierTime, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}