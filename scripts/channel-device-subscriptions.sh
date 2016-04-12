#!/bin/sh
SERVER="meshblu.octoblu.dev:80"
RECEIVED_MESSAGE_URL="http://requestb.in/15ygj4h1"
USER_DEVICE_UUID=$(meshblu-util register -s $SERVER -f ../data/device-user-config.json | tee ../tmp/meshblu-user-device.json | jq -r '.uuid')
CREDENTIALS_DEVICE_UUID=$(meshblu-util register -s $SERVER -f ../data/device-credentials-config.json | tee ../tmp/meshblu-credentials-device.json | jq -r '.uuid')
MESSENGER_DEVICE_UUID=$(meshblu-util register -s $SERVER | tee ../tmp/meshblu-messenger-device.json | jq -r '.uuid')

meshblu-util subscription-create -e $CREDENTIALS_DEVICE_UUID -t message.received ../tmp/meshblu-credentials-device.json
meshblu-util subscription-create -e $USER_DEVICE_UUID -t message.received ../tmp/meshblu-credentials-device.json

meshblu-util create-hook --type message.received --url $RECEIVED_MESSAGE_URL ../tmp/meshblu-credentials-device.json

meshblu-util message -d "{ \"devices\":[\"$USER_DEVICE_UUID\"], \"areThingsGood\":\"yes\"}" ../tmp/meshblu-messenger-device.json
