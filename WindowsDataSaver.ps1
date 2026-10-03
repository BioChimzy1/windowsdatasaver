<#
================================================================================
 DataSaver.ps1  -  Stop Windows background downloads on a limited data hotspot
================================================================================
 HOW TO RUN
   Right-click this file -> Run with PowerShell -> Yes (Administrator prompt)
   Type 1 = Data saver ON  (use on your phone hotspot)
   Type 2 = Data saver OFF (use on Wi-Fi with plenty of data)

   If "Run with PowerShell" is missing, open Command Prompt and run:
   powershell -ExecutionPolicy Bypass -File "C:\Scripts\DataSaver.ps1"

--------------------------------------------------------------------------------
 WHAT THE SCRIPT DOES FOR YOU (option 1)
   - Stops the update download services (DoSvc, wuauserv, bits)
   - Sets Delivery Optimization to bypass mode (no background downloads)
   - Sets Windows Update to "notify before downloading"
   - Disables the DoSvc service through the registry (Start = 4), because
     Set-Service is blocked with "access denied" on this PC
   - Turns off automatic Microsoft Store app updates (policy)
   - Blocks the Microsoft Store and disables its Install Service, so Store
     apps cannot download or update (option 2 brings the Store back)

--------------------------------------------------------------------------------
 WHAT A SCRIPT CANNOT DO - DO THESE BY HAND (checklist)
   Do these once. Together with the script they cover everything we found.

 [ ] 1. Set your hotspot as a metered connection
        Settings -> Network & Internet -> Wi-Fi -> click your hotspot name
        -> turn ON "Set as metered connection".
        (Windows ties this to each network, so it must be set per network.
         Do not turn on "random hardware addresses" for it; changing that can
         make Windows treat the hotspot as a new network and reset this.)

 [ ] 2. Pause Windows Update for 7 days
        Settings -> Update & Security -> Windows Update
        -> "Pause updates for 7 days". Repeat when it runs out.

 [ ] 3. Cancel anything already queued in the Microsoft Store
        Microsoft Store -> your profile icon -> Downloads and updates
        -> cancel any download in progress.
        Then: profile icon -> App settings -> turn OFF "Update apps automatically".
        (The script now also blocks the Store and disables its Install Service.
         The Store block policy may be ignored on Windows 10 Home, but the
         Install Service change works on every edition.)

 [ ] 4. Turn off Delivery Optimization sharing
        Settings -> Update & Security -> Delivery Optimization
        -> turn OFF "Allow downloads from other PCs".

 [ ] 5. Keep Chrome in check
        Press Shift+Esc inside Chrome, sort by Network, close any tab or
        extension using a lot of data. Watch videos at 360p or 480p.

 [ ] 6. OneDrive
        Not signed in on this laptop, so it has nothing to sync. If you want
        it gone completely: Task Manager -> Startup tab -> Microsoft OneDrive
        -> Disable.

 [ ] 7. Check the result
        Resource Monitor -> Network tab: nothing should be above a few KB/s
        while you are idle. Also watch the Hotspot counter on your phone.
        Per-app totals: Settings -> Network & Internet -> Data usage
        -> View usage per app.

 [ ] 8. Phone side
        Part of your bundle is your phone's own apps. On the phone, open data
        usage settings and sort by app. Turn off auto-updates in Play Store
        (Settings -> Network preferences -> Auto-update apps -> Don't
        auto-update apps) and restrict background data for heavy apps.

 [ ] 9. Turn the hotspot OFF when you are not using the laptop.

 [ ] 10. REBOOT NOTE
        Option 1 now disables DoSvc in the registry, so it should stay off after
        a restart. Still check Resource Monitor after a reboot. If anything
        downloads again, run this script and choose 1 before using the hotspot.
        After option 2, RESTART the laptop so DoSvc starts normally again.

 [ ] 11. SECURITY NOTE
        While data saver is ON, this PC does not get Windows updates. Windows
        10 needs security updates, so run option 2 on Wi-Fi with plenty of
        data from time to time, let it update fully, then run option 1 again.

--------------------------------------------------------------------------------
 If something still downloads, run this to see which service owns the process
 (replace 1234 with the PID shown in Resource Monitor):
     tasklist /svc /fi "PID eq 1234"
================================================================================
#>

# --- Re-launch as Administrator if needed ---
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

$doKey    = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization'
$auKey    = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
$storeKey = 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore'

function Enable-DataSaver {
    Write-Host "Stopping download services..." -ForegroundColor Cyan
    foreach ($s in 'DoSvc','wuauserv','bits') {
        Stop-Service $s -Force -ErrorAction SilentlyContinue
    }

    Write-Host "Setting Delivery Optimization to bypass mode..." -ForegroundColor Cyan
    New-Item $doKey -Force | Out-Null
    Set-ItemProperty $doKey -Name DODownloadMode -Value 100 -Type DWord

    Write-Host "Setting Windows Update to notify before downloading..." -ForegroundColor Cyan
    New-Item $auKey -Force | Out-Null
    Set-ItemProperty $auKey -Name NoAutoUpdate -Value 0 -Type DWord
    Set-ItemProperty $auKey -Name AUOptions -Value 2 -Type DWord

    Write-Host "Turning off automatic Store app updates..." -ForegroundColor Cyan
    New-Item $storeKey -Force | Out-Null
    Set-ItemProperty $storeKey -Name AutoDownload -Value 2 -Type DWord

    Write-Host "Blocking the Microsoft Store and its Install Service..." -ForegroundColor Cyan
    Set-ItemProperty $storeKey -Name RemoveWindowsStore -Value 1 -Type DWord
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\InstallService" /v Start /t REG_DWORD /d 4 /f | Out-Null
    Stop-Service InstallService -Force -ErrorAction SilentlyContinue

    Write-Host "Disabling DoSvc (registry method)..." -ForegroundColor Cyan
    $svcKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\DoSvc'
    try {
        Set-ItemProperty $svcKey -Name Start -Value 4 -Type DWord -ErrorAction Stop
        Write-Host "DoSvc set to Disabled." -ForegroundColor Cyan
    } catch {
        reg add "HKLM\SYSTEM\CurrentControlSet\Services\DoSvc" /v Start /t REG_DWORD /d 4 /f | Out-Null
        if ($LASTEXITCODE -eq 0) { Write-Host "DoSvc set to Disabled." -ForegroundColor Cyan }
        else { Write-Host "Could not disable DoSvc. The policy above still applies." -ForegroundColor Yellow }
    }

    Write-Host ""
    Write-Host "DATA SAVER ON. Background update downloads are stopped." -ForegroundColor Green
    Write-Host "Now finish the manual checklist at the top of this file (metered connection, Store settings). The Store is blocked until you run option 2." -ForegroundColor Yellow
}

function Disable-DataSaver {
    Write-Host "Removing data saver settings..." -ForegroundColor Cyan
    Remove-Item $doKey -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item $auKey -Recurse -Force -ErrorAction SilentlyContinue
    Remove-ItemProperty $storeKey -Name AutoDownload -ErrorAction SilentlyContinue
    Remove-ItemProperty $storeKey -Name RemoveWindowsStore -ErrorAction SilentlyContinue
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\InstallService" /v Start /t REG_DWORD /d 3 /f | Out-Null
    # Restore DoSvc to Automatic (Delayed Start) through the registry
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\DoSvc" /v Start /t REG_DWORD /d 2 /f | Out-Null
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\DoSvc" /v DelayedAutostart /t REG_DWORD /d 1 /f | Out-Null
    Start-Service wuauserv, bits -ErrorAction SilentlyContinue
    Start-Service DoSvc -ErrorAction SilentlyContinue

    Write-Host ""
    Write-Host "DATA SAVER OFF. Windows can download updates again." -ForegroundColor Green
    Write-Host "RESTART the laptop now so the Delivery Optimization service starts normally." -ForegroundColor Yellow
    Write-Host "Remember to undo the manual items too (unpause updates, Store auto-update, metered connection) if you want updates." -ForegroundColor Yellow
}

Write-Host "==============================" -ForegroundColor White
Write-Host "  Windows Data Saver" -ForegroundColor White
Write-Host "==============================" -ForegroundColor White
Write-Host "  1) Data saver ON  (use on your hotspot)"
Write-Host "  2) Data saver OFF (use on Wi-Fi with plenty of data)"
Write-Host ""
$choice = Read-Host "Type 1 or 2 and press Enter"

switch ($choice) {
    '1' { Enable-DataSaver }
    '2' { Disable-DataSaver }
    default { Write-Host "No change made." -ForegroundColor Yellow }
}

Write-Host ""
Read-Host "Press Enter to close"