# 
# ProjectNavigator SourceControl export script
#
# This script is generated and executed by ProjectNavigator
# to copy files related to the current project to a
# destination staging area.
#
# The list of files being exported, as controled by
# GUI settings, is placed in the variable export_files.
# Each file will be passed to the procedure CopyOut.  This
# procedure will determine the exact destination, and will
# attempt the file copy if the source and destination are different.
#
# This script is not indended for direct customer editing.
#
# Copyright 2006, Xilinx, Inc.
#
#
# CopyOut -- copy a source file to the staging area, with
#            extra options for files remote (outside of) the
#            project directory.
proc CopyOut { srcfile staging_area copy_option } {
   set report_errors true
   if { $copy_option == "flatten" } {
       set dest [ file join $staging_area [ file tail $srcfile ] ]
   } elseif { $copy_option == "nop" } {
       set dest  $staging_area
       set report_errors false
   } elseif { [ file pathtype $srcfile ] != "relative" } {
       set srcfile2 [ string map {: _} $srcfile ]
       set dest [ file join $staging_area absolute $srcfile2 ]
   } elseif { [ expr { $copy_option == "absremote" } && { [string equal -length 2 $srcfile ".." ] } ] } {
       set dest [ file join $staging_area outside_relative [ string map {.. up} $srcfile ] ]
   } else {
       set srcfile2 [ string map {: _} $srcfile ]
       set dest [ file join $staging_area $srcfile2 ]
   }

   set dest [ file normalize $dest ]
   set src [ file normalize $srcfile ]

   if { [ expr { [ string equal $dest $src ] == 0 } && { [ file exists $src ] } ] } {
      file mkdir [ file dirname $dest ]
      if { [catch { file copy -force $src $dest } ] } {
         if { $report_errors } { puts "Could not copy $src to $dest." }
      }
   }
}

# change to the working directory
set old_working_dir [pwd]
cd [file normalize {/home/brandyn/fpga-image-registration/modules/fetch_stage} ]
set copy_option relative
set staging_area "/home/brandyn/fpga-image-registration/modules/fetch_stage"
set export_files { 
          "../affine_coord_transform/affine_coord_transform.vhd" 
          "../conv_pixel_ordering/conv_pixel_ordering.vhd" 
          "conv_pix_ordering_mem_addr_select_test.vhd" 
          "convert_2d_to_1d_coord.vhd" 
          "fetch_stage.vhd" 
          "fetch_stage_tbw0.tbw" 
          "img1_compute_mem_addr.vhd" 
          "mem_addr_selector.vhd" 
          "pixel_conv_buffer.vhd" 
                 }
foreach file $export_files {
   CopyOut $file $staging_area $copy_option
}
# copy export file to staging area
CopyOut "/home/brandyn/fpga-image-registration/modules/fetch_stage/fetch_stage_import.tcl" "$staging_area" nop
# return back
cd $old_working_dir

