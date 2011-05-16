#!/bin/bash

#default values
FILE=/dev/stdin

VIDEO_BPS=500000
AUDIO_BPS=64000
VIDEO_CODEC=mpeg4
AUDIO_CODEC=libmp3lame
IPC_IP="127.0.0.1"
IPC_PORT=7777

PORT=6666
SOURCE_COPIES=3

# Usage: set paramters in this script (after the usage function), then run it with the command line option below
function usage () {
   echo "Usage: $0 [options]"
   echo "  options (and default values)"
   echo "  -f file: media file to stream ($FILE)"
   echo "  -v rate: video encoding rate in bps ($VIDEO_BPS)"
   echo "  -a rate: audio encoding rate in bps ($AUDIO_BPS)"
   echo "  -V codec: video encoder ($VIDEO_CODEC)"
   echo "  -A codec: audio encoder ($AUDIO_CODEC)"
   echo "  -l : the stream is a live source with its own timing"
   echo "  -p port: UDP port used by the streamer ($PORT)"
   echo "  -m copies: copies of the stream sent out directly by the source ($SOURCE_COPIES)"
   echo "  -I ip: IPC ip ($IPC_IP)"
   echo "  -P port: IPC port ($IPC_PORT)"
   exit $1
}

while getopts "f:v:a:V:A:lp:m:hI:P:" opt; do
   case $opt in

   f )  FILE=$OPTARG ;;
   v )  VIDEO_BPS=$OPTARG ;;
   a )  AUDIO_BPS=$OPTARG ;;
   V )  VIDEO_CODEC=$OPTARG ;;
   A )  AUDIO_CODEC=$OPTARG ;;
   l )  CHUNKER_XTRA+=" -l" ;;
   p )  PORT=$OPTARG ;;
   m )  SOURCE_COPIES=$OPTARG ;;
   I )  IPC_IP=$OPTARG ;;
   P )  IPC_PORT=$OPTARG ;;
   h )  usage 0 ;;
   \?)  usage 1 ;;
   esac
done


# start the chunker
./chunker_streamer -i $FILE -a $AUDIO_BPS -v $VIDEO_BPS -A $AUDIO_CODEC -V $VIDEO_CODEC -F tcp://$IPC_IP:$IPC_PORT $CHUNKER_XTRA  2>&1 1>chunker_streamer.log | tee chunker_streamer.err &
CPID=$!

# start a streamer as well
./streamer-ml-monl-chunkstream-static -P $PORT -f tcp://0.0.0.0:$IPC_PORT -m $SOURCE_COPIES

kill -9 $CPID




