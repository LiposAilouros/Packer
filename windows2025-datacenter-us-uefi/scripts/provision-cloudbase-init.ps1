Set-StrictMode -Version Latest
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'
trap {
    Write-Host
    Write-Host "ERROR: $_"
    ($_.ScriptStackTrace -split '\r?\n') -replace '^(.*)$','ERROR: $1' | Write-Host
    ($_.Exception.ToString() -split '\r?\n') -replace '^(.*)$','ERROR EXCEPTION: $1' | Write-Host
    Write-Host
    Write-Host 'Sleeping for 60m to give you time to look around the virtual machine before self-destruction...'
    Start-Sleep -Seconds (60*60)
    Exit 1
}

# enable TLS 1.2.
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol `
    -bor [Net.SecurityProtocolType]::Tls12

$cloudbaseInitHome = 'C:\Program Files\Cloudbase Solutions\Cloudbase-Init'
$cloudbaseInitConfPath = "$cloudbaseInitHome\conf\cloudbase-init.conf"

# see https://github.com/cloudbase/cloudbase-init/releases
# renovate: datasource=github-releases depName=cloudbase/cloudbase-init
$cloudbaseInitVersion = '1.1.6'

$artifactUrl = "https://github.com/cloudbase/cloudbase-init/releases/download/$cloudbaseInitVersion/CloudbaseInitSetup_$($cloudbaseInitVersion -replace '\.','_')_x64.msi"
$artifactPath = "$env:TEMP\$(Split-Path -Leaf $artifactUrl)"
$artifactLogPath = "$artifactPath.log"

$systemVendor = (Get-CimInstance -ClassName Win32_ComputerSystemProduct -Property Vendor).Vendor
if ($systemVendor -eq 'QEMU') {
    # qemu-kvm.
    $metadataServices = @(
        # NoCloudConfigDriveService for use in libvirt.
        # see https://cloudbase-init.readthedocs.io/en/latest/services.html#nocloud-configuration-drive
        'cloudbaseinit.metadata.services.nocloudservice.NoCloudConfigDriveService'
        # ConfigDriveService for use in Proxmox.
        # see https://cloudbase-init.readthedocs.io/en/latest/services.html#openstack-configuration-drive
        # see https://pve.proxmox.com/wiki/Cloud-Init_Support
        'cloudbaseinit.metadata.services.configdrive.ConfigDriveService'
    )
} elseif ($systemVendor -eq 'Microsoft Corporation') {
    # Hyper-V.
    $metadataServices = @(
        # NoCloudConfigDriveService for use in Hyper-V.
        # see https://cloudbase-init.readthedocs.io/en/latest/services.html#nocloud-configuration-drive
        'cloudbaseinit.metadata.services.nocloudservice.NoCloudConfigDriveService'
    )
} elseif ($systemVendor -eq 'VMware, Inc.') {
    # VMware ESXi.
    $metadataServices = @(
        # VMwareGuestInfoService for use in VMware ESXi.
        # see https://cloudbase-init.readthedocs.io/en/latest/services.html#vmware-guestinfo-service
        'cloudbaseinit.metadata.services.vmwareguestinfoservice.VMwareGuestInfoService'
    )
} else {
    Write-Host "WARNING: cloudbase-init is not supported on your system vendor $systemVendor"
    Exit 0
}

# NB we might have to retry the download due to errors:
#       The underlying connection was closed: Could not establish trust relationship for the SSL/TLS secure channel
while ($true) {
    try {
        Write-Host 'Downloading the cloudbase-init setup...'
        (New-Object System.Net.WebClient).DownloadFile($artifactUrl, $artifactPath)
        break
    } catch {
        Write-Host "Failed to download the cloudbase-init setup. Trying in a bit due to error $_"
        Start-Sleep -Seconds 5
    }
}

Write-Host 'Installing cloudbase-init...'
# NB this also installs the cloudbase-init service, which will automatically start on the next boot.
# see https://github.com/cloudbase/cloudbase-init-installer
msiexec /i $artifactPath /qn /l*v $artifactLogPath | Out-String -Stream
if ($LASTEXITCODE) {
    throw "Failed with Exit Code $LASTEXITCODE. See the logs at $artifactLogPath."
}

Write-Host 'Installing the provision sysprep oobe wait plugin...'
# see https://github.com/rgl/windows-sysprep-playground
$plugins = @('cloudbaseinit.plugins.windows.provisionsysprep.ProvisionSysprepOobeWaitPlugin')
$plugins += &"$cloudbaseInitHome\Python\python.exe" -c @"
import json
from cloudbaseinit import conf as cloudbaseinit_conf

CONF = cloudbaseinit_conf.CONF

print(json.dumps(CONF.plugins))
"@ | ConvertFrom-Json
Set-Content `
    -Encoding UTF8 `
    -NoNewline `
    -Path "$cloudbaseInitHome\Python\Lib\site-packages\cloudbaseinit\plugins\windows\provisionsysprep.py" `
    -Value @"
import time
import os.path
from oslo_log import log as oslo_logging
from cloudbaseinit.plugins.common import base

LOG = oslo_logging.getLogger(__name__)

# see https://github.com/rgl/windows-sysprep-playground
PROVISION_SYSPREP_OOBE_PATH = 'C:/Windows/System32/Sysprep/provision-sysprep-oobe.txt'

class ProvisionSysprepOobeWaitPlugin(base.BasePlugin):
    execution_stage = base.PLUGIN_STAGE_PRE_NETWORKING

    def execute(self, service, shared_data):
        LOG.debug("waiting for sysprep oobe to finish (the %s file to disappear)", PROVISION_SYSPREP_OOBE_PATH)
        if os.path.exists(PROVISION_SYSPREP_OOBE_PATH):
            while os.path.exists(PROVISION_SYSPREP_OOBE_PATH):
                time.sleep(5)
            time.sleep(5)
        return base.PLUGIN_EXECUTION_DONE, False
"@

Write-Host 'Replacing the configuration...'
# The default configuration is:
#   [DEFAULT]
#   username=Admin
#   groups=Administrators
#   inject_user_password=true
#   config_drive_raw_hhd=true
#   config_drive_cdrom=true
#   config_drive_vfat=true
#   bsdtar_path=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\bin\bsdtar.exe
#   mtools_path=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\bin\
#   verbose=true
#   debug=true
#   log_dir=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\log\
#   log_file=cloudbase-init.log
#   default_log_levels=comtypes=INFO,suds=INFO,iso8601=WARN,requests=WARN
#   logging_serial_port_settings=
#   mtu_use_dhcp_config=true
#   ntp_use_dhcp_config=true
#   local_scripts_path=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\LocalScripts\
#   check_latest_version=true
# see https://cloudbase-init.readthedocs.io/en/latest/tutorial.html#configuration-file
# see https://cloudbase-init.readthedocs.io/en/latest/config.html#config-list
Move-Item $cloudbaseInitConfPath "$cloudbaseInitConfPath.orig"
Set-Content -Encoding ascii $cloudbaseInitConfPath @"
[DEFAULT]
username=Administrator
groups=Administrators
first_logon_behaviour=no
debug=true
log_dir=$cloudbaseInitHome\log\
log_file=cloudbase-init.log
bsdtar_path=$cloudbaseInitHome\bin\bsdtar.exe
mtools_path=$cloudbaseInitHome\bin\
plugins=$($plugins -join ",`n         ")
metadata_services=$($metadataServices -join ",`n                  ")

[config_drive]
locations=cdrom
types=iso
"@
