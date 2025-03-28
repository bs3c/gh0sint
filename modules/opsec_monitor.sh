#!/bin/bash

check_dependencies() {
    for tool in yad curl ip hostname awk grep sed; do
        command -v "$tool" >/dev/null 2>&1 || {
            echo "$tool is required but not installed. Exiting."
            exit 1
        }
    done
}

get_interface_info() {
    interfaces_output=""
    interfaces=$(ip -br link | awk '{print $1}')

    for iface in $interfaces; do
        ipv4=$(ip -4 addr show "$iface" | awk '/inet / {print $2}')
        ipv6=$(ip -6 addr show "$iface" | awk '/inet6 / {print $2}')
        
        # Skip interfaces with no IPs
        [[ -z "$ipv4" && -z "$ipv6" ]] && continue

        interfaces_output+="Interface: $iface\n"
        [[ -n "$ipv4" ]] && interfaces_output+="  ▸ IPv4: $ipv4\n"
        [[ -n "$ipv6" ]] && interfaces_output+="  ▸ IPv6: $ipv6\n"
        interfaces_output+="\n"
    done

    echo -e "$interfaces_output"
}

generate_opsec_report() {
    public_ip=$(curl -s ifconfig.me)
    tor_check=$(curl -s https://check.torproject.org | grep -q "Congratulations" && echo "✔️ Using Tor" || echo "❌ Not using Tor")
    mac=$(ip link | grep ether | awk '{print $2}' | head -n 1)
    hostname=$(hostname)
    default_iface=$(ip route | grep default | awk '{print $5}' | head -n 1)
    dns=$(grep "nameserver" /etc/resolv.conf | awk '{print $2}' | paste -sd ", ")
    interfaces=$(get_interface_info)
    suspicious_procs=$(ps aux | grep -Ei "keylog|tcpdump|wireshark|netcat|nmap|socat|nc|strace" | grep -v grep)
    foreign_ssh=$(last -ai | grep -vE "127.0.0.1|::1" | head -n 5)

    output="🔒 Ghosint - Live OPSEC Monitor

• Hostname: $hostname
• Default Interface: $default_iface
• MAC Address: $mac
• Public IP: $public_ip
• DNS: $dns
• Tor Status: $tor_check

• Interfaces:
$interfaces
"

    [[ -n "$suspicious_procs" ]] && output+="⚠️ Suspicious Processes:\n$suspicious_procs\n\n"
    [[ -n "$foreign_ssh" ]] && output+="⚠️ Recent External SSH Logins:\n$foreign_ssh\n"

    echo -e "$output"
}

launch_yad_monitor() {
    (
        while true; do
            clear
            generate_opsec_report
            sleep 5
        done
    ) | yad --text-info \
        --title="Ghosint - Live OPSEC Monitor" \
        --width=800 \
        --height=600 \
        --fontname="monospace 10" \
        --center \
        --window-icon=dialog-information \
        --no-buttons \
        --timeout-indicator=bottom \
        --forever
}

main() {
    check_dependencies
    launch_yad_monitor &
    disown
    echo "✅ OPSEC Monitor launched. You can continue using Ghosint while it runs in the background."
    sleep 1
}

main

