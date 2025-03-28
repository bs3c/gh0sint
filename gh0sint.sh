#!/bin/bash

MODULES_DIR="./modules"

print_banner() {
    [[ -f ./utils/banner.sh ]] && source ./utils/banner.sh && print_banner
}

run_module_directly() {
    case "$1" in
        --ghostmode)
            bash "$MODULES_DIR/ghostmode.sh"
            exit 0
            ;;
        --opsec)
            bash "$MODULES_DIR/opsec_gui.sh"
            exit 0
            ;;
        *)
            echo "❌ Unknown flag: $1"
            echo "Usage: $0 [--ghostmode | --opsec]"
            exit 1
            ;;
    esac
}

show_menu() {
    while true; do
        echo "🌐 Welcome to Ghosint"
        echo "Available modules:"
        echo

        i=1
        declare -A module_map
        for module in "$MODULES_DIR"/*.sh; do
            module_name=$(basename "$module" .sh)
            echo "[$i] $module_name"
            module_map[$i]="$module"
            ((i++))
        done

        echo "[0] Exit"
        echo
        read -p "Choose a module to run (number): " choice

        if [[ "$choice" == "0" ]]; then
            echo "👻 Exiting Ghosint."
            exit 0
        fi

        selected_module="${module_map[$choice]}"
        if [[ -n "$selected_module" && -f "$selected_module" ]]; then
            echo "🚀 Launching module: $(basename "$selected_module")"
            bash "$selected_module"
        else
            echo "❌ Invalid selection. Try again."
        fi

        echo
        read -p "Press Enter to return to the menu..." dummy
        clear
    done
}

main() {
    print_banner

    if [[ $# -gt 0 ]]; then
        run_module_directly "$1"
    else
        show_menu
    fi
}

main "$@"
