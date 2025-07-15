#!/bin/bash

# Script to check current CPU frequency and voltage status
# Usage: ./check_cpu_status.sh

echo "=== CPU Status Check ==="
echo

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo "Note: Some information may not be available without root privileges"
    echo
fi

# Function to check if file exists and is readable
check_file() {
    if [[ -r "$1" ]]; then
        return 0
    else
        return 1
    fi
}

# Current CPU frequency
echo "--- CPU Frequency Information ---"
if check_file "/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq"; then
    echo -n "Current frequency: "
    cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq
    echo " Hz"
else
    echo "Current frequency: Not available"
fi

if check_file "/sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq"; then
    echo -n "Minimum frequency: "
    cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
    echo " Hz"
fi

if check_file "/sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq"; then
    echo -n "Maximum frequency: "
    cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
    echo " Hz"
fi

if check_file "/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies"; then
    echo -n "Available frequencies: "
    cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies
fi

echo

# Current CPU voltage
echo "--- CPU Voltage Information ---"
voltage_found=false

# Try different possible voltage paths
voltage_paths=(
    "/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_voltage"
    "/sys/class/regulator/regulator.0/microvolts"
    "/sys/class/regulator/regulator.1/microvolts"
    "/sys/kernel/debug/regulator/regulator_summary"
)

for path in "${voltage_paths[@]}"; do
    if check_file "$path"; then
        echo -n "Current voltage ($path): "
        cat "$path"
        echo " mV"
        voltage_found=true
        break
    fi
done

if [[ "$voltage_found" == false ]]; then
    echo "Current voltage: Not available (platform dependent)"
fi

echo

# CPU Governor information
echo "--- CPU Governor Information ---"
if check_file "/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"; then
    echo -n "Current governor: "
    cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
else
    echo "Current governor: Not available"
fi

if check_file "/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors"; then
    echo -n "Available governors: "
    cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
fi

echo

# CPU load information
echo "--- CPU Load Information ---"
if command -v uptime &> /dev/null; then
    echo -n "System load: "
    uptime
fi

if [[ -r "/proc/loadavg" ]]; then
    echo -n "Load average: "
    cat /proc/loadavg
fi

echo

# Additional CPU information
echo "--- Additional CPU Information ---"
if [[ -r "/proc/cpuinfo" ]]; then
    echo "CPU Model:"
    grep "model name" /proc/cpuinfo | head -1
    echo "CPU Cores:"
    grep "cpu cores" /proc/cpuinfo | head -1
fi

# Temperature information (if available)
if [[ -r "/sys/class/thermal/thermal_zone0/temp" ]]; then
    echo -n "CPU Temperature: "
    temp=$(cat /sys/class/thermal/thermal_zone0/temp)
    echo "scale=1; $temp/1000" | bc 2>/dev/null || echo "$temp milli-°C"
    echo "°C"
fi

echo "=== End of CPU Status Check ==="
