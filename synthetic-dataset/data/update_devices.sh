#!/bin/bash

# Script to update devices data in the HTML visualization from devices.csv

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CSV_FILE="$SCRIPT_DIR/devices.csv"
HTML_FILE="$SCRIPT_DIR/devices_map.html"

# Check if CSV file exists
if [ ! -f "$CSV_FILE" ]; then
    echo "Error: devices.csv not found at $CSV_FILE"
    exit 1
fi

echo "Reading devices from CSV..."

# Create temporary Python script file
cat > /tmp/update_devices_html.py << 'PYTHON_CODE'
import csv
import json
import re
import sys

csv_file = sys.argv[1]
html_file = sys.argv[2]

# Read all devices from CSV (keeping all columns)
devices = []
try:
    with open(csv_file, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            devices.append(row)
    
    print(f"Loaded {len(devices)} devices from CSV")
    
    # Generate JSON
    json_data = json.dumps(devices)
    
    # Read HTML file
    with open(html_file, 'r') as f:
        html_content = f.read()
    
    # Replace devices_data
    pattern = r'const devices_data = \[.*?\];'
    replacement = f'const devices_data = {json_data};'
    new_html = re.sub(pattern, replacement, html_content, flags=re.DOTALL)
    
    # Write updated HTML
    with open(html_file, 'w') as f:
        f.write(new_html)
    
    print(f"Updated devices_map.html with {len(devices)} devices")
    print("Reload the page in your browser to see the changes")
    
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
PYTHON_CODE

# Run the Python script
python3 /tmp/update_devices_html.py "$CSV_FILE" "$HTML_FILE"

# Cleanup
rm -f /tmp/update_devices_html.py
