#!/bin/bash

check_dependencies() {
    for tool in zenity curl ip hostname awk grep sed; do
        command -v "$tool" >/dev/null 2>&1 || {
            echo "$tool is required but not installed. Exiting."
            exit 1
        }
    done
}

generate_opsec_report() {
    public_ip=$(curl -s ifconfig.me)
    tor_check=$(curl -s https://check.torproject.org | grep -q "Congratulations" && echo "✔️ Using Tor" || echo "❌ Not using Tor")
    mac=$(ip link | grep ether | awk '{print $2}' | head -n 1)
    hostname=$(hostname)
    default_iface=$(ip route | grep default | awk '{print $5}' | head -n 1)
    dns=$(grep "nameserver" /etc/resolv.conf | awk '{print $2}' | paste -sd ", ")
    interfaces=$(ip -br addr | awk '{print $1 " => " $3}')
    suspicious_procs=$(ps aux | grep -Ei "keylog|tcpdump|wireshark|netcat|nmap|socat|nc|strace" | grep -v grep)
    foreign_ssh=$(last -ai | grep -vE "127.0.0.1|::1" | head -n 5)

    output="🔒 Ghosint - Live OPSEC Monitor

• Hostname: $hostname
• Interface: $default_iface
• MAC Address: $mac
• Public IP: $public_ip
• DNS: $dns
• Tor Status: $tor_check
• Interfaces:
$interfaces
"

    [[ ! -z "$suspicious_procs" ]] && output+="\n⚠️ Suspicious Processes:\n$suspicious_procs\n"
    [[ ! -z "$foreign_ssh" ]] && output+="\n⚠️ Recent External SSH Logins:\n$foreign_ssh"

    echo -e "$output"
}

launch_gui_monitor() {
    (
        while true; do
            generate_opsec_report
            sleep 5
        done
    ) | zenity --text-info \
        --title="Ghosint - Live OPSEC Monitor" \
        --width=700 --height=500 \
        --font="monospace 10" \
        --timeout=0 \
        --auto-scroll
}

main() {
    check_dependencies
    launch_gui_monitor &
    disown
    echo "OPSEC Monitor launched. You can continue using Ghosint while it's running."
    sleep 1
}

main
