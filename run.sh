#!/bin/bash

SPEEDTEST_RESULTS=`speedtest-cli --json 2> /dev/null`

[[ $? == 0 ]] \
  && echo "$SPEEDTEST_RESULTS" \
    | jq --compact-output \
      '{
        ping: .ping,
        down: .download,
        up: .upload,
        time: .timestamp
      }
      | to_entries
      | map(
        if
          .key == "down"
          or
          .key == "up"
        then
          .value/=1000000
        else
          .
        end
      )
      | from_entries' \
  || echo "Connection error."
