@echo off
echo ================================================================
echo NUCLEAR OPTION - RAW PACKAGE INSTALLATION
echo This bypasses ALL Windows Feature enabling and installs packages directly
echo ================================================================

REM Kill any stuck processes
echo Killing stuck processes...
taskkill /f /im dism.exe >nul 2>&1
taskkill /f /im TiWorker.exe >nul 2>&1
taskkill /f /im TrustedInstaller.exe >nul 2>&1

REM Install VMP packages directly (from your vmp.txt list)
echo Installing Virtual Machine Platform packages directly...
for %%i in (
"HyperV-Feature-VirtualMachinePlatform-Client-Package~31bf3856ad364e35~amd64~~10.0.26100.6584.mum"
"Microsoft-Windows-HyperV-OptionalFeature-VirtualMachinePlatform-Client-Package~31bf3856ad364e35~amd64~~10.0.26100.6584.mum"
"HyperV-Compute-Host-VirtualMachines-Package~31bf3856ad364e35~amd64~~10.0.26100.5074.mum"
"HyperV-Compute-System-VirtualMachine-Package~31bf3856ad364e35~amd64~~10.0.26100.6584.mum"
"HyperV-Primitive-VirtualMachine-Package~31bf3856ad364e35~amd64~~10.0.26100.6584.mum"
) do (
    echo Installing %%i...
    dism /online /norestart /add-package:"%SystemRoot%\servicing\Packages\%%~i" /quiet
    if not errorlevel 1 echo SUCCESS: %%i
)

echo.
echo Raw package installation complete - NO FEATURE ENABLING ATTEMPTED
echo Restart your computer and test WSL2 directly
echo.
pause


