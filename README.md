# Windows Data Saver

A PowerShell script to stop Windows background update downloads and preserve mobile hotspot data on limited connections.

## Features
- Stops download services (`DoSvc`, `wuauserv`, `bits`)
- Configures Delivery Optimization to bypass mode
- Sets Windows Update to notify before downloading
- Disables Microsoft Store auto-updates and Store Install Service

## Usage
1. Right-click `WindowsDataSaver.ps1` -> **Run with PowerShell** (Run as Administrator).
2. Choose **Option 1** when using a mobile hotspot to stop downloads.
3. Choose **Option 2** when connected to unmetered Wi-Fi to allow updates.
