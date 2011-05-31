#!/bin/bash
echo -en "Downloading channels list..."
if [ -f channels.conf ]; then
  rm -f channels.conf
fi
wget --no-cache http://peerstreamer.org/~napawine/release/channels.conf
if [ ! -f channels.conf ]; then
  echo "File not found on the server, please contact peerstreamer.org"
  exit;
fi

./chunker_player $@
