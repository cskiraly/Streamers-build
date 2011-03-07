#!/bin/bash

mkdir PeerStreamer
cd PeerStreamer

#prepare x264 (optional)
git clone git://git.videolan.org/x264.git
cd x264
./configure --prefix=`pwd`/../x264-install/
make -j 2
make install
cd ..

#prepare ffmpeg
git clone git://git.videolan.org/ffmpeg.git
cd ffmpeg
./configure --enable-libx264 --enable-gpl --enable-pthreads --extra-cflags=-I`pwd`/../x264-install/include --extra-ldflags=-L`pwd`/../x264-install/lib --prefix=`pwd`/../ffmpeg-install
#in case x264 is not reqired (do we need the encoding?): ./configure --enable-gpl --enable-pthreads --prefix=`pwd`/../ffmpeg-install
make -j 2
make install
cd ..

#prepare GRAPES
git clone http://halo.disi.unitn.it/~abeni/PublicGits/GRAPES.git
cd GRAPES
FFDIR=`pwd`/../ffmpeg make
cd ..

#prepare the Streamer
git clone http://halo.disi.unitn.it/~cskiraly/PublicGits/Streamers.git
cd Streamers
GRAPES=../GRAPES FFMPEG_DIR=../ffmpeg X264_DIR=../x264 make
cd ..

#get test scripts
git clone http://www.disi.unitn.it/~kiraly/SharedGits/Streamers-test.git

#run a test
mkdir test
cd test
wget http://halo.disi.unitn.it/~cskiraly/video/test.ts
../Streamers-test/test.sh -e ../Streamers/streamer-grapes -N 0 -X 0 -v test.ts -o "../ffmpeg/ffplay -" -O 1