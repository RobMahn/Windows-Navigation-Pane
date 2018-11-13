:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Add Google Drive to Navigation Pane.bat
::
:: Written by Robert Floyd Mahn AKA %Batch Mahn%
:: Rob.Mahn@Outlook.com
::
:: Registry edits credited to:
::     Created by: Shawn Brink
::     Created on: May 1st 2016
::     Tutorial: http://www.tenforums.com/tutorials/48991-google-drive-navigation-pane-add-remove-windows-10-a.html
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: Further reference found at "Integrate a Cloud Storage Provider"
:: https://msdn.microsoft.com/en-us/library/windows/desktop/dn889934(v=vs.85).aspx
:: Note: Google Drive Sync makes no entries in HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\SyncRootManager
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: Revisions:
:: 2018-02-25 Added prompt for Google Drive location and validated the desktop.ini file.
:: 2018-02-28 Changed the CLSID.  Dropped Wow6432Node, no apparent need.  Code cleanup and documentation.
:: 2018-03-05 Prompt to restart Explorer and fix bad key cleanup, getting Administrator privileges if needed.
::            Added menu to fix the Icon Overlays
:: 2018-03-06 If Google Drive Sync is not installed and Google Drive had been added to the Navigation Pane, remove it.
:: 2018-03-07 Replace accidental deletion of CLSID {81539FE6-33C7-4CE7-90C7-1C7B8F2F2D41} original values.
:: 2018-03-25 Google moved the 64 bit version to %ProgramFiles% and renamed the 32 bit dll to googledrivesync32.dll.
::            Also fix the problem with the short directory name appearing in the desktop.ini file.
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@setlocal EnableDelayedExpansion
@cls
@color 3F
@mode con cols=80 lines=20
@title %~n0

:: Check for :RunAsAdmin BatchLabel Parms
@set Parms=%*
@if "%1" EQU "CallBatchLabel" call %Parms:CallBatchLabel=% & goto :EOF

:: Powershell command to generate a new GUID
:: powershell -Command "[guid]::NewGuid().ToString()"
@set CLSID=3935ea0f-5756-4db1-8078-d2baf2f7b7b2


::::
:: This is only for Windows 10 or above
::::
@for /f "tokens=1,2,*" %%a in ('reg query "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion" 2^>nul') do @(
	if "%%a" EQU "CurrentMajorVersionNumber" set CurrentMajorVersionNumber=%%c
)
@rem Convert HEX to Decimal
@set /a CurrentMajorVersionNumber=0+%CurrentMajorVersionNumber%
@if %CurrentMajorVersionNumber% LSS 10 (
	echo.
	echo This program only supports Windows 10 or above.
	echo.
	pause
	goto :EOF
)


::::
:: Check the environment
::::
@set GoogleDriveIconFile="%ProgramFiles%\Google\Drive\googledrivesync.exe"
@for /f "delims=" %%x in ('dir "%ProgramFiles%\Google\Drive\googledrivesync*.dll" /b') do @set GoogleDriveDLL="%ProgramFiles%\Google\Drive\%%x"

@if not exist %GoogleDriveIconFile% (
	echo.
	echo Google Drive Backup and Sync is not installed.
	reg query HKEY_CURRENT_USER\Software\Classes\CLSID\{%CLSID%} >nul 2>&1 && (
		call :DelGoogleDriveFromNagivationPane
		echo.
		echo.
		echo CLEANUP FROM PRIOR INSTALLATION:
		echo Removed Google Drive from Navigation Pane
		echo 
		call :RestartExplorer
		goto :EOF
	)
	echo.
	echo To install, go to:
	echo https://www.google.com/drive/download/
	echo.
	pause
	goto :EOF
)

::::
:: Look for Google Drive Path in the default location
::::
@set GoogleDrivePath=%USERPROFILE%\Google Drive
@goto :GoogleDrivePathTest

::::
:: Prompt for the Google Drive Path
::::
:GoogleDrivePathPrompt
@echo.
@set /p GoogleDrivePath=Enter your Google Drive Path ^> 
@set GoogleDrivePath=%GoogleDrivePath:"=%

:GoogleDrivePathTest
@if not exist "%GoogleDrivePath%" (
	echo.
	echo Path not found:
	echo "%GoogleDrivePath%"
	echo 
	goto :GoogleDrivePathPrompt
)

::::
:: Check desktop.ini
:::
@set IconFile=
@set IconIndex=
@for /f "tokens=1,2 delims==" %%x in ('type "%GoogleDrivePath%\desktop.ini" 2^>nul') do @(
	if "%%x" EQU "IconFile" set IconFile="%%y"
	if "%%x" EQU "IconIndex" set IconIndex=%%y
)
:: IconFile=C:\Program Files (x86)\Google\Drive\googledrivesync.exe
:: IconFile=C:\PROGRA~1\Google\Drive\googledrivesync.exe
:: IconIndex=15
@echo %IconFile% | find /i "\Google\Drive\googledrivesync.exe" || (
	:: echo IconFile Mismatch 
	echo.
	echo Directory is not a Google Sync Drive
	echo "%GoogleDrivePath%"
	echo 
	goto :GoogleDrivePathPrompt
)

@if "%IconIndex%" NEQ "15" (
	:: echo IconIndex Mismatch
	echo.
	echo Directory is not a Google Sync Drive
	echo "%GoogleDrivePath%"
	echo 
	goto :GoogleDrivePathPrompt
)
	

:: ******************************  GOTO LABEL  ****************************
:Menu
:: ******************************  GOTO LABEL  ****************************
@cls
@color 3F
@mode con cols=80 lines=21
@echo.
@echo  þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ
@echo            WARNING: Changes will prompt to restart Windows Explorer!
@echo  þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ
@echo.
@echo  Google Drive Path:
@echo  "%GoogleDrivePath%"
@echo.
@echo  NOTE: If you have reinstalled Google Drive Sync and moved the location,
@echo        make sure your are referencing the new active Google Drive Path.
@echo.
@echo  A    Add Google Drive to Navigation Pane
@echo  C    Change the Google Drive Path
@echo  D    Delete Google Drive from Navigation Pane
@echo  F    Fix / Manage Icon Overlays
@echo  V    View associated registry entries
@echo.
@echo  X    Exit
@echo.
@choice /C ACDFVX /M "Choice: "
@echo.
:: Account for ErrorLevel 0 if Ctrl-C is used.
@      if %errorlevel% EQU 0 ( goto :Menu
) else if %errorlevel% EQU 1 ( call :AddGoogleDriveToNavigationPane & cls & call :RestartExplorer
) else if %errorlevel% EQU 2 ( goto :GoogleDrivePathPrompt
) else if %errorlevel% EQU 3 ( call :DelGoogleDriveFromNagivationPane & cls & call :RestartExplorer
) else if %errorlevel% EQU 4 ( call :IconOverlaysMenu
) else if %errorlevel% EQU 5 ( call :ViewRegistry
) else if %errorlevel% EQU 6 ( goto :EOF)
@goto :Menu


::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
:AddGoogleDriveToNavigationPane
::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
@call :CleanupOldEntries

:: Step 1: Add your CLSID and name your extension
@reg add HKEY_CURRENT_USER\Software\Classes\CLSID\{%CLSID%} /f /ve /t REG_SZ /d "Google Drive" >nul 2>&1

:: Step 2: Set the image for your icon
@reg add HKEY_CURRENT_USER\Software\Classes\CLSID\{%CLSID%}\DefaultIcon /f /ve /t REG_EXPAND_SZ /d "%GoogleDriveIconFile:"=%,%IconIndex%" >nul 2>&1

:: Step 3: Add your extension to the Navigation Pane and make it visible
@reg add HKEY_CURRENT_USER\Software\Classes\CLSID\{%CLSID%} /f /v System.IsPinnedToNamespaceTree /t REG_DWORD /d 0x1 >nul 2>&1

:: Step 4: Set the location for your extension in the Navigation Pane
@reg add HKEY_CURRENT_USER\Software\Classes\CLSID\{%CLSID%} /f /v SortOrderIndex /t REG_DWORD /d 0x42 >nul 2>&1

:: Step 5: Provide the dll that hosts your extension.
@reg add HKEY_CURRENT_USER\Software\Classes\CLSID\{%CLSID%}\InProcServer32 /f /ve /t REG_EXPAND_SZ /d "%SystemRoot%\system32\shell32.dll" >nul 2>&1

:: Step 6: Define the instance object
@reg add HKEY_CURRENT_USER\Software\Classes\CLSID\{%CLSID%}\Instance /f /v CLSID /t REG_SZ /d "{0E5AAE11-A475-4c5b-AB00-C66DE400274E}" >nul 2>&1

:: Step 7: Provide the file system attributes of the target folder
@reg add HKEY_CURRENT_USER\Software\Classes\CLSID\{%CLSID%}\Instance\InitPropertyBag /f /v Attributes /t REG_DWORD /d 0x11 >nul 2>&1

:: Step 8: Set the path for the sync root
@reg add HKEY_CURRENT_USER\Software\Classes\CLSID\{%CLSID%}\Instance\InitPropertyBag /f /v TargetFolderPath /t REG_EXPAND_SZ /d "%GoogleDrivePath%" >nul 2>&1

:: Step 9: Set appropriate shell flags
@reg add HKEY_CURRENT_USER\Software\Classes\CLSID\{%CLSID%}\ShellFolder /f /v FolderValueFlags /t REG_DWORD /d 0x28 >nul 2>&1

:: Step 10: Set the appropriate flags to control your shell behavior
@reg add HKEY_CURRENT_USER\Software\Classes\CLSID\{%CLSID%}\ShellFolder /f /v Attributes /t REG_DWORD /d 0xF080004D >nul 2>&1

:: Step 11: Register your extension in the namespace root
@reg add HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{%CLSID%} /f /ve /t REG_SZ /d "Google Drive" >nul 2>&1

:: Step 12: Hide your extension from the Desktop
@reg add HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /f /v {%CLSID%} /t REG_DWORD /d 0x1 >nul 2>&1

@goto :EOF


::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
:DelGoogleDriveFromNagivationPane
::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
@call :CleanupOldEntries

@reg delete HKEY_CURRENT_USER\Software\Classes\CLSID\{%CLSID%} /f >nul 2>&1
@reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /f /v {%CLSID%} >nul 2>&1
@reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{%CLSID%} /f >nul 2>&1

@goto :EOF

::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
:CleanupOldEntries
::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
:: Remove old entries that used a duplicate CLSID
@set CLSIDBAD=81539FE6-33C7-4CE7-90C7-1C7B8F2F2D41
@reg delete HKEY_CURRENT_USER\Software\Classes\CLSID\{%CLSIDBAD%} /f >nul 2>&1
@reg delete HKEY_CURRENT_USER\Software\Classes\Wow6432Node\CLSID\{%CLSIDBAD%} /f >nul 2>&1
@reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /f /v {%CLSIDBAD%} >nul 2>&1
@reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{%CLSIDBAD%} /f >nul 2>&1
:: Accidental bad key created
@reg delete HKEY_CURRENT_USER\Software\ClassesWow6432Node\CLSID\{%CLSIDBAD%} /f >nul 2>&1

:: Remove HKCR entries created by .reg file
:: To remove the registry virtualization, the HKCU key must be removed first.
@reg delete HKEY_CURRENT_USER\Software\Classes\CLSID\{%CLSID%} /f >nul 2>&1

:: Cleanup HKEY_CLASSES_ROOT
@reg query HKEY_CLASSES_ROOT\CLSID\{%CLSID%} >nul 2>&1 && (
	echo.
	echo _____________________________________________________________________________
	echo ROOT registry key removal of
	echo HKEY_CLASSES_ROOT\CLSID\{%CLSID%}
	echo will require administrator rights
	echo.
	pause
	powershell Start-Process -Verb RunAs -FilePath 'reg' -ArgumentList 'delete HKEY_CLASSES_ROOT\CLSID\{%CLSID%} /f' 2>nul
)

@reg query "HKEY_CLASSES_ROOT\CLSID\{%CLSIDBAD%}" /ve >nul 2>&1 | find "Google Drive Shell extension" >nul 2>&1 && (
	echo.
	echo _____________________________________________________________________________
	echo ROOT registry key repair of:
	echo HKEY_CLASSES_ROOT\CLSID\{%CLSIDBAD%} /ve /t REG_SZ /d "Google Drive Shell extension"
	echo will require administrator rights
	echo.
	pause
	powershell Start-Process -Verb RunAs -FilePath 'reg' -ArgumentList 'add HKEY_CLASSES_ROOT\CLSID\{%CLSIDBAD%} /f /ve /t REG_SZ /d """Google Drive Shell extension"""' 2>nul
)

@reg query "HKEY_CLASSES_ROOT\CLSID\{%CLSIDBAD%}\InProcServer32" /ve >nul 2>&1 | find %GoogleDriveDLL% >nul 2>&1 && (
	echo.
	echo _____________________________________________________________________________
	echo ROOT registry key repair of:
	echo HKEY_CLASSES_ROOT\CLSID\{%CLSIDBAD%}\InProcServer32  /ve /t REG_SZ /d %GoogleDriveDLL%
	echo will require administrator rights
	echo.
	pause
	powershell Start-Process -Verb RunAs -FilePath 'reg' -ArgumentList 'add HKEY_CLASSES_ROOT\CLSID\{%CLSIDBAD%}\InProcServer32 /f /ve /t REG_SZ /d """%GoogleDriveDLL%"""' 2>nul
)

@reg query "HKEY_CLASSES_ROOT\CLSID\{%CLSIDBAD%}\InProcServer32" /v ThreadingModel >nul 2>&1 | find "Apartment" >nul 2>&1 && (
	echo.
	echo _____________________________________________________________________________
	echo ROOT registry key repair of:
	echo HKEY_CLASSES_ROOT\CLSID\{%CLSIDBAD%}\InProcServer32 /v ThreadingModel /t REG_SZ /d Apartment
	echo will require administrator rights
	echo.
	pause
	powershell Start-Process -Verb RunAs -FilePath 'reg' -ArgumentList 'add HKEY_CLASSES_ROOT\CLSID\{%CLSIDBAD%}\InProcServer32 /f /v ThreadingModel /t REG_SZ /d Apartment' 2>nul
)

@goto :EOF


::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
:ViewRegistry
::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
@set Width=140
@set Height=50
@set BufferWidth=%Width%
@set BufferHeight=100
@mode con: cols=%Width% lines=%Height% & echo Setting window buffers ... & powershell -command "&{$H=get-host;$W=$H.ui.rawui;$B=$W.buffersize;$B.width=%BufferWidth%;$B.height=%BufferHeight%;$W.buffersize=$B;}" & cls

@echo.
@echo *********************************************************************
@echo Good values, if they exist:
@echo *********************************************************************
@reg query HKEY_CURRENT_USER\Software\Classes\CLSID\{%CLSID%} /s 2>nul
@reg query HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /v {%CLSID%} 2>nul
@reg query HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{%CLSID%} /s 2>nul
@echo.
@echo *********************************************************************
@echo Bad values, if they exist can be removed by running Add or Delete:
@echo *********************************************************************
:: Display global entries only
@reg query HKEY_CURRENT_USER\Software\Classes\CLSID\{%CLSID%} >nul 2>&1 || reg query HKEY_CLASSES_ROOT\CLSID\{%CLSID%} /s 2>nul

:: Display values using the bad CLSID
@set CLSIDBAD=81539FE6-33C7-4CE7-90C7-1C7B8F2F2D41
@reg query HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /v {%CLSIDBAD%} /s 2>nul | find /v "0 match"
@reg query HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{%CLSIDBAD%} /s 2>nul
@echo.
@pause
@goto :EOF


::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
:IconOverlaysMenu
::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
@cls
@color 1F
@mode con cols=80 lines=21
@echo.
@echo  þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ
@echo            WARNING: Changes will prompt to restart Windows Explorer!
@echo  þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ
@echo.
@echo.
@echo  P    Prioritize Google Overlays (Add copies with more leading spaces)
@echo  R    Remove Prioritze Google Overlays
@echo  V    View Icon Overlays
@echo.
@echo  H    Help
@echo.
@echo  X    Exit to Main Menu
@echo.
@choice /C PRVHX /M "Choice: "
@echo.
:: Account for ErrorLevel 0 if Ctrl-C is used.
@      if %errorlevel% EQU 0 ( goto :Menu
) else if %errorlevel% EQU 1 ( call :RunAsAdmin WAIT HIDDEN :PrioritizeGoogleIconOverlays && cls & call :RestartExplorer
) else if %errorlevel% EQU 2 ( call :RunAsAdmin WAIT HIDDEN :RemovePrioritizeGoogleIconOverlays && cls & call :RestartExplorer
) else if %errorlevel% EQU 3 ( call :ViewIconOverlays
) else if %errorlevel% EQU 4 ( call :IconOverlaysHelp
) else if %errorlevel% EQU 5 ( goto :EOF)
@goto :IconOverlaysMenu


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
:IconOverlaysHelp
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
@echo.
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


::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
:RunAsAdmin <NOWAIT or WAIT or HIDDEN) BatchLabel Parms
::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
:: Default is NOWAIT
@set WAIT=
@set HIDDEN=
@set ARGS=
:RunAsAdminNextArg
@set ARG=%1
@if not defined ARG goto :RunAsAdminNoMoreArgs
@if /i "%ARG:"=%" EQU "WAIT" set WAIT=-Wait & shift /1 & goto :RunAsAdminNextArg
@if /i "%ARG:"=%" EQU "HIDDEN" set HIDDEN=-WindowStyle Hidden & shift /1 & goto :RunAsAdminNextArg
@set ARGS=%ARGS% %ARG%
@shift /1
@goto :RunAsAdminNextArg
:RunAsAdminNoMoreArgs
@set ARGS=%ARGS:"="""%
@powershell Start-Process %WAIT% %HIDDEN% -Verb RunAs -FilePath 'cmd.exe' -ArgumentList '/c """ """%~dpnx0""" CallBatchLabel %ARGS% """' 2>nul
:: @echo Powershell retured: %errorlevel%
:: @if errorlevel 1 pause
@goto :EOF
