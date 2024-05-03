#!/bin/bash

#architecture
architecture=$(uname -m)

#physical cpu
cpuf=$(grep "physical id" /proc/cpuinfo | wc -l)

#virtual cpu
cpuv=$(grep processor /proc/cpuinfo | wc -l)

#RAM
total_ram=$(free --mega | awk '$1 == "Mem:" {print $2}')
use_ram=$(free --mega | awk '$1 == "Mem:" {print $3}')
percent_ram=$(free --mega | awk '$1 == "Mem:" {printf("%.2f%%"), $3/$2*100}')

#disk
total_disk=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{disk_t += $2} END {printf ("%.1fGb\n"), disk_t/1024}')
use_disk=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{disk_u += $3} END {print disk_u}')
percent_disk=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{disk_u += $3} {disk_t+= $2} END {printf("%d%%"), disk_u/disk_t*100}')

#cpu_usage
cpul=$(vmstat 1 4 | tail -1 | awk '{printf $15}')
cpu_op=$(expr 100 - $cpul)
cpu_fin=$(printf "%.1f" $cpu_op)

#last_boot
lb=$(who -b | awk '$1 == "system" {print $3 " " $4}')

#lvm_active
lvmu=$(if [ $(lsblk | grep "lvm" | wc -l) -gt 0 ]; then echo yes; else echo no; fi)

#tcp_connection
tcpc=$(ss -ta | grep ESTAB | wc -l)

#user_log
ulog=$(users | wc -w)

#network
ip=$(hostname -I)
mac=$(ip link | grep "link/ether" | awk '{print $2}')

#sudo
cmnd=$(journalctl _COMM=sudo | grep COMMAND | wc -l)

wall "	Architecture: $architecture
	CPU physical: $cpuf
	vCPU: $cpuv
	Memory Usage: $use_ram/${total_ram}MB ($percent_ram)
	Disk Usage: $use_disk/${total_disk} ($percent_disk)
	CPU load: $cpu_fin%
	Last boot: $lb
	LVM use: $lvmu
	Connections TCP: $tcpc ESTABLISHED
	User log: $ulog
	Network: IP $ip ($mac)
	Sudo: $cmnd cmd"