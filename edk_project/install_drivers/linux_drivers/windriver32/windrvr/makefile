# Jungo Confidential. Copyright (c) 2008 Jungo Ltd. http://www.jungo.com
# Template file for configure script

CSRCS = linux_wrappers.c wdusb_linux.c 
OD = LINUX.2.6.24-19-generic.i386
MODDIR = /lib/modules/2.6.24-19-generic/kernel/drivers/misc
LINK_OBJ = windrvr_gcc_v3_regparm.a
MODULE_NAME = windrvr6
TARGET = LINUX.2.6.24-19-generic.i386/windrvr6.ko
CFLAGS = -c -O2 -Wall -DLINUX -D__KERNEL__ -DMODULE -DWINDRIVER_KERNEL  -DLINUX_USB_SUPPORT -mpreferred-stack-boundary=2 -mregparm=3 -nostdinc -iwithprefix include -Wstrict-prototypes -Wno-trigraphs 		-fno-common -pipe -O -I/lib/modules/2.6.24-19-generic/build/include -I/lib/modules/2.6.24-19-generic/build/include/asm/mach-default -I/lib/modules/2.6.24-19-generic/build/include -I/home/brandyn/Documents/install_drivers/linux_drivers/windriver32/include -I/home/brandyn/Documents/install_drivers/linux_drivers/windriver32  -fno-strict-aliasing -D"KBUILD_STR(s)=\#s" -D"KBUILD_MODNAME=KBUILD_STR(windrvr6)" -D"KBUILD_BASENAME=KBUILD_STR(windrvr6)" -include /lib/modules/2.6.24-19-generic/build/include/linux/autoconf.h
LDFLAGS =  -m elf_i386
ROOT_DIR = /home/brandyn/Documents/install_drivers/linux_drivers/windriver32
SHARED_OBJECT = libwdapi921

ifeq ($(DEBUG),1)
	CFLAGS += -g -DDEBUG
endif

COBJS = $(patsubst %.c,$(OD)/%.o,$(CSRCS))

all: $(OD) $(TARGET)

$(OD):
	-@ mkdir $@ 

$(COBJS): $(OD)/%.o : %.c 
	$(CC) $(CFLAGS) -c -o $@ $<

$(TARGET): $(COBJS) __temp_link modpost
	$(LD) $(LDFLAGS) -r -o $@ $(OD)/$(MODULE_NAME).o $(OD)/$(MODULE_NAME).mod.o

__temp_link:
	$(LD) $(LDFLAGS) -r -o $(OD)/$(MODULE_NAME).o $(OD)/linux_wrappers.o $(OD)/wdusb_linux.o $(LINK_OBJ)

modpost:
	/lib/modules/2.6.24-19-generic/build/scripts/mod/modpost $(OD)/$(MODULE_NAME).o
	$(CC) $(CFLAGS) -c -o $(OD)/$(MODULE_NAME).mod.o $(OD)/$(MODULE_NAME).mod.c
	
clean:
	rm -f core $(TARGET) $(OD)/*

install: all
	./setup_inst_dir
	ln -sf $(ROOT_DIR)/lib/$(SHARED_OBJECT).so /usr/lib/$(SHARED_OBJECT).so
	-@ echo
	-@ echo "Installing the WinDriver kernel module"
	-@ echo "--------------------"
	-@ echo "WinDriver's kernel module ($(MODULE_NAME).o / $(MODULE_NAME).ko) can be reloaded upon every boot."
	-@ echo "The kernel module will be loaded after running the wdreg script upon boot"
	-@ echo "in the following manner:"
	-@ echo "    <path to the wdreg script>/wdreg $(MODULE_NAME) auto"
	-@ echo "Alternatively you can manually load the kernel module as explained"
	-@ echo "in WinDriver's User's Manual."
	-@ echo "It is recommended to add this call in your rc.local file."
	-@ echo "NOTE: Due to security reasons, by default, /dev/$(MODULE_NAME) is created with"
	-@ echo "permissions only for the root user. To enable other user access,"
	-@ echo change the permissions of /dev/windrvr6 
	
	-@ echo 
	mkdir -p $(MODDIR)
	cp $(TARGET) $(MODDIR)
	./wdreg $(MODULE_NAME) no 
