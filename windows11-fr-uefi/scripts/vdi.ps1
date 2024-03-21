write-host "Downloading sources"
wget -Uri "http://$ENV:PACKER_HTTP_ADDR/VMwareHorizonOSOptimizationTool-x86_64-1.2.2303.21510536.exe" -OutFile "c:\windows\temp\VMwareHorizonOSOptimizationTool.exe"
write-host "optimize"
C:\windows\temp\VMwareHorizonOSOptimizationTool.exe -o -finalize all
exit 0
