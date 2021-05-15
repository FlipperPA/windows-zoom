# windows-zoom

A PowerShell script to set up a fresh Windows 10 install with basic settings, remove crapware, and start a specific Zoom meeting. You shouldn't run scripts like this without understanding what they do, or if you know and trust the author.

## How to Use It

(1) Start up PowerShell as an Administrator. You can do this by pressing the Start button in Windows, typing `powershell`, then right clicking the `Winodws PowerShell` entry and selecting `Run as Administrator`.
(2) Run the follow commands in the PowerShell terminal window to install:

```powershell
Invoke-WebRequest https://raw.githubusercontent.com/FlipperPA/windows-zoom/main/windows-setup.ps1 -OutFile windows-setup.ps1
Set-ExecutionPolicy -Force Bypass
.\windows-setup.ps1
Set-ExecutionPolicy -Force RemoteSigned
rm .\windows-setup.ps1
```
