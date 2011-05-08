BASEDIR = $(shell pwd)
THIRDPARTYLIBS = $(BASEDIR)/THIRDPARTY-LIBS

.PHONY: $(THIRDPARTYLIBS) update

all: Streamers/streamer-grapes
ml: Streamers/streamer-ml-monl-grapes-static
chunkstream: Streamers/streamer-chunkstream ChunkerPlayer/chunker_player/chunker_player
ml-chunkstream: Streamers/streamer-ml-monl-chunkstream-static ChunkerPlayer/chunker_player/chunker_player

$(THIRDPARTYLIBS):
	$(MAKE) -C $(THIRDPARTYLIBS) || { echo "Error preparing third party libs" && exit 1; }

update:
	git pull
	git submodule update

Streamers/.git:
	git submodule update --init -- $(shell dirname $@)

Streamers/streamer-grapes: Streamers/.git $(THIRDPARTYLIBS)
	GRAPES=$(THIRDPARTYLIBS)/GRAPES FFMPEG_DIR=$(THIRDPARTYLIBS)/ffmpeg X264_DIR=$(THIRDPARTYLIBS)/x264 $(MAKE) -C Streamers  || { echo "Error compiling the Streamer" && exit 1; }

#version with NAPA-libs
Streamers/streamer-ml-monl-grapes-static: Streamers/.git $(THIRDPARTYLIBS)
	GRAPES=$(THIRDPARTYLIBS)/GRAPES FFMPEG_DIR=$(THIRDPARTYLIBS)/ffmpeg X264_DIR=$(THIRDPARTYLIBS)/x264 STATIC=2 NAPA=$(THIRDPARTYLIBS)/NAPA-BASELIBS/ LIBEVENT_DIR=$(THIRDPARTYLIBS)/NAPA-BASELIBS/3RDPARTY-LIBS/libevent ML=1 MONL=1 $(MAKE) -C Streamers || { echo "Error compiling the ML+MONL version of the Streamer" && exit 1; }

Streamers/streamer-chunkstream: Streamers/.git $(THIRDPARTYLIBS)
	IO=chunkstream GRAPES=$(THIRDPARTYLIBS)/GRAPES FFMPEG_DIR=$(THIRDPARTYLIBS)/ffmpeg X264_DIR=$(THIRDPARTYLIBS)/x264 $(MAKE) -C Streamers  || { echo "Error compiling the Streamer" && exit 1; }

Streamers/streamer-ml-monl-chunkstream-static: Streamers/.git $(THIRDPARTYLIBS)
	IO=chunkstream GRAPES=$(THIRDPARTYLIBS)/GRAPES FFMPEG_DIR=$(THIRDPARTYLIBS)/ffmpeg X264_DIR=$(THIRDPARTYLIBS)/x264 STATIC=2 NAPA=$(THIRDPARTYLIBS)/NAPA-BASELIBS/ LIBEVENT_DIR=$(THIRDPARTYLIBS)/NAPA-BASELIBS/3RDPARTY-LIBS/libevent ML=1 MONL=1 $(MAKE) -C Streamers || { echo "Error compiling the ML+MONL version of the Streamer" && exit 1; }

ChunkerPlayer/.git:
	git submodule update --init -- $(shell dirname $@)

ChunkerPlayer/chunker_player/chunker_player: ChunkerPlayer/.git
	cd ChunkerPlayer && ./build_ul.sh

prepare:
	git submodule update --init

clean:
	$(MAKE) -C $(THIRDPARTYLIBS) clean
	$(MAKE) -C Streamers clean