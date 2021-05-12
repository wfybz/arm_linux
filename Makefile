CC      = arm-linux-gcc
LD      = arm-linux-ld
OBJCOPY = arm-linux-objcopy

#**************************************************************************************
# debug options
#**************************************************************************************
DEBUG_LEVEL = debug

#**************************************************************************************
# boot source
#**************************************************************************************
BOOT_SRCS = \
src/boot/start.S             \
src/boot/mem.S

#**************************************************************************************
# init source
#**************************************************************************************
INIT_SRCS = \
src/init/main.c              

#**************************************************************************************
# driver source
#**************************************************************************************
DRIVER_SRCS = \
src/driver/led.c

#**************************************************************************************
# all arm_linux source
#**************************************************************************************
SRCS  = $(BOOT_SRCS)
SRCS += $(INIT_SRCS)
SRCS += $(DRIVER_SRCS)

#**************************************************************************************
# build path
#**************************************************************************************
ifeq ($(DEBUG_LEVEL), debug)
OUTPATH = ./debug
else
OUTPATH = ./release
endif

OBJPATH = $(OUTPATH)/obj

#**************************************************************************************
# arm_linux objects
#**************************************************************************************
OBJS_BOOT      = $(addprefix $(OBJPATH)/, $(addsuffix .o, $(basename $(BOOT_SRCS))))
OBJS_INIT      = $(addprefix $(OBJPATH)/, $(addsuffix .o, $(basename $(INIT_SRCS))))
OBJS_DRIVER    = $(addprefix $(OBJPATH)/, $(addsuffix .o, $(basename $(DRIVER_SRCS))))

OBJS  = $(OBJS_BOOT)
OBJS += $(OBJS_INIT)
OBJS += $(OBJS_DRIVER)

#**************************************************************************************
# include path
#**************************************************************************************
INCDIR  = "./src/include"

#**************************************************************************************
# compiler optimize
#**************************************************************************************
ifeq ($(DEBUG_LEVEL), debug)
OPTIMIZE = -O0 -g3 -I$(INCDIR)
else
OPTIMIZE = -O2 -g1 -I$(INCDIR)
endif

TARGET   = $(OUTPATH)/arm-os.elf
BINFILE  = $(OUTPATH)/arm-os.bin

all : $(TARGET)

$(TARGET) : $(OBJS)
	arm-linux-ld -Tgboot.lds -o $@ $^
	arm-linux-objcopy -O binary $(TARGET) $(BINFILE)

$(OBJPATH)/%.o : %.S
	@if [ ! -d "$(dir $@)" ]; then mkdir -p "$(dir $@)"; fi
	arm-linux-gcc $(OPTIMIZE) -c $< -o $@

$(OBJPATH)/%.o : %.c
	@if [ ! -d "$(dir $@)" ]; then mkdir -p "$(dir $@)"; fi
	arm-linux-gcc $(OPTIMIZE) -c $< -o $@

clean:
	rm -rdf gboot.elf gboot.bin $(OBJS) $(TARGET) $(BINFILE)
