:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Add Folder to Navigation Pane.bat
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
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: Revisions:
:: 2018-06-04 Release
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@setlocal EnableDelayedExpansion
@cls
@color 3F
@mode con cols=80 lines=20
@title %~n0

:: Check for :RunAsAdmin BatchLabel Parms
@set Parms=%*
:: @if "%1" EQU "CallBatchLabel" call %Parms:CallBatchLabel=% & goto :EOF


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

@call :GetFolderPath

:: ******************************  Menu  ****************************
:Menu
:: ******************************  Menu  ****************************
@call :GetExistingCLSID
@if defined FoundCLSID goto :DeleteMenu else goto :AddMenu

:: ******************************  GOTO LABEL  ****************************
:AddMenu
:: ******************************  GOTO LABEL  ****************************
@cls
@color 3F
@mode con cols=80 lines=21
@echo.
@echo  þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ
@echo            WARNING: Changes will prompt to restart Windows Explorer!
@echo  þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ
@echo.
@echo  Note: Consider just right clicking on the folder and "Pin to Quick access."
@echo.
@echo  Folder Path to add to the Navigation Pane:
@echo  "%FolderPath%"
@echo.
@echo  A    Add Folder to Navigation Pane
@echo  C    Change the Folder Path
@echo.
@echo  X    Exit
@echo.
@choice /C ACX /M "Choice: "
@echo.
:: Account for ErrorLevel 0 if Ctrl-C is used.
@      if %errorlevel% EQU 0 ( goto :Menu
) else if %errorlevel% EQU 1 ( call :AddFolderToNavigationPane & cls & call :RestartExplorer
) else if %errorlevel% EQU 2 ( call :GetFolderPath
) else if %errorlevel% EQU 3 ( goto :EOF)
@goto :Menu


:: ******************************  GOTO LABEL  ****************************
:DeleteMenu
:: ******************************  GOTO LABEL  ****************************
@cls
@color 1E
@mode con cols=80 lines=21
@echo.
@echo  þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ
@echo            WARNING: Changes will prompt to restart Windows Explorer!
@echo  þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ
@echo.
@echo  Folder Path is already added to the Nagivagion Pane:
@echo  "%FolderPath%"
@echo.
@echo  C    Change the Folder Path
@echo  D    Delete Folder from Navigation Pane
@echo  V    View associated registry entries
@echo.
@echo  X    Exit
@echo.
@choice /C CDVX /M "Choice: "
@echo.
:: Account for ErrorLevel 0 if Ctrl-C is used.
@      if %errorlevel% EQU 0 ( goto :Menu
) else if %errorlevel% EQU 1 ( call :GetFolderPath
) else if %errorlevel% EQU 2 ( call :DelFolderFromNagivationPane & cls & call :RestartExplorer
) else if %errorlevel% EQU 3 ( call :ViewRegistry
) else if %errorlevel% EQU 4 ( goto :EOF)
@goto :Menu


::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
:GetFolderPath
::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
@echo.
@set /p FolderPath=Enter your Folder Path ^> 
@set FolderPath=%FolderPath:"=%

:FolderPathTest
@if not exist "%FolderPath%" (
	echo.
	echo Path not found:
	echo "%FolderPath%"
	echo 
	goto :GetFolderPath
)
@call :GetFolderPathName "%FolderPath%"
@goto :EOF


::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
:GetFolderPathName
::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
@set FolderPathName=%~n1
@goto :EOF


::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
:GetExistingCLSID
::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
@set FoundCLSID=
@for /f "delims=	" %%x in ('reg query HKEY_CURRENT_USER\Software\Classes\CLSID /f "%FolderPath%" /s ^| find "Instance\InitPropertyBag"') do @(
	set FoundCLSID=%%x
)
@if not defined FoundCLSID goto :EOF
@set FoundCLSID=%FoundCLSID:HKEY_CURRENT_USER\Software\Classes\CLSID\{=%
@set FoundCLSID=%FoundCLSID:}\Instance\InitPropertyBag=%
:: @echo %FoundCLSID% & pause
@goto :EOF

::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
:AddFolderToNavigationPane
::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
:: Generate a new CLSID
@for /f "delims=" %%x in ('powershell -Command "[guid]::NewGuid().ToString()"') do @set CLSID=%%x

:: Retrieve Folder ICON from desktop.ini
@for /f "tokens=2,3 delims==," %%x in ('type "%FolderPath%\desktop.ini" ^| find "IconResource"') do @(
	set FolderIconFile=%%x
	set IconIndex=%%y
)

:: Step 1: Add your CLSID and name your extension
@reg add HKEY_CURRENT_USER\Software\Classes\CLSID\{%CLSID%} /f /ve /t REG_SZ /d "%FolderPathName%" >nul 2>&1

:: Step 2: Set the image for your icon
@reg add HKEY_CURRENT_USER\Software\Classes\CLSID\{%CLSID%}\DefaultIcon /f /ve /t REG_EXPAND_SZ /d "%FolderIconFile:"=%,%IconIndex%" >nul 2>&1

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

:: Step 8: Set the path for the folder
@reg add HKEY_CURRENT_USER\Software\Classes\CLSID\{%CLSID%}\Instance\InitPropertyBag /f /v TargetFolderPath /t REG_EXPAND_SZ /d "%FolderPath%" >nul 2>&1

:: Step 9: Set appropriate shell flags
@reg add HKEY_CURRENT_USER\Software\Classes\CLSID\{%CLSID%}\ShellFolder /f /v FolderValueFlags /t REG_DWORD /d 0x28 >nul 2>&1

:: Step 10: Set the appropriate flags to control your shell behavior
@reg add HKEY_CURRENT_USER\Software\Classes\CLSID\{%CLSID%}\ShellFolder /f /v Attributes /t REG_DWORD /d 0xF080004D >nul 2>&1

:: Step 11: Register your extension in the namespace root
@reg add HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{%CLSID%} /f /ve /t REG_SZ /d "Folder" >nul 2>&1

:: Step 12: Hide your extension from the Desktop
@reg add HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /f /v {%CLSID%} /t REG_DWORD /d 0x1 >nul 2>&1

@goto :EOF


::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::
:DelFolderFromNagivationPane
::::::::::::::::::::::::::::::::  SUBROUTINE  :::::::::::::::::::::::::::::

@reg delete HKEY_CURRENT_USER\Software\Classes\CLSID\{%FoundCLSID%} /f >nul 2>&1
@reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /f /v {%FoundCLSID%} >nul 2>&1
@reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{%FoundCLSID%} /f >nul 2>&1

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
@echo Folder values, if they exist:
@echo *********************************************************************
@reg query HKEY_CURRENT_USER\Software\Classes\CLSID\{%CLSID%} /s 2>nul
@reg query HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /v {%CLSID%} 2>nul
@reg query HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{%CLSID%} /s 2>nul
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
