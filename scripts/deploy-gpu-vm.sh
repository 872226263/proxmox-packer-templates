#!/bin/bash
# Deploy a GPU VM from template with cloud-init configuration
# Usage: ./deploy-gpu-vm.sh <TEMPLATE_ID> <NEW_VMID> <VM_NAME> <IP_ADDRESS> [PASSWORD]

set -e

TEMPLATE_ID=${1:?Usage: $0 <TEMPLATE_ID> <NEW_VMID> <VM_NAME> <IP_ADDRESS> [PASSWORD]}
NEW_VMID=${2:?Usage: $0 <TEMPLATE_ID> <NEW_VMID> <VM_NAME> <IP_ADDRESS> [PASSWORD]}
VM_NAME=${3:?Usage: $0 <TEMPLATE_ID> <NEW_VMID> <VM_NAME> <IP_ADDRESS> [PASSWORD]}
IP_ADDRESS=${4:?Usage: $0 <TEMPLATE_ID> <NEW_VMID> <VM_NAME> <IP_ADDRESS> [PASSWORD]}
PASSWORD=${5:-"123456"}

# Network config (modify as needed)
GATEWAY="192.168.2.1"
NETMASK="24"
DNS="8.8.8.8"

# GPU addresses (modify as needed)
GPU_ADDR="01:00.0"
AUDIO_ADDR="01:00.1"

echo "=== Deploying GPU VM ==="
echo "Template:  $TEMPLATE_ID"
echo "New VMID:  $NEW_VMID"
echo "Name:      $VM_NAME"
echo "IP:        $IP_ADDRESS/$NETMASK"
echo ""

# Clone template
echo "1. Cloning template..."
qm clone $TEMPLATE_ID $NEW_VMID --name $VM_NAME --full

# Configure cloud-init
echo "2. Configuring cloud-init..."
qm set $NEW_VMID --ciuser admin --cipassword "$PASSWORD"
qm set $NEW_VMID --ipconfig0 ip=${IP_ADDRESS}/${NETMASK},gw=${GATEWAY}
qm set $NEW_VMID --nameserver $DNS

# Configure GPU passthrough
echo "3. Configuring GPU passthrough..."

# Set machine type to q35
qm set $NEW_VMID --machine q35

# Set BIOS to OVMF
qm set $NEW_VMID --bios ovmf

# Add EFI disk
qm set $NEW_VMID --efidisk0 local-lvm:1,efitype=4m,pre-enrolled-keys=0

# Disable virtual VGA
qm set $NEW_VMID --vga none

# Add GPU passthrough
qm set $NEW_VMID --hostpci0 ${GPU_ADDR},pcie=1,x-vga=1
qm set $NEW_VMID --hostpci1 ${AUDIO_ADDR},pcie=1

# Set CPU type
qm set $NEW_VMID --cpu host

echo ""
echo "=== Deployment Complete ==="
echo "VM $NEW_VMID ($VM_NAME) is ready"
echo ""
echo "Start:    qm start $NEW_VMID"
echo "Console:  qm terminal $NEW_VMID"
echo "SSH:      ssh admin@$IP_ADDRESS"
echo ""
