#!/bin/bash

#default values
FILE=/dev/stdin

VIDEO_BPS=500000
AUDIO_BPS=64000
VIDEO_CODEC=mpeg4
AUDIO_CODEC=libmp3lame
IPC_IP="127.0.0.1"
IPC_PORT=7777
PORT=6676
AUDIO=1
VIDEO=1
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
   echo "  -c capture video: Video device to capture /dev/video$VIDEO"
   echo "  -d capture audio: Audio device to capture $AUDIO"
   echo "  -I ip: IPC ip ($IPC_IP)"
   echo "  -P port: IPC port ($IPC_PORT)"
   exit $1
}

while getopts "f:v:a:V:A:lp:I:P:c:d:h" opt; do
   case $opt in

   f )  FILE=$OPTARG ;;
   v )  VIDEO_BPS=$OPTARG ;;
   a )  AUDIO_BPS=$OPTARG ;;
   V )  VIDEO_CODEC=$OPTARG ;;
   A )  AUDIO_CODEC=$OPTARG ;;
   l )  CHUNKER_XTRA+=" -l" ;;
   p )  PORT=$OPTARG ;;
   I )  IPC_IP=$OPTARG ;;
   P )  IPC_PORT=$OPTARG ;;
   c )  VIDEO=$OPTARG ;;
   d )  AUDIO=$OPTARG ;;
   h )  usage 0 ;;
   \?)  usage 1 ;;
   esac
done


# start the chunker
echo "./chunker_streamer -i $FILE -a $AUDIO_BPS -v $VIDEO_BPS -A $AUDIO_CODEC -V $VIDEO_CODEC -F tcp://${IPC_IP}:$IPC_PORT $CHUNKER_XTRA  2>chunker_streamer.err 1>chunker_streamer.log &"
~/Streamers-build/THIRDPARTY-LIBS/ffmpeg/ffmpeg -f video4linux2 -i /dev/video1 -f alsa -ac 2 -i hw:1,0 -vcodec mpeg4 -b 20M -g 1 -acodec mp2 -f nut - 2>ffmpeg.err | \
./chunker_streamer -i $FILE -a $AUDIO_BPS -v $VIDEO_BPS -A $AUDIO_CODEC -V $VIDEO_CODEC -F tcp://${IPC_IP}:$IPC_PORT $CHUNKER_XTRA  2>chunker_streamer.err 1>chunker_streamer.log &

sleep 1 && ~/v4l-utils/utils/v4l2-ctl/v4l2-ctl -d /dev/video1 -i $VIDEO --verbose  --set-audio-input=$AUDIO &
sleep 5 && ~/v4l-utils/utils/v4l2-ctl/v4l2-ctl -d /dev/video1 -i $VIDEO --verbose  --set-audio-input=$AUDIO &