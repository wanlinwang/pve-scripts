#!/bin/bash

echo "请输入旧的 VMID:"
read oldVMID
if ! [[ $oldVMID =~ ^[0-9]+$ ]]; then
    echo "输入错误，只接受数字。退出。"
    exit 1
fi
echo "旧 VMID - $oldVMID"
echo

echo "请输入新的 VMID:"
read newVMID
if ! [[ $newVMID =~ ^[0-9]+$ ]]; then
    echo "输入错误，只接受数字。退出。"
    exit 1
fi
echo "新 VMID - $newVMID"
echo

vgNAME=$(lvs --noheadings -o lv_name,vg_name | grep "$oldVMID" | awk '{print $2}' | uniq)

if [[ -z $vgNAME ]]; then
    echo "找不到该机器在的卷组。退出。"
    exit 1
fi
echo "卷组 - $vgNAME"
echo

for i in $(lvs -a --noheadings -o lv_name | grep $oldVMID); do
    disk_number=$(echo $i | grep -o '[0-9]\+$')
    lvrename "$vgNAME/$i" "${i/$oldVMID/$newVMID}"
done

sed -i "s/$oldVMID/$newVMID/g" "/etc/pve/qemu-server/$oldVMID.conf"
mv "/etc/pve/qemu-server/$oldVMID.conf" "/etc/pve/qemu-server/$newVMID.conf"

echo "Changed: $oldVMID to $newVMID"