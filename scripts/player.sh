#!/bin/bash

# Kill everything we've stared or on exit (with trap).
function bashkilltrap()
{
  kill -15 -$$
  ps -o pid= --ppid $$ xargs kill 2>/dev/null
}
trap bashkilltrap 0

# some magic to make the installed version find resource files
WDIR=`readlink -f $0 | xargs dirname`
cd $WDIR

mkdir -p ~/.peerstreamer

./chunker_player $@ 2>&1 | tee ~/.peerstreamer/peerstreamer.log
