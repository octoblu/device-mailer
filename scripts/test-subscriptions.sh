#!/bin/sh
SERVER="meshblu.octoblu.com:443"
RECEIVED_MESSAGE_URL="http://requestb.in/phxbdcph"
MESSENGER_DEVICE_UUID=$(meshblu-util register -s $SERVER -o | tee messenger-device.json | jq -r '.uuid')
RECEIVER_DEVICE_UUID=$(meshblu-util register -s $SERVER -d "{\
 \"receiveWhitelist\": []\
, \"sendWhitelist\": [\"*\"]\
, \"discoverWhitelist\": [\"*\"]\
, \"configureWhitelist\": []\
, \"receiveAsWhitelist\": []\
, \"sendAsWhitelist\": []\
}" | tee receiver-device.json | jq -r '.uuid')

SUBSCRIBER_DEVICE_UUID=$(meshblu-util register -s $SERVER  -d "{\
 \"receiveWhitelist\": []\
, \"sendWhitelist\": []\
, \"configureWhitelist\": []\
, \"discoverWhitelist\": []\
}" | tee subscriber-device.json | jq -r '.uuid')

# meshblu-util update -d "{\
#  \"receiveAsWhitelist\": [\"$SUBSCRIBER_DEVICE_UUID\"]\
# }" ./receiver-device.json

meshblu-util subscription-create -e $RECEIVER_DEVICE_UUID -t received ./subscriber-device.json
meshblu-util create-hook --type received --url $RECEIVED_MESSAGE_URL ./subscriber-device.json

meshblu-util message -d "{\
 \"devices\":[\"$RECEIVER_DEVICE_UUID\"]
, \"areThingsBroken\":\"yes\"
  }" ./messenger-device.json
