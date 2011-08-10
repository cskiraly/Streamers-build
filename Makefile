BASEDIR := $(shell pwd)
THIRDPARTYLIBS := $(BASEDIR)/THIRDPARTY-LIBS

NOGIT := $(shell [ -d .git ] || echo 1)
REV := $(shell ( [ -d .git ] && git describe --tags --always --dirty 2>/dev/null ) || ( [ -d .git ] && git describe --tags --always 2>/dev/null ) || ( [ -d .git ] && git describe --tags ) || ( [ -d .svn ] && svnversion ) || echo exported)
DIR := PeerStreamer-$(subst PeerStreamer-,,$(REV))

UNAME := $(shell uname)
ifeq ($(UNAME), Linux)
  # do something Linux-y
  STATIC ?= 2
  XSTATIC = -static
endif
ifeq ($(UNAME), Darwin)
  # do something OSX-y
  STATIC = 0
  XSTATIC =
  MAC_OS = 1
endif
STATIC ?= 2
XSTATIC ?= -static

FLAGS_CHUNKER += LOCAL_FFMPEG=$(THIRDPARTYLIBS)/ffmpeg-install
ifneq ($(HOSTARCH),mingw32)
FLAGS_CHUNKER += LOCAL_X264=$(THIRDPARTYLIBS)/x264-install 
FLAGS_CHUNKER += LOCAL_LIBOGG=$(THIRDPARTYLIBS)/libogg-install
FLAGS_CHUNKER += LOCAL_LIBVORBIS=$(THIRDPARTYLIBS)/libvorbis-install
FLAGS_CHUNKER += LOCAL_MP3LAME=$(THIRDPARTYLIBS)/mp3lame-install
else
EXE =.exe
endif

.PHONY: $(THIRDPARTYLIBS) update clean ml-chunkstream

all: pack

simple: Streamers/streamer-grapes$(EXE)
ml: Streamers/streamer-ml-monl-grapes$(XSTATIC)$(EXE)
chunkstream: Streamers/streamer-chunkstream$(EXE) ChunkerPlayer/chunker_player/chunker_player$(EXE)
ml-chunkstream: Streamers/streamer-ml-monl-chunkstream$(XSTATIC)$(EXE) ChunkerPlayer/chunker_player/chunker_player$(EXE)

$(THIRDPARTYLIBS):
	$(MAKE) -C $(THIRDPARTYLIBS) || { echo "Error preparing third party libs" && exit 1; }

ifndef NOGIT
update:
	git pull
	git submodule update

forceupdate:
	git stash
	git pull
	git submodule foreach git stash
	git submodule update

Streamers/.git:
	git submodule init -- $(shell dirname $@)
	git submodule update -- $(shell dirname $@)

Streamers/streamer-grapes: Streamers/.git
Streamers/streamer-ml-monl-grapes$(XSTATIC)$(EXE): Streamers/.git
Streamers/streamer-chunkstream$(EXE): Streamers/.git
Streamers/streamer-ml-monl-chunkstream$(XSTATIC)$(EXE): Streamers/.git

ChunkerPlayer/.git:
	git submodule init -- $(shell dirname $@)
	git submodule update -- $(shell dirname $@)

ChunkerPlayer/chunker_player/chunker_player$(EXE): ChunkerPlayer/.git
endif

Streamers/streamer-grapes: $(THIRDPARTYLIBS)
	LDFLAGS=`cat $(THIRDPARTYLIBS)/ffmpeg.ldflags` LDLIBS=`cat $(THIRDPARTYLIBS)ffmpeg.ldlibs` \
	GRAPES=$(THIRDPARTYLIBS)/GRAPES FFMPEG_DIR=$(THIRDPARTYLIBS)/ffmpeg X264_DIR=$(THIRDPARTYLIBS)/x264 $(MAKE) -C Streamers  || { echo "Error compiling the Streamer" && exit 1; }

#version with NAPA-libs
Streamers/streamer-ml-monl-grapes$(XSTATIC)$(EXE): $(THIRDPARTYLIBS)
	LDFLAGS=`cat $(THIRDPARTYLIBS)/ffmpeg.ldflags` LDLIBS=`cat $(THIRDPARTYLIBS)/ffmpeg.ldlibs` \
	GRAPES=$(THIRDPARTYLIBS)/GRAPES FFMPEG_DIR=$(THIRDPARTYLIBS)/ffmpeg X264_DIR=$(THIRDPARTYLIBS)/x264 STATIC=$(STATIC) NAPA=$(THIRDPARTYLIBS)/NAPA-BASELIBS/ LIBEVENT_DIR=$(THIRDPARTYLIBS)/NAPA-BASELIBS/3RDPARTY-LIBS/libevent ML=1 MONL=1 $(MAKE) -C Streamers || { echo "Error compiling the ML+MONL version of the Streamer" && exit 1; }

Streamers/streamer-chunkstream$(EXE): $(THIRDPARTYLIBS)
	IO=chunkstream GRAPES=$(THIRDPARTYLIBS)/GRAPES FFMPEG_DIR=$(THIRDPARTYLIBS)/ffmpeg X264_DIR=$(THIRDPARTYLIBS)/x264 $(MAKE) -C Streamers  || { echo "Error compiling the Streamer" && exit 1; }

Streamers/streamer-ml-monl-chunkstream$(XSTATIC)$(EXE): $(THIRDPARTYLIBS)
	IO=chunkstream GRAPES=$(THIRDPARTYLIBS)/GRAPES FFMPEG_DIR=$(THIRDPARTYLIBS)/ffmpeg X264_DIR=$(THIRDPARTYLIBS)/x264 STATIC=$(STATIC) NAPA=$(THIRDPARTYLIBS)/NAPA-BASELIBS/ LIBEVENT_DIR=$(THIRDPARTYLIBS)/NAPA-BASELIBS/3RDPARTY-LIBS/libevent ML=1 MONL=1 $(MAKE) -C Streamers || { echo "Error compiling the ML+MONL version of the Streamer" && exit 1; }

ChunkerPlayer/chunker_player/chunker_player$(EXE): $(THIRDPARTYLIBS)
	cd ChunkerPlayer && $(FLAGS_CHUNKER) ./build_ul.sh

prepare:
ifndef NOGIT
	git submodule init
	git submodule update
else
	git clone http://halo.disi.unitn.it/~cskiraly/PublicGits/ffmpeg.git THIRDPARTY-LIBS/ffmpeg
	cd THIRDPARTY-LIBS/ffmpeg && git checkout -b streamer 210091b0e31832342322b8461bd053a0314e63bc
	git clone git://git.videolan.org/x264.git THIRDPARTY-LIBS/x264
	cd THIRDPARTY-LIBS/x264 && git checkout -b streamer 08d04a4d30b452faed3b763528611737d994b30b
endif

clean:
	$(MAKE) -C $(THIRDPARTYLIBS) clean
	$(MAKE) -C Streamers clean
	$(MAKE) -C ChunkerPlayer/chunker_player clean
	$(MAKE) -C ChunkerPlayer/chunk_transcoding clean
	$(MAKE) -C ChunkerPlayer/chunker_streamer clean

distclean:
	$(MAKE) -C $(THIRDPARTYLIBS) distclean
	$(MAKE) -C Streamers clean
	$(MAKE) -C ChunkerPlayer/chunker_player clean
	$(MAKE) -C ChunkerPlayer/chunk_transcoding clean
	$(MAKE) -C ChunkerPlayer/chunker_streamer clean

pack:  $(DIR)-stripped.tgz

$(DIR)-stripped.tgz:  Streamers/streamer-ml-monl-chunkstream$(XSTATIC)$(EXE) ChunkerPlayer/chunker_player/chunker_player$(EXE)
	rm -rf $(DIR) $(DIR).tgz $(DIR)-stripped.tgz
	mkdir $(DIR)
	cp Streamers/streamer-ml-monl-chunkstream$(XSTATIC)$(EXE) $(DIR)
	cp ChunkerPlayer/chunker_player/chunker_player$(EXE) $(DIR)
	mkdir $(DIR)/icons
	cp ChunkerPlayer/chunker_player/icons/* $(DIR)/icons
	cp ChunkerPlayer/chunker_player/stats_font.ttf ChunkerPlayer/chunker_player/mainfont.ttf ChunkerPlayer/chunker_player/napalogo_small.bmp $(DIR)
	echo streamer-ml-monl-chunkstream$(XSTATIC)$(EXE) > $(DIR)/peer_exec_name.conf
ifneq ($(HOSTARCH),mingw32)
	ln -s streamer-ml-monl-chunkstream$(XSTATIC)$(EXE) $(DIR)/streamer
	cp ChunkerPlayer/chunker_streamer/chunker_streamer ChunkerPlayer/chunker_streamer/chunker.conf $(DIR)
	cp scripts/source.sh $(DIR)
	cp scripts/player.sh $(DIR)
endif
	cp channels.conf $(DIR)
	cp README $(DIR)
ifneq ($(HOSTARCH),mingw32)
	tar czf $(DIR).tgz $(DIR)
	cd $(DIR) && strip chunker_streamer$(EXE)
endif
	cd $(DIR) && strip streamer-ml-monl-chunkstream$(XSTATIC)$(EXE) chunker_player$(EXE)
ifneq ($(HOSTARCH),mingw32)
	tar czf $(DIR)-stripped.tgz $(DIR)
else
	zip -r $(DIR).zip $(DIR)
endif
