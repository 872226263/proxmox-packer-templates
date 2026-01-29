name         = "windows-11-template"
iso_file     = "Win11_25H2_Pro_Chinese_Simplified_x64.iso"
iso_url      = ""
iso_checksum = "none"
iso_download = false
memory             = 43008
ballooning_minimum = 4096
cpu_cores          = 16
cpu_type           = "host"
disk_size          = "80G"
# Data disk (1600G) should be added after cloning the template
# Drive mapping: D:=VirtIO(ide0), E:=Windows ISO(ide2), F:=Scripts+Autounattend(sata3)
additional_iso_files = [
  {
    type         = "ide"
    index        = 0
    iso_file     = "virtio-win-0.1.285.iso"
    iso_url      = "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.285-1/virtio-win-0.1.285.iso"
    iso_checksum = "e14cf2b94492c3e925f0070ba7fdfedeb2048c91eea9c5a5afb30232a3976331"
  }
]
unattended_content = {
  "/Autounattend.xml" = {
    template = "./http/windows/Autounattend-win11.xml.pkrtpl"
    vars = {
      driver_version  = "w11"
      image_name      = "Windows 11 专业版"
    }
  }
}
additional_cd_files = [
  {
    type   = "sata"
    index  = 3
    files  = ["./http/windows-scripts/*"]
    label  = "DEPLOYTOOLS"
  }
]
os                     = "win11"
communicator           = "winrm"
http_directory         = ""
cloud_init             = true
boot_wait              = "1s"
boot_command           = ["<spacebar><spacebar><spacebar>"]
provisioner            = []
windows_language       = "zh-CN"
windows_input_language = "zh-CN"
machine                = "q35"
bios                   = "ovmf"
efi_config = {
  efi_storage_pool  = "local-lvm"
  efi_type          = "4m"
  pre_enrolled_keys = true
}
