@echo off
SetLocal EnableDelayedExpansion

title CS2

:: Set variables
set ROOT_DIR=%~dp0
set "gameinfo=server\game\csgo\gameinfo.gi"
set "searchString=Game	csgo/addons/metamod"
set "insertAfter=Game_LowViolence	csgo_lv"
set "bakFile=%gameinfo%.bak"
set "tempFile=%gameinfo%.tmp"
if not exist win.ini copy NUL win.ini
for /f %%S in (win.ini) do set %%S

cls

echo If you want to quit, close the CS2 window and type Y followed by Enter.

:: Ensure steamcmd exists
if not exist "%ROOT_DIR%steamcmd\steamcmd.exe" (
    echo steamcmd\steamcmd.exe does not exist!
    goto end
)

:: Use SteamCMD to download CS2
echo Using SteamCMD to check for updates.
start /wait %ROOT_DIR%steamcmd\steamcmd.exe +force_install_dir ../server +login anonymous +app_update 730 +quit

:: Ensure gameinfo.gi exists
if not exist "%ROOT_DIR%%gameinfo%" (
    echo The file %gameinfo% does not exist.
    goto end
)

:: Create a backup file if it doesn't exist
if not exist "%bakFile%" (
    echo Attempting to create backup file of %gameinfo%...
    copy "%gameinfo%" "%bakFile%"
    if %errorlevel% neq 0 (
        echo Failed to create backup file. Error: %errorlevel%
        goto end
    ) else (
        echo Backup file %bakFile% created successfully.
    )
) else (
    echo Backup file %gameinfo% already exists.
)

:: Check if searchString exists in the file
echo Checking if %gameinfo% has already been patched...
findstr /m /c:"%searchString%" "%gameinfo%" >nul
if %errorlevel%==0 (
    echo %gameinfo% has already been patched.
    goto start
) else (
    echo %gameinfo% needs to be patched...
)

:: Read the file, check each line for the insertAfter substring, and insert searchString
> "%tempFile%" (
    set "added=0"
    for /f "tokens=* delims=" %%a in ('findstr /n "^" "%gameinfo%"') do (
        set "line=%%a"
        setlocal enabledelayedexpansion
        set "line=!line:*:=!"
        if "!line!" neq "" ( 
            if "!line!"=="!line:%insertAfter%=!" (
                echo(!line!
            ) else (
                if "!added!"=="0" (
                    echo(!line!
                    echo(			%searchString%
                    set "added=1"
                )
            )
        ) else (
            echo(
        )
        endlocal
    )
)

:: Replace the original file with the modified content
if exist "%tempFile%" (
    echo Temporary file %tempFile% created successfully. Preparing to replace %gameinfo%...
    move /y "%tempFile%" "%gameinfo%"
    if %errorlevel% neq 0 (
        echo Failed to replace original file. Error: %errorlevel%
        goto end
    ) else (
        echo %gameinfo% has successfully been patched.
    )
) else (
    echo Failed to create or modify temporary file %tempFile%. Potential access issue or write protection.
)

:start

:: Deleting addons folder so no old plugins are left to cause issues
:: If you have modifications in your addons/ folder they should be in custom_files as these are merged at the end
echo Deleting addons folder.
rmdir /S /Q "%ROOT_DIR%server\game\csgo\addons\"

:: Patch server with mod files
echo Copying mod files.
xcopy "%ROOT_DIR%game\csgo\*" "%ROOT_DIR%server\game\csgo\" /K /S /E /I /H /Y >NUL

:: Merge Windows specific files
echo Merging Windows specific files.
xcopy "%ROOT_DIR%game\csgo\addons\windows\*" "%ROOT_DIR%server\game\csgo\addons\" /K /S /E /I /H /Y >NUL

:: Merge your custom files in
echo Copying custom files from "%custom_folder%".
xcopy "%ROOT_DIR%%custom_folder%\*" "%ROOT_DIR%server\game\csgo\" /K /S /E /I /H /Y >NUL

:: Start the server
echo CS2 started.
start /wait %ROOT_DIR%server\game\bin\win64\cs2.exe -dedicated -console -debug -condebug -conclearlog -usercon +game_type 0 +game_mode 0 +mapgroup mg_active +map de_dust2 -port %PORT% -ip 0.0.0.0 +net_public_adr %IP% -tickrate %TICKRATE% -maxplayers %MAXPLAYERS% -authkey %API_KEY% +sv_setsteamaccount %STEAM_ACCOUNT% +sv_lan %LAN% +sv_password %SERVER_PASSWORD% +rcon_password %RCON_PASSWORD% +exec %EXEC%
echo WARNING: CS2 closed or crashed.

:end
pause
EndLocal
