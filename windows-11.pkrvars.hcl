name         = "windows-11-template"
iso_file     = "Win11_25H2_Pro_Chinese_Simplified_x64.iso"
iso_url      = ""
iso_checksum = "none"
iso_download = false
memory       = 43008
cpu_cores    = 16
disk_size    = "80G"
additional_disks = [
  { disk_size = "1600G" }
]
additional_iso_files = [
  {
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
    type = "sata"
    index = 3
    files  = ["./http/windows-scripts/*"]
  }
]
os                     = "win11"
communicator           = "winrm"
http_directory         = ""
cloud_init             = false
boot_command           = []
provisioner            = []
windows_language       = "zh-CN"
windows_input_language = "zh-CN"
