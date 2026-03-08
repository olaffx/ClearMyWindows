@echo off
title Windows Debloater
color 0A
echo ===============================================
echo          Windows 10/11 Debloater Script
echo ===============================================
echo.
echo This script will:
echo   - Remove pre-installed bloatware apps
echo   - Disable telemetry and data collection
echo   - Turn off Cortana and Xbox features
echo   - Disable OneDrive (optional)
echo   - Disable unnecessary background apps
echo   - Clean temporary files
echo.
echo It is recommended to create a system restore point before proceeding.
echo.
set /p choice="Do you want to create a restore point? (Y/N): "
if /i "%choice%"=="Y" call :CreateRestorePoint

:AdminCheck
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This script must be run as Administrator.
    echo Please right-click and select "Run as administrator".
    pause
    exit /b
)

echo.
echo Press any key to start debloating...
pause >nul

echo.
echo Removing bloatware apps...

powershell -Command "$apps = @('Microsoft.BingNews','Microsoft.BingWeather','Microsoft.BingSports','Microsoft.BingFinance','Microsoft.GetHelp','Microsoft.Getstarted','Microsoft.Messaging','Microsoft.Microsoft3DViewer','Microsoft.MicrosoftOfficeHub','Microsoft.MicrosoftSolitaireCollection','Microsoft.MixedReality.Portal','Microsoft.Office.OneNote','Microsoft.OneConnect','Microsoft.People','Microsoft.Print3D','Microsoft.SkypeApp','Microsoft.Wallet','Microsoft.WindowsAlarms','Microsoft.WindowsCamera','Microsoft.WindowsCommunicationsApps','Microsoft.WindowsFeedbackHub','Microsoft.WindowsMaps','Microsoft.WindowsSoundRecorder','Microsoft.Xbox.TCUI','Microsoft.XboxApp','Microsoft.XboxGameCallableUI','Microsoft.XboxGamingOverlay','Microsoft.XboxIdentityProvider','Microsoft.XboxSpeechToTextOverlay','Microsoft.YourPhone','Microsoft.ZuneMusic','Microsoft.ZuneVideo','Microsoft.MSPaint','Microsoft.Todos','Microsoft.PowerAutomateDesktop','Microsoft.Windows.DevHome','Clipchamp.Clipchamp','Disney','SpotifyAB.SpotifyMusic'); foreach ($app in $apps) { Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue; Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $app | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue }; Write-Host 'Bloatware removal completed.'"

if %errorlevel% neq 0 (
    echo [Warning] PowerShell command may have encountered errors. Some apps might not be removed.
)

echo.
echo Disabling telemetry and data collection...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" /v TailoredExperiencesWithDiagnosticDataEnabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v PreventDeviceMetadataFromNetwork /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" /v value /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" /v AutoConnectAllowedOEM /t REG_DWORD /d 0 /f >nul 2>&1

echo.
echo Disabling Cortana...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Personalization\Settings" /v AcceptedPrivacyPolicy /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization" /v RestrictImplicitTextCollection /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization" /v RestrictImplicitInkCollection /t REG_DWORD /d 1 /f >nul 2>&1

echo.
echo Disabling Xbox features...
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 0 /f >nul 2>&1

echo.
set /p onedrive="Do you want to disable OneDrive? (Y/N): "
if /i "%onedrive%"=="Y" (
    echo Disabling OneDrive...
    taskkill /f /im OneDrive.exe >nul 2>&1
    %SystemRoot%\SysWOW64\OneDriveSetup.exe /uninstall >nul 2>&1
    %SystemRoot%\System32\OneDriveSetup.exe /uninstall >nul 2>&1
    reg delete "HKCR\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f >nul 2>&1
    reg delete "HKCR\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f >nul 2>&1
    echo OneDrive has been disabled.
)

echo.
echo Disabling background apps...
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v LetAppsRunInBackground /t REG_DWORD /d 2 /f >nul 2>&1

echo.
echo Cleaning temporary files...
del /f /s /q "%TEMP%\*.*" >nul 2>&1
del /f /s /q "C:\Windows\Temp\*.*" >nul 2>&1
del /f /s /q "C:\Windows\Prefetch\*.*" >nul 2>&1
start /b cleanmgr /sagerun:1 >nul 2>&1

echo.
set /p startup="Do you want to disable all non-Microsoft startup programs? (Y/N): "
if /i "%startup%"=="Y" (
    echo Disabling startup programs...
    reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /va /f >nul 2>&1
    reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /va /f >nul 2>&1
    echo Startup entries cleared. You may need to manually re-enable essential ones.
)

echo.
echo Debloating completed!
set /p reboot="Do you want to restart your computer now? (Y/N): "
if /i "%reboot%"=="Y" shutdown /r /t 5 /c "Rebooting to apply changes..."
pause
exit /b

:CreateRestorePoint
echo Creating system restore point...
wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "Before Debloat", 100, 7 >nul
if %errorlevel% equ 0 (
    echo Restore point created successfully.
) else (
    echo Failed to create restore point. Possibly disabled or insufficient permissions.
)
goto :eof