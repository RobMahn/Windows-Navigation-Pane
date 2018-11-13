:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Windows Explorer Navigation Pane Duplicate Removable Drives Manager.bat
::
:: Written by Robert Floyd Mahn AKA %Batch Mahn%
:: Rob.Mahn@Outlook.com
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: Revisions:
:: 2018-06-06 Release
::     
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@setlocal EnableDelayedExpansion
@cls
@color 3F
@mode con cols=80 lines=20
@title %~n0


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


:::::::::::::::::::::::::::::::::::::::
:: Run with Administrator privileges ::
:::::::::::::::::::::::::::::::::::::::
@setlocal EnableDelayedExpansion
@>nul 2>&1 "%SYSTEMROOT%\system32\fsutil.exe" dirty query "%SystemDrive%" || (
	mode con cols=40 lines=5 & color 4E & echo. & echo Elevating to Administrator ...
	set args=%*
	if defined args set args=!args:"="""!
	powershell Start-Process -Verb RunAs -FilePath 'cmd.exe' -ArgumentList '/c """ """%~dpnx0""" !args! """' 2>nul
	goto :EOF
)
@endlocal


:: ******************************  Menu  ****************************
:Main_Menu
:: ******************************  Menu  ****************************
@cls
@mode con cols=80 lines=21
@echo.
@echo  þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ
@echo       Windows Explorer Navigation Pane Duplicate Removable Drives Manager
@echo  þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ

@>nul 2>&1 reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}"
@if errorlevel 1 (goto :AddMenu) else (goto :DeleteMenu)

:: ******************************  GOTO LABEL  ****************************
:AddMenu
:: ******************************  GOTO LABEL  ****************************
@color 3F
@echo.
@echo  A    Add default duplicate external drives to Navigation Pane
@echo.
@echo  X    Exit
@echo.
@choice /C AX /M "Choice: "
@echo.
:: Account for ErrorLevel 0 if Ctrl-C is used.
@      if %errorlevel% EQU 0 ( goto :Main_Menu
) else if %errorlevel% EQU 1 (
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}" /d "Removable Drives"
	reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node" && reg add "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}" /d "Removable Drives"
) else if %errorlevel% EQU 2 ( goto :EOF)
@goto :Main_Menu


:: ******************************  GOTO LABEL  ****************************
:DeleteMenu
:: ******************************  GOTO LABEL  ****************************
@color 1E
@echo.
@echo  D    Delete default duplicate external drives from Navigation Pane
@echo       (After deleting, you will be able to add it back in.)
@echo.
@echo  X    Exit
@echo.
@choice /C DX /M "Choice: "
@echo.
:: Account for ErrorLevel 0 if Ctrl-C is used.
@      if %errorlevel% EQU 0 ( goto :Main_Menu
) else if %errorlevel% EQU 1 (
	reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}" /f
	reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}" /f
) else if %errorlevel% EQU 2 ( goto :EOF)
@goto :Main_Menu




Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}]
@="Removable Drives"

[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}]
@="Removable Drives"
