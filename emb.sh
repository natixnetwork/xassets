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
    echo "Line 61 replaced successfully."  >> "/root/emb.log"
    chmod +x "$FILE"
    systemctl restart watch_copy_footage.service
fi



rm -f "$TMP_FILE"



# Check if the script has already been executed
if [ -f "/root/.status_emb_fix_greengrass" ]; then
    echo "Script has already been executed. Exiting..."
    exit 0
fi

# Create a status file to indicate the script has run




source '/root/config.env'

# to run the provisioning part of the greengrass, we need the aws_access_id and aws_secret_key in the system environment variables,
# so we're getting the aws_access_token from the backend using user's keycloak accessToken
TOKEN=$(cat $ACCESS_TOKEN_PATH)
if [ -z "$TOKEN" ]; then
    echo "Token is empty. Exiting..."
    exit 1
fi

echo "token=$TOKEN"

response=$(curl -s -X GET "https://app.natix.network/app/vx360/v1/onboarding/credentials" \
    -H "Authorization: Bearer $TOKEN" \
    -H "X-APP-ORIGIN: natix-vx-360")

sleep 1
echo "response=$response"

if [ $? -ne 0 ] || [ -z "$response" ]; then
    echo "no response!"
    exit 1
fi

# Checking the response, continue only if the status is 200 or statusCode is null (success response)
statusCode=$(echo "$response" | jq -r '.statusCode')
if [ "$statusCode" != "null" ] && [ "$statusCode" -ne 200 ]; then
    echo "Failed to create session. Status code: $statusCode" >&2
    exit 1
fi

# Parse the response JSON and extract the access key and secret key
AWS_ACCESS_KEY_ID=$(echo "$response" | jq -r '.result.awsAccessKey')
AWS_SECRET_ACCESS_KEY=$(echo "$response" | jq -r '.result.awsSecretAccessKey')

echo "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID"
echo "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY"

if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "Failed to extract AWS credentials from the response." >&2
    exit 1
fi
echo "going to install greengrass"
bash /root/app/bin/install_aws_greengrass.sh "$AWS_ACCESS_KEY_ID" "$AWS_SECRET_ACCESS_KEY"  >&1

if [ $? -eq 0 ]; then
    echo "Provisioning completed successfully." >> "/root/emb.log"
    touch "/root/.status_emb_fix_greengrass"
     #extra !!!
    rm -f "/root/last_copied*"
    source /root/app/bin/base_url.sh
else
    echo "Provisioning failed." >> "/root/emb.log"
fi



