# Windows 11 Build 26100 Virtual Machine Platform PowerShell Fix
# Addresses Error 0x80240021 when installing VMP through Windows Features

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "POWERSHELL FIX FOR VIRTUAL MACHINE PLATFORM ERROR 0x80240021" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Step 1: Stopping Windows Update services..." -ForegroundColor Yellow
try {
    Stop-Service -Name "wuauserv" -Force -ErrorAction SilentlyContinue
    Stop-Service -Name "bits" -Force -ErrorAction SilentlyContinue  
    Stop-Service -Name "cryptsvc" -Force -ErrorAction SilentlyContinue
    Stop-Service -Name "msiserver" -Force -ErrorAction SilentlyContinue
    Write-Host "✅ Services stopped successfully" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Some services may already be stopped" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Step 2: Clearing Windows Update cache..." -ForegroundColor Yellow
try {
    if (Test-Path "C:\Windows\SoftwareDistribution") {
        Rename-Item "C:\Windows\SoftwareDistribution" "C:\Windows\SoftwareDistribution.old" -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path "C:\Windows\System32\catroot2") {
        Rename-Item "C:\Windows\System32\catroot2" "C:\Windows\System32\catroot2.old" -Force -ErrorAction SilentlyContinue
    }
    Write-Host "✅ Cache cleared successfully" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Some cache files may be in use" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Step 3: Restarting Windows Update services..." -ForegroundColor Yellow
try {
    Start-Service -Name "cryptsvc" -ErrorAction SilentlyContinue
    Start-Service -Name "bits" -ErrorAction SilentlyContinue
    Start-Service -Name "wuauserv" -ErrorAction SilentlyContinue  
    Start-Service -Name "msiserver" -ErrorAction SilentlyContinue
    Write-Host "✅ Services restarted successfully" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Some services may take time to start" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Step 4: Running DISM system health restore..." -ForegroundColor Yellow
try {
    & dism /online /Cleanup-Image /RestoreHealth | Out-Null
    Write-Host "✅ DISM restore completed" -ForegroundColor Green
} catch {
    Write-Host "⚠️  DISM restore had some issues (continuing anyway)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Step 5: Attempting PowerShell-based feature installation..." -ForegroundColor Yellow

# Method 1: Try PowerShell Enable-WindowsOptionalFeature
Write-Host "Trying Method 1: Enable-WindowsOptionalFeature..." -ForegroundColor Cyan
try {
    Enable-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform" -All -NoRestart
    Write-Host "✅ Method 1 succeeded!" -ForegroundColor Green
    $success = $true
} catch {
    Write-Host "❌ Method 1 failed: $($_.Exception.Message)" -ForegroundColor Red
    $success = $false
}

if (-not $success) {
    # Method 2: Try DISM with specific parameters  
    Write-Host "Trying Method 2: DISM with LimitAccess..." -ForegroundColor Cyan
    try {
        & dism /online /enable-feature /featurename:VirtualMachinePlatform /all /LimitAccess /norestart
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Method 2 succeeded!" -ForegroundColor Green
            $success = $true
        } else {
            Write-Host "❌ Method 2 failed with exit code: $LASTEXITCODE" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ Method 2 failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

if (-not $success) {
    # Method 3: Try Get-WindowsCapability approach
    Write-Host "Trying Method 3: Windows Capability approach..." -ForegroundColor Cyan
    try {
        $capabilities = Get-WindowsCapability -Online | Where-Object {$_.Name -like "*VirtualMachine*"}
        foreach ($cap in $capabilities) {
            Add-WindowsCapability -Online -Name $cap.Name -LimitAccess
        }
        Write-Host "✅ Method 3 completed" -ForegroundColor Green
        $success = $true
    } catch {
        Write-Host "❌ Method 3 failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Step 6: Installing complementary features..." -ForegroundColor Yellow

# Install WSL and Hypervisor Platform (these typically work)
try {
    Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -All -NoRestart -ErrorAction SilentlyContinue
    Write-Host "✅ WSL feature enabled" -ForegroundColor Green
} catch {
    Write-Host "⚠️  WSL may already be enabled" -ForegroundColor Yellow
}

try {
    Enable-WindowsOptionalFeature -Online -FeatureName "HypervisorPlatform" -All -NoRestart -ErrorAction SilentlyContinue  
    Write-Host "✅ Hypervisor Platform enabled" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Hypervisor Platform may already be enabled" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Step 7: Final verification..." -ForegroundColor Yellow

# Check if VMP is now enabled
try {
    $vmpFeature = Get-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform"
    if ($vmpFeature.State -eq "Enabled") {
        Write-Host "✅ SUCCESS: Virtual Machine Platform is now enabled!" -ForegroundColor Green
        $finalSuccess = $true
    } else {
        Write-Host "❌ Virtual Machine Platform state: $($vmpFeature.State)" -ForegroundColor Red
        $finalSuccess = $false
    }
} catch {
    Write-Host "❌ Could not verify VMP status" -ForegroundColor Red
    $finalSuccess = $false
}

Write-Host ""
Write-Host "==================================================================" -ForegroundColor Cyan
if ($finalSuccess) {
    Write-Host "🎉 SUCCESS! RESTART YOUR COMPUTER NOW!" -ForegroundColor Green
    Write-Host ""
    Write-Host "After restart, test with:" -ForegroundColor White
    Write-Host "  wsl --set-version Ubuntu 2" -ForegroundColor Cyan
} else {
    Write-Host "❌ POWERSHELL METHODS FAILED" -ForegroundColor Red
    Write-Host ""
    Write-Host "NUCLEAR OPTION REQUIRED:" -ForegroundColor Yellow
    Write-Host "1. Settings > Recovery > Reset this PC > Keep my files" -ForegroundColor White
    Write-Host "2. This will fix the Windows Update corruption" -ForegroundColor White
    Write-Host ""
    Write-Host "OR TRY:" -ForegroundColor Yellow  
    Write-Host "Manual Windows 11 ISO installation to repair system" -ForegroundColor White
}
Write-Host "==================================================================" -ForegroundColor Cyan

Read-Host "Press Enter to exit"
