# Ubuntu 24.04 with GPU Passthrough (RTX 5090)
# For admin machines with NVIDIA GPU passthrough

name           = "ubuntu-24.04-gpu-template"
iso_file       = "ubuntu-24.04.2-live-server-amd64.iso"
iso_url        = "https://old-releases.ubuntu.com/releases/24.04/ubuntu-24.04.2-live-server-amd64.iso"
iso_checksum   = "file:https://old-releases.ubuntu.com/releases/24.04/SHA256SUMS"
http_directory = "./http/ubuntu-gpu"

# Hardware configuration for admin (42GB RAM, adjust cores as needed)
memory    = 43008
cpu_cores = 16
disk_size = "60G"

# Network config (VLAN can be set when cloning if needed)
# network_adapter_vlan = 100  # Uncomment if VLAN isolation needed

# Cloud-init for IP/password management
cloud_init              = true
cloud_init_storage_pool = "local-lvm"

# NOTE: Use standard BIOS for template build
# GPU passthrough (q35, ovmf, efi) is configured AFTER cloning
# See: scripts/deploy-gpu-vm.sh

boot_wait = "5s"
boot_command = [
  "c<wait> ",
  "linux /casper/vmlinuz --- autoinstall ds='nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/'",
  "<enter><wait>",
  "initrd /casper/initrd",
  "<enter><wait>",
  "boot",
  "<enter>"
]

provisioner = [
  "apt-get update",
  "apt-get install -y build-essential dkms",
  # Enable SSH password authentication
  "sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config",
  # Create admin user (password changed via cloud-init)
  "useradd -m -s /bin/bash -G sudo admin",
  "echo 'admin:123456' | chpasswd",
  "echo 'admin ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/admin",
  # Cloud-init config for password/network changes
  "printf 'ssh_pwauth: true\nchpasswd: { expire: false }' > /etc/cloud/cloud.cfg.d/99-admin.cfg",
  # Clean up
  "cloud-init clean",
  "userdel --remove --force packer"
]
