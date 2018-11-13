:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Icon Overlays Manager.bat
::
:: Written by Robert Floyd Mahn AKA %Batch Mahn%
:: Rob.Mahn@Outlook.com
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: Problem with sync overlay icons limit:
:: https://www.itwriting.com/blog/9456-the-battle-to-own-windows-explorer-shell-overlay-icons-or-why-your-onedrive-green-ticks-have-stopped-working.html
:: https://answers.microsoft.com/en-us/windows/forum/windows_10-start-win_desk/icon-overlays-less-than-15/b4f59d5c-9a17-4d95-8651-610c1ede4a11
:: https://www.ghacks.net/2016/07/24/fix-sync-icons-not-showing-explorer/
:: https://www.dropboxforum.com/t5/Dropbox/Shell-Overlay-Icons/idi-p/111622/page/10#comments
:: List your ShellIconOverlayIdentifiers with:
:: reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers
:: reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\explorer\ShellIconOverlayIdentifiers
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: Revisions:
:: 2018-02-28 Initial revision.
:: 2018-03-03 Use powershell to run as administrator
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@setlocal
@cls
@color 3F
@title %~n0

:::::::::::::::::::::::::::::::::::::::
:: Run with Administrator privileges ::
:::::::::::::::::::::::::::::::::::::::
@setlocal EnableDelayedExpansion
@>nul 2>&1 "%SYSTEMROOT%\system32\fsutil.exe" dirty query "%SystemDrive%" || (
	set args=%*
	if defined args set args=!args:"="""!
	powershell Start-Process -Verb RunAs -FilePath 'cmd.exe' -ArgumentList '/c """ """%~dpnx0""" !args! """' 2>nul
	exit /B
)
@endlocal



::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
:Menu
::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
@cls
@mode con cols=80 lines=20
@color 3F
@echo.
@echo.
@echo  þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ
@echo            WARNING: Changes will restart the Windows Explorer!
@echo  þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ
@echo.
@echo.
@echo  P    Prioritize Google Overlays (Add copies with more leading spaces)
@echo  R    Remove Prioritze Google Overlays
@echo  A    Add DropBox Icon Overlays
@echo  D    Delete DropBox Icon Overlays
@echo  V    View Icon Overlays
@echo.
@echo  H    Help
@echo.
@echo  X    Exit
@echo.
@choice /C PRADVHX /M "Choice: "
@echo.
:: Account for ErrorLevel 0 if Ctrl-C is used.
@      if %errorlevel% EQU 0 ( goto :Menu
) else if %errorlevel% EQU 1 ( call :PrioritizeGoogleIconOverlays & call :RestartExplorer
) else if %errorlevel% EQU 2 ( call :RemovePrioritizeGoogleIconOverlays & call :RestartExplorer
) else if %errorlevel% EQU 3 ( call :AddDropboxIconOverlays & call :RestartExplorer
) else if %errorlevel% EQU 4 ( call :DeleteDropboxIconOverlays & call :RestartExplorer
) else if %errorlevel% EQU 5 ( call :ViewIconOverlays
) else if %errorlevel% EQU 6 ( call :Help
) else if %errorlevel% EQU 7 ( goto :EOF)
@goto :Menu


::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
:PrioritizeGoogleIconOverlays
::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
@call :DeleteGoogleDriveOverlays

:: Add prioritized values - Using 0x01, SOH character to beat all the
:: cloud drives that keep adding more spaces.
@set PriorityString=" "
@call :AddGoogleDriveOverlays

@goto :EOF


::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
:RemovePrioritizeGoogleIconOverlays
::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
@call :DeleteGoogleDriveOverlays

:: Restore original values
:: Default has 2 spaces
@set PriorityString="  "
@call :AddGoogleDriveOverlays

@goto :EOF


::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
:AddGoogleDriveOverlays
::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
@> nul 2>&1 reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\%PriorityString:"=%GoogleDriveBlacklisted" /f /ve /t REG_SZ /d "{81539FE6-33C7-4CE7-90C7-1C7B8F2F2D42}"
@> nul 2>&1 reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\%PriorityString:"=%GoogleDriveSynced"      /f /ve /t REG_SZ /d "{81539FE6-33C7-4CE7-90C7-1C7B8F2F2D40}"
@> nul 2>&1 reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\%PriorityString:"=%GoogleDriveSyncing"     /f /ve /t REG_SZ /d "{81539FE6-33C7-4CE7-90C7-1C7B8F2F2D41}"
@goto :EOF


::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
:DeleteGoogleDriveOverlays
::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
@for %%x in (81539FE6-33C7-4CE7-90C7-1C7B8F2F2D40 81539FE6-33C7-4CE7-90C7-1C7B8F2F2D41 81539FE6-33C7-4CE7-90C7-1C7B8F2F2D42) do @(
	for /f "delims=" %%y in ('reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\ /s /f {%%x} 2^>nul ^| find "HKEY"') do @(
		 > nul 2>&1 reg delete "%%y" /f 
	)
)
@goto :EOF


::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
:AddDropboxIconOverlays
::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
@> nul 2>&1 reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt01" /f /ve /t REG_SZ /d "{FB314ED9-A251-47B7-93E1-CDD82E34AF8B}"
@> nul 2>&1 reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt02" /f /ve /t REG_SZ /d "{FB314EDF-A251-47B7-93E1-CDD82E34AF8B}"
@> nul 2>&1 reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt03" /f /ve /t REG_SZ /d "{FB314EE1-A251-47B7-93E1-CDD82E34AF8B}"
@> nul 2>&1 reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt04" /f /ve /t REG_SZ /d "{FB314EDB-A251-47B7-93E1-CDD82E34AF8B}"
@> nul 2>&1 reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt05" /f /ve /t REG_SZ /d "{FB314EDA-A251-47B7-93E1-CDD82E34AF8B}"
@> nul 2>&1 reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt06" /f /ve /t REG_SZ /d "{FB314EDC-A251-47B7-93E1-CDD82E34AF8B}"
@> nul 2>&1 reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt07" /f /ve /t REG_SZ /d "{FB314EDD-A251-47B7-93E1-CDD82E34AF8B}"
@> nul 2>&1 reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt08" /f /ve /t REG_SZ /d "{FB314EE0-A251-47B7-93E1-CDD82E34AF8B}"
@> nul 2>&1 reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt09" /f /ve /t REG_SZ /d "{FB314EE2-A251-47B7-93E1-CDD82E34AF8B}"
@> nul 2>&1 reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt10" /f /ve /t REG_SZ /d "{FB314EDE-A251-47B7-93E1-CDD82E34AF8B}"

@if defined ProgramFiles(x86) >nul 2>&1 reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt01" /f /ve /t REG_SZ /d "{FB314ED9-A251-47B7-93E1-CDD82E34AF8B}"
@if defined ProgramFiles(x86) >nul 2>&1 reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt02" /f /ve /t REG_SZ /d "{FB314EDF-A251-47B7-93E1-CDD82E34AF8B}"
@if defined ProgramFiles(x86) >nul 2>&1 reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt03" /f /ve /t REG_SZ /d "{FB314EE1-A251-47B7-93E1-CDD82E34AF8B}"
@if defined ProgramFiles(x86) >nul 2>&1 reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt04" /f /ve /t REG_SZ /d "{FB314EDB-A251-47B7-93E1-CDD82E34AF8B}"
@if defined ProgramFiles(x86) >nul 2>&1 reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt05" /f /ve /t REG_SZ /d "{FB314EDA-A251-47B7-93E1-CDD82E34AF8B}"
@if defined ProgramFiles(x86) >nul 2>&1 reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt06" /f /ve /t REG_SZ /d "{FB314EDC-A251-47B7-93E1-CDD82E34AF8B}"
@if defined ProgramFiles(x86) >nul 2>&1 reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt07" /f /ve /t REG_SZ /d "{FB314EDD-A251-47B7-93E1-CDD82E34AF8B}"
@if defined ProgramFiles(x86) >nul 2>&1 reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt08" /f /ve /t REG_SZ /d "{FB314EE0-A251-47B7-93E1-CDD82E34AF8B}"
@if defined ProgramFiles(x86) >nul 2>&1 reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt09" /f /ve /t REG_SZ /d "{FB314EE2-A251-47B7-93E1-CDD82E34AF8B}"
@if defined ProgramFiles(x86) >nul 2>&1 reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt10" /f /ve /t REG_SZ /d "{FB314EDE-A251-47B7-93E1-CDD82E34AF8B}"

@goto :EOF


::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
:DeleteDropboxIconOverlays
::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
@> nul 2>&1 reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt01" /f
@> nul 2>&1 reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt02" /f
@> nul 2>&1 reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt03" /f
@> nul 2>&1 reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt04" /f
@> nul 2>&1 reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt05" /f
@> nul 2>&1 reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt06" /f
@> nul 2>&1 reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt07" /f
@> nul 2>&1 reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt08" /f
@> nul 2>&1 reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt09" /f
@> nul 2>&1 reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt10" /f

@if defined ProgramFiles(x86) >nul 2>&1 reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt01" /f 
@if defined ProgramFiles(x86) >nul 2>&1 reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt02" /f 
@if defined ProgramFiles(x86) >nul 2>&1 reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt03" /f 
@if defined ProgramFiles(x86) >nul 2>&1 reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt04" /f 
@if defined ProgramFiles(x86) >nul 2>&1 reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt05" /f 
@if defined ProgramFiles(x86) >nul 2>&1 reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt06" /f 
@if defined ProgramFiles(x86) >nul 2>&1 reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt07" /f 
@if defined ProgramFiles(x86) >nul 2>&1 reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt08" /f 
@if defined ProgramFiles(x86) >nul 2>&1 reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt09" /f 
@if defined ProgramFiles(x86) >nul 2>&1 reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers\   DropboxExt10" /f 

@goto :EOF


::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
:ViewIconOverlays
::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
@call :ConsoleSize 140 60 140 100
@reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers
@echo.
@if defined ProgramFiles(x86) (
	echo.
	echo Some providers add entries in the Wow6432Node keys, shown here ...
	reg query HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers
)
@echo.
@pause
@goto :EOF


::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
:Help
::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
@mode con cols=80 lines=50
@color 2E
@echo.
@echo  Date: 2018-03-05
@echo.
@echo  If you use cloud storage applications such as OneDrive, Google Drive,
@echo  or Dropbox, you will be familiar with the idea of files in Explorer
@echo  showing little icons to indicate their state: synced, not synced,
@echo  in conflict, excluded and so on.
@echo.
@echo  A common complaint is that while everything still works, the icon
@echo  status indicators no longer appear.
@echo.
@echo  There are two reasons. One is that Windows has a limit of 15 overlay
@echo  icons. If more than that are specified (by multiple applications) then
@echo  anything over the limit does not work.
@echo.
@echo  The second is that multiple applications cannot apply overlays to the same
@echo  file. So if you tried to set up your DropBox in a OneDrive folder
@echo  (do not do this), one or other would win the overlay battle but not both.
@echo.
@echo  Icon Overlays are loaded in sorted order and the first 15 win.
@echo.
@echo  DropBox uses 10 and makes it's registry entries with four spaces at the
@echo  beginning to win priority.
@echo    e.g. "...\ShellIconOverlayIdentifiers\   DropboxExt01"
@echo.
@echo  This script prioritizes Google Drive by preceding it with a 0x01 character.
@echo  This will win over any number of preceeding spaces.
@echo.
@echo  If it's important to you that a particular synchronization solution icon
@echo  overlays work, they must be listed first.
@echo.
@echo  You can delete registry entries, rename them, or create copies that sort
@echo  to the top.  Keep in mind that re-installations or updates will restore
@echo  the default entries and you will have to re-prioritize again.
@echo.
@echo  Here is an excellent article, "THE BATTLE TO OWN WINDOWS EXPLORER SHELL
@echo  OVERLAY ICONS, OR WHY YOUR ONEDRIVE GREEN TICKS HAVE STOPPED WORKING":
@echo https://www.itwriting.com/blog/9456-the-battle-to-own-windows-explorer-shell-overlay-icons-or-why-your-onedrive-green-ticks-have-stopped-working.html
@echo.
@echo  Here is a good discussion, "Icon Overlays less than 15":
@echo https://answers.microsoft.com/en-us/windows/forum/windows_10-start-win_desk/icon-overlays-less-than-15/b4f59d5c-9a17-4d95-8651-610c1ede4a11
@echo.
@echo. I am uncertain of the effect of the Wow6432Node registry entries on the count
@echo  and have not tried testing the limit of 15 to specific functional overlays.
@echo.
@pause
@goto :EOF


::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
:RestartExplorer
::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
@cls
@echo.
@echo _____________________________________________________________________________
@echo Explorer must be restarted for the changes to take effect.
@echo Otherwise, they will take effect the next time you login.
@echo.
@>nul 2>&1 "%SYSTEMROOT%\system32\fsutil.exe" dirty query "%SystemDrive%" && (
	echo Explorer will be restarted with the Administrator Privileges of this session.
	echo To restart Exporer normally, kill and restart it from the TaskManager
	echo or logout and login.
) 
:: Pause to read message
@echo.
@choice /m "Restart Explorer now"
@if errorlevel 2 goto :EOF
@endlocal
@taskkill /f /im explorer.exe
@start explorer.exe
:: Open explorer window
@start explorer.exe
@goto :EOF


::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
:ConsoleSize  Window_Width<-Buffer_Width>  Window_Height<-Buffer_Height>
::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
:: Examples ...
:: @call :ConsoleSize
:: @call :ConsoleSize 120 30-300
:: @call :ConsoleSize 120-200 30-60
@set Width=%1
@set Height=%2
@set Window_Width=
@set Buffer_Width=
@set Window_Height=
@set Buffer_Height=
@if defined Width for /f "tokens=1,2 delims=-" %%x in ('echo %Width%') do @(
		set Window_Width=%%x
		set Buffer_Width=%%y
)
@if defined Height for /f "tokens=1,2 delims=-" %%x in ('echo %Height%') do @(
		set Window_Height=%%x
		set Buffer_Height=%%y
	)
)
:: Set defaults if values not defined
@if not defined Window_Width set Window_Width=80
@if not defined Buffer_Width set Buffer_Width=%Window_Width%
@if not defined Window_Height set Window_Height=25
@if not defined Buffer_Height set Buffer_Height=300
@mode con: cols=%Window_Width% lines=%Window_Height% & echo Setting window buffers ... & powershell -command "&{$H=get-host;$W=$H.ui.rawui;$B=$W.buffersize;$B.width=%Buffer_Width%;$B.height=%Buffer_Height%;$W.buffersize=$B;}" & cls
@goto :EOF
