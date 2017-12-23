#!/bin/sh

speedtest-cli --json \
  | jq --compact-output \
    '{ping: .ping, down: .download, up: .upload, time: .timestamp} | to_entries | map(if .key == "down" or .key == "up" then .value/=1000000 else . end) | from_entries'