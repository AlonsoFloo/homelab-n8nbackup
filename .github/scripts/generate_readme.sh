#!/bin/bash
set -e

# Directory containing the JSON files
BACKUP_DIR="n8nbackups"

# Output README file
README_FILE="$BACKUP_DIR/README.md"

# Temporary file to store data for sorting
TMP_FILE=$(mktemp)

# Ensure the temporary file is removed on exit
trap 'rm -f "$TMP_FILE"' EXIT

# Add table header to README
{
  echo "# n8n Workflows"
  echo ""
  echo "| Filename | Name |"
  echo "|---|---|"
} > "$README_FILE"

# Process each JSON file
for file in "$BACKUP_DIR"/*.json; do
  if [ -f "$file" ]; then
    # Extract the name from the JSON file. If not found, default to UNKNOWN.
    name=$(jq -r '.name' "$file")
    if [ "$name" == "null" ] || [ -z "$name" ]; then
        name="UNKNOWN"
    fi
    filename=$(basename "$file")
    echo "$filename|$name" >> "$TMP_FILE"
  fi
done

# Sort the data by name (the second column) and append to README
sort -t'|' -k2 "$TMP_FILE" | while IFS='|' read -r filename name; do
  echo "| $filename | $name |" >> "$README_FILE"
done

echo "README.md generated successfully in $BACKUP_DIR"
