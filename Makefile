# Enable standard/heavy debugging (slow, lots of output)
DEBUG  = no
HDEBUG = no
# Optimize binary
OPTIM  = yes
# Silence build
SILENT = yes
# Show warnings
WARN   = no


# CROM/CRAM configuration
# 1 = 1K CROM, 1K CRAM, 1 set of S registers
# 2 = 2K CROM, 1K CRAM, 1 set of S registers
# 3 = 1K CROM, 3K CRAM, 8 sets of S registers
CRAM = 1

# Project name and version number
PROJECT   = salto
VER_MAJOR = 0
VER_MINOR = 4
VER_MICRO = 2
VERSION   = $(VER_MAJOR).$(VER_MINOR).$(VER_MICRO)

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
### PLATFORM = MINGW

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
ifeq ($(OPTIM), yes)
	CFLAGS	+= -O3 -fno-strict-aliasing -DDEBUG=0
endif
ifeq ($(WARN), yes)
	CFLAGS += -Wall -MD
	CFLAGS	+= -O3 -fno-strict-aliasing -DDEBUG=0
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
# LDFLAGS +=

# Archiver and flags
AR = ar
ARFLAGS = r

# Archiver TOC updater
RANLIB = ranlib

# Lex and Yacc (required for the Alto assember aasm)
LEX    = flex
YACC   = yacc
YFLAGS = -d -t -v

# Move command
MV = mv


# Default libraries
## LIBS +=
# Include paths in source directory
INC = -I./include -I./$(TEMP)


# Define platform/dependent includes and libraries
ifeq ($(PLATFORM), Darwin)
	BREW := $(shell brew --prefix)
	CFLAGS += -m64 -DMACOSX
	CFLAGS += -DHAVE_STDINT_H=1
	LDFLAGS += -mmacosx-version-min=$(OSXMIN)
	INCLUDES = -I$(BREW)/include -L$(BREW)/lib
endif
ifeq ($(PLATFORM), Linux)
	ifeq ($(ARCH), x86_64)
		LNXENV = 64
	else
		LNXENV = 32
	endif
	CFLAGS += -m$(LNXENV) -DLINUX
	CFLAGS += -DHAVE_STDINT_H=1
	LDFLAGS += -m$(LNXENV) -static
	INCLUDES = -I/usr/include -L/usr/lib
endif
ifeq ($(PLATFORM), MINGW)
	CFLAGS += -m32 -DWINDOWS
	CFLAGS += -DHAVE_STDINT_H=1		# check!
	LDFLAGS += -m32 -static
	INCLUDES = -I/usr/include -L/usr/lib
endif
ifeq ($(findstring NT-5.1,$(PLATFORM)), NT-5.1)
	CFLAGS += -m32 -DWINDOWS
	CFLAGS += -DHAVE_STDINT_H=1		# check!
	LDFLAGS += -m32 -static
	INCLUDES = -I/usr/include -L/usr/lib
endif
### ifeq ($(PLATFORM), ADD_YOUR_PLATFORM_HERE)
### 	FCFLAGS += -m32 -DLINUX
### 	LDFLAGS += -m32 -static
### 	INCLUDES = -I/usr/include -L/usr/lib
### endif

# CRAM configuration
CFLAGS += -DCRAM_CONFIG=$(CRAM)

# Draw some nifty icons on the frontend
CFLAGS += -DFRONTEND_ICONS=1


# # Include path (use to find zlib.h header file)
#
# # Specify the full path to a libz.so, if you know it, or
# # otherwise just comment the following line to build our own
# #
# ifeq ($(wildcard /usr/local/include/zlib.h),/usr/local/include/zlib.h)
# INCZ	=	-I/usr/local/include
# LIBZ	=	-L/usr/local/lib -Wl,-rpath,/usr/local/lib -lz
# else
# ifeq ($(wildcard /usr/pkg/include/zlib.h),/usr/pkg/include/zlib.h)
# INCZ	=	-I/usr/pkg/include
# LIBZ	=	-L/usr/pkg/lib -Wl,-rpath,/usr/pkg/lib -lz
# else
# ifeq ($(wildcard /usr/include/zlib.h),/usr/include/zlib.h)
# INCZ	=	-I/usr/include
# ifeq ($(wildcard /usr/lib/libz.so),/usr/lib/libz.so)
# LIBZ	=	-L/usr/lib -Wl,-rpath,/usr/lib -lz
# else
# ifeq ($(wildcard /lib/libz.so),/lib/libz.so)
# LIBZ	=	-L/lib -Wl,-rpath,/lib -lz
# else
# LIBZ	=
# endif
# endif
# endif
# endif
# endif


# If LIBZ is left empty, we will build our own in ./zlib
LIBZ =
INCZ = -Izlib

# Additional include paths
INC += $(INCZ)
# Additional libraries
LIBS +=

# Pull in the SDL CFLAGS, -I includes and LIBS
INC  += $(shell sdl-config --cflags)
LIBS += $(shell sdl-config --libs)


# # Define this, if your OS and compiler has stdint.h
# ifeq ($(wildcard /usr/include/stdint.h),/usr/include/stdint.h)
# CFLAGS	+= -DHAVE_STDINT_H=1
# endif


ifeq ($(SILENT), no)
	CC_MS      = @echo "==> compiling $< ..."
	CC_RUN     = @$(GCC)

	LD_MSG     = @echo "==> linking $@ ..."
	LD_RUN     = @$(LD)

	AR_MSG     = @echo "==> archiving $@ ..."
	AR_RUN     = @$(AR)

	RANLIB_MSG = @echo "==> indexing $@ ..."
	RANLIB_RUN = @$(RANLIB)

	LEX_MSG    = @echo "==> building lexer $< ..."
	LEX_RUN    = @$(LEX)

	YACC_RUN   = @$(YACC)
	YACC_MSG   = @echo "==> building parser $< ..."

	MV_RUN     = @$(MV)

	AASM_MSG   = @echo "==> assembling Alto code $< ..."
else
	CC_MSG     = @echo
	CC_RUN     = $(GCC)

	LD_MSG     = @echo
	LD_RUN     = $(LD)

	AR_MSG     = @echo
	AR_RUN     = $(AR)

	RANLIB_MSG = @echo
	RANLIB_RUN = $(RANLIB)

	LEX_MSG    = @echo
	LEX_RUN    = $(LEX)

	YACC_MSG   = @echo
	YACC_RUN   = $(YACC)

	MV_RUN     = $(MV)

	AASM_MSG   = @echo
endif


# List of source files
SRCS =	$(addprefix $(SRC)/, \
		alto.c      \
		cpu.c       \
		curt.c      \
		debug.c     \
		dht.c       \
		disk.c      \
		display.c   \
		drive.c     \
		dvt.c       \
		dwt.c       \
		eia.c       \
		emu.c       \
		ether.c     \
		hardware.c  \
		jkfflut.c   \
		keyboard.c  \
		ksec.c      \
		kwd.c       \
		md5.c       \
		memory.c    \
		mkcpu.c     \
		mng.c       \
		mouse.c     \
		mrt.c       \
		part.c      \
		png.c       \
		printer.c   \
		ram.c       \
		salto.c     \
		timer.c     \
		unused.c    \
		zcat.c      \
		)


# The object files for the altogether binary
# OTMP =	$(patsubst $(SRC)%.c,$(OBJ)%.o, $(SRCS))
# OBJS = $(filter-out %jkfflut.o, $(OTMP))
OBJS =	$(addprefix $(OBJ)/, \
		alto.o      \
		cpu.o       \
		curt.o      \
		debug.o     \
		dht.o       \
		disk.o      \
		display.o   \
		drive.o     \
		dvt.o       \
		dwt.o       \
		eia.o       \
		emu.o       \
		ether.o     \
		hardware.o  \
		keyboard.o  \
		ksec.o      \
		kwd.o       \
		md5.o       \
		memory.o    \
		mng.o       \
		mouse.o     \
		mrt.o       \
		part.o      \
		pics.o      \
		png.o       \
		printer.o   \
		ram.o       \
		salto.o     \
		timer.o     \
		unused.o    \
		zcat.o      \
		)

TARGETS :=

ifneq	($(strip $(LIBZ)),)
	# Use a system provided zlib
	LIBS += $(LIBZ)
	LIBZOBJ =
else
	# Use our own static zlib libz.a
	DIRS += $(OBJ)/zlib
	LIBS += $(OBJ)/$(ZLIB)/libz.a
	TARGETS += $(OBJ)/$(ZLIB)/libz.a
	LIBZOBJ += $(OBJ)/$(ZLIB)/adler32.o $(OBJ)/$(ZLIB)/compress.o \
		$(OBJ)/$(ZLIB)/crc32.o $(OBJ)/$(ZLIB)/deflate.o \
		$(OBJ)/$(ZLIB)/gzio.o $(OBJ)/$(ZLIB)/inffast.o \
		$(OBJ)/$(ZLIB)/inflate.o $(OBJ)/$(ZLIB)/infback.o \
		$(OBJ)/$(ZLIB)/inftrees.o $(OBJ)/$(ZLIB)/trees.o \
		$(OBJ)/$(ZLIB)/uncompr.o $(OBJ)/$(ZLIB)/zutil.o

	LIBZCFLAGS = -O2 -Wall -fno-strict-aliasing \
		-Wwrite-strings -Wpointer-arith -Wconversion \
		-Wstrict-prototypes -Wmissing-prototypes
endif

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


TARGETS += $(BIN)/ppm2c $(BIN)/convbdf $(BIN)/salto \
	$(BIN)/aasm $(BIN)/adasm $(BIN)/edasm \
	$(BIN)/dumpdsk $(BIN)/aar $(BIN)/aldump $(BIN)/helloworld.bin

all:	dirs $(TARGETS)


dirs:
	@-mkdir -p $(DIRS) 2>/dev/null
	@echo "*************** AUTO CONFIGURATION ***************"
	@echo "CC_RUN ....... $(CC_RUN)"
	@echo "LD_RUN ....... $(LD_RUN)"
	@echo "AR_RUN ....... $(AR_RUN)"
	@echo "RANLIB_RUN ... $(RANLIB_RUN)"
	@echo "LEX_RUN ...... $(LEX_RUN)"
	@echo "YACC_RUN ..... $(YACC_RUN)"
	@echo "**************************************************"

$(BIN)/salto:	$(OBJS)
	$(LD_MSG)
	$(LD) $(LDFLAGS) $(LIBS) -o $@ $^

$(BIN)/ppm2c:	$(OBJ)/ppm2c.o
	$(LD_MSG)
	$(LD) $(LDFLAGS) -o $@ $^

$(BIN)/convbdf:	$(OBJ)/convbdf.o
	$(LD_MSG)
	$(LD) $(LDFLAGS) -o $@ $^

$(BIN)/aasm:	$(OBJ)/aasm.tab.o $(OBJ)/aasmyy.o
	$(LD_MSG)
	$(LD) $(LDFLAGS) -o $@ $^

$(BIN)/adasm:	$(OBJ)/adasm.o
	$(LD_MSG)
	$(LD) $(LDFLAGS) -o $@ $^

$(BIN)/edasm:	$(OBJ)/edasm.o
	$(LD_MSG)
	$(LD) $(LDFLAGS) -o $@ $^

$(BIN)/dumpdsk:	$(OBJ)/dumpdsk.o
	$(LD_MSG)
	$(LD) $(LDFLAGS) -o $@ $^

$(BIN)/aar:	$(OBJ)/aar.o
	$(LD_MSG)
	$(LD) $(LDFLAGS) -o $@ $^

$(BIN)/aldump:	$(OBJ)/aldump.o $(OBJ)/png.o $(OBJ)/md5.o
	$(LD_MSG)
	$(LD) $(LDFLAGS) $(LIBS) -o $@ $^

$(BIN)/helloworld.bin: asm/helloworld.asm $(BIN)/aasm
	$(AASM_MSG)
	$(BIN)/aasm -l -o $@ $<

$(TEMP)/pics.c: $(BIN)/ppm2c
	@echo "==> embedding icons in C source $@ ..."
	@$(BIN)/ppm2c $(wildcard pics/*.ppm) >$@


$(OBJ)/%.o:	 $(SRC)/%.c
	$(CC_MSG)
	$(CC_RUN) $(CFLAGS) $(INC) -o $@ -c $<

$(OBJ)/%.o:	$(TOOLS)/%.c
	$(CC_MSG)
	$(CC_RUN) $(CFLAGS) -Iinclude -I$(TEMP) -Itools -o $@ -c $<

$(OBJ)/%.o:	$(TEMP)/%.c
	$(CC_MSG)
	$(CC_RUN) $(CFLAGS) $(INC) -Itools -o $@ -c $<


$(OBJ)/$(ZLIB)/%.o:	 $(SRC)/$(ZLIB)/%.c
	$(CC_MSG)
	$(CC_RUN) $(LIBZCFLAGS) $(INC) -o $@ -c $<

$(OBJ)/$(ZLIB)/libz.a:	$(LIBZOBJ)
	$(AR_MSG)
	$(AR_RUN) $(ARFLAGS) $@ $^
	$(RANLIB_MSG)
	$(RANLIB_RUN) $@


$(TEMP)/aasmyy.c:	$(TOOLS)/aasm.l
	$(LEX_MSG)
	$(LEX_RUN) -o$@ -i $<

$(TEMP)/aasm.tab.c:	$(TOOLS)/aasm.y
	$(YACC_MSG)
	$(YACC_RUN) $(YFLAGS) -baasm $<
	$(MV_RUN) aasm.output $(TEMP)
	$(MV_RUN) aasm.tab.? $(TEMP)



# helloworld:	all
# ifeq	($(DEBUG), yes)
# 	$(BIN)/salto -all $(BIN)/helloworld.bin
# else
# 	$(BIN)/salto $(BIN)/helloworld.bin
# endif


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
