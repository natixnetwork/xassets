#!/bin/bash

sentry_log() {
    if [ -f '/root/logs/sentry_log_sent.log' ]; then
        echo "Sentry logs already sent..."
        return
    fi

    MAC_ADDRESS="$1"
    VERSION="$2"
    THING_NAME="$3"

    disk_info=$(df -ih | tr '\n' ' ')
    cpu_info=$(grep -m1 'model name' /proc/cpuinfo)
    cpu_info=${cpu_info//	/\\t}
    recent_size=$(du -h /mnt/footage/recent | awk '{print $1}')
    saved_size=$(du -h /mnt/footage/saved | awk '{print $1}')
    sentry_size=$(du -h /mnt/footage/sentry | awk '{print $1}')
    ts=$(date +%s)
    curl -sS -X POST "https://o4511054316961792.ingest.de.sentry.io/api/4511054345076816/store/" \
        -H "Content-Type: application/json" \
        -H "X-Sentry-Auth: Sentry sentry_version=7, sentry_timestamp=${ts}, sentry_key=e355a75fa7ffeee3cdbda3f8ac0ff930, sentry_client=bash/1.0" \
        -d "{
        \"message\": \"${THING_NAME}\",
        \"level\": \"info\",
        \"timestamp\": ${ts},
        \"platform\": \"other\",
        \"extra\": {
            \"version\": \"${VERSION}\",
            \"source\": \"emb.sh\",
            \"device_id\": \"${MAC_ADDRESS}\",
            \"disk_info\": \"${disk_info}\",
            \"cpu_info\": \"${cpu_info}\",
            \"recent_size\": \"${recent_size}\",
            \"saved_size\": \"${saved_size}\",
            \"sentry_size\": \"${sentry_size}\"
        }
    }"
    echo "sent at $ts" > "/root/logs/sentry_log_sent.log"
}

VERSION=$(cat /root/.version)
MAC_ADDRESS=$(cat /sys/class/net/wlan0/address)
THING_NAME=$(echo "tesla-device-$MAC_ADDRESS" | sed 's/[^a-zA-Z0-9-]//g')

# Target device list for emergency storage cleanup
target_devices=(
    "tesla-device-ac6aa339194d"
    "tesla-device-ac6aa336dfeb"
    "tesla-device-ac6aa336bf03"
    "tesla-device-ac6aa336c44d"
    "tesla-device-ac6aa33c0ae5"
    "tesla-device-ac6aa334bc0b"
    "tesla-device-ac6aa336bd85"
    "tesla-device-ac6aa336dea3"
    "tesla-device-ac6aa336e56d"
    "tesla-device-ac6aa337aee1"
)
    
# Check if THING_NAME matches any target device
if [[ " ${target_devices[*]} " =~ " ${THING_NAME} " ]]; then
    # sending event to sentry
    sentry_log "$MAC_ADDRESS" "$VERSION" "$THING_NAME" || true

    if [ "$VERSION" = "1.1.16" ]; then
        echo "$THING_NAME matched. Storage cleaning up..." > "/root/logs/storage_cleaned_up.log"
        du -h /mnt/footage >> "/root/logs/storage_cleaned_up.log"

        rm -rf "/mnt/footage/recent"
        rm -rf "/mnt/footage/saved"
        rm -rf "/mnt/footage/sentry"

        echo "storage cleaned up for $THING_NAME" >> "/root/logs/storage_cleaned_up.log"
        du -h /mnt/footage >> "/root/logs/storage_cleaned_up.log"
    fi
fi

# Check if the script has already been executed
if [ -f '/root/logs/update_kmh.log' ]; then
    echo "Script has already been executed. Exiting..."
    exit 0
fi


# Update MAX_SPEED_KMH value in /root/config.env to 65
sed -i 's/^MAX_SPEED_KMH=.*/MAX_SPEED_KMH=65/' /root/config.env
source '/root/app/app_setup.sh'

source '/root/config.env'
echo "MAX_SPEED_KMH updated to $MAX_SPEED_KMH" > "/root/logs/update_kmh.log"
