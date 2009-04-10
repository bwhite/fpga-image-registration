##############################################################################
## Filename:          /home/brandyn/Xilinx10.1i/edk_user_repository/MyProcessorIPLib/drivers/registration_core_v1_00_a/data/registration_core_v2_1_0.tcl
## Description:       Microprocess Driver Command (tcl)
## Date:              Wed Mar 18 00:17:50 2009 (by Create and Import Peripheral Wizard)
##############################################################################

#uses "xillib.tcl"

proc generate {drv_handle} {
  xdefine_include_file $drv_handle "xparameters.h" "registration_core" "NUM_INSTANCES" "DEVICE_ID" "C_BASEADDR" "C_HIGHADDR" 
}
