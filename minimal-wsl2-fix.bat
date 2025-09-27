@echo off
echo ================================================================
echo MINIMAL WSL2 FIX - JUST THE ESSENTIALS
echo Installing only what's absolutely required for WSL2
echo ================================================================

REM Stop any background services that might interfere
net stop wuauserv >nul 2>&1

REM Install only the core VMP package (the most important one)
echo Installing core Virtual Machine Platform package...
dism /online /norestart /add-package:"%SystemRoot%\servicing\Packages\HyperV-Feature-VirtualMachinePlatform-Client-Package~31bf3856ad364e35~amd64~~10.0.26100.6584.mum" /quiet

REM Install the HCS compute package (needed for WSL2)
echo Installing HCS compute package...
dism /online /norestart /add-package:"%SystemRoot%\servicing\Packages\HyperV-Compute-System-VirtualMachine-Package~31bf3856ad364e35~amd64~~10.0.26100.6584.mum" /quiet

REM Restart Windows Update
net start wuauserv >nul 2>&1

echo.
echo MINIMAL INSTALLATION COMPLETE
echo Restart now and test: wsl --set-version Ubuntu 2
echo.
pause


