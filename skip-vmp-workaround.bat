@echo off
echo ================================================================
echo SKIP BROKEN VMP - INSTALL EVERYTHING ELSE
echo Virtual Machine Platform is broken in Build 26100
echo Let's install WSL + Hypervisor and see if WSL2 works anyway
echo ================================================================

REM Kill any stuck processes
taskkill /f /im dism.exe >nul 2>&1
taskkill /f /im OptionalFeatures.exe >nul 2>&1
taskkill /f /im TiWorker.exe >nul 2>&1

echo Installing Windows Subsystem for Linux...
dism /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart /quiet

echo Installing Windows Hypervisor Platform... 
dism /online /enable-feature /featurename:HypervisorPlatform /all /norestart /quiet

echo Installing Hyper-V components (already working from your script)...
dism /online /enable-feature /featurename:Microsoft-Hyper-V-All /all /norestart /quiet

echo.
echo SKIPPED: Virtual Machine Platform (broken in Build 26100)
echo INSTALLED: WSL + Hypervisor + Hyper-V
echo.
echo Restart and test: wsl --set-version Ubuntu 2
echo (Might work even without VMP!)
echo.
pause

