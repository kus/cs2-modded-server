CREATE TABLE IF NOT EXISTS PlayerStageTimes (
                                            MapName TEXT,
                                            SteamID TEXT,
                                            PlayerName TEXT,
                                            Stage INT,
                                            TimerTicks INT,
                                            FormattedTime TEXT,
                                            Velocity TEXT,
                                            PRIMARY KEY (MapName, SteamID, Stage)
                                        );