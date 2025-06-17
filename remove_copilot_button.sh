#!/bin/bash

# Bash Script to remove Copilot button from VSCodium
# This patches the minified workbench.desktop.main.js file with exact pattern matching

set -e  # Exit on any error

# Configuration
WORKBENCH_FILE="VSCode-win32-x64/resources/app/out/vs/workbench/workbench.desktop.main.js"
BACKUP_FILE="${WORKBENCH_FILE}.backup"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
color_echo() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

color_echo "$BLUE" "=== VSCodium Copilot Button Removal Script v2 ==="
echo ""

# Check if the workbench file exists
if [ ! -f "$WORKBENCH_FILE" ]; then
    color_echo "$RED" "Error: Workbench file not found at: $WORKBENCH_FILE"
    color_echo "$YELLOW" "Please make sure you're running this script from the correct directory."
    exit 1
fi

# Create backup if it doesn't exist
if [ ! -f "$BACKUP_FILE" ]; then
    color_echo "$YELLOW" "Creating backup..."
    cp "$WORKBENCH_FILE" "$BACKUP_FILE"
    color_echo "$GREEN" "Backup created: $BACKUP_FILE"
else
    color_echo "$YELLOW" "Backup already exists: $BACKUP_FILE"
fi

# Read the file content
color_echo "$YELLOW" "Reading workbench file..."
content=$(cat "$WORKBENCH_FILE")

patches_applied=0
original_content="$content"

# Pattern 1: CommandCenter appendMenuItem with d(4787,null)
pattern1_name="CommandCenter appendMenuItem"
color_echo "$YELLOW" "Searching for: $pattern1_name"

# Use sed to find and replace the pattern
if grep -q "re\.appendMenuItem.*ChatTitleBarMenu.*d(4787" "$WORKBENCH_FILE"; then
    color_echo "$GREEN" "Found pattern: $pattern1_name"
    # Use sed to replace the pattern
    sed -i.tmp 's/re\.appendMenuItem(E\.CommandCenter,{submenu:E\.ChatTitleBarMenu,title:d(4787,null),icon:P\.copilot[^}]*})/\/\* REMOVED COPILOT BUTTON - CommandCenter \*\/ undefined/g' "$WORKBENCH_FILE"
    rm -f "${WORKBENCH_FILE}.tmp"
    ((patches_applied++))
    color_echo "$GREEN" "Applied patch: $pattern1_name"
else
    color_echo "$RED" "Pattern not found: $pattern1_name"
    color_echo "$YELLOW" "This might already be patched or the pattern has changed."
fi

# Pattern 2: TitleBar appendMenuItem with d(4788,null)
pattern2_name="TitleBar appendMenuItem"
color_echo "$YELLOW" "Searching for: $pattern2_name"

if grep -q "re\.appendMenuItem.*ChatTitleBarMenu.*d(4788" "$WORKBENCH_FILE"; then
    color_echo "$GREEN" "Found pattern: $pattern2_name"
    # Use sed to replace the pattern
    sed -i.tmp 's/re\.appendMenuItem(E\.TitleBar,{submenu:E\.ChatTitleBarMenu,title:d(4788,null)[^}]*})/\/\* REMOVED COPILOT BUTTON - TitleBar \*\/ undefined/g' "$WORKBENCH_FILE"
    rm -f "${WORKBENCH_FILE}.tmp"
    ((patches_applied++))
    color_echo "$GREEN" "Applied patch: $pattern2_name"
else
    color_echo "$RED" "Pattern not found: $pattern2_name"
    color_echo "$YELLOW" "This might already be patched or the pattern has changed."
fi

# Check if any changes were made by comparing file sizes or checking for our replacement text
if grep -q "REMOVED COPILOT BUTTON" "$WORKBENCH_FILE"; then
    if [ "$patches_applied" -eq 0 ]; then
        color_echo "$GREEN" "File appears to already be patched (found REMOVED COPILOT BUTTON comments)."
        exit 0
    fi
else
    if [ "$patches_applied" -eq 0 ]; then
        color_echo "$RED" "No patterns were found. The file might have a different structure."
        color_echo "$YELLOW" "Manual inspection may be required."
        exit 1
    fi
fi

echo ""
color_echo "$BLUE" "=== Patch Summary ==="
color_echo "$GREEN" "Patches applied: $patches_applied"
color_echo "$GREEN" "File successfully patched: $WORKBENCH_FILE"
echo ""
color_echo "$BLUE" "Next steps:"
color_echo "$NC" "1. Restart VSCodium completely"
color_echo "$NC" "2. The Copilot button should no longer appear in the top bar"
echo ""
color_echo "$YELLOW" "To restore the original file:"
color_echo "$NC" "cp \"$BACKUP_FILE\" \"$WORKBENCH_FILE\"" 