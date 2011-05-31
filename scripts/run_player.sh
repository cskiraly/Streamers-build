#!/bin/bash
echo -en "Downloading channels list..."
if [ -f channels.conf ]; then
  rm -f channels.conf
fi
wget --no-cache http://peerstreamer.org/~napawine/release/channels.conf
if [ ! -f channels.conf ]; then
  echo "File not found on the server, please contact peerstreamer.org"
else
  echo "done. Enjoy!"  
  DIR="PeerStreamer-`git describe --always --dirty || git describe --always`"
  cp channels.conf ../$DIR
  cd ..
  if  [ ! -d $DIR ]; then
    echo "check git diff and run make"
  else
  cd $DIR && ./chunker_player 1>player.log 2>player.err &
  fi 
fi
