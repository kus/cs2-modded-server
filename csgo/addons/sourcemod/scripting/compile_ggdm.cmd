@echo off 

set DIR_SERVER_SOURCEMOD=H:\games\csgo_ds\csgo\addons\sourcemod
set DIR_SERVER_SCRIPTING=%DIR_SERVER_SOURCEMOD%\scripting
set DIR_SERVER_PLUGINS=%DIR_SERVER_SOURCEMOD%\plugins

set DIR_SOURCES_SOURCEMOD=C:\home\altex\git\css_plugins\sm_ggdm\addons\sourcemod
set DIR_SOURCES_SCRIPTING=%DIR_SOURCES_SOURCEMOD%\scripting
set DIR_SOURCES_PLUGINS=%DIR_SOURCES_SOURCEMOD%\plugins

set LOG_COMPILE=%DIR_SOURCES_SCRIPTING%\compile.log

xcopy /e /f /y %DIR_SOURCES_SCRIPTING%\*.* %DIR_SERVER_SCRIPTING%\

cd /d %DIR_SERVER_SCRIPTING%

echo %DATE% %TIME% > %LOG_COMPILE%

%DIR_SERVER_SCRIPTING%\spcomp sm_ggdm.sp                    >> %LOG_COMPILE%
%DIR_SERVER_SCRIPTING%\spcomp sm_ggdm_spawnprotection.sp    >> %LOG_COMPILE%
%DIR_SERVER_SCRIPTING%\spcomp sm_ggdm_spawns.sp             >> %LOG_COMPILE%
%DIR_SERVER_SCRIPTING%\spcomp sm_ggdm_firstspawn.sp         >> %LOG_COMPILE%
%DIR_SERVER_SCRIPTING%\spcomp sm_ggdm_ragdoll.sp            >> %LOG_COMPILE%
%DIR_SERVER_SCRIPTING%\spcomp sm_ggdm_weapons.sp            >> %LOG_COMPILE%
%DIR_SERVER_SCRIPTING%\spcomp sm_ggdm_elimination.sp        >> %LOG_COMPILE%

copy %DIR_SERVER_SCRIPTING%\sm_ggdm.smx                     %DIR_SOURCES_PLUGINS%\
copy %DIR_SERVER_SCRIPTING%\sm_ggdm_spawnprotection.smx     %DIR_SOURCES_PLUGINS%\
copy %DIR_SERVER_SCRIPTING%\sm_ggdm_spawns.smx              %DIR_SOURCES_PLUGINS%\
copy %DIR_SERVER_SCRIPTING%\sm_ggdm_firstspawn.smx          %DIR_SOURCES_PLUGINS%\
copy %DIR_SERVER_SCRIPTING%\sm_ggdm_ragdoll.smx             %DIR_SOURCES_PLUGINS%\
copy %DIR_SERVER_SCRIPTING%\sm_ggdm_weapons.smx             %DIR_SOURCES_PLUGINS%\
copy %DIR_SERVER_SCRIPTING%\sm_ggdm_elimination.smx         %DIR_SOURCES_PLUGINS%\

copy %DIR_SERVER_SCRIPTING%\sm_ggdm.smx                     %DIR_SERVER_PLUGINS%\
copy %DIR_SERVER_SCRIPTING%\sm_ggdm_spawnprotection.smx     %DIR_SERVER_PLUGINS%\
copy %DIR_SERVER_SCRIPTING%\sm_ggdm_spawns.smx              %DIR_SERVER_PLUGINS%\
copy %DIR_SERVER_SCRIPTING%\sm_ggdm_firstspawn.smx          %DIR_SERVER_PLUGINS%\
copy %DIR_SERVER_SCRIPTING%\sm_ggdm_ragdoll.smx             %DIR_SERVER_PLUGINS%\
copy %DIR_SERVER_SCRIPTING%\sm_ggdm_weapons.smx             %DIR_SERVER_PLUGINS%\
copy %DIR_SERVER_SCRIPTING%\sm_ggdm_elimination.smx         %DIR_SERVER_PLUGINS%\

cd /d %DIR_SOURCES_SCRIPTING%
