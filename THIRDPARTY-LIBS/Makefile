UNAME := $(shell uname)

THIRDPARTYLIBS = $(shell pwd)
#NAPA-LIBS = NAPA-BASELIBS/monl/libmon.a NAPA-BASELIBS/ml/libml.a
#GRAPES-LIBS = GRAPES/src/libgrapes.a
#LIBS = $(GRAPES-LIBS) $(NAPA-LIBS)

NOGIT := $(shell [ -d ../.git ] || echo 1)
GITREPOCHECK = .git/HEAD

#configure FFMPEG
CONFIG_FFMPEG += --disable-sse #required because of an error in recent ffmpeg version in case of -bf > 0
CONFIG_FFMPEG += --disable-vaapi #there seems to be no static version of vaapi, so it creates problems in distributed binaries
CONFIG_FFMPEG += --enable-gpl
CONFIG_FFMPEG += --disable-doc #for less build dependecies and faster build
ifneq (,$(findstring mingw32,$(HOSTARCH)))
CONFIG_FFMPEG += --arch=i586 --enable-cross-compile --cross-prefix=$(CROSSPREFIX) --target-os=mingw32 --enable-memalign-hack --disable-pthreads
else
ifeq ($(UNAME), Darwin)
CONFIG_FFMPEG += --disable-avfilter # current libav fails to build on OSX Lion
CONFIG_FFMPEG += --disable-vda # seems to create some linking problems in ffmpeg 0.10.2
CONFIG_LIBVORBIS += --build=x86_64 # OSX 10.7.2 needs this
endif

CONFIG_FFMPEG += --enable-pthreads
CONFIG_FFMPEG += --enable-libvorbis
CONFIG_FFMPEG_CFLAGS += -I$(THIRDPARTYLIBS)/libvorbis-install/include
CONFIG_FFMPEG_LDFLAGS += -L$(THIRDPARTYLIBS)/libvorbis-install/lib
CONFIG_FFMPEG_LDLIBS += -lvorbis
CONFIG_FFMPEG_LDLIBS += -lvorbisenc
CONFIG_FFMPEG_CFLAGS += -I$(THIRDPARTYLIBS)/libogg-install/include
CONFIG_FFMPEG_LDFLAGS += -L$(THIRDPARTYLIBS)/libogg-install/lib
CONFIG_FFMPEG_LDLIBS += -logg
endif
CONFIG_FFMPEG += --enable-libx264
CONFIG_FFMPEG_CFLAGS += -I$(THIRDPARTYLIBS)/x264-install/include
CONFIG_FFMPEG_LDFLAGS += -L$(THIRDPARTYLIBS)/x264-install/lib
CONFIG_FFMPEG_LDLIBS += -lx264
CONFIG_FFMPEG += --enable-libmp3lame
CONFIG_FFMPEG_CFLAGS += -I$(THIRDPARTYLIBS)/mp3lame-install/include
CONFIG_FFMPEG_LDFLAGS += -L$(THIRDPARTYLIBS)/mp3lame-install/lib
CONFIG_FFMPEG_LDLIBS += -lmp3lame

CONFIG_FFMPEG += --extra-cflags='$(CONFIG_FFMPEG_CFLAGS)'
CONFIG_FFMPEG += --extra-ldflags='$(CONFIG_FFMPEG_LDFLAGS)'

ifneq (,$(findstring mingw32,$(HOSTARCH)))
FLAGS_GRAPES += ARCH=win32
ALTO_OPTION = ALTO=0
CONFIG_X264 += --host=$(HOSTARCH)
CONFIG_MP3LAME += --host=$(HOSTARCH)
endif

WGET_OR_CURL = $(shell which wget || echo "curl -O -L")

.PHONY: GRAPES-build NAPA-build all

all: GRAPES-build NAPA-build

ifndef NOGIT
x264/$(GITREPOCHECK) ffmpeg/$(GITREPOCHECK) GRAPES/$(GITREPOCHECK) NAPA-BASELIBS/$(GITREPOCHECK):
	cd .. && git submodule init $(THIRDPARTYLIBS)/$(@:/$(GITREPOCHECK)=)
	cd .. && git submodule update $(THIRDPARTYLIBS)/$(@:/$(GITREPOCHECK)=)

x264/config.mak: x264/$(GITREPOCHECK)

ffmpeg/config.mak: ffmpeg/$(GITREPOCHECK)

GRAPES-build: GRAPES/$(GITREPOCHECK)

NAPA-build: NAPA-BASELIBS/$(GITREPOCHECK)
endif

x264/config.mak:
	cd x264 && ./configure --disable-lavf --prefix=$(THIRDPARTYLIBS)/x264-install/ --libdir=$(THIRDPARTYLIBS)/x264-install/lib $(CONFIG_X264) || { echo "Error configuring x264" && exit 1; }

x264-install: x264/config.mak
	$(MAKE) -C x264 || { echo "Error compiling x264" && exit 1; }
	$(MAKE) -C x264 install-lib-static  || { echo "Error installing x264" && exit 1; }
	touch x264-install

libogg:
	$(WGET_OR_CURL) http://downloads.xiph.org/releases/ogg/libogg-1.2.2.tar.gz && tar xzf libogg-1.2.2.tar.gz && mv libogg-1.2.2 libogg && rm libogg-1.2.2.tar.gz

libogg-install: libogg
	cd libogg && ./configure --disable-oggtest --disable-shared --prefix=$(THIRDPARTYLIBS)/libogg-install/ --libdir=$(THIRDPARTYLIBS)/libogg-install/lib && make && make install

libvorbis:
	$(WGET_OR_CURL) http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.2.tar.gz && tar xzf libvorbis-1.3.2.tar.gz && mv libvorbis-1.3.2 libvorbis && rm libvorbis-1.3.2.tar.gz

libvorbis-install: libvorbis libogg-install
	cd libvorbis && ./configure --disable-oggtest --disable-shared --prefix=$(THIRDPARTYLIBS)/libvorbis-install/ --libdir=$(THIRDPARTYLIBS)/libvorbis-install/lib --with-ogg=$(THIRDPARTYLIBS)/libogg-install/ $(CONFIG_LIBVORBIS) && make && make install

mp3lame: VERSION_LAME_DIR = 3.99
mp3lame: VERSION_LAME = 3.99.5
mp3lame:
	$(WGET_OR_CURL) http://sourceforge.net/projects/lame/files/lame/$(VERSION_LAME_DIR)/lame-$(VERSION_LAME).tar.gz && tar xzf lame-$(VERSION_LAME).tar.gz && rm -f lame-$(VERSION_LAME).tar.gz && mv lame-$(VERSION_LAME) mp3lame;

mp3lame-install: mp3lame
	cd mp3lame && ./configure --disable-gtktest --disable-frontend --disable-shared --prefix=$(THIRDPARTYLIBS)/mp3lame-install/ --libdir=$(THIRDPARTYLIBS)/mp3lame-install/lib $(CONFIG_MP3LAME) && make && make install

ifeq (,$(findstring mingw32,$(HOSTARCH)))
ffmpeg/config.mak: libvorbis-install libogg-install
endif
ffmpeg/config.mak: x264-install
ffmpeg/config.mak: mp3lame-install
ffmpeg/config.mak:
	cd ffmpeg && ./configure --prefix=$(THIRDPARTYLIBS)/ffmpeg-install --libdir=$(THIRDPARTYLIBS)/ffmpeg-install/lib $(CONFIG_FFMPEG) || { echo "Error configuring ffmpeg" && exit 1; }
	#in case x264 is not reqired (do we need the encoding?): ./configure --enable-gpl --enable-pthreads --prefix=$BASEDIR/ffmpeg-install --libdir=$BASEDIR/ffmpeg-install/lib
	echo $(CONFIG_FFMPEG_CFLAGS) >ffmpeg.cflags
	echo $(CONFIG_FFMPEG_LDFLAGS) >ffmpeg.ldflags
	echo $(CONFIG_FFMPEG_LDLIBS) >ffmpeg.ldlibs

ffmpeg-install: ffmpeg/config.mak
	$(MAKE) -C ffmpeg || { echo "Error compiling ffmpeg" && exit 1; }
	$(MAKE) -C ffmpeg install || { echo "Error installing ffmpeg" && exit 1; }
	touch ffmpeg-install

GRAPES-build: ffmpeg-install
	$(FLAGS_GRAPES) FFDIR=$(THIRDPARTYLIBS)/ffmpeg $(MAKE) -C GRAPES || { echo "Error compiling GRAPES" && exit 1; }

NAPA-build:
	cd NAPA-BASELIBS && $(ALTO_OPTION) ./build_all.sh -q

clean:
	$(MAKE) -C GRAPES clean
	$(MAKE) -C NAPA-BASELIBS clean

distclean:
	[ ! -d GRAPES ] || $(MAKE) -C GRAPES clean
	[ ! -d NAPA-BASELIBS ] || $(MAKE) -C NAPA-BASELIBS clean
	rm -rf libx264-install
	[ ! -d x264 ] || $(MAKE) -C x264 distclean || true
	rm -rf ffmpeg-install
	rm -rf ffmpeg.{ldflags,cflags,ldlibs}
	[ ! -d ffmpeg ] || $(MAKE) -C ffmpeg distclean || true
	rm -rf mp3lame-install
	[ ! -d mp3lame ] || $(MAKE) -C mp3lame distclean || true
	rm -rf libvorbis-install
	[ ! -d libvorbis ] || $(MAKE) -C libvorbis distclean || true
	rm -rf libogg-install
	[ ! -d libogg ] || $(MAKE) -C libogg distclean || true
