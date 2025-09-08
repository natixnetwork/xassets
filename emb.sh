#!/bin/bash

#  This is a sample script to be run on in emergency cases on device
echo "hi, i am  a emb" > "/root/emb.log"

MAC_ADDRESS=$(cat /sys/class/net/wlan0/address)
THING_NAME=$(echo "tesla-device-$MAC_ADDRESS" | sed 's/[^a-zA-Z0-9-]//g')


# DEVICES_LIST=("tesla-device-ac6aa336bd85"
# "tesla-device-ac6aa336dea3"
# "tesla-device-ac6aa336e6b3"
# "tesla-device-ac6aa336e6ed"
# "tesla-device-ac6aa336e865"
# "tesla-device-ac6aa3374bd9"
# "tesla-device-ac6aa337c49d"
# "tesla-device-ac6aa337c58f"
# "tesla-device-ac6aa3380927"
# "tesla-device-ac6aa33918e5"
# "tesla-device-ac6aa3374c17"
# )

# if [[ " ${DEVICES_LIST[@]} " =~ " ${THING_NAME} " ]]; then
#     VERSION=$(cat /root/.version)
#     if [ "$VERSION" = "1.1.20" ]; then
#         echo  "Rolling back the 1.1.20 version to '1.1.15'..."
#         echo "1.1.15" > /root/.version
#     fi
# fi


# Check if the script has already been executed
if [ -f "/root/.status_emb_fix_greengrass" ]; then
    echo "Script has already been executed. Exiting..."
    exit 0
fi
