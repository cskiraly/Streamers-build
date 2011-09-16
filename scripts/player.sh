#!/bin/bash

# Kill everything we've stared or on exit (with trap).
function bashkilltrap()
{
  kill -15 -$$
  ps -o pid= --ppid $$ xargs kill 2>/dev/null
}
trap bashkilltrap 0

mkdir -p ~/.peerstreamer

./chunker_player $@
