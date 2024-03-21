Write-Output "Downloading debloat zip"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$url = "https://github.com/LeDragoX/Win-Debloat-Tools/archive/develop.zip"
(New-Object System.Net.WebClient).DownloadFile($url, "c:\windows\TEMP\main.zip")
Expand-Archive -Path c:\windows\TEMP\main.zip -DestinationPath c:\tmp -Force

Write-Output debloat Windows
cd C:\tmp\Win-Debloat-Tools-develop\
Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force; ls -Recurse *.ps*1 | Unblock-File
.\src\scripts\Optimize-Performance.ps1
.\src\scripts\Invoke-DebloatSoftware.ps1
.\src\scripts\Optimize-Privacy.ps1
.\src\scripts\Optimize-ServicesRunning.ps1
.\src\scripts\Optimize-TaskScheduler.ps1
.\src\scripts\Optimize-WindowsFeaturesList.ps1
.\src\scripts\Register-PersonalTweaksList.ps1
.\src\scripts\Remove-BloatwareAppsList.ps1
#.\src\scripts\Remove-MSEdge.ps1
.\src\scripts\Remove-OneDrive.ps1
#.\src\scripts\Optimize-WindowsFeaturesList.ps1
#.\src\scripts\Remove-Xbox.ps1
.\src\scripts\Start-DiskCleanUp.ps1
#.\"WinDebloatTools.ps1" 'CLI'
#
#  #:: Remove-Item $env:TEMP\main.zip
#    #:: Remove-Item -recurse $env:TEMP\Debloat-Windows-10-master
