packer {
  required_plugins {
    # see https://github.com/hashicorp/packer-plugin-qemu
    qemu = {
      version = "1.1.1"
      source  = "github.com/hashicorp/qemu"
    }
    # see https://github.com/rgl/packer-plugin-windows-update
    windows-update = {
      version = "0.16.9"
      source  = "github.com/rgl/windows-update"
    }
  }
}

variable "vm_name" {
  type    = string
  default = "windows-2025-uefi-DC-us.qcow2"
}
variable "dir" {
  type    = string
  default = "./"
}
variable "disk_size" {
  type    = string
  default = "61440"
}

variable "iso_url" {
  type    = string
  default = "./OS_ISO/SW_DVD9_Win_Server_STD_CORE_2025_24H2.2_64Bit_English_DC_STD_MLF_X23-91027.ISO"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:d26110e4eb49e00c237ccdbb7af9ee3755f249b67754b5fa36a21bdc40656551"
}

source "qemu" "windows-2025-uefi-amd64" {
  accelerator  = "kvm"
  machine_type = "q35"
  cpus         = 2
  memory       = 4096
  qemuargs = [
    ["-bios", "/usr/share/ovmf/OVMF.fd"],
    ["-cpu", "host"],
    ["-device", "qemu-xhci"],
    ["-device", "virtio-tablet"],
    ["-device", "virtio-scsi-pci,id=scsi0"],
    ["-device", "scsi-hd,bus=scsi0.0,drive=drive0"],
    ["-device", "virtio-net,netdev=user.0"],
    ["-vga", "qxl"],
    ["-device", "virtio-serial-pci"],
    ["-chardev", "socket,path=/tmp/{{ .Name }}-qga.sock,server,nowait,id=qga0"],
    ["-device", "virtserialport,chardev=qga0,name=org.qemu.guest_agent.0"],
    ["-chardev", "spicevmc,id=spicechannel0,name=vdagent"],
    ["-device", "virtserialport,chardev=spicechannel0,name=com.redhat.spice.0"],
    ["-spice", "unix,addr=/tmp/{{ .Name }}-spice.socket,disable-ticketing"],
  ]
  boot_wait      = "1s"
  boot_command   = ["<up><wait><up><wait><up><wait><up><wait><up><wait><up><wait><up><wait><up><wait><up><wait><up><wait>"]
  disk_interface = "virtio-scsi"
  disk_cache     = "unsafe"
  disk_discard   = "unmap"
  disk_size      = var.disk_size
  cd_label       = "PROVISION"
  cd_files = [
    "drivers/NetKVM/2k25/amd64/*.cat",
    "drivers/NetKVM/2k25/amd64/*.inf",
    "drivers/NetKVM/2k25/amd64/*.sys",
    "drivers/NetKVM/2k25/amd64/*.exe",
    "drivers/qxldod/2k25/amd64/*.cat",
    "drivers/qxldod/2k25/amd64/*.inf",
    "drivers/qxldod/2k25/amd64/*.sys",
    "drivers/vioscsi/2k25/amd64/*.cat",
    "drivers/vioscsi/2k25/amd64/*.inf",
    "drivers/vioscsi/2k25/amd64/*.sys",
    "drivers/vioserial/2k25/amd64/*.cat",
    "drivers/vioserial/2k25/amd64/*.inf",
    "drivers/vioserial/2k25/amd64/*.sys",
    "drivers/viostor/2k25/amd64/*.cat",
    "drivers/viostor/2k25/amd64/*.inf",
    "drivers/viostor/2k25/amd64/*.sys",
    "drivers/virtio-win-guest-tools.exe",
    "scripts/provision-autounattend.ps1",
    "scripts/provision-guest-tools-qemu-kvm.ps1",
    "scripts/provision-openssh.ps1",
    "scripts/provision-psremoting.ps1",
    "scripts/provision-pwsh.ps1",
    "scripts/provision-winrm.ps1",
    "scripts/sysprep.bat",
    "answer_files/2025/Autounattend.xml",
  ]
  format                   = "qcow2"
  headless                 = true
  net_device               = "virtio-net"
  http_directory           = "."
  iso_url                  = var.iso_url
  iso_checksum             = var.iso_checksum
  shutdown_command         = "c:/windows/system32/sysprep/sysprep.exe /generalize /oobe /shutdown /quiet"
  communicator             = "ssh"
  ssh_username             = "Administrator"
  ssh_password             = "PasswOrd4g"
  ssh_timeout              = "4h"
  ssh_file_transfer_method = "sftp"
  output_directory = "./images"
  vm_name = "windows-2025-uefi-DC-us.qcow2"
}

build {
  sources = [
    "source.qemu.windows-2025-uefi-amd64"
  ]

  provisioner "powershell" {
    use_pwsh = true
    script   = "./scripts/disable-windows-updates.ps1"
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "./scripts/disable-windows-defender.ps1"
  }

  provisioner "windows-restart" {
  }

  provisioner "windows-update" {
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "./scripts/enable-remote-desktop.ps1"
  }

 # provisioner "powershell" {
 #   use_pwsh = true
 #   script   = "./scripts/provision-cloudbase-init.ps1"
 # }

  provisioner "powershell" {
    use_pwsh = true
    script   = "./scripts/provision-lock-screen-background.ps1"
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "./scripts/optimize.ps1"
  }

}
