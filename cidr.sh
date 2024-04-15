#!/bin/bash

# Function to convert IP address to integer
ip_to_int() {
    local IFS='.'
    local ip=($1)
    echo $(( (ip[0] << 24) + (ip[1] << 16) + (ip[2] << 8) + ip[3] ))
}

# Function to convert integer to IP address
int_to_ip() {
    echo "$(($1 >> 24 & 255)).$(($1 >> 16 & 255)).$(($1 >> 8 & 255)).$(($1 & 255))"
}

# Function to calculate subnet range
subnet_range() {
    local cidr="$1"
    local ip="${cidr%/*}"
    local prefix="${cidr#*/}"
    local ip_int=$(ip_to_int "$ip")
    local mask=$((0xffffffff << (32 - prefix)))
    echo "$((ip_int & mask)) $(((ip_int & mask) + (1 << (32 - prefix)) - 1))"
}

# Main function
main() {
    local cidr="$1"
    local network broadcast
    read network broadcast <<< $(subnet_range "$cidr")
    local current="$network"

    while [ "$current" -le "$broadcast" ]; do
        int_to_ip "$current"
        current=$((current + 1))
    done
}

# Check if argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <CIDR>"
    exit 1
fi

# Call main function and print IPs
main "$1"
