@echo off
echo Installing Virtual Machine Platform manually...

REM First try to enable the feature directly
dism /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

REM If that fails, install the core packages
for %%i in (
"HyperV-Feature-VirtualMachinePlatform-Client-Package~31bf3856ad364e35~amd64~~10.0.26100.6584.mum"
"Microsoft-Windows-HyperV-OptionalFeature-VirtualMachinePlatform-Client-Package~31bf3856ad364e35~amd64~~10.0.26100.6584.mum"
"HyperV-Compute-Host-VirtualMachines-Package~31bf3856ad364e35~amd64~~10.0.26100.5074.mum"
) do (
    echo Installing %%i...
    dism /online /norestart /add-package:"%SystemRoot%\servicing\Packages\%%~i"
)

echo Virtual Machine Platform installation complete.
echo You may need to restart your computer.
pause


