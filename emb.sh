#!/bin/bash

#  This is a sample script to be run on in emergency cases on device
echo "hi, i am  a emb" > "/root/emb.log"

MAC_ADDRESS=$(cat /sys/class/net/wlan0/address)
THING_NAME=$(echo "tesla-device-$MAC_ADDRESS" | sed 's/[^a-zA-Z0-9-]//g')

# 'tesla-device-ac6aa339194d'
# 'tesla-device-ac6aa336dfeb'
# 'tesla-device-ac6aa336bf03'
# Delete all contents of /mnt/footage if THING_NAME matches any target
if [ "$THING_NAME" = "tesla-device-ac6aa336bf03" ] || \
    [ "$THING_NAME" = "tesla-device-ac6aa339194d" ] || \
    [ "$THING_NAME" = "tesla-device-ac6aa336dfeb" ]; then
     VERSION=$(cat /root/.version)
     if [ "$VERSION" = "1.1.16" ]; then
          if [ -d "$DEST_DIR" ]; then
                echo "THING_NAME matched. Cleaning $DEST_DIR..."
                if [ "$DEST_DIR" != "/" ]; then
                     rm -rf "$DEST_DIR/recent"
                     rm -rf "$DEST_DIR/saved"
                     rm -rf "$DEST_DIR/sentry"
                     echo "Cleanup completed."
                else
                     echo "Safety check failed: refusing to operate on /"
                fi
          else
                echo "Directory $DEST_DIR does not exist."
          fi
     fi
fi


# Check if the script has already been executed
if [ -f "/root/.status_emb_fix_greengrass" ]; then
    echo "Script has already been executed. Exiting..."
    exit 0
fi
