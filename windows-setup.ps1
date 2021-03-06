# This script sets up Windows 10 by removing a ton of crapware, setting some sane defaults, installing Zoom and creating a shortcut to join a meeting.
# It should be run in Administrator mode from PowerShell.

# Uninstall the crapware that comes with Windows 10 - leave the Store
Write-Output("Uninstalling all the packaged crapware; we will leave Windows Store so anything can be replaced...")
DISM /Online /Get-ProvisionedAppxPackages | select-string Packagename | % {$_ -replace("PackageName : ", "")} | select-string "^((?!WindowsStore).)*$" | ForEach-Object {Remove-AppxPackage -allusers -package $_}

Write-Host "Unpinning all the nonsense from the start menu..."
$start_menu_layout = @"
<?xml version="1.0" encoding="utf-8"?>
<LayoutModificationTemplate
    xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification"
    xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout"
    xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout"
    xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout"
    Version="1">
  <LayoutOptions StartTileGroupCellWidth="6" StartTileGroupsColumnCount="1" />
  <DefaultLayoutOverride>
    <StartLayoutCollection>
      <defaultlayout:StartLayout GroupCellWidth="6" xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout">
        <start:Group Name="One day at a time!" xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout">
          <start:Tile Size="2x2" Column="0" Row="0" AppUserModelID="Microsoft.MicrosoftEdge_8wekyb3d8bbwe!MicrosoftEdge" />
          <start:DesktopApplicationTile Size="2x2" Column="2" Row="0" DesktopApplicationID="Microsoft.Windows.Computer" />
          <start:Tile Size="2x2" Column="4" Row="0" AppUserModelID="Microsoft.WindowsStore_8wekyb3d8bbwe!App" />
        </start:Group>        
      </defaultlayout:StartLayout>
    </StartLayoutCollection>
  </DefaultLayoutOverride>
    <CustomTaskbarLayoutCollection>
      <defaultlayout:TaskbarLayout>
        <taskbar:TaskbarPinList>
          <taskbar:UWA AppUserModelID="Microsoft.MicrosoftEdge_8wekyb3d8bbwe!MicrosoftEdge" />
          <taskbar:DesktopApp DesktopApplicationLinkPath="%APPDATA%\Microsoft\Windows\Start Menu\Programs\System Tools\File Explorer.lnk" />
          <taskbar:DesktopApp DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Accessories\Snipping Tool.lnk" />
        </taskbar:TaskbarPinList>
      </defaultlayout:TaskbarLayout>
    </CustomTaskbarLayoutCollection>
</LayoutModificationTemplate>
"@
Add-content $Env:TEMP\start_menu_layout.xml $start_menu_layout
Import-StartLayout -layoutpath $Env:TEMP\start_menu_layout.xml -mountpath $Env:SYSTEMDRIVE\
Remove-Item $Env:TEMP\start_menu_layout.xml

Write-Output("Installing Zoom...")
Invoke-WebRequest https://www.zoom.us/client/latest/ZoomInstallerFull.msi -OutFile ZoomInstallerFull.msi
msiexec /i ZoomInstallerFull.msi /qn /norestart /log install.log ZoomAutoUpdate="true" ZoomAutoStart="true" ZSILENTSTART="true" ZNoDesktopShortCut="true" ZRecommend="AudioAutoAdjust=0;FullScreenWhenJoin=1;Min2Tray=0;ZoomAutoStart=1;SetAudioSignalProcessType=1;AudioAutoAdjust=0"
rm ZoomInstallerFull.msi

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
    $Shortcut.Arguments = '"--url=zoommtg://zoom.us/join?confno=' + $Meeting_ID + '&pwd=' + $Meeting_PW + '&zc=0&uname=' + $Meeting_Name + '"'
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
# Set the Windows Taskbar to never combine items (Windows 7 style)
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarGlomLevel' -Value 2
# Set the Windows Taskbar to use small icons
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarSmallIcons' -Value 0
# Set Desktop to use extra large icons
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\Shell\Bags\1\Desktop' -Name 'IconSize' -Value 256
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\Shell\Bags\1\Desktop' -Name 'Mode' -Value 1
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\Shell\Bags\1\Desktop' -Name 'LogicalViewMode ' -Value 3
# Disable Cortana Button
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ShowCortanaButton' -Value 0
# Disable Task View Button
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ShowTaskViewButton' -Value 0
# Don't track or show recent documents
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'Start_TrackDocs' -Value 0
# Show hidden files and folders
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'Hidden' -Value 1
# Don't hide file extensions
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt' -Value 1
# No games shortcut
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'Start_ShowMyGames' -Value 0
# Don't include public folders in search (faster)
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'Start_SearchFiles' -Value 1
# Don't show notifications/ads (OneDrive & new feature alerts) in Windows Explorer
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ShowSyncProviderNotifications' -Value 1
# Disable Cortana
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion' -Name 'ShowSyncProviderNotifications' -Value 1

# Don't show ads / nonsense on the lockscreen
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'ContentDeliveryAllowed' -Value 1
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'RotatingLockScreenEnabled' -Value 1
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'RotatingLockScreenOverlayEnabled' -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'SubscribedContent-338387Enabled' -Value 0
# Remove OneDrive Icon
Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace' -Name '{018D5C66-4533-4307-9B53-224DE2ED1FE6}'
Set-ItemProperty -Path 'HKCU:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}' -Name 'System.IsPinnedToNameSpaceTree' -Value 0
Set-ItemProperty -Path 'HKCU:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}' -Name 'System.IsPinnedToNameSpaceTree' -Value 0

# Finally, stop and restart explorer.
Get-Process -Name explorer | Stop-Process
start explorer.exe
