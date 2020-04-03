char trainingModelBall[128] = "models/soccer_mod/ball_2014.mdl";

public void RegisterServerCommandsTraining()
{
    RegServerCmd
    (
        "soccer_mod_training_model_ball",
        ServerCommandsTraining,
        "Sets the model of the training ball - values: path/to/dir/file.mdl"
    );
}

public Action ServerCommandsTraining(int args)
{
    char serverCommand[50], cmdArg1[32];
    GetCmdArg(0, serverCommand, sizeof(serverCommand));
    GetCmdArg(1, cmdArg1, sizeof(cmdArg1));

    if (StrEqual(serverCommand, "soccer_mod_training_model_ball"))
    {
        char cmdArgString[128];
        GetCmdArgString(cmdArgString, sizeof(cmdArgString));

        if (FileExists(cmdArgString, true))
        {
            trainingModelBall = cmdArgString;

            if (!IsModelPrecached(trainingModelBall)) PrecacheModel(trainingModelBall);

            PrintToServer("%s Training ball model set to %s", PREFIX, cmdArgString);
            PrintToChatAll("%s Training ball model set to %s", PREFIX, cmdArgString);
        }
        else
        {
            PrintToServer("%s Can't set training ball model to %s", PREFIX, cmdArgString);
            PrintToChatAll("%s Can't set training ball model to %s", PREFIX, cmdArgString);
        }
    }

    return Plugin_Handled;
}