CREATE TABLE IF NOT EXISTS PlayerStageTimes (
                                            MapName VARCHAR(255),
                                            SteamID VARCHAR(20),
                                            PlayerName VARCHAR(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
                                            Stage INT,
                                            TimerTicks INT,
                                            FormattedTime VARCHAR(255),
                                            Velocity VARCHAR(255),
                                            PRIMARY KEY (MapName, SteamID, Stage)
                                        );