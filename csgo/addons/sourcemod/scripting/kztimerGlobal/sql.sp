//TABLE CHALLENGE
new String:sql_createChallenges[] 				= "CREATE TABLE IF NOT EXISTS challenges (steamid VARCHAR(32) NOT NULL, steamid2 VARCHAR(32) NOT NULL, bet INT(12) NOT NULL DEFAULT '-1', cp_allowed INT(12) NOT NULL DEFAULT '-1', map VARCHAR(32) NOT NULL, date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY(steamid,steamid2,date));";
new String:sql_insertChallenges[] 				= "INSERT INTO challenges (steamid, steamid2, bet, map, cp_allowed) VALUES('%s', '%s','%i','%s','%i');";
new String:sql_selectChallenges2[] 				= "SELECT steamid, steamid2, bet, cp_allowed, map, date FROM challenges where steamid = '%s' OR steamid2 ='%s' ORDER BY date DESC";
new String:sql_selectChallenges[] 				= "SELECT steamid, steamid2, bet, cp_allowed, map FROM challenges where steamid = '%s' OR steamid2 ='%s'";
new String:sql_selectChallengesCompare[] 		= "SELECT steamid, steamid2, bet FROM challenges where (steamid = '%s' AND steamid2 ='%s') OR (steamid = '%s' AND steamid2 ='%s')";
new String:sql_deleteChallenges[] 				= "DELETE from challenges where steamid = '%s'";

//TABLE LATEST 15 LOCAL RECORDS
new String:sql_createLatestRecords[] 			= "CREATE TABLE IF NOT EXISTS LatestRecords (steamid VARCHAR(32) NOT NULL, name VARCHAR(32) NOT NULL, runtime FLOAT NOT NULL DEFAULT '-1.0', teleports INT(12) NOT NULL DEFAULT '-1', map VARCHAR(32) NOT NULL, date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY(steamid,map,date));";
new String:sql_insertLatestRecords[] 			= "INSERT INTO LatestRecords (steamid, name, runtime, teleports, map) VALUES('%s','%s','%f','%i','%s');";
new String:sql_selectLatestRecords[] 			= "SELECT name, runtime, teleports, map, date FROM LatestRecords ORDER BY date DESC LIMIT 50";

//TABLE PLAYEROPTIONS
new String:sql_createPlayerOptions[] 			= "CREATE TABLE IF NOT EXISTS playeroptions2 (steamid VARCHAR(32) NOT NULL, colorchat INT(12) NOT NULL DEFAULT '1' , speedmeter INT(12) NOT NULL DEFAULT '0' , climbersmenu_sounds INT(12) NOT NULL DEFAULT '1' , quake_sounds INT(12) NOT NULL DEFAULT '1' , autobhop INT(12) NOT NULL DEFAULT '0' , shownames INT(12) NOT NULL DEFAULT '1' , goto INT(12) NOT NULL DEFAULT '1' , strafesync INT(12) NOT NULL DEFAULT '0' , showtime INT(12) NOT NULL DEFAULT '1' , hideplayers INT(12) NOT NULL DEFAULT '0' , showspecs INT(12) NOT NULL DEFAULT '1' , cpmessage INT(12) NOT NULL DEFAULT '0' , adv_menu INT(12) NOT NULL DEFAULT '0' , knife VARCHAR(32) NOT NULL DEFAULT 'weapon_knife', jumppenalty INT(12) NOT NULL DEFAULT '0' , new1 INT(12) NOT NULL DEFAULT '0' , new2 INT(12) NOT NULL DEFAULT '0' , new3 INT(12) NOT NULL DEFAULT '0' , error_sounds INT(12) NOT NULL DEFAULT '1', PRIMARY KEY(steamid));";
new String:sql_insertPlayerOptions[] 			= "INSERT INTO playeroptions2 (steamid, colorchat, speedmeter, climbersmenu_sounds, quake_sounds, autobhop, shownames, goto, strafesync, showtime, hideplayers, showspecs, cpmessage, adv_menu, knife, jumppenalty, new1, new2, new3, ViewModel, AdvInfoPanel, ReplayRoute,Language, error_sounds) VALUES('%s', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%s', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i')";
new String:sql_selectPlayerOptions[] 			= "SELECT colorchat, speedmeter, climbersmenu_sounds, quake_sounds, autobhop, shownames, goto, strafesync, showtime, hideplayers, showspecs, cpmessage, adv_menu, knife, jumppenalty, new1, new2, new3, ViewModel,  AdvInfoPanel, ReplayRoute,Language, error_sounds FROM playeroptions2 where steamid = '%s'";
new String:sql_updatePlayerOptions[] 			= "UPDATE playeroptions2 SET colorchat ='%i', speedmeter ='%i', climbersmenu_sounds ='%i', quake_sounds ='%i', autobhop ='%i', shownames ='%i', goto ='%i', strafesync ='%i', showtime ='%i', hideplayers ='%i', showspecs ='%i', cpmessage ='%i', adv_menu ='%i', knife ='%s', jumppenalty ='%i', new1 = '%i', new2 = '%i', new3 = '%i', ViewModel = '%i', AdvInfoPanel ='%i', ReplayRoute ='%i', Language ='%i', error_sounds = '%i' where steamid = '%s';";

//TABLE PLAYERRANK
new String:sql_createPlayerRank[]				= "CREATE TABLE IF NOT EXISTS playerrank (steamid VARCHAR(32) NOT NULL, name VARCHAR(32) NOT NULL, country VARCHAR(32) NOT NULL, points INT(12) NOT NULL DEFAULT '0', winratio INT(12) NOT NULL DEFAULT '0', pointsratio INT(12) NOT NULL DEFAULT '0',finishedmaps INT(12) NOT NULL DEFAULT '0', multiplier INT(12) NOT NULL DEFAULT '0', finishedmapstp INT(12) NOT NULL DEFAULT '0', finishedmapspro INT(12) NOT NULL DEFAULT '0', PRIMARY KEY(steamid));";
new String:sql_insertPlayerRank[] 				= "INSERT INTO playerrank (steamid, name, country) VALUES('%s', '%s', '%s');";
new String:sql_updatePlayerRankPoints[]			= "UPDATE playerrank SET name ='%s', points ='%i', finishedmapstp ='%i', finishedmapspro='%i',winratio = '%i',pointsratio = '%i' where steamid='%s'";
new String:sql_updatePlayerRankPoints2[]		= "UPDATE playerrank SET name ='%s', points ='%i', finishedmapstp ='%i', finishedmapspro='%i',winratio = '%i',pointsratio = '%i', country ='%s' where steamid='%s'";
new String:sql_updatePlayerRank[]				= "UPDATE playerrank SET finishedmaps ='%i', finishedmapstp ='%i', finishedmapspro='%i', multiplier ='%i'  where steamid='%s'";
new String:sql_selectPlayerRankAll[] 			= "SELECT name, steamid FROM playerrank where name like '%c%s%c' order by lastseen DESC";
new String:sql_selectPlayerRankAll2[] 			= "SELECT name, steamid FROM playerrank where name = '%s' order by lastseen DESC";
new String:sql_selectPlayerName[] 				= "SELECT name FROM playerrank where steamid = '%s'";
new String:sql_UpdateLastSeenMySQL[]			= "UPDATE playerrank SET lastseen = NOW() where steamid = '%s'";
new String:sql_UpdateLastSeenSQLite[]			= "UPDATE playerrank SET lastseen = date('now') where steamid = '%s'";
new String:sql_selectTopPlayers[]				= "SELECT name, points, finishedmapspro, finishedmapstp, steamid FROM playerrank ORDER BY points DESC LIMIT 100";
new String:sql_selectTopChallengers[]			= "SELECT name, winratio, pointsratio, steamid FROM playerrank ORDER BY pointsratio DESC LIMIT 5";
new String:sql_selectTopChallengers2[]			= "SELECT name, winratio, pointsratio, steamid FROM playerrank ORDER BY winratio DESC LIMIT 5";
new String:sql_selectRankedPlayer[]				= "SELECT steamid, name, points, finishedmapstp, finishedmapspro, multiplier, country, lastseen from playerrank where steamid='%s'";
new String:sql_selectRankedPlayersRank[]		= "SELECT name FROM playerrank WHERE points >= (SELECT points FROM playerrank WHERE steamid = '%s') ORDER BY points";
new String:sql_selectRankedPlayers[]			= "SELECT steamid, name from playerrank where points > 0 ORDER BY points DESC";
new String:sql_CountRankedPlayers[] 			= "SELECT COUNT(steamid) FROM playerrank";
new String:sql_CountRankedPlayers2[] 			= "SELECT COUNT(steamid) FROM playerrank where points > 0";

//TABLE PLAYERTIMES
new String:sql_createPlayertimes[] 				= "CREATE TABLE IF NOT EXISTS playertimes (steamid VARCHAR(32) NOT NULL, mapname VARCHAR(32) NOT NULL, name VARCHAR(32) NOT NULL, teleports INT(12) NOT NULL DEFAULT '-1', runtime FLOAT NOT NULL DEFAULT '-1.0', runtimepro FLOAT NOT NULL DEFAULT '-1.0',teleports_pro INT(12) NOT NULL DEFAULT '0', PRIMARY KEY(steamid,mapname));";
new String:sql_insertPlayer[] 					= "INSERT INTO playertimes (steamid, mapname, name) VALUES('%s', '%s', '%s');";
new String:sql_insertPlayerTp[] 					= "INSERT INTO playertimes (steamid, mapname, name,runtime, teleports) VALUES('%s', '%s', '%s', '%f', '%i');";
new String:sql_insertPlayerPro[] 				= "INSERT INTO playertimes (steamid, mapname, name,runtimepro) VALUES('%s', '%s', '%s', '%f');";
new String:sql_updateRecord[] 					= "UPDATE playertimes SET name = '%s', teleports = '%i', runtime = '%f' WHERE steamid = '%s' AND mapname = '%s';"; 
new String:sql_updateRecordPro[]					= "UPDATE playertimes SET name = '%s', runtimepro = '%f' WHERE steamid = '%s' AND mapname = '%s';"; 
new String:sql_CountFinishedMapsTP[] 			= "SELECT mapname FROM playertimes where steamid='%s' AND runtime > -1.0";
new String:sql_CountFinishedMapsPro[] 			= "SELECT mapname FROM playertimes where steamid='%s' AND runtimepro > -1.0";
new String:sql_selectPlayer[] 					= "SELECT steamid FROM playertimes WHERE steamid = '%s' AND mapname = '%s';";
new String:sql_selectRecordTp[] 					= "SELECT mapname, steamid, name, runtime, teleports  FROM playertimes WHERE steamid = '%s' AND mapname = '%s' AND runtime > -1.0;";
new String:sql_selectProRecord[] 				= "SELECT mapname, steamid, name, runtimepro FROM playertimes WHERE steamid = '%s' AND mapname = '%s' AND runtimepro > -1.0;";
new String:sql_selectRecord[] 					= "SELECT steamid, runtime, runtimepro FROM playertimes WHERE steamid = '%s' AND mapname = '%s' AND (runtime  > 0.0 OR runtimepro  > 0.0)";
new String:sql_selectMapRecordCP[] 				= "SELECT db2.runtime, db1.name, db2.teleports, db1.steamid, db2.steamid FROM playertimes as db2 INNER JOIN playerrank as db1 on db1.steamid = db2.steamid WHERE db2.mapname = '%s' AND db2.runtime  > -1.0 ORDER BY db2.runtime ASC LIMIT 1"; 
new String:sql_selectMapRecordPro[] 			= "SELECT db2.runtimepro, db1.name, db2.teleports, db1.steamid, db2.steamid FROM playertimes as db2 INNER JOIN playerrank as db1 on db1.steamid = db2.steamid WHERE db2.mapname = '%s' AND db2.runtimepro  > -1.0 ORDER BY db2.runtimepro ASC LIMIT 1"; 
new String:sql_selectPersonalRecords[] 			= "SELECT db2.mapname, db2.steamid, db1.name, db2.runtime, db2.runtimepro, db2.teleports, db1.steamid  FROM playertimes as db2 INNER JOIN playerrank as db1 on db1.steamid = db2.steamid WHERE db2.steamid = '%s' AND db2.mapname = '%s' AND (db2.runtime > 0.0 OR db2.runtimepro > 0.0)"; 
new String:sql_selectPersonalAllRecords[] 		= "SELECT db1.name, db2.steamid, db2.mapname, db2.runtime as overall, db2.teleports AS tp, db1.steamid FROM playertimes as db2 INNER JOIN playerrank as db1 on db2.steamid = db1.steamid WHERE db2.steamid = '%s' AND db2.runtime > -1.0 AND db2.teleports >= 0  UNION SELECT db1.name, db2.steamid, db2.mapname, db2.runtimepro as overall, db2.teleports_pro AS tp, db1.steamid FROM playertimes as db2 INNER JOIN playerrank as db1 on db2.steamid = db1.steamid WHERE db2.steamid = '%s' AND db2.runtimepro > -1.0 ORDER BY mapname ASC;";
new String:sql_selectTPClimbers[] 				= "SELECT db1.name, db2.runtime, db2.teleports, db2.steamid, db1.steamid FROM playertimes as db2 INNER JOIN playerrank as db1 on db2.steamid = db1.steamid WHERE db2.mapname = '%s' AND db2.runtime > -1.0 AND db2.teleports >= 0 ORDER BY db2.runtime ASC LIMIT 20";
new String:sql_selectProClimbers[] 				= "SELECT db1.name, db2.runtimepro, db2.steamid, db1.steamid FROM playertimes as db2 INNER JOIN playerrank as db1 on db2.steamid = db1.steamid WHERE db2.mapname = '%s' AND db2.runtimepro > -1.0 ORDER BY db2.runtimepro ASC LIMIT 20";
new String:sql_selectTopClimbers2[] 			= "SELECT db2.steamid, db1.name, db2.runtime as overall, db2.teleports AS tp, db1.steamid, db2.mapname FROM playertimes as db2 INNER JOIN playerrank as db1 on db2.steamid = db1.steamid WHERE db2.mapname LIKE '%c%s%c' AND db2.runtime > -1.0 AND db2.teleports >= 0 UNION SELECT db2.steamid, db1.name, db2.runtimepro as overall, db2.teleports_pro AS tp, db1.steamid, db2.mapname FROM playertimes as db2 INNER JOIN playerrank as db1 on db2.steamid = db1.steamid WHERE db2.mapname LIKE '%c%s%c' AND db2.runtimepro > -1.0 ORDER BY overall ASC LIMIT 100;";
new String:sql_selectTopClimbers[] 				= "SELECT db2.steamid, db1.name, db2.runtime as overall, db2.teleports AS tp, db1.steamid, db2.mapname FROM playertimes as db2 INNER JOIN playerrank as db1 on db2.steamid = db1.steamid WHERE db2.mapname = '%s' AND db2.runtime > -1.0 AND db2.teleports >= 0 UNION SELECT db2.steamid, db1.name, db2.runtimepro as overall, db2.teleports_pro AS tp, db1.steamid, db2.mapname FROM playertimes as db2 INNER JOIN playerrank as db1 on db2.steamid = db1.steamid WHERE db2.mapname = '%s' AND db2.runtimepro > -1.0 ORDER BY overall ASC LIMIT 100;";
new String:sql_selectPlayerCount[] 				= "SELECT name FROM playertimes WHERE mapname = '%s' AND runtime  > -1.0;";
new String:sql_selectPlayerProCount[] 			= "SELECT name FROM playertimes WHERE mapname = '%s' AND runtimepro  > -1.0;";
new String:sql_selectPlayerRankTime[] 			= "SELECT name,teleports,mapname FROM playertimes WHERE runtime <= (SELECT runtime FROM playertimes WHERE steamid = '%s' AND mapname = '%s' AND runtime > -1.0) AND mapname = '%s' AND runtime  > -1.0 ORDER BY runtime;";
new String:sql_selectPlayerRankProTime[] 		= "SELECT name,teleports_pro,mapname FROM playertimes WHERE runtimepro <= (SELECT runtimepro FROM playertimes WHERE steamid = '%s' AND mapname = '%s' AND runtimepro > -1.0) AND mapname = '%s' AND runtimepro > -1.0 ORDER BY runtimepro;";
new String:sql_selectProRecordHolders[] 		= "SELECT y.steamid, COUNT(*) AS rekorde FROM (SELECT s.steamid FROM playertimes s INNER JOIN (SELECT mapname, MIN(runtimepro) AS runtimepro FROM playertimes where runtimepro > -1.0 GROUP BY mapname) x ON s.mapname = x.mapname AND s.runtimepro = x.runtimepro) y GROUP BY y.steamid ORDER BY rekorde DESC , y.steamid LIMIT 5;";
new String:sql_selectTpRecordHolders[] 			= "SELECT y.steamid, COUNT(*) AS rekorde FROM (SELECT s.steamid FROM playertimes s INNER JOIN (SELECT mapname, MIN(runtime) AS runtime FROM playertimes where runtime > -1.0 GROUP BY mapname) x ON s.mapname = x.mapname AND s.runtime = x.runtime) y GROUP BY y.steamid ORDER BY rekorde DESC , y.steamid LIMIT 5;";
new String:sql_selectTpRecordCount[] 			= "SELECT y.steamid, COUNT(*) AS rekorde FROM (SELECT s.steamid FROM playertimes s INNER JOIN (SELECT mapname, MIN(runtime) AS runtime FROM playertimes where runtime > -1.0  GROUP BY mapname) x ON s.mapname = x.mapname AND s.runtime = x.runtime) y where y.steamid = '%s' GROUP BY y.steamid ORDER BY rekorde DESC , y.steamid;";
new String:sql_selectProRecordCount[] 			= "SELECT y.steamid, COUNT(*) AS rekorde FROM (SELECT s.steamid FROM playertimes s INNER JOIN (SELECT mapname, MIN(runtimepro) AS runtimepro FROM playertimes where runtimepro > -1.0  GROUP BY mapname) x ON s.mapname = x.mapname AND s.runtimepro = x.runtimepro) y where y.steamid = '%s' GROUP BY y.steamid ORDER BY rekorde DESC , y.steamid;";

//TABLE PLAYERTMP
new String:sql_createPlayertmp[] 				= "CREATE TABLE IF NOT EXISTS playertmp (steamid VARCHAR(32) NOT NULL, mapname VARCHAR(32) NOT NULL, cords1 FLOAT NOT NULL DEFAULT '-1.0', cords2 FLOAT NOT NULL DEFAULT '-1.0', cords3 FLOAT NOT NULL DEFAULT '-1.0', angle1 FLOAT NOT NULL DEFAULT '-1.0',angle2 FLOAT NOT NULL DEFAULT '-1.0',angle3 FLOAT NOT NULL DEFAULT '-1.0', EncTickrate INT(12) NOT NULL DEFAULT '-1.0', teleports INT(12) NOT NULL DEFAULT '-1.0', checkpoints INT(12) NOT NULL DEFAULT '0', runtimeTmp FLOAT NOT NULL DEFAULT '-1.0', PRIMARY KEY(steamid,mapname));";
new String:sql_insertPlayerTmp[]  				= "INSERT INTO playertmp (cords1, cords2, cords3, angle1,angle2,angle3, teleports,checkpoints,runtimeTmp,steamid,mapname,EncTickrate) VALUES ('%f','%f','%f','%f','%f','%f','%i','%i','%f','%s', '%s', '%i');";
new String:sql_updatePlayerTmp[] 				= "UPDATE playertmp SET cords1 = '%f', cords2 = '%f', cords3 = '%f', angle1 = '%f', angle2 = '%f', angle3 = '%f', teleports = '%i', checkpoints = '%i', runtimeTmp = '%f', mapname ='%s', EncTickrate='%i' where steamid = '%s';";
new String:sql_deletePlayerTmp[] 				= "DELETE FROM playertmp where steamid = '%s';";
new String:sql_selectPlayerTmp[] 				= "SELECT cords1,cords2,cords3, angle1, angle2, angle3, teleports, checkpoints, runtimeTmp, EncTickrate FROM playertmp WHERE steamid = '%s' AND mapname = '%s';";

//TABLE JUMMPSTATS
new String:sql_createPlayerjumpstats[] 			= "CREATE TABLE IF NOT EXISTS playerjumpstats3 (steamid VARCHAR(32) NOT NULL, name VARCHAR(32) NOT NULL, multibhoprecord FLOAT NOT NULL DEFAULT '-1.0',  multibhoppre FLOAT NOT NULL DEFAULT '-1.0', multibhopmax FLOAT NOT NULL DEFAULT '-1.0', multibhopstrafes INT(12) NOT NULL DEFAULT '-1',multibhopcount INT(12) NOT NULL DEFAULT '-1',multibhopsync INT(12) NOT NULL DEFAULT '-1', multibhopheight FLOAT NOT NULL DEFAULT '-1.0', bhoprecord FLOAT NOT NULL DEFAULT '-1.0',  bhoppre FLOAT NOT NULL DEFAULT '-1.0', bhopmax FLOAT NOT NULL DEFAULT '-1.0', bhopstrafes INT(12) NOT NULL DEFAULT '-1',bhopsync INT(12) NOT NULL DEFAULT '-1', bhopheight FLOAT NOT NULL DEFAULT '-1.0', ljrecord FLOAT NOT NULL DEFAULT '-1.0', ljpre FLOAT NOT NULL DEFAULT '-1.0', ljmax FLOAT NOT NULL DEFAULT '-1.0', ljstrafes INT(12) NOT NULL DEFAULT '-1',ljsync INT(12) NOT NULL DEFAULT '-1', ljheight FLOAT NOT NULL DEFAULT '-1.0', ljblockdist INT(12) NOT NULL DEFAULT '-1',ljblockrecord FLOAT NOT NULL DEFAULT '-1.0', ljblockpre FLOAT NOT NULL DEFAULT '-1.0',  ljblockmax FLOAT NOT NULL DEFAULT '-1.0', ljblockstrafes INT(12) NOT NULL DEFAULT '-1',ljblocksync INT(12) NOT NULL DEFAULT '-1', ljblockheight FLOAT NOT NULL DEFAULT '-1.0', dropbhoprecord FLOAT NOT NULL DEFAULT '-1.0',  dropbhoppre FLOAT NOT NULL DEFAULT '-1.0',  dropbhopmax FLOAT NOT NULL DEFAULT '-1.0', dropbhopstrafes INT(12) NOT NULL DEFAULT '-1',dropbhopsync INT(12) NOT NULL DEFAULT '-1', dropbhopheight FLOAT NOT NULL DEFAULT '-1.0', wjrecord FLOAT NOT NULL DEFAULT '-1.0', wjpre FLOAT NOT NULL DEFAULT '-1.0',  wjmax FLOAT NOT NULL DEFAULT '-1.0', wjstrafes INT(12) NOT NULL DEFAULT '-1',wjsync INT(12) NOT NULL DEFAULT '-1', wjheight FLOAT NOT NULL DEFAULT '-1.0', ladderjumprecord FLOAT NOT NULL DEFAULT '-1.0',  ladderjumppre FLOAT NOT NULL DEFAULT '-1.0',  ladderjumpmax FLOAT NOT NULL DEFAULT '-1.0', ladderjumpstrafes INT(12) NOT NULL DEFAULT '-1', ladderjumpsync INT(12) NOT NULL DEFAULT '-1', ladderjumpheight FLOAT NOT NULL DEFAULT '-1.0',   PRIMARY KEY(steamid));";
new String:sql_insertPlayerJumpBhop[] 			= "INSERT INTO playerjumpstats3 (steamid, name, bhoprecord, bhoppre, bhopmax, bhopstrafes, bhopsync, bhopheight) VALUES('%s', '%s', '%f', '%f', '%f', '%i', '%i', '%f');";
new String:sql_insertPlayerJumpLj[] 			= "INSERT INTO playerjumpstats3 (steamid, name, ljrecord, ljpre, ljmax, ljstrafes, ljsync, ljheight) VALUES('%s', '%s', '%f', '%f', '%f', '%i', '%i', '%f');";
new String:sql_insertPlayerJumpLjBlock[] 		= "INSERT INTO playerjumpstats3 (steamid, name, ljblockdist, ljblockrecord, ljblockpre, ljblockmax, ljblockstrafes, ljblocksync, ljblockheight) VALUES('%s', '%s', '%i', '%f', '%f', '%f', '%i', '%i', '%f');";
new String:sql_insertPlayerJumpMultiBhop[] 	= "INSERT INTO playerjumpstats3 (steamid, name, multibhoprecord, multibhoppre, multibhopmax, multibhopstrafes, multibhopcount, multibhopsync, multibhopheight) VALUES('%s', '%s', '%f', '%f', '%f', '%i', '%i', '%i', '%f');";
new String:sql_insertPlayerJumpDropBhop[] 		= "INSERT INTO playerjumpstats3 (steamid, name, dropbhoprecord, dropbhoppre, dropbhopmax, dropbhopstrafes, dropbhopsync, dropbhopheight) VALUES('%s', '%s', '%f', '%f', '%f', '%i', '%i', '%f');";
new String:sql_insertPlayerJumpWJ[] 			= "INSERT INTO playerjumpstats3 (steamid, name, wjrecord, wjpre, wjmax, wjstrafes, wjsync, wjheight) VALUES('%s', '%s', '%f', '%f', '%f', '%i', '%i', '%f');";

new String:sql_updateLjBlock[] 					= "UPDATE playerjumpstats3 SET name='%s', ljblockdist ='%i', ljblockrecord ='%f', ljblockpre ='%f', ljblockmax ='%f', ljblockstrafes='%i', ljblocksync='%i', ljblockheight='%f' WHERE steamid = '%s';";
new String:sql_updateLj[] 						= "UPDATE playerjumpstats3 SET name='%s', ljrecord ='%f', ljpre ='%f', ljmax ='%f', ljstrafes='%i', ljsync='%i', ljheight='%f' WHERE steamid = '%s';";
new String:sql_updateBhop[] 						= "UPDATE playerjumpstats3 SET name='%s', bhoprecord ='%f', bhoppre ='%f', bhopmax ='%f', bhopstrafes='%i', bhopsync='%i', bhopheight='%f' WHERE steamid = '%s';";
new String:sql_updateMultiBhop[] 				= "UPDATE playerjumpstats3 SET name='%s', multibhoprecord ='%f', multibhoppre ='%f', multibhopmax ='%f', multibhopstrafes='%i', multibhopcount='%i', multibhopsync='%i', multibhopheight='%f' WHERE steamid = '%s';";
new String:sql_updateDropBhop[] 					= "UPDATE playerjumpstats3 SET name='%s', dropbhoprecord ='%f', dropbhoppre ='%f', dropbhopmax ='%f', dropbhopstrafes='%i', dropbhopsync='%i', dropbhopheight='%f' WHERE steamid = '%s';";
new String:sql_updateWJ[] 						= "UPDATE playerjumpstats3 SET name='%s', wjrecord ='%f', wjpre ='%f', wjmax ='%f', wjstrafes='%i', wjsync='%i', wjheight='%f' WHERE steamid = '%s';";

new String:sql_selectPlayerJumpTopLJBlock[] 	= "SELECT db1.name, db2.ljblockdist, db2.ljblockrecord,db2.ljblockstrafes, db2.steamid, db1.steamid FROM playerjumpstats3 as db2 INNER JOIN playerrank as db1 on db2.steamid=db1.steamid WHERE ljblockdist > -1 ORDER BY ljblockdist DESC, ljblockrecord DESC LIMIT 20";
new String:sql_selectPlayerJumpTopLJ[] 			= "SELECT db1.name, db2.ljrecord,db2.ljstrafes, db2.steamid, db1.steamid FROM playerjumpstats3 as db2 INNER JOIN playerrank as db1 on db2.steamid=db1.steamid WHERE ljrecord > -1.0 ORDER BY ljrecord DESC LIMIT 20";
new String:sql_selectPlayerJumpTopBhop[] 		= "SELECT db1.name, db2.bhoprecord,db2.bhopstrafes, db2.steamid, db1.steamid FROM playerjumpstats3 as db2 INNER JOIN playerrank as db1 on db2.steamid=db1.steamid WHERE bhoprecord > -1.0 ORDER BY bhoprecord DESC LIMIT 20";
new String:sql_selectPlayerJumpTopMultiBhop[] 	= "SELECT db1.name, db2.multibhoprecord,db2.multibhopstrafes, db2.steamid, db1.steamid FROM playerjumpstats3 as db2 INNER JOIN playerrank as db1 on db2.steamid=db1.steamid WHERE multibhoprecord > -1.0 ORDER BY multibhoprecord DESC LIMIT 20";
new String:sql_selectPlayerJumpTopDropBhop[] 	= "SELECT db1.name, db2.dropbhoprecord,db2.dropbhopstrafes, db2.steamid, db1.steamid FROM playerjumpstats3 as db2 INNER JOIN playerrank as db1 on db2.steamid = db1.steamid WHERE db2.dropbhoprecord > -1.0 ORDER BY db2.dropbhoprecord DESC LIMIT 20";
new String:sql_selectPlayerJumpTopWJ[] 			= "SELECT db1.name, db2.wjrecord, db2.wjstrafes, db2.steamid, db1.steamid FROM playerjumpstats3 as db2 INNER JOIN playerrank as db1 on db2.steamid = db1.steamid WHERE db2.wjrecord > -1.0 ORDER BY db2.wjrecord DESC LIMIT 20";

new String:sql_selectPlayerJumpLJBlock[] 		= "SELECT steamid, name, ljblockdist, ljblockrecord FROM playerjumpstats3 WHERE steamid = '%s';";
new String:sql_selectPlayerJumpLJ[] 			= "SELECT steamid, name, ljrecord FROM playerjumpstats3 WHERE steamid = '%s';";
new String:sql_selectPlayerJumpBhop[] 			= "SELECT steamid, name, bhoprecord FROM playerjumpstats3 WHERE steamid = '%s';";
new String:sql_selectPlayerJumpMultiBhop[] 	= "SELECT steamid, name, multibhoprecord FROM playerjumpstats3 WHERE steamid = '%s';";
new String:sql_selectPlayerJumpWJ[] 			= "SELECT steamid, name, wjrecord FROM playerjumpstats3 WHERE steamid = '%s';";
new String:sql_selectPlayerJumpDropBhop[] 		= "SELECT steamid, name, dropbhoprecord FROM playerjumpstats3 WHERE steamid = '%s';";

new String:sql_selectJumpStats1[] 				= "SELECT db2.steamid, db1.name, db2.ladderjumprecord, db2.ladderjumppre, db2.ladderjumpmax, db2.ladderjumpstrafes,db2.ladderjumpsync,db2.ladderjumpheight FROM playerjumpstats3 as db2 INNER JOIN playerrank as db1 on db2.steamid = db1.steamid WHERE db2.ladderjumprecord > -1.0 AND db2.steamid = '%s';";
new String:sql_selectJumpStats2[] 				= "SELECT db2.steamid, db1.name, db2.bhoprecord,db2.bhoppre,db2.bhopmax,db2.bhopstrafes,db2.bhopsync, db2.ljrecord, db2.ljpre, db2.ljmax, db2.ljstrafes,db2.ljsync, db2.multibhoprecord,db2.multibhoppre,db2.multibhopmax, db2.multibhopstrafes,db2.multibhopcount,db2.multibhopsync, db2.wjrecord, db2.wjpre, db2.wjmax, db2.wjstrafes, db2.wjsync, db2.dropbhoprecord, db2.dropbhoppre, db2.dropbhopmax, db2.dropbhopstrafes, db2.dropbhopsync, db2.ljheight, db2.bhopheight, db2.multibhopheight, db2.dropbhopheight, db2.wjheight,db2.ljblockdist,db2.ljblockrecord, db2.ljblockpre, db2.ljblockmax, db2.ljblockstrafes, db2.ljblocksync, db2.ljblockheight,db2.cjrecord, db2.cjpre, db2.cjmax, db2.cjstrafes, db2.cjsync, db2.cjheight FROM playerjumpstats3 as db2 INNER JOIN playerrank as db1 on db2.steamid = db1.steamid WHERE (db2.wjrecord > -1.0 OR db2.dropbhoprecord > -1.0 OR db2.ljrecord > -1.0 OR db2.bhoprecord > -1.0 OR db2.multibhoprecord > -1.0 OR db2.cjrecord > -1.0) AND db2.steamid = '%s';";
new String:sql_selectPlayerRankMultiBhop[]		= "SELECT name FROM playerjumpstats3 WHERE multibhoprecord >= (SELECT multibhoprecord FROM playerjumpstats3 WHERE steamid = '%s' AND multibhoprecord > -1.0) AND multibhoprecord  > -1.0 ORDER BY multibhoprecord;";
new String:sql_selectPlayerRankLj[] 			= "SELECT name FROM playerjumpstats3 WHERE ljrecord >= (SELECT ljrecord FROM playerjumpstats3 WHERE steamid = '%s' AND ljrecord > -1.0) AND ljrecord  > -1.0 ORDER BY ljrecord;";
new String:sql_selectPlayerRankLjBlock[] 		= "SELECT name FROM playerjumpstats3 WHERE ljblockdist >= (SELECT ljblockdist FROM playerjumpstats3 WHERE steamid = '%s' AND ljblockdist > -1.0) AND ljblockdist  > -1.0 ORDER BY ljblockdist DESC, ljblockrecord DESC;";
new String:sql_selectPlayerRankBhop[] 			= "SELECT name FROM playerjumpstats3 WHERE bhoprecord >= (SELECT bhoprecord FROM playerjumpstats3 WHERE steamid = '%s' AND bhoprecord > -1.0) AND bhoprecord  > -1.0 ORDER BY bhoprecord;";
new String:sql_selectPlayerRankWJ[] 			= "SELECT name FROM playerjumpstats3 WHERE wjrecord >= (SELECT wjrecord FROM playerjumpstats3 WHERE steamid = '%s' AND wjrecord > -1.0) AND wjrecord  > -1.0 ORDER BY wjrecord;";
new String:sql_selectPlayerRankDropBhop[] 		= "SELECT name FROM playerjumpstats3 WHERE dropbhoprecord >= (SELECT dropbhoprecord FROM playerjumpstats3 WHERE steamid = '%s' AND dropbhoprecord > -1.0) AND dropbhoprecord  > -1.0 ORDER BY dropbhoprecord;";

//new ladderjump
new String:sql_insertPlayerJumpLadderJump[] 			= "INSERT INTO playerjumpstats3 (steamid, name, ladderjumprecord, ladderjumppre, ladderjumpmax, ladderjumpstrafes, ladderjumpsync, ladderjumpheight) VALUES('%s', '%s', '%f', '%f', '%f', '%i', '%i', '%f');";
new String:sql_updateLadderJump[] 						= "UPDATE playerjumpstats3 SET name='%s', ladderjumprecord ='%f', ladderjumppre ='%f', ladderjumpmax ='%f', ladderjumpstrafes='%i', ladderjumpsync='%i', ladderjumpheight='%f' WHERE steamid = '%s';";
new String:sql_selectPlayerJumpTopLadderJump[] 			= "SELECT db1.name, db2.ladderjumprecord,db2.ladderjumpstrafes, db2.steamid, db1.steamid FROM playerjumpstats3 as db2 INNER JOIN playerrank as db1 on db2.steamid=db1.steamid WHERE ladderjumprecord > -1.0 ORDER BY ladderjumprecord DESC LIMIT 20";
new String:sql_selectPlayerJumpLadderJump[] 			= "SELECT steamid, name, ladderjumprecord FROM playerjumpstats3 WHERE steamid = '%s';";
new String:sql_selectPlayerRankLadderJump[] 			= "SELECT name FROM playerjumpstats3 WHERE ladderjumprecord >= (SELECT ladderjumprecord FROM playerjumpstats3 WHERE steamid = '%s' AND ladderjumprecord > -1.0) AND ladderjumprecord  > -1.0 ORDER BY ladderjumprecord;";

//new countjump
new String:sql_insertPlayerJumpCountJump[] 			= "INSERT INTO playerjumpstats3 (steamid, name, cjrecord, cjpre, cjmax, cjstrafes, cjsync, cjheight) VALUES('%s', '%s', '%f', '%f', '%f', '%i', '%i', '%f');";
new String:sql_updateCountJump[] 						= "UPDATE playerjumpstats3 SET name='%s', cjrecord ='%f', cjpre ='%f', cjmax ='%f', cjstrafes='%i', cjsync='%i', cjheight='%f' WHERE steamid = '%s';";
new String:sql_selectPlayerJumpTopCountJump[] 			= "SELECT db1.name, db2.cjrecord,db2.cjstrafes, db2.steamid, db1.steamid FROM playerjumpstats3 as db2 INNER JOIN playerrank as db1 on db2.steamid=db1.steamid WHERE cjrecord > -1.0 ORDER BY cjrecord DESC LIMIT 20";
new String:sql_selectPlayerJumpCountJump[] 			= "SELECT steamid, name, cjrecord FROM playerjumpstats3 WHERE steamid = '%s';";
new String:sql_selectPlayerRankCountJump[] 			= "SELECT name FROM playerjumpstats3 WHERE cjrecord >= (SELECT cjrecord FROM playerjumpstats3 WHERE steamid = '%s' AND cjrecord > -1.0) AND cjrecord  > -1.0 ORDER BY cjrecord;";

// TABLE MAP BUTTONS
new String:sql_createMapButtons[] 				= "CREATE TABLE IF NOT EXISTS MapButtons (mapname VARCHAR(32) NOT NULL, cords1Start FLOAT NOT NULL DEFAULT '-1.0', cords2Start FLOAT NOT NULL DEFAULT '-1.0', cords3Start FLOAT NOT NULL DEFAULT '-1.0', cords1End FLOAT NOT NULL DEFAULT '-1.0', cords2End FLOAT NOT NULL DEFAULT '-1.0', cords3End FLOAT NOT NULL DEFAULT '-1.0', ang_start FLOAT NOT NULL DEFAULT '-1.0', ang_end FLOAT NOT NULL DEFAULT '-1.0', PRIMARY KEY(mapname));";
new String:sql_deleteMapButtons[] 				= "DELETE FROM MapButtons where mapname= '%s';";
new String:sql_insertMapButtons[] 				= "INSERT INTO MapButtons (mapname, cords1Start, cords2Start,cords3Start,cords1End,cords2End,cords3End,ang_start,ang_end) VALUES('%s', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f');";
new String:sql_selectMapButtons[] 				= "SELECT cords1Start,cords2Start,cords3Start,cords1End,cords2End,cords3End,ang_start,ang_end FROM MapButtons WHERE mapname = '%s';";
new String:sql_updateMapButtonsStart[] 			= "UPDATE MapButtons SET cords1Start ='%f', cords2Start ='%f', cords3Start ='%f', ang_start = '%f' WHERE mapname = '%s';";
new String:sql_updateMapButtonsEnd[]			= "UPDATE MapButtons SET cords1End ='%f', cords2End ='%f', cords3End ='%f', ang_end = '%f' WHERE mapname = '%s';";

// ADMIN 
new String:sqlite_dropMap[] 					= "DROP TABLE MapButtons; VACCUM";
new String:sql_dropMap[] 						= "DROP TABLE MapButtons;";
new String:sqlite_dropChallenges[] 					= "DROP TABLE challenges; VACCUM";
new String:sql_dropChallenges[] 						= "DROP TABLE challenges;";
new String:sqlite_dropPlayer[] 				= "DROP TABLE playertimes; VACCUM";
new String:sql_dropPlayer[] 					= "DROP TABLE playertimes;";
new String:sql_dropPlayerRank[] 				= "DROP TABLE playerrank;";
new String:sqlite_dropPlayerRank[] 			= "DROP TABLE playerrank; VACCUM";
new String:sqlite_dropPlayerJump[] 			= "DROP TABLE playerjumpstats3; VACCUM";
new String:sql_dropPlayerJump[] 				= "DROP TABLE playerjumpstats3;";
new String:sql_resetRecords[] 				= "DELETE FROM playertimes WHERE steamid = '%s'";
new String:sql_resetRecords2[] 				= "DELETE FROM playertimes WHERE steamid = '%s' AND mapname LIKE '%s';";
new String:sql_resetRecordTp[] 				= "UPDATE playertimes SET runtime = '-1.0' WHERE steamid = '%s' AND mapname LIKE '%s';";
new String:sql_resetRecordPro[] 				= "UPDATE playertimes SET runtimepro = '-1.0' WHERE steamid = '%s' AND mapname LIKE '%s';";
new String:sql_resetMapRecords[] 			= "DELETE FROM playertimes WHERE mapname = '%s'";
new String:sql_resetBhopRecord[] 			= "UPDATE playerjumpstats3 SET bhoprecord = '-1.0' WHERE steamid = '%s';";   
new String:sql_resetDropBhopRecord[] 		= "UPDATE playerjumpstats3 SET dropbhoprecord = '-1.0' WHERE steamid = '%s';";   
new String:sql_resetWJRecord[] 				= "UPDATE playerjumpstats3 SET wjrecord = '-1.0' WHERE steamid = '%s';";   
new String:sql_resetLjRecord[] 				= "UPDATE playerjumpstats3 SET ljrecord = '-1.0' WHERE steamid = '%s';";  
new String:sql_resetCjRecord[] 				= "UPDATE playerjumpstats3 SET cjrecord = '-1.0' WHERE steamid = '%s';";  
new String:sql_resetLadderJumpRecord[] 			= "UPDATE playerjumpstats3 SET ladderjumprecord = '-1.0' WHERE steamid = '%s';";  
new String:sql_resetLjBlockRecord[] 			= "UPDATE playerjumpstats3 SET ljblockdist = '-1' WHERE steamid = '%s';";
new String:sql_resetMultiBhopRecord[] 		= "UPDATE playerjumpstats3 SET multibhoprecord = '-1.0' WHERE steamid = '%s';";  
new String:sql_resetJumpStats[] 				= "UPDATE playerjumpstats3 SET multibhoprecord = '-1.0', ladderjumprecord = '-1.0', cjrecord = '-1.0', ljrecord = '-1.0', wjrecord = '-1.0', dropbhoprecord = '-1.0', bhoprecord = '-1.0', ljblockdist = '-1' WHERE steamid = '%s';";  
new String:sql_resetCheat1[] 					= "DELETE FROM playertimes WHERE steamid = '%s'";
new String:sql_resetCheat2[] 					= "DELETE FROM playerrank WHERE steamid = '%s'";


public db_DeleteCheater(String:steamid[32])
{
	decl String:szQuery[255];
	decl String:szsteamid[32*2+1];
	SQL_QuoteString(g_hDb, steamid, szsteamid, 32*2+1);      	
	Format(szQuery, 255, sql_resetCheat1, szsteamid);       
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery,DBPrio_Low);
	Format(szQuery, 255, sql_resetCheat2, szsteamid);       
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery,DBPrio_Low);	   
	Format(szQuery, 255, sql_resetJumpStats, szsteamid);       
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery,DBPrio_Low);	
}

public db_viewPlayerRank2(client, String:szSteamId[32])
{
	decl String:szQuery[512];  
	Format(g_pr_szrank[client], 512, "");	
	Format(szQuery, 512, sql_selectRankedPlayer, szSteamId);  
	SQL_TQuery(g_hDb, SQL_ViewRankedPlayer2Callback, szQuery, client,DBPrio_Low);
}

public SQL_ViewRankedPlayer2Callback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{	
		if (!IsValidClient(client))
			return;	
		
		decl String:szQuery[512];
		decl String:szName[MAX_NAME_LENGTH];
		decl String:szSteamIdTarget[32];	
		SQL_FetchString(hndl, 0, szSteamIdTarget, 32);
		SQL_FetchString(hndl, 1, szName, MAX_NAME_LENGTH);
				
		new Handle:pack = CreateDataPack();
		WritePackCell(pack, client);
		WritePackString(pack, szName);
		Format(szQuery, 512, sql_selectChallengesCompare, g_szSteamID[client],szSteamIdTarget,szSteamIdTarget,g_szSteamID[client]);
		SQL_TQuery(g_hDb, sql_selectChallengesCompareCallback, szQuery, pack,DBPrio_Low);
	}
}

public sql_selectChallengesCompareCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new winratio=0;
	new challenges= SQL_GetRowCount(hndl);
	new pointratio=0;
	decl String:szWinRatio[32];
	decl String:szPointsRatio[32];
	decl String:szName[MAX_NAME_LENGTH]	;
	new Handle:pack = data;
	ResetPack(pack);
	new client = ReadPackCell(pack);      
	if (!IsValidClient(client))
		return;
	ReadPackString(pack, szName, MAX_NAME_LENGTH);
	CloseHandle(pack);	
	if(SQL_HasResultSet(hndl))
	{
		while (SQL_FetchRow(hndl))
		{
			decl String:szID[32];
			new bet;
			SQL_FetchString(hndl, 0, szID, 32);
			bet = SQL_FetchInt(hndl,2);
			if (StrEqual(szID, g_szSteamID[client]))
			{
				winratio++;
				pointratio+= bet;
			}
			else
			{
				winratio--;
				pointratio-= bet;	
			}
		}
		if (winratio>0)
			Format(szWinRatio, 32, "+%i",winratio);
		else
			Format(szWinRatio, 32, "%i",winratio);
			
		if (pointratio>0)
			Format(szPointsRatio, 32, "+%ip",pointratio);
		else
			Format(szPointsRatio, 32, "%ip",pointratio);			
		
		if (winratio>0)
		{
			if (pointratio>0)
				PrintToChat(client,"[%cKZ%c] %cYou have played %c%i%c challenges against %c%s%c (win/loss ratio: %c%s%c, points ratio: %c%s%c)", MOSSGREEN,WHITE,GRAY,PURPLE,challenges,GRAY,PURPLE, szName,GRAY, GREEN,szWinRatio,GRAY,GREEN,szPointsRatio,GRAY);
			else
					if (pointratio<0)
						PrintToChat(client,"[%cKZ%c] %cYou have played %c%i%c challenges against %c%s%c (win/loss ratio: %c%s%c, points ratio: %c%s%c)", MOSSGREEN,WHITE,GRAY,PURPLE,challenges,GRAY,PURPLE, szName,GRAY, GREEN,szWinRatio,GRAY,RED,szPointsRatio,GRAY);
					else
						PrintToChat(client,"[%cKZ%c] %cYou have played %c%i%c challenges against %c%s%c (win/loss ratio: %c%s%c, points ratio: %c%s%c)", MOSSGREEN,WHITE,GRAY,PURPLE,challenges,GRAY,PURPLE, szName,GRAY, GREEN,szWinRatio,GRAY,YELLOW,szPointsRatio,GRAY);	
		}
		else
		{
			if (winratio<0)
			{
				if (pointratio>0)
					PrintToChat(client,"[%cKZ%c] %cYou have played %c%i%c challenges against %c%s%c (win/loss ratio: %c%s%c, points ratio: %c%s%c)", MOSSGREEN,WHITE,GRAY,PURPLE,challenges,GRAY,PURPLE, szName,GRAY, RED,szWinRatio,GRAY,GREEN,szPointsRatio,GRAY);
				else
					if (pointratio<0)
						PrintToChat(client,"[%cKZ%c] %cYou have played %c%i%c challenges against %c%s%c (win/loss ratio: %c%s%c, points ratio: %c%s%c)", MOSSGREEN,WHITE,GRAY,PURPLE,challenges,GRAY,PURPLE, szName,GRAY, RED,szWinRatio,GRAY,RED,szPointsRatio,GRAY);
					else
						PrintToChat(client,"[%cKZ%c] %cYou have played %c%i%c challenges against %c%s%c (win/loss ratio: %c%s%c, points ratio: %c%s%c)", MOSSGREEN,WHITE,GRAY,PURPLE,challenges,GRAY,PURPLE, szName,GRAY, RED,szWinRatio,GRAY,YELLOW,szPointsRatio,GRAY);	
		
			}
			else
			{
				if (pointratio>0)
					PrintToChat(client,"[%cKZ%c] %cYou have played %c%i%c challenges against %c%s%c (win/loss ratio: %c%s%c, points ratio: %c%s%c)", MOSSGREEN,WHITE,GRAY,PURPLE,challenges,GRAY,PURPLE, szName,GRAY, YELLOW,szWinRatio,GRAY,GREEN,szPointsRatio,GRAY);
				else
					if (pointratio<0)
						PrintToChat(client,"[%cKZ%c] %cYou have played %c%i%c challenges against %c%s%c (win/loss ratio: %c%s%c, points ratio: %c%s%c)", MOSSGREEN,WHITE,GRAY,PURPLE,challenges,GRAY,PURPLE, szName,GRAY, YELLOW,szWinRatio,GRAY,RED,szPointsRatio,GRAY);
					else
						PrintToChat(client,"[%cKZ%c] %cYou have played %c%i%c challenges against %c%s%c (win/loss ratio: %c%s%c, points ratio: %c%s%c)", MOSSGREEN,WHITE,GRAY,PURPLE,challenges,GRAY,PURPLE, szName,GRAY, YELLOW,szWinRatio,GRAY,YELLOW,szPointsRatio,GRAY);	
			}
		}	
	}
	else
		PrintToChat(client,"[%cKZ%c] No challenges againgst %s found", szName);
}

//COMPARE
public db_viewPlayerAll2(client, String:szPlayerName[MAX_NAME_LENGTH])
{
	decl String:szQuery[512];
	decl String:szName[MAX_NAME_LENGTH*2+1];
	SQL_QuoteString(g_hDb, szPlayerName, szName, MAX_NAME_LENGTH*2+1);      
	Format(szQuery, 512, sql_selectPlayerRankAll, PERCENT,szName,PERCENT);
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, szPlayerName);
	SQL_TQuery(g_hDb, SQL_ViewPlayerAll2Callback, szQuery, pack,DBPrio_Low);
}
//COMPARE
public SQL_ViewPlayerAll2Callback(Handle:owner, Handle:hndl, const String:error[], any:data)
{  
	decl String:szName[MAX_NAME_LENGTH]; 
	new Handle:pack = data;	
	ResetPack(pack);
	new client = ReadPackCell(pack);      
	ReadPackString(pack, szName, MAX_NAME_LENGTH);
	decl String:szSteamId2[32];
	if (!IsValidClient(client))	
	{
		CloseHandle(pack);
		return;
	}
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{   	
		SQL_FetchString(hndl, 1, szSteamId2, 32);	
		if (!StrEqual(szSteamId2,g_szSteamID[client]))
			db_viewPlayerRank2(client,szSteamId2);
	}
	else
		PrintToChat(client, "%t", "PlayerNotFound", MOSSGREEN,WHITE, szName);
	CloseHandle(pack);
}


public db_setupDatabase()
{
	decl String:szError[255];
	g_hDb = SQL_Connect("kztimer", false, szError, 255);
	if(g_hDb == INVALID_HANDLE)
	{
		SetFailState("[KZTimer] Unable to connect to database (%s)",szError);
		return;
	}
	decl String:szIdent[8];
	SQL_ReadDriver(g_hDb, szIdent, 8);
        
	if(strcmp(szIdent, "mysql", false) == 0)
	{
		g_DbType = MYSQL;
	}
	else 
		if(strcmp(szIdent, "sqlite", false) == 0)
			g_DbType = SQLITE;
		else
		{
			LogError("[KZPro] Invalid Database-Type");
			return;
		}
	SQL_SetCharset(g_hDb,"UTF8");
	db_createTables();
}


public db_createTables()
{
	SQL_LockDatabase(g_hDb);        
	SQL_FastQuery(g_hDb, sql_createPlayertmp);
	SQL_FastQuery(g_hDb, sql_createPlayertimes);
	SQL_FastQuery(g_hDb, sql_createPlayerjumpstats);
	SQL_FastQuery(g_hDb, sql_createPlayerRank);
	SQL_FastQuery(g_hDb, sql_createChallenges);
	SQL_FastQuery(g_hDb, sql_createMapButtons);
	SQL_FastQuery(g_hDb, sql_createPlayerOptions);
	SQL_FastQuery(g_hDb, sql_createLatestRecords);
	SQL_FastQuery(g_hDb, "ALTER TABLE playerrank ADD lastseen  DATE NOT NULL DEFAULT '0000-00-00'"); //added in 1.54
	SQL_FastQuery(g_hDb, "ALTER TABLE playertmp ADD EncTickrate INT NOT NULL");	//added in 1.55
	SQL_FastQuery(g_hDb, "ALTER TABLE playeroptions2 ADD ViewModel INT NOT NULL DEFAULT '1'"); //added in 1.67 
	SQL_FastQuery(g_hDb, "ALTER TABLE playeroptions2 ADD AdvInfoPanel INT NOT NULL DEFAULT '0'"); //added in 1.71
	SQL_FastQuery(g_hDb, "ALTER TABLE playeroptions2 ADD ReplayRoute INT NOT NULL DEFAULT '0'"); //added in 1.75
	SQL_FastQuery(g_hDb, "ALTER TABLE playeroptions2 ADD Language INT NOT NULL DEFAULT '0'"); //added in 1.75
	SQL_FastQuery(g_hDb, "ALTER TABLE playerjumpstats3 ADD cjrecord FLOAT NOT NULL DEFAULT '-1.0'"); //added in 1.73
	SQL_FastQuery(g_hDb, "ALTER TABLE playerjumpstats3 ADD cjpre FLOAT NOT NULL DEFAULT '-1.0'"); //added in 1.73
	SQL_FastQuery(g_hDb, "ALTER TABLE playerjumpstats3 ADD cjmax FLOAT NOT NULL DEFAULT '-1.0'"); //added in 1.73
	SQL_FastQuery(g_hDb, "ALTER TABLE playerjumpstats3 ADD cjstrafes INT NOT NULL DEFAULT '0'"); //added in 1.73
	SQL_FastQuery(g_hDb, "ALTER TABLE playerjumpstats3 ADD cjsync INT NOT NULL DEFAULT '0'"); //added in 1.73
	SQL_FastQuery(g_hDb, "ALTER TABLE playerjumpstats3 ADD cjheight FLOAT NOT NULL DEFAULT '-1.0'"); //added in 1.73
	SQL_FastQuery(g_hDb, "ALTER TABLE playeroptions2 ADD error_sounds INT NOT NULL DEFAULT '1'"); //added in 1.88
	SQL_UnlockDatabase(g_hDb);
}

public db_insertPlayerChallenge(client)
{
	if (!IsValidClient(client))
		return;
	decl String:szQuery[255];
	new points;
	new cps;
	points = g_Challenge_Bet[client] * g_pr_PointUnit;
	if (g_bChallenge_Checkpoints[client])
		cps=1;
	else
		cps=0;
	Format(szQuery, 255, sql_insertChallenges, g_szSteamID[client], g_szChallenge_OpponentID[client],points,g_szMapName, cps);
	SQL_TQuery(g_hDb, sql_insertChallengesCallback, szQuery,client,DBPrio_Low);
}

public sql_insertChallengesCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
}	
public db_insertPlayer(client)
{
	decl String:szQuery[255];
	decl String:szUName[MAX_NAME_LENGTH];
	if (IsValidClient(client))
	{
		GetClientName(client, szUName, MAX_NAME_LENGTH);
	}
	else
		return;	
	decl String:szName[MAX_NAME_LENGTH*2+1];      
	SQL_QuoteString(g_hDb, szUName, szName, MAX_NAME_LENGTH*2+1);
	Format(szQuery, 255, sql_insertPlayer, g_szSteamID[client], g_szMapName, szName); 
	SQL_TQuery(g_hDb, SQL_InsertPlayerCallback, szQuery,client,DBPrio_Low);
}

public SQL_InsertPlayerCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
}	
	
public db_deleteTmp(client)
{
	decl String:szQuery[256];
	if (!IsValidClient(client))
		return;
	Format(szQuery, 256, sql_deletePlayerTmp, g_szSteamID[client]); 
	SQL_TQuery(g_hDb, sql_deletePlayerCheckCallback, szQuery, client,DBPrio_Low);
}
public db_deleteMapButtons(String:szMapName[128])
{
	decl String:szQuery[256];
	Format(szQuery, 256, sql_deleteMapButtons, g_szMapName); 
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery,DBPrio_Low);
}

public db_selectLastRun(client)
{
	decl String:szQuery[512];
	if (!IsValidClient(client))
		return;

	if(g_bDisconnected[client])
		g_bGlobalDisconnected[client] = true;

	Format(szQuery, 512, sql_selectPlayerTmp, g_szSteamID[client], g_szMapName);     
	SQL_TQuery(g_hDb, SQL_LastRunCallback, szQuery, client,DBPrio_Low);
}

public SQL_LastRunCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;	
	g_bTimeractivated[client] = false;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl) && IsValidClient(client))
	{
	
		//Get last psition
		g_fPlayerCordsRestore[client][0] = SQL_FetchFloat(hndl, 0);
		g_fPlayerCordsRestore[client][1] = SQL_FetchFloat(hndl, 1);
		g_fPlayerCordsRestore[client][2] = SQL_FetchFloat(hndl, 2);
		g_fPlayerAnglesRestore[client][0] = SQL_FetchFloat(hndl, 3);
		g_fPlayerAnglesRestore[client][1] = SQL_FetchFloat(hndl, 4);
		g_fPlayerAnglesRestore[client][2] = SQL_FetchFloat(hndl, 5);		
		g_OverallTp[client] = SQL_FetchInt(hndl, 6);
		g_OverallCp[client] = SQL_FetchInt(hndl, 7);		
		
		//Set new start time	
		new Float: fl_time = SQL_FetchFloat(hndl, 8);
		new Float:absTime = FloatAbs(fl_time);
		new tickrate = SQL_FetchInt(hndl, 9);
		if (absTime < 1.0 || tickrate < 1)
			return;
		tickrate = tickrate / 5 / RoundToFloor(absTime);
		
		
		if (tickrate == g_Server_Tickrate)
		{
			if (fl_time > 0.0)
			{

				if (g_OverallTp[client] < 0) 
					g_OverallTp[client] = 0;
				if (g_OverallCp[client] < 0) 
					g_OverallCp[client] = 0;
				g_fStartTime[client] = GetEngineTime() - fl_time;  
				g_bTimeractivated[client] = true;
				
			}
				
			if (SQL_FetchFloat(hndl, 0) == -1.0 && SQL_FetchFloat(hndl, 1) == -1.0 && SQL_FetchFloat(hndl, 2) == -1.0) 
			{
				g_bRestorePosition[client] = false;
				g_bRestorePositionMsg[client] = false;
			}
			else
			{
				if (g_bLateLoaded && IsPlayerAlive(client))
				{
					g_bPositionRestored[client] = true;		
					DoValidTeleport(client, g_fPlayerCordsRestore[client],g_fPlayerAnglesRestore[client],Float:{0.0,0.0,-100.0});
					g_bRestorePosition[client]  = false;
				}
				else
				{
					g_bRestorePosition[client] = true;
					g_bRestorePositionMsg[client]=true;
				}
				
			}
		}
	}
	else
	{
		g_bTimeractivated[client] = false;
	}
}
public db_viewPersonalRecords(client, String:szSteamId[32], String:szMapName[128])
{
	decl String:szQuery[1024];
	Format(szQuery, 1024, sql_selectPersonalRecords, szSteamId, szMapName);
	SQL_TQuery(g_hDb, SQL_selectPersonalRecordsCallback, szQuery, client,DBPrio_Low);
}

public SQL_selectPersonalRecordsCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new id = data;
	g_fPersonalRecord[id] = 0.0;
	g_fPersonalRecordPro[id] = 0.0;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_fPersonalRecord[id] = SQL_FetchFloat(hndl, 3);
		g_fPersonalRecordPro[id] = SQL_FetchFloat(hndl, 4); 
		
		if (g_fPersonalRecordPro[id]>0.0)
			db_viewMapRankPro(id);
		else
			g_fPersonalRecordPro[id] = 0.0;
		if (g_fPersonalRecord[id]>0.0)
			db_viewMapRankTp(id);
		else
			g_fPersonalRecord[id] = 0.0;
	}
}                


public db_viewJumpStats(client, String:szSteamId[32])
{
	decl String:szQuery[1024];       
	Format(szQuery, 1024, sql_selectJumpStats1, szSteamId);  
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, szSteamId);	
	SQL_TQuery(g_hDb, SQL_ViewJumpStatsCallback, szQuery, pack,DBPrio_Low);
}

public SQL_ViewJumpStatsCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	decl String:szSteamId[1024]; 
	decl String:szQuery[1024];   
	decl Float:ladderjumprecord, Float:ladderjumppre,Float:ladderjumpmax, Float:ladderjumpheight;	
	
	new Handle:pack = data;	
	ResetPack(pack); 
	new client = ReadPackCell(pack);      
	ReadPackString(pack, szSteamId, 32);
	g_bClimbersMenuOpen[client] = false;
	g_bMenuOpen[client] = true;		
	new ladderjumpstrafes, ladderjumpsync;
	ladderjumprecord = -1.0;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		ladderjumprecord = SQL_FetchFloat(hndl, 2);
		ladderjumppre = SQL_FetchFloat(hndl, 3);
		ladderjumpmax = SQL_FetchFloat(hndl, 4);
		ladderjumpstrafes = SQL_FetchInt(hndl, 5);	
		ladderjumpsync = SQL_FetchInt(hndl, 6);
		ladderjumpheight = SQL_FetchFloat(hndl, 7);
	}

	WritePackFloat(pack, ladderjumprecord);
	WritePackFloat(pack, ladderjumppre);
	WritePackFloat(pack, ladderjumpmax);
	WritePackCell(pack, ladderjumpstrafes);
	WritePackCell(pack, ladderjumpsync);
	WritePackFloat(pack, ladderjumpheight);
	
	Format(szQuery, 1024, sql_selectJumpStats2, szSteamId);  
	SQL_TQuery(g_hDb, SQL_ViewJumpStatsCallback2, szQuery, pack,DBPrio_Low);
}
public SQL_ViewJumpStatsCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	decl String:szSteamId[32];	
	new Handle:pack = data;	
	ResetPack(pack); 
	new client = ReadPackCell(pack);      
	ReadPackString(pack, szSteamId, 32);
	new Float:ladderjumprecord = ReadPackFloat(pack);
	new Float:ladderjumppre = ReadPackFloat(pack);
	new Float:ladderjumpmax = ReadPackFloat(pack);
	new ladderjumpstrafes = ReadPackCell(pack);
	new ladderjumpsync = ReadPackCell(pack);
	new Float:ladderjumpheight = ReadPackFloat(pack);
	CloseHandle(pack);
	g_bClimbersMenuOpen[client] = false;
	g_bMenuOpen[client] = true;		
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
					
		decl String:szName[17];	
		decl String:szVr[255];	
		
		//get the result
		SQL_FetchString(hndl, 0, szSteamId, MAX_NAME_LENGTH);
		SQL_FetchString(hndl, 1, szName, 17);
		new Float:bhoprecord = SQL_FetchFloat(hndl, 2);
		new Float:bhoppre = SQL_FetchFloat(hndl, 3);
		new Float:bhopmax = SQL_FetchFloat(hndl, 4);
		new bhopstrafes = SQL_FetchInt(hndl, 5);
		new bhopsync = SQL_FetchInt(hndl, 6);
		new Float:ljrecord = SQL_FetchFloat(hndl, 7);
		new Float:ljpre = SQL_FetchFloat(hndl, 8);
		new Float:ljmax = SQL_FetchFloat(hndl, 9);
		new ljstrafes = SQL_FetchInt(hndl, 10);
		new ljsync = SQL_FetchInt(hndl, 11);		
		new Float:multibhoprecord = SQL_FetchFloat(hndl, 12);
		new Float:multibhoppre = SQL_FetchFloat(hndl, 13);
		new Float:multibhopmax = SQL_FetchFloat(hndl, 14);
		new multibhopstrafes = SQL_FetchInt(hndl, 15);
		new multibhopsync = SQL_FetchInt(hndl, 17);
		new Float:wjrecord = SQL_FetchFloat(hndl, 18);
		new Float:wjpre = SQL_FetchFloat(hndl, 19);
		new Float:wjmax = SQL_FetchFloat(hndl, 20);
		new wjstrafes = SQL_FetchInt(hndl, 21);	 
		new wjsync = SQL_FetchInt(hndl, 22);	
		new Float:dropbhoprecord = SQL_FetchFloat(hndl, 23);
		new Float:dropbhoppre = SQL_FetchFloat(hndl, 24);
		new Float:dropbhopmax = SQL_FetchFloat(hndl, 25);
		new dropbhopstrafes = SQL_FetchInt(hndl, 26);	
		new dropbhopsync = SQL_FetchInt(hndl, 27);	
		new Float:ljheight = SQL_FetchFloat(hndl, 28);
		new Float:bhopheight = SQL_FetchFloat(hndl, 29);
		new Float:multibhopheight = SQL_FetchFloat(hndl, 30);
		new Float:dropbhopheight = SQL_FetchFloat(hndl, 31);
		new Float:wjheight = SQL_FetchFloat(hndl, 32);		
		new ljblockdist = SQL_FetchInt(hndl, 33);	
		new Float:ljblockrecord = SQL_FetchFloat(hndl, 34);		
		new Float:ljblockpre = SQL_FetchFloat(hndl, 35);
		new Float:ljblockmax = SQL_FetchFloat(hndl, 36);
		new ljblockstrafes = SQL_FetchInt(hndl, 37);
		new ljblocksync = SQL_FetchInt(hndl, 38);		
		new Float:ljblockheight = SQL_FetchFloat(hndl, 39);	
		new Float:cjrecord = SQL_FetchFloat(hndl, 40);		
		new Float:cjpre = SQL_FetchFloat(hndl, 41);
		new Float:cjmax = SQL_FetchFloat(hndl, 42);
		new cjstrafes = SQL_FetchInt(hndl, 43);
		new cjsync = SQL_FetchInt(hndl, 44);		
		new Float:cjheight = SQL_FetchFloat(hndl, 45);
		
		new bool:ljtrue;
		
		
		if (bhoprecord >0.0 || ljrecord > 0.0 || multibhoprecord > 0.0 || wjrecord > 0.0 || dropbhoprecord > 0.0 || ljblockdist > 0.0 || ladderjumprecord > 0.0 || cjrecord > 0.0)
		{										 
			Format(szVr, 255, "Jumpstats: %s\nType               Distance  Strafes  Pre        Max      Height  Sync", szName);
			new Handle:menu = CreateMenu(JumpStatsMenuHandler);
			SetMenuTitle(menu, szVr);
			if (ljrecord > 0.0)
			{
				if (ljstrafes>9)
					Format(szVr, 255, "LJ:              %.3f     %i       %.2f   %.2f  %.1f    %i%c", ljrecord,ljstrafes,ljpre,ljmax,ljheight,ljsync,PERCENT);
				else
					Format(szVr, 255, "LJ:              %.3f       %i       %.2f   %.2f  %.1f    %i%c", ljrecord,ljstrafes,ljpre,ljmax,ljheight,ljsync,PERCENT);
				AddMenuItem(menu, szVr, szVr);	
				ljtrue=true;
			}
			if (ljblockdist > 0)
			{
				if (ljstrafes>9)
					Format(szVr, 255, "BlockLJ:     %i|%.1f  %i       %.2f   %.2f  %.1f    %i%c", ljblockdist,ljblockrecord,ljblockstrafes,ljblockpre,ljblockmax,ljblockheight,ljblocksync,PERCENT);
				else
					Format(szVr, 255, "BlockLJ:     %i|%.1f    %i       %.2f   %.2f  %.1f    %i%c", ljblockdist,ljblockrecord,ljblockstrafes,ljblockpre,ljblockmax,ljblockheight,ljblocksync,PERCENT);
				AddMenuItem(menu, szVr, szVr);	
				ljtrue=true;
			}				
			if (bhoprecord > 0.0)
			{
				if (bhopstrafes>9)
					Format(szVr, 255, "Bhop:         %.3f     %i       %.2f   %.2f  %.1f    %i%c", bhoprecord,bhopstrafes,bhoppre,bhopmax,bhopheight,bhopsync,PERCENT);
				else
					Format(szVr, 255, "Bhop:         %.3f       %i       %.2f   %.2f  %.1f    %i%c", bhoprecord,bhopstrafes,bhoppre,bhopmax,bhopheight,bhopsync,PERCENT);
				AddMenuItem(menu, szVr, szVr);	
			}
			if (dropbhoprecord > 0.0)
			{
				if (dropbhopstrafes>9)
					Format(szVr, 255, "D.-Bhop:    %.3f     %i       %.2f   %.2f  %.1f    %i%c", dropbhoprecord,dropbhopstrafes,dropbhoppre,dropbhopmax,dropbhopheight,dropbhopsync,PERCENT);
				else  
					Format(szVr, 255, "D.-Bhop:    %.3f       %i       %.2f   %.2f  %.1f    %i%c", dropbhoprecord,dropbhopstrafes,dropbhoppre,dropbhopmax,dropbhopheight,dropbhopsync,PERCENT);	
				AddMenuItem(menu, szVr, szVr);	
			}	
			if (multibhoprecord > 0.0)
			{
				if (multibhopstrafes>9)
					Format(szVr, 255, "M.-Bhop:    %.3f     %i       %.2f   %.2f  %.1f    %i%c", multibhoprecord,multibhopstrafes,multibhoppre,multibhopmax,multibhopheight,multibhopsync,PERCENT);
				else
					Format(szVr, 255, "M.-Bhop:    %.3f       %i       %.2f   %.2f  %.1f    %i%c", multibhoprecord,multibhopstrafes,multibhoppre,multibhopmax,multibhopheight,multibhopsync,PERCENT);
				AddMenuItem(menu, szVr, szVr);	
			}
			if (wjrecord > 0.0)
			{
				if (wjstrafes>9)
					Format(szVr, 255, "WJ:             %.3f     %i       %.2f   %.2f  %.1f    %i%c", wjrecord,wjstrafes,wjpre,wjmax,wjheight,wjsync,PERCENT);
				else
					Format(szVr, 255, "WJ:             %.3f       %i       %.2f   %.2f  %.1f    %i%c", wjrecord,wjstrafes,wjpre,wjmax,wjheight,wjsync,PERCENT);	
				AddMenuItem(menu, szVr, szVr);	
			}
			if (cjrecord > 0.0)
			{
				if (ladderjumpstrafes>9)
					Format(szVr, 255, "CJ:              %.3f     %i       %.2f   %.2f  %.1f    %i%c", cjrecord,cjstrafes,cjpre,cjmax,cjheight,cjsync,PERCENT);
				else 
					Format(szVr, 255, "CJ:              %.3f       %i       %.2f   %.2f  %.1f    %i%c", cjrecord,cjstrafes,cjpre,cjmax,cjheight,cjsync,PERCENT);	
				AddMenuItem(menu, szVr, szVr);	
			}
			if (ladderjumprecord > 0.0)
			{
				if (ladderjumpstrafes>9)
					Format(szVr, 255, "Ladder:       %.3f     %i       %.2f   %.2f  %.1f    %i%c", ladderjumprecord,ladderjumpstrafes,ladderjumppre,ladderjumpmax,ladderjumpheight,ladderjumpsync,PERCENT);
				else
					Format(szVr, 255, "Ladder:       %.3f       %i       %.2f   %.2f  %.1f    %i%c", ladderjumprecord,ladderjumpstrafes,ladderjumppre,ladderjumpmax,ladderjumpheight,ladderjumpsync,PERCENT);	
				AddMenuItem(menu, szVr, szVr);	
			}				
			if (ljtrue && !g_bPreStrafe)
				PrintToChat(client,"[%cKZ%c] %cJUMPSTATS INFO%c: %cLJ PRE%c = JumpOff",MOSSGREEN,WHITE,GRAY,WHITE,YELLOW,WHITE);	
			SetMenuPagination(menu, 5);
			//SetMenuPagination(menu, MENU_NO_PAGINATION); 
			SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
			DisplayMenu(menu, client, MENU_TIME_FOREVER);	
		}
		else
			PrintToChat(client, "%t", "noJumpRecords",MOSSGREEN,WHITE);

		
	}
	else
	{
		ProfileMenu(client, -1);
		PrintToChat(client, "%t", "noJumpRecords",MOSSGREEN,WHITE);
	}
}

public JumpStatsMenuHandler(Handle:menu, MenuAction:action, param1,param2)
{
	if (action ==  MenuAction_Cancel || action ==  MenuAction_Select)
	{
		ProfileMenu(param1, -1);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public db_viewPersonalLJRecord(client, String:szSteamId[32])
{
	decl String:szQuery[512];      
	Format(szQuery, 512, sql_selectPlayerJumpLJ, szSteamId);  
	SQL_TQuery(g_hDb, SQL_LJRecordCallback, szQuery, client,DBPrio_Low);
}

public db_viewPersonalLadderJumpRecord(client, String:szSteamId[32])
{
	decl String:szQuery[512];      
	Format(szQuery, 512, sql_selectPlayerJumpLadderJump, szSteamId);  
	SQL_TQuery(g_hDb, SQL_LadderJumpRecordCallback, szQuery, client,DBPrio_Low);
}

public db_viewPersonalCJRecord(client, String:szSteamId[32])
{
	decl String:szQuery[512];      
	Format(szQuery, 512, sql_selectPlayerJumpCountJump, szSteamId);  
	SQL_TQuery(g_hDb, SQL_CJRecordCallback, szQuery, client,DBPrio_Low);
}


public db_viewPersonalLJBlockRecord(client, String:szSteamId[32])
{
	decl String:szQuery[512];      
	Format(szQuery, 512, sql_selectPlayerJumpLJBlock, szSteamId);  
	SQL_TQuery(g_hDb, SQL_LJBlockRecordCallback, szQuery, client,DBPrio_Low);
}

public db_viewPersonalBhopRecord(client, String:szSteamId[32])
{
	decl String:szQuery[512];       
	Format(szQuery, 512, sql_selectPlayerJumpBhop, szSteamId);  
	SQL_TQuery(g_hDb, SQL_ViewBhopRecordCallback, szQuery, client,DBPrio_Low);
}

public db_viewPersonalDropBhopRecord(client, String:szSteamId[32])
{
	decl String:szQuery[512];       
	Format(szQuery, 512, sql_selectPlayerJumpDropBhop, szSteamId);  
	SQL_TQuery(g_hDb, SQL_ViewDropBhopRecordCallback, szQuery, client,DBPrio_Low);
}


public db_viewPersonalWeirdRecord(client, String:szSteamId[32])
{
	decl String:szQuery[512];       
	Format(szQuery, 512, sql_selectPlayerJumpWJ, szSteamId);  
	SQL_TQuery(g_hDb, SQL_ViewWeirdRecordCallback, szQuery, client,DBPrio_Low);
}


public db_viewPersonalMultiBhopRecord(client, String:szSteamId[32])
{
	decl String:szQuery[512];       
	Format(szQuery, 512, sql_selectPlayerJumpMultiBhop, szSteamId);  
	SQL_TQuery(g_hDb, SQL_ViewMultiBhopRecordCallback, szQuery, client,DBPrio_Low);
}

public GetDBName(client, String:szSteamId[32])
{
	decl String:szQuery[512];      
	Format(szQuery, 512, sql_selectRankedPlayer, szSteamId); 
	SQL_TQuery(g_hDb, GetDBNameCallback, szQuery, client,DBPrio_Low);
}

public GetDBNameCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{               
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		SQL_FetchString(hndl, 1, g_szProfileName[client], MAX_NAME_LENGTH);	
		db_viewPlayerAll(client, g_szProfileName[client]);
	}
}

public db_CalcAvgRunTime()
{
	decl String:szQuery[256];  
	Format(szQuery, 256, "select runtime, runtimepro from playertimes where mapname = '%s'", g_szMapName);
	SQL_TQuery(g_hDb, SQL_db_CalcAvgRunTimeCallback, szQuery, DBPrio_Low);
}

public SQL_db_CalcAvgRunTimeCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{   
	g_favg_protime = 0.0;
	g_favg_tptime = 0.0;
	if(SQL_HasResultSet(hndl))
	{
		new rowcount = SQL_GetRowCount(hndl);
		new i, protimes, tptimes;
		new Float:TpTime, Float:ProTime;	
		while (SQL_FetchRow(hndl))
		{
			new Float:tp = SQL_FetchFloat(hndl, 0);
			new Float:pro = SQL_FetchFloat(hndl, 1);
			if (tp > 0.0)
			{
				TpTime += tp;
				tptimes++;
			}
			if (pro > 0.0)
			{
				ProTime += pro;
				protimes++;
			}			
			i++;
			if (rowcount == i)
			{
				g_favg_tptime = TpTime / tptimes;
				g_favg_protime = ProTime / protimes;
			}
		}
	}
}

public db_GetDynamicTimelimit()
{
	if (!g_bDynamicTimelimit)
		return;
	decl String:szQuery[256];  
	Format(szQuery, 256, "select runtime, runtimepro from playertimes where mapname = '%s'", g_szMapName);
	SQL_TQuery(g_hDb, SQL_db_GetDynamicTimelimitCallback, szQuery, DBPrio_Low);
}

public SQL_db_GetDynamicTimelimitCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{   
	if(SQL_HasResultSet(hndl))
	{
		new rowcount = SQL_GetRowCount(hndl);
		new i, maptimes;
		new Float:total = 0.0,Float:TpTime,Float:ProTime;	
		while (SQL_FetchRow(hndl))
		{
			
			TpTime = SQL_FetchFloat(hndl, 0);
			ProTime = SQL_FetchFloat(hndl, 1);
			if (TpTime > 0.0 || ProTime > 0.0)
			{
				if (TpTime > 0.0 && ProTime > 0.0)
					total += ((TpTime+ProTime)/2);
				else
					if (TpTime > 0.0)
						total += TpTime;
					else
						total += ProTime;
				maptimes++;
			}
			i++;
			if (rowcount == i)
			{
				//requires min. 5 map times
				if (maptimes > 5)
				{				
					new scale_factor = 3;
					new avg = RoundToNearest((total) / float(60) / float(maptimes)); ////output: x min
			
						
					//scale factor
					if (avg <= 10) 
						scale_factor = 5;
					if (avg <= 5) 
						scale_factor = 8;
					if (avg <= 3)
						scale_factor = 10;
					if (avg <= 2)
						scale_factor = 12;
					if (avg <= 1)
						scale_factor = 14;			
					avg = avg * scale_factor;
				
					//timelimit: min 20min, max 150min
					if (avg < 20)
						avg = 20;
					if (avg > 150)
						avg = 150;
						
					//set timelimit
					decl String:szBuffer[32];
					Format(szBuffer,32,"mp_timelimit %i", avg);
					ServerCommand(szBuffer);
					if (avg > 60)
						avg = 60;
					Format(szBuffer,32,"mp_roundtime %i", avg);
					ServerCommand(szBuffer);		
					ServerCommand("mp_restartgame 1");
				}
			}
		}
	}
}


public db_viewPlayerAll(client, String:szPlayerName[MAX_NAME_LENGTH])
{
	decl String:szQuery[512];
	decl String:szName[MAX_NAME_LENGTH*2+1];
	SQL_QuoteString(g_hDb, szPlayerName, szName, MAX_NAME_LENGTH*2+1);      
	Format(szQuery, 512, sql_selectPlayerRankAll, PERCENT,szName,PERCENT);
	SQL_TQuery(g_hDb, SQL_ViewPlayerAllCallback, szQuery, client,DBPrio_Low);
}


public SQL_ViewPlayerAllCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{    
	new client = data;  
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{           
		SQL_FetchString(hndl, 1, g_szProfileSteamId[client], 32);
		db_viewPlayerRank(client,g_szProfileSteamId[client]);
	}
	else
		if(IsClientInGame(client))
			PrintToChat(client, "%t", "PlayerNotFound", MOSSGREEN,WHITE, g_szProfileName[client]);
}



public SQL_CJRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{            
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_js_fPersonal_CJ_Record[client] = SQL_FetchFloat(hndl, 2);
		if (g_js_fPersonal_CJ_Record[client] > -1.0)
		{
			decl String:szQuery[512];   
			if (client > MAXPLAYERS)
			{
				decl String:szSteamId[32];
				Format(szSteamId, 32, "%s", g_pr_szSteamID[client]); 
				Format(szQuery, 255, sql_selectPlayerRankCountJump, szSteamId);
				SQL_TQuery(g_hDb, SQL_viewCJRecordCallback2, szQuery, client,DBPrio_Low);
			}
			else
			{
				if (IsValidClient(client))
				{
					Format(szQuery, 255, sql_selectPlayerRankCountJump, g_szSteamID[client]);
					SQL_TQuery(g_hDb, SQL_viewCJRecordCallback2, szQuery, client,DBPrio_Low);
				}
			}
		}
		else
		{
			g_js_CJRank[client] = 99999999;
			g_js_fPersonal_CJ_Record[client] = -1.0;
		}
	}
	else
	{
		g_js_CJRank[client] = 99999999;
		g_js_fPersonal_CJ_Record[client] = -1.0;
	}
}


public SQL_LadderJumpRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{            
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_js_fPersonal_LadderJump_Record[client] = SQL_FetchFloat(hndl, 2);
		if (g_js_fPersonal_LadderJump_Record[client] > -1.0)
		{
			decl String:szQuery[512];   
			if (client > MAXPLAYERS)
			{
				decl String:szSteamId[32];
				Format(szSteamId, 32, "%s", g_pr_szSteamID[client]); 
				Format(szQuery, 255, sql_selectPlayerRankLadderJump, szSteamId);
				SQL_TQuery(g_hDb, SQL_viewLadderJumpRecordCallback2, szQuery, client,DBPrio_Low);
			}
			else
			{
				if (IsValidClient(client))
				{
					Format(szQuery, 255, sql_selectPlayerRankLadderJump, g_szSteamID[client]);
					SQL_TQuery(g_hDb, SQL_viewLadderJumpRecordCallback2, szQuery, client,DBPrio_Low);
				}
			}
		}
		else
		{
			g_js_LadderJumpRank[client] = 99999999;
			g_js_fPersonal_LadderJump_Record[client] = -1.0;
		}
	}
	else
	{
		g_js_LadderJumpRank[client] = 99999999;
		g_js_fPersonal_LadderJump_Record[client] = -1.0;
	}
}

public SQL_LJRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{            
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_js_fPersonal_Lj_Record[client] = SQL_FetchFloat(hndl, 2);
		if (g_js_fPersonal_Lj_Record[client] > -1.0)
		{
			decl String:szQuery[512];   
			if (client > MAXPLAYERS)
			{
				decl String:szSteamId[32];
				Format(szSteamId, 32, "%s", g_pr_szSteamID[client]); 
				Format(szQuery, 255, sql_selectPlayerRankLj, szSteamId);
				SQL_TQuery(g_hDb, SQL_viewLjRecordCallback2, szQuery, client,DBPrio_Low);
			}
			else
			{
				if (IsValidClient(client))
				{
					Format(szQuery, 255, sql_selectPlayerRankLj, g_szSteamID[client]);
					SQL_TQuery(g_hDb, SQL_viewLjRecordCallback2, szQuery, client,DBPrio_Low);
				}
			}

		}
		else
		{
			g_js_LjRank[client] = 99999999;
			g_js_fPersonal_Lj_Record[client] = -1.0;
			ContinueRecalc(client);
		}
	}
	else
	{
		g_js_LjRank[client] = 99999999;
		g_js_fPersonal_Lj_Record[client] = -1.0;
		ContinueRecalc(client);
	}
}

public SQL_LJBlockRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{               
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_js_Personal_LjBlock_Record[client] = SQL_FetchInt(hndl, 2);
		g_js_fPersonal_LjBlockRecord_Dist[client] = SQL_FetchFloat(hndl, 3);
		if (g_js_Personal_LjBlock_Record[client] > -1)
		{
			decl String:szQuery[512];   
			if (client > MAXPLAYERS)
			{
				decl String:szSteamId[32];
				Format(szSteamId, 32, "%s", g_pr_szSteamID[client]); 
				Format(szQuery, 255, sql_selectPlayerRankLjBlock, szSteamId);
				SQL_TQuery(g_hDb, SQL_viewLjBlockRecordCallback2, szQuery, client,DBPrio_Low);
			}
			else
			{
				if (IsValidClient(client))
				{
					Format(szQuery, 255, sql_selectPlayerRankLjBlock, g_szSteamID[client]);
					SQL_TQuery(g_hDb, SQL_viewLjBlockRecordCallback2, szQuery, client,DBPrio_Low);
				}
			}

		}
		else
		{
		g_js_LjBlockRank[client] = 99999999;
		g_js_Personal_LjBlock_Record[client] = -1;
		g_js_fPersonal_LjBlockRecord_Dist[client] = -1.0;
		}
	}
	else
	{
		g_js_LjBlockRank[client] = 99999999;
		g_js_Personal_LjBlock_Record[client] = -1;
		g_js_fPersonal_LjBlockRecord_Dist[client] = -1.0;
	}
}

public SQL_viewLadderJumpRecordCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{		
		g_js_LadderJumpRank[client]= SQL_GetRowCount(hndl);
	}
}

public SQL_viewCJRecordCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{		
		g_js_CJRank[client]= SQL_GetRowCount(hndl);
	}
}

public SQL_viewLjRecordCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{		
		g_js_LjRank[client]= SQL_GetRowCount(hndl);
	}
	ContinueRecalc(client);
}

public SQL_viewLjBlockRecordCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{		
		g_js_LjBlockRank[client]= SQL_GetRowCount(hndl);
	}
}

public ContinueRecalc(client)
{
	//ON RECALC ALL
	if (client > MAXPLAYERS)
		CalculatePlayerRank(client); 
	else
	{
		//ON CONNECT
		if (!IsValidClient(client) || IsFakeClient(client))
			return;
		new Float: diff = GetEngineTime() - g_fMapStartTime + 1.5;
		if (GetClientTime(client) < diff)
		{
			CalculatePlayerRank(client); 	
		}
		else
		{
			db_viewPlayerPoints(client);
		}
	}
}	
public SQL_ViewBhopRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_js_fPersonal_Bhop_Record[client] = SQL_FetchFloat(hndl, 2);
		if (g_js_fPersonal_Bhop_Record[client] > -1.0)
		{
			decl String:szQuery[512];  
			if (client > MAXPLAYERS)
			{
				decl String:szSteamId[32];
				Format(szSteamId, 32, "%s", g_pr_szSteamID[client]); 
				Format(szQuery, 255, sql_selectPlayerRankBhop, szSteamId);
				SQL_TQuery(g_hDb, SQL_viewBhopRecordCallback2, szQuery, client,DBPrio_Low);
			}
			else
			{
				if (IsValidClient(client))
				{
					Format(szQuery, 255, sql_selectPlayerRankBhop, g_szSteamID[client]);
					SQL_TQuery(g_hDb, SQL_viewBhopRecordCallback2, szQuery, client,DBPrio_Low);
				}
			}
		}
		else
		{
			g_js_BhopRank[client] = 99999999;
			g_js_fPersonal_Bhop_Record[client] = -1.0;
		}
	}
	else
	{
		g_js_BhopRank[client] = 99999999;
		g_js_fPersonal_Bhop_Record[client] = -1.0;
	}
}

public SQL_ViewDropBhopRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_js_fPersonal_DropBhop_Record[client] = SQL_FetchFloat(hndl, 2);
		if (g_js_fPersonal_DropBhop_Record[client] > -1.0)
		{
			decl String:szQuery[512];  
			if (client > MAXPLAYERS)
			{
				decl String:szSteamId[32];
				Format(szSteamId, 32, "%s", g_pr_szSteamID[client]); 
				Format(szQuery, 255, sql_selectPlayerRankDropBhop, szSteamId);
				SQL_TQuery(g_hDb, SQL_viewDropBhopRecordCallback2, szQuery, client,DBPrio_Low);
			}
			else
			{

				if (IsValidClient(client))
				{
					Format(szQuery, 255, sql_selectPlayerRankDropBhop, g_szSteamID[client]);
					SQL_TQuery(g_hDb, SQL_viewDropBhopRecordCallback2, szQuery, client,DBPrio_Low);
				}
			}
		}
		else
		{
			g_js_DropBhopRank[client] = 99999999;
			g_js_fPersonal_DropBhop_Record[client] = -1.0;
		}
	}
	else
	{
		g_js_DropBhopRank[client] = 99999999;
		g_js_fPersonal_DropBhop_Record[client] = -1.0;
	}
}

public SQL_viewDropBhopRecordCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		g_js_DropBhopRank[client]= SQL_GetRowCount(hndl);
}

public SQL_ViewWeirdRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_js_fPersonal_Wj_Record[client] = SQL_FetchFloat(hndl, 2);
		if (g_js_fPersonal_Wj_Record[client] > -1.0)
		{
			decl String:szSteamId[32];
			decl String:szQuery[512];  
			if (client > MAXPLAYERS)
			{
				Format(szSteamId, 32, "%s", g_pr_szSteamID[client]); 
				Format(szQuery, 255, sql_selectPlayerRankWJ, szSteamId);
				SQL_TQuery(g_hDb, SQL_viewWeirdRecordCallback2, szQuery, client,DBPrio_Low);
			}
			else
			{
				if (IsValidClient(client))
				{
					Format(szQuery, 255, sql_selectPlayerRankWJ, g_szSteamID[client]);
					SQL_TQuery(g_hDb, SQL_viewWeirdRecordCallback2, szQuery, client,DBPrio_Low);
				}
			}
		}
		else
		{
			g_js_WjRank[client] = 99999999;
			g_js_fPersonal_Wj_Record[client] = -1.0;
		}
	}
	else
	{
		g_js_WjRank[client] = 99999999;
		g_js_fPersonal_Wj_Record[client] = -1.0;
	}
}

public SQL_viewWeirdRecordCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		g_js_WjRank[client]= SQL_GetRowCount(hndl);
}

public SQL_ViewMultiBhopRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_js_fPersonal_MultiBhop_Record[client] = SQL_FetchFloat(hndl, 2);
		if (g_js_fPersonal_MultiBhop_Record[client] > -1.0)
		{
			decl String:szSteamId[32];
			decl String:szQuery[512];  
			if (client > MAXPLAYERS)
			{
				Format(szSteamId, 32, "%s", g_pr_szSteamID[client]); 
				Format(szQuery, 255, sql_selectPlayerRankMultiBhop, szSteamId);
				SQL_TQuery(g_hDb, SQL_viewMultiBhopRecordCallback2, szQuery, client,DBPrio_Low);
			}
			else
			{
				if (IsValidClient(client))
				{
					Format(szQuery, 255, sql_selectPlayerRankMultiBhop, g_szSteamID[client]);
					SQL_TQuery(g_hDb, SQL_viewMultiBhopRecordCallback2, szQuery, client,DBPrio_Low);
				}
			}
		}
		else
		{
			g_js_MultiBhopRank[client] = 99999999;
			g_js_fPersonal_MultiBhop_Record[client] = -1.0;
		}
	}
	else
	{
		g_js_MultiBhopRank[client] = 99999999;
		g_js_fPersonal_MultiBhop_Record[client] = -1.0;
	}
}

public SQL_viewBhopRecordCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		g_js_BhopRank[client]= SQL_GetRowCount(hndl);
}

public SQL_viewMultiBhopRecordCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		g_js_MultiBhopRank[client]= SQL_GetRowCount(hndl);
}

//---------------------//
// select player method //
//---------------------//
public db_selectPlayer(client)
{
	decl String:szQuery[255];
	if (!IsValidClient(client))
		return;
	Format(szQuery, 255, sql_selectPlayer, g_szSteamID[client], g_szMapName);
	SQL_TQuery(g_hDb, SQL_SelectPlayerCallback, szQuery, client,DBPrio_Low);
}



public db_viewBhopRecord2(client)
{
	decl String:szQuery[512];
	if (!IsValidClient(client))
		return;
	Format(szQuery, 512, sql_selectPlayerJumpBhop, g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_viewBhop2RecordCallback, szQuery, client,DBPrio_Low);
}

public db_viewDropBhopRecord2(client)
{
	decl String:szQuery[512];
	if (!IsValidClient(client))
		return;
	Format(szQuery, 512, sql_selectPlayerJumpDropBhop, g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_viewDropBhop2RecordCallback, szQuery, client,DBPrio_Low);
}

public db_viewCountJumpRecord2(client)
{
	decl String:szQuery[512];
	if (!IsValidClient(client))
		return;
	Format(szQuery, 512, sql_selectPlayerJumpCountJump, g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_viewCountJump2RecordCallback, szQuery, client,DBPrio_Low);
}

public SQL_viewCountJump2RecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		decl String:szQuery[512];
		decl String:szName[MAX_NAME_LENGTH];
		decl String:szSteamId[32];
		SQL_FetchString(hndl, 0, szSteamId, 32);	
		SQL_FetchString(hndl, 1, szName, MAX_NAME_LENGTH);				
		new Handle:pack = CreateDataPack();
		WritePackCell(pack, client);
		WritePackString(pack, szName);		
		Format(szQuery, 512, sql_selectPlayerRankCountJump, szSteamId);
		SQL_TQuery(g_hDb, SQL_viewCountJump2RecordCallback2, szQuery, pack,DBPrio_Low);
	}
}

public SQL_viewDropBhop2RecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		decl String:szQuery[512];
		decl String:szName[MAX_NAME_LENGTH];
		decl String:szSteamId[32];
		SQL_FetchString(hndl, 0, szSteamId, 32);	
		SQL_FetchString(hndl, 1, szName, MAX_NAME_LENGTH);				
		new Handle:pack = CreateDataPack();
		WritePackCell(pack, client);
		WritePackString(pack, szName);		
		Format(szQuery, 512, sql_selectPlayerRankDropBhop, szSteamId);
		SQL_TQuery(g_hDb, SQL_viewDropBhop2RecordCallback2, szQuery, pack,DBPrio_Low);
	}
}

public SQL_viewBhop2RecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		decl String:szQuery[512];
		decl String:szName[MAX_NAME_LENGTH];
		decl String:szSteamId[32];
		SQL_FetchString(hndl, 0, szSteamId, 32);	
		SQL_FetchString(hndl, 1, szName, MAX_NAME_LENGTH);				
		new Handle:pack = CreateDataPack();
		WritePackCell(pack, client);
		WritePackString(pack, szName);		
		Format(szQuery, 512, sql_selectPlayerRankBhop, szSteamId);
		SQL_TQuery(g_hDb, SQL_viewBhop2RecordCallback2, szQuery, pack,DBPrio_Low);
	}
}

public db_CalculatePlayerCount()
{
	decl String:szQuery[255];
	Format(szQuery, 255, sql_CountRankedPlayers);      
	SQL_TQuery(g_hDb, sql_CountRankedPlayersCallback, szQuery,DBPrio_Low);

	db_CalculatePlayersCountGreater0();
}

public db_CalculatePlayersCountGreater0()
{
	decl String:szQuery[255];
	Format(szQuery, 255, sql_CountRankedPlayers2);      
	SQL_TQuery(g_hDb, sql_CountRankedPlayers2Callback, szQuery,DBPrio_Low);
}



public sql_CountRankedPlayersCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_pr_AllPlayers = SQL_FetchInt(hndl, 0);
	}
	else
		g_pr_AllPlayers=1;	
}

public sql_CountRankedPlayers2Callback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_pr_RankedPlayers = SQL_FetchInt(hndl, 0);
	}
	else
		g_pr_RankedPlayers=0;	
}


public SQL_viewBhop2RecordCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		decl String:szName[MAX_NAME_LENGTH];
		new rank = SQL_GetRowCount(hndl);
		new Handle:pack = data;
		ResetPack(pack);
		new client = ReadPackCell(pack);		
		ReadPackString(pack, szName, MAX_NAME_LENGTH);
		CloseHandle(pack);
		if (rank < 21 && rank < g_js_BhopRank[client])
		{
			if (rank == 1)
				PlayOwnageSound(client);
			g_js_BhopRank[client] = rank;
			for(new i = 1; i <= GetMaxClients(); i++) 
			{ 
				if(IsValidClient(i) && !IsFakeClient(i)) 
				{ 					
					PrintToChat(i, "%t", "Jumpstats_BhopTop", MOSSGREEN, WHITE, YELLOW, szName, rank, g_js_fPersonal_Bhop_Record[client]);
					PrintToConsole(i, "[KZ] %s is now #%i in the Bunnyhop Top 20! [%.3f units]", szName, rank, g_js_fPersonal_Bhop_Record[client]);
				}
			}
			g_pr_showmsg[client]=true;
			CalculatePlayerRank(client);
		}
	}
}

public SQL_viewDropBhop2RecordCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		decl String:szName[MAX_NAME_LENGTH];
		new rank = SQL_GetRowCount(hndl);
		new Handle:pack = data;
		ResetPack(pack);
		new client = ReadPackCell(pack);
		ReadPackString(pack, szName, MAX_NAME_LENGTH);	
		CloseHandle(pack);
		if (rank < 21 && rank < g_js_DropBhopRank[client])
		{
			if (rank == 1)
				PlayOwnageSound(client);
			g_js_DropBhopRank[client] = rank;
			for(new i = 1; i <= GetMaxClients(); i++) 
			{ 
				if(IsValidClient(i) && !IsFakeClient(i)) 
				{ 			
					PrintToChat(i, "%t", "Jumpstats_DropBhopTop", MOSSGREEN, WHITE, YELLOW, szName, rank, g_js_fPersonal_DropBhop_Record[client]);
					PrintToConsole(i, "[KZ] %s is now #%i in the Drop-Bunnyhop Top 20! [%.3f units]", szName, rank, g_js_fPersonal_DropBhop_Record[client]);
				}
			}
			g_pr_showmsg[client]=true;
			CalculatePlayerRank(client);
		}
	}
}

public SQL_viewCountJump2RecordCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		decl String:szName[MAX_NAME_LENGTH];
		new rank = SQL_GetRowCount(hndl);
		new Handle:pack = data;
		ResetPack(pack);
		new client = ReadPackCell(pack);
		ReadPackString(pack, szName, MAX_NAME_LENGTH);	
		CloseHandle(pack);
		if (rank < 21 && rank < g_js_CJRank[client])
		{
			if (rank == 1)
				PlayOwnageSound(client);
			g_js_CJRank[client] = rank;
			for(new i = 1; i <= GetMaxClients(); i++) 
			{ 
				if(IsValidClient(i) && !IsFakeClient(i)) 
				{ 			
					PrintToChat(i, "%t", "Jumpstats_CountJumpTop", MOSSGREEN, WHITE, YELLOW, szName, rank, g_js_fPersonal_CJ_Record[client]);
					PrintToConsole(i, "[KZ] %s is now #%i in the CountJump Top 20! [%.3f units]", szName, rank, g_js_fPersonal_CJ_Record[client]);
				}
			}
			g_pr_showmsg[client]=true;
			CalculatePlayerRank(client);
		}
	}
}

public db_viewMultiBhopRecord2(client)
{
	decl String:szQuery[512];
	if (!IsValidClient(client))
		return;
	Format(szQuery, 512, sql_selectPlayerJumpMultiBhop, g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_viewMultiBhop2RecordCallback, szQuery, client,DBPrio_Low);
}

public SQL_viewMultiBhop2RecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		decl String:szQuery[512];
		decl String:szName[MAX_NAME_LENGTH];
		decl String:szSteamId[32];
		SQL_FetchString(hndl, 0, szSteamId, MAX_NAME_LENGTH);	
		SQL_FetchString(hndl, 1, szName, MAX_NAME_LENGTH);				
		new Handle:pack = CreateDataPack();
		WritePackCell(pack, client);
		WritePackString(pack, szName);		
		Format(szQuery, 512, sql_selectPlayerRankMultiBhop, szSteamId);
		SQL_TQuery(g_hDb, SQL_viewMultiBhop2RecordCallback2, szQuery, pack,DBPrio_Low);
	}
}

public SQL_viewMultiBhop2RecordCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		decl String:szName[MAX_NAME_LENGTH];
		new rank = SQL_GetRowCount(hndl);
		new Handle:pack = data;
		ResetPack(pack);
		new client = ReadPackCell(pack);
		ReadPackString(pack, szName, MAX_NAME_LENGTH);
		CloseHandle(pack);
		if (rank < 21 && rank < g_js_MultiBhopRank[client])
		{
			if (rank == 1)
				PlayOwnageSound(client);
			g_js_MultiBhopRank[client] = rank;
			for(new i = 1; i <= GetMaxClients(); i++) 
			{ 
				if(IsValidClient(i) && !IsFakeClient(i)) 
				{ 					
					PrintToChat(i, "%t", "Jumpstats_MultiBhopTop", MOSSGREEN, WHITE, YELLOW, szName, rank, g_js_fPersonal_MultiBhop_Record[client]);
					PrintToConsole(i, "[KZ] %s is now #%i in the Multi-Bunnyhop Top 20! [%.3f units]", szName, rank, g_js_fPersonal_MultiBhop_Record[client]);
				}
			}
			g_pr_showmsg[client]=true;
			CalculatePlayerRank(client);
		}
	}
}

public db_viewLjRecord2(client)
{
	decl String:szQuery[512];
	if (!IsValidClient(client))
		return;
	Format(szQuery, 512, sql_selectPlayerJumpLJ, g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_viewLj2RecordCallback, szQuery, client,DBPrio_Low);
}

public db_viewLadderJumpRecord2(client)
{
	decl String:szQuery[512];
	if (!IsValidClient(client))
		return;
	Format(szQuery, 512, sql_selectPlayerJumpLadderJump, g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_viewLadderJump2RecordCallback, szQuery, client,DBPrio_Low);
}

public db_viewLjBlockRecord2(client)
{
	decl String:szQuery[512];
	if (!IsValidClient(client))
		return;
	Format(szQuery, 512, sql_selectPlayerJumpLJBlock, g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_viewLjBlock2RecordCallback, szQuery, client,DBPrio_Low);
}

public SQL_viewLjBlock2RecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		decl String:szQuery[512];
		decl String:szName[MAX_NAME_LENGTH];
		decl String:szSteamId[32];
		SQL_FetchString(hndl, 0, szSteamId, MAX_NAME_LENGTH);
		SQL_FetchString(hndl, 1, szName, MAX_NAME_LENGTH);	
		new Handle:pack = CreateDataPack();
		WritePackCell(pack, client);
		WritePackString(pack, szName);		
		Format(szQuery, 512, sql_selectPlayerRankLjBlock, szSteamId);
		SQL_TQuery(g_hDb, SQL_viewLjBlock2RecordCallback2, szQuery, pack,DBPrio_Low);
	}
}

public SQL_viewLadderJump2RecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		decl String:szQuery[512];
		decl String:szName[MAX_NAME_LENGTH];
		decl String:szSteamId[32];
		SQL_FetchString(hndl, 0, szSteamId, MAX_NAME_LENGTH);
		SQL_FetchString(hndl, 1, szName, MAX_NAME_LENGTH);	
		new Handle:pack = CreateDataPack();
		WritePackCell(pack, client);
		WritePackString(pack, szName);		
		Format(szQuery, 512, sql_selectPlayerRankLadderJump, szSteamId);
		SQL_TQuery(g_hDb, SQL_viewLadderJump2RecordCallback2, szQuery, pack,DBPrio_Low);
	}
}

public SQL_viewLj2RecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		decl String:szQuery[512];
		decl String:szName[MAX_NAME_LENGTH];
		decl String:szSteamId[32];
		SQL_FetchString(hndl, 0, szSteamId, MAX_NAME_LENGTH);
		SQL_FetchString(hndl, 1, szName, MAX_NAME_LENGTH);	
		new Handle:pack = CreateDataPack();
		WritePackCell(pack, client);
		WritePackString(pack, szName);		
		Format(szQuery, 512, sql_selectPlayerRankLj, szSteamId);
		SQL_TQuery(g_hDb, SQL_viewLj2RecordCallback2, szQuery, pack,DBPrio_Low);
	}
}

public SQL_viewLjBlock2RecordCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		decl String:szName[MAX_NAME_LENGTH];
		new rank = SQL_GetRowCount(hndl);
		new Handle:pack = data;
		ResetPack(pack);
		new client = ReadPackCell(pack);
		ReadPackString(pack, szName, MAX_NAME_LENGTH);
		CloseHandle(pack);
			
		if (rank < 21 && rank < g_js_LjBlockRank[client])
		{		
			if (rank == 1)
				PlayOwnageSound(client);
			g_js_LjBlockRank[client] = rank;
			for(new i = 1; i <= GetMaxClients(); i++) 
			{ 
				if(IsValidClient(i) && !IsFakeClient(i)) 
				{ 		
					PrintToChat(i, "%t", "Jumpstats_LjBlockTop", MOSSGREEN, WHITE, YELLOW, szName, rank, g_js_Personal_LjBlock_Record[client],g_js_fPersonal_LjBlockRecord_Dist[client]);
					PrintToConsole(i, "[KZ] %s is now #%i in the Longjump 20! [%i units block/%.3f units jump]", szName, rank, g_js_Personal_LjBlock_Record[client],g_js_fPersonal_LjBlockRecord_Dist[client]);
				}
			}
			g_pr_showmsg[client] = true;
			CalculatePlayerRank(client);		
		}
	}
}

public SQL_viewLj2RecordCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		decl String:szName[MAX_NAME_LENGTH];
		new rank = SQL_GetRowCount(hndl);
		new Handle:pack = data;
		ResetPack(pack);
		new client = ReadPackCell(pack);
		ReadPackString(pack, szName, MAX_NAME_LENGTH);
		CloseHandle(pack);
			
		if (rank < 21 && rank < g_js_LjRank[client])
		{		
			if (rank == 1)
				PlayOwnageSound(client);		
			g_js_LjRank[client] = rank;
			for(new i = 1; i <= GetMaxClients(); i++) 
			{ 
				if(IsValidClient(i) && !IsFakeClient(i)) 
				{ 		
					PrintToChat(i, "%t", "Jumpstats_LjTop", MOSSGREEN, WHITE, YELLOW, szName, rank, g_js_fPersonal_Lj_Record[client]);
					PrintToConsole(i, "[KZ] %s is now #%i in the Longjump 20! [%.3f units]", szName, rank, g_js_fPersonal_Lj_Record[client]);
				}
			}
			g_pr_showmsg[client] = true;
			CalculatePlayerRank(client);		
		}
	}
}

public SQL_viewLadderJump2RecordCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		decl String:szName[MAX_NAME_LENGTH];
		new rank = SQL_GetRowCount(hndl);
		new Handle:pack = data;
		ResetPack(pack);
		new client = ReadPackCell(pack);
		ReadPackString(pack, szName, MAX_NAME_LENGTH);
		CloseHandle(pack);
			
		if (rank < 21 && rank < g_js_LadderJumpRank[client])
		{		
			if (rank == 1)
				PlayOwnageSound(client);		
			g_js_LadderJumpRank[client] = rank;
			for(new i = 1; i <= GetMaxClients(); i++) 
			{ 
				if(IsValidClient(i) && !IsFakeClient(i)) 
				{ 		
					PrintToChat(i, "%t", "Jumpstats_LadderJumpTop", MOSSGREEN, WHITE, YELLOW, szName, rank, g_js_fPersonal_LadderJump_Record[client]);
					PrintToConsole(i, "[KZ] %s is now #%i in the Ladderjump 20! [%.3f units]", szName, rank, g_js_fPersonal_LadderJump_Record[client]);
				}
			}
			g_pr_showmsg[client] = true;
			CalculatePlayerRank(client);		
		}
	}
}

public db_ClearLatestRecords()
{
	if(g_DbType == MYSQL)
		SQL_TQuery(g_hDb, SQL_CheckCallback, "DELETE FROM LatestRecords WHERE date < NOW() - INTERVAL 1 WEEK", DBPrio_Low);
	else
		SQL_TQuery(g_hDb, SQL_CheckCallback, "DELETE FROM LatestRecords WHERE date <= date('now','-7 day')", DBPrio_Low);
}


public db_viewWjRecord2(client)
{
	decl String:szQuery[512];
	if (!IsValidClient(client))
		return;
	Format(szQuery, 512, sql_selectPlayerJumpWJ, g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_viewWj2RecordCallback, szQuery, client,DBPrio_Low);
}

public SQL_viewWj2RecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		decl String:szQuery[512];
		decl String:szName[MAX_NAME_LENGTH];
		decl String:szSteamId[32];
		SQL_FetchString(hndl, 0, szSteamId, MAX_NAME_LENGTH);
		SQL_FetchString(hndl, 1, szName, MAX_NAME_LENGTH);	
		new Handle:pack = CreateDataPack();
		WritePackCell(pack, client);
		WritePackString(pack, szName);		
		Format(szQuery, 512, sql_selectPlayerRankWJ, szSteamId);
		SQL_TQuery(g_hDb, SQL_viewWj2RecordCallback2, szQuery, pack,DBPrio_Low);
	}
}

public SQL_viewWj2RecordCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		decl String:szName[MAX_NAME_LENGTH];
		new rank = SQL_GetRowCount(hndl);
		new Handle:pack = data;
		ResetPack(pack);
		new client = ReadPackCell(pack);
		ReadPackString(pack, szName, MAX_NAME_LENGTH);
		CloseHandle(pack);
		
		if (rank < 21 && rank < g_js_WjRank[client])
		{			
			if (rank == 1)
				PlayOwnageSound(client);
			g_js_WjRank[client] = rank;
			for(new i = 1; i <= GetMaxClients(); i++) 
			{ 
				if(IsValidClient(i) && !IsFakeClient(i)) 
				{ 		
					PrintToChat(i, "%t", "Jumpstats_WjTop", MOSSGREEN, WHITE, YELLOW, szName, rank, g_js_fPersonal_Wj_Record[client]);
					PrintToConsole(i, "[KZ] %s is now #%i in the Weirdjump 20! [%.3f units]", szName, rank, g_js_fPersonal_Wj_Record[client]);
				}
			}
			g_pr_showmsg[client] = true;
			CalculatePlayerRank(client);		
		}
	}
}

public db_viewUnfinishedMaps(client, String:szSteamId[32])
{
	decl String:szQuery[1024];       
	new String:map[128];
	for (new i = 0; i < GetArraySize(g_MapList); i++)
	{
		GetArrayString(g_MapList, i, map, sizeof(map));
		Format(szQuery, 1024, sql_selectRecord, szSteamId, map);  
		new Handle:pack = CreateDataPack();			
		WritePackString(pack, map);
		WritePackCell(pack, client);
		SQL_TQuery(g_hDb, db_viewUnfinishedMapsCallback, szQuery, pack,DBPrio_Low);
	}	
	if (IsValidClient(client))
	{
		PrintToConsole(client," ");
		PrintToConsole(client,"-------------");
		PrintToConsole(client,"Unfinished Maps");
		PrintToConsole(client,"SteamID: %s", szSteamId);
		PrintToConsole(client,"-------------");
		PrintToConsole(client," ");
		PrintToChat(client, "%t", "ConsoleOutput", LIMEGREEN,WHITE); 	
		ProfileMenu(client, -1);
	}
}

public db_viewUnfinishedMapsCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new Handle:pack = data;
	ResetPack(pack);
	decl String:szMap[128];
	ReadPackString(pack, szMap, 128);
	new client = ReadPackCell(pack);
	new Float:tptime;
	new Float:protime;
	CloseHandle(pack);
	new String:prefix[2][32];
	ExplodeString(szMap, "_", prefix, 2, 32);		
		
	
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{	
		tptime = SQL_FetchFloat(hndl, 1);
		protime = SQL_FetchFloat(hndl, 2);
		if (tptime <= 0.0 && !StrEqual("kzpro",prefix[0]))
			PrintToConsole(client, "%s (TP)",szMap);
		if (protime <= 0.0)
			PrintToConsole(client, "%s (PRO)",szMap);
	}
	else
	{
		if (IsValidClient(client))
		{
			if (!StrEqual("kzpro",prefix[0]))
				PrintToConsole(client, "%s (PRO)\n%s (TP)",szMap,szMap);
			else	
				PrintToConsole(client, "%s (PRO)",szMap);
		}
	}
}

public db_viewChallengeHistory(client, String:szSteamId[32])
{
	decl String:szQuery[1024];       
	Format(szQuery, 1024, sql_selectChallenges2, szSteamId, szSteamId);  
	if ((StrContains(szSteamId, "STEAM_") != -1) && IsClientInGame(client))
	{
		new Handle:pack = CreateDataPack();			
		WritePackString(pack, szSteamId);
		WritePackString(pack, g_szProfileName[client]);
		WritePackCell(pack, client);		
		SQL_TQuery(g_hDb, sql_selectChallengesCallback, szQuery, pack,DBPrio_Low);
	}
	else
		if (IsClientInGame(client))
			PrintToChat(client,"[%cKZ%c] Invalid SteamID found.",RED,WHITE);
	ProfileMenu(client, -1);
}

public sql_selectChallengesCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	//decl.
	new bet, cp_allowed, client;
	new bHeader=false;
	decl String:szMapName[32];
	decl String:szSteamId[32];
	decl String:szSteamId2[32];	
	decl String:szSteamIdTarget[32];
	decl String:szNameTarget[32];	
	decl String:szDate[64];	
	
	//get pack data
	new Handle:pack = data;
	ResetPack(pack);
	ReadPackString(pack, szSteamIdTarget, 32);
	ReadPackString(pack, szNameTarget, 32);
	client = ReadPackCell(pack);
	CloseHandle(pack);
	
	if(SQL_HasResultSet(hndl))
	{	
		//fetch rows
		while (SQL_FetchRow(hndl))
		{
			//get row data
			SQL_FetchString(hndl, 0, szSteamId, 32);
			SQL_FetchString(hndl, 1, szSteamId2, 32);
			bet = SQL_FetchInt(hndl, 2);
			cp_allowed = SQL_FetchInt(hndl, 3);
			SQL_FetchString(hndl, 4, szMapName, 32);					
			SQL_FetchString(hndl, 5, szDate, 64);	
			
			//header
			if (!bHeader)
			{
				PrintToConsole(client," ");
				PrintToConsole(client,"-------------");
				PrintToConsole(client,"Challenge history");
				PrintToConsole(client,"Player: %s", szNameTarget);
				PrintToConsole(client,"SteamID: %s", szSteamIdTarget);
				PrintToConsole(client,"-------------");
				PrintToConsole(client," ");
				bHeader=true;
				PrintToChat(client, "%t", "ConsoleOutput", LIMEGREEN,WHITE); 	
			}
			
			//won/loss?
			new WinnerTarget=0;
			if (StrEqual(szSteamId,szSteamIdTarget))
				WinnerTarget=1;
			
			//create pack
			new Handle:pack2 = CreateDataPack();		
			WritePackCell(pack2, client);		
			WritePackCell(pack2, WinnerTarget);	
			WritePackString(pack2, szNameTarget);
			WritePackString(pack2, szSteamId);
			WritePackString(pack2, szSteamId2);
			WritePackString(pack2, szMapName);	
			WritePackString(pack2, szDate);	
			WritePackCell(pack2, bet);		
			WritePackCell(pack2, cp_allowed);		
			
			//Query
			decl String:szQuery[512];
			if (WinnerTarget==1)
				Format(szQuery, 512, "select name from playerrank where steamid = '%s'", szSteamId2);
			else
				Format(szQuery, 512, "select name from playerrank where steamid = '%s'", szSteamId);
			SQL_TQuery(g_hDb, sql_selectChallengesCallback2, szQuery, pack2,DBPrio_Low);						
		}
	}
	if(!bHeader)
	{
		ProfileMenu(client, -1);
		PrintToChat(client, "[%cKZ%c] No challenges found.",MOSSGREEN,WHITE);
	}
}

public sql_selectChallengesCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	//decl.
	decl String:szNameTarget[32];
	decl String:szNameOpponent[32];
	decl String:szSteamId[32];
	decl String:szCps[32];
	decl String:szResult[32];
	decl String:szSteamId2[32];
	decl String:szMapName[32];
	decl String:szDate[64];
	new client, bet, WinnerTarget, cp_allowed;
	
	//get pack data
	new Handle:pack = data;
	ResetPack(pack);	
	client = ReadPackCell(pack);
	WinnerTarget = ReadPackCell(pack);
	ReadPackString(pack, szNameTarget, 32);
	ReadPackString(pack, szSteamId, 32);
	ReadPackString(pack, szSteamId2, 32);
	ReadPackString(pack, szMapName, 32);
	ReadPackString(pack, szDate, 64);	
	bet = ReadPackCell(pack);
	cp_allowed = ReadPackCell(pack);
	CloseHandle(pack);
	
	//default name=steamid
	if (WinnerTarget==1)
		Format(szNameOpponent, 32, "%s", szSteamId2);
	else
		Format(szNameOpponent, 32, "%s", szSteamId);
	
	//query result
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		SQL_FetchString(hndl, 0, szNameOpponent, 32);
	
	//format..
	if (WinnerTarget==1)
		Format(szResult, 32, "WIN");
	else
		Format(szResult, 32, "LOSS");
	
	if (cp_allowed==1)
		Format(szCps, 32, "yes");
	else
		Format(szCps, 32, "no");
		
	//console msg
	if (IsClientInGame(client))
		PrintToConsole(client,"(%s) %s vs. %s, map: %s, bet: %i, checkpoints: %s, result: %s", szDate, szNameTarget, szNameOpponent, szMapName, bet, szCps, szResult);
}

public db_viewAllRecords(client, String:szSteamId[32])
{
	decl String:szQuery[1024];       
	Format(szQuery, 1024, sql_selectPersonalAllRecords, szSteamId, szSteamId);  
	if ((StrContains(szSteamId, "STEAM_") != -1))
		SQL_TQuery(g_hDb, SQL_ViewAllRecordsCallback, szQuery, client,DBPrio_Low);
	else
		if (IsClientInGame(client))
			PrintToChat(client,"[%cKZ%c] Invalid SteamID found.",RED,WHITE);
	ProfileMenu(client, -1);
}


public SQL_ViewAllRecordsCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	new bHeader=false;
	decl String:szUncMaps[1024];
	new mapcount=0;
	decl String:szName[MAX_NAME_LENGTH];
	decl String:szSteamId[32];
	if(SQL_HasResultSet(hndl))
	{	
		new Float:time;
		new teleports;
		decl String:szMapName[128];		
		decl String:szMapName2[128];
		decl String:szRecord_type[4];
		decl String:szQuery[1024];
		Format(szUncMaps,sizeof(szUncMaps),"");
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, szName, MAX_NAME_LENGTH);
			SQL_FetchString(hndl, 1, szSteamId, MAX_NAME_LENGTH);
			SQL_FetchString(hndl, 2, szMapName, 128);	
			

			time = SQL_FetchFloat(hndl, 3);
			teleports = SQL_FetchInt(hndl, 4);
			if (teleports > 0)
				Format(szRecord_type, 4, "TP");
				else
					Format(szRecord_type, 4, "PRO");	
			new mapfound=false;
			
			//map in rotation?
			for (new i = 0; i < GetArraySize(g_MapList); i++)
			{
				GetArrayString(g_MapList, i, szMapName2, sizeof(szMapName2));
				if (StrEqual(szMapName2, szMapName, false))
				{
					if (!bHeader)
					{
						PrintToConsole(client," ");
						PrintToConsole(client,"-------------");
						PrintToConsole(client,"Finished Maps");
						PrintToConsole(client,"Player: %s", szName);
						PrintToConsole(client,"SteamID: %s", szSteamId);
						PrintToConsole(client,"-------------");
						PrintToConsole(client," ");
						bHeader=true;
						PrintToChat(client, "%t", "ConsoleOutput", LIMEGREEN,WHITE); 	
					}
					new Handle:pack = CreateDataPack();			
					WritePackString(pack, szName);
					WritePackString(pack, szSteamId);
					WritePackString(pack, szMapName);			
					WritePackString(pack, szRecord_type);		
					WritePackCell(pack, teleports);
					WritePackFloat(pack, time);
					WritePackCell(pack, client);
					
					if (teleports > 0)
					{
						Format(szQuery, 1024, sql_selectPlayerRankTime, szSteamId, szMapName, szMapName);
						SQL_TQuery(g_hDb, SQL_ViewAllRecordsCallback2, szQuery, pack,DBPrio_Low);
					}
					else
					{	
						Format(szQuery, 1024, sql_selectPlayerRankProTime, szSteamId, szMapName, szMapName);
						SQL_TQuery(g_hDb, SQL_ViewAllRecordsCallback2, szQuery, pack,DBPrio_Low);
					}
					mapfound=true;
					continue;
				}
			}
			if (!mapfound)
			{
				mapcount++;
				if (!mapfound && mapcount==1)
				{
					if (teleports>0)
						Format(szUncMaps,sizeof(szUncMaps),"%s (TP)",szMapName);
					else
						Format(szUncMaps,sizeof(szUncMaps),"%s (Pro)",szMapName);
				}
				else
				{
					if (!mapfound && mapcount>1)
					{
						if (teleports>0)
							Format(szUncMaps,sizeof(szUncMaps),"%s, %s (TP)",szUncMaps, szMapName);
						else
							Format(szUncMaps,sizeof(szUncMaps),"%s, %s (Pro)",szUncMaps, szMapName);
					}
				}
			}
		}
	}
	if (!StrEqual(szUncMaps,""))
	{		
		if(!bHeader)
		{
			PrintToChat(client, "%t", "ConsoleOutput", LIMEGREEN,WHITE); 
			PrintToConsole(client," ");
			PrintToConsole(client,"-------------");
			PrintToConsole(client,"Finished Maps");
			PrintToConsole(client,"Player: %s", szName);
			PrintToConsole(client,"SteamID: %s", szSteamId);
			PrintToConsole(client,"-------------");
			PrintToConsole(client," ");		
		}
		PrintToConsole(client, "Times on maps which are not in the mapcycle.txt (TP and Pro records still count but you don't get points): %s", szUncMaps);
	}
	if(!bHeader && StrEqual(szUncMaps,""))
	{
		ProfileMenu(client, -1);
		PrintToChat(client, "%t", "PlayerHasNoMapRecords", LIMEGREEN,WHITE,g_szProfileName[client]);
	}
}

public SQL_ViewAllRecordsCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		decl String:szQuery[512];
		new rank = SQL_GetRowCount(hndl);
		new Handle:pack = data;
		WritePackCell(pack, rank);
		ResetPack(pack);
		decl String:szName[MAX_NAME_LENGTH];
		ReadPackString(pack, szName, MAX_NAME_LENGTH);
		decl String:szSteamId[32];
		ReadPackString(pack, szSteamId, 32);
		decl String:szMapName[128];
		ReadPackString(pack, szMapName, 128);
		decl String:szRecord_type[4];
		ReadPackString(pack, szRecord_type, 4);	
		new teleports = ReadPackCell(pack);
		if (teleports > 0)
		{
			Format(szQuery, 512, sql_selectPlayerCount, szMapName);
			SQL_TQuery(g_hDb, SQL_ViewAllRecordsCallback3, szQuery, pack,DBPrio_Low);
		}
		else
		{
			Format(szQuery, 512, sql_selectPlayerProCount, szMapName);
			SQL_TQuery(g_hDb, SQL_ViewAllRecordsCallback3, szQuery, pack,DBPrio_Low);
		}
		
	}
}

public SQL_ViewAllRecordsCallback3(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	//if there is a player record
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		new count = SQL_GetRowCount(hndl);
		new Handle:pack = data;
		ResetPack(pack);
		
		decl String:szName[MAX_NAME_LENGTH];
		ReadPackString(pack, szName, MAX_NAME_LENGTH);
		decl String:szSteamId[32];
		ReadPackString(pack, szSteamId, 32);
		decl String:szMapName[128];
		ReadPackString(pack, szMapName, 128);	
		decl String:szRecord_type[4];
		decl String:szTime[32];
		ReadPackString(pack, szRecord_type, 4);				
		new teleports = ReadPackCell(pack);
		new Float:time = ReadPackFloat(pack);	
		new client = ReadPackCell(pack);
		new rank = ReadPackCell(pack);
		
		CloseHandle(pack);
		FormatTimeFloat(client,time,3,szTime,sizeof(szTime));
		if (IsValidClient(client))
			PrintToConsole(client,"%s, Time: %s (%s), Teleports: %i, Rank: %i/%i", szMapName, szTime, szRecord_type, teleports,rank,count);
	}
}	
		
public db_viewPlayerRank(client, String:szSteamId[32])
{
	decl String:szQuery[512];  
	Format(g_pr_szrank[client], 512, "");	
	Format(szQuery, 512, sql_selectRankedPlayer, szSteamId);
	SQL_TQuery(g_hDb, SQL_ViewRankedPlayerCallback, szQuery, client,DBPrio_Low);
}

public SQL_ViewRankedPlayerCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{	
		decl String:szQuery[512];
		decl String:szName[MAX_NAME_LENGTH];
		decl String:szCountry[100];
		decl String:szLastSeen[100];
		decl String:szSteamId[32];
		new finishedmapstp;
		new finishedmapspro;
		new points;
		g_TpRecordCount[client] = 0;	
		g_ProRecordCount[client] = 0;	
		
		//get the result
		SQL_FetchString(hndl, 0, szSteamId, 32);
		SQL_FetchString(hndl, 1, szName, MAX_NAME_LENGTH);
		points = SQL_FetchInt(hndl, 2);
		finishedmapstp = SQL_FetchInt(hndl, 3);      
		finishedmapspro = SQL_FetchInt(hndl, 4);
		SQL_FetchString(hndl, 6, szCountry, 100);
		SQL_FetchString(hndl, 7, szLastSeen, 100);
		new Handle:pack_pr = CreateDataPack();	
		WritePackString(pack_pr, szName);
		WritePackString(pack_pr, szSteamId);	
		WritePackCell(pack_pr, client);		
		WritePackCell(pack_pr, points);
		WritePackCell(pack_pr, finishedmapstp);
		WritePackCell(pack_pr, finishedmapspro);
		WritePackString(pack_pr, szCountry);	
		WritePackString(pack_pr, szLastSeen);	
		Format(szQuery, 512, sql_selectRankedPlayersRank, szSteamId);
		SQL_TQuery(g_hDb, SQL_ViewRankedPlayerCallback2, szQuery, pack_pr,DBPrio_Low);
	}
}

public db_GetPlayerRank(client)
{
	decl String:szQuery[512];
	Format(szQuery, 512, sql_selectRankedPlayersRank, g_szSteamID[client]);
	SQL_TQuery(g_hDb, sql_selectRankedPlayersRankCallback, szQuery, client,DBPrio_Low);		
}

public sql_selectRankedPlayersRankCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		g_PlayerRank[client] = SQL_GetRowCount(hndl);
}

public SQL_ViewRankedPlayerCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		decl String:szQuery[512];
		decl String:szSteamId[32];
		decl String:szName[MAX_NAME_LENGTH];
		new rank = SQL_GetRowCount(hndl);
		new Handle:pack_pr = data;
		WritePackCell(pack_pr, rank);
		ResetPack(pack_pr);	        
		ReadPackString(pack_pr, szName, MAX_NAME_LENGTH);
		ReadPackString(pack_pr, szSteamId, 32);	
		Format(szQuery, 512, sql_selectTpRecordCount, szSteamId);
		SQL_TQuery(g_hDb, SQL_ViewRankedPlayerCallback3, szQuery, pack_pr,DBPrio_Low);	
	}
}

public SQL_ViewRankedPlayerCallback3(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new Handle:pack_pr = data;
	decl String:szQuery[512];
	decl String:szSteamId[32];
	decl String:szName[MAX_NAME_LENGTH];
	ResetPack(pack_pr);	        
	ReadPackString(pack_pr, szName, MAX_NAME_LENGTH);
	ReadPackString(pack_pr, szSteamId, 32);	
	new client = ReadPackCell(pack_pr);    
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) 
		g_TpRecordCount[client] = SQL_FetchInt(hndl, 1);	//pack full?´
	Format(szQuery, 512, sql_selectProRecordCount, szSteamId);
	SQL_TQuery(g_hDb, SQL_ViewRankedPlayerCallback4, szQuery, pack_pr,DBPrio_Low);		
}

public SQL_ViewRankedPlayerCallback4(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	decl String:szQuery[512];
	decl String:szSteamId[32];
	decl String:szName[MAX_NAME_LENGTH];
	new Handle:pack_pr = data;
	ResetPack(pack_pr);       
	ReadPackString(pack_pr, szName, MAX_NAME_LENGTH);
	ReadPackString(pack_pr, szSteamId, 32);		
	new client = ReadPackCell(pack_pr);  
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) 
		g_ProRecordCount[client] = SQL_FetchInt(hndl, 1);	//pack full?
	Format(szQuery, 512, sql_selectChallenges, szSteamId,szSteamId);
	SQL_TQuery(g_hDb, SQL_ViewRankedPlayerCallback5, szQuery, pack_pr,DBPrio_Low);		
}

public SQL_ViewRankedPlayerCallback5(Handle:owner, Handle:hndl, const String:error[], any:data)
{		
	decl String:szChallengesPoints[32];
	Format(szChallengesPoints, 32, "0p")
	decl String:szChallengesWinRatio[32];
	Format(szChallengesWinRatio, 32, "0")
	new Handle:pack_pr = data;
	decl String:szName[MAX_NAME_LENGTH];
	decl String:szSteamId[32];
	decl String:szSteamIdChallenge[32];
	decl String:szCountry[100];
	decl String:szLastSeen[100];
	decl String:szNextRank[32];
	decl String:szSkillGroup[32];
	ResetPack(pack_pr);     
	ReadPackString(pack_pr, szName, MAX_NAME_LENGTH);
	ReadPackString(pack_pr, szSteamId, 32);
	new client = ReadPackCell(pack_pr);       
	new points = ReadPackCell(pack_pr);
	new finishedmapstp = ReadPackCell(pack_pr);
	new finishedmapspro = ReadPackCell(pack_pr);  
	ReadPackString(pack_pr, szCountry, 100);	
	ReadPackString(pack_pr, szLastSeen, 100);	
	if (StrEqual(szLastSeen,""))
		Format(szLastSeen, 100, "Unknown");
	new rank = ReadPackCell(pack_pr);
	new tprecords = g_TpRecordCount[client];
	new prorecords = g_ProRecordCount[client];
	Format(g_szProfileSteamId[client], 32, "%s", szSteamId);
	Format(g_szProfileName[client], MAX_NAME_LENGTH, "%s", szName);
	new bool:master=false;
	new RankDifference;		   
	CloseHandle(pack_pr);	
	new bet;

	if (StrEqual(szSteamId, g_szSteamID[client]))
		g_PlayerRank[client] = rank;
		
	//get challenge results
	new challenges = 0;
	new challengeswon = 0;  
	new challengespoints = 0;  
	if(SQL_HasResultSet(hndl))
	{	
		challenges= SQL_GetRowCount(hndl);
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, szSteamIdChallenge, 32);
			bet = SQL_FetchInt(hndl, 2);
			if (StrEqual(szSteamIdChallenge,szSteamId))
			{
				challengespoints+= bet;
				challengeswon++;
			}
			else
			{
				challengespoints-= bet;
				challengeswon--;
			}
		}
	}
	
	if (!g_bChallengePoints)
		challengespoints = 0;
	
	if (challengespoints>0)
		Format(szChallengesPoints, 32, "+%ip",challengespoints);   
	else
		if (challengespoints <= 0 && g_bChallengePoints)
			Format(szChallengesPoints, 32, "%ip",challengespoints);	
		else
			if (challengespoints <= 0 && !g_bChallengePoints)
				Format(szChallengesPoints, 32, "0p (disabled)"); 		
	
	
	if (challengeswon>0)
		Format(szChallengesWinRatio, 32, "+%i",challengeswon);   
	else
		if (challengeswon<0)
			Format(szChallengesWinRatio, 32, "%i",challengeswon); 
	
	
	//profile not refreshed after removing maps?
	if (finishedmapstp > g_pr_MapCountTp)
		finishedmapstp=g_pr_MapCountTp;
	if (finishedmapspro > g_pr_MapCount)	
		finishedmapspro=g_pr_MapCount;
		
	if (points < g_pr_rank_Percentage[1])
	{
		Format(szSkillGroup, 32, "%s",g_szSkillGroups[0]);
		RankDifference = g_pr_rank_Percentage[1] - points;
		Format(szNextRank, 32, " (%s)",g_szSkillGroups[1]);
	}
	else
	if (g_pr_rank_Percentage[1] <= points && points < g_pr_rank_Percentage[2])
	{
		Format(szSkillGroup, 32, "%s",g_szSkillGroups[1]);
		RankDifference = g_pr_rank_Percentage[2] - points;
		Format(szNextRank, 32, " (%s)",g_szSkillGroups[2]);
	}
	else
	if (g_pr_rank_Percentage[2] <= points && points < g_pr_rank_Percentage[3])
	{
		Format(szSkillGroup, 32, "%s",g_szSkillGroups[2]);
		RankDifference = g_pr_rank_Percentage[3] - points;
		Format(szNextRank, 32, " (%s)",g_szSkillGroups[3]);
	}		   
	else
	if (g_pr_rank_Percentage[3] <= points && points < g_pr_rank_Percentage[4])
	{
		Format(szSkillGroup, 32, "%s",g_szSkillGroups[3]);
		RankDifference = g_pr_rank_Percentage[4] - points;
		Format(szNextRank, 32, " (%s)",g_szSkillGroups[4]);
	}                      
	else
	if (g_pr_rank_Percentage[4] <= points && points < g_pr_rank_Percentage[5])
	{
	   Format(szSkillGroup, 32, "%s",g_szSkillGroups[4]);
	   RankDifference = g_pr_rank_Percentage[5] - points;
	   Format(szNextRank, 32, " (%s)",g_szSkillGroups[5]);
	}                      
	else
	if (g_pr_rank_Percentage[5] <= points && points < g_pr_rank_Percentage[6])
	{
	   Format(szSkillGroup, 32, "%s",g_szSkillGroups[5]);
	   RankDifference = g_pr_rank_Percentage[6] - points;
	   Format(szNextRank, 32, " (%s)",g_szSkillGroups[6]);
	}
	else
	if (g_pr_rank_Percentage[6] <= points && points < g_pr_rank_Percentage[7])
	{
		Format(szSkillGroup, 32, "%s",g_szSkillGroups[6]);
		RankDifference = g_pr_rank_Percentage[7] - points;
		Format(szNextRank, 32, " (%s)",g_szSkillGroups[7]);
	}
	else
	if (g_pr_rank_Percentage[7] <= points && points < g_pr_rank_Percentage[8])
	{
		Format(szSkillGroup, 32, "%s",g_szSkillGroups[7]);    
		RankDifference = g_pr_rank_Percentage[8] - points;
		Format(szNextRank, 32, " (%s)",g_szSkillGroups[8]);
	}
	else
	if (points >= g_pr_rank_Percentage[8])
	{
		Format(szSkillGroup, 32, "%s",g_szSkillGroups[8]);    
		RankDifference = 0;
		Format(szNextRank, 32, "");
		master=true;
	}  
	
	decl String: szRank[32];
	if (rank > g_pr_RankedPlayers || points == 0)
		Format(szRank,32,"-");
	else
		Format(szRank,32,"%i", rank);
	
	decl String:szRanking[255];
	Format(szRanking, 255, "");			
	if (master==false)
	{	
		if (g_bPointSystem)
			Format(szRanking, 255,"Rank: %s/%i (Overall: %i)\nPoints: %ip (%s)\nNext skill group in: %ip%s\n", szRank,g_pr_RankedPlayers, g_pr_AllPlayers,points,szSkillGroup,RankDifference,szNextRank);
		if (g_bAllowCheckpoints || StrEqual(g_szMapPrefix[0],"kzpro"))
			Format(g_pr_szrank[client], 512, "%sPro times: %i/%i (records: %i)\nTP times: %i/%i (records: %i)\nPlayed challenges: %i\n▪ W/L Ratio: %s\n▪ W/L Points ratio: %s\n ",szRanking,finishedmapspro,g_pr_MapCount,prorecords,finishedmapstp,g_pr_MapCountTp,tprecords,challenges,szChallengesWinRatio,szChallengesPoints);                    
		else
			Format(g_pr_szrank[client], 512, "Rank: %s/%i (%i)\nPoints: %ip (%s)\nNext skill group in: %ip%s\nMaps completed: %i/%i (records: %i)\nPlayed challenges: %i\n▪ W/L Ratio: %s\n▪ W/L Points ratio: %s\n ", szRank,g_pr_RankedPlayers, g_pr_AllPlayers,points,szSkillGroup,RankDifference,szNextRank,finishedmapspro,g_pr_MapCount,prorecords,challenges,szChallengesWinRatio,szChallengesPoints);                    	
	}
	else
	{
		if (g_bPointSystem)
			Format(szRanking, 255,"Rank: %s/%i (Overall: %i)\nPoints: %ip (%s)\n", szRank,g_pr_RankedPlayers, g_pr_AllPlayers,points,szSkillGroup);
		if (g_bAllowCheckpoints || StrEqual(g_szMapPrefix[0],"kzpro"))
			Format(g_pr_szrank[client], 512, "%sPro times: %i/%i (records: %i)\nTP times: %i/%i (records: %i)\nPlayed challenges: %i\n▪ W/L Ratio: %s\n▪ W/L points ratio: %s\n ", szRanking,finishedmapspro,g_pr_MapCount,prorecords,finishedmapstp,g_pr_MapCountTp,tprecords,challenges,szChallengesWinRatio,szChallengesPoints);                    
		else
			Format(g_pr_szrank[client], 512, "Rank: %s/%i (%i)\nPoints: %ip (%s)\nMaps completed: %i/%i (records: %i)\nPlayed challenges: %i\n▪ W/L Ratio: %s\n▪ W/L points ratio: %s\n ", szRank,g_pr_RankedPlayers, g_pr_AllPlayers,points,szSkillGroup,finishedmapspro,g_pr_MapCount,prorecords,challenges,szChallengesWinRatio,szChallengesPoints);                    
		
	}
	new String:szID[32][2];
	ExplodeString(szSteamId,"_",szID,2,32);
	decl String:szTitle[1024];
	if (g_bCountry)
		Format(szTitle, 1024, "Player: %s\nSteamID: %s\nNationality: %s \nLast seen: %s\n \n%s\n",  szName,szID[1],szCountry,szLastSeen,g_pr_szrank[client]);		
	else
		Format(szTitle, 1024, "Player: %s\nSteamID: %s\nLast seen: %s\n \n%s\n",  szName,szID[1],szLastSeen,g_pr_szrank[client]);				
			
	new Handle:menu = CreateMenu(ProfileMenuHandler);
	SetMenuTitle(menu, szTitle);
	AddMenuItem(menu, "Current map time", "Current map time");
	if (g_bJumpStats)
		AddMenuItem(menu, "Jumpstats", "Jumpstats");
	else
		AddMenuItem(menu, "Jumpstats", "Jumpstats (disabled)",ITEMDRAW_DISABLED);
	AddMenuItem(menu, "Challenge history", "Challenge history");
	AddMenuItem(menu, "Finished maps", "Finished maps");
	AddMenuItem(menu, "Unfinished maps", "Unfinished maps");
	if (IsValidClient(client))
	{
		if(StrEqual(szSteamId,g_szSteamID[client]))
		{			
			if (g_bPointSystem)
				AddMenuItem(menu, "Refresh my profile", "Refresh my profile");
		}
	}	
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	g_bProfileSelected[client] = true;
	g_bClimbersMenuOpen[client]=false;
	g_bMenuOpen[client]=true;
}

public db_ViewLatestRecords(client)
{
	SQL_TQuery(g_hDb, sql_selectLatestRecordsCallback, sql_selectLatestRecords, client,DBPrio_Low);
}

public sql_selectLatestRecordsCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	decl String:szName[64];
	decl String:szMapName[64];
	decl String:szDate[64];
	decl String:szTime[32];
	new teleports;
	new Float: ftime;
	PrintToConsole(client, "----------------------------------------------------------------------------------------------------");
	PrintToConsole(client,"Last map records:");
	if(SQL_HasResultSet(hndl))
	{		
		new i = 1;
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, szName, 64);
			ftime = SQL_FetchFloat(hndl, 1); 
			FormatTimeFloat(client, ftime, 3,szTime,sizeof(szTime));
			teleports = SQL_FetchInt(hndl, 2); 
			SQL_FetchString(hndl, 3, szMapName, 64);
			SQL_FetchString(hndl, 4, szDate, 64);
			PrintToConsole(client,"%s: %s on %s - Time %s, TP's %i",szDate,szName, szMapName, szTime, teleports);
			i++;
		}
		if (i==1)
			PrintToConsole(client,"No records found.");	
	}
	else
		PrintToConsole(client,"No records found.");
	PrintToConsole(client, "----------------------------------------------------------------------------------------------------");
	PrintToChat(client, "[%cKZ%c] See console for output!", MOSSGREEN,WHITE);	
}

			
public db_InsertLatestRecords(String:szSteamID[32], String:szName[32], Float: FinalTime, Teleports)
{
	decl String:szQuery[512];       
	Format(szQuery, 512, sql_insertLatestRecords, szSteamID, szName, FinalTime, Teleports, g_szMapName); 
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery,DBPrio_Low);
}

public db_viewRecord(client, String:szSteamId[32], String:szMapName[128])
{
	decl String:szQuery[512];       
	Format(szQuery, 512, sql_selectPersonalRecords, szSteamId, szMapName);  
	SQL_TQuery(g_hDb, SQL_ViewRecordCallback, szQuery, client,DBPrio_Low);
}



public SQL_ViewRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;	
	g_bClimbersMenuOpen[client]=false;
	g_bMenuOpen[client] = true;	
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		
		decl String:szQuery[512];
		decl String:szMapName[128];
		decl String:szName[MAX_NAME_LENGTH];
		decl String:szSteamId[32];
		new Float:time;
		new Float:timepro;
		new teleports;
        
		//get the result
		SQL_FetchString(hndl, 0, szMapName, 128);
		SQL_FetchString(hndl, 1, szSteamId, MAX_NAME_LENGTH);
		SQL_FetchString(hndl, 2, szName, MAX_NAME_LENGTH);
		time = SQL_FetchFloat(hndl, 3);
		timepro = SQL_FetchFloat(hndl, 4);      
		teleports = SQL_FetchInt(hndl, 5);
		new Handle:pack1 = CreateDataPack();		
		WritePackString(pack1, szMapName);
		WritePackString(pack1, szSteamId);	
		WritePackString(pack1, szName);	
		WritePackFloat(pack1, time);
		WritePackCell(pack1, client);
		WritePackFloat(pack1, timepro);
		WritePackCell(pack1, teleports);
		
		if (SQL_FetchInt(hndl, 3) != -1.0)
			Format(szQuery, 512, sql_selectPlayerRankTime, szSteamId, szMapName, szMapName);
		else
			Format(szQuery, 512, sql_selectPlayerRankProTime, szSteamId, szMapName, szMapName);
		SQL_TQuery(g_hDb, SQL_ViewRecordCallback2, szQuery, pack1,DBPrio_Low);
	}
	else
	{ 
		new Handle:panel = CreatePanel();
		DrawPanelText(panel, "Current map time");
		DrawPanelText(panel, " ");
		DrawPanelText(panel, "No record found on this map.");
		DrawPanelItem(panel, "exit");
		SendPanelToClient(panel, client, MenuHandler2, 300);
		CloseHandle(panel);
	}
}

public SQL_ViewRecordCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
	decl String:szQuery[512];
	new rank = SQL_GetRowCount(hndl);
	new Handle:pack2 = data;
	WritePackCell(pack2, rank);
	ResetPack(pack2);	
	decl String:szMapName[128];
	ReadPackString(pack2, szMapName, 128);
	decl String:szSteamId[32];
	ReadPackString(pack2, szSteamId, 32);
	decl String:szName[MAX_NAME_LENGTH];
	ReadPackString(pack2, szName, MAX_NAME_LENGTH);
	new Float:time = ReadPackFloat(pack2);
	if (time != -1.0)
		Format(szQuery, 512, sql_selectPlayerCount, szMapName);
	else
		Format(szQuery, 512, sql_selectPlayerProCount, szMapName);
	SQL_TQuery(g_hDb, SQL_ViewRecordCallback3, szQuery, pack2,DBPrio_Low);
	}
}

//----------//
// callback //
//----------//
public SQL_ViewRecordCallback3(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	//if there is a player record
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		new count1 = SQL_GetRowCount(hndl);
		new Handle:pack3 = data;
		ResetPack(pack3);		
		decl String:szMapName[128];
		ReadPackString(pack3, szMapName, 128);
		decl String:szSteamId[32];
		ReadPackString(pack3, szSteamId, 32);
		decl String:szName[MAX_NAME_LENGTH];
		ReadPackString(pack3, szName, MAX_NAME_LENGTH);	
		new Float:time = ReadPackFloat(pack3);
		new client = ReadPackCell(pack3);
		new Float:timepro = ReadPackFloat(pack3);
		new teleports = ReadPackCell(pack3);
		new rank = ReadPackCell(pack3);
		g_bClimbersMenuOpen[client]=false;
		g_bMenuOpen[client] = true;	
		if (time != -1.0 && timepro == -1.0)
		{
			new Handle:panel = CreatePanel();
			decl String:szVrName[256];
			decl String:szVrTime[256];
			Format(szVrName, 256, "Map time of %s", szName);
			DrawPanelText(panel, szVrName);
			Format(szVrName, 256, "on %s", g_szMapName);
			DrawPanelText(panel, szVrName);
			DrawPanelText(panel, " ");
			decl String:szVrTeleports[32];
			decl String:szVrRank[32];			
			
			FormatTimeFloat(client, time, 3,szVrTime,sizeof(szVrTime));
			Format(szVrTime, 256, "Time: %s", szVrTime);
			
			Format(szVrTeleports, 32, "Teleports: %i", teleports);
			Format(szVrRank, 32, "Rank: %i of %i", rank,count1);                  
			DrawPanelText(panel, "TP time:");
			DrawPanelText(panel, szVrTime);
			DrawPanelText(panel, szVrTeleports);
			DrawPanelText(panel, szVrRank);
			DrawPanelText(panel, " ");
			DrawPanelText(panel, "Pro time:");
			DrawPanelText(panel, "-");
			DrawPanelText(panel, " ");
			DrawPanelItem(panel, "exit");
			CloseHandle(pack3);
			SendPanelToClient(panel, client, RecordPanelHandler, 300);
			CloseHandle(panel);                 
		}
		else
			if (time == -1.0 && timepro != -1.0)
			{               
				new Handle:panel = CreatePanel();
				decl String:szVrName[256];
				decl String:szVrTime[256];
				Format(szVrName, 256, "Map time of %s", szName);
				DrawPanelText(panel, szVrName);
				Format(szVrName, 256, "on %s", g_szMapName);
				DrawPanelText(panel, " ");		
				decl String:szVrRank[32];
				
				FormatTimeFloat(client, timepro, 3,szVrTime,sizeof(szVrTime));
				Format(szVrTime, 256, "Time: %s", szVrTime);

				Format(szVrRank, 32, "Rank: %i of %i", rank,count1);
				DrawPanelText(panel, "TP time:");
				DrawPanelText(panel, "-");
				DrawPanelText(panel, " ");
				DrawPanelText(panel, "Pro time:");
				DrawPanelText(panel, szVrTime);
				DrawPanelText(panel, szVrRank);
				DrawPanelText(panel, " ");
				DrawPanelItem(panel, "exit");
				CloseHandle(pack3);
				SendPanelToClient(panel, client, RecordPanelHandler, 300);
				CloseHandle(panel);
			}
			else
				if (time != 0.000000 && timepro != 0.000000)
				{
					WritePackCell(pack3, count1);
					decl String:szQuery[512];
					Format(szQuery, 512, sql_selectPlayerRankProTime, szSteamId, szMapName, szMapName);
					SQL_TQuery(g_hDb, SQL_ViewRecordCallback4, szQuery, pack3,DBPrio_Low);
                }
        }
}

public SQL_ViewRecordCallback4(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{

		decl String:szQuery[512];
		new rankPro = SQL_GetRowCount(hndl);
		new Handle:pack4 = data;
		WritePackCell(pack4, rankPro);
		ResetPack(pack4);
		decl String:szMapName[128];
		ReadPackString(pack4, szMapName, 128);
		Format(szQuery, 512, sql_selectPlayerProCount, szMapName);
		SQL_TQuery(g_hDb, SQL_ViewRecordCallback5, szQuery, pack4,DBPrio_Low);
	}
}

public SQL_ViewRecordCallback5(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	//if there is a player record
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		new countPro = SQL_GetRowCount(hndl);           
		//retrieve all values
		new Handle:pack5 = data;
		ResetPack(pack5);            
		decl String:szMapName[128];
		ReadPackString(pack5, szMapName, 128);
		decl String:szSteamId[32];
		ReadPackString(pack5, szSteamId, 32);
		decl String:szName[MAX_NAME_LENGTH];
		ReadPackString(pack5, szName, MAX_NAME_LENGTH);	
		new Float:time = ReadPackFloat(pack5);
		new client = ReadPackCell(pack5);
		new Float:timepro = ReadPackFloat(pack5);
		new teleports = ReadPackCell(pack5);
		new rank = ReadPackCell(pack5);                  
		new count1 = ReadPackCell(pack5);        
		new rankPro = ReadPackCell(pack5);                 
		g_bClimbersMenuOpen[client]=false;
		g_bMenuOpen[client] = true;			
		if (time != -1.0 && timepro != -1.0)
		{				
			new Handle:panel = CreatePanel();
			decl String:szVrName[256];
			Format(szVrName, 256, "Map time of %s", szName);
			DrawPanelText(panel, szVrName);
			Format(szVrName, 256, "on %s", g_szMapName);
			DrawPanelText(panel, " ");
			
			decl String:szVrTeleports[16];
			decl String:szVrRank[32];
			decl String:szVrRankPro[32];      
			decl String:szVrTime[256];
			decl String:szVrTimePro[256];
			FormatTimeFloat(client, time, 3,szVrTime,sizeof(szVrTime));	
			Format(szVrTime, 256, "Time: %s",szVrTime);
			FormatTimeFloat(client, timepro, 3,szVrTimePro,sizeof(szVrTimePro));
			Format(szVrTimePro, 256, "Time: %s", szVrTimePro);
			
			Format(szVrTeleports, 16, "Teleports: %i", teleports); 
			Format(szVrRank, 32, "Rank: %i of %i", rank,count1); 
			Format(szVrRankPro, 32, "Rank: %i of %i", rankPro,countPro); 
					          
			DrawPanelText(panel, "TP time:");
			DrawPanelText(panel, szVrTime);
			DrawPanelText(panel, szVrTeleports);
			DrawPanelText(panel, szVrRank);
			DrawPanelText(panel, " ");
			DrawPanelText(panel, "Pro time:");
			DrawPanelText(panel, szVrTimePro);
			DrawPanelText(panel, szVrRankPro);
			DrawPanelText(panel, " ");
			DrawPanelItem(panel, "exit");
			SendPanelToClient(panel, client, RecordPanelHandler, 300);
			CloseHandle(panel);
		}
		CloseHandle(pack5);
	}
	
}

//PROFILE %LIKE
public db_viewPlayerProfile1(client, String:szPlayerName[MAX_NAME_LENGTH])
{
	decl String:szQuery[512];
	decl String:szName[MAX_NAME_LENGTH*2+1];
	SQL_QuoteString(g_hDb, szPlayerName, szName, MAX_NAME_LENGTH*2+1);    
	Format(szQuery, 512, sql_selectPlayerRankAll2, szName);
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, szPlayerName);
	SQL_TQuery(g_hDb, SQL_ViewPlayerProfile1Callback, szQuery, pack,DBPrio_Low);
}

public SQL_ViewPlayerProfile1Callback(Handle:owner, Handle:hndl, const String:error[], any:data)
{    
	new Handle:pack = data;
	ResetPack(pack);
	new client = ReadPackCell(pack);
	decl String:szPlayerName[MAX_NAME_LENGTH];
	ReadPackString(pack, szPlayerName, MAX_NAME_LENGTH);	
	CloseHandle(pack);
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{           		
		SQL_FetchString(hndl, 1, g_szProfileSteamId[client], 32);
		db_viewPlayerRank(client,g_szProfileSteamId[client]);
	}
	else
	{
		decl String:szQuery[512];
		decl String:szName[MAX_NAME_LENGTH*2+1];
		SQL_QuoteString(g_hDb, szPlayerName, szName, MAX_NAME_LENGTH*2+1);      
		Format(szQuery, 512, sql_selectPlayerRankAll, PERCENT,szName,PERCENT);
		SQL_TQuery(g_hDb, SQL_ViewPlayerProfile2Callback, szQuery, client,DBPrio_Low);		
	}
}

public SQL_ViewPlayerProfile2Callback(Handle:owner, Handle:hndl, const String:error[], any:data)
{    
	new client = data;  
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{           
		SQL_FetchString(hndl, 1, g_szProfileSteamId[client], 32);
		db_viewPlayerRank(client,g_szProfileSteamId[client]);
	}
	else
		if(IsClientInGame(client))
			PrintToChat(client, "%t", "PlayerNotFound", MOSSGREEN,WHITE, g_szProfileName[client]);
}

public ProfileMenuHandler(Handle:menu, MenuAction:action, param1,param2)
{ 
	if(action == MenuAction_Select)
	{
		switch(param2)
		{
			case 0: db_viewRecord(param1, g_szProfileSteamId[param1], g_szMapName);
			case 1: 
			{
				db_viewJumpStats(param1, g_szProfileSteamId[param1]);
				if (!g_bJumpStats)
					PrintToChat(param1, "%t", "JumpstatsDisabled",MOSSGREEN,WHITE);
			}
			case 2: db_viewChallengeHistory(param1, g_szProfileSteamId[param1]);
			case 3: db_viewAllRecords(param1, g_szProfileSteamId[param1]);
			case 4: db_viewUnfinishedMaps(param1, g_szProfileSteamId[param1]);	
			case 5:
			{
				if(g_bRecalcRankInProgess[param1])
				{
					PrintToChat(param1, "[%cKZ%c] %cRecalculation in progress. Please wait!", MOSSGREEN,WHITE,GRAY);
				}
				else
				{
				
					g_bRecalcRankInProgess[param1] = true;
					PrintToChat(param1, "%t", "Rc_PlayerRankStart", MOSSGREEN,WHITE,GRAY);
					CalculatePlayerRank(param1);
				}
			}		
		}	
	}
	else
	if(action == MenuAction_Cancel)
	{
		if (1 <= param1 <= MaxClients && IsValidClient(param1))
		{
			switch(g_MenuLevel[param1])
			{
				case 0: db_selectTopPlayers(param1);
				case 1: db_selectTopClimbers(param1,g_szMapTopName[param1]);
				case 2: db_selectTopLj(param1);	
				case 3: db_selectTopChallengers(param1);
				case 4: db_selectTopWj(param1);
				case 5: db_selectTopBhop(param1);
				case 6: db_selectTopDropBhop(param1);	
				case 7: db_selectTopMultiBhop(param1);	
				case 8: db_selectTPClimbers(param1,g_szMapTopName[param1]);	
				case 9: db_selectProClimbers(param1,g_szMapTopName[param1]);	
				case 10: db_selectTopTpRecordHolders(param1);
				case 11: db_selectTopProRecordHolders(param1);	
				case 12: db_selectTopLjBlock(param1);
				case 13: db_selectTopLadderJump(param1);
			}	
			if (g_MenuLevel[param1] < 0)		
			{
				if (g_bSelectProfile[param1])
					ProfileMenu(param1,0);
				else
					g_bMenuOpen[param1]=false;	
			}
			g_bProfileSelected[param1]=false;
		}							
	}
	else 
		if (action == MenuAction_End)	
		{
			CloseHandle(menu);
		}
}


public db_selectRecord(client, String:mapname[128])
{
	decl String:szQuery[255];
	if (!IsValidClient(client))
		return;
	Format(szQuery, 255, sql_selectRecord, g_szSteamID[client], mapname);
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, mapname);
	SQL_TQuery(g_hDb, sql_selectRecordCallback, szQuery, pack,DBPrio_High);
}

public sql_selectRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new Handle:pack = data;
	ResetPack(pack);
	new client = ReadPackCell(pack);
	decl String:mapname[128];
	ReadPackString(pack, mapname, 128);	
	decl String:szQuery[512];
	if (!IsValidClient(client))
		return;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		if	(g_Tp_Final[client]>0)
			Format(szQuery, 512, sql_selectRecordTp, g_szSteamID[client], mapname);
		else
			Format(szQuery, 512, sql_selectProRecord, g_szSteamID[client], mapname);
		if (!IsFakeClient(client))
			SQL_TQuery(g_hDb, SQL_UpdateRecordCallback, szQuery, pack,DBPrio_High);		
	}
	else
	{
 		CloseHandle(pack);
 		decl String:szUName[MAX_NAME_LENGTH];
 		GetClientName(client, szUName, MAX_NAME_LENGTH);
 		decl String:szName[MAX_NAME_LENGTH*2+1];
 		SQL_QuoteString(g_hDb, szUName, szName, MAX_NAME_LENGTH*2+1);
		if	(g_Tp_Final[client]>0)
		{						
			Format(szQuery, 512, sql_insertPlayerTp, g_szSteamID[client], mapname, szName, g_fFinalTime[client], g_Tp_Final[client]);
			g_fPersonalRecord[client] = g_fFinalTime[client];	
			SQL_TQuery(g_hDb, SQL_UpdateRecordTpCallback, szQuery,client,DBPrio_High);	
		}
		else
		{
			Format(szQuery, 512, sql_insertPlayerPro, g_szSteamID[client], mapname, szName, g_fFinalTime[client]);
			g_fPersonalRecordPro[client] = g_fFinalTime[client];
			SQL_TQuery(g_hDb, SQL_UpdateRecordProCallback, szQuery,client,DBPrio_High);	
		}
			
	}
}
	
public db_Cleanup()
{
	decl String:szQuery[255];
	Format(szQuery, 255, "DELETE FROM playertmp where mapname != '%s'", g_szMapName);
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery);
	SQL_TQuery(g_hDb, SQL_CheckCallback, "DELETE FROM playertimes where runtime = -1.0 and runtimepro = -1.0");
}

public db_updateLjRecord(client)
{
	decl String:szQuery[255];
	if (!IsValidClient(client))
		return;
	Format(szQuery, 255, sql_selectPlayerJumpLJ, g_szSteamID[client]);
	if (!IsFakeClient(client))
		SQL_TQuery(g_hDb, SQL_UpdateLjRecordCallback, szQuery, client,DBPrio_Low);
}

public db_updateLadderJumpRecord(client)
{
	decl String:szQuery[255];
	if (!IsValidClient(client))
		return;
	Format(szQuery, 255, sql_selectPlayerJumpLadderJump, g_szSteamID[client]);
	if (!IsFakeClient(client))
		SQL_TQuery(g_hDb, SQL_UpdateLadderJumpRecordCallback, szQuery, client,DBPrio_Low);
}

public db_updateLjBlockRecord(client)
{
	decl String:szQuery[255];
	if (!IsValidClient(client))
		return;
	Format(szQuery, 255, sql_selectPlayerJumpLJBlock, g_szSteamID[client]);
	if (!IsFakeClient(client))
		SQL_TQuery(g_hDb, SQL_UpdateLjBlockRecordCallback, szQuery, client,DBPrio_Low);
}

public db_updateWjRecord(client)
{
	decl String:szQuery[255];
	if (!IsValidClient(client))
		return;
	Format(szQuery, 255, sql_selectPlayerJumpWJ, g_szSteamID[client]);
	if (!IsFakeClient(client))
		SQL_TQuery(g_hDb, SQL_UpdateWjRecordCallback, szQuery, client,DBPrio_Low);
}

public db_updateBhopRecord(client)
{
	decl String:szQuery[255];
	if (!IsValidClient(client))
		return;
	Format(szQuery, 255, sql_selectPlayerJumpBhop, g_szSteamID[client]);
	if (!IsFakeClient(client))
		SQL_TQuery(g_hDb, SQL_UpdateBhopRecordCallback, szQuery, client,DBPrio_Low);
}

public db_updateDropBhopRecord(client)
{
	decl String:szQuery[255];
	if (!IsValidClient(client))
		return;
	Format(szQuery, 255, sql_selectPlayerJumpDropBhop, g_szSteamID[client]);
	if (!IsFakeClient(client))
		SQL_TQuery(g_hDb, SQL_UpdateDropBhopRecordCallback, szQuery, client,DBPrio_Low);
}

public db_updateCountJumpRecord(client)
{
	decl String:szQuery[255];
	if (!IsValidClient(client))
		return;
	Format(szQuery, 255, sql_selectPlayerJumpCountJump, g_szSteamID[client]);
	if (!IsFakeClient(client))
		SQL_TQuery(g_hDb, SQL_UpdateCountJumpRecordCallback, szQuery, client,DBPrio_Low);
}


public db_updateMultiBhopRecord(client)
{
	decl String:szQuery[255];
	if (!IsValidClient(client))
		return;
	Format(szQuery, 255, sql_selectPlayerJumpMultiBhop, g_szSteamID[client]);
	if (!IsFakeClient(client))
		SQL_TQuery(g_hDb, SQL_UpdateMultiBhopRecordCallback, szQuery, client,DBPrio_Low);
}

public db_updateMapButtons(Float:loc0, Float:loc1, Float:loc2, Float:ang0, index)
{
	decl String:szQuery[255];
	new Handle:pack = CreateDataPack();
	WritePackFloat(pack, loc0);
	WritePackFloat(pack, loc1);
	WritePackFloat(pack, loc2);
	WritePackFloat(pack, ang0);
	WritePackCell(pack, index);
	Format(szQuery, 255, sql_selectMapButtons, g_szMapName);
	SQL_TQuery(g_hDb, SQL_selectMapButtonsCallback, szQuery, pack,DBPrio_Low);
}

public SQL_selectMapButtonsCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	decl String:szQuery[512];
	new Handle:pack = data;
	ResetPack(pack);
	new Float:loc0 = ReadPackFloat(pack);
	new Float:loc1 = ReadPackFloat(pack);
	new Float:loc2 = ReadPackFloat(pack);
	new Float:ang0 = ReadPackFloat(pack);
	new index = ReadPackCell(pack);
	CloseHandle(pack);
	
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		if (index==0)
			Format(szQuery, 512, sql_updateMapButtonsStart, loc0,loc1,loc2,ang0, g_szMapName);
		else
			Format(szQuery, 512, sql_updateMapButtonsEnd, loc0,loc1,loc2,ang0, g_szMapName);
		SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery,DBPrio_Low);
	}
	else
	{
		if (index==0)
			Format(szQuery, 512, sql_insertMapButtons, g_szMapName,loc0,loc1,loc2,-1.0,-1.0,-1.0,ang0,-1.0);
		else
			Format(szQuery, 512, sql_insertMapButtons, g_szMapName,-1.0,-1.0,-1.0,loc0,loc1,loc2,-1.0,ang0);
		SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery,DBPrio_Low);
	}
}


public SQL_UpdateLjRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if (IsValidClient(client))
	{
		decl String:szQuery[512];
		decl String:szUName[MAX_NAME_LENGTH];
		GetClientName(client, szUName, MAX_NAME_LENGTH);
		decl String:szName[MAX_NAME_LENGTH*2+1];
		SQL_QuoteString(g_hDb, szUName, szName, MAX_NAME_LENGTH*2+1);
		if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		{
			Format(szQuery, 512, sql_updateLj, szName, g_js_fPersonal_Lj_Record[client], g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client], g_js_Strafes_Final[client],g_js_Sync_Final[client],g_flastHeight[client], g_szSteamID[client]);
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery,DBPrio_Low);
		}	
		else
		{
			Format(szQuery, 512, sql_insertPlayerJumpLj, g_szSteamID[client], szName, g_js_fPersonal_Lj_Record[client], g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client], g_js_Strafes_Final[client],g_js_Sync_Final[client],g_flastHeight[client]);
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery,DBPrio_Low);
		}
		db_viewLjRecord2(client);
	}
}

public SQL_UpdateLadderJumpRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if (IsValidClient(client))
	{
		decl String:szQuery[512];
		decl String:szUName[MAX_NAME_LENGTH];
		GetClientName(client, szUName, MAX_NAME_LENGTH);
		decl String:szName[MAX_NAME_LENGTH*2+1];
		SQL_QuoteString(g_hDb, szUName, szName, MAX_NAME_LENGTH*2+1);
		if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		{
			Format(szQuery, 512, sql_updateLadderJump, szName, g_js_fPersonal_LadderJump_Record[client], g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client], g_js_Strafes_Final[client],g_js_Sync_Final[client],g_flastHeight[client], g_szSteamID[client]);
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery,DBPrio_Low);
		}	
		else
		{
			Format(szQuery, 512, sql_insertPlayerJumpLadderJump, g_szSteamID[client], szName, g_js_fPersonal_LadderJump_Record[client], g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client], g_js_Strafes_Final[client],g_js_Sync_Final[client],g_flastHeight[client]);
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery,DBPrio_Low);
		}
		db_viewLadderJumpRecord2(client);
	}
}

public SQL_UpdateLjBlockRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if (IsValidClient(client))
	{
		decl String:szQuery[512];
		decl String:szUName[MAX_NAME_LENGTH];
		GetClientName(client, szUName, MAX_NAME_LENGTH);
		decl String:szName[MAX_NAME_LENGTH*2+1];
		SQL_QuoteString(g_hDb, szUName, szName, MAX_NAME_LENGTH*2+1);
		if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		{
			Format(szQuery, 512, sql_updateLjBlock, szName, g_js_Personal_LjBlock_Record[client], g_js_fPersonal_LjBlockRecord_Dist[client], g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client], g_js_Strafes_Final[client],g_js_Sync_Final[client],g_flastHeight[client], g_szSteamID[client]);
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery,DBPrio_Low);
			}	
		else
		{
			Format(szQuery, 512, sql_insertPlayerJumpLjBlock , g_szSteamID[client], szName, g_js_Personal_LjBlock_Record[client], g_js_fPersonal_LjBlockRecord_Dist[client], g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client], g_js_Strafes_Final[client],g_js_Sync_Final[client],g_flastHeight[client]);
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery,DBPrio_Low);
			}
		db_viewLjBlockRecord2(client);
	}
}

public SQL_UpdateWjRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if (IsValidClient(client))
	{
		decl String:szQuery[512];
		decl String:szUName[MAX_NAME_LENGTH];
		GetClientName(client, szUName, MAX_NAME_LENGTH);
		decl String:szName[MAX_NAME_LENGTH*2+1];
		SQL_QuoteString(g_hDb, szUName, szName, MAX_NAME_LENGTH*2+1);
		if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		{
			Format(szQuery, 512, sql_updateWJ, szName, g_js_fPersonal_Wj_Record[client], g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client], g_js_Strafes_Final[client],g_js_Sync_Final[client],g_flastHeight[client], g_szSteamID[client]);
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery,DBPrio_Low);
		}	
		else
		{
			Format(szQuery, 512, sql_insertPlayerJumpWJ, g_szSteamID[client], szName, g_js_fPersonal_Wj_Record[client], g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client], g_js_Strafes_Final[client],g_js_Sync_Final[client],g_flastHeight[client]);
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery,DBPrio_Low);
		}
	}
	db_viewWjRecord2(client);
}


public SQL_UpdateCountJumpRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if (IsValidClient(client))
	{
		decl String:szQuery[512];
		decl String:szUName[MAX_NAME_LENGTH];
		GetClientName(client, szUName, MAX_NAME_LENGTH);
		decl String:szName[MAX_NAME_LENGTH*2+1];
		SQL_QuoteString(g_hDb, szUName, szName, MAX_NAME_LENGTH*2+1);
		if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		{
			Format(szQuery, 512, sql_updateCountJump, szName, g_js_fPersonal_CJ_Record[client], g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client], g_js_Strafes_Final[client],g_js_Sync_Final[client],g_flastHeight[client], g_szSteamID[client]);
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery,DBPrio_Low);
		}
		else
		{
			Format(szQuery, 512, sql_insertPlayerJumpCountJump, g_szSteamID[client], szName, g_js_fPersonal_CJ_Record[client], g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client], g_js_Strafes_Final[client],g_js_Sync_Final[client],g_flastHeight[client]);
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery,DBPrio_Low);
		}
	}
	db_viewCountJumpRecord2(client);
}

public SQL_UpdateDropBhopRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if (IsValidClient(client))
	{
		decl String:szQuery[512];
		decl String:szUName[MAX_NAME_LENGTH];
		GetClientName(client, szUName, MAX_NAME_LENGTH);
		decl String:szName[MAX_NAME_LENGTH*2+1];
		SQL_QuoteString(g_hDb, szUName, szName, MAX_NAME_LENGTH*2+1);
		if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		{
			Format(szQuery, 512, sql_updateDropBhop, szName, g_js_fPersonal_DropBhop_Record[client], g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client], g_js_Strafes_Final[client],g_js_Sync_Final[client],g_flastHeight[client], g_szSteamID[client]);
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery,DBPrio_Low);
		}
		else
		{
			Format(szQuery, 512, sql_insertPlayerJumpDropBhop, g_szSteamID[client], szName, g_js_fPersonal_DropBhop_Record[client], g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client], g_js_Strafes_Final[client],g_js_Sync_Final[client],g_flastHeight[client]);
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery,DBPrio_Low);
		}
	}
	db_viewDropBhopRecord2(client);
}

public SQL_UpdateBhopRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if (IsValidClient(client))
	{
		decl String:szQuery[512];
		decl String:szUName[MAX_NAME_LENGTH];
		GetClientName(client, szUName, MAX_NAME_LENGTH);
		decl String:szName[MAX_NAME_LENGTH*2+1];
		SQL_QuoteString(g_hDb, szUName, szName, MAX_NAME_LENGTH*2+1);
		if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		{
			Format(szQuery, 512, sql_updateBhop, szName, g_js_fPersonal_Bhop_Record[client], g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client], g_js_Strafes_Final[client],g_js_Sync_Final[client],g_flastHeight[client], g_szSteamID[client]);
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery,DBPrio_Low);
		}
		else
		{
			Format(szQuery, 512, sql_insertPlayerJumpBhop, g_szSteamID[client], szName, g_js_fPersonal_Bhop_Record[client], g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client], g_js_Strafes_Final[client],g_js_Sync_Final[client],g_flastHeight[client]);
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery,DBPrio_Low);
		}
		db_viewBhopRecord2(client);
	}
}

public SQL_UpdateMultiBhopRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if (IsValidClient(client))
	{
		decl String:szQuery[512];
		decl String:szUName[MAX_NAME_LENGTH];
		GetClientName(client, szUName, MAX_NAME_LENGTH);
		decl String:szName[MAX_NAME_LENGTH*2+1];
		SQL_QuoteString(g_hDb, szUName, szName, MAX_NAME_LENGTH*2+1);
		if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		{		
			Format(szQuery, 512, sql_updateMultiBhop, szName, g_js_fPersonal_MultiBhop_Record[client], g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client], g_js_Strafes_Final[client],g_js_MultiBhop_Count[client],g_js_Sync_Final[client],g_flastHeight[client], g_szSteamID[client]);
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery,DBPrio_Low);
		}
		else
		{		
			Format(szQuery, 512, sql_insertPlayerJumpMultiBhop, g_szSteamID[client], szName, g_js_fPersonal_MultiBhop_Record[client], g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client], g_js_Strafes_Final[client],g_js_MultiBhop_Count[client],g_js_Sync_Final[client],g_flastHeight[client]);
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery,DBPrio_Low);
		}
		db_viewMultiBhopRecord2(client);
	}
}

public SQL_UpdateRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new Handle:pack = data;
	ResetPack(pack);
	new client = ReadPackCell(pack);
	decl String:mapname[128];
	ReadPackString(pack, mapname, 128);
	CloseHandle(pack);	
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		new Float:time;
		time = SQL_FetchFloat(hndl, 3);
		if((g_fFinalTime[client] <= time || time <= 0.0) && g_Tp_Final[client] > 0)
		db_updateRecordCP(client, mapname);
		else
			if((g_fFinalTime[client] <= time || time <= 0.0) && g_Tp_Final[client] == 0)
		db_updateRecordPro(client, mapname);
	}    
	else
	{
		if (g_Tp_Final[client] > 0)
			db_updateRecordCP(client, mapname);	
		else 
			db_updateRecordPro(client, mapname);	
	}
}

public db_updateRecordCP(client, String:mapname[128])
{	
	decl String:szQuery[1024];
	decl String:szUName[MAX_NAME_LENGTH];
	if (IsValidClient(client))
		GetClientName(client, szUName, MAX_NAME_LENGTH);
	else
		return;	
	decl String:szName[MAX_NAME_LENGTH*2+1];
	SQL_QuoteString(g_hDb, szUName, szName, MAX_NAME_LENGTH*2+1);   
	Format(szQuery, 1024, sql_updateRecord, szUName, g_Tp_Final[client], g_fFinalTime[client], g_szSteamID[client], mapname);
	SQL_TQuery(g_hDb, SQL_UpdateRecordTpCallback, szQuery,client,DBPrio_Low);
	g_fPersonalRecord[client] = g_fFinalTime[client];	
}

public db_updateRecordPro(client, String:mapname[128])
{
	decl String:szQuery[1024];
	decl String:szUName[MAX_NAME_LENGTH];
	if (IsValidClient(client))
		GetClientName(client, szUName, MAX_NAME_LENGTH);
	else
		return;   
	decl String:szName[MAX_NAME_LENGTH*2+1];
	SQL_QuoteString(g_hDb, szUName, szName, MAX_NAME_LENGTH*2+1);
	Format(szQuery, 1024, sql_updateRecordPro, szUName, g_fFinalTime[client], g_szSteamID[client], mapname);
	SQL_TQuery(g_hDb, SQL_UpdateRecordProCallback, szQuery,client,DBPrio_Low);
	g_fPersonalRecordPro[client] = g_fFinalTime[client];
}

public SQL_UpdateRecordTpCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	g_bMapRankToChat[client]=true;
	db_viewMapRankTp(client);
}

public SQL_UpdateRecordProCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	g_bMapRankToChat[client]=true;
	db_viewMapRankPro(client);
}

public db_selectTPClimbers(client, String:mapname[128])
{
	decl String:szQuery[1024];       
	Format(szQuery, 1024, sql_selectTPClimbers, mapname);   
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, mapname);
	SQL_TQuery(g_hDb, sql_selectTPClimbersCallback, szQuery, pack,DBPrio_Low);
}

public db_selectTopClimbers(client, String:mapname[128])
{
	decl String:szQuery[1024];       
	Format(szQuery, 1024, sql_selectTopClimbers, mapname, mapname);  
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, mapname);
	SQL_TQuery(g_hDb, sql_selectTopClimbersCallback, szQuery, pack,DBPrio_Low);
}

public db_selectMapTopClimbers(client, String:mapname[128])
{
	decl String:szQuery[1024];       
	Format(szQuery, 1024, sql_selectTopClimbers2, PERCENT,mapname,PERCENT,PERCENT, mapname,PERCENT);
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, mapname);
	SQL_TQuery(g_hDb, sql_selectMapTopClimbersCallback, szQuery, pack,DBPrio_Low);
}

public db_selectProClimbers(client, String:mapname[128])
{    
	decl String:szQuery[1024]; 
	Format(szQuery, 1024, sql_selectProClimbers, mapname);   	
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, mapname);	
	SQL_TQuery(g_hDb, sql_selectProClimbersCallback, szQuery, pack,DBPrio_Low);
}
public db_selectTopLj(client)
{
	decl String:szQuery[1024];       
	Format(szQuery, 1024, sql_selectPlayerJumpTopLJ);   		
	SQL_TQuery(g_hDb, sql_selectPlayerJumpTopLJCallback, szQuery, client,DBPrio_Low);
}

public db_selectTopLadderJump(client)
{
	decl String:szQuery[1024];       
	Format(szQuery, 1024, sql_selectPlayerJumpTopLadderJump);   		
	SQL_TQuery(g_hDb, sql_selectPlayerJumpTopLadderJumpCallback, szQuery, client,DBPrio_Low);
}

public db_selectTopLjBlock(client)
{
	decl String:szQuery[1024];       
	Format(szQuery, 1024, sql_selectPlayerJumpTopLJBlock);   		
	SQL_TQuery(g_hDb, sql_selectPlayerJumpTopLJBlockCallback, szQuery, client,DBPrio_Low);
}

public db_selectTopWj(client)
{
	decl String:szQuery[1024];       
	Format(szQuery, 1024, sql_selectPlayerJumpTopWJ);   		
	SQL_TQuery(g_hDb, sql_selectPlayerJumpTopWJCallback, szQuery, client,DBPrio_Low);
}

public db_selectTopCj(client)
{
	decl String:szQuery[1024];       
	Format(szQuery, 1024, sql_selectPlayerJumpTopCountJump);   		
	SQL_TQuery(g_hDb, sql_selectPlayerJumpTopCJCallback, szQuery, client,DBPrio_Low);
}

public db_selectTopBhop(client)
{
	decl String:szQuery[1024];       
	Format(szQuery, 1024, sql_selectPlayerJumpTopBhop);   		
	SQL_TQuery(g_hDb, sql_selectPlayerJumpTopBhopCallback, szQuery, client,DBPrio_Low);
}

public db_selectTopDropBhop(client)
{
	decl String:szQuery[1024];       
	Format(szQuery, 1024, sql_selectPlayerJumpTopDropBhop);   		
	SQL_TQuery(g_hDb, sql_selectPlayerJumpTopDropBhopCallback, szQuery, client,DBPrio_Low);
}


public db_selectTopMultiBhop(client)
{
	decl String:szQuery[1024];       
	Format(szQuery, 1024, sql_selectPlayerJumpTopMultiBhop);   		
	SQL_TQuery(g_hDb, sql_selectPlayerJumpTopMultiBhopCallback, szQuery, client,DBPrio_Low);
}

public db_selectMapButtons()
{
	decl String:szQuery[1024];       
	Format(szQuery, 1024, sql_selectMapButtons, g_szMapName);
	SQL_TQuery(g_hDb, sql_ViewMapButtonsCallback, szQuery,DBPrio_Low);
}

public sql_ViewMapButtonsCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{       
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		new Float:location3[3];
		new Float:StartCords[3];
		new Float:CordsSprite[3];
		new Float:EndCords[3];
		new Float:Angs[3];
		new Float: angstart;
		new Float: angend;
		Angs[0]=0.0;
		Angs[2]=0.0;
		StartCords[0] = SQL_FetchFloat(hndl, 0);
		StartCords[1] = SQL_FetchFloat(hndl, 1);
		StartCords[2] = SQL_FetchFloat(hndl, 2);
		EndCords[0] = SQL_FetchFloat(hndl, 3);
		EndCords[1] = SQL_FetchFloat(hndl, 4);
		EndCords[2] = SQL_FetchFloat(hndl, 5);	
		angstart = SQL_FetchFloat(hndl, 6);	
		angend = SQL_FetchFloat(hndl, 7);

		new Float:angstartbutton = angstart+180.0;
		new Float:angendbutton = angend+180.0;
		
		//STARTBUTTON
		if (StartCords[0] != -1.0 && StartCords[1] != -1.0 && StartCords[2] != -1.0)
		{
			new ent = CreateEntityByName("prop_physics_override");
			if (ent != -1)
			{  
				Angs[1]=angstartbutton;
				DispatchKeyValue(ent, "model", "models/props/switch001.mdl");
				DispatchKeyValue(ent, "spawnflags", "264");
				DispatchKeyValue(ent, "targetname","climb_startbuttonx");
				DispatchSpawn(ent);   
				TeleportEntity(ent, StartCords, Angs, NULL_VECTOR);			
				location3 = StartCords;			
				g_fStartButtonPos = location3;
				g_bFirstStartButtonPush = false;
				SDKHook(ent, SDKHook_UsePost, OnUsePost);	
				g_global_SelfBuiltButtons=true;
			}
			if (angstart != -1.0)
			{
				Angs[1]=angstart;
				new spritestart = CreateEntityByName("env_sprite"); 
				if(spritestart != -1) 
				{ 
					DispatchKeyValue(spritestart, "classname", "env_sprite");
					DispatchKeyValue(spritestart, "spawnflags", "1");
					DispatchKeyValue(spritestart, "scale", "0.2");
					DispatchKeyValue(spritestart, "model", "materials/models/props/startkztimer.vmt"); 
					DispatchKeyValue(spritestart, "targetname", "starttimersign");
					DispatchKeyValue(spritestart, "rendermode", "1");
					DispatchKeyValue(spritestart, "framerate", "0");
					DispatchKeyValue(spritestart, "HDRColorScale", "1.0");
					DispatchKeyValue(spritestart, "rendercolor", "255 255 255");
					DispatchKeyValue(spritestart, "renderamt", "255");
					DispatchSpawn(spritestart);
					CordsSprite = StartCords;
					CordsSprite[2]+=95;
					TeleportEntity(spritestart, CordsSprite, Angs, NULL_VECTOR);
				}	
			}		
		}
		//ENDBUTTON
		if (EndCords[0] != -1.0 && EndCords[1] != -1.0 && EndCords[2] != -1.0)
		{		
			new ent2 = CreateEntityByName("prop_physics_override");
			if (ent2 != -1)
			{  
				Angs[1]=angendbutton;
				DispatchKeyValue(ent2, "model", "models/props/switch001.mdl");
				DispatchKeyValue(ent2, "spawnflags", "264");
				DispatchKeyValue(ent2, "targetname","climb_endbuttonx");
				DispatchSpawn(ent2);   
				TeleportEntity(ent2, EndCords, Angs, NULL_VECTOR);
				location3 = EndCords;		
				g_fEndButtonPos = location3;
				g_bFirstEndButtonPush = false;
				SDKHook(ent2, SDKHook_UsePost, OnUsePost);
				g_global_SelfBuiltButtons=true;
			}
			if (angend != -1.0)
			{
				Angs[1]=angend;
				new spritestop = CreateEntityByName("env_sprite");
				if(spritestop != -1) 
				{ 
					DispatchKeyValue(spritestop, "classname", "env_sprite");
					DispatchKeyValue(spritestop, "spawnflags", "1");
					DispatchKeyValue(spritestop, "scale", "0.2");
					DispatchKeyValue(spritestop, "model", "materials/models/props/stopkztimer.vmt"); 
					DispatchKeyValue(spritestop, "targetname", "stoptimersign");
					DispatchKeyValue(spritestop, "rendermode", "1");
					DispatchKeyValue(spritestop, "framerate", "0");
					DispatchKeyValue(spritestop, "HDRColorScale", "1.0");
					DispatchKeyValue(spritestop, "rendercolor", "255 255 255");
					DispatchKeyValue(spritestop, "renderamt", "255");	
					DispatchSpawn(spritestop);
					CordsSprite = EndCords;
					CordsSprite[2]+=95;
					TeleportEntity(spritestop, CordsSprite, Angs, NULL_VECTOR);
				}	
			}	
		}
	}
}


public sql_selectPlayerJumpTopLJBlockCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{       
	new client = data;
	decl String:szValue[128];
	decl String:szName[64];
	decl String:szSteamID[32];
	new ljblock;
	new Float:ljrecord;
	new String:szStrafes[32];
	new strafes;
	new Handle:menu = CreateMenu(LjBlockJumpMenuHandler1);
	SetMenuTitle(menu, "Top 20 Block Longjump\n    Rank    Block   Distance           Strafes      Player");  
	SetMenuPagination(menu, 5);
	if(SQL_HasResultSet(hndl))
	{
		new i = 1;
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, szName, 64);
			ljblock = SQL_FetchInt(hndl, 1); 
			ljrecord = SQL_FetchFloat(hndl, 2); 
			strafes = SQL_FetchInt(hndl, 3); 
			SQL_FetchString(hndl, 4, szSteamID, 32);
			if (strafes < 10)
				Format(szStrafes, 32, " %i ", strafes); 
			else
				Format(szStrafes, 32, "%i", strafes); 
			if (i < 10)
					Format(szValue, 128, "[0%i.]    %i     %.3f units       %s      » %s", i, ljblock,ljrecord,szStrafes, szName);
				else
					Format(szValue, 128, "[%i.]    %i     %.3f units       %s      » %s", i, ljblock,ljrecord,szStrafes, szName);
			AddMenuItem(menu, szSteamID, szValue, ITEMDRAW_DEFAULT);
			i++;
		}
	}
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}


public sql_selectPlayerJumpTopLJCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{       
	new client = data;
	decl String:szValue[128];
	decl String:szName[64];
	decl String:szSteamID[32];
	new Float:ljrecord;
	new String:szStrafes[32];
	new strafes;
	new Handle:menu = CreateMenu(LjJumpMenuHandler1);
	SetMenuTitle(menu, "Top 20 Longjump\n    Rank    Distance           Strafes      Player");  
	SetMenuPagination(menu, 5);
	if(SQL_HasResultSet(hndl))
	{
		new i = 1;
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, szName, 64);
			ljrecord = SQL_FetchFloat(hndl, 1); 
			strafes = SQL_FetchInt(hndl, 2); 
			SQL_FetchString(hndl, 3, szSteamID, 32);
			if (strafes < 10)
				Format(szStrafes, 32, " %i ", strafes); 
			else
				Format(szStrafes, 32, "%i", strafes); 
			if (i < 10)
					Format(szValue, 128, "[0%i.]    %.3f units      %s      » %s", i, ljrecord,szStrafes, szName);
				else
					Format(szValue, 128, "[%i.]    %.3f units      %s      » %s", i, ljrecord,szStrafes, szName);
			AddMenuItem(menu, szSteamID, szValue, ITEMDRAW_DEFAULT);
			i++;
		}
	}
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public sql_selectPlayerJumpTopLadderJumpCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{       
	new client = data;
	decl String:szValue[128];
	decl String:szName[64];
	decl String:szSteamID[32];
	new Float:ladderjumprecord;
	new String:szStrafes[32];
	new strafes;
	new Handle:menu = CreateMenu(LadderJumpMenuHandler1);
	SetMenuTitle(menu, "Top 20 Ladderjump\n    Rank    Distance           Strafes      Player");  
	SetMenuPagination(menu, 5);
	if(SQL_HasResultSet(hndl))
	{
		new i = 1;
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, szName, 64);
			ladderjumprecord = SQL_FetchFloat(hndl, 1); 
			strafes = SQL_FetchInt(hndl, 2); 
			SQL_FetchString(hndl, 3, szSteamID, 32);
			if (strafes < 10)
				Format(szStrafes, 32, " %i ", strafes); 
			else
				Format(szStrafes, 32, "%i", strafes); 
			if (i < 10)
					Format(szValue, 128, "[0%i.]    %.3f units      %s      » %s", i, ladderjumprecord,szStrafes, szName);
				else
					Format(szValue, 128, "[%i.]    %.3f units      %s      » %s", i, ladderjumprecord,szStrafes, szName);
			AddMenuItem(menu, szSteamID, szValue, ITEMDRAW_DEFAULT);
			i++;
		}
	}
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public sql_selectPlayerJumpTopCJCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{       
	new client = data;
	decl String:szValue[128];
	decl String:szName[64];
	new Float:cjrecord;
	new String:szStrafes[32];
	decl String:szSteamID[32];
	new strafes;
	new Handle:menu = CreateMenu(CjJumpMenuHandler1);
	SetMenuTitle(menu, "Top 20 Countjump\n    Rank    Distance           Strafes      Player");  
	SetMenuPagination(menu, 5);
	if(SQL_HasResultSet(hndl))
	{
		new i = 1;
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, szName, 64);
			cjrecord = SQL_FetchFloat(hndl, 1); 
			strafes = SQL_FetchInt(hndl, 2); 
			SQL_FetchString(hndl, 3, szSteamID, 32);
			if (strafes < 10)
				Format(szStrafes, 32, " %i ", strafes); 
			else
				Format(szStrafes, 32, "%i", strafes); 
			if (i < 10)
					Format(szValue, 128, "[0%i.]    %.3f units      %s      » %s", i, cjrecord,szStrafes, szName);
				else
					Format(szValue, 128, "[%i.]    %.3f units      %s      » %s", i, cjrecord,szStrafes, szName);
			AddMenuItem(menu, szSteamID, szValue, ITEMDRAW_DEFAULT);
			i++;
		}
	}
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public CjJumpMenuHandler1(Handle:menu, MenuAction:action, param1, param2)
{
	if (action ==  MenuAction_Select)
	{
		decl String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		g_MenuLevel[param1] = 14;
		db_viewPlayerRank(param1, info);	
	}
	if (action ==  MenuAction_Cancel)
	{
		JumpTopMenu(param1);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public sql_selectPlayerJumpTopWJCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{       
	new client = data;
	decl String:szValue[128];
	decl String:szName[64];
	new Float:ljrecord;
	new String:szStrafes[32];
	decl String:szSteamID[32];
	new strafes;
	new Handle:menu = CreateMenu(WjJumpMenuHandler1);
	SetMenuTitle(menu, "Top 20 Weirdjump\n    Rank    Distance           Strafes      Player");  
	SetMenuPagination(menu, 5);
	if(SQL_HasResultSet(hndl))
	{
		new i = 1;
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, szName, 64);
			ljrecord = SQL_FetchFloat(hndl, 1); 
			strafes = SQL_FetchInt(hndl, 2); 
			SQL_FetchString(hndl, 3, szSteamID, 32);
			if (strafes < 10)
				Format(szStrafes, 32, " %i ", strafes); 
			else
				Format(szStrafes, 32, "%i", strafes); 
			if (i < 10)
					Format(szValue, 128, "[0%i.]    %.3f units      %s      » %s", i, ljrecord,szStrafes, szName);
				else
					Format(szValue, 128, "[%i.]    %.3f units      %s      » %s", i, ljrecord,szStrafes, szName);
			AddMenuItem(menu, szSteamID, szValue, ITEMDRAW_DEFAULT);
			i++;
		}
	}
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public sql_selectPlayerJumpTopBhopCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{       
	new client = data;
	decl String:szValue[128];
	decl String:szName[64];
	new Float:bhoprecord;
	decl String:szSteamID[32];
	new String:szStrafes[32];
	new strafes;
	new Handle:menu = CreateMenu(BhopJumpMenuHandler1);
	SetMenuTitle(menu, "Top 20 Bunnyhop\n    Rank    Distance           Strafes      Player");  
	SetMenuPagination(menu, 5);
	if(SQL_HasResultSet(hndl))
	{
		new i = 1;
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, szName, 64);
			bhoprecord = SQL_FetchFloat(hndl, 1); 
			strafes = SQL_FetchInt(hndl, 2); 
			SQL_FetchString(hndl, 3, szSteamID, 32);
			if (strafes < 10)
				Format(szStrafes, 32, " %i ", strafes); 
			else
				Format(szStrafes, 32, "%i", strafes); 
			if (i < 10)
					Format(szValue, 128, "[0%i.]    %.3f units      %s      » %s", i, bhoprecord,szStrafes, szName);
				else
					Format(szValue, 128, "[%i.]    %.3f units      %s      » %s", i, bhoprecord,szStrafes, szName);
			AddMenuItem(menu, szSteamID, szValue, ITEMDRAW_DEFAULT);
			i++;
		}
	}
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public sql_selectPlayerJumpTopDropBhopCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{       
	new client = data;
	decl String:szValue[128];
	decl String:szName[64];
	new Float:bhoprecord;
	decl String:szSteamID[32];
	new String:szStrafes[32];
	new strafes;
	new Handle:menu = CreateMenu(DropBhopJumpMenuHandler1);
	SetMenuTitle(menu, "Top 20 Drop-Bunnyhop\n    Rank    Distance           Strafes      Player");  
	SetMenuPagination(menu, 5);
	if(SQL_HasResultSet(hndl))
	{
		new i = 1;
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, szName, 64);
			bhoprecord = SQL_FetchFloat(hndl, 1); 
			strafes = SQL_FetchInt(hndl, 2); 
			SQL_FetchString(hndl, 3, szSteamID, 32);
			if (strafes < 10)
				Format(szStrafes, 32, " %i ", strafes); 
			else
				Format(szStrafes, 32, "%i", strafes); 
			if (i < 10)
					Format(szValue, 128, "[0%i.]    %.3f units      %s      » %s", i, bhoprecord,szStrafes, szName);
				else
					Format(szValue, 128, "[%i.]    %.3f units      %s      » %s", i, bhoprecord,szStrafes, szName);
			AddMenuItem(menu, szSteamID, szValue, ITEMDRAW_DEFAULT);
			i++;
		}
	}
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public sql_selectPlayerJumpTopMultiBhopCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{       
	new client = data;
	decl String:szValue[128];
	decl String:szName[64];
	new Float:multibhoprecord;
	decl String:szSteamID[32];
	new String:szStrafes[32];
	new strafes;
	new Handle:menu = CreateMenu(MultiBhopJumpMenuHandler1);
	SetMenuTitle(menu, "Top 20 Multi-Bunnyhop\n    Rank    Distance           Strafes      Player");  
	SetMenuPagination(menu, 5);
	if(SQL_HasResultSet(hndl))
	{
		new i = 1;
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, szName, 64);
			multibhoprecord = SQL_FetchFloat(hndl, 1); 
			strafes = SQL_FetchInt(hndl, 2); 
			SQL_FetchString(hndl, 3, szSteamID, 32);
			if (strafes < 10)
				Format(szStrafes, 32, " %i ", strafes); 
			else
				Format(szStrafes, 32, "%i", strafes); 	
			if (i < 10)
					Format(szValue, 128, "[0%i.]    %.3f units      %s      » %s", i, multibhoprecord,szStrafes, szName);
				else
					Format(szValue, 128, "[%i.]    %.3f units      %s      » %s", i, multibhoprecord,szStrafes, szName);
			AddMenuItem(menu, szSteamID, szValue, ITEMDRAW_DEFAULT);
			i++;
		}
	}
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public sql_selectTopClimbersCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{       
	
	new Handle:pack = data;
	ResetPack(pack);
	new client = ReadPackCell(pack);
	decl String:szMap[128];
	ReadPackString(pack, szMap, 128);	
	CloseHandle(pack);
	decl String:szFirstMap[128];
	decl String:szValue[128];
	decl String:szName[64];
	new Float:time;
	new teleports;
	decl String:szTeleports[32];
	decl String:szSteamID[32];
	new String:lineBuf[256];
	new Handle:stringArray = CreateArray(100);
	new Handle:menu;
	menu = CreateMenu(MapMenuHandler1);
	SetMenuPagination(menu, 5);
	new bool:bduplicat = false;
	decl String:title[256];
	if(SQL_HasResultSet(hndl))
	{
		new i = 1;
		while (SQL_FetchRow(hndl))
		{
			bduplicat = false;
			SQL_FetchString(hndl, 0, szSteamID, 32);
			SQL_FetchString(hndl, 1, szName, 64);
			time = SQL_FetchFloat(hndl, 2); 
			teleports = SQL_FetchInt(hndl, 3);		
			SQL_FetchString(hndl, 5, szMap, 128);
			if (i == 1 || (i > 1 && StrEqual(szFirstMap,szMap)))
			{
				new stringArraySize = GetArraySize(stringArray);
				for(new x = 0; x < stringArraySize; x++)
				{
					GetArrayString(stringArray, x, lineBuf, sizeof(lineBuf));
					if (StrEqual(lineBuf, szName, false))
						bduplicat=true;		
				}
				if (bduplicat==false && i < 51)
				{
					if (teleports < 10)
						Format(szTeleports, 32, "    %i",teleports);
					else
					if (teleports < 100)
						Format(szTeleports, 32, "  %i",teleports);
					else
						Format(szTeleports, 32, "%i",teleports);
					
					decl String:szTime[32];
					FormatTimeFloat(client, time, 3,szTime,sizeof(szTime));
					if (time<3600.0)
						Format(szTime, 32, "   %s", szTime);			
					if (i == 100)
						Format(szValue, 128, "[%i.] %s | %s    » %s", i, szTime, szTeleports, szName);
					if (i >= 10)
						Format(szValue, 128, "[%i.] %s | %s    » %s", i, szTime, szTeleports, szName);
					else
						Format(szValue, 128, "[0%i.] %s | %s    » %s", i, szTime, szTeleports, szName);
					AddMenuItem(menu, szSteamID, szValue, ITEMDRAW_DEFAULT);
					PushArrayString(stringArray, szName);
					if (i == 1)
						Format(szFirstMap, 128, "%s",szMap);
					i++;
				}
			}
		}
		if(i == 1)
		{
			PrintToChat(client, "%t", "NoTopRecords", MOSSGREEN,WHITE, szMap);
		}
	}
	else
		PrintToChat(client, "%t", "NoTopRecords", MOSSGREEN,WHITE, szMap);
	Format(title, 256, "Top 50 Times on %s (local)\n    Rank    Time           TP's     Player", szFirstMap);
	SetMenuTitle(menu, title);     
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	CloseHandle(stringArray);
}

public sql_selectMapTopClimbersCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{       
	new Handle:pack = data;
	ResetPack(pack);
	new client = ReadPackCell(pack);
	decl String:szMap[128];
	ReadPackString(pack, szMap, 128);	
	CloseHandle(pack);
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		
		new i = SQL_GetRowCount(hndl);
		SQL_FetchString(hndl, 5, szMap, 128);
		if(i == 0)
			PrintToChat(client, "%t", "NoTopRecords", MOSSGREEN,WHITE, szMap);
		else
			MapTopMenu(client,szMap);
	}
	else
		PrintToChat(client, "%t", "NoTopRecords", MOSSGREEN,WHITE, szMap);
}

public sql_selectTPClimbersCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{       
	new Handle:pack = data;
	ResetPack(pack);
	new client = ReadPackCell(pack);
	decl String:mapname[128];
	ReadPackString(pack, mapname, 128);	
	CloseHandle(pack);
	decl String:szValue[128];
	decl String:szName[64];
	new Float:time;
	new teleports;
	decl String:szTeleports[32];
	decl String:szSteamID[32];
	decl String:szTime[32];
	new Handle:menu = CreateMenu(MapMenuHandler2);
	SetMenuPagination(menu, 5);
	decl String:title[255];
	Format(title, 256, "Top 20 TP Times on %s (local)\n    Rank    Time           TP's       Player", mapname);
	SetMenuTitle(menu, title);     
	if(SQL_HasResultSet(hndl))
	{
		new i = 1;
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, szName, 64);
			time = SQL_FetchFloat(hndl, 1); 
			teleports = SQL_FetchInt(hndl, 2);		
			SQL_FetchString(hndl, 3, szSteamID, 32);
			if (teleports < 10)
				Format(szTeleports, 32, "    %i",teleports);
			else
				if (teleports < 100)
					Format(szTeleports, 32, "  %i",teleports);
				else
					Format(szTeleports, 32, "%i",teleports);
			
			FormatTimeFloat(client, time, 3,szTime,sizeof(szTime));
			if (time<3600.0)
				Format(szTime, 32, "   %s", szTime);			
			if (i < 10)
				Format(szValue, 128, "[0%i.] %s | %s      » %s", i, szTime, szTeleports, szName);
			else
				Format(szValue, 128, "[%i.] %s | %s      » %s", i, szTime, szTeleports, szName);
			AddMenuItem(menu, szSteamID, szValue, ITEMDRAW_DEFAULT);
			i++;
		}
		if(i == 1)
		{
			PrintToChat(client, "%t", "NoTpRecords", MOSSGREEN,WHITE, mapname);
		}
	}
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}
public sql_selectProClimbersCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{      
	new Handle:pack = data;
	ResetPack(pack);
	new client = ReadPackCell(pack);
	decl String:mapname[128];
	ReadPackString(pack, mapname, 128);	
	CloseHandle(pack);
	decl String:szValue[128];
	decl String:szSteamID[32];
	decl String:szName[64];
	decl String:szTime[32];
	new Float:time;
	new Handle:menu = CreateMenu(MapMenuHandler3);
	SetMenuPagination(menu, 5);
	decl String:title[255];
	Format(title, 256, "Top 20 PRO Times on %s (local)\n    Rank   Time              Player", mapname);
	SetMenuTitle(menu, title);
	if(SQL_HasResultSet(hndl))
		
	{
		new i = 1;
		while (SQL_FetchRow(hndl))
		{		
			SQL_FetchString(hndl, 0, szName, 64);
			time = SQL_FetchFloat(hndl, 1);		
			SQL_FetchString(hndl, 2, szSteamID, 32);
			FormatTimeFloat(client, time, 3,szTime,sizeof(szTime));			
			if (time<3600.0)
				Format(szTime, 32, "  %s", szTime);
			if (i < 10)
				Format(szValue, 128, "[0%i.] %s    » %s", i, szTime, szName);
			else
				Format(szValue, 128, "[%i.] %s    » %s", i, szTime, szName);
			AddMenuItem(menu, szSteamID, szValue, ITEMDRAW_DEFAULT);
			i++;
		}
		if(i == 1)
		{
			PrintToChat(client, "%t", "NoProRecords",MOSSGREEN,WHITE, mapname);
		}
	}     
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public TopChallengeHandler1(Handle:menu, MenuAction:action, param1, param2)
{

	if (action ==  MenuAction_Select)
	{
		decl String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		g_MenuLevel[param1]=3;
		db_viewPlayerRank(param1,info);
	}

	if (action ==  MenuAction_Cancel)
	{
		KZTopMenu(param1);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public TopTpHoldersHandler1(Handle:menu, MenuAction:action, param1, param2)
{

	if (action ==  MenuAction_Select)
	{
		decl String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		g_MenuLevel[param1]=10;
		db_viewPlayerRank(param1,info);
	}

	if (action ==  MenuAction_Cancel)
	{
		KZTopMenu(param1);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}
public TopProHoldersHandler1(Handle:menu, MenuAction:action, param1, param2)
{

	if (action ==  MenuAction_Select)
	{
		decl String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		g_MenuLevel[param1]=11;
		db_viewPlayerRank(param1,info);
	}

	if (action ==  MenuAction_Cancel)
	{
		KZTopMenu(param1);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public TopPlayersMenuHandler1(Handle:menu, MenuAction:action, param1, param2)
{
	if (action ==  MenuAction_Select)
	{
		decl String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		g_MenuLevel[param1]=0;
		db_viewPlayerRank(param1,info);
	}
	if (action ==  MenuAction_Cancel)
	{
		KZTopMenu(param1);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public LjBlockJumpMenuHandler1(Handle:menu, MenuAction:action, param1, param2)
{
	if (action ==  MenuAction_Select)
	{
		decl String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		g_MenuLevel[param1] = 12;
		db_viewPlayerRank(param1, info);	
	}
	if (action ==  MenuAction_Cancel)
	{
		JumpTopMenu(param1);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public LjJumpMenuHandler1(Handle:menu, MenuAction:action, param1, param2)
{
	if (action ==  MenuAction_Select)
	{
		decl String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		g_MenuLevel[param1] = 2;
		db_viewPlayerRank(param1, info);	
	}
	if (action ==  MenuAction_Cancel)
	{
		JumpTopMenu(param1);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public LadderJumpMenuHandler1(Handle:menu, MenuAction:action, param1, param2)
{
	if (action ==  MenuAction_Select)
	{
		decl String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		g_MenuLevel[param1] = 13;
		db_viewPlayerRank(param1, info);	
	}
	if (action ==  MenuAction_Cancel)
	{
		JumpTopMenu(param1);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public WjJumpMenuHandler1(Handle:menu, MenuAction:action, param1, param2)
{
	if (action ==  MenuAction_Select)
	{
		decl String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		g_MenuLevel[param1] = 4;
		db_viewPlayerRank(param1, info);	
	}
	if (action ==  MenuAction_Cancel)
	{
		JumpTopMenu(param1);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}
public BhopJumpMenuHandler1(Handle:menu, MenuAction:action, param1, param2)
{
	if (action ==  MenuAction_Select)
	{
		decl String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		g_MenuLevel[param1] = 5;
		db_viewPlayerRank(param1, info);	
	}
	if (action ==  MenuAction_Cancel)
	{
		JumpTopMenu(param1);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}
public DropBhopJumpMenuHandler1(Handle:menu, MenuAction:action, param1, param2)
{
	if (action ==  MenuAction_Select)
	{
		decl String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		g_MenuLevel[param1] = 6;
		db_viewPlayerRank(param1, info);	
	}
	if (action ==  MenuAction_Cancel)
	{
		JumpTopMenu(param1);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public MultiBhopJumpMenuHandler1(Handle:menu, MenuAction:action, param1, param2)
{
	if (action ==  MenuAction_Select)
	{
		decl String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		g_MenuLevel[param1] = 7;
		db_viewPlayerRank(param1, info);	
	}
	if (action ==  MenuAction_Cancel)
	{
		JumpTopMenu(param1);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public MapMenuHandler1(Handle:menu, MenuAction:action, param1, param2)
{
	if (action ==  MenuAction_Select)
	{
		decl String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		g_MenuLevel[param1] = 1;
		db_viewPlayerRank(param1, info);		
	}
	if (action ==  MenuAction_Cancel)
	{
		MapTopMenu(param1,g_szMapTopName[param1]);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public MapTopMenuHandler2(Handle:menu, MenuAction:action, param1, param2)
{
	if (action ==  MenuAction_Select)
	{
		decl String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		g_MenuLevel[param1] = 1;
		db_viewPlayerRank(param1, info);		
	}
}

public MapMenuHandler2(Handle:menu, MenuAction:action, param1, param2)
{
	if (action ==  MenuAction_Select)
	{
		decl String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		g_MenuLevel[param1] = 8;
		db_viewPlayerRank(param1, info);		
	}
	if (action ==  MenuAction_Cancel)
	{
		MapTopMenu(param1,g_szMapTopName[param1]);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}


public MapMenuHandler3(Handle:menu, MenuAction:action, param1, param2)
{
	if (action ==  MenuAction_Select)
	{
		decl String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		g_MenuLevel[param1] = 9;
		db_viewPlayerRank(param1, info);		
	}
	if (action ==  MenuAction_Cancel)
	{
		MapTopMenu(param1,g_szMapTopName[param1]);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}


public MenuHandler2(Handle:menu, MenuAction:action, param1, param2)
{
	if (action ==  MenuAction_Cancel || action ==  MenuAction_Select)
	{
		ProfileMenu(param1, -1);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public SQL_SelectPlayerCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{       
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl) && IsValidClient(client))
	{
	}
	else
		db_insertPlayer(client);
}


public db_GetMapRecord_CP()
{
	decl String:szQuery[512];      
	Format(szQuery, 512, sql_selectMapRecordCP, g_szMapName);       
	SQL_TQuery(g_hDb, sql_selectMapRecordCPCallback, szQuery,DBPrio_Low);
}
public db_GetMapRecord_Pro()
{
	decl String:szQuery[512];      
	Format(szQuery, 512, sql_selectMapRecordPro, g_szMapName);      
	SQL_TQuery(g_hDb, sql_selectMapRecordProCallback, szQuery,DBPrio_Low);
}
public sql_selectMapRecordCPCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{

	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
	
		if (SQL_FetchFloat(hndl, 0) > -1.0)
		{
			g_fRecordTime = SQL_FetchFloat(hndl, 0);
			SQL_FetchString(hndl, 1, g_szRecordPlayer, MAX_NAME_LENGTH);	
		}
		else
			g_fRecordTime = 9999999.0;	
	}
	else
		g_fRecordTime = 9999999.0;		

	if (g_bProReplay)
		LoadReplayPro();
	if (g_bTpReplay)
		LoadReplayTp();
		
}

public sql_selectMapRecordProCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		if (SQL_FetchFloat(hndl, 0) > -1.0)
		{
			g_fRecordTimePro = SQL_FetchFloat(hndl, 0);
			SQL_FetchString(hndl, 1, g_szRecordPlayerPro, MAX_NAME_LENGTH);	
		}
		else
			g_fRecordTimePro = 9999999.0;
	}
	else
		g_fRecordTimePro = 9999999.0;
		
	if (!g_bTpReplay && g_bProReplay)
		g_bRoutePro=true;
	else
		if (g_bTpReplay && !g_bProReplay)
			g_bRoutePro=false;
		else
			if (g_fRecordTime <= g_fRecordTimePro)
				g_bRoutePro=false;
			else
				g_bRoutePro=true;		
}

public db_dropMap(client)
{
	SQL_LockDatabase(g_hDb);       
	if(g_DbType == MYSQL)
		SQL_FastQuery(g_hDb, sql_dropMap);
	else
		SQL_FastQuery(g_hDb, sqlite_dropMap);	
	SQL_UnlockDatabase(g_hDb);       
	PrintToConsole(client, "map buttons table dropped. Please restart your server!");
}

public db_dropChallenges(client)
{
	SQL_TQuery(g_hDb, SQL_CheckCallback, "UPDATE playerrank SET winratio = '0',pointsratio = '0'", client);
	SQL_LockDatabase(g_hDb);
	if(g_DbType == MYSQL)
		SQL_FastQuery(g_hDb, sql_dropChallenges);
	else
		SQL_FastQuery(g_hDb, sqlite_dropChallenges);
	SQL_UnlockDatabase(g_hDb);
	PrintToConsole(client, "challenge table dropped. Please restart your server!");
}

public db_dropPlayer(client)
{
	SQL_TQuery(g_hDb, sql_selectMutliplierCallback, "UPDATE playerrank SET multiplier ='0'", client);
	SQL_LockDatabase(g_hDb);
	if(g_DbType == MYSQL)
		SQL_FastQuery(g_hDb, sql_dropPlayer);
	else
		SQL_FastQuery(g_hDb, sqlite_dropPlayer);
	SQL_UnlockDatabase(g_hDb);
	PrintToConsole(client, "playertimes table dropped. Please restart your server!");
}

public db_dropPlayerRanks(client)
{
	SQL_LockDatabase(g_hDb);
	if(g_DbType == MYSQL)
		SQL_FastQuery(g_hDb, sql_dropPlayerRank);
	else
		SQL_FastQuery(g_hDb, sqlite_dropPlayerRank);
	SQL_UnlockDatabase(g_hDb);
	PrintToConsole(client, "playerranks table dropped. Please restart your server!");
}

public db_dropPlayerJump(client)
{
	SQL_LockDatabase(g_hDb);
	if(g_DbType == MYSQL)
		SQL_FastQuery(g_hDb, sql_dropPlayerJump);
	else
		SQL_FastQuery(g_hDb, sqlite_dropPlayerJump);
	SQL_UnlockDatabase(g_hDb);
	PrintToConsole(client, "jumpstats table dropped. Please restart your server!");
}

public db_resetMapRecords(client, String:szMapName[128])
{
	decl String:szQuery[255];      
	Format(szQuery, 255, sql_resetMapRecords, szMapName);
	SQL_TQuery(g_hDb, SQL_CheckCallback2, szQuery,DBPrio_Low);	       
	PrintToConsole(client, "player times on %s cleared.", szMapName);
	if (StrEqual(szMapName,g_szMapName))
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i))
			{
				g_fPersonalRecord[i] = 0.0;
				g_fPersonalRecordPro[i] = 0.0;
				g_MapRankTp[i] = 99999;
				g_MapRankPro[i] = 99999;
			}
		}
	}            
}

public db_resetPlayerRecords(client, String:steamid[128])
{
	decl String:szQuery[255];    
	decl String:szsteamid[128*2+1];
	SQL_QuoteString(g_hDb, steamid, szsteamid, 128*2+1);   	
	Format(szQuery, 255, sql_resetRecords, szsteamid);       
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery);	        
	PrintToConsole(client, "map times of %s cleared.", szsteamid);
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, steamid);	
	Format(szQuery, 255, "UPDATE playerrank SET multiplier ='0' WHERE steamid = '%s'", szsteamid);       
	SQL_TQuery(g_hDb, SQL_CheckCallback3, szQuery , pack);
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			if(StrEqual(g_szSteamID[i],szsteamid))
			{
				g_fPersonalRecord[i] = 0.0;
				g_fPersonalRecordPro[i] = 0.0;
				g_MapRankTp[i] = 99999;
				g_MapRankPro[i] = 99999;
			}
		}
	}
}

public db_resetPlayerRecordTp(client, String:steamid[128], String:szMapName[128])
{
	decl String:szQuery[255];      
	decl String:szsteamid[128*2+1];
	
	SQL_QuoteString(g_hDb, steamid, szsteamid, 128*2+1);      
	Format(szQuery, 255, sql_resetRecordTp, szsteamid, szMapName);
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, steamid);		
	SQL_TQuery(g_hDb, SQL_CheckCallback3, szQuery,pack);	    
	PrintToConsole(client, "tp time of %s on %s cleared.", steamid, szMapName);
    
	if (StrEqual(szMapName,g_szMapName))
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i))
			{
				if(StrEqual(g_szSteamID[i],szsteamid))
				{
					g_fPersonalRecord[i] = 0.0;
					g_MapRankTp[i] = 99999;
				}
			}
		}
	}  
}

public db_resetPlayerRecordPro(client, String:steamid[128], String:szMapName[128])
{
	decl String:szQuery[255];      
	decl String:szsteamid[128*2+1];
	
	SQL_QuoteString(g_hDb, steamid, szsteamid, 128*2+1);      
	Format(szQuery, 255, sql_resetRecordPro, szsteamid, szMapName);   
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, steamid);	    
	SQL_TQuery(g_hDb, SQL_CheckCallback3, szQuery,pack);	    
	PrintToConsole(client, "pro time of %s on %s cleared.", steamid, szMapName);
    
	if (StrEqual(szMapName,g_szMapName))
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i))
			{
				if(StrEqual(g_szSteamID[i],szsteamid))
				{
					g_fPersonalRecordPro[i] = 0.0;
					g_MapRankPro[i] = 99999;
				}
			}
		}
	} 
}

public db_resetPlayerRecords2(client, String:steamid[128], String:szMapName[128])
{
	decl String:szQuery[255];      
	decl String:szsteamid[128*2+1];
	
	SQL_QuoteString(g_hDb, steamid, szsteamid, 128*2+1);      
	Format(szQuery, 255, sql_resetRecords2, szsteamid, szMapName); 
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, steamid);		
	SQL_TQuery(g_hDb, SQL_CheckCallback3, szQuery, pack);	    
	PrintToConsole(client, "map times of %s on %s cleared.", steamid, szMapName);
    
	if (StrEqual(szMapName,g_szMapName))
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i))
			{
				if(StrEqual(g_szSteamID[i],szsteamid))
				{
					g_fPersonalRecord[i] = 0.0;
					g_fPersonalRecordPro[i] = 0.0;
					g_MapRankTp[i] = 99999;
					g_MapRankPro[i] = 99999;
				}
			}
		}
	}
}

public db_resetPlayerBhopRecord(client, String:steamid[128])
{
	decl String:szQuery[255];
	decl String:szsteamid[128*2+1];
	SQL_QuoteString(g_hDb, steamid, szsteamid, 128*2+1);      
	Format(szQuery, 255, sql_resetBhopRecord, szsteamid);    
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, steamid);		
	SQL_TQuery(g_hDb, SQL_CheckCallback4, szQuery, pack);	      
	PrintToConsole(client, "bhop record cleared (%s).", szsteamid);
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			if(StrEqual(g_szSteamID[i],szsteamid))
			{
				g_js_BhopRank[i] = 99999999;
				g_js_fPersonal_Bhop_Record[i] = -1.0;
			}
		}
	}
}

public db_resetPlayerDropBhopRecord(client, String:steamid[128])
{
	decl String:szQuery[255];
	decl String:szsteamid[128*2+1];
	SQL_QuoteString(g_hDb, steamid, szsteamid, 128*2+1);      
	Format(szQuery, 255, sql_resetDropBhopRecord, szsteamid);  
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, steamid);		
	SQL_TQuery(g_hDb, SQL_CheckCallback4, szQuery, pack);	    
	PrintToConsole(client, "dropbhop record cleared (%s).", szsteamid);
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			if(StrEqual(g_szSteamID[i],szsteamid))
			{
				g_js_DropBhopRank[i] = 99999999;
				g_js_fPersonal_DropBhop_Record[i] = -1.0;
			}
		}
	}
}

public db_resetPlayerWJRecord(client, String:steamid[128])
{
	decl String:szQuery[255];
	decl String:szsteamid[128*2+1];
	SQL_QuoteString(g_hDb, steamid, szsteamid, 128*2+1);      
	Format(szQuery, 255, sql_resetWJRecord, szsteamid);   
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, steamid);		
	SQL_TQuery(g_hDb, SQL_CheckCallback4, szQuery, pack);	    
	PrintToConsole(client, "wj record cleared (%s).", szsteamid);
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			if(StrEqual(g_szSteamID[i],szsteamid))
			{
				g_js_WjRank[i] = 99999999;
				g_js_fPersonal_Wj_Record[i] = -1.0;
			}
		}
	}
}

public db_resetPlayerJumpstats(client, String:steamid[128])
{
	decl String:szQuery[255];
	decl String:szsteamid[128*2+1];
	SQL_QuoteString(g_hDb, steamid, szsteamid, 128*2+1);      
	Format(szQuery, 255, sql_resetJumpStats, szsteamid);
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, steamid);	
	SQL_TQuery(g_hDb, SQL_CheckCallback4, szQuery, pack);	       
	PrintToConsole(client, "jumpstats cleared (%s).", szsteamid);
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			if(StrEqual(g_szSteamID[i],szsteamid))
			{
				g_js_MultiBhopRank[i] = 99999999;
				g_js_fPersonal_MultiBhop_Record[i] = -1.0;
				g_js_WjRank[i] = 99999999;
				g_js_fPersonal_Wj_Record[i] = -1.0;	
				g_js_DropBhopRank[i] = 99999999;
				g_js_fPersonal_DropBhop_Record[i] = -1.0;		
				g_js_BhopRank[i] = 99999999;
				g_js_fPersonal_Bhop_Record[i] = -1.0;	
				g_js_LjRank[i] = 99999999;
				g_js_fPersonal_Lj_Record[i] = -1.0;	
				g_js_LadderJumpRank[i] = 99999999;
				g_js_fPersonal_LadderJump_Record[i] = -1.0;			
				g_js_CJRank[i] = 99999999;
				g_js_fPersonal_CJ_Record[i] = -1.0;						
			}
		}
	}
}

public db_resetPlayerMultiBhopRecord(client, String:steamid[128])
{
	decl String:szQuery[255];
	decl String:szsteamid[128*2+1];
	SQL_QuoteString(g_hDb, steamid, szsteamid, 128*2+1);      
	Format(szQuery, 255, sql_resetMultiBhopRecord, szsteamid);
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, steamid);	
	SQL_TQuery(g_hDb, SQL_CheckCallback4, szQuery, pack);	      
	PrintToConsole(client, "multibhop record cleared (%s).", szsteamid);
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			if(StrEqual(g_szSteamID[i],szsteamid))
			{
				g_js_MultiBhopRank[i] = 99999999;
				g_js_fPersonal_MultiBhop_Record[i] = -1.0;
			}
		}
	}
}

public db_resetPlayerResetChallenges(client, String:steamid[128])
{
	decl String:szQuery[255];
	decl String:szsteamid[128*2+1];
	SQL_QuoteString(g_hDb, steamid, szsteamid, 128*2+1);        
	Format(szQuery, 255, sql_deleteChallenges, szsteamid);       
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, steamid);	    
	SQL_TQuery(g_hDb, SQL_CheckCallback4, szQuery, pack);	     	
	PrintToConsole(client, "won challenges cleared (%s)", szsteamid);
}


public db_resetPlayerLjRecord(client, String:steamid[128])
{
	decl String:szQuery[255];
	decl String:szsteamid[128*2+1];
	SQL_QuoteString(g_hDb, steamid, szsteamid, 128*2+1);      
	Format(szQuery, 255, sql_resetLjRecord, szsteamid);   
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, steamid);	    
	SQL_TQuery(g_hDb, SQL_CheckCallback4, szQuery, pack);	      
	PrintToConsole(client, "lj record cleared (%s).", szsteamid);
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			if(StrEqual(g_szSteamID[i],szsteamid))
			{
				g_js_LjRank[i] = 99999999;
				g_js_fPersonal_Lj_Record[i] = -1.0;
			}
		}
	}
}

public db_resetPlayerCjRecord(client, String:steamid[128])
{
	decl String:szQuery[255];
	decl String:szsteamid[128*2+1];
	SQL_QuoteString(g_hDb, steamid, szsteamid, 128*2+1);      
	Format(szQuery, 255, sql_resetCjRecord, szsteamid);   
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, steamid);	    
	SQL_TQuery(g_hDb, SQL_CheckCallback4, szQuery, pack);	      
	PrintToConsole(client, "cj record cleared (%s).", szsteamid);
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			if(StrEqual(g_szSteamID[i],szsteamid))
			{
				g_js_CJRank[i] = 99999999;
				g_js_fPersonal_CJ_Record[i] = -1.0;
			}
		}
	}
}


public db_resetPlayerLadderJumpRecord(client, String:steamid[128])
{
	decl String:szQuery[255];
	decl String:szsteamid[128*2+1];
	SQL_QuoteString(g_hDb, steamid, szsteamid, 128*2+1);      
	Format(szQuery, 255, sql_resetLadderJumpRecord, szsteamid);   
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, steamid);	    
	SQL_TQuery(g_hDb, SQL_CheckCallback4, szQuery, pack);	      
	PrintToConsole(client, "ladderjump record cleared (%s).", szsteamid);
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			if(StrEqual(g_szSteamID[i],szsteamid))
			{
				g_js_LadderJumpRank[i] = 99999999;
				g_js_fPersonal_LadderJump_Record[i] = -1.0;
			}
		}
	}
}


public db_resetPlayerLjBlockRecord(client, String:steamid[128])
{
	decl String:szQuery[255];
	decl String:szsteamid[128*2+1];
	SQL_QuoteString(g_hDb, steamid, szsteamid, 128*2+1);      
	Format(szQuery, 255, sql_resetLjBlockRecord, szsteamid);       
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, steamid);	
	SQL_TQuery(g_hDb, SQL_CheckCallback4, szQuery, pack);	    
	PrintToConsole(client, "ljblock record cleared (%s).", szsteamid);
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			if(StrEqual(g_szSteamID[i],szsteamid))
			{
				g_js_LjBlockRank[i] = 99999999;
				g_js_Personal_LjBlock_Record[i] = -1;
			}
		}
	}
}

public SQL_CheckCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
}

public SQL_CheckCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	db_viewMapProRankCount();
	db_viewMapTpRankCount();
	db_GetMapRecord_CP();
	db_GetMapRecord_Pro();
}

public SQL_CheckCallback3(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new Handle:pack = data;
	ResetPack(pack);
	new client = ReadPackCell(pack);
	decl String:steamid[128];
	ReadPackString(pack, steamid, 128);	
	CloseHandle(pack);
	RecalcPlayerRank(client, steamid);
	db_viewMapProRankCount();
	db_viewMapTpRankCount();
	db_GetMapRecord_CP();
	db_GetMapRecord_Pro();
}

public SQL_CheckCallback4(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new Handle:pack = data;
	ResetPack(pack);
	new client = ReadPackCell(pack);
	decl String:steamid[128];
	ReadPackString(pack, steamid, 128);	
	CloseHandle(pack);
	RecalcPlayerRank(client, steamid);
}


public SQL_InsertCheckCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
}

public sql_deletePlayerCheckCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
}

public RecordPanelHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if(action ==  MenuAction_Select)
	{
		if (g_CMOpen[param1])
		{
			g_CMOpen[param1]=false;
			ClimbersMenu(param1)
		}
		else
			ProfileMenu(param1,-1);
	}	
}

public RecordPanelHandler2(Handle:menu, MenuAction:action, param1, param2)
{
	if (action ==  MenuAction_Select)
	{
		KZTopMenu(param1);
	}
}

public db_viewPlayerOptions(client, String:szSteamId[32])
{
	decl String:szQuery[512];      
	Format(szQuery, 512, sql_selectPlayerOptions, szSteamId);     
	SQL_TQuery(g_hDb, db_viewPlayerOptionsCallback, szQuery,client,DBPrio_Low);	
}

public db_viewPlayerOptionsCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;		
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{		
		g_ColorChat[client]=SQL_FetchInt(hndl, 0);
		g_bInfoPanel[client]=IntoBool(SQL_FetchInt(hndl, 1));
		g_bClimbersMenuSounds[client]=IntoBool(SQL_FetchInt(hndl,2));
		g_EnableQuakeSounds[client]=SQL_FetchInt(hndl, 3); 
		g_bAutoBhopClient[client]=IntoBool(SQL_FetchInt(hndl, 4)); //FieldName ShowKeys
		g_bShowNames[client]=IntoBool(SQL_FetchInt(hndl, 5));
		g_bStrafeSync[client]=IntoBool(SQL_FetchInt(hndl, 7));
		g_bGoToClient[client]=IntoBool(SQL_FetchInt(hndl, 6));
		g_bShowTime[client]=IntoBool(SQL_FetchInt(hndl, 8));
		g_bHide[client]=IntoBool(SQL_FetchInt(hndl, 9));
		g_ShowSpecs[client]= SQL_FetchInt(hndl, 10);		
		g_bCPTextMessage[client]=IntoBool(SQL_FetchInt(hndl, 11));
		g_bAdvancedClimbersMenu[client]=IntoBool(SQL_FetchInt(hndl, 12));	
		g_bStartWithUsp[client]=IntoBool(SQL_FetchInt(hndl, 15));
		g_bJumpBeam[client]=IntoBool(SQL_FetchInt(hndl, 16));
		g_bHideChat[client]=IntoBool(SQL_FetchInt(hndl, 17));
		g_bViewModel[client]=IntoBool(SQL_FetchInt(hndl, 18));
		g_bAdvInfoPanel[client]=IntoBool(SQL_FetchInt(hndl, 19));
		g_bReplayRoute[client]=IntoBool(SQL_FetchInt(hndl, 20));
		g_ClientLang[client]= SQL_FetchInt(hndl, 21);	
		g_bErrorSounds[client] = IntoBool(SQL_FetchInt(hndl, 22));
		//org
		g_borg_AutoBhopClient[client] = g_bAutoBhopClient[client];
		g_org_ColorChat[client] = g_ColorChat[client];
		g_borg_InfoPanel[client] = g_bInfoPanel[client];
		g_borg_ClimbersMenuSounds[client] = g_bClimbersMenuSounds[client];
		g_org_EnableQuakeSounds[client] = g_EnableQuakeSounds[client];
		g_borg_ShowNames[client] = g_bShowNames[client];
		g_borg_StrafeSync[client] = g_bStrafeSync[client];
		g_borg_GoToClient[client] = g_bGoToClient[client];
		g_borg_ShowTime[client] = g_bShowTime[client]; 
		g_borg_Hide[client] = g_bHide[client];
		g_borg_StartWithUsp[client] = g_bStartWithUsp[client];
		g_org_ShowSpecs[client] = g_ShowSpecs[client]; 
		g_borg_CPTextMessage[client] = g_bCPTextMessage[client];
		g_borg_AdvancedClimbersMenu[client] = g_bAdvancedClimbersMenu[client];
		g_borg_JumpBeam[client] = g_bJumpBeam[client];
		g_borg_HideChat[client] = g_bHideChat[client];
		g_borg_ViewModel[client] = g_bViewModel[client];
		g_borg_AdvInfoPanel[client] = g_bAdvInfoPanel[client];
		g_borg_ReplayRoute[client] = g_bReplayRoute[client];
		g_org_ClientLang[client] = g_ClientLang[client];
		g_borg_ErrorSounds[client] = g_bErrorSounds[client];
	}
	else
	{		
		decl String:szQuery[512];      
		if (!IsValidClient(client))
			return;
		Format(szQuery, 512, sql_insertPlayerOptions, g_szSteamID[client], 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, "weapon_knife", 0, 0, 0, 0, 1, 0, 0, g_DefaultLanguage, 1);
		SQL_TQuery(g_hDb, SQL_InsertCheckCallback, szQuery, DBPrio_Low);
		g_org_ColorChat[client] = 1;
		g_borg_InfoPanel[client] = false;
		g_borg_ClimbersMenuSounds[client] = true;
		g_org_EnableQuakeSounds[client] = 1;
		g_borg_ShowNames[client] = true
		g_borg_StrafeSync[client] = false;
		g_borg_GoToClient[client] = true;
		g_borg_ShowTime[client] = true; 
		g_borg_Hide[client] = false;
		g_org_ShowSpecs[client] = 0; 
		g_borg_StartWithUsp[client] = false;
		g_borg_CPTextMessage[client] = false;
		g_borg_AdvancedClimbersMenu[client] = true;
		g_borg_AutoBhopClient[client] = true;
		g_borg_JumpBeam[client] = false;
		g_borg_HideChat[client] = false;
		g_borg_ViewModel[client] = true;
		g_borg_AdvInfoPanel[client]=false;
		g_borg_ReplayRoute[client]=false;
		g_org_ClientLang[client] = g_DefaultLanguage;
		g_borg_ErrorSounds[client] = true;
	}
}

public db_updatePlayerOptions(client)
{
	if (g_ClientLang[client] != g_org_ClientLang[client] || g_borg_ReplayRoute[client] != g_bReplayRoute[client] ||g_borg_AdvInfoPanel[client] != g_bAdvInfoPanel[client] || g_borg_ViewModel[client] != g_bViewModel[client] || g_borg_HideChat[client] != g_bHideChat[client] || g_borg_JumpBeam[client] != g_bJumpBeam[client] || g_borg_StartWithUsp[client] != g_bStartWithUsp[client] || g_borg_AutoBhopClient[client] != g_bAutoBhopClient[client] || g_org_ColorChat[client] != g_ColorChat[client] || g_borg_InfoPanel[client] != g_bInfoPanel[client] || g_borg_ClimbersMenuSounds[client] != g_bClimbersMenuSounds[client] ||  g_org_EnableQuakeSounds[client] != g_EnableQuakeSounds[client] || g_borg_ShowNames[client] != g_bShowNames[client] || g_borg_StrafeSync[client] != g_bStrafeSync[client] || g_borg_GoToClient[client] != g_bGoToClient[client] || g_borg_ShowTime[client] != g_bShowTime[client] || g_borg_Hide[client] != g_bHide[client] || g_org_ShowSpecs[client] != g_ShowSpecs[client] || g_borg_CPTextMessage[client] != g_bCPTextMessage[client] || g_borg_AdvancedClimbersMenu[client] != g_bAdvancedClimbersMenu[client] || g_borg_ErrorSounds[client] != g_bErrorSounds[client])
	{
		decl String:szQuery[1024];
		Format(szQuery, 1024, sql_updatePlayerOptions,g_ColorChat[client],BooltoInt(g_bInfoPanel[client]),BooltoInt(g_bClimbersMenuSounds[client]), g_EnableQuakeSounds[client], BooltoInt(g_bAutoBhopClient[client]),BooltoInt(g_bShowNames[client]),BooltoInt(g_bGoToClient[client]),BooltoInt(g_bStrafeSync[client]),BooltoInt(g_bShowTime[client]),BooltoInt(g_bHide[client]),g_ShowSpecs[client],BooltoInt(g_bCPTextMessage[client]),BooltoInt(g_bAdvancedClimbersMenu[client]),"weapon_knife",0,BooltoInt(g_bStartWithUsp[client]),BooltoInt(g_bJumpBeam[client]),BooltoInt(g_bHideChat[client]),BooltoInt(g_bViewModel[client]),BooltoInt(g_bAdvInfoPanel[client]), BooltoInt(g_bReplayRoute[client]),g_ClientLang[client],BooltoInt(g_bErrorSounds[client]), g_szSteamID[client]);
		SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, client,DBPrio_Low);
	}
}

public db_viewPlayerPoints(client)
{
	g_pr_Calculating[client]=true;
	g_pr_multiplier[client] = 0;
	g_pr_finishedmaps_pro[client] = 0;
	g_pr_finishedmaps_tp[client] = 0;
	g_pr_finishedmaps_pro_perc[client] = 0.0;
	g_pr_finishedmaps_tp_perc[client] = 0.0;
	g_pr_points[client] = 0;
	decl String:szQuery[255];      
	if (!IsValidClient(client))
		return;
	Format(szQuery, 255, sql_selectRankedPlayer, g_szSteamID[client]);     
	SQL_TQuery(g_hDb, db_viewPlayerPointsCallback, szQuery,client,DBPrio_Low);	
	
}

public db_viewPlayerPointsCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
		
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{		
		g_pr_points[client]=SQL_FetchInt(hndl, 2);	
		g_pr_finishedmaps_tp[client]=SQL_FetchInt(hndl, 3);	
		g_pr_finishedmaps_pro[client] = SQL_FetchInt(hndl, 4);	
		g_pr_multiplier[client] = SQL_FetchInt(hndl, 5);
		if (g_pr_multiplier[client] < 0)
			g_pr_multiplier[client] = -1 * g_pr_multiplier[client];
		
		g_pr_finishedmaps_tp_perc[client]= (float(g_pr_finishedmaps_tp[client]) / float(g_pr_MapCountTp)) * 100.0;
		g_pr_finishedmaps_pro_perc[client]= (float(g_pr_finishedmaps_pro[client]) / float(g_pr_MapCount)) * 100.0;	
		if (IsValidClient(client))
			db_GetPlayerRank(client);
	}
	else
	{
		if (IsValidClient(client))
		{
			//insert	
			decl String:szQuery[512];
			decl String:szUName[MAX_NAME_LENGTH];
			if (IsValidClient(client))
				GetClientName(client, szUName, MAX_NAME_LENGTH);
			else
				return;			
			decl String:szName[MAX_NAME_LENGTH*2+1];      
			SQL_QuoteString(g_hDb, szUName, szName, MAX_NAME_LENGTH*2+1);	
			Format(szQuery, 512, sql_insertPlayerRank, g_szSteamID[client], szName,g_szCountry[client]); 
			SQL_TQuery(g_hDb, SQL_InsertCheckCallback, szQuery,DBPrio_Low);
			db_GetPlayerRank(client);
		}
	}
	g_pr_Calculating[client]=false;
}

/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
////////////////////////PLAYER-RANKING-SYSTEM////////////////////
/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////START/
/////////////////////////////////////////////////////////////////

public RecalcPlayerRank(client, String:steamid[128])
{
	new i = 66;
	while (g_bProfileRecalc[i] == true)
		i++;
	if (!g_bProfileRecalc[i])
	{
		decl String:szQuery[255];
		decl String:szsteamid[128*2+1];
		SQL_QuoteString(g_hDb, steamid, szsteamid, 128*2+1);    
		Format(g_pr_szSteamID[i], 32, "%s", steamid); 	
		Format(szQuery, 255, sql_selectPlayerName, szsteamid); 
		new Handle:pack = CreateDataPack();
		WritePackCell(pack, i);	
		WritePackCell(pack, client);		
		SQL_TQuery(g_hDb, sql_selectPlayerNameCallback, szQuery, pack);	    
	}
}

	
public sql_selectPlayerNameCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new Handle:pack = data;
	ResetPack(pack);
	new clientid = ReadPackCell(pack);
	new client = ReadPackCell(pack);
	CloseHandle(pack);
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		SQL_FetchString(hndl, 0, g_pr_szName[clientid], 64);			
		g_bProfileRecalc[clientid]=true;
		db_viewPersonalBhopRecord(clientid,g_pr_szSteamID[clientid]);
		db_viewPersonalMultiBhopRecord(clientid,g_pr_szSteamID[clientid]);
		db_viewPersonalWeirdRecord(clientid,g_pr_szSteamID[clientid]);
		db_viewPersonalDropBhopRecord(clientid,g_pr_szSteamID[clientid]); 
		db_viewPersonalLJRecord(clientid,g_pr_szSteamID[clientid]);
		db_viewPersonalLJBlockRecord(clientid,g_pr_szSteamID[clientid]);
		if (IsValidClient(client))
			PrintToConsole(client, "Profile refreshed (%s Total).", g_pr_szSteamID[clientid]);
	}
	else
		if (IsValidClient(client))
			PrintToConsole(client, "SteamID %s not found.", g_pr_szSteamID[clientid]);
}

public RefreshPlayerRankTable(max)
{
	g_pr_Recalc_ClientID=1;
	g_pr_RankingRecalc_InProgress=true;
	decl String:szQuery[255];
	Format(szQuery, 255, sql_selectRankedPlayers);      
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, max);
	SQL_TQuery(g_hDb, sql_selectRankedPlayersCallback, szQuery, pack,DBPrio_Low);
}

public sql_selectRankedPlayersCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new Handle:pack = data;
	ResetPack(pack);
	new maxplayers = ReadPackCell(pack);
	CloseHandle(pack);
	if(SQL_HasResultSet(hndl))
	{	
		new i = 66;
		new x;
		g_pr_TableRowCount = SQL_GetRowCount(hndl);
		if (g_pr_TableRowCount==0)
		{
			for (new c = 1; c <= MaxClients; c++)
			if (1 <= c <= MaxClients && IsValidEntity(c) && IsValidClient(c))
			{
				if (g_bManualRecalc)
					PrintToChat(c, "%t", "PrUpdateFinished", MOSSGREEN, WHITE, LIMEGREEN);
				if (g_bTop100Refresh)
					PrintToChat(c, "%t", "Top100Refreshed", MOSSGREEN, WHITE, LIMEGREEN);
			}
			
			g_bTop100Refresh = false;
			g_bManualRecalc = false;
			g_pr_RankingRecalc_InProgress = false;
			
			if (IsValidClient(g_pr_Recalc_AdminID))
			{
				PrintToConsole(g_pr_Recalc_AdminID, ">> Recalculation finished");
				CreateTimer(0.1, RefreshAdminMenu, g_pr_Recalc_AdminID,TIMER_FLAG_NO_MAPCHANGE);
			}			
		}
		if (MAX_PR_PLAYERS != maxplayers && g_pr_TableRowCount > maxplayers)
			x = 66 + maxplayers;
		else
			x = 66 + g_pr_TableRowCount;

		if (x > MAX_PR_PLAYERS)
			x = MAX_PR_PLAYERS-1;
		if (IsValidClient(g_pr_Recalc_AdminID) && g_bManualRecalc)
		{
			new max = MAX_PR_PLAYERS-66;	
			PrintToConsole(g_pr_Recalc_AdminID, " \n>> Recalculation started! (Only Top %i because of performance reasons)",max); 
		}
		while (SQL_FetchRow(hndl))
		{		
			if (i <= x)
			{
				g_pr_points[i] = 0;
				SQL_FetchString(hndl, 0, g_pr_szSteamID[i], 32);
				SQL_FetchString(hndl, 1, g_pr_szName[i], 64);		
				g_bProfileRecalc[i] = true;
				i++;	
			}
			if (i == x)
			{
				db_viewPersonalBhopRecord(66,g_pr_szSteamID[66]);
				db_viewPersonalMultiBhopRecord(66,g_pr_szSteamID[66]);
				db_viewPersonalWeirdRecord(66,g_pr_szSteamID[66]);
				db_viewPersonalDropBhopRecord(66,g_pr_szSteamID[66]);
				db_viewPersonalLadderJumpRecord(66,g_pr_szSteamID[66]);	
				db_viewPersonalCJRecord(66,g_pr_szSteamID[66]);	
				db_viewPersonalLJBlockRecord(66,g_pr_szSteamID[66]);				
				db_viewPersonalLJRecord(66,g_pr_szSteamID[66]);
			}
		}
	}
}


public CalculatePlayerRank(client)
{
	if (IsValidClient(client))
		g_pr_Calculating[client] = true;
	decl String:szQuery[255];      
	decl String:szSteamId[32];
	g_pr_oldpoints[client] = g_pr_points[client];
	g_pr_points[client] = 0;				
	if (client>MAXPLAYERS)
	{
		if (!g_pr_RankingRecalc_InProgress && !g_bProfileRecalc[client])
			return;
		Format(szSteamId, 32, "%s", g_pr_szSteamID[client]); 
	}
	else
	{
		if (!g_bPointSystem || !IsValidClient(client))
		{	
			g_pr_Calculating[client] = false;
			return;
		}
		GetClientAuthId(client, AuthId_Steam2, szSteamId, sizeof(szSteamId), true);
	}	

	Format(szQuery, 255, sql_selectRankedPlayer, szSteamId);   
	SQL_TQuery(g_hDb, sql_selectRankedPlayerCallback, szQuery,client, DBPrio_Low);	
}

public sql_selectRankedPlayerCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	decl String:szSteamId[32];
	if (client>MAXPLAYERS)
	{
		if (!g_pr_RankingRecalc_InProgress && !g_bProfileRecalc[client])
			return;
		Format(szSteamId, 32, "%s", g_pr_szSteamID[client]); 
	}
	else
	{
		if (IsValidClient(client))
			GetClientAuthId(client, AuthId_Steam2, szSteamId, sizeof(szSteamId), true);
		else
			return;
	}
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{		
		if (client <= MAXPLAYERS && IsValidClient(client))
		{
			new Float: diff = GetEngineTime() - g_fMapStartTime;
			if (GetClientTime(client) < diff)
				db_UpdateLastSeen(client);
		}
		g_pr_multiplier[client] = SQL_FetchInt(hndl, 5);
		if (g_pr_multiplier[client] < 0)
			g_pr_multiplier[client] = g_pr_multiplier[client] * -1;
		g_pr_points[client]+=  g_ExtraPoints * g_pr_multiplier[client];			
		

		//get challenge results
		decl String:szQuery[512];      
		Format(szQuery, 512, sql_selectChallenges, szSteamId,szSteamId);
		SQL_TQuery(g_hDb, sql_selectChallengesCallbackCalc, szQuery, client,DBPrio_Low);	
	}
	else
	{
		if (client <= MaxClients)
		{		
			g_pr_AllPlayers++;			
			//insert
			decl String:szQuery[255];
			decl String:szUName[MAX_NAME_LENGTH];
			GetClientName(client, szUName, MAX_NAME_LENGTH);
			decl String:szName[MAX_NAME_LENGTH*2+1];      
			SQL_QuoteString(g_hDb, szUName, szName, MAX_NAME_LENGTH*2+1);
			Format(szQuery, 255, sql_insertPlayerRank, szSteamId, szName,g_szCountry[client]); 
			SQL_TQuery(g_hDb, SQL_InsertPlayerCallBack, szQuery, client, DBPrio_Low);
			g_pr_multiplier[client] = 0;
			g_pr_Calculating[client] = false;
			g_pr_finishedmaps_pro[client] = 0;
			g_pr_finishedmaps_tp[client] = 0;
			g_pr_finishedmaps_pro_perc[client] = 0.0;
			g_pr_finishedmaps_tp_perc[client] = 0.0;
		}
	}
}

public SQL_InsertPlayerCallBack(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if (IsClientInGame(client))
		db_UpdateLastSeen(client);	
}

public sql_selectChallengesCallbackCalc(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	decl String:szQuery[512];   
	decl String:szSteamId[32];	
	decl String:szSteamIdChallenge[32];	
	
	if (client>MAXPLAYERS)
	{
		if (!g_pr_RankingRecalc_InProgress && !g_bProfileRecalc[client])
			return;
		Format(szSteamId, 32, "%s", g_pr_szSteamID[client]); 
	}
	else
	{
		if (IsValidClient(client))
			GetClientAuthId(client, AuthId_Steam2, szSteamId, sizeof(szSteamId), true);
		else
			return;
	}
	new bet;
	if(SQL_HasResultSet(hndl))
	{	
		g_Challenge_WinRatio[client] = 0;
		g_Challenge_PointsRatio[client] = 0;
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, szSteamIdChallenge, 32);
			bet = SQL_FetchInt(hndl, 2);
			if (StrEqual(szSteamIdChallenge,szSteamId))
			{
				g_Challenge_WinRatio[client]++;
				g_Challenge_PointsRatio[client]+= bet;
			}
			else
			{
				g_Challenge_WinRatio[client]--;
				g_Challenge_PointsRatio[client]-= bet;
			}
		}
	}
	if (g_bChallengePoints)
		g_pr_points[client]+= g_Challenge_PointsRatio[client];
	Format(szQuery, 512, sql_CountFinishedMapsTP, szSteamId, szSteamId);  
	SQL_TQuery(g_hDb, sql_CountFinishedMapsTPCallback, szQuery, client, DBPrio_Low);
}

public sql_CountFinishedMapsTPCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	decl String:szQuery[512];   
	decl String:szSteamId[32];
	decl String:MapName[128];
	decl String:MapName2[128];
	new finished_TP=0;
	
	if (client>MAXPLAYERS)
	{
		if (!g_pr_RankingRecalc_InProgress && !g_bProfileRecalc[client])
			return;
		Format(szSteamId, 32, "%s", g_pr_szSteamID[client]); 
	}
	else
	{
		if (IsValidClient(client))
			GetClientAuthId(client, AuthId_Steam2, szSteamId, sizeof(szSteamId), true);
		else
			return;
	}
	
	if(SQL_HasResultSet(hndl))
	{
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, MapName, 128);	
			for (new i = 0; i < GetArraySize(g_MapList); i++)
			{
				GetArrayString(g_MapList, i, MapName2, sizeof(MapName2));
				if (StrEqual(MapName2, MapName, false))
				{
					finished_TP++;
					continue;
				}
			}			
		}	
		g_pr_finishedmaps_tp[client]=finished_TP;	
		g_pr_finishedmaps_tp_perc[client]= (float(finished_TP) / float(g_pr_MapCountTp)) * 100.0;
		g_pr_points[client]+= (finished_TP * g_ExtraPoints2);

		//CountFinishedMapsPro
		Format(szQuery, 512, sql_CountFinishedMapsPro, szSteamId, szSteamId);  
		SQL_TQuery(g_hDb, sql_CountFinishedMapsProCallback, szQuery, client, DBPrio_Low);			
	}	
}

public sql_CountFinishedMapsProCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	decl String:szQuery[1024];   
	decl String:szSteamId[32];
	decl String:MapName[128];
	decl String:MapName2[128];
	new finished_Pro=0;
	
	if (client>MAXPLAYERS)
	{
		if (!g_pr_RankingRecalc_InProgress && !g_bProfileRecalc[client])
			return;
		Format(szSteamId, 32, "%s", g_pr_szSteamID[client]); 
	}
	else
	{
		if (IsValidClient(client))
			GetClientAuthId(client, AuthId_Steam2, szSteamId, sizeof(szSteamId), true);
		else
			return;
	}

	if(SQL_HasResultSet(hndl))
	{	
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, MapName, 128);	
			for (new i = 0; i < GetArraySize(g_MapList); i++)
			{
				GetArrayString(g_MapList, i, MapName2, sizeof(MapName2));
				if (StrEqual(MapName2, MapName, false))
				{
					finished_Pro++;
					continue;
				}
			}			
		}
		//pro count
		g_pr_finishedmaps_pro[client]=finished_Pro;
		g_pr_finishedmaps_pro_perc[client]= (float(finished_Pro) / float(g_pr_MapCount)) * 100.0;	
		g_pr_points[client]+= (finished_Pro * g_ExtraPoints2 * 2);
		
		Format(szQuery, 1024, sql_selectPersonalAllRecords, szSteamId, szSteamId);  	
		if ((StrContains(szSteamId, "STEAM_") != -1))
			SQL_TQuery(g_hDb, sql_selectPersonalAllRecordsCallback, szQuery, client, DBPrio_Low);			
	}	
}
public sql_selectPersonalAllRecordsCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	decl String:szQuery[1024];  
	new client = data;
	decl String:szSteamId[32];
	if (client>MAXPLAYERS)
	{
		if (!g_pr_RankingRecalc_InProgress && !g_bProfileRecalc[client])
			return;
		Format(szSteamId, 32, "%s", g_pr_szSteamID[client]); 
	}
	else
	{
		if (IsValidClient(client))
			GetClientAuthId(client, AuthId_Steam2, szSteamId, sizeof(szSteamId), true);
		else
			return;
	}
	decl String:szMapName[128];
	if(SQL_HasResultSet(hndl))
	{	
		g_pr_maprecords_row_counter[client]=0;
		g_pr_maprecords_row_count[client] = SQL_GetRowCount(hndl);
		new teleports;
		while (SQL_FetchRow(hndl))
		{		
			SQL_FetchString(hndl, 2, szMapName, 128);			
			teleports = SQL_FetchInt(hndl, 4);	
			if (teleports > 0)
				Format(szQuery, 1024, sql_selectPlayerRankTime, szSteamId, szMapName, szMapName);
			else
				Format(szQuery, 1024, sql_selectPlayerRankProTime, szSteamId, szMapName, szMapName);
			SQL_TQuery(g_hDb, sql_selectPlayerRankCallback, szQuery, client, DBPrio_Low);								
		}	
	}
	if (g_pr_maprecords_row_count[client]==0)
	{
		new Float:percentage2;
		if (g_js_CJRank[client]<21 && g_js_CJRank[client] > 0)
		{
			percentage2 = 1.05 - (float (g_js_CJRank[client]) / 20.0);
			g_pr_points[client]+= RoundToCeil(500.0 * percentage2);
		}
		if (g_js_LadderJumpRank[client]<21 && g_js_LadderJumpRank[client] > 0)
		{
			percentage2 = 1.05 - (float (g_js_LadderJumpRank[client]) / 20.0);
			g_pr_points[client]+= RoundToCeil(500.0 * percentage2);
		}
		if (g_js_LjBlockRank[client]<21 && g_js_LjBlockRank[client] > 0)
		{
			percentage2 = 1.05 - (float (g_js_LjBlockRank[client]) / 20.0);
			g_pr_points[client]+= RoundToCeil(500.0 * percentage2);
		}
		if (g_js_LjRank[client]<21 && g_js_LjRank[client] > 0)
		{
			percentage2 = 1.05 - (float (g_js_LjRank[client]) / 20.0);
			g_pr_points[client]+= RoundToCeil(500.0 * percentage2);
		}
		if (g_js_BhopRank[client]<21 && g_js_BhopRank[client] > 0)
		{
			percentage2 = 1.05 - (float (g_js_BhopRank[client]) / 20.0);
			g_pr_points[client]+= RoundToCeil(500.0 * percentage2);
		}
		if (g_js_WjRank[client]<21 && g_js_WjRank[client] > 0)
		{
			percentage2 = 1.05 - (float (g_js_WjRank[client]) / 20.0);
			g_pr_points[client]+= RoundToCeil(500.0 * percentage2);
		}
		
		if (g_js_DropBhopRank[client]<21 && g_js_DropBhopRank[client] > 0)
		{
			percentage2 = 1.05 - (float (g_js_DropBhopRank[client]) / 20.0);
			g_pr_points[client]+= RoundToCeil(500.0 * percentage2);
		}
		if (g_js_MultiBhopRank[client]<21 && g_js_MultiBhopRank[client] > 0)
		{
			percentage2 = 1.05 - (float (g_js_MultiBhopRank[client]) / 20.0);
			g_pr_points[client]+= RoundToCeil(500.0 * percentage2);
		}
		db_updatePoints(client);		
	}	
}

public 	sql_selectPlayerRankCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	decl String:szMapName[128];
	new client = data;
	decl String:szQuery[255];  
	if (hndl == INVALID_HANDLE)
		return;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		SQL_FetchString(hndl, 2, szMapName, 128);	
		new rank = SQL_GetRowCount(hndl);
		new teleports = SQL_FetchInt(hndl, 1);	
		new Handle:pack = CreateDataPack();
		WritePackCell(pack, client);
		WritePackCell(pack, rank);
		WritePackCell(pack, teleports);
		WritePackString(pack, szMapName);
		if (teleports > 0)
			Format(szQuery, 255, sql_selectPlayerCount, szMapName);
		else
			Format(szQuery, 255, sql_selectPlayerProCount, szMapName);
		SQL_TQuery(g_hDb, sql_selectPlayerRankCallback2, szQuery, pack, DBPrio_Low);
	}
}

public sql_selectPlayerRankCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new Handle:pack = data;
	ResetPack(pack);
	new client = ReadPackCell(pack);
	new rank = ReadPackCell(pack);
	new teleports = ReadPackCell(pack);
	decl String:szMap[64];
	ReadPackString(pack, szMap, 64);	
	CloseHandle(pack);
	decl String:szMapName2[128];
	
	if (hndl == INVALID_HANDLE)
		return;
	//if there is a player record
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		new count = SQL_GetRowCount(hndl);
		for (new i = 0; i < GetArraySize(g_MapList); i++)
		{
			GetArrayString(g_MapList, i, szMapName2, sizeof(szMapName2));	
			if (StrEqual(szMapName2, szMap, false))
			{	
				if (teleports == 0)
				{			
					new Float: percentage = 1.0+(1.0/float (count)) - (float (rank) / float (count));
					g_pr_points[client]+= RoundToCeil(200.0 * percentage);			
					switch(rank) 
					{
						case 1: g_pr_points[client]+= 600;
						case 2: g_pr_points[client]+= 500;
						case 3: g_pr_points[client]+= 400;
						case 4: g_pr_points[client]+= 375;
						case 5: g_pr_points[client]+= 350;
						case 6: g_pr_points[client]+= 325;
						case 7: g_pr_points[client]+= 300;
						case 8: g_pr_points[client]+= 275;
						case 9: g_pr_points[client]+= 250;
						case 10: g_pr_points[client]+= 225;
						case 11: g_pr_points[client]+= 200;
						case 12: g_pr_points[client]+= 175;
						case 13: g_pr_points[client]+= 150;
						case 14: g_pr_points[client]+= 125;
						case 15: g_pr_points[client]+= 100;
						case 16: g_pr_points[client]+= 90;
						case 17: g_pr_points[client]+= 80;
						case 18: g_pr_points[client]+= 70;
						case 19: g_pr_points[client]+= 60;
						case 20: g_pr_points[client]+= 50;
					}							
				}
				else
				{
					new Float: percentage = 1.0+(1.0/float (count)) - (float (rank) / float (count));
					g_pr_points[client]+= RoundToCeil(100.0 * percentage);					
					switch(rank) 
					{
						case 1: g_pr_points[client]+= 400;
						case 2: g_pr_points[client]+= 300;
						case 3: g_pr_points[client]+= 200;
						case 4: g_pr_points[client]+= 190;
						case 5: g_pr_points[client]+= 180;
						case 6: g_pr_points[client]+= 170;
						case 7: g_pr_points[client]+= 160;
						case 8: g_pr_points[client]+= 150;
						case 9: g_pr_points[client]+= 140;
						case 10: g_pr_points[client]+= 130;
						case 11: g_pr_points[client]+= 120;
						case 12: g_pr_points[client]+= 110;
						case 13: g_pr_points[client]+= 100;
						case 14: g_pr_points[client]+= 90;
						case 15: g_pr_points[client]+= 80;
						case 16: g_pr_points[client]+= 60;
						case 17: g_pr_points[client]+= 40;
						case 18: g_pr_points[client]+= 20;
						case 19: g_pr_points[client]+= 10;
						case 20: g_pr_points[client]+= 5;
					}																	
				}
				break;
			}				
		}
	}
	g_pr_maprecords_row_counter[client]++;
	if (g_pr_maprecords_row_counter[client]==g_pr_maprecords_row_count[client])
	{
		new Float:percentage2;
		if (g_js_CJRank[client]<21 && g_js_CJRank[client] > 0)
		{
			percentage2 = 1.05 - (float (g_js_CJRank[client]) / 20.0);
			g_pr_points[client]+= RoundToCeil(500.0 * percentage2);
		}
		if (g_js_LadderJumpRank[client]<21 && g_js_LadderJumpRank[client] > 0)
		{
			percentage2 = 1.05 - (float (g_js_LadderJumpRank[client]) / 20.0);
			g_pr_points[client]+= RoundToCeil(500.0 * percentage2);
		}
		if (g_js_LjBlockRank[client]<21 && g_js_LjBlockRank[client] > 0)
		{
			percentage2 = 1.05 - (float (g_js_LjBlockRank[client]) / 20.0);
			g_pr_points[client]+= RoundToCeil(500.0 * percentage2);
		}
		if (g_js_LjRank[client]<21 && g_js_LjRank[client] > 0)
		{
			percentage2 = 1.05 - (float (g_js_LjRank[client]) / 20.0);
			g_pr_points[client]+= RoundToCeil(500.0 * percentage2);
		}
		if (g_js_BhopRank[client]<21 && g_js_BhopRank[client] > 0)
		{
			percentage2 = 1.05 - (float (g_js_BhopRank[client]) / 20.0);
			g_pr_points[client]+= RoundToCeil(500.0 * percentage2);
		}
		if (g_js_WjRank[client]<21 && g_js_WjRank[client] > 0)
		{
			percentage2 = 1.05 - (float (g_js_WjRank[client]) / 20.0);
			g_pr_points[client]+= RoundToCeil(500.0 * percentage2);
		}
		
		if (g_js_DropBhopRank[client]<21 && g_js_DropBhopRank[client] > 0)
		{
			percentage2 = 1.05 - (float (g_js_DropBhopRank[client]) / 20.0);
			g_pr_points[client]+= RoundToCeil(500.0 * percentage2);
		}
		if (g_js_MultiBhopRank[client]<21 && g_js_MultiBhopRank[client] > 0)
		{
			percentage2 = 1.05 - (float (g_js_MultiBhopRank[client]) / 20.0);
			g_pr_points[client]+= RoundToCeil(500.0 * percentage2);
		}
		db_updatePoints(client);		
	}
}
	
/////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////UDPATE METHODS
public db_updatePoints(client)
{
	decl String:szQuery[512];
	decl String:szSteamId[32];	
	if (client>MAXPLAYERS && g_pr_RankingRecalc_InProgress || client>MAXPLAYERS && g_bProfileRecalc[client])
	{
		Format(szQuery, 512, sql_updatePlayerRankPoints, g_pr_szName[client], g_pr_points[client], g_pr_finishedmaps_tp[client],g_pr_finishedmaps_pro[client],g_Challenge_WinRatio[client],g_Challenge_PointsRatio[client], g_pr_szSteamID[client]); 
		SQL_TQuery(g_hDb, sql_updatePlayerRankPointsCallback, szQuery, client, DBPrio_Low);
	}
	else
	{
		if (IsValidClient(client))
		{
			decl String:szUName[MAX_NAME_LENGTH];
 			GetClientName(client, szUName, MAX_NAME_LENGTH);
 			decl String:szName[MAX_NAME_LENGTH*2+1];
 			SQL_QuoteString(g_hDb, szUName, szName, MAX_NAME_LENGTH*2+1);
			GetClientAuthId(client, AuthId_Steam2, szSteamId, sizeof(szSteamId), true);	
			Format(szQuery, 512, sql_updatePlayerRankPoints2, szName, g_pr_points[client], g_pr_finishedmaps_tp[client],g_pr_finishedmaps_pro[client],g_Challenge_WinRatio[client],g_Challenge_PointsRatio[client],g_szCountry[client], szSteamId); 
			SQL_TQuery(g_hDb, sql_updatePlayerRankPointsCallback, szQuery, client, DBPrio_Low);
		}
	}	
}

public db_insertLastPosition(client, String:szMapName[128])
{	 
	if(g_bRestore && !g_bRoundEnd && (StrContains(g_szSteamID[client], "STEAM_") != -1))
	{
		new Handle:pack = CreateDataPack();
		WritePackCell(pack, client);
		WritePackString(pack, szMapName);
		WritePackString(pack, g_szSteamID[client]);
		decl String:szQuery[512]; 
		Format(szQuery, 512, "SELECT * FROM playertmp WHERE steamid = '%s'",g_szSteamID[client]);
		SQL_TQuery(g_hDb,db_insertLastPositionCallback,szQuery,pack,DBPrio_Low);
	}
}

public db_insertLastPositionCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	decl String:szQuery[1024]; 
	decl String:szMapName[128]; 
	decl String:szSteamID[32]; 
	new Handle:pack = data;
	ResetPack(pack);
	new client = ReadPackCell(pack);      
	ReadPackString(pack, szMapName, 128);	
	ReadPackString(pack, szSteamID, 32);	
	CloseHandle(pack);		
	if (1 <= client <= MaxClients)
	{
		if (!g_bTimeractivated[client])
			g_fPlayerLastTime[client] = -1.0;
			
		new Float:absTime = FloatAbs(g_fPlayerLastTime[client]);
		new tickrate = g_Server_Tickrate * 5 * RoundToFloor(absTime);

		if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		{
			
			Format(szQuery, 1024, sql_updatePlayerTmp, g_fPlayerCordsLastPosition[client][0],g_fPlayerCordsLastPosition[client][1],g_fPlayerCordsLastPosition[client][2],g_fPlayerAnglesLastPosition[client][0],g_fPlayerAnglesLastPosition[client][1],g_fPlayerAnglesLastPosition[client][2], g_OverallTp[client], g_OverallCp[client], g_fPlayerLastTime[client], szMapName, tickrate,szSteamID);
			SQL_TQuery(g_hDb,SQL_CheckCallback,szQuery,DBPrio_Low);	
		}
		else
		{
			Format(szQuery, 1024, sql_insertPlayerTmp, g_fPlayerCordsLastPosition[client][0],g_fPlayerCordsLastPosition[client][1],g_fPlayerCordsLastPosition[client][2],g_fPlayerAnglesLastPosition[client][0],g_fPlayerAnglesLastPosition[client][1],g_fPlayerAnglesLastPosition[client][2], g_OverallTp[client], g_OverallCp[client], g_fPlayerLastTime[client],szSteamID, szMapName,tickrate);
			SQL_TQuery(g_hDb,SQL_CheckCallback,szQuery,DBPrio_Low);
		}
	}
}

public db_deletePlayerTmps()
{	 
	decl String:szQuery[64]; 
	Format(szQuery, 64, "delete FROM playertmp");
	SQL_TQuery(g_hDb,SQL_CheckCallback,szQuery,DBPrio_Low);	
}

public sql_updatePlayerRankPointsCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if (client>MAXPLAYERS &&  g_pr_RankingRecalc_InProgress  || client>MAXPLAYERS && g_bProfileRecalc[client])
	{		
		if (g_bProfileRecalc[client] && !g_pr_RankingRecalc_InProgress)
		{
			for (new i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i))
				{
					if(StrEqual(g_szSteamID[i],g_pr_szSteamID[client]))
						CalculatePlayerRank(i);
				}
			}
		}
		g_bProfileRecalc[client] = false;
		if (g_pr_RankingRecalc_InProgress)
		{
			new y = MAX_PR_PLAYERS - 66;
			//console info
			if (IsValidClient(g_pr_Recalc_AdminID) && g_bManualRecalc)
			{			
				if (g_pr_TableRowCount > MAX_PR_PLAYERS)
					PrintToConsole(g_pr_Recalc_AdminID, "%i/%i",g_pr_Recalc_ClientID,y); 
				else
					PrintToConsole(g_pr_Recalc_AdminID, "%i/%i",g_pr_Recalc_ClientID,g_pr_TableRowCount); 
			}
			new x = 66+g_pr_Recalc_ClientID;
			if(x < MAX_PR_PLAYERS && StrContains(g_pr_szSteamID[x],"STEAM",false)!=-1)  
			{	
				db_viewPersonalBhopRecord(x,g_pr_szSteamID[x]);
				db_viewPersonalMultiBhopRecord(x,g_pr_szSteamID[x]);
				db_viewPersonalWeirdRecord(x,g_pr_szSteamID[x]);
				db_viewPersonalDropBhopRecord(x,g_pr_szSteamID[x]); 
				db_viewPersonalLJRecord(x,g_pr_szSteamID[x]);
				db_viewPersonalLJBlockRecord(x,g_pr_szSteamID[x]);
			}
			else
			{
				for (new i = 1; i <= MaxClients; i++)
				if (1 <= i <= MaxClients && IsValidEntity(i) && IsValidClient(i))
				{
					if (g_bManualRecalc)
						PrintToChat(i, "%t", "PrUpdateFinished", MOSSGREEN, WHITE, LIMEGREEN);
					if (g_bTop100Refresh)
						PrintToChat(i, "%t", "Top100Refreshed", MOSSGREEN, WHITE, LIMEGREEN);
				}
				
				g_bTop100Refresh = false;
				g_bManualRecalc = false;
				g_pr_RankingRecalc_InProgress = false;
				
				if (IsValidClient(g_pr_Recalc_AdminID))
				{
					PrintToConsole(g_pr_Recalc_AdminID, ">> Recalculation finished");
					CreateTimer(0.1, RefreshAdminMenu, g_pr_Recalc_AdminID,TIMER_FLAG_NO_MAPCHANGE);
				}
			}		
			g_pr_Recalc_ClientID++;		
		}		
	}
	else
	{
		if (g_bRecalcRankInProgess[client] && client <= MAXPLAYERS)
		{
			ProfileMenu(client, -1);
			if (IsValidClient(client))
				PrintToChat(client, "%t", "Rc_PlayerRankFinished", MOSSGREEN,WHITE,GRAY,PURPLE,g_pr_points[client],GRAY);	
			g_bRecalcRankInProgess[client]=false;
		}
		if (IsValidClient(client) && g_pr_showmsg[client])
		{	
			decl String:szName[MAX_NAME_LENGTH];	
			GetClientName(client, szName, MAX_NAME_LENGTH);	
			new diff = g_pr_points[client] - g_pr_oldpoints[client];	
			if (diff > 0 && diff < 1001)
			{
				for (new i = 1; i <= MaxClients; i++)
					if (IsValidClient(i))
						PrintToChat(i, "%t", "EarnedPoints", MOSSGREEN, WHITE, PURPLE,szName, GRAY, PURPLE, diff,GRAY,PURPLE, g_pr_points[client], GRAY);
			}
			g_pr_showmsg[client]=false;
			db_CalculatePlayersCountGreater0();
		}
		g_pr_Calculating[client] = false;		
		db_GetPlayerRank(client);
		CreateTimer(1.0, SetClanTag, client,TIMER_FLAG_NO_MAPCHANGE);			
	}
}

public db_UpdateLastSeen(client)
{	 
	if((StrContains(g_szSteamID[client], "STEAM_") != -1) && !IsFakeClient(client))
	{
		decl String:szQuery[512]; 
		if (g_DbType == 0)
			Format(szQuery, 512, sql_UpdateLastSeenMySQL,g_szSteamID[client]);
		else
			if (g_DbType == 1)
				Format(szQuery, 512, sql_UpdateLastSeenSQLite,g_szSteamID[client]);
		SQL_TQuery(g_hDb,SQL_CheckCallback,szQuery,DBPrio_Low);
	}
}

public db_updateStat(client) 
{
	decl String:szQuery[512];
	new finishedmaps=g_pr_finishedmaps_pro[client]+g_pr_finishedmaps_tp[client];
	Format(szQuery, 512, sql_updatePlayerRank, finishedmaps, g_pr_finishedmaps_tp[client],g_pr_finishedmaps_pro[client],g_pr_multiplier[client],g_szSteamID[client]); 
	SQL_TQuery(g_hDb, SQL_UpdateStatCallback, szQuery, client, DBPrio_Low);
	
}

public SQL_UpdateStatCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	CalculatePlayerRank(client);
}


public db_viewMapRankPro(client)
{
	decl String:szQuery[512];
	if (!IsValidClient(client))
		return;
	Format(szQuery, 512, sql_selectPlayerRankProTime, g_szSteamID[client], g_szMapName, g_szMapName);
	SQL_TQuery(g_hDb, db_viewMapRankProCallback, szQuery, client,DBPrio_Low);
}

public db_viewMapRankProCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;  
	g_OldMapRankPro[client] = g_MapRankPro[client];
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		g_MapRankPro[client] = SQL_GetRowCount(hndl); 
	if (g_bMapRankToChat[client])
			MapFinishedMsgs(client, 1);		
}

public db_viewMapProRankCount()
{
	decl String:szQuery[512];
	Format(szQuery, 512, sql_selectPlayerProCount, g_szMapName);
	SQL_TQuery(g_hDb, sql_selectPlayerProCountCallback, szQuery,DBPrio_Low);
}
public sql_selectPlayerProCountCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		g_MapTimesCountPro = SQL_GetRowCount(hndl);
	else
		g_MapTimesCountPro = 0;
}

public db_viewMapRankTp(client)
{
	decl String:szQuery[512];
	if (!IsValidClient(client))
		return;
	Format(szQuery, 512, sql_selectPlayerRankTime, g_szSteamID[client], g_szMapName, g_szMapName);
	SQL_TQuery(g_hDb, db_viewMapRankTpCallback, szQuery, client,DBPrio_Low);
}

public db_viewMapRankTpCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;  
	g_OldMapRankTp[client] = g_MapRankTp[client];
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		g_MapRankTp[client] = SQL_GetRowCount(hndl); 
	if (g_bMapRankToChat[client])
			MapFinishedMsgs(client, 0);
}

public db_viewMapTpRankCount()
{
	decl String:szQuery[512];
	Format(szQuery, 512, sql_selectPlayerCount, g_szMapName);
	SQL_TQuery(g_hDb, sql_selectPlayerCountCallback, szQuery,DBPrio_Low);	
}

public sql_selectPlayerCountCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		g_MapTimesCountTp = SQL_GetRowCount(hndl);
	else
		g_MapTimesCountTp = 0;
		
}
//////////////////////////////////////////////////////
/////////////////TOP 100 PLAYERS
public db_selectTopChallengers(client)
{
	decl String:szQuery[128];       
	if (g_bChallengePoints)
		Format(szQuery, 128, sql_selectTopChallengers);   
	else
		Format(szQuery, 128, sql_selectTopChallengers2);  
	SQL_TQuery(g_hDb, sql_selectTopChallengersCallback, szQuery, client,DBPrio_Low);
}


public sql_selectTopChallengersCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{       
	new client = data;
	decl String:szValue[128];
	decl String:szName[MAX_NAME_LENGTH];
	decl String:szWinRatio[32];
	decl String:szSteamID[32];
	decl String:szPointsRatio[32];
	new winratio;
	new pointsratio;
	new Handle:menu = CreateMenu(TopChallengeHandler1);
	SetMenuPagination(menu, 5); 
	SetMenuTitle(menu, "Top 5 Challengers\n#   W/L P.-Ratio    Player (W/L ratio)");     
	if(SQL_HasResultSet(hndl))
	{
		new i = 1;
		while (SQL_FetchRow(hndl))
		{	
			SQL_FetchString(hndl, 0, szName, MAX_NAME_LENGTH);
			winratio = SQL_FetchInt(hndl, 1); 
			if (!g_bChallengePoints)
				pointsratio = 0;
			else
				pointsratio = SQL_FetchInt(hndl, 2); 
			SQL_FetchString(hndl, 3, szSteamID, 32);			
			if (winratio>=0)
				Format(szWinRatio, 32, "+%i",winratio);
			else
				Format(szWinRatio, 32, "%i",winratio);
			
			if (pointsratio>=0)
				Format(szPointsRatio, 32, "+%ip",pointsratio);
			else
				Format(szPointsRatio, 32, "%ip",pointsratio);
			


			
			if (pointsratio  < 10)
				Format(szValue, 128, "       %s         » %s (%s)", szPointsRatio, szName,szWinRatio);
			else
				if (pointsratio  < 100)
					Format(szValue, 128, "       %s       » %s (%s)", szPointsRatio, szName,szWinRatio);		
				else
					if (pointsratio  < 1000)
						Format(szValue, 128, "       %s     » %s (%s)", szPointsRatio, szName,szWinRatio);		
					else
						if (pointsratio  < 10000)
							Format(szValue, 128, "       %s   » %s (%s)", szPointsRatio, szName,szWinRatio);	
						else
							Format(szValue, 128, "       %s » %s (%s)", szPointsRatio, szName,szWinRatio);	
			AddMenuItem(menu, szSteamID, szValue, ITEMDRAW_DEFAULT);
			i++;
		}
		if(i == 1)
		{
			PrintToChat(client, "%t", "NoPlayerTop", MOSSGREEN,WHITE);
			KZTopMenu(client);
		}
		else
		{
			SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
			DisplayMenu(menu, client, MENU_TIME_FOREVER);
		}
	}
	else
	{
		PrintToChat(client, "%t", "NoPlayerTop", MOSSGREEN,WHITE);
		KZTopMenu(client);
	}
}

public db_selectTopProRecordHolders(client)
{
	decl String:szQuery[512];       
	Format(szQuery, 512, sql_selectProRecordHolders);   
	SQL_TQuery(g_hDb, db_sql_selectProRecordHoldersCallback, szQuery, client);
}

public db_sql_selectProRecordHoldersCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{       
	new client = data;
	decl String:szSteamID[32];
	decl String:szRecords[64];
	decl String:szQuery[256]; 
	new records=0;	 
	if(SQL_HasResultSet(hndl))
	{
		new i = SQL_GetRowCount(hndl);
		new x = i;
		g_hTopJumpersMenu[client] = CreateMenu(TopProHoldersHandler1);
		SetMenuTitle(g_hTopJumpersMenu[client], "Top 5 Pro Jumpers\n#   Records       Player");   
		while (SQL_FetchRow(hndl))
		{		
			SQL_FetchString(hndl, 0, szSteamID, 32);
			records = SQL_FetchInt(hndl, 1); 
			if (records > 9)
				Format(szRecords,64, "%i", records);
			else
				Format(szRecords,64, "%i  ", records);	
				
			new Handle:pack = CreateDataPack();
			WritePackCell(pack, client);
			WritePackString(pack, szRecords);
			WritePackCell(pack, i);
			WritePackString(pack, szSteamID);
			Format(szQuery, 256, sql_selectRankedPlayer, szSteamID);
			SQL_TQuery(g_hDb, db_sql_selectProRecordHoldersCallback2, szQuery, pack);
			i--;
		}
		if (x == 0)
		{
			PrintToChat(client, "%t", "NoRecordTop", MOSSGREEN,WHITE);
			KZTopMenu(client);
		}
	}
	else
	{
		PrintToChat(client, "%t", "NoRecordTop", MOSSGREEN,WHITE);
		KZTopMenu(client);
	}
}

public db_sql_selectProRecordHoldersCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{       
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		decl String:szName[MAX_NAME_LENGTH];
		decl String:szSteamID[32];
		decl String:szRecords[64];
		decl String:szValue[128];
		new Handle:pack = data;
		ResetPack(pack);
		new client = ReadPackCell(pack);      
		ReadPackString(pack, szRecords, 64);	
		new count = ReadPackCell(pack); 
		ReadPackString(pack, szSteamID, 32);	
		CloseHandle(pack);
		SQL_FetchString(hndl, 1, szName, MAX_NAME_LENGTH);
		Format(szValue, 128, "      %s       »  %s",szRecords, szName);
		AddMenuItem(g_hTopJumpersMenu[client], szSteamID, szValue, ITEMDRAW_DEFAULT);
		if (count==1)
		{
			SetMenuOptionFlags(g_hTopJumpersMenu[client], MENUFLAG_BUTTON_EXIT);
			DisplayMenu(g_hTopJumpersMenu[client], client, MENU_TIME_FOREVER);
		}
	}	
}

public db_selectTopTpRecordHolders(client)
{
	decl String:szQuery[512];       
	Format(szQuery, 512, sql_selectTpRecordHolders);   
	SQL_TQuery(g_hDb, db_sql_selectTpRecordHoldersCallback, szQuery, client,DBPrio_Low);
}

public db_sql_selectTpRecordHoldersCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{       
	new client = data;
	decl String:szSteamID[32];
	decl String:szRecords[64];
	decl String:szQuery[256]; 
	new records=0;	 
	if(SQL_HasResultSet(hndl))
	{
		new i = SQL_GetRowCount(hndl);
		new x = i;
		g_hTopJumpersMenu[client] = CreateMenu(TopTpHoldersHandler1);
		SetMenuTitle(g_hTopJumpersMenu[client], "Top 5 TP Jumpers\n#   Records       Player");   
		while (SQL_FetchRow(hndl))
		{		
			SQL_FetchString(hndl, 0, szSteamID, 32);
			records = SQL_FetchInt(hndl, 1); 
			if (records > 9)
				Format(szRecords,64, "%i", records);
			else
				Format(szRecords,64, "%i  ", records);	
				
			new Handle:pack = CreateDataPack();
			WritePackCell(pack, client);
			WritePackString(pack, szRecords);
			WritePackCell(pack, i);
			WritePackString(pack, szSteamID);
			Format(szQuery, 256, sql_selectRankedPlayer, szSteamID);
			SQL_TQuery(g_hDb, db_sql_selectTpRecordHoldersCallback2, szQuery, pack);
			i--;
		}
		if (x == 0)
		{
			PrintToChat(client, "%t", "NoRecordTop", MOSSGREEN,WHITE);
			KZTopMenu(client);
		}
	}
	else
	{
		PrintToChat(client, "%t", "NoRecordTop", MOSSGREEN,WHITE);
		KZTopMenu(client);
	}
}

public db_sql_selectTpRecordHoldersCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{       
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		decl String:szName[MAX_NAME_LENGTH];
		decl String:szSteamID[32];
		decl String:szRecords[64];
		decl String:szValue[128];
		new Handle:pack = data;
		ResetPack(pack);
		new client = ReadPackCell(pack);      
		ReadPackString(pack, szRecords, 64);	
		new count = ReadPackCell(pack); 
		ReadPackString(pack, szSteamID, 32);
		CloseHandle(pack);
		SQL_FetchString(hndl, 1, szName, MAX_NAME_LENGTH);
		Format(szValue, 128, "      %s       »  %s",szRecords, szName);
		AddMenuItem(g_hTopJumpersMenu[client], szSteamID, szValue, ITEMDRAW_DEFAULT);
		if (count==1)
		{
			SetMenuOptionFlags(g_hTopJumpersMenu[client], MENUFLAG_BUTTON_EXIT);
			DisplayMenu(g_hTopJumpersMenu[client], client, MENU_TIME_FOREVER);			
		}
	}	
}


public db_selectTopPlayers(client)
{
	decl String:szQuery[128];       
	Format(szQuery, 128, sql_selectTopPlayers);   
	SQL_TQuery(g_hDb, db_selectTop100PlayersCallback, szQuery, client,DBPrio_Low);
}

public db_selectTop100PlayersCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{       
	new client = data;
	decl String:szValue[128];
	decl String:szName[64];
	decl String:szRank[16];
	decl String:szSteamID[32];
	decl String:szPerc[16];
	new points;
	new Handle:menu = CreateMenu(TopPlayersMenuHandler1);
	SetMenuTitle(menu, "Top 100 Players\n    Rank   Points       Maps            Player");     
	SetMenuPagination(menu, 5); 
	if(SQL_HasResultSet(hndl))
	{
		new i = 1;
		while (SQL_FetchRow(hndl))
		{	
			SQL_FetchString(hndl, 0, szName, 64);
			if (i==100)
				Format(szRank, 16, "[%i.]",i);
			else
			if (i<10)
				Format(szRank, 16, "[0%i.]  ",i);
			else
				Format(szRank, 16, "[%i.]  ",i);
			points = SQL_FetchInt(hndl, 1); 
			new pro = SQL_FetchInt(hndl, 2); 
			new tp = SQL_FetchInt(hndl, 3); 
			SQL_FetchString(hndl, 4, szSteamID, 32);				
			new Float:fperc;
			new count = g_pr_MapCount+g_pr_MapCountTp;
			if (g_bAllowCheckpoints || StrEqual(g_szMapPrefix[0],"kzpro"))
				fperc =  (float(pro+tp) / (float(count))) * 100.0;
			else
				fperc =  (float(pro) / (float(g_pr_MapCount))) * 100.0;
				
			if (fperc<10.0)
				Format(szPerc, 16, "  %.1f%c  ",fperc,PERCENT);
			else
				if (fperc== 100.0)
					Format(szPerc, 16, "100.0%c",PERCENT);
				else
					if (fperc> 100.0) //player profile not refreshed after removing maps
						Format(szPerc, 16, "100.0%c",PERCENT);
					else
						Format(szPerc, 16, "%.1f%c  ",fperc,PERCENT);
						
			if (points  < 10)
				Format(szValue, 128, "%s      %ip       %s     » %s",szRank, points, szPerc,szName);
			else
				if (points  < 100)
					Format(szValue, 128, "%s     %ip       %s     » %s",szRank, points, szPerc,szName);		
				else
					if (points  < 1000)
						Format(szValue, 128, "%s   %ip       %s     » %s",szRank, points, szPerc,szName);		
					else
						if (points  < 10000)
							Format(szValue, 128, "%s %ip       %s     » %s",szRank, points, szPerc,szName);	
						else
							if (points  < 100000)
								Format(szValue, 128, "%s %ip     %s     » %s",szRank, points, szPerc,szName);	
							else
								Format(szValue, 128, "%s %ip   %s     » %s",szRank, points, szPerc,szName);	
			
			AddMenuItem(menu, szSteamID, szValue, ITEMDRAW_DEFAULT);
			i++;
		}
		if(i == 1)
		{
			PrintToChat(client, "%t", "NoPlayerTop", MOSSGREEN,WHITE);
		}
		else
		{
			SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
			DisplayMenu(menu, client, MENU_TIME_FOREVER);
		}
	}
	else
	{
		PrintToChat(client, "%t", "NoPlayerTop", MOSSGREEN,WHITE);
	}
}


public CleanupDB()
{
	SQL_TQuery(g_hDb, CleanupDBCallback, "DELETE FROM playerrank where points = '0'", DBPrio_Low);
}

public CleanupDBCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{       
	SQL_TQuery(g_hDb, SQL_CheckCallback, "DELETE FROM playerjumpstats3 where steamid NOT IN (SELECT steamid FROM playerrank)", DBPrio_Low);
}
