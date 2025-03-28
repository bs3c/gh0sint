#!/bin/bash

INSTALL_DIR="/opt/gh0sint"
LAUNCHER="/usr/local/bin/gh0sint"

REQUIRED_PACKAGES=(tor torsocks proxychains4 curl iproute2 yad)

check_and_install() {
    echo "📦 Checking dependencies..."
    local missing=()
    for pkg in "${REQUIRED_PACKAGES[@]}"; do
        if ! dpkg -s "$pkg" &>/dev/null; then
            missing+=("$pkg")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "📦 Installing missing packages: ${missing[*]}"
        sudo apt update && sudo apt install -y "${missing[@]}"
    else
        echo "✅ All dependencies installed."
    fi
}

copy_tool() {
    echo "📁 Installing gh0sint to $INSTALL_DIR..."
    sudo rm -rf "$INSTALL_DIR"
    sudo mkdir -p "$INSTALL_DIR"
    sudo cp -r ./* "$INSTALL_DIR"
    sudo chmod -R +x "$INSTALL_DIR"
}

create_launcher() {
    echo "🚀 Creating launcher script at $LAUNCHER..."

    echo "#!/bin/bash
cd $INSTALL_DIR
./gh0sint.sh \"\$@\"" | sudo tee "$LAUNCHER" >/dev/null

    sudo chmod +x "$LAUNCHER"
    echo "✅ You can now run the tool from anywhere with: gh0sint"
}

main() {
    check_and_install
    copy_tool
    create_launcher

    echo
    echo "🎉 Ghosint is ready to go!"
    echo "➡️  Try running: gh0sint --opsec"
}

main
