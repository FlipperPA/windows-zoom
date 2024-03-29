# Windows-Zoom for Windows 11

A PowerShell script to set up a fresh Windows 11 install with basic settings, remove crapware, and start a specific Zoom meeting. You shouldn't run scripts like this willy-nilly, so the source is made fully available here.

If you need help installing a basic Windows 11 machine, [here are instructions on how to install Windows 11 fresh on a machine](https://github.com/FlipperPA/windows-setup/blob/main/README-windows-setup.md).

## How to Use It

1. Start up PowerShell as an Administrator. You can do this by pressing the Start button in Windows, typing `powershell`, then right clicking the `Windows PowerShell` entry and selecting `Run as Administrator`.
1. Run the follow commands in the PowerShell terminal window to install:

```powershell
Invoke-WebRequest https://raw.githubusercontent.com/FlipperPA/windows-zoom/main/windows-setup.ps1 -OutFile windows-setup.ps1
Set-ExecutionPolicy -Force Bypass
.\windows-setup.ps1
Set-ExecutionPolicy -Force RemoteSigned
rm .\windows-setup.ps1
```

## Zoom Installation and Launch Options

Here's a link to Zoom's various options, if you want to tweak the script: https://support.zoom.us/hc/en-us/articles/201362163-Mass-deployment-with-preconfigured-settings-for-Windows
