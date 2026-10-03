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
3. **Manage the browser:** Watch videos at lower resolutions and close heavy tabs.

## Notes
- While data saver is ON, Windows and Defender updates are blocked. Run **Option 2** on unmetered Wi-Fi from time to time, let the PC update fully, then run **Option 1** again.
- Windows feature updates can switch `DiagTrack` back on, so re-run **Option 1** now and then.
- To check the result, use Resource Monitor -> Network, and Settings -> Network & Internet -> Data usage -> View usage per app.
- If something still downloads, find which service owns the process with `tasklist /svc /fi "PID eq <pid>"`.
