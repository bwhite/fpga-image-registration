################################################################# 
# Makefile generated by Xilinx Platform Studio SDK 
#                                                          
# WARNING : This file will be re-generated every time a command 
# to run a make target is invoked. So, any changes made to this 
# file manually, will be lost when make is invoked next. 
#################################################################

MHSFILE = /home/brandyn/Documents/blah.mhs
MSSFILE = /home/brandyn/Documents/SDK_projects/microblaze_0_sw_platform/blah.mss
SW_PLATFORM_DIR = /home/brandyn/Documents/SDK_projects/microblaze_0_sw_platform
LOGFILE = /home/brandyn/Documents/SDK_projects/microblaze_0_sw_platform/libgen.log
LIBRARIES = /home/brandyn/Documents/SDK_projects/microblaze_0_sw_platform/microblaze_0/lib/libxil.a
DEVICE = xc5vsx50tff1136-1
SEARCHPATHOPT = 

libs: $(LIBRARIES)

$(LIBRARIES): $(MHSFILE) $(MSSFILE)
	libgen -mhs /home/brandyn/Documents/blah.mhs -xmpdir /home/brandyn/Documents \
	-p $(DEVICE) $(SEARCHPATHOPT) -pe microblaze_0 -od $(SW_PLATFORM_DIR) \
	-log ${LOGFILE} /home/brandyn/Documents/SDK_projects/microblaze_0_sw_platform/blah.mss

