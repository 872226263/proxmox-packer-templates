# Windows 11 with GPU Passthrough (RTX 5090)
# For rental machines with NVIDIA GPU passthrough

name         = "windows-11-gpu-template"
iso_file     = "26200.6584.250915-1905.25h2_ge_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
iso_url      = "https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26200.6584.250915-1905.25h2_ge_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
iso_checksum = "a61adeab895ef5a4db436e0a7011c92a2ff17bb0357f58b13bbc4062e535e7b9"

# Hardware configuration for rental (42GB RAM, adjust cores as needed)
memory    = 43008
cpu_cores = 16
disk_size = "60G"

# Network config (VLAN can be set when cloning if needed)
# network_adapter_vlan = 100  # Uncomment if VLAN isolation needed

# NOTE: Windows 11 requires UEFI, GPU passthrough configured after cloning
# See: scripts/deploy-gpu-vm.sh

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
      driver_version = "w11"
      image_name     = "Windows 11 Enterprise Evaluation"
    }
  }
}

additional_cd_files = [
  {
    type  = "sata"
    index = 3
    files = ["./http/windows-gpu-scripts/*"]
  }
]

os             = "win11"
communicator   = "winrm"
winrm_password = "123456"
http_directory = ""
# Enable cloud-init for IP/password management via cloudbase-init
cloud_init              = true
cloud_init_storage_pool = "local-lvm"
boot_command   = []
provisioner    = []
