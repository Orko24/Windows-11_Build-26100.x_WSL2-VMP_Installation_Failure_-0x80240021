@echo off
echo Starting critical Hyper-V and WSL2 services...
echo.

echo Stopping WSL and VM services...
wsl --shutdown
net stop vmcompute 2>nul
net stop HvHost 2>nul

echo.
echo Starting Hyper-V Host Service...
net start HvHost

echo.
echo Starting VM Compute Service...  
net start vmcompute

echo.
echo Service Status:
sc query HvHost | findstr "STATE"
sc query vmcompute | findstr "STATE"
sc query vmms | findstr "STATE"

echo.
echo Testing WSL2...
wsl --status
echo.
echo Attempting WSL2 conversion...
wsl --set-version Ubuntu 2

pause




