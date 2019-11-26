#!/bin/bash
cpu_path="/sys/devices/system/cpu/"
for cpu in $(find $cpu_path -regex ".*/cpu[0-9]+$" -printf "%f\n"); do
	min=$(cat /sys/devices/system/cpu/$cpu/cpufreq/cpuinfo_min_freq)
	echo $min > /sys/devices/system/cpu/$cpu/cpufreq/scaling_max_freq
	echo "$cpu_path$cpu: $min"
done
