
@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

set MyPath="%CD%"
cd !MyPath!

if [%1]==[] goto nofolder

if not exist spcomp.exe goto nospcomp

:loop
For /R %1 %%G IN (*.sp) do (

spcomp %%G

set RelativePath=%%~dG%%~pG

call:ReplaceText "!RelativePath!" !MyPath! "" RESULT
Set RESULT=!RESULT:~1!
Set RESULT=!RESULT:~0,-1!

set RelativePath=!RESULT!

REM Remove quotes.
set MyPath=!MyPath:"=!

if not exist !MyPath!\compiled\!RelativePath! md !MyPath!\compiled\!RelativePath!
move !MyPath!\%%~nG.smx !MyPath!\compiled\!RelativePath! >nul 2>nul


echo.
)

shift
if not [%1]==[] goto loop

echo Press enter to exit
pause >nul
exit

goto eof

:nofolder

echo Error: No folder was fed to this file
echo.
echo Please Drag and Drop a folder to this file in order to compile the files inside it.
echo.
echo Press enter to exit
pause >nul
exit

:nospcomp

echo Error: spcomp.exe was not found in the same folder as this file.
echo.
echo Press enter to exit
pause >nul
exit

:FUNCTIONS
@REM FUNCTIONS AREA
GOTO:EOF
EXIT /B

:ReplaceText
::Replace Text In String
::USE:
:: CALL:ReplaceText "!OrginalText!" OldWordToReplace NewWordToUse  Result
::Example
::SET "MYTEXT=jump over the chair"
::  echo !MYTEXT!
::  call:ReplaceText "!MYTEXT!" chair table RESULT
::  echo !RESULT!
::
:: Remember to use the "! on the input text, but NOT on the Output text.
:: The Following is Wrong: "!MYTEXT!" !chair! !table! !RESULT!
:: ^^Because it has a ! around the chair table and RESULT
:: Remember to add quotes "" around the MYTEXT Variable when calling.
:: If you don't add quotes, it won't treat it as a single string
::
set "OrginalText=%~1"
set "OldWord=%~2"
set "NewWord=%~3"
call set OrginalText=%%OrginalText:!OldWord!=!NewWord!%%
SET %4=!OrginalText!
GOTO:EOF