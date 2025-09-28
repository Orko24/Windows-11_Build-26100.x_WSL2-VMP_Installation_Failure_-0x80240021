@echo off
echo ========================================================
echo FINAL HYPER-V/WSL2 FIX FOR WINDOWS 11 BUILD 26100
echo ========================================================
echo.

echo Setting Hyper-V hypervisor to start at boot...
bcdedit /set hypervisorlaunchtype auto
if %errorlevel% neq 0 (
    echo ERROR: Could not set hypervisor launch type. This script must be run as Administrator.
    echo Right-click this file and select "Run as administrator"
    pause
    exit /b 1
)

echo.
echo Enabling Data Execution Prevention...
bcdedit /set nx OptIn

echo.
echo Stopping all WSL and virtualization services...
wsl --shutdown
net stop vmcompute 2>nul
net stop HvHost 2>nul
net stop vmms 2>nul

echo.
echo Disabling and re-enabling Virtual Machine Platform...
dism /online /disable-feature /featurename:VirtualMachinePlatform /norestart
dism /online /enable-feature /featurename:VirtualMachinePlatform /norestart

echo.
echo Starting services...
net start vmms
net start HvHost  
net start vmcompute

echo.
echo Reinstalling WSL components...
wsl.exe --install --no-distribution

echo.
echo ========================================================
echo REBOOT REQUIRED - System will restart in 30 seconds
echo ========================================================
echo Press Ctrl+C to cancel restart
timeout /t 30
shutdown /r /t 0

pause




