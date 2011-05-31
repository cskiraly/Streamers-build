THIRDPARTYLIBS = $(shell pwd)
#NAPA-LIBS = NAPA-BASELIBS/monl/libmon.a NAPA-BASELIBS/ml/libml.a
#GRAPES-LIBS = GRAPES/src/libgrapes.a
#LIBS = $(GRAPES-LIBS) $(NAPA-LIBS)

#configure FFMPEG
CONFIG_FFMPEG += --disable-sse #required because of an error in recent ffmpeg version in case of -bf > 0
CONFIG_FFMPEG += --enable-libx264
CONFIG_FFMPEG_CFLAGS += -I$(THIRDPARTYLIBS)/x264-install/include
CONFIG_FFMPEG_LDFLAGS += -L$(THIRDPARTYLIBS)/x264-install/lib
CONFIG_FFMPEG += --enable-libvorbis
CONFIG_FFMPEG_CFLAGS += -I$(THIRDPARTYLIBS)/libvorbis-install/include
CONFIG_FFMPEG_LDFLAGS += -L$(THIRDPARTYLIBS)/libvorbis-install/lib
CONFIG_FFMPEG_CFLAGS += -I$(THIRDPARTYLIBS)/libogg-install/include
CONFIG_FFMPEG_LDFLAGS += -L$(THIRDPARTYLIBS)/libogg-install/lib
CONFIG_FFMPEG += --enable-libmp3lame
CONFIG_FFMPEG_CFLAGS += -I$(THIRDPARTYLIBS)/mp3lame-install/include
CONFIG_FFMPEG_LDFLAGS += -L$(THIRDPARTYLIBS)/mp3lame-install/lib
CONFIG_FFMPEG += --enable-gpl
CONFIG_FFMPEG += --extra-cflags='$(CONFIG_FFMPEG_CFLAGS)'
CONFIG_FFMPEG += --extra-ldflags='$(CONFIG_FFMPEG_LDFLAGS)'
ifeq ($(HOSTARCH),mingw32)
CONFIG_FFMPEG += --arch=i586 --enable-cross-compile --cross-prefix=i586-mingw32msvc- --target-os=mingw32 --enable-memalign-hack --disable-pthreads
else
CONFIG_FFMPEG += --enable-pthreads
endif

.PHONY: GRAPES-build NAPA-build all

all: GRAPES-build NAPA-build

x264/.git:
	cd .. && git submodule update --init $(shell dirname $(THIRDPARTYLIBS)/$@)

x264/config.mak: x264/.git
	cd x264 && ./configure --disable-lavf --prefix=$(THIRDPARTYLIBS)/x264-install/ || { echo "Error configuring x264" && exit 1; }

x264-install: x264/config.mak
	$(MAKE) -C x264 || { echo "Error compiling x264" && exit 1; }
	$(MAKE) -C x264 install  || { echo "Error installing x264" && exit 1; }
	touch x264-install

libogg:
	wget http://downloads.xiph.org/releases/ogg/libogg-1.2.2.tar.gz && tar xzf libogg-1.2.2.tar.gz && mv libogg-1.2.2 libogg && rm libogg-1.2.2.tar.gz

libogg-install: libogg
	cd libogg && ./configure --disable-oggtest --disable-shared --prefix=$(THIRDPARTYLIBS)/libogg-install/ && make && make install

libvorbis:
	wget http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.2.tar.gz && tar xzf libvorbis-1.3.2.tar.gz && mv libvorbis-1.3.2 libvorbis && rm libvorbis-1.3.2.tar.gz

libvorbis-install: libvorbis libogg-install
	cd libvorbis && ./configure --disable-oggtest --disable-shared --prefix=$(THIRDPARTYLIBS)/libvorbis-install/ --with-ogg=$(THIRDPARTYLIBS)/libogg-install/ && make && make install

mp3lame:
	wget http://sourceforge.net/projects/lame/files/lame/3.98.4/lame-3.98.4.tar.gz && tar xzf lame-3.98.4.tar.gz && rm -f lame-3.98.4.tar.gz && mv lame-3.98.4 mp3lame;

mp3lame-install: mp3lame
	cd mp3lame && ./configure --disable-gtktest --disable-frontend --disable-shared --prefix=$(THIRDPARTYLIBS)/mp3lame-install/ ${HOSTARCH:+--host=$HOSTARCH} && make && make install

ffmpeg/.git:
	cd .. && git submodule update --init $(shell dirname $(THIRDPARTYLIBS)/$@)

ffmpeg/config.mak: ffmpeg/.git x264-install libvorbis-install libogg-install mp3lame-install
	cd ffmpeg && ./configure --prefix=$(THIRDPARTYLIBS)/ffmpeg-install $(CONFIG_FFMPEG) || { echo "Error configuring ffmpeg" && exit 1; }
	#in case x264 is not reqired (do we need the encoding?): ./configure --enable-gpl --enable-pthreads --prefix=$BASEDIR/ffmpeg-install

ffmpeg-install: ffmpeg/config.mak
	$(MAKE) -C ffmpeg || { echo "Error compiling ffmpeg" && exit 1; }
	$(MAKE) -C ffmpeg install || { echo "Error installing ffmpeg" && exit 1; }
	touch ffmpeg-install

GRAPES/.git: 
	cd .. && git submodule update --init $(shell dirname $(THIRDPARTYLIBS)/$@)

GRAPES-build: GRAPES/.git ffmpeg-install
	FFDIR=$(THIRDPARTYLIBS)/ffmpeg $(MAKE) -C GRAPES || { echo "Error compiling GRAPES" && exit 1; }

NAPA-BASELIBS/.git:
	cd .. && git submodule update --init $(shell dirname $(THIRDPARTYLIBS)/$@)

NAPA-build: NAPA-BASELIBS/.git
	cd NAPA-BASELIBS && ./build_all.sh -q

clean:
	$(MAKE) -C GRAPES clean
