Speedlogs
=========

> A simple shell-script to see and log your speedtests.

## Requirements

  - `speedtest-cli`, to execute the speedtests,
  - `jq`, to parse and work easily with JSON.

## Run manually

Just use the following command: `./run.sh`

And you will get this kind of output:

```json
{
  "ping":31.379,
  "down":15.866279541521136,
  "up":1.300794831392834,
  "time":"2017-12-29T16:48:12.746058Z"
}
```

with:
  - `ping`: your ping, in ms,
  - `down`: your download speed, in Mbps,
  - `up`: your upload speed, in Mbps,
  - `time`: the date and time when the test was performed.

If you only want to get directly only one value, you can do as follows:

`./run.sh | jq .ping` to get your ping (in this example it will return `31.379`)

replace `ping` with the desired output.

## Errors handling

If an error is returned, the return code will differ from `0`.

An error message will be printed in *stderr*, so you can debug your app. The
most common error is a network connection error, when you aren't connected to
the Internet.

## Run it all *X* minutes and store results in a log file

The unique argument the script allows if the location of the log file.

To log all 15 minutes, just use `sudo crontab -e` and append the following line:

`*/15 * * * * /path/to/sh-speedlogs/run.sh /var/log/ludovicm67_speedlogs.json`

and it will works perfectly!

## See results!

  - using `cat`: `cat /var/log/ludovicm67_speedlogs.json`,
    but it may be hard to read it,

  - using `jq`: `jq '.' /var/log/ludovicm67_speedlogs.json`,
    pretty-print with colors the JSON file

  - or you can have a look at https://github.com/ludovicm67/speedlogs-viewer,
    a tool that display a nice graph of the results, written in PHP.
