@echo off
echo.
echo MyJailbreak compile script
echo.
echo.
echo. Check if 'plugins/MyJailbreak/' folder exist.
if not exist "../plugins/MyJailbreak/" mkdir "../plugins/MyJailbreak/"
echo.
echo.
echo Compile: MyJailbreak Core
spcomp MyJailbreak/myjailbreak.sp -o../plugins/MyJailbreak/myjailbreak.smx
echo.
echo Compile: MyJailbreak Menu
spcomp MyJailbreak/menu.sp -o../plugins/MyJailbreak/menu.smx 
echo.
echo Compile: MyJailbreak Last Guard Rule
spcomp MyJailbreak/lastguard.sp -o../plugins/MyJailbreak/lastguard.smx 
echo.
echo Compile: MyJailbreak PlayerTags
spcomp MyJailbreak/playertags.sp -o../plugins/MyJailbreak/playertags.smx 
echo.
echo Compile: MyJailbreak Warden
spcomp MyJailbreak/warden.sp -o../plugins/MyJailbreak/warden.smx 
echo.
echo Compile: MyJailbreak Weapons
spcomp MyJailbreak/weapons.sp -o../plugins/MyJailbreak/weapons.smx 
echo.
echo Compile: MyJailbreak Request
spcomp MyJailbreak/request.sp -o../plugins/MyJailbreak/request.smx 
echo.
echo Compile: MyJailbreak HUD
spcomp MyJailbreak/hud.sp -o../plugins/MyJailbreak/hud.smx 
echo.
echo Compile: MyJailbreak Ratio
spcomp MyJailbreak/ratio.sp -o../plugins/MyJailbreak/ratio.smx 
echo.
echo Compile: MyJailbreak Icons
spcomp MyJailbreak/icons.sp -o../plugins/MyJailbreak/icons.smx 
echo.
echo.
echo Compile: MyJailbreak Event Days
echo.
echo.
echo Compile: MyJailbreak Event Day Arms Race
spcomp MyJailbreak/armsrace.sp -o../plugins/MyJailbreak/armsrace.smx 
echo.
echo Compile: MyJailbreak Event Day CatchFreeze
spcomp MyJailbreak/catch.sp -o../plugins/MyJailbreak/catch.smx 
echo.
echo Compile: MyJailbreak Event Day DuckHunt
spcomp MyJailbreak/duckhunt.sp -o../plugins/MyJailbreak/duckhunt.smx 
echo.
echo Compile: MyJailbreak Event Day FreeForAll
spcomp MyJailbreak/ffa.sp -o../plugins/MyJailbreak/ffa.smx 
echo.
echo Compile: MyJailbreak Event Day FreeDay
spcomp MyJailbreak/freeday.sp -o../plugins/MyJailbreak/freeday.smx 
echo.
echo Compile: MyJailbreak Event Day HE Battle
spcomp MyJailbreak/hebattle.sp -o../plugins/MyJailbreak/hebattle.smx 
echo.
echo Compile: MyJailbreak Event Day HideInTheDark
spcomp MyJailbreak/hide.sp -o../plugins/MyJailbreak/hide.smx 
echo.
echo Compile: MyJailbreak Event Day SuicideBomber
spcomp MyJailbreak/suicide.sp -o../plugins/MyJailbreak/suicide.smx 
echo.
echo Compile: MyJailbreak Event Day Teleport
spcomp MyJailbreak/teleport.sp -o../plugins/MyJailbreak/teleport.smx 
echo.
echo Compile: MyJailbreak Event Day KnifeFight
spcomp MyJailbreak/knife.sp -o../plugins/MyJailbreak/knife.smx 
echo.
echo Compile: MyJailbreak Event Day No scope
spcomp MyJailbreak/noscope.sp -o../plugins/MyJailbreak/noscope.smx 
echo.
echo Compile: MyJailbreak Event Day War
spcomp MyJailbreak/war.sp -o../plugins/MyJailbreak/war.smx 
echo.
echo Compile: MyJailbreak Event Day Zeus
spcomp MyJailbreak/zeus.sp -o../plugins/MyJailbreak/zeus.smx 
echo.
echo Compile: MyJailbreak Event Day Cowboy
spcomp MyJailbreak/cowboy.sp -o../plugins/MyJailbreak/cowboy.smx 
echo.
echo Compile: MyJailbreak Event Day Drunk
spcomp MyJailbreak/drunk.sp -o../plugins/MyJailbreak/drunk.smx 
echo.
echo Compile: MyJailbreak Event Day Torch Relay
spcomp MyJailbreak/torch.sp -o../plugins/MyJailbreak/torch.smx 
echo.
echo Compile: MyJailbreak Event Day Zombie
spcomp MyJailbreak/zombie.sp -o../plugins/MyJailbreak/zombie.smx 
echo.
echo Compile: MyJailbreak Event Day Deal Damage
spcomp MyJailbreak/dealdamage.sp -o../plugins/MyJailbreak/dealdamage.smx 
echo.
echo Compile: MyJailbreak Event Day Ghosts
spcomp MyJailbreak/ghosts.sp -o../plugins/MyJailbreak/ghosts.smx 
echo.
echo Compile: MyJailbreak Event Day One in the chamber
spcomp MyJailbreak/oneinthechamber.sp -o../plugins/MyJailbreak/oneinthechamber.smx 
echo.
echo.
echo. Check if 'plugins/MyJailbreak/disabled' folder exist.
if not exist "../plugins/MyJailbreak/disabled" mkdir "../plugins/MyJailbreak/disabled"
echo.
echo.
echo Compile: MyJailbreak  Add-ons
echo.
echo.
echo Compile: MyJailbreak Add-on Support addicted CT Ban
spcomp MyJailbreak/Add-ons/ratio_ctbans_addicted.sp -o../plugins/MyJailbreak/disabled/ratio_ctbans_addicted.smx 
echo.
echo Compile: MyJailbreak Add-on Support databomb CT Ban
spcomp MyJailbreak/Add-ons/ratio_ctbans_databomb.sp -o../plugins/MyJailbreak/disabled/ratio_ctbans_databomb.smx  
echo.
echo Compile: MyJailbreak Add-on Support r1ko CT Ban
spcomp MyJailbreak/Add-ons/ratio_ctbans_r1ko.sp -o../plugins/MyJailbreak/disabled/ratio_ctbans_r1ko.smx  
echo.
echo Compile: MyJailbreak Add-on Support bara TeamBans
spcomp MyJailbreak/Add-ons/ratio_teambans.sp -o../plugins/MyJailbreak/disabled/ratio_teambans.smx  
echo.
echo Compile: MyJailbreak Add-on Support Steamrep
spcomp MyJailbreak/Add-ons/ratio_steamrep.sp -o../plugins/MyJailbreak/disabled/ratio_steamrep.smx  
echo.
echo Compile: MyJailbreak Add-on Support hl gangs
spcomp MyJailbreak/Add-ons/myjailbreak_gangs.sp -o../plugins/MyJailbreak/disabled/myjailbreak_gangs.smx  
echo.
echo Compile: MyJailbreak Add-on Support VIP core
spcomp MyJailbreak/Add-ons/ratio_vipcore.sp -o../plugins/MyJailbreak/disabled/ratio_vipcore.smx  
echo.
echo Compile: MyJailbreak Add-on Support DevZones
spcomp MyJailbreak/Add-ons/myjailbreak_devzones.sp -o../plugins/MyJailbreak/disabled/myjailbreak_devzones.smx  
echo.
echo Compile: MyJailbreak Add-on Support MostActive
spcomp MyJailbreak/Add-ons/myjailbreak_mostactive.sp -o../plugins/MyJailbreak/disabled/myjailbreak_mostactive.smx
echo.
echo Compile: MyJailbreak Add-on Support Steamgroups
spcomp MyJailbreak/Add-ons/myjailbreak_steamgroups.sp -o../plugins/MyJailbreak/disabled/myjailbreak_steamgroups.smx  
echo.
echo Compile: MyJailbreak Add-on Support stamm
spcomp MyJailbreak/Add-ons/myjailbreak_stamm.sp -o../plugins/MyJailbreak/disabled/myjailbreak_stamm.smx  
echo.
echo Compile: MyJailbreak Add-on Support Reputation
spcomp MyJailbreak/Add-ons/myjailbreak_reputation.sp -o../plugins/MyJailbreak/disabled/myjailbreak_reputation.smx  
echo.
echo Compile: MyJailbreak Add-on Support Kento RankMe
spcomp MyJailbreak/Add-ons/myjailbreak_kento_rankme.sp -o../plugins/MyJailbreak/disabled/myjailbreak_kento_rankme.smx  
echo.
echo Compile: MyJailbreak Add-on Support SM Store
spcomp MyJailbreak/Add-ons/myjailbreak_sm-store_credits.sp -o../plugins/MyJailbreak/disabled/myjailbreak_sm-store_credits.smx  
echo.
echo Compile: MyJailbreak Add-on Support simplestats
spcomp MyJailbreak/Add-ons/myjailbreak_simplestats.sp -o../plugins/MyJailbreak/disabled/myjailbreak_simplestats.smx
echo.
echo Compile: MyJailbreak Add-on add custom menu item
spcomp MyJailbreak/Add-ons/menu_custom.sp -o../plugins/MyJailbreak/disabled/menu_custom.smx
echo.
echo Compile: MyJailbreak Add-on toggles for event days
spcomp MyJailbreak/Add-ons/eventday_toggle.sp -o../plugins/MyJailbreak/disabled/eventday_toggle.smx
echo.
echo Compile: MyJailbreak Add-on Support Voiceannouce_ex
spcomp MyJailbreak/Add-ons/ratio_voiceannounce_ex.sp -o../plugins/MyJailbreak/disabled/ratio_voiceannounce_ex.smx
echo.
pause