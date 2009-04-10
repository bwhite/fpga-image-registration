###############################################################################
##
## Copyright (c) 1995-2002 Xilinx, Inc.  All rights reserved.
##
## genace.tcl
## Generate SystemACE configuration file from FPGA bitstream 
## and PowerPC ELF program
## 
## $Header: /devl/xcs/repo/env/Jobs/MDT/sw/Apps/debug/new_xmd/DataFiles/Attic/genace.tcl,v 1.1.2.8.16.1 2007/08/24 00:41:12 rajn Exp $
###############################################################################

# Quick Start:
#
# USAGE: 
# xmd -tcl genace.tcl [-opt <genace options file>] [-jprog]  [-target <target type>] 
# [-hw <bitstream>] [-elf <Elf Files>] [-data <Data files>] [-board <board type>] -ace <ACE file>
#
#
# Note: 
# This script has been tested for ML300 V2P4/7,Memec V2P4/7 boards and Microblaze Demo Board
# For other boards, the options that may have to be modified below are :
# "xmd_options", "jtag_fpga_position" and "jtag_devices" 
#
# Raj: Added Boards ML401, ML402 and ML403


set usage "\nUSAGE:
xmd -tcl genace.tcl \[-opt <genace options file>\] | 
                    \[-jprog\] \[-hw <bitstream>\] \[-elf {ELF files}\]  \[-data {<Data file> <load address>}\] -board <target board> -target <target type> -ace <output ACE file>\n\n\
\t<target type>  - \[ppc_hw|mdm\]\n\
\t\[bitstream\]    - bit/svf file\n\
\t\[ELF files\]    - elf/svf files\n\
\t\[Data file\]    - data/svf file loaded at <load address>\n\
\t<target board> - \[user|<supported board name>\]\n\
\t\tSupported board name   -> Supported Board Name\n\
\t\tuser   -> User Specified Config parameters\n\n"

#---------------------------------------------------------------------
#
#  Supported Board Settings
#     The following are the list of Supported Boards. The JTAG Chain
#     devices information and FPGA position in the Chain are captured.
#        a. jtag_chain_options -
#        b. jtag_fpga_position -
#        c. jtag_devices -
#
#     Use the "-board <board name>" to select a particular board.
#
#  Note: To Specify the JTAG Chain information for a custom board, use 
#        "-board user" option and specify them in a genace option file.
#
#---------------------------------------------------------------------

set ml300(jtag_chain_options) "-configdevice devicenr 1 idcode 0x123e093 irlength 10 partname xc2vp7"
set ml300(jtag_fpga_position) 1
set ml300(jtag_devices) "xc2vp7"

set ml310(jtag_chain_options) "-configdevice devicenr 1 idcode 0x127E093 irlength 14 partname xc2vp30"
set ml310(jtag_fpga_position) 1
set ml310(jtag_devices) "xc2vp30"

set ml410(jtag_chain_options) "-configdevice devicenr 1 idcode 0x01EB4093 irlength 14 partname xc4vfx60"
set ml410(jtag_fpga_position) 1
set ml410(jtag_devices) "xc4vfx60"

set ml411(jtag_chain_options) "-configdevice devicenr 1 idcode 0x01EE4093 irlength 14 partname xc4vfx100"
set ml411(jtag_fpga_position) 1
set ml411(jtag_devices) "xc4vfx100"

set memec(jtag_chain_options) "-configdevice devicenr 1 irlength 8 partname xc18v04 -configdevice devicenr 2 irlength 8 partname xc18v04 -configdevice devicenr 3 idcode 0x123E093 irLength 10 partname xc2vp4"
set memec(jtag_fpga_position) 3
set memec(jtag_devices) "xc18v04 xc18v04 xc2vp4"

set mbdemo(jtag_chain_options) "-configdevice devicenr 1 idcode 0x1028093 irlength 6 partname xc2v1000"
set mbdemo(jtag_fpga_position) 1
set mbdemo(jtag_devices) "xc2v1000"

# Production ML403
set ml403(jtag_chain_options) "-configdevice devicenr 1 idcode 0x05059093 irlength 16 partname xcf32p -configdevice devicenr 2 idcode 0x01E58093 irlength 10 partname xc4vfx12 -configdevice devicenr 3 idcode 0x09608093 irlength 8 partname xc95144xl"
set ml403(jtag_fpga_position) 2
set ml403(jtag_devices) "xcf32p xc4vfx12 xc95144xl"

# Production ML402
set ml402(jtag_chain_options) "-configdevice devicenr 1 idcode 0x05059093 irlength 16 partname xcf32p -configdevice devicenr 2 idcode 0x02088093 irlength 10 partname xc4vsx35 -configdevice devicenr 3 idcode 0x09608093 irlength 8 partname xc95144xl"
set ml402(jtag_fpga_position) 2
set ml402(jtag_devices) "xcf32p xc4vsx35 xc95144xl"

# Production ML401
set ml401(jtag_chain_options) "-configdevice devicenr 1 idcode 0x05059093 irlength 16 partname xcf32p -configdevice devicenr 2 idcode 0x0167C093 irlength 10 partname xc4vlx25 -configdevice devicenr 3 idcode 0x09608093 irlength 8 partname xc95144xl"
set ml401(jtag_fpga_position) 2
set ml401(jtag_devices) "xcf32p xc4vlx25 xc95144xl"

# ML401 Engineering Sample
set ml401_es(jtag_chain_options) "-configdevice devicenr 1 idcode 0x05059093 irlength 16 partname xcf32p -configdevice devicenr 2 idcode 0x0167C093 irlength 10 partname xc4vlx25 -configdevice devicenr 3 idcode 0x09608093 irlength 8 partname xc95144xl -bscan USER1"
set ml401_es(jtag_fpga_position) 2
set ml401_es(jtag_devices) "xcf32p xc4vlx25 xc95144xl"

# Production ML405
set ml405(jtag_chain_options) "-configdevice devicenr 1 idcode 0x05059093 irlength 16 partname xcf32p -configdevice devicenr 2 idcode 0x01E64093 irlength 10 partname xc4vFx20 -configdevice devicenr 3 idcode 0x09608093 irlength 8 partname xc95144xl"
set ml405(jtag_fpga_position) 2
set ml405(jtag_devices) "xcf32p xc4vFx20 xc95144xl"

 # Production ML501
set ml501(jtag_chain_options) "-configdevice devicenr 1 idcode 0x02896093 irlength 10 partname xc5vlx50"
set ml501(jtag_fpga_position) 1
set ml501(jtag_devices) "xc5vlx50"

# Production ML505
set ml505(jtag_chain_options) "-configdevice devicenr 1 idcode 0x02a96093 irlength 10 partname xc5vlx50t"
set ml505(jtag_fpga_position) 1
set ml505(jtag_devices) "xc5vlx50t"

# Production ML506
set ml506(jtag_chain_options) "-configdevice devicenr 1 idcode 0x02E9A093 irlength 10 partname xc5vsx50t"
set ml506(jtag_fpga_position) 1
set ml506(jtag_devices) "xc5vsx50t"

# Production ML507
set ml507(jtag_chain_options) "-configdevice devicenr 1 idcode 0x032c6093 irlength 10 partname xc5vfx70t"
set ml507(jtag_fpga_position) 1
set ml507(jtag_devices) "xc5vfx70t"

#---------------------------------------------------------------------
#
#  Global Script Variables
#
#---------------------------------------------------------------------
# Setting some default options
set param(board) "ml403"
set param(hw) ""
set param(jprog) "false"
set param(ace) ""
set param(xmd_options) ""
set param(jtag_fpga_position) ""
set param(jtag_devices) ""
set param(jtag_chain_options) [list]
set param(ncpu) 0
set param(sw) [list]
set param(data) [list]
# Processor Specific information
set cpu_nr(0)          [list]
set cpu_target(0)      [list]
set cpu_debugdevice(0) [list]
set cpu_elf(0)         [list]
set cpu_data(0)        [list]
set cpu_startaddr(0)   [list] 

set final_svf 0
set fpga_irlength 0

#
#
# Detailed description of the genace.tcl script :
#
#
# This script works in xmd (EDK3.2 or later) and generates a SystemACE file
# from a bitstream and one or more PowerPC software(ELF) program or Data Files.
#
# The main steps in generating the SystemACE file are :
#   1. Converting a bitstream into an SVF file using iMPACT
#         The SVF file contains the sequence of JTAG instructions 
#         used to configure the FPGA and bring it up. (Done pin going high)
#      NOTE: 
#         In order to create a valid SVF file, the JTAG chain of the 
#         board has to be specified correctly in the "jtag_fpga_position",
#         and "jtag_devices" options at the beginning of this script.
# 
#   2. Converting executables into SVF files using XMD
#         This SVF file contains the JTAG sequence used by XMD to
#         download the ELF executable to internal/external memory
#         through the JTAG debug port of the PowerPC on the Virtex2Pro or
#         through the MDM debug port of Microblaze
#      NOTE: 
#         (i) This step assumes that the FPGA was configured with a 
#         bitstream containing a PowerPC/Microblaze hardware system in which
#         the JTAG debug port has been connected to the FPGA JTAG pins 
#         using the JTAGPPC or Microblaze hardware system with opb_mdm.
#         (ii) In order to create a valid SVF file, 
#         the position of the PowerPC/Microblaze and the JTAG chain of 
#         the board has to be specified correctly in the 
#         "xmd_options" at the beginning of this script. Refer the 
#         XMD documentation for more information about these options.
#             NOTE on NOTE: 
#                These options could be used to create ACE files that would 
#                directly write to PPC I/DCaches, etc
#   3. Converting data/binary into SVF files using XMD
#   4. Concatenating the SVF files from step 1 and 2
#   5. Generating a SystemACE file from the combined SVF file using iMPACT
#
# IMPORTANT NOTE: 
#   The JTAG chain options for step 1,2 and 3 have to be specified based on 
#   the relative position of each device in the JTAG chain from 
#   the SystemACE controller.
#


#---------------------------------------------------------------------
#
#  Helper Procedures to convert bit->svf, elf->svf, data->svf  and svf->ave
#
#---------------------------------------------------------------------

proc impact_bit2svf { bitfile jtag_fpga_position jtag_devices } {

    set svffile "[file rootname $bitfile].svf"
    set script [open "bit2svf.scr" "w"]
    puts $script "setmode -bs"
    puts $script "setCable -p svf -file $svffile"
    
    set devicePos 0
    foreach device $jtag_devices {
	incr devicePos 
	if { $devicePos != $jtag_fpga_position } {
	    puts $script "addDevice -p $devicePos -part $device"
	} else {
	    puts $script "addDevice -p $jtag_fpga_position -file $bitfile"
	}
    }
    puts $script "program -p $jtag_fpga_position"
    puts $script "quit"
    close $script

    puts "\n############################################################"
    puts "Converting Bitstream '$bitfile' to SVF file '$svffile'"
    puts "Executing 'impact -batch bit2svf.scr'"
    if { [catch {exec impact -batch bit2svf.scr} msg] } {
	if { ![string match "*Programmed successfully.*" $msg] } {
	    puts $msg
	    error "ERROR in SVF file generation"
	}
    }
    return
}

proc xmd_elf2svf { target_type elffile xmd_options } {
    set svffile "[file rootname $elffile].svf"
    puts "\n############################################################"
    puts "Converting ELF file '$elffile' to SVF file '$svffile'"

    set tgt 0
    if { $target_type == "ppc_hw" } {
	set a "xconnect ppc hw -cable type xilinx_svffile fname $svffile $xmd_options"
    } else {
	set a "xconnect mb mdm -cable type xilinx_svffile fname $svffile $xmd_options"
    }
    if { [catch {set tgt [eval_xmd_cmd $a]} retval] } {
	puts "$retval"
	error "ERROR: Unable to create SVF file '$svffile' for ELF file : $elffile"
    }

    xdebugconfig $tgt -reset_on_run disable
    xdownload $tgt $elffile

    # Fix for PowerPC CPU errata 212/213 on Virtex4. Causes erroneous data to be loaded when data
    # cache is loaded. Workaround is to set 1 and 3 bits of CCR0 
    if { $target_type == "ppc_hw" } {
	xwreg $tgt 68 0x50700000
    }

    xdisconnect $tgt
    xdisconnect -cable
    return
}

proc xmd_data2svf { target_type dfile load_addr xmd_options } {
    set svffile "[file rootname $dfile].svf"
    puts "\n############################################################"
    puts "Converting Data file '$dfile' to SVF file '$svffile'"

    set tgt 0
    if { $target_type == "ppc_hw" } {
	set a "xconnect ppc hw -cable type xilinx_svffile fname $svffile $xmd_options"
    } else {
	set a "xconnect mb mdm -cable type xilinx_svffile fname $svffile $xmd_options"
    }
    if { [catch {set tgt [eval_xmd_cmd $a]} retval] } {
	puts "$retval"
	error "ERROR: Unable to create SVF file '$svffile' for Data file : $dfile"
    }

    xdebugconfig $tgt -reset_on_run disable
    xdownload $tgt -data $dfile $load_addr

    xdisconnect $tgt
    xdisconnect -cable
    return
}

proc write_swsuffix { target_type elffile xmd_options saddr } {
    set svffile "[file rootname $elffile].svf"
    puts "\n############################################################"
    puts "Writing Processor JTAG \"continue\" command to SVF file '$svffile'"

    set tgt 0
    if { $target_type == "ppc_hw" } {
	set a "xconnect ppc hw -cable type xilinx_svffile fname $svffile $xmd_options"
    } else {
	set a "xconnect mb mdm -cable type xilinx_svffile fname $svffile $xmd_options"
    }
    if { [catch {set tgt [eval_xmd_cmd $a]} retval] } {
	puts "$retval"
	error "ERROR: Unable to create SVF file '$svffile' for ELF file : $elffile"
    }
    xdebugconfig $tgt -reset_on_run disable

    xwreg $tgt 32 [format "0x%x" $saddr]
    xcontinue $tgt
    xdisconnect $tgt
    xdisconnect -cable
    return
}

proc impact_svf2ace { acefile } {
    set svffile "[file rootname $acefile].svf"
    set script [open "svf2ace.scr" "w"]
    puts $script "svf2ace -wtck -d -m 16776192 -i $svffile -o $acefile"
    puts $script quit
    close $script
    
    puts "\n############################################################"
    puts "Converting SVF file '$svffile' to SystemACE file '$acefile'"    
    puts "Executing 'impact -batch svf2ace.scr'"
    catch {exec impact -batch svf2ace.scr}
    return
}

proc write_swprefix { target_type svffile xmd_options final_svf } {
    set tgt 0
    if { $target_type == "ppc_hw" } {
	set a "xconnect ppc hw -cable type xilinx_svffile fname $svffile $xmd_options"
    } else {
	set a "xconnect mb mdm -cable type xilinx_svffile fname $svffile $xmd_options"
    }
    if { [catch {set tgt [eval_xmd_cmd $a]} retval] } {
	puts "$retval"
	error "ERROR: Failed to Write SW Prefix for SVF generation"
    }
    xreset $tgt -processor

    xdisconnect $tgt
    xdisconnect -cable

    puts $final_svf "
//======================================================= 
// 
STATE RESET IDLE; 
RUNTEST 100000 TCK; 
HIR 0 ; 
HDR 0 ; 
TIR 0 ; 
TDR 0 ; 
// Reset the System
//======================================================="

    set prefixsvf [open $svffile "r"]
    fcopy $prefixsvf $final_svf
    close $prefixsvf

    puts $final_svf "
//======================================================= 
// 
STATE RESET IDLE; 
RUNTEST 100000 TCK; 
HIR 0 ; 
HDR 0 ; 
TIR 0 ; 
TDR 0 ; 
// Start ELF downloading here 
//======================================================="
    return
}

proc write_hwprefix { svffile use_jprog fpga_irlength } {
    puts $svffile "
//======================================================= 
// Initial JTAG Reset
// 
HIR 0 ; 
TIR 0 ; 
TDR 0 ; 
HDR 0 ; 
STATE RESET IDLE; 
//======================================================="
    if { $fpga_irlength <= 5 } {
	return 
    }
    if { $use_jprog == "true" } {
	set jprog 3fcb
	set smask 3fff
	switch -- $fpga_irlength {
	    6 {
		set jprog 0b
		set smask 3f
	    }
	    10 {
		set jprog 3cb
		set smask 3ff
	    }
	    14 {
		set jprog 3fcb
		set smask 3fff
	    }
	}
	puts $svffile "
// For runtime reconfiguration, using 'jprog_b' instruction
// Loading device with 'jprog_b' instruction. 
SIR $fpga_irlength TDI ($jprog) SMASK ($smask) ; 
RUNTEST 1000 TCK ;
// end of jprog_b 
// NOTE - The following delay will have to be modified in genace.tcl 
//        for non-ML300, non-xc2vp7 devices. The frame information is
//        available in <Device> user guide (Configration Details)
// Send into bypass and idle until program latency is over 
//   4 us per frame.  XC2VP7 is 1320 frames = 5280 us 
//   @maximum TCK freq 33 MHz = 174240 cycles 
// Setting it to max value.. XC2VP100 = 3500 frames
SIR $fpga_irlength TDI ($smask) SMASK ($smask) ; 
RUNTEST 462000 TCK ; 
//======================================================="
    }
    return
}


proc write_prefix { svffile argv } {
    puts $svffile "
//======================================================= 
//======================================================= 
//  SVF file automatically created using XMD + genace.tcl
//  Commandline : xmd genace.tcl $argv
//  Date/Time : [clock format [clock seconds]]
//======================================================= 
//======================================================= 
"
    return
}

proc get_elf_startaddr { target_type elffile } {
    if { ![file exists $elffile] } {
	puts "Error: File $elffile not found\n"
	return -code error
    }

    if { $target_type == "ppc_hw" } {
	if { [catch {set saddr [exec powerpc-eabi-objdump -x $elffile | grep -w "start address"]} err] } {
	    puts "Error: Executable $elffile does not contain start address.."
	    return -code error
	}
    } else {
	if { [catch {set saddr [exec mb-objdump -x $elffile | grep -w "start address"]} err] } {
	    puts "Error: Executable $elffile does not contain start address.."
	    return -code error
	}
    }
    set saddr_list [string trimleft $saddr]
    set saddr [lindex $saddr_list end]
    return $saddr
}


#---------------------------------------------------------------------
#
# Procedures to Generate SVF file
#
#---------------------------------------------------------------------

#######################################################################
#  Procedure to generate the SVF file from .bit 
#######################################################################
proc genace_hw { } {
    global param 
    global fpga_irlength final_svf
    
    set acefile $param(ace)

    # Convert bit->svf file
    set bitfile $param(hw)
    if { $bitfile != "" } {
	if { ![file readable $bitfile] } {
	    error "Unable to open Bitstream file : $bitfile"
	}

	write_hwprefix $final_svf $param(jprog) $fpga_irlength
	if { ![string match "[file extension $bitfile]" ".svf"] } {
	    # Generate the .svf file for .bit file
	    impact_bit2svf $bitfile $param(jtag_fpga_position) $param(jtag_devices)
	}
	set bitsvf [open "[file rootname $bitfile].svf" "r"]
	puts "\nCopying [file rootname $bitfile].svf File to \
	    [file rootname $acefile].svf File\n" 
	fcopy $bitsvf $final_svf
	close $bitsvf
    }
}

#######################################################################
#  Procedure to generate the SVF file from .elf/data file 
#######################################################################
proc genace_sw_download { } {
    global param
    global final_svf

    set acefile $param(ace)

    write_swprefix $param(target) "sw_prefix.svf" $param(xmd_options) $final_svf

    # Convert data->svf files
    set data_files $param(data)
    if { [llength $data_files] > 0 } {
	set i 0
	while { $i < [llength $data_files] } {
	    set dfile [lindex $data_files $i]
	    set laddr [lindex $data_files [incr i 1]]
	    incr i 1
	    if { ![file readable $dfile] } {
		error "Unable to open data file : $dfile"
	    }

	    if { ![string match "[file extension $dfile]" ".svf"] } {
		# Generate the .svf file for data file
		xmd_data2svf $param(target) $dfile $laddr $param(xmd_options)
	    }
	    set datasvf [open "[file rootname $dfile].svf" "r"]
	    puts $final_svf "\n// Starting Download of Data file : $dfile\n"
	    puts "\nCopying [file rootname $dfile].svf File to \
	    [file rootname $acefile].svf File\n" 
	    fcopy $datasvf $final_svf
	    close $datasvf
	}
    }

    # Convert elf->svf files.
    set elf_files $param(sw)
    if { [llength $elf_files] > 0 } {
	foreach elf $elf_files { 
	    if { ![file readable $elf] } {
		error "Unable to open executable file : $elf"
	    }

	    if { ![string match "[file extension $elf]" ".svf"] } {
		# Generate the .svf file for .elf file
		xmd_elf2svf $param(target) $elf $param(xmd_options)
	    }
	    set elfsvf [open "[file rootname $elf].svf" "r"]
	    puts $final_svf "\n// Starting Download of ELF file : $elf\n"
	    puts "\nCopying [file rootname $elf].svf File to \
	    [file rootname $acefile].svf File\n" 
	    fcopy $elfsvf $final_svf
	    close $elfsvf

	}
    }
}

#######################################################################
#  Procedure to generate the SVF file to run processor
#  saddr - is the PC value of Processor Execution
#######################################################################
proc genace_sw_run { saddr } {
    global param
    global final_svf

    write_swsuffix $param(target) "sw_suffix.elf" $param(xmd_options) $saddr
    # Generate code to execute the program downloaded
    set suffixsvf [open "sw_suffix.svf" "r"]
    puts $final_svf "\n// Issuing Run command to PowerPC to start execution\n"
    fcopy $suffixsvf $final_svf
    close $suffixsvf
}


#---------------------------------------------------------------------
#
# Procedures to parse GenACE Options
#
#---------------------------------------------------------------------

#######################################################################
# Proc to parse genace option file options
#######################################################################
proc parse_genace_optfile { optfilename } {
    global param cpu_nr cpu_debugdevice cpu_target cpu_elf cpu_data cpu_startaddr

    if { ![file readable $optfilename] } {
	error "Unable to open GenACE option file : $optfilename"
    }
    set optfile [open "$optfilename" "r"]
    puts "Using GenACE option file : $optfilename"

    set debugdevice 1
    set configdevice 1
    set first_cpu 1
    set ncpu 1
    set cpu_nr($ncpu) 1
    while { [gets $optfile optline] != -1 } {
	set llist [concat $optline]
	set genace_opt [lindex $llist 0]
	# Skip Comments
	if { [string match -nocase "#*" $genace_opt] } {
	      continue 
	}
	if { [string match -nocase "" $genace_opt] } {
	      continue 
	}
	switch -- $genace_opt {
	    -jprog {
		#
		# Partial Configuration
		set param(jprog) "true"
	    }
	    -hw {
		#
		# Bitstream
		set param(hw) [lindex $llist 1]
	    }
	    -board {
		#
		# Board Type
		set param(board) [lindex $llist 1]
	    }
	    -ace {
		#
		# Output ACE file name
		set param(ace) [lindex $llist 1]
	    }
	    -configdevice {
		#
		# Board Jtag Chain information - Get the JTAG Devices Name from this option
		if { ![info exists param(jtag_chain_options)] } {
		    set param(jtag_chain_options) $llist
		}
		set param(jtag_chain_options) [concat $param(jtag_chain_options) [lrange $llist 0 end]]
		set i 1
		while { $i < [llength $llist] } {
		    if {[string match -nocase "partname" [lindex $llist $i]]} {
			set param(jtag_devices) [concat $param(jtag_devices) [lindex $llist [expr $i+1]]]
			break
		    }
		    incr i 2
		}
		if { $i >= [llength $llist] } {
		    error "Device partname not specifed in -configdevice option"
		}
		set configdevice 0
	    }
	    -debugdevice {
		#
		# FPGA position in the Chain. Also the CPU Nr of the processor
		set i 1
		while { $i < [llength $llist] } {
		    if {[string match -nocase "devicenr" [lindex $llist $i]]} {
			set jtag_fpga_position [lindex $llist [expr $i+1]]
			if { $param(jtag_fpga_position) == "" } {
			    set param(jtag_fpga_position) $jtag_fpga_position
			    set debugdevice 0
			} else {
			    if { $param(jtag_fpga_position) != $jtag_fpga_position } {
				error "JTAG FPGA position($jtag_fpga_position) is INVALID\n Previous value specified was $param(jtag_fpga_position)"
			    }
			}
		    }
		    #
		    # CPU Nr of the processor
		    if {[string match -nocase "cpunr" [lindex $llist $i]]} {
			set cpunr [lindex $llist [expr $i+1]]
			if { !$first_cpu } {
			    incr ncpu 1
			}
			set first_cpu 0
			set cpu_nr($ncpu) $cpunr
		    }
		    incr i 2
		}
		set cpu_debugdevice($ncpu) $llist
	    }
	    -jtag_fpga_position {
		#
		# FPGA position in the Chain.
		set jtag_fpga_position [lindex $llist 1]
		if { $param(jtag_fpga_position) == "" } {
		    set param(jtag_fpga_position) $jtag_fpga_position
		    set debugdevice 0
		} else {
		    if { $param(jtag_fpga_position) != $jtag_fpga_position } {
			error "JTAG FPGA position($jtag_fpga_position) is INVALID\n Previous value specified was $param(jtag_fpga_position)"
		    }
		}
	    }
	    -target {
		#
		# Processor Target Type (ppc, mdm)
		set cpu_target($ncpu) [lindex $llist 1]
	    }
	    -elf {
		#
		# ELF files to write for the Processor
		if { ![info exists cpu_elf($ncpu)] } {
		    set cpu_elf($ncpu) [list]
		}
		set cpu_elf($ncpu) [concat $cpu_elf($ncpu) [lrange $llist 1 end]]
	    }
	    -data {
		#
		# Data files & Start Address to write for the Processor
		if { ![info exists cpu_data($ncpu)] } {
		    set cpu_data($ncpu) [list]
		}
		set data_ip [llength $llist]
		incr data_ip -1
		if { [expr $data_ip % 2] } {
		    error "Incorrect -data option. Check if the Load Address is Specified"
		}
		set cpu_data($ncpu) [concat $cpu_data($ncpu) [lrange $llist 1 end]]
	    }
	    -start_address {
		#
		# Address to Start Program Execution
		set cpu_startaddr($ncpu) [lrange $llist 1 end]
	    }
	    default {
		error "Unknown option $genace_opt"
	    }
	}
    }
    close $optfile
    set param(ncpu) $ncpu

    set i 1
    while { $i <= $param(ncpu) } {
	set cpunr $cpu_nr($i)
	if { ![info exists cpu_target($i)] } {
	    puts "Target Type not defined for Processor $cpunr, Using default Target Type ppc_hw"
	    set cpu_target($i) "ppc_hw"
	}
	incr i 1
    }

    if { [string match -nocase $param(board) "user"] && [expr $configdevice || $debugdevice]} {
	error "\[-board user\] option missing either -configdevice or -debugdevice options"
    }
     	
    #puts "\nGenACE Options"
    #puts "Jtag Chain         : $param(jtag_chain_options)"
    #puts "jtag_fpga_position : $param(jtag_fpga_position)"
    #puts "jtag_devices       : $param(jtag_devices)"
    #puts "NCPUs              : $param(ncpu)"
    #set i 1
    #while { $i <= $param(ncpu) } {
    #set cpunr $cpu_nr($i)
    #puts "\nProcessor $cpu_target($i)_$cpu_nr($i) Information"
    #if { [info exists cpu_elf($i)] } {
    #puts "ELF files : $cpu_elf($i)"
    #}
    #if { [info exists cpu_data($i)] } {
    #puts "ELF files : $cpu_data($i)"
    #}
    #incr i 1
    #}
    return
}


#######################################################################
# Proc to parse genace commandline options
#######################################################################
proc parse_genace_options {optc optv} {
    global param cpu_nr cpu_target cpu_elf cpu_data cpu_startaddr

    if {[string match -nocase "-opt" [lindex $optv 0]]} {
	if { [catch {parse_genace_optfile [lindex $optv 1]} err] } {
	    error "(OptFile) $err"
	}	    
	return
    }

    set first_cpu 1
    set ncpu 1
    set cpu_nr($ncpu) 1
    for {set i 0} { $i < $optc } { incr i } {
	set arg [lindex $optv $i]
	switch -- $arg {
	    -jprog { 
		set param(jprog) "true"
	    }
	    -hw  {
		incr i
		set param(hw) [lindex $optv $i]
	    }
	    -board {
		incr i
		set param(board) [lindex $optv $i]
	    }
	    -ace {
		incr i
		set param(ace) [lindex $optv $i]
	    }
	    -target  {
		incr i
		# No check done !!
		set cpu_target($ncpu) [lindex $optv $i] 
	    }
	    -elf {
		incr i
		set next_option_index [lsearch [lrange $optv $i end] "-*"]
		if {$next_option_index == -1 } {
		    set next_option_index $optc
		} else {
		    incr next_option_index $i
		}

		while {$i < $next_option_index} {
		    set elf [lindex $optv $i]
		    incr i
		}
		# go back one arg as outer loop would "incr i" too
		incr i -1 

		if { ![info exists cpu_elf($ncpu)] } {
		    set cpu_elf($ncpu) [list]
		}
		set cpu_elf($ncpu) [concat $cpu_elf($ncpu) $elf]
	    }
	    -data {
		incr i
		set next_option_index [lsearch [lrange $optv $i end] "-*"]
		if {$next_option_index == -1 } {
		    set next_option_index $optc
		} else {
		    incr next_option_index $i
		}
		if { [expr ($next_option_index - $i)%2] != 0 } {
		    error "Missing load address for data file"
		}

		set data [list]
		while {$i < $next_option_index} {
		    set data [concat $data [lrange $optv $i [incr i]]]
		    incr i
		}
		# go back one arg as outer loop would "incr i" too
		incr i -1 

		if { ![info exists cpu_data($ncpu)] } {
		    set cpu_data($ncpu) [list]
		}
		set cpu_data($ncpu) [concat $cpu_data($ncpu) $data]
	    }
	    -start_address {
		incr i
		set cpu_startaddr($ncpu) [lindex $optv $i]
	    }
	    default {
		error "Unknown option $arg"
	    }
	}
    }
    set param(ncpu) $ncpu

    set i 1
    while { $i <= $param(ncpu) } {
	set cpunr $cpu_nr($i)
	if { ![info exists cpu_target($i)] } {
	    puts "Target Type not defined for Processor $cpunr, Using default Target Type ppc_hw"
	    set cpu_target($i) "ppc_hw"
	}
	incr i 1
    }
    return
}

#---------------------------------------------------------------------
#
# Start GenACE 
#
#---------------------------------------------------------------------

puts "\n#######################################################################"
puts "XMD GenACE utility. Generate SystemACE File from bit/elf/data Files"
puts "#######################################################################"


# Platform Check - Solaris NOT Supported
set platform [lindex [array get tcl_platform os] 1]
if { [string match -nocase $platform "SunOS"] } {
    puts "\nERROR : Solaris platform NOT supported by GenACE Utility"
    return
}

# Parse Genace script Options
if { [catch {parse_genace_options $argc $argv} err] } {
    puts "\nCmdline Error: $err"
    puts $usage
    return
}

# Check if either -elf or -hw options are specified 
set i 1
set sw_exists 0
# Used for Filename check - See below
set flist ""
while { $i <= $param(ncpu) } {
    if { [info exists cpu_elf($i)] } {
	set flist [concat $flist $cpu_elf($i)]
	set sw_exists 1
	#break
    }
    if { [info exists cpu_data($i)] } {
	set flist [concat $flist $cpu_data($i)]
	set sw_exists 1
	#break
    }
    incr i 1
}
if { $sw_exists == 0 && $param(hw) == "" } {
    puts "\nERROR : Either a hw bitstream or sw ELF/data file should be provided to generate the ACE file"
    puts $usage
    return
}

# Check if -ace option has been specified
if { $param(ace) == "" } {
    puts "\nERROR : An output ACE file should be specified using the -ace option"
    puts $usage
    return
}

# Check Filenames. BIT/ELF/Data filename prefix should not match ACE filename prefix
# -- Backward Compatibility
set ace_prefix [file rootname $param(ace)]
set flist [concat $param(hw) $flist]
foreach filename $flist {
    set fname_prefix [file rootname $filename]
    if { [string match $ace_prefix $fname_prefix] } {
	puts "\nERROR : Output ACE File($param(ace)) & I/P $filename have same Filename prefix \"$ace_prefix\""
	puts "ERROR : Please provide a different ACE file name\n"
	return
    }    
}


#######################################################################
#
# Actually Start the ACE file generation Process
#
#######################################################################
#silent_mode on
# Get the Board Information - Jtag Chain, FPGA device on the chain.
# For Board Type user - get the board config information from user
set board $param(board)
if { ![string match $board "user"]} {
    set param(jtag_chain_options) [lindex [array get $board "jtag_chain_options"] 1]
    set param(jtag_devices) [lindex [array get $board "jtag_devices"] 1]
    set param(jtag_fpga_position) [lindex [array get $board "jtag_fpga_position"] 1]
}

# Get the Start PC address for each Processor
set i 1
while { $i <= $param(ncpu) } {
    set cpunr $cpu_nr($i)
    if { ![info exists cpu_startaddr($i)] } {
	if { [info exists cpu_elf($i)] } {
	    set elflist $cpu_elf($i)
	    set lastelf [lindex $elflist end]
	    if { [catch {set cpu_startaddr($i) [get_elf_startaddr $cpu_target($i) $lastelf]} err] } {
		puts "\nError: $err"
		return
	    }
	} else {
	    if { [info exists cpu_data($i)] } {
		error "Address to Start Processor Execution Not Specified"
	    }
	}
    }
    incr i 1
}

puts "GenACE Options:"
puts "\tBoard      : $param(board)"
puts "\tJtag Devs  : $param(jtag_devices)"
puts "\tFPGA pos   : $param(jtag_fpga_position)"
puts "\tJPROG      : $param(jprog)"
puts "\tHW File    : $param(hw)"
puts "\tACE File   : $param(ace)"
puts "\tnCPUs      : $param(ncpu)"
set i 1
while { $i <= $param(ncpu) } {
    set cpunr $cpu_nr($i)
    puts "\n\tProcessor $cpu_target($i)_$cpu_nr($i) Information"
    if { ![info exists cpu_debugdevice($i)] } {
	set cpu_debugdevice($i) "-debugdevice devicenr $param(jtag_fpga_position) cpunr $cpu_nr($i)"
    } else {
	if { [lsearch $cpu_debugdevice($i) "devicenr"] == -1 } {
	    set cpu_debugdevice($i) [concat $cpu_debugdevice($i) "devicenr $param(jtag_fpga_position)"]
	}
	if { [lsearch $cpu_debugdevice($i) "cpunr"] == -1 } {
	    set cpu_debugdevice($i) [concat $cpu_debugdevice($i) "cpunr $cpu_nr($i)"]
	}
    }
    puts "\t\tDebug opt : $cpu_debugdevice($i)"
    if { [info exists cpu_elf($i)] } {
	puts "\t\tELF files : $cpu_elf($i)"
    }
    if { [info exists cpu_data($i)] } {
	puts "\t\tData files : $cpu_data($i)"
    }
    if { [info exists cpu_startaddr($i)] } {
	puts "\t\tStart PC Address : $cpu_startaddr($i)"
    }
    incr i 1
}

# Get the irLength of FPGA.
set options_list [concat $param(jtag_chain_options)]
set index $param(jtag_fpga_position)
set i 0
while { $i < [llength $options_list] } {
    if {[string match -nocase "irlength" [lindex $options_list $i]]} {
	incr index -1
	if { $index == 0 } {
	    set fpga_irlength [lindex $options_list [expr $i+1]]
	    break
	}
    }
    incr i 1
}
if { $index > 0 } {
    error "Cannot find FPGA Instr Register Length.. Please check your JTAG options"
}

#
# Open the SVF File
set final_svf [open "[file rootname $param(ace)].svf" "w"]
write_prefix $final_svf $argv

#
# Generate ACE for H/W BitStream
if { $param(hw) != "" } {
    if { [catch {genace_hw} err] } {
	puts "Error: $err"
	return
    }
}

if { $sw_exists } {
    #
    # Generate ACE for S/W files, for each processor
    set i 1
    while { $i <= $param(ncpu) } {
	set cpunr $cpu_nr($i)
	set param(target) $cpu_target($i)
	set param(xmd_options) [concat $param(jtag_chain_options) $cpu_debugdevice($i)]
	if { [info exists cpu_elf($i)] } {
	    set param(sw) $cpu_elf($i)
	}
	if { [info exists cpu_data($i)] } {
	    set param(data) $cpu_data($i)
	}
	if { [catch {genace_sw_download} err] } {
	    puts "Error: $err"
	    return
	}
	incr i 1
    }
    
    #
    # Generate ACE to Run each processor
    set i 1
    while { $i <= $param(ncpu) } {
	set cpunr $cpu_nr($i)
	set param(target) $cpu_target($i)
	set param(xmd_options) [concat $param(jtag_chain_options) $cpu_debugdevice($i)]
	if { [info exists cpu_startaddr($i)] } {
	    if { [catch {genace_sw_run $cpu_startaddr($i)} err] } {
		puts "Error: $err"
		return
	    }
	}
	incr i 1
    }
}

close $final_svf

#
# Convert the SVF -> ACE
impact_svf2ace $param(ace)

puts "\nSystemACE file '$param(ace)' created successfully"
return

