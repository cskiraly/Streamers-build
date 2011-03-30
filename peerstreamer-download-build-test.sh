#!/bin/bash

mkdir PeerStreamer
cd PeerStreamer

BASEDIR=`pwd`
THIRDPARTYLIBS=$BASEDIR/THIRDPARTY-LIBS

mkdir $THIRDPARTYLIBS
cd $THIRDPARTYLIBS

#prepare x264 (optional)
git clone git://git.videolan.org/x264.git
cd x264
./configure --prefix=$THIRDPARTYLIBS/x264-install/ || { echo "Error configuring x264" && exit 1; }
make -j 2 || { echo "Error compiling x264" && exit 1; }
make install  || { echo "Error installing x264" && exit 1; }
cd ..

#prepare ffmpeg
git clone git://git.videolan.org/ffmpeg.git
cd ffmpeg
./configure --enable-libx264 --enable-gpl --enable-pthreads --extra-cflags=-I$THIRDPARTYLIBS/x264-install/include --extra-ldflags=-L$THIRDPARTYLIBS/x264-install/lib --prefix=$THIRDPARTYLIBS/ffmpeg-install || { echo "Error configuring ffmpeg" && exit 1; }
#in case x264 is not reqired (do we need the encoding?): ./configure --enable-gpl --enable-pthreads --prefix=$BASEDIR/ffmpeg-install
make -j 2 || { echo "Error cimpiling ffmpeg" && exit 1; }
make install || { echo "Error installing ffmpeg" && exit 1; }
cd ..

#cd .. #3RDPARTY-LIBS

#prepare GRAPES
git clone http://halo.disi.unitn.it/~abeni/PublicGits/GRAPES.git
cd GRAPES
FFDIR=$THIRDPARTYLIBS/ffmpeg make || { echo "Error cimpiling GRAPES" && exit 1; }
cd ../..

#prepare the Streamer
git clone http://halo.disi.unitn.it/~cskiraly/PublicGits/Streamers.git
cd Streamers
GRAPES=$THIRDPARTYLIBS/GRAPES FFMPEG_DIR=$THIRDPARTYLIBS/ffmpeg X264_DIR=$THIRDPARTYLIBS/x264 make clean
GRAPES=$THIRDPARTYLIBS/GRAPES FFMPEG_DIR=$THIRDPARTYLIBS/ffmpeg X264_DIR=$THIRDPARTYLIBS/x264 make || { echo "Error cimpiling the Streamer" && exit 1; }
cd ..

#get test scripts
git clone http://www.disi.unitn.it/~kiraly/SharedGits/Streamers-test.git

#run a test
mkdir test
cd test
wget http://halo.disi.unitn.it/~cskiraly/video/test.ts -N
$BASEDIR/Streamers-test/test.sh -e $BASEDIR/Streamers/streamer-grapes -N 0 -X 0 -v test.ts -o "$THIRDPARTYLIBS/ffmpeg/ffplay -" -O 1 &
PID=$!
sleep 20
kill $PID || { echo "1st Test failed!" && exit 1; }
cd ..

#NAPA-libs
cd $THIRDPARTYLIBS
git clone http://halo.disi.unitn.it/~cskiraly/SharedGits/NAPA-BASELIBS.git
cd NAPA-BASELIBS
./build_all.sh -q
cd ..
cd .. #$THIRDPARTYLIBS

#version with NAPA-libs
cd Streamers
GRAPES=$THIRDPARTYLIBS/GRAPES FFMPEG_DIR=$THIRDPARTYLIBS/ffmpeg X264_DIR=$THIRDPARTYLIBS/x264 STATIC=2 NAPA=$THIRDPARTYLIBS/NAPA-BASELIBS/ LIBEVENT_DIR=$THIRDPARTYLIBS/NAPA-BASELIBS/3RDPARTY-LIBS/libevent ML=1 MONL=1  make clean >/dev/null
GRAPES=$THIRDPARTYLIBS/GRAPES FFMPEG_DIR=$THIRDPARTYLIBS/ffmpeg X264_DIR=$THIRDPARTYLIBS/x264 STATIC=2 NAPA=$THIRDPARTYLIBS/NAPA-BASELIBS/ LIBEVENT_DIR=$THIRDPARTYLIBS/NAPA-BASELIBS/3RDPARTY-LIBS/libevent ML=1 MONL=1  make || { echo "Error cimpiling the ML+MONL version of the Streamer" && exit 1; }
cd ..

#run a test
cd test
$BASEDIR/Streamers-test/test.sh -e $BASEDIR/Streamers/streamer-ml-monl-grapes-static -N 0 -X 0 -v test.ts -o "$THIRDPARTYLIBS/ffmpeg/ffplay -" -O 1 &
PID=$!
sleep 20
kill $PID || { echo "2nd Test failed!" && exit 1; }
cd ..

echo "Your executables are ready"
