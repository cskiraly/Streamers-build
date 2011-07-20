#!/bin/bash

# Kill everything we've stared or on exit (with trap).
trap "ps -o pid= --ppid $$ | xargs kill 2>/dev/null" 0

echo -en "Downloading channels list..."
wget -N --no-cache http://peerstreamer.org/~napawine/release/channels.conf || curl -f -L -O http://peerstreamer.org/~napawine/release/channels.conf
if [ ! -f channels.conf ]; then
  echo "File not found on the server, please contact peerstreamer.org"
  exit;
fi

./chunker_player $@
