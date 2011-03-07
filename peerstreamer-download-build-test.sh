#!/bin/bash

mkdir PeerStreamer
cd PeerStreamer

BASEDIR=`pwd`

#prepare x264 (optional)
git clone git://git.videolan.org/x264.git
cd x264
./configure --prefix=$BASEDIR/x264-install/
make -j 2
make install
cd ..

#prepare ffmpeg
git clone git://git.videolan.org/ffmpeg.git
cd ffmpeg
./configure --enable-libx264 --enable-gpl --enable-pthreads --extra-cflags=-I$BASEDIR/x264-install/include --extra-ldflags=-L$BASEDIR/x264-install/lib --prefix=$BASEDIR/ffmpeg-install
#in case x264 is not reqired (do we need the encoding?): ./configure --enable-gpl --enable-pthreads --prefix=$BASEDIR/ffmpeg-install
make -j 2
make install
cd ..

#prepare GRAPES
git clone http://halo.disi.unitn.it/~abeni/PublicGits/GRAPES.git
cd GRAPES
FFDIR=$BASEDIR/ffmpeg make
cd ..

#prepare the Streamer
git clone http://halo.disi.unitn.it/~cskiraly/PublicGits/Streamers.git
cd Streamers
GRAPES=$BASEDIR/GRAPES FFMPEG_DIR=$BASEDIR/ffmpeg X264_DIR=$BASEDIR/x264 make
cd ..

#get test scripts
git clone http://www.disi.unitn.it/~kiraly/SharedGits/Streamers-test.git

#run a test
mkdir test
cd test
wget http://halo.disi.unitn.it/~cskiraly/video/test.ts
$BASEDIR/Streamers-test/test.sh -e $BASEDIR/Streamers/streamer-grapes -N 0 -X 0 -v test.ts -o "$BASEDIR/ffmpeg/ffplay -" -O 1
