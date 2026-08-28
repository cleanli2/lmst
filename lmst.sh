#!/bin/bash

# Path to the JSON configuration file
CONFIG_FILE="/c/f/s/lmst/llm_menu.json"

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' is not installed. Please install it to parse JSON."
    echo "Download from: https://stedolan.github.io/jq/download/"
    exit 1
fi

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file $CONFIG_FILE not found!"
    exit 1
fi

while true; do
    echo "========================================"
    echo "        Git Bash Custom Menu"
    echo "========================================"

    # Read labels from JSON and display them as a list
    # Extract the 'label' field from each object in the 'menu_items' array
    options=$(jq -r '.menu_items[].label' "$CONFIG_FILE")
    
    # Create a counter for the menu index
    i=1
    while read -r line; do
        echo "$i) $line"
        ((i++))
    done <<< "$options"

    echo "0) Exit"
    echo "========================================"
    read -p "Please select an option: " choice

    # Exit if user chooses 0
    if [ "$choice" == "0" ]; then
        echo "Exiting..."
        break
    fi

    # Validate if the input is a positive integer
    if [[ "$choice" =~ ^[0-9]+$ ]]; then
        # Extract the command corresponding to the selected index (index is 0-based in jq)
        index=$((choice - 1))
        cmd=$(jq -r ".menu_items[$index].command" "$CONFIG_FILE")

        # Check if the command exists (jq returns "null" if index out of bounds)
        if [ "$cmd" == "null" ] || [ -z "$cmd" ]; then
            echo "Invalid selection, exit."
	    exit
        else
            echo -e "\nExecuting: $cmd"
            echo "----------------------------------------"
            eval "$cmd"
            echo "----------------------------------------"
            read -p "Press Enter to return to menu..."
        fi
    else
        echo "Invalid input, exit."
	exit
    fi
done

