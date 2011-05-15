BASEDIR = $(shell pwd)
THIRDPARTYLIBS = $(BASEDIR)/THIRDPARTY-LIBS

.PHONY: $(THIRDPARTYLIBS) update

all: pack

simple: Streamers/streamer-grapes
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

ChunkerPlayer/chunker_player/chunker_player: ChunkerPlayer/.git $(THIRDPARTYLIBS)
	cd ChunkerPlayer && LOCAL_X264=$(THIRDPARTYLIBS)/x264-install LOCAL_FFMPEG=$(THIRDPARTYLIBS)/ffmpeg-install LOCAL_LIBOGG=$(THIRDPARTYLIBS)/libogg-install LOCAL_LIBVORBIS=$(THIRDPARTYLIBS)/libvorbis-install LOCAL_MP3LAME=$(THIRDPARTYLIBS)/mp3lame-install ./build_ul.sh

prepare:
	git submodule update --init

clean:
	$(MAKE) -C $(THIRDPARTYLIBS) clean
	$(MAKE) -C Streamers clean

pack: DIR = PeerStreamer-$(shell git describe --always --dirty)
pack: ml-chunkstream
	rm -rf $(DIR) $(DIR).tgz $(DIR)-stripped.tgz
	mkdir $(DIR)
	cp Streamers/streamer-ml-monl-chunkstream-static $(DIR)
	cp -r ChunkerPlayer/chunker_player/chunker_player ChunkerPlayer/chunker_player/icons ChunkerPlayer/chunker_player/channels.conf $(DIR)
	cp ChunkerPlayer/chunker_player/stats_font.ttf ChunkerPlayer/chunker_player/mainfont.ttf ChunkerPlayer/chunker_player/napalogo_small.bmp $(DIR)
	cp ChunkerPlayer/chunker_streamer/chunker_streamer ChunkerPlayer/chunker_streamer/chunker.conf $(DIR)
	echo streamer-ml-monl-chunkstream-static > $(DIR)/peer_exec_name.conf
	ln -s streamer-ml-monl-chunkstream-static $(DIR)/streamer
	cp scripts/* $(DIR)
	cp README $(DIR)
	tar czf $(DIR).tgz $(DIR)
	cd $(DIR) && strip streamer-ml-monl-chunkstream-static chunker_player chunker_streamer
	tar czf $(DIR)-stripped.tgz $(DIR)