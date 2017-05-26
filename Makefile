# Optimize binary
OPTIM  = yes
# Show warnings
WARN   = no
# Enable standard/heavy debugging (slow, lots of output)
DEBUG  = no
HDEBUG = no


# CROM/CRAM configuration
#   1 = 1K CROM, 1K CRAM, 1 set of S registers
#   2 = 2K CROM, 1K CRAM, 1 set of S registers
#   3 = 1K CROM, 3K CRAM, 8 sets of S registers
CRAM = 1


# # Project name and version number
# PROJECT   = salto
# VER_MAJOR = 0
# VER_MINOR = 4
# VER_MICRO = 2
# VERSION   = $(VER_MAJOR).$(VER_MINOR).$(VER_MICRO)


# Relative path names
SRC   = src
OBJ   = obj
BIN   = bin
TEMP  = temp
ZLIB  = zlib
TOOLS = tools
DIRS  = $(BIN) $(OBJ) $(TEMP)

# Check platform (Darwin, Linux or Windows) and architecture (32/64 bit)
PLATFORM := $(shell uname)
ARCH     := $(shell uname -m)
OSXMIN = 10.8

# Manually choose this platform for cross-compilation of Windows executable under Linux
## PLATFORM = MINGW

# Set GCC compiler according to platform
ifeq ($(PLATFORM), Darwin)
	export GCC = $(shell which gcc)
endif
ifeq ($(PLATFORM), Linux)
	export GCC = $(shell which gcc)
endif
ifeq ($(PLATFORM), MINGW)
	export GCC = i686-w64-mingw32-gcc
endif
ifeq ($(findstring NT-5.1,$(PLATFORM)), NT-5.1)
	export GCC = $(shell which gcc)
endif
### ifeq ($(PLATFORM), ADD_YOUR_PLATFORM_HERE)
### 	export GCC = ADD_YOUR_COMPILER_HERE
### endif


# Set optimization/warning/debug flags
CFLAGS =
LDFLAGS =
ifeq ($(OPTIM), yes)
	CFLAGS += -O3 -fno-strict-aliasing -DDEBUG=0
endif
ifeq ($(WARN), yes)
	CFLAGS += -Wall -MD
	CFLAGS += -O3 -fno-strict-aliasing -DDEBUG=0
endif
# standard debugging
ifeq ($(DEBUG), yes)
	CFLAGS += -g -O3 -DDEBUG=1		# why not -O0?
	LDFLAGS += -g
endif
# heavy debugging (normally not needed)
ifeq ($(HDEBUG), yes)
	CFLAGS += -g -O3 -DDEBUG=1		# why not -O0?
	CFLAGS += -DDEBUG_CPU_TIMESLICES=1
	CFLAGS += -DDEBUG_DISPLAY_TIMING=1
	LDFLAGS += -g
endif


# Linker and flags
LD = $(GCC)

# Archiver and flags
AR = ar
ARFLAGS = r

# Archiver TOC updater
RANLIB = ranlib

# Lex and Yacc (required for the Alto assember aasm)
LEX = flex
YACC = yacc
YFLAGS = -d -t -v

# Move command
MV = mv


# Default libraries
LIBS =
# Include paths in source directory
INC = -I./include -I./$(TEMP)


# Define platform/dependent includes and libraries
INCLUDES =
ifeq ($(PLATFORM), Darwin)
	BREW := $(shell brew --prefix)
	CFLAGS += -m64 -DMACOSX
	CFLAGS += -DHAVE_STDINT_H=1
	LDFLAGS += -mmacosx-version-min=$(OSXMIN)
	INCLUDES += -I$(BREW)/include -L$(BREW)/lib
endif
ifeq ($(PLATFORM), Linux)
	ifeq ($(ARCH), x86_64)
		LNXENV = 64
	else
		LNXENV = 32
	endif
	CFLAGS += -m$(LNXENV) -DLINUX
	CFLAGS += -DHAVE_STDINT_H=1
	LDFLAGS += -m$(LNXENV)
	INCLUDES += -I/usr/include -L/usr/lib
endif
ifeq ($(PLATFORM), MINGW)
	CFLAGS += -m32 -DWINDOWS
	CFLAGS += -DHAVE_STDINT_H=1		# check!
	LDFLAGS += -m32
	INCLUDES += -I/usr/include -L/usr/lib
endif
ifeq ($(findstring NT-5.1,$(PLATFORM)), NT-5.1)
	CFLAGS += -m32 -DWINDOWS
	CFLAGS += -DHAVE_STDINT_H=1		# check!
	LDFLAGS += -m32 -static
	INCLUDES += -I/usr/include -L/usr/lib
endif
### ifeq ($(PLATFORM), ADD_YOUR_PLATFORM_HERE)
### 	FCFLAGS += -m32 -DLINUX
### 	LDFLAGS += -m32 -static
### 	INCLUDES += -I/usr/include -L/usr/lib
### endif


# CRAM configuration
CFLAGS += -DCRAM_CONFIG=$(CRAM)

# Draw some nifty icons on the frontend
CFLAGS += -DFRONTEND_ICONS=1


# Pull in the SDL CFLAGS, -I includes and LIBS
INC  += $(shell sdl-config --cflags)
LIBS += $(shell sdl-config --libs)

# If LIBZ is left empty, build libz in ./zlib
LIBZ =
INCZ = -Izlib

# Include path (use to find zlib.h header file)
#   specify the full path to a libz.so, if you know it, or
#   otherwise just comment the following line to build our own
# ifeq ($(wildcard /usr/local/include/zlib.h),/usr/local/include/zlib.h)
# INCZ = -I/usr/local/include
# LIBZ = -L/usr/local/lib -Wl,-rpath,/usr/local/lib -lz
# else
# ifeq ($(wildcard /usr/pkg/include/zlib.h),/usr/pkg/include/zlib.h)
# INCZ = -I/usr/pkg/include
# LIBZ = -L/usr/pkg/lib -Wl,-rpath,/usr/pkg/lib -lz
# else
# ifeq ($(wildcard /usr/include/zlib.h),/usr/include/zlib.h)
# INCZ = -I/usr/include
# ifeq ($(wildcard /usr/lib/libz.so),/usr/lib/libz.so)
# LIBZ = -L/usr/lib -Wl,-rpath,/usr/lib -lz
# else
# ifeq ($(wildcard /lib/libz.so),/lib/libz.so)
# LIBZ = -L/lib -Wl,-rpath,/lib -lz
# else
# LIBZ =
# endif
# endif
# endif
# endif
# endif


# Additional include paths
INC += $(INCZ)


# List of source files
SRCS =	$(addprefix $(SRC)/, \
		alto.c      cpu.c       curt.c      debug.c     \
		dht.c       disk.c      display.c   drive.c     \
		dvt.c       dwt.c       eia.c       emu.c       \
		ether.c     hardware.c  jkfflut.c   keyboard.c  \
		ksec.c      kwd.c       md5.c       memory.c    \
		mkcpu.c     mng.c       mouse.c     mrt.c       \
		part.c      png.c       printer.c   ram.c       \
		salto.c     timer.c     unused.c    zcat.c      \
		)

# List of object files
OBJS =	$(addprefix $(OBJ)/, \
		alto.o      cpu.o       curt.o      debug.o     \
		dht.o       disk.o      display.o   drive.o     \
		dvt.o       dwt.o       eia.o       emu.o       \
		ether.o     hardware.o  keyboard.o  ksec.o      \
		kwd.o       md5.o       memory.o    mng.o       \
		mouse.o     mrt.o       part.o      pics.o      \
		png.o       printer.o   ram.o       salto.o     \
		timer.o     unused.o    zcat.o                  \
		)

# Compiled binaries
BINARIES = $(addprefix $(BIN)/, \
		ppm2c           \
		convbdf         \
		salto           \
		aasm            \
		adasm           \
		edasm           \
		dumpdsk         \
		aar             \
		aldump          \
		helloworld.bin  \
		)

TARGETS :=

ifneq ($(strip $(LIBZ)),)
	# Use a system provided zlib
	LIBS += $(LIBZ)
	LIBZOBJS =
else
	# Use our own static zlib libz.a
	DIRS += $(OBJ)/zlib
	LIBS += $(OBJ)/$(ZLIB)/libz.a
	TARGETS += $(OBJ)/$(ZLIB)/libz.a
	LIBZOBJS = $(addprefix $(OBJ)/$(ZLIB)/, \
		adler32.o   compress.o  crc32.o     deflate.o   \
		gzio.o      inffast.o   inflate.o   infback.o   \
		inftrees.o  trees.o     uncompr.o   zutil.o     \
		)
	LIBZCFLAGS = -O2 -Wall -fno-strict-aliasing \
		-Wwrite-strings -Wpointer-arith -Wconversion \
		-Wstrict-prototypes -Wmissing-prototypes
endif


TARGETS += $(BIN)/ppm2c $(BIN)/convbdf $(BIN)/salto \
	$(BIN)/aasm $(BIN)/adasm $(BIN)/edasm \
	$(BIN)/dumpdsk $(BIN)/aar $(BIN)/aldump $(BIN)/helloworld.bin

all:	dirs $(TARGETS)

dirs:
	@-mkdir -p $(DIRS) 2>/dev/null


$(BIN)/salto:	$(OBJS)
	$(LD) $(LDFLAGS) -o $@ $^ $(LIBS)

$(BIN)/ppm2c:	$(OBJ)/ppm2c.o
	$(LD) $(LDFLAGS) -o $@ $^

$(BIN)/convbdf:	$(OBJ)/convbdf.o
	$(LD) $(LDFLAGS) -o $@ $^

$(BIN)/aasm:	$(OBJ)/aasm.tab.o $(OBJ)/aasmyy.o
	$(LD) $(LDFLAGS) -o $@ $^

$(BIN)/adasm:	$(OBJ)/adasm.o
	$(LD) $(LDFLAGS) -o $@ $^

$(BIN)/edasm:	$(OBJ)/edasm.o
	$(LD) $(LDFLAGS) -o $@ $^

$(BIN)/dumpdsk:	$(OBJ)/dumpdsk.o
	$(LD) $(LDFLAGS) -o $@ $^

$(BIN)/aar:	$(OBJ)/aar.o
	$(LD) $(LDFLAGS) -o $@ $^

$(BIN)/aldump:	$(OBJ)/aldump.o $(OBJ)/png.o $(OBJ)/md5.o
	$(LD) $(LDFLAGS) -o $@ $^ $(LIBS)

$(BIN)/helloworld.bin: asm/helloworld.asm $(BIN)/aasm
	$(BIN)/aasm -l -o $@ $<

$(TEMP)/pics.c: $(BIN)/ppm2c
	@echo "==> embedding icons in C source $@ ..."
	@$(BIN)/ppm2c $(wildcard pics/*.ppm) >$@


$(OBJ)/%.o:	 $(SRC)/%.c
	$(GCC) $(CFLAGS) $(INC) -o $@ -c $<

$(OBJ)/%.o:	$(TOOLS)/%.c
	$(GCC) $(CFLAGS) -Iinclude -I$(TEMP) -Itools -o $@ -c $<

$(OBJ)/%.o:	$(TEMP)/%.c
	$(GCC) $(CFLAGS) $(INC) -Itools -o $@ -c $<


$(OBJ)/$(ZLIB)/%.o:	 $(SRC)/$(ZLIB)/%.c
	$(GCC) $(LIBZCFLAGS) $(INC) -o $@ -c $<

$(OBJ)/$(ZLIB)/libz.a:	$(LIBZOBJS)
	$(AR) $(ARFLAGS) $@ $^
	$(RANLIB) $@


$(TEMP)/aasmyy.c:	$(TOOLS)/aasm.l
	$(LEX) -o$@ -i $<

$(TEMP)/aasm.tab.c:	$(TOOLS)/aasm.y
	$(YACC) $(YFLAGS) -baasm $<
	$(MV) aasm.output $(TEMP)
	$(MV) aasm.tab.? $(TEMP)



helloworld:	all
ifeq	($(DEBUG), yes)
	$(BIN)/salto -all $(BIN)/helloworld.bin
else
	$(BIN)/salto $(BIN)/helloworld.bin
endif


clean:
	rm -rf salto *.core $(TEMP) $(OBJ) $(BIN)

distclean:	clean
	rm -rf helloworld.bin alto.mng alto*.png alto.dump log *.bck */*.bck

# dist:	distclean
# 	cd .. && tar -czf $(PROJECT)-$(VERSION).tar.gz \
# 	`find salto \
# 		-regex ".*\.[chly]$$" \
# 		-o -regex ".*\.asm$$" \
# 		-o -regex ".*\.txt$$" \
# 		-o -regex ".*\.mu$$" \
# 		-o -regex "salto/README$$" \
# 		-o -regex "salto/COPYING$$" \
# 		-o -regex "salto/Makefile$$" \
# 		-o -regex "salto/Doxyfile$$" \
# 		-o -regex "salto/roms/.*$$" \
# 		-o -regex "salto/pics/.*$$" | \
# 		grep -v Alto_ROMs | \
# 		grep -v CVS`


print-% :
	@echo $* = $($*)


# include $(wildcard $(OBJ)/*.d)
