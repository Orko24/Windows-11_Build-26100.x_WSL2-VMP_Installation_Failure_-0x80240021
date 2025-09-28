@echo off
echo ============================================================
echo  Windows 11 Licensing Identity Fix Script
echo  Fixes kernel-level Windows 10/11 confusion in Build 26100
echo ============================================================
echo.

echo Checking current system identity...
powershell -Command "Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion"
echo.

echo Step 1: Stopping Windows licensing services...
net stop sppsvc 2>nul
net stop ClipSVC 2>nul
taskkill /f /im slui.exe 2>nul

echo.
echo Step 2: Clearing licensing cache...
del /f /q "%SystemRoot%\System32\spp\tokens\*" 2>nul
del /f /q "%SystemRoot%\ServiceState\EventLog\Data\lastalive*.dat" 2>nul

echo.
echo Step 3: Configuring hypervisor boot (requires UAC)...
bcdedit /set hypervisorlaunchtype auto
bcdedit /set nx OptIn
bcdedit /set pae ForceEnable

echo.
echo Step 4: Restarting licensing services...
net start sppsvc
net start ClipSVC

echo.
echo Step 5: Force licensing refresh...
slmgr.vbs /rilc
timeout /t 3 /nobreak >nul
slmgr.vbs /ato
timeout /t 3 /nobreak >nul

echo.
echo Step 6: Refresh group policies...
gpupdate /force

echo.
echo Step 7: Force Windows Update check...
powershell -Command "Get-WindowsUpdate -Install -AcceptAll -AutoReboot:$false" 2>nul

echo.
echo ============================================================
echo Fix completed! Checking results...
echo ============================================================
echo.

echo Current system identity:
powershell -Command "Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion"
echo.

echo Hypervisor status:
powershell -Command "Get-WmiObject -Class Win32_ComputerSystem | Select-Object HypervisorPresent"
echo.

echo Hypervisor boot config:
bcdedit /enum | findstr -i hypervisor
echo.

echo ============================================================
echo REBOOT REQUIRED to complete licensing refresh!
echo ============================================================
echo.
echo After reboot, run:
echo wsl --set-default-version 2
echo wsl --install Ubuntu
echo.
pause


