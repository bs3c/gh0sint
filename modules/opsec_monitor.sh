#!/bin/bash

command -v zenity >/dev/null 2>&1 || { echo "Zenity is required."; exit 1; }

# Collect info
public_ip=$(curl -s ifconfig.me)
tor_check=$(curl -s https://check.torproject.org | grep -q "Congratulations" && echo "✔️ Using Tor" || echo "❌ Not using Tor")
mac=$(ip link | grep ether | awk '{print $2}' | head -n 1)
hostname=$(hostname)
default_iface=$(ip route | grep default | awk '{print $5}' | head -n 1)
dns=$(grep "nameserver" /etc/resolv.conf | awk '{print $2}' | paste -sd ", ")
suspicious_procs=$(ps aux | grep -Ei "keylog|tcpdump|wireshark|netcat|nmap|socat|nc|strace" | grep -v grep)
foreign_ssh=$(last -ai | grep -vE "127.0.0.1|::1" | tail -n 5)

# Build output
output="🔒 OPSEC Report

• Hostname: $hostname
• Interface: $default_iface
• MAC Address: $mac
• Public IP: $public_ip
• DNS: $dns
• Tor Status: $tor_check
"

if [[ ! -z "$suspicious_procs" ]]; then
    output+="\n⚠️ Suspicious processes:\n$suspicious_procs"
fi

if [[ ! -z "$foreign_ssh" ]]; then
    output+="\n⚠️ Recent external SSH logins:\n$foreign_ssh"
fi

zenity --info \
  --title="OPSEC Monitor - Ghosint" \
  --width=600 \
  --height=400 \
  --text="$output"
