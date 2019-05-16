CHAINPREFIX := /opt/mipsel-linux-uclibc
CROSS_COMPILE := $(CHAINPREFIX)/usr/bin/mipsel-linux-

CXX := $(CROSS_COMPILE)g++
STRIP := $(CROSS_COMPILE)strip

SYSROOT := $(shell $(CC) --print-sysroot)
SDL_CFLAGS := $(shell $(SYSROOT)/usr/bin/sdl-config --cflags)
SDL_LIBS := $(shell $(SYSROOT)/usr/bin/sdl-config --libs)

TARGET	:= stransball2/stransball2.elf
OBJS	:= \
	sources/auxiliar.o            sources/configuration.o         sources/encoder.o \
	sources/enemies.o             sources/fonts.o       	      sources/game.o \
	sources/main.o                sources/maps.o                  sources/replays.o \
	sources/state_changepack.o    sources/state_chooseship.o      sources/state_endsequence.o \
	sources/state_game.o          sources/state_gameover.o        sources/state_instructions.o \
	sources/state_interphase.o    sources/state_keyredefinition.o \
	sources/state_levelfinished.o sources/state_logo.o            sources/state_mainmenu.o \
	sources/state_replay.o        sources/state_replaymanager.o \
	sources/state_typetext.o      sources/tiles.o                 sources/transball.o \
	sources/homedir.o

ifdef DEBUG
	CXXFLAGS += -g3
else
	CXXFLAGS += -Ofast -mno-abicalls -mips32 -mplt -I./libSGE
endif

all: $(TARGET)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@ -I$(SYSROOT)/usr/include/SDL

# dynamically linked binary:
$(TARGET): $(OBJS)
	$(CXX) $^ -o $@ -lSDL -lSDL_image -lSDL_mixer ./sources/libSGE/libSGE.a
ifndef DEBUG
	$(STRIP) $(TARGET)
endif
	# mv ./$(TARGET) ..

ipk: $(TARGET)
	@rm -rf /tmp/.stransball2-ipk/ && mkdir -p /tmp/.stransball2-ipk/root/home/retrofw/games/stransball2 /tmp/.stransball2-ipk/root/home/retrofw/apps/gmenu2x/sections/games
	@cp -r stransball2/stransball2.elf stransball2/stransball2.png stransball2/stransball2.man.txt stransball2/transball.cfg stransball2/demos stransball2/graphics stransball2/high stransball2/maps stransball2/sound /tmp/.stransball2-ipk/root/home/retrofw/games/stransball2
	@cp stransball2/stransball2.lnk /tmp/.stransball2-ipk/root/home/retrofw/apps/gmenu2x/sections/games
	@sed "s/^Version:.*/Version: $$(date +%Y%m%d)/" stransball2/control > /tmp/.stransball2-ipk/control
	@cp stransball2/conffiles /tmp/.stransball2-ipk/
	@tar --owner=0 --group=0 -czvf /tmp/.stransball2-ipk/control.tar.gz -C /tmp/.stransball2-ipk/ control conffiles
	@tar --owner=0 --group=0 -czvf /tmp/.stransball2-ipk/data.tar.gz -C /tmp/.stransball2-ipk/root/ .
	@echo 2.0 > /tmp/.stransball2-ipk/debian-binary
	@ar r stransball2/stransball2.ipk /tmp/.stransball2-ipk/control.tar.gz /tmp/.stransball2-ipk/data.tar.gz /tmp/.stransball2-ipk/debian-binary

clean:
	rm -f $(TARGET)
	rm -f sources/*.o
