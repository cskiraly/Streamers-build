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
  LINUX_OS = 1
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

.PHONY: $(THIRDPARTYLIBS) update clean ml-chunkstream $(DIR)

all: $(DIR)

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

#.PHONY: Streamers/streamer-grapes Streamers/streamer-ml-monl-grapes$(XSTATIC)$(EXE) Streamers/streamer-chunkstream$(EXE) Streamers/streamer-ml-monl-chunkstream$(XSTATIC)$(EXE)
Streamers/streamer-grapes: $(THIRDPARTYLIBS)
	cd Streamers && ./configure \
	--with-ldflags="`cat $(THIRDPARTYLIBS)/ffmpeg.ldflags`" --with-ldlibs="`cat $(THIRDPARTYLIBS)/ffmpeg.ldlibs`" \
	--with-grapes=$(THIRDPARTYLIBS)/GRAPES --with-ffmpeg=$(THIRDPARTYLIBS)/ffmpeg --with-x264=$(THIRDPARTYLIBS)/x264 \
	--with-static=$(STATIC)
	$(MAKE) -C Streamers

#version with NAPA-libs
Streamers/streamer-ml-monl-grapes$(XSTATIC)$(EXE): $(THIRDPARTYLIBS)
	cd Streamers && ./configure \
	--with-ldflags="`cat $(THIRDPARTYLIBS)/ffmpeg.ldflags`" --with-ldlibs="`cat $(THIRDPARTYLIBS)/ffmpeg.ldlibs`" \
	--with-grapes=$(THIRDPARTYLIBS)/GRAPES --with-ffmpeg=$(THIRDPARTYLIBS)/ffmpeg --with-x264=$(THIRDPARTYLIBS)/x264 \
	--with-napa=$(THIRDPARTYLIBS)/NAPA-BASELIBS/ --with-libevent=$(THIRDPARTYLIBS)/NAPA-BASELIBS/3RDPARTY-LIBS/libevent \
	--with-ml --with-monl \
	--with-static=$(STATIC)
	$(MAKE) -C Streamers

Streamers/streamer-chunkstream$(EXE): $(THIRDPARTYLIBS)
	cd Streamers && ./configure \
	--with-io=chunkstream \
	--with-grapes=$(THIRDPARTYLIBS)/GRAPES --with-ffmpeg=$(THIRDPARTYLIBS)/ffmpeg --with-x264=$(THIRDPARTYLIBS)/x264 \
	--with-static=$(STATIC)
	$(MAKE) -C Streamers

Streamers/streamer-ml-monl-chunkstream$(XSTATIC)$(EXE): $(THIRDPARTYLIBS)
	cd Streamers && ./configure \
	--with-io=chunkstream \
	--with-grapes=$(THIRDPARTYLIBS)/GRAPES --with-ffmpeg=$(THIRDPARTYLIBS)/ffmpeg --with-x264=$(THIRDPARTYLIBS)/x264 \
	--with-napa=$(THIRDPARTYLIBS)/NAPA-BASELIBS/ --with-libevent=$(THIRDPARTYLIBS)/NAPA-BASELIBS/3RDPARTY-LIBS/libevent \
	--with-ml --with-monl \
	--with-static=$(STATIC)
	$(MAKE) -C Streamers

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
ifdef MAC_OS
	rm -rf *.app *.dmg
endif

distclean:
	$(MAKE) -C $(THIRDPARTYLIBS) distclean
	$(MAKE) -C Streamers clean
	$(MAKE) -C ChunkerPlayer/chunker_player clean
	$(MAKE) -C ChunkerPlayer/chunk_transcoding clean
	$(MAKE) -C ChunkerPlayer/chunker_streamer clean

pack:  $(DIR)-stripped.tgz

$(DIR):  Streamers/streamer-ml-monl-chunkstream$(XSTATIC)$(EXE) ChunkerPlayer/chunker_player/chunker_player$(EXE)
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

$(DIR).tgz: $(DIR)
	tar czf $(DIR).tgz $(DIR)

$(DIR)-stripped.tgz: $(DIR).tgz
ifneq ($(HOSTARCH),mingw32)
	cd $(DIR) && strip chunker_streamer$(EXE)
endif
	cd $(DIR) && strip streamer-ml-monl-chunkstream$(XSTATIC)$(EXE) chunker_player$(EXE)
ifneq ($(HOSTARCH),mingw32)
	tar czf $(DIR)-stripped.tgz $(DIR)
else
	zip -r $(DIR).zip $(DIR)
endif

install: $(DIR)
	mkdir -p /opt/peerstreamer
	cp -r $(DIR)/* /opt/peerstreamer
	ln -f -s /opt/peerstreamer/player.sh /usr/local/bin/peerstreamer
	cp -r Installer/Lin/usr/share /usr

uninstall:
	rm -rf /opt/peerstreamer
	rm -f /usr/local/bin/peerstreamer
	rm -rf /usr/share/applications/peerstreamer.desktop
	rm -rf /usr/share/menu/peerstreamer
	rm -rf /usr/share/pixmaps/peerstreamer.xpm

ifdef LINUX_OS
debian:
	fakeroot checkinstall -D --fstrans --install=no --pkgname="peerstreamer" --pkgversion="$(subst PeerStreamer-,,$(REV))" --pkglicense="GPLv3" --maintainer='"Csaba Kiraly <info@peerstreamer.org>"' --nodoc --strip=yes --showinstall=no --default --backup=no

debian-amd64:
	fakeroot checkinstall --requires=ia32-libs -D --fstrans --install=no --pkgname="peerstreamer" --pkgversion="$(subst PeerStreamer-,,$(REV))" --pkgarch=amd64 --pkglicense="GPLv3" --maintainer='"Csaba Kiraly <info@peerstreamer.org>"' --nodoc --strip=yes --showinstall=no --default --backup=no

rpm: TMPDIR:=$(shell mktemp -d)
rpm: debian
	cp $(subst PeerStreamer-,peerstreamer_,$(DIR))-1_i386.deb $(TMPDIR)
	cd $(TMPDIR) && alien -r $(subst PeerStreamer-,peerstreamer_,$(DIR))-1_i386.deb -v --fixperms -k
	mv $(TMPDIR)/$(subst PeerStreamer_,peerstreamer-,$(subst -,_,$(DIR)))-1.i386.rpm .
	rm -rf $(TMPDIR)
endif

ifeq ($(HOSTARCH),mingw32)
installer-win: $(DIR)
	ln -s $(DIR) PeerStreamer
	makensis -DPRODUCT_VERSION="$(subst PeerStreamer-,,$(REV))" Installer/Win/04_peerstreamer.nsi 
	rm PeerStreamer
	mv Installer/Win/PeerStreamerInstaller*.exe .
endif

ifdef MAC_OS
installer-OSX: $(DIR)
	cd Installer/OSX/ && tar zfx OSX_template.tgz && ./makeApp.sh $(DIR) && rm -rf napa-template.app && make VERSION=$(REV) && mv $(REV).dmg ../../
endif
