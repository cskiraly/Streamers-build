THIRDPARTYLIBS = $(shell pwd)
#NAPA-LIBS = NAPA-BASELIBS/monl/libmon.a NAPA-BASELIBS/ml/libml.a
#GRAPES-LIBS = GRAPES/src/libgrapes.a
#LIBS = $(GRAPES-LIBS) $(NAPA-LIBS)

.PHONY: GRAPES-build NAPA-build x264-build ffmpeg-build

all: GRAPES-build NAPA-build

x264/.git:
	cd .. && git submodule update --init $(shell dirname $(THIRDPARTYLIBS)/$@)
	cd x264 && ./configure --prefix=$(THIRDPARTYLIBS)/x264-install/ || { echo "Error configuring x264" && exit 1; }

x264-build: x264/.git
	$(MAKE) -C x264 || { echo "Error compiling x264" && exit 1; }

x264-install: x264-build
	$(MAKE) -C x264 install  || { echo "Error installing x264" && exit 1; }

ffmpeg/.git: x264-install
	cd .. && git submodule update --init $(shell dirname $(THIRDPARTYLIBS)/$@)
	cd ffmpeg && ./configure --enable-libx264 --enable-gpl --enable-pthreads --extra-cflags=-I$(THIRDPARTYLIBS)/x264-install/include --extra-ldflags=-L$(THIRDPARTYLIBS)/x264-install/lib --prefix=$(THIRDPARTYLIBS)/ffmpeg-install || { echo "Error configuring ffmpeg" && exit 1; }
	#in case x264 is not reqired (do we need the encoding?): ./configure --enable-gpl --enable-pthreads --prefix=$BASEDIR/ffmpeg-install

ffmpeg-build: ffmpeg/.git
	$(MAKE) -C ffmpeg || { echo "Error compiling ffmpeg" && exit 1; }

ffmpeg-install: ffmpeg-build
	$(MAKE) -C ffmpeg install || { echo "Error installing ffmpeg" && exit 1; }

GRAPES/.git: ffmpeg-install
	cd .. && git submodule update --init $(shell dirname $(THIRDPARTYLIBS)/$@)

GRAPES-build: GRAPES/.git
	FFDIR=$(THIRDPARTYLIBS)/ffmpeg $(MAKE) -C GRAPES || { echo "Error compiling GRAPES" && exit 1; }

NAPA-BASELIBS/.git:
	cd .. && git submodule update --init $(shell dirname $(THIRDPARTYLIBS)/$@)

NAPA-build: NAPA-BASELIBS/.git
	cd NAPA-BASELIBS && ./build_all.sh -q

clean:
	$(MAKE) -C GRAPES clean
