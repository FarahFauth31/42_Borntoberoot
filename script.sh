#!/bin/bash

# Architecture of the system and kernel version
arch=$(uname -a)

# Number of physical nuclei
phys_nuc=$(grep "physical id" /proc/cpuinfo | wc -l)

# Number of virtual nuclei
virt_nuc=$(grep "processor" /proc/cpuinfo | wc -l)

# Available RAM memory in the server and its usage percentage
ram_total=$(free --mega | awk '$1 == "Mem:" {print $2}')
ram_used=$(free --mega | awk '$1 == "Mem:" {print $3}')
ram_percentage=$(free --mega | awk '$1 == "Mem:" {printf("%.2f"), $3/$2*100}')

# Available memory in the server and its usage percentage
d_total=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{disk_t += $2} END {printf ("%.1fGb\n"), disk_t/1024}')
d_used=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{disk_u += $3} END {print disk_u}')
d_percentage=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{disk_u += $3} {disk_t+= $2} END {printf("%d"), disk_u/disk_t*100}')

# Usage percentage of the nuclei
use_nuc=$(vmstat 1 2 | tail -1 | awk '{printf $15}')
use_nuc_sub=$(expr 100 - $cpul)
use_nuc_res=$(printf "%.1f" $cpu_op)

# Date and time of last restart
last_restart=$(who -b | awk '$1 == "system" {print $3 " " $4}')

# If LVM is active
active_LVM=$(if [ $(lsblk | grep "lvm" | wc -l) -gt 0 ]; then echo yes; else echo no; fi)

# Number of active connections
active_con=$(ss -ta | grep ESTAB | wc -l)

# Number of users in server
nusers=$(users | wc -w)

# Direction IPv4 of the server and its MAC
ip=$(hostname -I)
dir=$(ip link | grep "link/ether" | awk '{print $2}')

# Number of commands executed with sudo
command_sudo=$(journalctl _COMM=sudo | grep COMMAND | wc -l)

wall "	Architecture: $arch
	CPU physical: $phys_nuc
	vCPU: $virt_nuc
	Memory Usage: $ram_used/${ram_total}MB ($ram_percentage%)
	Disk Usage: $d_used/${d_total} ($d_percentage%)
	CPU load: $use_nuc_res%
	Last boot: $last_restart
	LVM use: $active_LVM
	Connections TCP: $active_con ESTABLISHED
	User log: $nusers
	Network: IP $ip ($dir)
	Sudo: $command_sudo cmd"
