@echo off
echo ================================================================
echo WINDOWS FEATURES DOWNLOAD BLOCK BYPASS INSTALLER
echo This script will:
echo 1. Cancel any stuck Windows Features downloads
echo 2. Reset Windows Update components
echo 3. Manually install all virtualization features
echo ================================================================

REM Kill any stuck Windows Features processes
echo Stopping stuck Windows Features processes...
taskkill /f /im OptionalFeatures.exe >nul 2>&1
taskkill /f /im dism.exe >nul 2>&1

REM Stop and reset Windows Update Service
echo Resetting Windows Update Service...
net stop wuauserv
net stop bits
net stop cryptsvc

REM Clear update cache
echo Clearing Windows Update cache...
del /q /s %systemroot%\SoftwareDistribution\Download\* >nul 2>&1
del /q /s %systemroot%\Temp\* >nul 2>&1

REM Restart services
net start cryptsvc
net start bits  
net start wuauserv

echo.
echo Windows Update components reset. Now installing virtualization features manually...
echo.

REM Install components using DISM directly (bypassing Windows Features UI)
echo Installing Virtual Machine Platform...
dism /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

echo Installing Windows Hypervisor Platform...
dism /online /enable-feature /featurename:HypervisorPlatform /all /norestart

echo Installing Windows Subsystem for Linux...
dism /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

echo Installing Hyper-V (complete)...
dism /online /enable-feature /featurename:Microsoft-Hyper-V-All /all /norestart

echo.
echo ================================================================
echo INSTALLATION COMPLETE!
echo 
echo NEXT STEPS:
echo 1. RESTART your computer
echo 2. Test WSL2: wsl --set-version Ubuntu 2
echo 3. Launch Docker Desktop (should work now)
echo 4. Check Hyper-V Manager in Start Menu
echo ================================================================
pause


