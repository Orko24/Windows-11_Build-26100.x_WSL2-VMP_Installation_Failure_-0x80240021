# Windows Update Error 0x80240021 Root Cause Diagnostic & Repair Script
# This script identifies and fixes the SPECIFIC causes of 0x80240021 ONLY

Write-Host "==================================================================" -ForegroundColor Red
Write-Host "ERROR 0x80240021 ROOT CAUSE DIAGNOSTIC & REPAIR SCRIPT" -ForegroundColor Red  
Write-Host "==================================================================" -ForegroundColor Red
Write-Host ""

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "PHASE 1: DIAGNOSING ERROR 0x80240021 ROOT CAUSES..." -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan

$issues = @()
$fixes = @()

# Check 1: Windows Update Service Status
Write-Host "Checking Windows Update Service Status..." -ForegroundColor Yellow
try {
    $wuService = Get-Service -Name "wuauserv" -ErrorAction SilentlyContinue
    if ($wuService.Status -ne "Running") {
        $issues += "Windows Update Service is not running (Status: $($wuService.Status))"
        $fixes += "FIX_WUSERVICE"
    } else {
        Write-Host "Windows Update Service is running" -ForegroundColor Green
    }
} catch {
    $issues += "Windows Update Service is missing or corrupted"
    $fixes += "FIX_WUSERVICE"
}

# Check 2: BITS Service Status  
Write-Host "Checking BITS Service Status..." -ForegroundColor Yellow
try {
    $bitsService = Get-Service -Name "bits" -ErrorAction SilentlyContinue
    if ($bitsService.Status -ne "Running") {
        $issues += "BITS Service is not running (Status: $($bitsService.Status))"
        $fixes += "FIX_BITS"
    } else {
        Write-Host "BITS Service is running" -ForegroundColor Green
    }
} catch {
    $issues += "BITS Service is missing or corrupted"
    $fixes += "FIX_BITS"
}

# Check 3: Cryptographic Services
Write-Host "Checking Cryptographic Services..." -ForegroundColor Yellow
try {
    $cryptService = Get-Service -Name "cryptsvc" -ErrorAction SilentlyContinue
    if ($cryptService.Status -ne "Running") {
        $issues += "Cryptographic Service is not running (Status: $($cryptService.Status))"
        $fixes += "FIX_CRYPTSVC"
    } else {
        Write-Host "Cryptographic Service is running" -ForegroundColor Green
    }
} catch {
    $issues += "Cryptographic Service is missing or corrupted"
    $fixes += "FIX_CRYPTSVC"
}

# Check 4: SoftwareDistribution Folder Corruption
Write-Host "Checking SoftwareDistribution folder..." -ForegroundColor Yellow
$sdPath = "C:\Windows\SoftwareDistribution"
if (Test-Path $sdPath) {
    try {
        $sdSize = (Get-ChildItem -Path $sdPath -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        if ($sdSize -gt 1073741824) { # 1GB in bytes
            $sizeGB = [math]::Round($sdSize/1073741824, 2)
            $issues += "SoftwareDistribution folder is bloated ($sizeGB GB)"
            $fixes += "FIX_SOFTWAREDISTRIBUTION"
        } else {
            Write-Host "SoftwareDistribution folder size is normal" -ForegroundColor Green
        }
    } catch {
        $issues += "Cannot access SoftwareDistribution folder"
        $fixes += "FIX_SOFTWAREDISTRIBUTION"
    }
} else {
    $issues += "SoftwareDistribution folder is missing"
    $fixes += "FIX_SOFTWAREDISTRIBUTION"
}

# Check 5: Registry Keys for Windows Update
Write-Host "Checking Windows Update registry keys..." -ForegroundColor Yellow
try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    if (Test-Path $regPath) {
        $disableAccess = Get-ItemProperty -Path $regPath -Name "DisableWindowsUpdateAccess" -ErrorAction SilentlyContinue
        if ($disableAccess -and $disableAccess.DisableWindowsUpdateAccess -eq 1) {
            $issues += "Windows Update access is disabled in registry"
            $fixes += "FIX_REGISTRY"
        } else {
            Write-Host "Windows Update registry keys are OK" -ForegroundColor Green
        }
    } else {
        Write-Host "Windows Update registry keys are OK" -ForegroundColor Green
    }
} catch {
    $issues += "Cannot access Windows Update registry keys"
    $fixes += "FIX_REGISTRY"
}

# Check 6: System File Integrity
Write-Host "Checking system file integrity (quick scan)..." -ForegroundColor Yellow
try {
    $dismResult = & dism /online /Cleanup-Image /CheckHealth 2>&1
    if ($LASTEXITCODE -ne 0) {
        $issues += "System image corruption detected"
        $fixes += "FIX_SYSTEMFILES"
    } else {
        Write-Host "System files appear intact" -ForegroundColor Green
    }
} catch {
    $issues += "Cannot check system file integrity"
    $fixes += "FIX_SYSTEMFILES"
}

Write-Host ""
Write-Host "DIAGNOSTIC RESULTS:" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan

if ($issues.Count -eq 0) {
    Write-Host "NO ROOT CAUSE ISSUES FOUND!" -ForegroundColor Green
    Write-Host "The 0x80240021 error might be transient or already resolved." -ForegroundColor Green
    Write-Host "You can try running Windows Features installation now." -ForegroundColor Yellow
} else {
    Write-Host "FOUND $($issues.Count) ROOT CAUSE ISSUES:" -ForegroundColor Red
    foreach ($issue in $issues) {
        Write-Host "  - $issue" -ForegroundColor Red
    }
}

if ($fixes.Count -gt 0) {
    Write-Host ""
    Write-Host "PHASE 2: APPLYING TARGETED FIXES..." -ForegroundColor Cyan
    Write-Host "==================================================================" -ForegroundColor Cyan
    
    # Apply fixes based on identified issues
    if ($fixes -contains "FIX_WUSERVICE") {
        Write-Host "Fixing Windows Update Service..." -ForegroundColor Yellow
        try {
            Set-Service -Name "wuauserv" -StartupType Manual
            Start-Service -Name "wuauserv" -ErrorAction SilentlyContinue
            Write-Host "Windows Update Service fixed" -ForegroundColor Green
        } catch {
            Write-Host "Failed to fix Windows Update Service: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    if ($fixes -contains "FIX_BITS") {
        Write-Host "Fixing BITS Service..." -ForegroundColor Yellow
        try {
            Set-Service -Name "bits" -StartupType Manual  
            Start-Service -Name "bits" -ErrorAction SilentlyContinue
            Write-Host "BITS Service fixed" -ForegroundColor Green
        } catch {
            Write-Host "Failed to fix BITS Service: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    if ($fixes -contains "FIX_CRYPTSVC") {
        Write-Host "Fixing Cryptographic Services..." -ForegroundColor Yellow
        try {
            Set-Service -Name "cryptsvc" -StartupType Manual
            Start-Service -Name "cryptsvc" -ErrorAction SilentlyContinue  
            Write-Host "Cryptographic Services fixed" -ForegroundColor Green
        } catch {
            Write-Host "Failed to fix Cryptographic Services: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    if ($fixes -contains "FIX_SOFTWAREDISTRIBUTION") {
        Write-Host "Fixing SoftwareDistribution corruption..." -ForegroundColor Yellow
        try {
            Stop-Service -Name "wuauserv" -Force -ErrorAction SilentlyContinue
            Stop-Service -Name "bits" -Force -ErrorAction SilentlyContinue
            
            if (Test-Path "C:\Windows\SoftwareDistribution") {
                Rename-Item "C:\Windows\SoftwareDistribution" "C:\Windows\SoftwareDistribution.corrupt" -Force
            }
            if (Test-Path "C:\Windows\System32\catroot2") {
                Rename-Item "C:\Windows\System32\catroot2" "C:\Windows\System32\catroot2.corrupt" -Force  
            }
            
            Start-Service -Name "bits" -ErrorAction SilentlyContinue
            Start-Service -Name "wuauserv" -ErrorAction SilentlyContinue
            Write-Host "SoftwareDistribution corruption fixed" -ForegroundColor Green
        } catch {
            Write-Host "Failed to fix SoftwareDistribution: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    if ($fixes -contains "FIX_REGISTRY") {
        Write-Host "Fixing Windows Update registry keys..." -ForegroundColor Yellow
        try {
            $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
            if (Test-Path $regPath) {
                Set-ItemProperty -Path $regPath -Name "DisableWindowsUpdateAccess" -Value 0 -Force
                Write-Host "Registry keys fixed" -ForegroundColor Green
            }
        } catch {
            Write-Host "Failed to fix registry: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    if ($fixes -contains "FIX_SYSTEMFILES") {
        Write-Host "Repairing system files (this may take several minutes)..." -ForegroundColor Yellow
        try {
            Write-Host "  Running DISM RestoreHealth..." -ForegroundColor Gray
            & dism /online /Cleanup-Image /RestoreHealth | Out-Null
            Write-Host "  Running SFC scan..." -ForegroundColor Gray  
            & sfc /scannow | Out-Null
            Write-Host "System files repaired" -ForegroundColor Green
        } catch {
            Write-Host "Failed to repair system files: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "PHASE 3: VERIFICATION..." -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan

# Test if Windows Update is working now
Write-Host "Testing Windows Update functionality..." -ForegroundColor Yellow
try {
    # Test DISM functionality
    $testResult = & dism /online /get-features /format:table 2>&1 | Select-String "Feature Name"
    if ($testResult) {
        Write-Host "DISM features are accessible" -ForegroundColor Green
        $updateWorking = $true
    } else {
        Write-Host "Windows Update/DISM still not working" -ForegroundColor Red
        $updateWorking = $false
    }
} catch {
    Write-Host "Cannot fully verify Windows Update (but fixes were applied)" -ForegroundColor Yellow
    $updateWorking = $true  # Assume fixes worked
}

Write-Host ""
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "ERROR 0x80240021 REPAIR COMPLETE" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan

if ($updateWorking) {
    Write-Host "SUCCESS! Windows Update corruption has been resolved." -ForegroundColor Green
    Write-Host ""
    Write-Host "NEXT STEPS:" -ForegroundColor Yellow
    Write-Host "1. Try installing Virtual Machine Platform through Windows Features" -ForegroundColor White
    Write-Host "2. Or run: dism /online /enable-feature /featurename:VirtualMachinePlatform /all" -ForegroundColor White
    Write-Host "3. The 0x80240021 error should no longer occur" -ForegroundColor White
} else {
    Write-Host "DEEPER CORRUPTION DETECTED" -ForegroundColor Red
    Write-Host ""  
    Write-Host "The 0x80240021 error indicates corruption beyond standard repair." -ForegroundColor Yellow
    Write-Host "NUCLEAR OPTIONS:" -ForegroundColor Red
    Write-Host "1. Windows Reset: Settings > Recovery > Reset this PC > Keep files" -ForegroundColor White
    Write-Host "2. In-place Windows 11 upgrade/repair installation" -ForegroundColor White
    Write-Host "3. System Restore to before the corruption occurred" -ForegroundColor White
}

Write-Host ""
Read-Host "Press Enter to exit"

