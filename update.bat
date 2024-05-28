@echo off
SetLocal EnableDelayedExpansion

title CS2 Update

cls

:: Perform git pull
git pull

:: Check if the git pull was successful
if %errorlevel% neq 0 (
    echo Git pull failed!
    echo Was this folder cloned from git?
    echo git clone https://github.com/kus/cs2-modded-server.git
    pause

) else (
    :: Wait for a few seconds
    timeout /t 3 /nobreak > NUL

    :: Run win.bat script
    start win.bat
)

EndLocal