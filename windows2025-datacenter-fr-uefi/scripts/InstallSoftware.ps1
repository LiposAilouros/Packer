# 1. Make sure the Microsoft App Installer is installed:
#    https://www.microsoft.com/en-us/p/app-installer/9nblggh4nns1
# 2. Edit the list of apps to install.
# 3. Run this script as administrator.
$apps = @(
    @{name = "7zip.7zip" }
    #@{name = "Adobe.Acrobat.Reader.64-bit" },
    @{name = "mRemoteNG.mRemoteNG" },
    @{name = "Git.Git" },
    @{name = "Putty.Putty" },
    #@{name = "OhMyPosh" },
    #@{name = "Microsoft.dotnet" },
    #@{name = "Microsoft.PowerShell" },
    #@{name = "Vercel.Hyper" },
    @{name = "Microsoft.VisualStudioCode" },
    #@{name = "Microsoft.WindowsTerminal" },
    @{name = "Mozilla.Firefox" },
    @{name = "Notepad++.Notepad++" },
    @{name = "WinSCP.WinSCP" }
);
#wget -Uri "https://github.com/microsoft/winget-cli/releases/download/v1.7.10582/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -OutFile "c:\tmp\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
#wget -uri "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx" -OutFile  "c:\tmp\Microsoft.VCLibs.14.00.Desktop.appx"
#Add-AppxProvisionedPackage -Online -PackagePath "c:\tmp\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -SkipLicense
#Start-Sleep -Seconds 220
winget source reset --force
winget upgrade --all --accept-source-agreements
winget source update
winget list  --accept-source-agreements -s winget
Write-Output "Installing Apps"
Foreach ($app in $apps) {
    Write-Output $app.name
    $listApp = winget list --exact -q $app.name --accept-source-agreements
    Write-Output $listApp
    if (![String]::Join("", $listApp).Contains($app.name)) {
        Write-host "Installing: " $app.name
        winget install -e -h --accept-source-agreements --accept-package-agreements --id $app.name -s winget
    }
    else {
        Write-host "Skipping: " $app.name " (already installed)"
    }
}
exit 0

