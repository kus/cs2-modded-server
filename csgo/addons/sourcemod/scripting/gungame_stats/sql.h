enum DbType
{
    DbTypeSqlite,
    DbTypeMysql,
    DbTypePgsql,
    MaxDbTypes
};

new DbType:g_DbType;
new Handle:g_DbConnection = INVALID_HANDLE;

new const String:g_sql_createPlayerTable[DbType:MaxDbTypes][]   =
{
    "CREATE TABLE IF NOT EXISTS gungame_playerdata (   id INTEGER PRIMARY KEY AUTOINCREMENT, wins int(12) NOT NULL default 0, authid varchar(255) NOT NULL default '', name varchar(255) NOT NULL default '', timestamp timestamp NOT NULL default CURRENT_TIMESTAMP );",
    "CREATE TABLE IF NOT EXISTS `gungame_playerdata`(`id` int(11) NOT NULL auto_increment,`wins` int(12) NOT NULL default '0',`authid` varchar(255) NOT NULL default '',`name` varchar(255) NOT NULL default '',`timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP,PRIMARY KEY  (`id`),KEY `wins` (`wins`),KEY `authid` (`authid`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;",
    "CREATE TABLE gungame_playerdata (id serial, wins int NOT NULL default 0, authid varchar(255) NOT NULL default '', name  varchar(255) NOT NULL default '', timestamp timestamp NOT NULL default CURRENT_TIMESTAMP, PRIMARY KEY (id));"
};
new const String:g_sql_createPlayerTableIndex1[DbType:MaxDbTypes][]  = 
{
    "CREATE INDEX wins ON gungame_playerdata(wins);",
    "",
    "CREATE INDEX gg_playerdata_wins ON gungame_playerdata(wins);"
};
new const String:g_sql_createPlayerTableIndex2[DbType:MaxDbTypes][]  =
{
    "CREATE INDEX authid ON gungame_playerdata(authid);",
    "",
    "CREATE INDEX gg_playerdata_authid ON gungame_playerdata(authid);"
};
new const String:g_sql_checkTableExists[DbType:MaxDbTypes][]    =
{
    "SELECT name FROM sqlite_master WHERE name = 'gungame_playerdata';",
    "SHOW TABLES like 'gungame_playerdata';",
    "SELECT table_name FROM information_schema.tables WHERE table_name = 'gungame_playerdata';"
};
new const String:g_sql_dropPlayerTable[]      = "DROP TABLE IF EXISTS gungame_playerdata;";

new const String:g_sql_insertPlayer[]         = "INSERT INTO gungame_playerdata (wins, name, timestamp, authid) VALUES (%i, '%s', current_timestamp, '%s');";
new const String:g_sql_updatePlayerByAuth[]   = "UPDATE gungame_playerdata SET wins = %i, name = '%s', timestamp = current_timestamp WHERE authid = '%s';";
new const String:g_sql_getPlayerPlaceByWins[] = "SELECT count(*) FROM gungame_playerdata WHERE wins > %i;";
new const String:g_sql_getPlayersCount[]      = "SELECT count(*) FROM gungame_playerdata;";
new const String:g_sql_getPlayerByAuth[]      = "SELECT id, wins, name FROM gungame_playerdata WHERE authid = '%s';";
new const String:g_sql_updatePlayerTsById[]   = "UPDATE gungame_playerdata SET timestamp = current_timestamp WHERE id = %i;";
new const String:g_sql_getTopPlayers[]        = "SELECT id, wins, name, authid FROM gungame_playerdata ORDER by wins desc, id LIMIT %i OFFSET %i;";

new const String:g_sql_prunePlayers[DbType:MaxDbTypes][]    =
{
    "DELETE FROM gungame_playerdata WHERE timestamp < %i;",
    "DELETE FROM gungame_playerdata WHERE timestamp < current_timestamp - interval %i day;",
    "DELETE FROM gungame_playerdata WHERE timestamp < current_timestamp - interval '%i day';"
};

