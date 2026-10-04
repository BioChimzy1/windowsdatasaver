# Windows Data Saver

A PowerShell script to stop Windows background update downloads and preserve mobile hotspot data on limited connections.

## Features
- Stops download services (`DoSvc`, `wuauserv`, `bits`)
- Configures Delivery Optimization to bypass mode
- Sets Windows Update to notify before downloading
- Disables Microsoft Store auto-updates and Store Install Service
- Disables Windows Telemetry (`DiagTrack`)
- Disables Microsoft Office background updates (policy and scheduled task)
- Disables the Google (Chrome) and Microsoft Edge background updaters (`updater.exe`, `MicrosoftEdgeUpdate.exe`): stops their services and scheduled tasks, ends the running process, and sets the Google Update and Edge Update policies to block updates. These updaters ignore the Windows metered-connection setting, so the script has to handle them directly. **Option 2** restores them.

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
- Chrome and Edge also stop updating while data saver is ON. After **Option 2**, open `chrome://settings/help` and `edge://settings/help` to update them.
- Windows feature updates can switch `DiagTrack` back on, so re-run **Option 1** now and then.
- To check the result, use Resource Monitor -> Network, and Settings -> Network & Internet -> Data usage -> View usage per app. If you see a "Reset usage stats" option, use it so you start from zero when testing.
- If something still downloads, find which service owns the process with `tasklist /svc /fi "PID eq <pid>"`.
- If `updater.exe` shows heavy Receive traffic in Resource Monitor, that is the Google Updater. Run **Option 1** again and check that its path is under `...\Google\GoogleUpdater\`.
- Option 1 saves the original startup type of the Chrome and Edge updater services to `C:\ProgramData\WindowsDataSaver\updater-services.json`, and Option 2 restores them from it.