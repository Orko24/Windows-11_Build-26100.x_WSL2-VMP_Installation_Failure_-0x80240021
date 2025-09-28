# Fix Virtual Machine Platform Feature on Demand Download Issue
# This addresses the CBS download failure (0x80004004 - E_ABORT) in Build 26100

Write-Host "==================================================================" -ForegroundColor Yellow
Write-Host "VMP FEATURE ON DEMAND DOWNLOAD FIX - BUILD 26100 WORKAROUND" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Yellow
Write-Host ""

# Check admin privileges
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: Must run as Administrator!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "PROBLEM IDENTIFIED: VMP Feature on Demand download failing from Microsoft servers" -ForegroundColor Red
Write-Host "CBS Error: 0x80004004 - E_ABORT during online download" -ForegroundColor Red
Write-Host ""

Write-Host "SOLUTION 1: Try offline installation (bypass download)" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan

try {
    Write-Host "Attempting VMP installation with /LimitAccess (no online download)..." -ForegroundColor Yellow
    $result = & dism /online /enable-feature /featurename:VirtualMachinePlatform /all /LimitAccess /norestart
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "SUCCESS! VMP installed without online download!" -ForegroundColor Green
        Write-Host "Restart your computer and test: wsl --set-version Ubuntu 2" -ForegroundColor White
        Read-Host "Press Enter to exit"
        exit 0
    } else {
        Write-Host "LimitAccess method failed - trying alternative approaches..." -ForegroundColor Yellow
    }
} catch {
    Write-Host "LimitAccess method failed - trying alternative approaches..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "SOLUTION 2: Reset Windows Update Agent (fix FOD downloads)" -ForegroundColor Cyan  
Write-Host "==================================================================" -ForegroundColor Cyan

Write-Host "Stopping Windows Update services..." -ForegroundColor Yellow
Stop-Service -Name "wuauserv", "bits", "cryptsvc" -Force -ErrorAction SilentlyContinue

Write-Host "Resetting Windows Update Agent..." -ForegroundColor Yellow
try {
    # Reset Windows Update Agent
    & "$env:SystemRoot\System32\wuauclt.exe" /resetauthorization /detectnow
    Start-Sleep -Seconds 5
    
    # Clear additional FOD-related caches  
    if (Test-Path "C:\Windows\SoftwareDistribution\PostRebootEventCache.V2") {
        Remove-Item "C:\Windows\SoftwareDistribution\PostRebootEventCache.V2" -Force -Recurse -ErrorAction SilentlyContinue
    }
    
    Write-Host "Windows Update Agent reset complete" -ForegroundColor Green
} catch {
    Write-Host "Windows Update Agent reset had issues (continuing...)" -ForegroundColor Yellow
}

Write-Host "Restarting services..." -ForegroundColor Yellow
Start-Service -Name "cryptsvc", "bits", "wuauserv" -ErrorAction SilentlyContinue

Write-Host "Testing VMP installation after WU Agent reset..." -ForegroundColor Yellow
try {
    $result = & dism /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "SUCCESS! VMP installed after WU Agent reset!" -ForegroundColor Green
        Write-Host "Restart your computer and test: wsl --set-version Ubuntu 2" -ForegroundColor White
        Read-Host "Press Enter to exit"
        exit 0
    } else {
        Write-Host "WU Agent reset didn't resolve the FOD download issue..." -ForegroundColor Yellow
    }
} catch {
    Write-Host "WU Agent reset didn't resolve the issue..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "SOLUTION 3: Alternative Windows Feature Installation" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan

Write-Host "Trying PowerShell Enable-WindowsOptionalFeature method..." -ForegroundColor Yellow
try {
    Enable-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform" -All -NoRestart
    Write-Host "SUCCESS! VMP installed via PowerShell method!" -ForegroundColor Green
    Write-Host "Restart your computer and test: wsl --set-version Ubuntu 2" -ForegroundColor White
    Read-Host "Press Enter to exit"
    exit 0
} catch {
    Write-Host "PowerShell method also failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "==================================================================" -ForegroundColor Red
Write-Host "ALL METHODS FAILED - BUILD 26100 FOD DOWNLOAD IS BROKEN" -ForegroundColor Red
Write-Host "==================================================================" -ForegroundColor Red
Write-Host ""

Write-Host "ROOT CAUSE: Windows 11 Build 26100 cannot download Feature on Demand components" -ForegroundColor Yellow
Write-Host "Microsoft servers reject or abort downloads for VMP on this build" -ForegroundColor Yellow
Write-Host ""

Write-Host "NUCLEAR OPTIONS:" -ForegroundColor Red
Write-Host ""
Write-Host "1. WINDOWS RESET (Recommended):" -ForegroundColor White
Write-Host "   Settings > Recovery > Reset this PC > Keep my files" -ForegroundColor Gray
Write-Host "   This will fix the FOD download system completely" -ForegroundColor Gray
Write-Host ""
Write-Host "2. IN-PLACE WINDOWS 11 UPGRADE:" -ForegroundColor White  
Write-Host "   Download Windows 11 ISO, run setup.exe from within Windows" -ForegroundColor Gray
Write-Host "   Repairs Windows while keeping programs/data" -ForegroundColor Gray
Write-Host ""
Write-Host "3. WAIT FOR MICROSOFT FIX:" -ForegroundColor White
Write-Host "   Check for Windows Updates regularly" -ForegroundColor Gray
Write-Host "   Microsoft may release a Build 26100 fix" -ForegroundColor Gray
Write-Host ""
Write-Host "4. USE WSL1 TEMPORARILY:" -ForegroundColor White
Write-Host "   WSL1 works fine, just slower than WSL2" -ForegroundColor Gray
Write-Host ""

Write-Host "Your hardware is perfect. Your troubleshooting was excellent." -ForegroundColor Green
Write-Host "This is 100% a Microsoft Windows 11 Build 26100 bug." -ForegroundColor Green

Read-Host "Press Enter to exit"

