#!/bin/bash

#  This is a sample script to be run on in emergency cases on device
echo "hi, i am  a emb!" > "/root/emb.log"


response="https://app.stage.natix.network"

VERSION=$(cat /root/.version)


if [ "$VERSION" = "1.1.3" ] || [ "$VERSION" = "1.1.4" ] || [ "$VERSION" = "1.1.5" ]; then

echo  "for $VERSION BASE URL should be $response..."

echo "Start setting BASE URL..."
VAR_NAME="BASE_URL"

# Check if the variable is already present in /etc/environment
if grep -q "^${VAR_NAME}=" /etc/environment; then
    echo "Variable ${VAR_NAME} already exists. Updating it..."
    # Use sed to replace the line
    sudo sed -i "s|^${VAR_NAME}=.*|${VAR_NAME}=\"${response}\"|" /etc/environment
else
    echo "Adding ${VAR_NAME} to /etc/environment..."
    # Append to the end of the file
    echo "${VAR_NAME}=\"${response}\"" | sudo tee -a /etc/environment > /dev/null
fi

export $(cat /etc/environment | xargs)

else
    echo "VERSION is $VERSION – skipping BASE_URL setup." >> "/root/emb.log"
fi
