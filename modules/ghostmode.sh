#!/bin/bash

check_dependencies() {
    for dep in tor torsocks curl; do
        command -v "$dep" >/dev/null 2>&1 || {
            echo "❌ Missing dependency: $dep"
            exit 1
        }
    done
}

start_tor() {
    echo "🔄 Starting Tor routing..."

    if ! pgrep tor >/dev/null; then
        sudo systemctl start tor
        sleep 3
    fi

    if pgrep tor >/dev/null; then
        echo "🟢 Tor is running."
    else
        echo "🔴 Failed to start Tor."
    fi
}

stop_tor() {
    echo "🛑 Stopping Tor routing..."
    sudo systemctl stop tor
    sleep 2
}

check_tor_status() {
    echo "🔍 Checking current routing..."

    real_ip=$(curl -s ifconfig.me)
    tor_status=$(torsocks curl -s https://check.torproject.org | grep -q "Congratulations" && echo "🟢 Routing through Tor" || echo "🔴 Not routing through Tor")

    echo
    echo "• Public IP: $real_ip"
    echo "• Tor Status: $tor_status"
    echo
}

ghostmode_menu() {
    start_tor
    while true; do
        clear
        echo "🧊 Ghosint: GhostMode (Tor Routing)"
        check_tor_status

        echo "Options:"
        echo "1) Stop Tor routing"
        echo "2) Restart Tor"
        echo "0) Return to Ghosint main menu"
        echo

        read -p "Choice: " choice
        case $choice in
            1) stop_tor ;;
            2) stop_tor; start_tor ;;
            0) break ;;
            *) echo "Invalid option"; sleep 1 ;;
        esac
    done
}

main() {
    check_dependencies
    ghostmode_menu
}

main
