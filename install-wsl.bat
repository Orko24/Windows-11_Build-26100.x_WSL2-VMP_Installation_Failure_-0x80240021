@echo off
echo Installing Windows Subsystem for Linux manually...

REM Enable WSL feature
dism /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

REM Also enable the WSL optional component
dism /online /enable-feature /featurename:Windows-Subsystem-for-Linux /all /norestart

echo WSL installation complete.
echo You may need to restart your computer.
pause


