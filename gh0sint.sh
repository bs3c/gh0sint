#!/bin/bash

MODULES_DIR="./modules"

# Optional: Import a cool ASCII banner
if [[ -f ./utils/banner.sh ]]; then
    source ./utils/banner.sh
    print_banner
fi

echo "Welcome to Ghosint 🌐"
echo "Available modules:"
echo

# List modules
i=1
declare -A module_map
for module in "$MODULES_DIR"/*.sh; do
    module_name=$(basename "$module" .sh)
    echo "[$i] $module_name"
    module_map[$i]="$module"
    ((i++))
done

echo
read -p "Choose a module to run (number): " choice

selected_module="${module_map[$choice]}"

if [[ -n "$selected_module" && -f "$selected_module" ]]; then
    echo "Launching module: $(basename "$selected_module")"
    bash "$selected_module"
else
    echo "Invalid selection. Exiting."
    exit 1
fi
