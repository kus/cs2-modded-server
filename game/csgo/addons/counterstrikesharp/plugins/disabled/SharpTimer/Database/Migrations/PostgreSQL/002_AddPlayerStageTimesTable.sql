CREATE TABLE IF NOT EXISTS "PlayerStageTimes" (
                                            "MapName" VARCHAR(255),
                                            "SteamID" VARCHAR(20),
                                            "PlayerName" VARCHAR(32),
                                            "Stage" INT,
                                            "TimerTicks" INT,
                                            "FormattedTime" VARCHAR(255),
                                            "Velocity" VARCHAR(255),
                                            PRIMARY KEY ("MapName", "SteamID", "Stage")
                                        );