 Write-Output Downloading debloat zip

  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  $url = "https://github.com/kdpuvvadi/debloat-windows11/archive/refs/heads/main.zip"
  (New-Object System.Net.WebClient).DownloadFile($url, "$env:TEMP\main.zip")
  Expand-Archive -Path $env:TEMP\main.zip -DestinationPath c:\tmp -Force
#
#   Write-Output debloat Windows
#  . $env:TEMP\debloat-windows11-main\debloat.ps1
# 
  #:: Remove-Item $env:TEMP\main.zip
  #:: Remove-Item -recurse $env:TEMP\Debloat-Windows-10-master
