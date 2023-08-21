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
    @{name = "Vercel.Hyper" },
    @{name = "Microsoft.VisualStudioCode" },
    #@{name = "Microsoft.WindowsTerminal" },
    @{name = "Mozilla.Firefox" },
    @{name = "Notepad++.Notepad++" },
    @{name = "WinSCP.WinSCP" }
);
winget source reset
winget source upgrade --force
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

