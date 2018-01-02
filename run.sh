#!/bin/bash

# check existance of a command passed in arg $1
check_existence() {
  command -v "$1" > /dev/null 2>&1 \
    || ( \
      echo "Missing command '$1'." 1>&2; \
      echo "Try installing it using 'sudo apt install $1'." 1>&2; \
      exit 1 \
    )
}

# check existance of needed commands
check_existence speedtest-cli
check_existence jq

# results of the speedtest
SPEEDTEST_RESULTS=`speedtest-cli --json 2> /dev/null`
RES_CODE=$?

# if good results
if [ $RES_CODE -eq 0 ]; then
  RES_PRINT=`echo "$SPEEDTEST_RESULTS" \
    | jq -r --compact-output \
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
      | from_entries'`
# in case of bad results
else
  echo "Connection error." 1>&2
  CURRENT_DATE_UTC=`date -u +%FT%T.%6NZ`
  RES_PRINT=`echo '{
    "ping":-1,
    "down":0,
    "up":0,
    "time":"'"$CURRENT_DATE_UTC"'"
  }' | jq -r --compact-output '.'`
fi

# we print final results
echo "$RES_PRINT"

# if a file was specified in arg, we print log the content directly in it
if [ $# -eq 1 ]; then

  # if the file exists
  if [ -f "$1" ]; then
    CLEAN_FILE=`jq -r --compact-output '.' "$1" 2> /dev/null`
    if [ -z "$CLEAN_FILE" ]; then
      echo "[$RES_PRINT]" > "$1"
    else
      echo "$RES_PRINT" > "/tmp/ludovicm67_speedlogs.$$"
      RES_FILE=`jq -s -r --compact-output \
        '.[0][.[0] | length] = .[1] | .[0]' \
        "$1" "/tmp/ludovicm67_speedlogs.$$"`
      rm -f "/tmp/ludovicm67_speedlogs.$$"
      echo "$RES_FILE" > "$1"
    fi
  else
    echo "[$RES_PRINT]" > "$1"
  fi
fi

exit $RES_CODE
