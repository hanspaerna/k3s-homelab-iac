#!/bin/sh

#
# Inspired by: https://fz42.net/posts/automating-your-homelab-p1-cloudinit/
# and: https://github.com/andrewglass3/ProxmoxCloudInitScript/blob/master/create-ubuntu-jammy-template.sh
#
# Please run with ./execute.sh
#

apt update
apt install libguestfs-tools -y

rm *.img
wget -O disk.tar.xz $imageURL
tar -xf disk.tar.xz
rm disk.tar.xz
mv disk.raw $imageName
qm destroy $virtualMachineId

virt-customize -a $imageName --install qemu-guest-agent
virt-customize -a $imageName --root-password password:$rootPasswd

qm create $virtualMachineId --name $templateName --memory $tmp_memory --cores $tmp_cores --net0 virtio,bridge=vmbr0
qm importdisk $virtualMachineId $imageName $volumeName

qm set $virtualMachineId --machine q35
qm set $virtualMachineId --scsihw virtio-scsi-pci --scsi0 $volumeName:vm-$virtualMachineId-disk-0
qm set $virtualMachineId --boot c --bootdisk scsi0
qm set $virtualMachineId --ide2 $volumeName:cloudinit 
qm set $virtualMachineId --serial0 socket --vga serial0
qm set $virtualMachineId --ipconfig0 ip=dhcp
qm set $virtualMachineId --cpu cputype=$cpuTypeRequired

qm template $virtualMachineId
