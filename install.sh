#!/bin/bash

INSTALL_DIR="/opt/gh0sint"
LAUNCHER="/usr/local/bin/gh0sint"
REQUIRED_PACKAGES=(tor torsocks proxychains4 curl iproute2 yad)

echo "🔧 Ghosint Installer"

check_and_install_dependencies() {
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

copy_tool_files() {
    echo "📁 Copying Ghosint to $INSTALL_DIR..."
    sudo rm -rf "$INSTALL_DIR"
    sudo mkdir -p "$INSTALL_DIR"
    sudo cp -r . "$INSTALL_DIR"
    sudo chmod -R +x "$INSTALL_DIR"
}

create_launcher() {
    echo "🚀 Creating launcher at $LAUNCHER..."

    sudo tee "$LAUNCHER" > /dev/null <<EOF
#!/bin/bash
BASE_DIR="$INSTALL_DIR"
MODULES_DIR="\$BASE_DIR/modules"
UTILS_DIR="\$BASE_DIR/utils"

# Print banner if it exists
[[ -f "\$UTILS_DIR/banner.sh" ]] && source "\$UTILS_DIR/banner.sh" && print_banner

run_module_directly() {
    for arg in "\$@"; do
        case "\$arg" in
            --ghostmode)
                bash "\$MODULES_DIR/ghostmode.sh"
                ;;
            --opsec)
                bash "\$MODULES_DIR/opsec_gui.sh"
                ;;
            *)
                echo "❌ Unknown flag: \$arg"
                echo "Usage: gh0sint [--ghostmode] [--opsec]"
                exit 1
                ;;
        esac
    done
    exit 0
}

show_menu() {
    while true; do
        echo "🌐 Welcome to Ghosint"
        echo "Available modules:"
        echo

        i=1
        declare -A module_map
        for module in "\$MODULES_DIR"/*.sh; do
            module_name=\$(basename "\$module" .sh)
            echo "[$i] \$module_name"
            module_map[\$i]="\$module"
            ((i++))
        done

        echo "[0] Exit"
        echo
        read -p "Choose a module to run (number): " choice

        if [[ "\$choice" == "0" ]]; then
            echo "👻 Exiting Ghosint."
            exit 0
        fi

        selected_module="\${module_map[\$choice]}"
        if [[ -n "\$selected_module" && -f "\$selected_module" ]]; then
            echo "🚀 Launching module: \$(basename "\$selected_module")"
            bash "\$selected_module"
        else
            echo "❌ Invalid selection. Try again."
        fi

        echo
        read -p "Press Enter to return to the menu..." dummy
        clear
    done
}

main() {
    if [[ \$# -gt 0 ]]; then
        run_module_directly "\$@"
    else
        show_menu
    fi
}

main "\$@"
EOF

    sudo chmod +x "$LAUNCHER"
    echo "✅ You can now run Ghosint globally with: gh0sint"
}

main() {
    check_and_install_dependencies
    copy_tool_files
    create_launcher

    echo
    echo "🎉 Ghosint is installed!"
    echo "➡️  Run it from anywhere using: gh0sint"
    echo "➡️  Or use flags like: gh0sint --opsec --ghostmode"
}

main
