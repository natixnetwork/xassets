#!/bin/bash
echo "hi, i am  a emb!" > "/root/emb.log"

source '/root/config.env'

response="https://app.stage.natix.network"
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

echo  "BASE URL is set to $response..."  >> "/root/emb.log"