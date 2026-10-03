# Windows Data Saver

A PowerShell script to stop Windows background update downloads and preserve mobile hotspot data on limited connections.

## Features
- Stops download services (`DoSvc`, `wuauserv`, `bits`)
- Configures Delivery Optimization to bypass mode
- Sets Windows Update to notify before downloading
- Disables Microsoft Store auto-updates and Store Install Service
- Disables Windows Telemetry (`DiagTrack`)
- Disables Microsoft Office background updates (policy and scheduled task)

## Usage
1. Right-click `WindowsDataSaver.ps1` -> **Run with PowerShell** (Run as Administrator).
2. Choose **Option 1** when using a mobile hotspot to stop downloads.
3. Choose **Option 2** when connected to unmetered Wi-Fi to allow updates, then restart the laptop.

## Manual Steps Required
The script handles the heavy Windows Update background tasks, but you still need to do a few things manually:
1. **Set your hotspot as a metered connection** in Windows Wi-Fi settings.
2. **Turn off News and Interests:** Right-click the taskbar weather widget -> **News and interests** -> **Turn off** (stops `ActionsServer.exe`).
3. **Manage the browser & editor:**
   - Watch videos at lower resolutions and close heavy tabs.
   - **Chrome:** Install [uBlock Origin Lite (by Raymond Hill)](https://chromewebstore.google.com/detail/ublock-origin-lite/ddkjiahejlhfcafbddmgiahcphecmpfh) directly from the Chrome Web Store and set it to Optimal mode to block data-heavy ads and trackers. Don't forget to pin the extension to your toolbar (click the puzzle-piece icon) so you can easily access it. Turn off Preload pages and enable Memory Saver in Chrome's Performance settings. Use `Shift + Esc` to monitor Chrome Task Manager.
   - **VS Code:** Open Settings (JSON) by pressing `Ctrl+Shift+P`, typing "Preferences: Open User Settings (JSON)", and adding the following configuration exactly as shown between the main `{` and `}` braces to block silent updates and telemetry:
     ```json
     {
         "update.mode": "none",
         "extensions.autoUpdate": "off",
         "extensions.autoCheckUpdates": false,
         "telemetry.telemetryLevel": "off"
     }
     ```
     *(Note: If you use Settings Sync, turn that off while on the hotspot as well. Fully close and reopen VS Code for `update.mode` to take effect).*

## Notes
- While data saver is ON, Windows and Defender updates are blocked. Run **Option 2** on unmetered Wi-Fi from time to time, let the PC update fully, then run **Option 1** again.
- Windows feature updates can switch `DiagTrack` back on, so re-run **Option 1** now and then.
- To check the result, use Resource Monitor -> Network, and Settings -> Network & Internet -> Data usage -> View usage per app. If you see a "Reset usage stats" option, use it so you start from zero when testing.
- If something still downloads, find which service owns the process with `tasklist /svc /fi "PID eq <pid>"`.