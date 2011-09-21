#!/bin/bash
APP_NAME=napa-template.app
APP_NEW="../../PeerStreamer.app"
PEER_SRC=../../$1
SRC_LIST="mainfont.ttf stats_font.ttf README streamer-ml-monl-chunkstream napalogo_small.bmp icons peer_exec_name.conf channels.conf"
rm -rf $APP_NEW
cp -R $APP_NAME $APP_NEW
for res in $SRC_LIST; 
do 
  cp -R $PEER_SRC/$res $APP_NEW/Contents/Resources/
done;
cp -R $PEER_SRC/chunker_player $APP_NEW/Contents/MacOS/
strip $APP_NEW/Contents/MacOS/chunker_player 
strip $APP_NEW/Contents/Resources/streamer-ml-monl-chunkstream
