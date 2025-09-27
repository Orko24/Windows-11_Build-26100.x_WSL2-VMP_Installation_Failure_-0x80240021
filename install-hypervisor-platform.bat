@echo off
echo Installing Windows Hypervisor Platform manually...

REM Try to enable Windows Hypervisor Platform feature
dism /online /enable-feature /featurename:HypervisorPlatform /all /norestart

REM Alternative method - try through Windows Features
dism /online /enable-feature /featurename:Microsoft-Hyper-V-Hypervisor /all /norestart

echo Windows Hypervisor Platform installation complete.
echo You may need to restart your computer.
pause


