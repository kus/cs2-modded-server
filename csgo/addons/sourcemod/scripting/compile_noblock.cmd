@echo off 

xcopy /e /f /y D:\home\altex\css_plugins-trunk\sm_noblock\addons\sourcemod\scripting\*.* D:\games\css_server\orangebox\cstrike\addons\sourcemod\scripting\

cd D:\games\css_server\orangebox\cstrike\addons\sourcemod\scripting\

echo %DATE%  %TIME% > D:\home\altex\css_plugins-trunk\sm_noblock\addons\sourcemod\scripting\compile_noblock.log

D:\games\css_server\orangebox\cstrike\addons\sourcemod\scripting\spcomp noblock.sp >> D:\home\altex\css_plugins-trunk\sm_noblock\addons\sourcemod\scripting\compile_noblock.log

copy D:\games\css_server\orangebox\cstrike\addons\sourcemod\scripting\noblock.smx D:\home\altex\css_plugins-trunk\sm_noblock\addons\sourcemod\plugins\

copy D:\games\css_server\orangebox\cstrike\addons\sourcemod\scripting\noblock.smx D:\games\css_server\orangebox\cstrike\addons\sourcemod\plugins\

cd D:\home\altex\css_plugins-trunk\sm_noblock\addons\sourcemod
