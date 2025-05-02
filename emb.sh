#!/bin/bash

#  This is a sample script to be run on in emergency cases on device
echo "hi, i am  a emb! 1.1.11 fix" > "/root/emb.log"

#!/bin/bash

FILE="/root/app/bin/watch_and_copy.sh"
TMP_FILE=$(mktemp)

# Replace the specific problematic line with the correct one, preserving indentation
awk '
NR == 61 {
    sub(/^[ \t]*/, indent);  # Save indentation
    print indent "if [[ \"$type\" == \"recent\" ]] && (( 10#$hour >= NIGHT_STRAT_TIME || 10#$hour < NIGHT_END_TIME )); then"
    next
}
{ print }
' indent="$(head -n 61 "$FILE" | tail -n 1 | grep -o '^[[:space:]]*')" "$FILE" > "$TMP_FILE"

if cmp -s "$FILE" "$TMP_FILE"; then
    echo "No change needed. Line 61 did not match expected pattern."
else
    mv "$TMP_FILE" "$FILE"
    echo "Line 61 replaced successfully."
    chmod +x "$FILE"
    systemctl restart watch_copy_footage.service
fi

rm -f "$TMP_FILE"


