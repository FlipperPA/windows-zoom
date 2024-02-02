# This script sets up Windows 11 by removing a ton of crapware, setting some sane defaults, installing Zoom and creating a shortcut to join a meeting.
# It should be run in Administrator mode from PowerShell.

Write-Output("Uninstalling all the packaged crapware; we will leave Windows Store so anything can be replaced...")
DISM /Online /Get-ProvisionedAppxPackages | select-string Packagename | % {$_ -replace("PackageName : ", "")} | select-string "^((?!WindowsStore).)*$" | select-string "^((?!SecHealthUI).)*$" | select-string "^((?!DesktopAppInstaller).)*$" | ForEach-Object {Remove-AppxPackage -allusers -package $_}

Write-Output("Uninstalling more crap we probably don't want, like apps for OneDrive, Spotify, and Disney+...")
winget uninstall "Cortana" --silent --accept-source-agreements
winget uninstall "Disney+" --silent --accept-source-agreements
winget uninstall "Mail and Calendar" --silent --accept-source-agreements
winget uninstall "Microsoft News" --silent --accept-source-agreements
winget uninstall "Microsoft OneDrive" --silent --accept-source-agreements
winget uninstall "Microsoft Tips" --silent --accept-source-agreements
winget uninstall "MSN Weather" --silent --accept-source-agreements
winget uninstall "Movies & TV" --silent --accept-source-agreements
winget uninstall "Office" --silent --accept-source-agreements
winget uninstall "OneDrive" --silent --accept-source-agreements
winget uninstall "Spotify Music" --silent --accept-source-agreements
winget uninstall "Windows Maps" --silent --accept-source-agreements
winget uninstall "Xbox TCUI" --silent --accept-source-agreements
winget uninstall "Xbox Game Bar Plugin" --silent --accept-source-agreements
winget uninstall "Xbox Game Bar" --silent --accept-source-agreements
winget uninstall "Xbox Identity Provider" --silent --accept-source-agreements
winget uninstall "Xbox Game Speech Windows" --silent --accept-source-agreements

Write-Output("Changing registry settings for taskbar, lockscreen, and more...")
# Set the Windows Taskbar to never combine items (Windows 7 style)
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarGlomLevel' -Value 2
# Set the Windows Taskbar to use small icons
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarSmallIcons' -Value 1
# Disable Chat, Widgets Taskbar Buttons
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarMn' -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarDa' -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ShowTaskViewButton' -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'SearchboxTaskbarMode' -Value 0
# Disable Game Overlays
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR' -Name 'AppCaptureEnabled' -Value 0
# Show hidden files and folders
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'Hidden' -Value 1
# Don't hide file extensions
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt' -Value 1
# Don't include public folders in search (faster)
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'Start_SearchFiles' -Value 1
# Disable Taskbar / Cortana Search Box on Windows 11
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value "00000000";

# Don't show ads / nonsense on the lockscreen
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'ContentDeliveryAllowed' -Value 1
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'RotatingLockScreenEnabled' -Value 1
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'RotatingLockScreenOverlayEnabled' -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'SubscribedContent-338388Enabled' -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'SubscribedContent-338389Enabled' -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'SubscribedContent-88000326Enabled' -Value 0

# Stop pestering to create a Microsoft Account. Local accounts: this is the way.
New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'NoConnectedUser' -PropertyType DWord -Value 3 -Force

# Get rid of the incredibly stupid "Show More Options" context menu default that NO ONE ASKED FOR
New-Item -Path 'HKCU:\Software\Classes\CLSID' -Name '{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}' -f
New-Item -Path 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}' -Name 'InprocServer32' -Value '' -f

# Set timezone automatically
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate" -Name "Start" -Value "00000003";

# Disable prompts to create an MSFT account
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value "00000000";

Write-Output("Disabling as much data collection / mining as we can...")
Get-Service DiagTrack | Set-Service -StartupType Disabled
Get-Service dmwappushservice | Set-Service -StartupType Disabled
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0

# Disable Copilot
New-Item -Path 'HKCU\Software\Policies\Microsoft\Windows\WindowsCopilot' -Name 'TurnOffWindowsCopilot' -Value '1' -f

# Finally, stop and restart explorer.
Get-Process -Name explorer | Stop-Process
start explorer.exe

Write-Output("Installing Zoom...")
Invoke-WebRequest https://www.zoom.us/client/latest/ZoomInstallerFull.msi -OutFile ZoomInstallerFull.msi
msiexec /i ZoomInstallerFull.msi /qn /norestart /log install.log ZoomAutoUpdate="true" ZoomAutoStart="true" zSilentStart="true" ZNoDesktopShortCut="true" ZRecommend="AudioAutoAdjust=0;FullScreenWhenJoin=1;Min2Tray=0;ZoomAutoStart=1;SetAudioSignalProcessType=1;AudioAutoAdjust=0"
rm ZoomInstallerFull.msi

# Set Zoom to stay in windowed mode for startup
New-Item -Path 'HKLM:\Software\Policies\Zoom\Zoom Meetings\Meetings' -Name 'EnterFullScreenWhenJoinMeeting' -Value '0' -f

$Meeting_Count = 0
while (1) {
    Write-Output("Let's create a shortcut to a Zoom meeting on your desktop. If you don't want to add another, don't enter an ID number.")
    $Meeting_ID = Read-Host "Enter your Zoom Meeting ID Number (example: 123456789)"
    if($Meeting_ID.Length -eq 0) {
        break;
    }

    $Meeting_PW = Read-Host "Enter your Zoom Meeting Hashed Password (example: U0MeOUpxS1BpRmc2ExzU1WjZErUUQT09)"
    $Meeting_Name = Read-Host "Enter your Zoom Meeting Name (example: The Hope Group)"
    $Meeting_Count++

    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut_Path = "$Home\Desktop\Launch Zoom " + $Meeting_Name + ".lnk"
    $Shortcut = $WshShell.CreateShortcut($Shortcut_Path)
    $Shortcut.TargetPath = "C:\Program Files (x86)\Zoom\bin\Zoom.exe"
    $Shortcut.Arguments = '"--url=zoommtg://zoom.us/join?action=join&confno=' + $Meeting_ID + '&pwd=' + $Meeting_PW + '&zc=0&uname=' + $Meeting_Name + '"'
    $Shortcut.WorkingDirectory = "C:\Program Files (x86)\Zoom\bin"
    $Shortcut.Save()
    
    # Automatically launch Zoom into the first meeting added.
    if($Meeting_Count -eq 1) {
        $StartUp = "$Env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\LaunchZoomMeeting.lnk"
        New-Item -ItemType SymbolicLink -Path "$StartUp" -Target "$Shortcut_Path"
    }
}

$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$Home\Desktop\Shutdown Computer.lnk")
$Shortcut.TargetPath = "C:\Windows\System32\shutdown.exe"
$Shortcut.Arguments = "-s -t 00"
$Shortcut.WorkingDirectory = "C:\Windows\System32"
$Shortcut.Save()

Write-Output("Changing registry settings for taskbar, lockscreen, and more...")
# Set the Windows Taskbar to use small icons
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarSmallIcons' -Value 0
# Set Desktop to use extra large icons
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\Shell\Bags\1\Desktop' -Name 'IconSize' -Value 256
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\Shell\Bags\1\Desktop' -Name 'Mode' -Value 1
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\Shell\Bags\1\Desktop' -Name 'LogicalViewMode ' -Value 3

# Finally, stop and restart explorer.
Get-Process -Name explorer | Stop-Process
start explorer.exe
