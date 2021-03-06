#
# Cookbook Name:: loop-lvm
# Recipe:: default
#
# Copyright (C) 2014 Venkat Venkataraju
#
# All rights reserved - Do Not Redistribute
#

package "parted"

directory '/var/opt/lvm' do
  recursive true
  mode '0755'
end

directory '/mnt/loop-lvm' do
  owner 'root'
  group 'root'
  mode 00777
end

execute "create disk" do
  command "fallocate -l 200M /var/opt/lvm/disk0.img"
  not_if { ::File.exists? "/var/opt/lvm/disk0.img" }
end

execute "setup loopback" do
  command "/sbin/losetup /dev/loop0 /var/opt/lvm/disk0.img"
  not_if "/sbin/losetup -a | /bin/grep \"/var/opt/lvm/disk0.img\""
end

execute "create label for disk" do
  command "parted --align optimal /dev/loop0 --script -- mklabel gpt"
  not_if "parted /dev/loop0 --script -- print | /bin/grep \"Partition Table: gpt\""
  notifies :run, "execute[partition disk]", :immediately
end

execute "partition disk" do
  command "parted --align optimal /dev/loop0 --script -- mkpart primary 0% 100%"
  notifies :run, "execute[set lvm on disk]", :immediately
  action :nothing
end

execute "set lvm on disk" do
  command "parted --align optimal /dev/loop0 --script -- set 1 lvm on"
  action :nothing
end

execute "create physical volume" do
  command "pvcreate /dev/loop0"
  only_if "pvcreate /dev/loop0 -t"
end

execute "create volume group" do
  command "vgcreate loopg /dev/loop0"
  only_if "vgcreate loopg /dev/loop0 -t"
end

execute "create logical volume" do
  command "lvcreate --extents 85%VG --name lv loopg"
  only_if "lvcreate --extents 85%VG --name lv loopg -t"
end

execute '/sbin/mkfs.ext4 /dev/loopg/lv' do
  not_if '/usr/bin/file -sL /dev/loopg/lv | /bin/grep ext4'
end

execute '/bin/mount -t ext4 /dev/loopg/lv /mnt/loop-lvm' do
  not_if '/bin/mount | /bin/grep "/dev/loopg/lv"'
end
