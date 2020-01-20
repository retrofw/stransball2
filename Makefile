CHAINPREFIX := /opt/mipsel-linux-uclibc
CROSS_COMPILE := $(CHAINPREFIX)/usr/bin/mipsel-linux-

CXX := $(CROSS_COMPILE)g++
STRIP := $(CROSS_COMPILE)strip

SYSROOT := $(shell $(CC) --print-sysroot)
SDL_CFLAGS := $(shell $(SYSROOT)/usr/bin/sdl-config --cflags)
SDL_LIBS := $(shell $(SYSROOT)/usr/bin/sdl-config --libs)

TARGET	:= stransball2/stransball2.dge

OBJS	:= \
	src/auxiliar.o            src/configuration.o         src/encoder.o \
	src/enemies.o             src/fonts.o       	      src/game.o \
	src/main.o                src/maps.o                  src/replays.o \
	src/state_changepack.o    src/state_chooseship.o      src/state_endsequence.o \
	src/state_game.o          src/state_gameover.o        src/state_instructions.o \
	src/state_interphase.o    src/state_keyredefinition.o \
	src/state_levelfinished.o src/state_logo.o            src/state_mainmenu.o \
	src/state_replay.o        src/state_replaymanager.o \
	src/state_typetext.o      src/tiles.o                 src/transball.o \
	src/homedir.o

ifdef DEBUG
	CXXFLAGS += -g3
else
	CXXFLAGS += -Ofast -mno-abicalls -mips32 -mplt -I./src/libSGE
endif

all: $(TARGET)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@ -I$(SYSROOT)/usr/include/SDL

# dynamically linked binary:
$(TARGET): $(OBJS)
	$(CXX) $^ -o $@ -lSDL -lSDL_image -lSDL_mixer ./src/libSGE/libSGE.a
ifndef DEBUG
	$(STRIP) $(TARGET)
endif
	# mv ./$(TARGET) ..

ipk: all
	@rm -rf /tmp/.stransball2-ipk/ && mkdir -p /tmp/.stransball2-ipk/root/home/retrofw/games/stransball2 /tmp/.stransball2-ipk/root/home/retrofw/apps/gmenu2x/sections/games
	@cp -r stransball2/stransball2.elf stransball2/stransball2.png stransball2/stransball2.man.txt stransball2/transball.cfg stransball2/demos stransball2/graphics stransball2/high stransball2/maps stransball2/sound /tmp/.stransball2-ipk/root/home/retrofw/games/stransball2
	@cp stransball2/stransball2.lnk /tmp/.stransball2-ipk/root/home/retrofw/apps/gmenu2x/sections/games
	@sed "s/^Version:.*/Version: $$(date +%Y%m%d)/" stransball2/control > /tmp/.stransball2-ipk/control
	@cp stransball2/conffiles /tmp/.stransball2-ipk/
	@tar --owner=0 --group=0 -czvf /tmp/.stransball2-ipk/control.tar.gz -C /tmp/.stransball2-ipk/ control conffiles
	@tar --owner=0 --group=0 -czvf /tmp/.stransball2-ipk/data.tar.gz -C /tmp/.stransball2-ipk/root/ .
	@echo 2.0 > /tmp/.stransball2-ipk/debian-binary
	@ar r stransball2/stransball2.ipk /tmp/.stransball2-ipk/control.tar.gz /tmp/.stransball2-ipk/data.tar.gz /tmp/.stransball2-ipk/debian-binary

opk: all
	@mksquashfs \
	stransball2/default.retrofw.desktop \
	stransball2/stransball2.dge \
	stransball2/stransball2.png \
	stransball2/stransball2.man.txt \
	stransball2/transball.cfg \
	stransball2/demos \
	stransball2/graphics \
	stransball2/high \
	stransball2/maps \
	stransball2/sound \
	stransball2/stransball2.opk \
	-all-root -noappend -no-exports -no-xattrs

clean:
	rm -f $(TARGET)
	rm -f src/*.o
