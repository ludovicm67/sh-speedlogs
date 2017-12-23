#!/bin/bash

# check existance of a command passed in arg $1
check_existence() {
  command -v "$1" > /dev/null 2>&1 \
    || ( \
      echo "Missing command '$1'."; \
      echo "Try installing it using 'sudo apt install $1'."; \
      exit 1 \
    )
}

# check existance of needed commands
check_existence speedtest-cli
check_existence jq

# results of the speedtest
SPEEDTEST_RESULTS=`speedtest-cli --json 2> /dev/null`

# generate a simple JSON
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
