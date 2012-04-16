#!/bin/bash

#default values
FILE=/dev/stdin

VIDEO_BPS=500000
AUDIO_BPS=64000
VIDEO_CODEC=mpeg4
AUDIO_CODEC=libmp3lame
IPC_IP="127.0.0.1"
IPC_PORT=$((7000 + ($RANDOM % 1000)))
SUBCHANNELS=1
RESTART=0

PORT=6666
SOURCE_COPIES=3

# Kill everything we've stared on exit (with trap).
trap "ps -o pid= --ppid $$ | xargs kill 2>/dev/null" 0

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
   echo "  -o : try to sync audio and video streams"
   echo "  -p port: UDP port used by the streamer ($PORT)"
   echo "  -m copies: copies of the stream sent out directly by the source ($SOURCE_COPIES)"
   echo "  -I ip: IPC ip ($IPC_IP)"
   echo "  -P port: IPC port ($IPC_PORT)"
   echo "  -q subchannels: number of subchannels generated ($SUBCHANNELS)"
   echo "     Note: this has to be in-line with chunker parameters (--passthrough, --indexchannel, --qualitylevels)"
   echo "  -c options: chunker extra option (e.g. -c '-s 640x480')"
   echo "  -s options: source streamer extra options (e.g. -s '-b 100')"
   echo "  -R : restart chunker if it dies for some reason (should not be needed with stable releases)"
   exit $1
}

while getopts "f:v:a:V:A:lop:m:I:P:c:s:Rq:h" opt; do
   case $opt in

   f )  FILE=$OPTARG ;;
   v )  VIDEO_BPS=$OPTARG ;;
   a )  AUDIO_BPS=$OPTARG ;;
   V )  VIDEO_CODEC=$OPTARG ;;
   A )  AUDIO_CODEC=$OPTARG ;;
   l )  CHUNKER_XTRA+=" -l" ;;
   o )  CHUNKER_XTRA+=" -o" ;;
   p )  PORT=$OPTARG ;;
   m )  SOURCE_COPIES=$OPTARG ;;
   I )  IPC_IP=$OPTARG ;;
   P )  IPC_PORT=$OPTARG ;;
   c )  CHUNKER_XTRA+=" "$OPTARG ;;
   s )  STREAMER_XTRA+=" "$OPTARG ;;
   R )  RESTART=1 ;;
   q )  SUBCHANNELS=$OPTARG ;;
   h )  usage 0 ;;
   \?)  usage 1 ;;
   esac
done

for (( j = 0;  $RESTART || j < 1; j++ )); do

  echo "starting chunker"
  DATE=`date +%Y%m%d_%H%M%S`
  ./chunker_streamer -i $FILE -a $AUDIO_BPS -v $VIDEO_BPS -A $AUDIO_CODEC -V $VIDEO_CODEC -F tcp://$IPC_IP:$(($IPC_PORT+$j*$SUBCHANNELS)) $CHUNKER_XTRA  1>chunker_streamer_$DATE.log 2>chunker_streamer_$DATE.err &
  CPID=$!

  SPID=""
  for (( i = 0; i < $SUBCHANNELS; i++ )); do
    echo "starting streamer $(($i+1))"
    ./streamer-ml-monl-chunkstream-static -P $(($PORT+$i)) -f tcp://0.0.0.0:$(($IPC_PORT+$j*$SUBCHANNELS+$i)) -m $SOURCE_COPIES --autotune_period 0 $STREAMER_XTRA &
    SPID+=" $!"
  done

  wait $CPID; kill $SPID
  sleep 1

done;

kill -9 $CPID


