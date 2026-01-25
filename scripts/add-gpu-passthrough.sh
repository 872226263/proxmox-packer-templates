#!/bin/bash
# Add GPU passthrough to a VM after cloning from template
# Usage: ./add-gpu-passthrough.sh <VMID> [GPU_ADDR] [AUDIO_ADDR]

set -e

VMID=${1:?Usage: $0 <VMID> [GPU_ADDR] [AUDIO_ADDR]}
GPU_ADDR=${2:-"01:00.0"}
AUDIO_ADDR=${3:-"01:00.1"}

echo "Configuring GPU passthrough for VM $VMID..."

# Stop VM if running
if qm status $VMID | grep -q "running"; then
    echo "Stopping VM $VMID..."
    qm stop $VMID
    sleep 3
fi

# Set machine type to q35 (required for PCIe passthrough)
qm set $VMID --machine q35

# Set BIOS to OVMF (UEFI)
qm set $VMID --bios ovmf

# Add EFI disk if not exists
if ! qm config $VMID | grep -q "efidisk0"; then
    qm set $VMID --efidisk0 local-lvm:1,efitype=4m,pre-enrolled-keys=0
fi

# Disable virtual VGA (using physical GPU)
qm set $VMID --vga none

# Add GPU passthrough
qm set $VMID --hostpci0 ${GPU_ADDR},pcie=1,x-vga=1

# Add GPU Audio passthrough
qm set $VMID --hostpci1 ${AUDIO_ADDR},pcie=1

# Set CPU type to host (better compatibility)
qm set $VMID --cpu host

echo ""
echo "GPU passthrough configured for VM $VMID"
echo "  GPU:   $GPU_ADDR (hostpci0, x-vga=1)"
echo "  Audio: $AUDIO_ADDR (hostpci1)"
echo ""
echo "Start VM with: qm start $VMID"
