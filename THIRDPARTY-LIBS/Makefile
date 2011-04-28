THIRDPARTYLIBS = $(shell pwd)
#NAPA-LIBS = NAPA-BASELIBS/monl/libmon.a NAPA-BASELIBS/ml/libml.a
#GRAPES-LIBS = GRAPES/src/libgrapes.a
#LIBS = $(GRAPES-LIBS) $(NAPA-LIBS)

.PHONY: GRAPES-build NAPA-build x264-build ffmpeg-build

all: GRAPES-build NAPA-build

x264:
	git clone git://git.videolan.org/x264.git
	cd x264 && ./configure --prefix=$(THIRDPARTYLIBS)/x264-install/ || { echo "Error configuring x264" && exit 1; }

x264-build: x264
	$(MAKE) -C x264 || { echo "Error compiling x264" && exit 1; }

x264-install: x264-build
	$(MAKE) -C x264 install  || { echo "Error installing x264" && exit 1; }

ffmpeg: x264-install
	git clone git://git.videolan.org/ffmpeg.git
	cd ffmpeg && git checkout 2cae9809e2d59c7336fc2cccb97b82c7f764868a
	cd ffmpeg && ./configure --enable-libx264 --enable-gpl --enable-pthreads --extra-cflags=-I$(THIRDPARTYLIBS)/x264-install/include --extra-ldflags=-L$(THIRDPARTYLIBS)/x264-install/lib --prefix=$(THIRDPARTYLIBS)/ffmpeg-install || { echo "Error configuring ffmpeg" && exit 1; }
	#in case x264 is not reqired (do we need the encoding?): ./configure --enable-gpl --enable-pthreads --prefix=$BASEDIR/ffmpeg-install

ffmpeg-build: ffmpeg
	$(MAKE) -C ffmpeg || { echo "Error compiling ffmpeg" && exit 1; }

ffmpeg-install: ffmpeg-build
	$(MAKE) -C ffmpeg install || { echo "Error installing ffmpeg" && exit 1; }

GRAPES: ffmpeg-install
	git clone http://halo.disi.unitn.it/~cskiraly/PublicGits/GRAPES.git

GRAPES-build: GRAPES
	FFDIR=$(THIRDPARTYLIBS)/ffmpeg $(MAKE) -C GRAPES || { echo "Error compiling GRAPES" && exit 1; }

NAPA-BASELIBS:
	git clone http://halo.disi.unitn.it/~cskiraly/SharedGits/NAPA-BASELIBS.git

NAPA-build: NAPA-BASELIBS
	cd NAPA-BASELIBS && ./build_all.sh -q

clean:
	TODO