#!/bin/bash

echo "🔧 Installing Ghosint..."

REQUIRED_PACKAGES=(tor torsocks proxychains4 curl iproute2 yad)

MISSING_PACKAGES=()

check_and_install() {
    for pkg in "${REQUIRED_PACKAGES[@]}"; do
        if ! dpkg -s "$pkg" &>/dev/null; then
            MISSING_PACKAGES+=("$pkg")
        fi
    done

    if [[ ${#MISSING_PACKAGES[@]} -gt 0 ]]; then
        echo "📦 Installing missing packages: ${MISSING_PACKAGES[*]}"
        sudo apt update && sudo apt install -y "${MISSING_PACKAGES[@]}"
    else
        echo "✅ All required packages are already installed."
    fi
}

set_permissions() {
    echo "🔐 Setting executable permissions..."
    chmod +x ghosint.sh
    chmod +x modules/*.sh
}

install_to_path() {
    echo "🚀 Adding gh0sint to /usr/local/bin..."

    # Create a wrapper if needed
    sudo cp "$(pwd)/ghosint.sh" /usr/local/bin/gh0sint
    sudo chmod +x /usr/local/bin/gh0sint

    echo "✅ You can now run the tool from anywhere with: gh0sint"
}

main() {
    check_and_install
    set_permissions
    install_to_path

    echo
    echo "🎉 Ghosint is fully installed!"
    echo "➡️  Run it from anywhere using: gh0sint"
}

main
