#ChipScope Core Inserter Project File Version 3.0
#Thu Jun 12 21:41:32 GMT-05:00 2008
Project.device.designInputFile=/home/brandyn/fpga-image-registration/modules/image_store_stage/image_store_display_test_cs.ngc
Project.device.designOutputFile=/home/brandyn/fpga-image-registration/modules/image_store_stage/image_store_display_test_cs.ngc
Project.device.deviceFamily=14
Project.device.enableRPMs=true
Project.device.outputDirectory=/home/brandyn/fpga-image-registration/modules/image_store_stage/_ngo
Project.device.useSRL16=true
Project.filter.dimension=19
Project.filter<0>=*data_valid*
Project.filter<10>=*HSYNC*
Project.filter<11>=HSYNC*
Project.filter<12>=*pixel_count*
Project.filter<13>=*cs*
Project.filter<14>=*cs
Project.filter<15>=*mem_addr_reg*
Project.filter<16>=*dvi_gray*
Project.filter<17>=image_store*
Project.filter<18>=image_display*
Project.filter<1>=
Project.filter<2>=*dvi_gray_delay*
Project.filter<3>=*pixel_count_reg*
Project.filter<4>=*vga_timing_generator*
Project.filter<5>=vga_timing_generator*
Project.filter<6>=image_display_fifo_write*
Project.filter<7>=image_display_fifo*
Project.filter<8>=*image_display_mem*
Project.filter<9>=*VSYNC*
Project.icon.boundaryScanChain=1
Project.icon.disableBUFGInsertion=false
Project.icon.enableExtTriggerIn=false
Project.icon.enableExtTriggerOut=false
Project.icon.triggerInPinName=
Project.icon.triggerOutPinName=
Project.unit.dimension=3
Project.unit<0>.clockChannel=clk_intbuf
Project.unit<0>.clockEdge=Rising
Project.unit<0>.dataChannel<0>=MEMORY_ADDR_VALUE<0>
Project.unit<0>.dataChannel<10>=MEMORY_ADDR_VALUE<10>
Project.unit<0>.dataChannel<11>=MEMORY_ADDR_VALUE<11>
Project.unit<0>.dataChannel<12>=MEMORY_ADDR_VALUE<12>
Project.unit<0>.dataChannel<13>=MEMORY_ADDR_VALUE<13>
Project.unit<0>.dataChannel<14>=MEMORY_ADDR_VALUE<14>
Project.unit<0>.dataChannel<15>=MEMORY_ADDR_VALUE<15>
Project.unit<0>.dataChannel<16>=MEMORY_ADDR_VALUE<16>
Project.unit<0>.dataChannel<17>=MEMORY_ADDR_VALUE<17>
Project.unit<0>.dataChannel<18>=MEMORY_ADDR_VALUE<18>
Project.unit<0>.dataChannel<19>=MEMORY_ADDR_VALUE<19>
Project.unit<0>.dataChannel<1>=MEMORY_ADDR_VALUE<1>
Project.unit<0>.dataChannel<20>=MEMORY_READ_VALUE<0>
Project.unit<0>.dataChannel<21>=MEMORY_READ_VALUE<1>
Project.unit<0>.dataChannel<22>=MEMORY_READ_VALUE<2>
Project.unit<0>.dataChannel<23>=MEMORY_READ_VALUE<3>
Project.unit<0>.dataChannel<24>=MEMORY_READ_VALUE<4>
Project.unit<0>.dataChannel<25>=MEMORY_READ_VALUE<5>
Project.unit<0>.dataChannel<26>=MEMORY_READ_VALUE<6>
Project.unit<0>.dataChannel<27>=MEMORY_READ_VALUE<7>
Project.unit<0>.dataChannel<28>=MEMORY_READ_VALUE<8>
Project.unit<0>.dataChannel<29>=MEMORY_WRITE_VALUE<0>
Project.unit<0>.dataChannel<2>=MEMORY_ADDR_VALUE<2>
Project.unit<0>.dataChannel<30>=MEMORY_WRITE_VALUE<1>
Project.unit<0>.dataChannel<31>=MEMORY_WRITE_VALUE<2>
Project.unit<0>.dataChannel<32>=MEMORY_WRITE_VALUE<3>
Project.unit<0>.dataChannel<33>=MEMORY_WRITE_VALUE<4>
Project.unit<0>.dataChannel<34>=MEMORY_WRITE_VALUE<5>
Project.unit<0>.dataChannel<35>=MEMORY_WRITE_VALUE<6>
Project.unit<0>.dataChannel<36>=MEMORY_WRITE_VALUE<7>
Project.unit<0>.dataChannel<37>=MEMORY_WRITE_VALUE<8>
Project.unit<0>.dataChannel<38>=MEMORY_DUMP_DONE_VALUE
Project.unit<0>.dataChannel<39>=mem_read_valid_reg
Project.unit<0>.dataChannel<3>=MEMORY_ADDR_VALUE<3>
Project.unit<0>.dataChannel<40>=cur_state_FSM_FFd1
Project.unit<0>.dataChannel<41>=cur_state_FSM_FFd2
Project.unit<0>.dataChannel<42>=cur_state_FSM_FFd3
Project.unit<0>.dataChannel<43>=pixel_memory_controller_i/cs_b_buf
Project.unit<0>.dataChannel<44>=pixel_memory_controller_i/we_b_buf
Project.unit<0>.dataChannel<45>=image_display_fifo_empty_cs
Project.unit<0>.dataChannel<46>=image_display_fifo_re_cs
Project.unit<0>.dataChannel<47>=image_display_fifo_rst_cs
Project.unit<0>.dataChannel<48>=image_display_stage_i/vga_timing_generator_i/hsync_reg
Project.unit<0>.dataChannel<49>=image_display_stage_i/vga_timing_generator_i/vsync_reg
Project.unit<0>.dataChannel<4>=MEMORY_ADDR_VALUE<4>
Project.unit<0>.dataChannel<50>=image_display_mem_output_valid_cs
Project.unit<0>.dataChannel<51>=image_display_mem_addr_cs<0>
Project.unit<0>.dataChannel<52>=image_display_mem_addr_cs<1>
Project.unit<0>.dataChannel<53>=image_display_mem_addr_cs<2>
Project.unit<0>.dataChannel<54>=image_display_mem_addr_cs<3>
Project.unit<0>.dataChannel<55>=image_display_mem_addr_cs<4>
Project.unit<0>.dataChannel<56>=image_display_mem_addr_cs<5>
Project.unit<0>.dataChannel<57>=image_display_mem_addr_cs<6>
Project.unit<0>.dataChannel<58>=image_display_mem_addr_cs<7>
Project.unit<0>.dataChannel<59>=image_display_mem_addr_cs<8>
Project.unit<0>.dataChannel<5>=MEMORY_ADDR_VALUE<5>
Project.unit<0>.dataChannel<60>=image_display_mem_addr_cs<9>
Project.unit<0>.dataChannel<61>=image_display_fifo_empty_cs
Project.unit<0>.dataChannel<62>=image_display_fifo_read_count0_cs<0>
Project.unit<0>.dataChannel<63>=image_display_fifo_read_count0_cs<1>
Project.unit<0>.dataChannel<64>=image_display_fifo_read_count0_cs<2>
Project.unit<0>.dataChannel<65>=image_display_fifo_read_count0_cs<3>
Project.unit<0>.dataChannel<66>=image_display_fifo_read_count0_cs<4>
Project.unit<0>.dataChannel<67>=image_display_fifo_read_count0_cs<5>
Project.unit<0>.dataChannel<68>=image_display_fifo_read_count0_cs<6>
Project.unit<0>.dataChannel<69>=image_display_fifo_read_count0_cs<7>
Project.unit<0>.dataChannel<6>=MEMORY_ADDR_VALUE<6>
Project.unit<0>.dataChannel<70>=image_display_fifo_read_count0_cs<8>
Project.unit<0>.dataChannel<71>=image_display_fifo_rderr_cs
Project.unit<0>.dataChannel<72>=image_display_fifo_write_count0_cs<0>
Project.unit<0>.dataChannel<73>=image_display_fifo_write_count0_cs<1>
Project.unit<0>.dataChannel<74>=image_display_fifo_write_count0_cs<2>
Project.unit<0>.dataChannel<75>=image_display_fifo_write_count0_cs<3>
Project.unit<0>.dataChannel<76>=image_display_fifo_write_count0_cs<4>
Project.unit<0>.dataChannel<77>=image_display_fifo_write_count0_cs<5>
Project.unit<0>.dataChannel<78>=image_display_fifo_write_count0_cs<6>
Project.unit<0>.dataChannel<79>=image_display_fifo_write_count0_cs<7>
Project.unit<0>.dataChannel<7>=MEMORY_ADDR_VALUE<7>
Project.unit<0>.dataChannel<80>=image_display_fifo_write_count0_cs<8>
Project.unit<0>.dataChannel<8>=MEMORY_ADDR_VALUE<8>
Project.unit<0>.dataChannel<9>=MEMORY_ADDR_VALUE<9>
Project.unit<0>.dataDepth=16384
Project.unit<0>.dataEqualsTrigger=true
Project.unit<0>.dataPortWidth=81
Project.unit<0>.enableGaps=false
Project.unit<0>.enableStorageQualification=true
Project.unit<0>.enableTimestamps=false
Project.unit<0>.timestampDepth=0
Project.unit<0>.timestampWidth=0
Project.unit<0>.triggerChannel<0><0>=MEMORY_ADDR_VALUE<0>
Project.unit<0>.triggerChannel<0><10>=MEMORY_ADDR_VALUE<10>
Project.unit<0>.triggerChannel<0><11>=MEMORY_ADDR_VALUE<11>
Project.unit<0>.triggerChannel<0><12>=MEMORY_ADDR_VALUE<12>
Project.unit<0>.triggerChannel<0><13>=MEMORY_ADDR_VALUE<13>
Project.unit<0>.triggerChannel<0><14>=MEMORY_ADDR_VALUE<14>
Project.unit<0>.triggerChannel<0><15>=MEMORY_ADDR_VALUE<15>
Project.unit<0>.triggerChannel<0><16>=MEMORY_ADDR_VALUE<16>
Project.unit<0>.triggerChannel<0><17>=MEMORY_ADDR_VALUE<17>
Project.unit<0>.triggerChannel<0><18>=MEMORY_ADDR_VALUE<18>
Project.unit<0>.triggerChannel<0><19>=MEMORY_ADDR_VALUE<19>
Project.unit<0>.triggerChannel<0><1>=MEMORY_ADDR_VALUE<1>
Project.unit<0>.triggerChannel<0><20>=MEMORY_READ_VALUE<0>
Project.unit<0>.triggerChannel<0><21>=MEMORY_READ_VALUE<1>
Project.unit<0>.triggerChannel<0><22>=MEMORY_READ_VALUE<2>
Project.unit<0>.triggerChannel<0><23>=MEMORY_READ_VALUE<3>
Project.unit<0>.triggerChannel<0><24>=MEMORY_READ_VALUE<4>
Project.unit<0>.triggerChannel<0><25>=MEMORY_READ_VALUE<5>
Project.unit<0>.triggerChannel<0><26>=MEMORY_READ_VALUE<6>
Project.unit<0>.triggerChannel<0><27>=MEMORY_READ_VALUE<7>
Project.unit<0>.triggerChannel<0><28>=MEMORY_READ_VALUE<8>
Project.unit<0>.triggerChannel<0><29>=MEMORY_WRITE_VALUE<0>
Project.unit<0>.triggerChannel<0><2>=MEMORY_ADDR_VALUE<2>
Project.unit<0>.triggerChannel<0><30>=MEMORY_WRITE_VALUE<1>
Project.unit<0>.triggerChannel<0><31>=MEMORY_WRITE_VALUE<2>
Project.unit<0>.triggerChannel<0><32>=MEMORY_WRITE_VALUE<3>
Project.unit<0>.triggerChannel<0><33>=MEMORY_WRITE_VALUE<4>
Project.unit<0>.triggerChannel<0><34>=MEMORY_WRITE_VALUE<5>
Project.unit<0>.triggerChannel<0><35>=MEMORY_WRITE_VALUE<6>
Project.unit<0>.triggerChannel<0><36>=MEMORY_WRITE_VALUE<7>
Project.unit<0>.triggerChannel<0><37>=MEMORY_WRITE_VALUE<8>
Project.unit<0>.triggerChannel<0><38>=MEMORY_DUMP_DONE_VALUE
Project.unit<0>.triggerChannel<0><39>=mem_read_valid_reg
Project.unit<0>.triggerChannel<0><3>=MEMORY_ADDR_VALUE<3>
Project.unit<0>.triggerChannel<0><40>=cur_state_FSM_FFd1
Project.unit<0>.triggerChannel<0><41>=cur_state_FSM_FFd2
Project.unit<0>.triggerChannel<0><42>=cur_state_FSM_FFd3
Project.unit<0>.triggerChannel<0><43>=pixel_memory_controller_i/cs_b_buf
Project.unit<0>.triggerChannel<0><44>=pixel_memory_controller_i/we_b_buf
Project.unit<0>.triggerChannel<0><45>=image_display_fifo_empty_cs
Project.unit<0>.triggerChannel<0><46>=image_display_fifo_re_cs
Project.unit<0>.triggerChannel<0><47>=image_display_fifo_rst_cs
Project.unit<0>.triggerChannel<0><48>=image_display_stage_i/vga_timing_generator_i/hsync_reg
Project.unit<0>.triggerChannel<0><49>=image_display_stage_i/vga_timing_generator_i/vsync_reg
Project.unit<0>.triggerChannel<0><4>=MEMORY_ADDR_VALUE<4>
Project.unit<0>.triggerChannel<0><50>=image_display_mem_output_valid_cs
Project.unit<0>.triggerChannel<0><51>=image_display_mem_addr_cs<0>
Project.unit<0>.triggerChannel<0><52>=image_display_mem_addr_cs<1>
Project.unit<0>.triggerChannel<0><53>=image_display_mem_addr_cs<2>
Project.unit<0>.triggerChannel<0><54>=image_display_mem_addr_cs<3>
Project.unit<0>.triggerChannel<0><55>=image_display_mem_addr_cs<4>
Project.unit<0>.triggerChannel<0><56>=image_display_mem_addr_cs<5>
Project.unit<0>.triggerChannel<0><57>=image_display_mem_addr_cs<6>
Project.unit<0>.triggerChannel<0><58>=image_display_mem_addr_cs<7>
Project.unit<0>.triggerChannel<0><59>=image_display_mem_addr_cs<8>
Project.unit<0>.triggerChannel<0><5>=MEMORY_ADDR_VALUE<5>
Project.unit<0>.triggerChannel<0><60>=image_display_mem_addr_cs<9>
Project.unit<0>.triggerChannel<0><61>=image_display_fifo_empty_cs
Project.unit<0>.triggerChannel<0><62>=image_display_fifo_read_count0_cs<0>
Project.unit<0>.triggerChannel<0><63>=image_display_fifo_read_count0_cs<1>
Project.unit<0>.triggerChannel<0><64>=image_display_fifo_read_count0_cs<2>
Project.unit<0>.triggerChannel<0><65>=image_display_fifo_read_count0_cs<3>
Project.unit<0>.triggerChannel<0><66>=image_display_fifo_read_count0_cs<4>
Project.unit<0>.triggerChannel<0><67>=image_display_fifo_read_count0_cs<5>
Project.unit<0>.triggerChannel<0><68>=image_display_fifo_read_count0_cs<6>
Project.unit<0>.triggerChannel<0><69>=image_display_fifo_read_count0_cs<7>
Project.unit<0>.triggerChannel<0><6>=MEMORY_ADDR_VALUE<6>
Project.unit<0>.triggerChannel<0><70>=image_display_fifo_read_count0_cs<8>
Project.unit<0>.triggerChannel<0><71>=image_display_fifo_rderr_cs
Project.unit<0>.triggerChannel<0><72>=image_display_fifo_write_count0_cs<0>
Project.unit<0>.triggerChannel<0><73>=image_display_fifo_write_count0_cs<1>
Project.unit<0>.triggerChannel<0><74>=image_display_fifo_write_count0_cs<2>
Project.unit<0>.triggerChannel<0><75>=image_display_fifo_write_count0_cs<3>
Project.unit<0>.triggerChannel<0><76>=image_display_fifo_write_count0_cs<4>
Project.unit<0>.triggerChannel<0><77>=image_display_fifo_write_count0_cs<5>
Project.unit<0>.triggerChannel<0><78>=image_display_fifo_write_count0_cs<6>
Project.unit<0>.triggerChannel<0><79>=image_display_fifo_write_count0_cs<7>
Project.unit<0>.triggerChannel<0><7>=MEMORY_ADDR_VALUE<7>
Project.unit<0>.triggerChannel<0><80>=image_display_fifo_write_count0_cs<8>
Project.unit<0>.triggerChannel<0><8>=MEMORY_ADDR_VALUE<8>
Project.unit<0>.triggerChannel<0><9>=MEMORY_ADDR_VALUE<9>
Project.unit<0>.triggerConditionCountWidth=0
Project.unit<0>.triggerMatchCount<0>=1
Project.unit<0>.triggerMatchCountWidth<0><0>=0
Project.unit<0>.triggerMatchType<0><0>=0
Project.unit<0>.triggerPortCount=1
Project.unit<0>.triggerPortIsData<0>=true
Project.unit<0>.triggerPortWidth<0>=81
Project.unit<0>.triggerSequencerLevels=16
Project.unit<0>.triggerSequencerType=1
Project.unit<0>.type=ilapro
Project.unit<1>.clockChannel=VGA_PIXEL_CLK_BUFGP
Project.unit<1>.clockEdge=Rising
Project.unit<1>.dataChannel<0>=VGA_HSYNC_IBUF
Project.unit<1>.dataChannel<10>=image_store_stage_i/vga_timing_decode_i/data_valid_reg
Project.unit<1>.dataChannel<11>=image_store_stage_i/vga_timing_decode_i/hcount<0>
Project.unit<1>.dataChannel<12>=image_store_stage_i/vga_timing_decode_i/hcount<1>
Project.unit<1>.dataChannel<13>=image_store_stage_i/vga_timing_decode_i/hcount<2>
Project.unit<1>.dataChannel<14>=image_store_stage_i/vga_timing_decode_i/hcount<3>
Project.unit<1>.dataChannel<15>=image_store_stage_i/vga_timing_decode_i/hcount<4>
Project.unit<1>.dataChannel<16>=image_store_stage_i/vga_timing_decode_i/hcount<5>
Project.unit<1>.dataChannel<17>=image_store_stage_i/vga_timing_decode_i/hcount<6>
Project.unit<1>.dataChannel<18>=image_store_stage_i/vga_timing_decode_i/hcount<7>
Project.unit<1>.dataChannel<19>=image_store_stage_i/vga_timing_decode_i/hcount<8>
Project.unit<1>.dataChannel<1>=VGA_VSYNC_IBUF
Project.unit<1>.dataChannel<20>=image_store_stage_i/vga_timing_decode_i/hcount<9>
Project.unit<1>.dataChannel<21>=image_store_stage_i/vga_timing_decode_i/hcount<10>
Project.unit<1>.dataChannel<22>=image_store_stage_i/vga_timing_decode_i/vcount<0>
Project.unit<1>.dataChannel<23>=image_store_stage_i/vga_timing_decode_i/vcount<1>
Project.unit<1>.dataChannel<24>=image_store_stage_i/vga_timing_decode_i/vcount<2>
Project.unit<1>.dataChannel<25>=image_store_stage_i/vga_timing_decode_i/vcount<3>
Project.unit<1>.dataChannel<26>=image_store_stage_i/vga_timing_decode_i/vcount<4>
Project.unit<1>.dataChannel<27>=image_store_stage_i/vga_timing_decode_i/vcount<5>
Project.unit<1>.dataChannel<28>=image_store_stage_i/vga_timing_decode_i/vcount<6>
Project.unit<1>.dataChannel<29>=image_store_stage_i/vga_timing_decode_i/vcount<7>
Project.unit<1>.dataChannel<2>=VGA_Y_GREEN_0_IBUF
Project.unit<1>.dataChannel<30>=image_store_stage_i/vga_timing_decode_i/vcount<8>
Project.unit<1>.dataChannel<31>=image_store_stage_i/vga_timing_decode_i/vcount<9>
Project.unit<1>.dataChannel<32>=image_store_stage_i/vga_timing_decode_i/vcount<10>
Project.unit<1>.dataChannel<33>=image_store_fifo_empty
Project.unit<1>.dataChannel<34>=image_store_stage_i/vga_data_valid_buf
Project.unit<1>.dataChannel<35>=image_store_stage_i/mem_addr_reg<0>
Project.unit<1>.dataChannel<36>=image_store_stage_i/mem_addr_reg<1>
Project.unit<1>.dataChannel<37>=image_store_stage_i/mem_addr_reg<2>
Project.unit<1>.dataChannel<38>=image_store_stage_i/mem_addr_reg<3>
Project.unit<1>.dataChannel<39>=image_store_stage_i/mem_addr_reg<4>
Project.unit<1>.dataChannel<3>=VGA_Y_GREEN_1_IBUF
Project.unit<1>.dataChannel<40>=image_store_stage_i/mem_addr_reg<5>
Project.unit<1>.dataChannel<41>=image_store_stage_i/mem_addr_reg<6>
Project.unit<1>.dataChannel<42>=image_store_stage_i/mem_addr_reg<7>
Project.unit<1>.dataChannel<43>=image_store_stage_i/mem_addr_reg<8>
Project.unit<1>.dataChannel<44>=image_store_stage_i/mem_addr_reg<9>
Project.unit<1>.dataChannel<45>=image_store_stage_i/mem_addr_reg<10>
Project.unit<1>.dataChannel<46>=image_store_stage_i/mem_addr_reg<11>
Project.unit<1>.dataChannel<47>=image_store_stage_i/mem_addr_reg<12>
Project.unit<1>.dataChannel<48>=image_store_stage_i/mem_addr_reg<13>
Project.unit<1>.dataChannel<49>=image_store_stage_i/mem_addr_reg<14>
Project.unit<1>.dataChannel<4>=VGA_Y_GREEN_2_IBUF
Project.unit<1>.dataChannel<50>=image_store_stage_i/mem_addr_reg<15>
Project.unit<1>.dataChannel<51>=image_store_stage_i/mem_addr_reg<16>
Project.unit<1>.dataChannel<52>=image_store_stage_i/mem_addr_reg<17>
Project.unit<1>.dataChannel<53>=image_store_stage_i/mem_addr_reg<18>
Project.unit<1>.dataChannel<54>=image_store_stage_i/mem_addr_reg<19>
Project.unit<1>.dataChannel<5>=VGA_Y_GREEN_3_IBUF
Project.unit<1>.dataChannel<6>=VGA_Y_GREEN_4_IBUF
Project.unit<1>.dataChannel<7>=VGA_Y_GREEN_5_IBUF
Project.unit<1>.dataChannel<8>=VGA_Y_GREEN_6_IBUF
Project.unit<1>.dataChannel<9>=VGA_Y_GREEN_7_IBUF
Project.unit<1>.dataDepth=4096
Project.unit<1>.dataEqualsTrigger=true
Project.unit<1>.dataPortWidth=55
Project.unit<1>.enableGaps=false
Project.unit<1>.enableStorageQualification=true
Project.unit<1>.enableTimestamps=false
Project.unit<1>.timestampDepth=0
Project.unit<1>.timestampWidth=0
Project.unit<1>.triggerChannel<0><0>=VGA_HSYNC_IBUF
Project.unit<1>.triggerChannel<0><10>=image_store_stage_i/vga_timing_decode_i/data_valid_reg
Project.unit<1>.triggerChannel<0><11>=image_store_stage_i/vga_timing_decode_i/hcount<0>
Project.unit<1>.triggerChannel<0><12>=image_store_stage_i/vga_timing_decode_i/hcount<1>
Project.unit<1>.triggerChannel<0><13>=image_store_stage_i/vga_timing_decode_i/hcount<2>
Project.unit<1>.triggerChannel<0><14>=image_store_stage_i/vga_timing_decode_i/hcount<3>
Project.unit<1>.triggerChannel<0><15>=image_store_stage_i/vga_timing_decode_i/hcount<4>
Project.unit<1>.triggerChannel<0><16>=image_store_stage_i/vga_timing_decode_i/hcount<5>
Project.unit<1>.triggerChannel<0><17>=image_store_stage_i/vga_timing_decode_i/hcount<6>
Project.unit<1>.triggerChannel<0><18>=image_store_stage_i/vga_timing_decode_i/hcount<7>
Project.unit<1>.triggerChannel<0><19>=image_store_stage_i/vga_timing_decode_i/hcount<8>
Project.unit<1>.triggerChannel<0><1>=VGA_VSYNC_IBUF
Project.unit<1>.triggerChannel<0><20>=image_store_stage_i/vga_timing_decode_i/hcount<9>
Project.unit<1>.triggerChannel<0><21>=image_store_stage_i/vga_timing_decode_i/hcount<10>
Project.unit<1>.triggerChannel<0><22>=image_store_stage_i/vga_timing_decode_i/vcount<0>
Project.unit<1>.triggerChannel<0><23>=image_store_stage_i/vga_timing_decode_i/vcount<1>
Project.unit<1>.triggerChannel<0><24>=image_store_stage_i/vga_timing_decode_i/vcount<2>
Project.unit<1>.triggerChannel<0><25>=image_store_stage_i/vga_timing_decode_i/vcount<3>
Project.unit<1>.triggerChannel<0><26>=image_store_stage_i/vga_timing_decode_i/vcount<4>
Project.unit<1>.triggerChannel<0><27>=image_store_stage_i/vga_timing_decode_i/vcount<5>
Project.unit<1>.triggerChannel<0><28>=image_store_stage_i/vga_timing_decode_i/vcount<6>
Project.unit<1>.triggerChannel<0><29>=image_store_stage_i/vga_timing_decode_i/vcount<7>
Project.unit<1>.triggerChannel<0><2>=VGA_Y_GREEN_0_IBUF
Project.unit<1>.triggerChannel<0><30>=image_store_stage_i/vga_timing_decode_i/vcount<8>
Project.unit<1>.triggerChannel<0><31>=image_store_stage_i/vga_timing_decode_i/vcount<9>
Project.unit<1>.triggerChannel<0><32>=image_store_stage_i/vga_timing_decode_i/vcount<10>
Project.unit<1>.triggerChannel<0><33>=image_store_fifo_empty
Project.unit<1>.triggerChannel<0><34>=image_store_stage_i/vga_data_valid_buf
Project.unit<1>.triggerChannel<0><35>=image_store_stage_i/mem_addr_reg<0>
Project.unit<1>.triggerChannel<0><36>=image_store_stage_i/mem_addr_reg<1>
Project.unit<1>.triggerChannel<0><37>=image_store_stage_i/mem_addr_reg<2>
Project.unit<1>.triggerChannel<0><38>=image_store_stage_i/mem_addr_reg<3>
Project.unit<1>.triggerChannel<0><39>=image_store_stage_i/mem_addr_reg<4>
Project.unit<1>.triggerChannel<0><3>=VGA_Y_GREEN_1_IBUF
Project.unit<1>.triggerChannel<0><40>=image_store_stage_i/mem_addr_reg<5>
Project.unit<1>.triggerChannel<0><41>=image_store_stage_i/mem_addr_reg<6>
Project.unit<1>.triggerChannel<0><42>=image_store_stage_i/mem_addr_reg<7>
Project.unit<1>.triggerChannel<0><43>=image_store_stage_i/mem_addr_reg<8>
Project.unit<1>.triggerChannel<0><44>=image_store_stage_i/mem_addr_reg<9>
Project.unit<1>.triggerChannel<0><45>=image_store_stage_i/mem_addr_reg<10>
Project.unit<1>.triggerChannel<0><46>=image_store_stage_i/mem_addr_reg<11>
Project.unit<1>.triggerChannel<0><47>=image_store_stage_i/mem_addr_reg<12>
Project.unit<1>.triggerChannel<0><48>=image_store_stage_i/mem_addr_reg<13>
Project.unit<1>.triggerChannel<0><49>=image_store_stage_i/mem_addr_reg<14>
Project.unit<1>.triggerChannel<0><4>=VGA_Y_GREEN_2_IBUF
Project.unit<1>.triggerChannel<0><50>=image_store_stage_i/mem_addr_reg<15>
Project.unit<1>.triggerChannel<0><51>=image_store_stage_i/mem_addr_reg<16>
Project.unit<1>.triggerChannel<0><52>=image_store_stage_i/mem_addr_reg<17>
Project.unit<1>.triggerChannel<0><53>=image_store_stage_i/mem_addr_reg<18>
Project.unit<1>.triggerChannel<0><54>=image_store_stage_i/mem_addr_reg<19>
Project.unit<1>.triggerChannel<0><5>=VGA_Y_GREEN_3_IBUF
Project.unit<1>.triggerChannel<0><6>=VGA_Y_GREEN_4_IBUF
Project.unit<1>.triggerChannel<0><7>=VGA_Y_GREEN_5_IBUF
Project.unit<1>.triggerChannel<0><8>=VGA_Y_GREEN_6_IBUF
Project.unit<1>.triggerChannel<0><9>=VGA_Y_GREEN_7_IBUF
Project.unit<1>.triggerConditionCountWidth=0
Project.unit<1>.triggerMatchCount<0>=1
Project.unit<1>.triggerMatchCountWidth<0><0>=0
Project.unit<1>.triggerMatchType<0><0>=0
Project.unit<1>.triggerPortCount=1
Project.unit<1>.triggerPortIsData<0>=true
Project.unit<1>.triggerPortWidth<0>=55
Project.unit<1>.triggerSequencerLevels=16
Project.unit<1>.triggerSequencerType=1
Project.unit<1>.type=ilapro
Project.unit<2>.clockChannel=dvi_pixel_clk
Project.unit<2>.clockEdge=Rising
Project.unit<2>.dataChannel<0>=image_display_stage_i/vga_timing_generator_i/hsync_reg
Project.unit<2>.dataChannel<10>=image_display_stage_i/vga_timing_generator_i/pixel_count_reg<6>
Project.unit<2>.dataChannel<11>=image_display_stage_i/vga_timing_generator_i/pixel_count_reg<7>
Project.unit<2>.dataChannel<12>=image_display_stage_i/vga_timing_generator_i/pixel_count_reg<8>
Project.unit<2>.dataChannel<13>=image_display_stage_i/vga_timing_generator_i/pixel_count_reg<9>
Project.unit<2>.dataChannel<14>=image_display_stage_i/vga_timing_generator_i/pixel_count_reg<10>
Project.unit<2>.dataChannel<15>=image_display_stage_i/vga_timing_generator_i/pixel_count_reg<11>
Project.unit<2>.dataChannel<16>=image_display_stage_i/vga_timing_generator_i/pixel_count_reg<12>
Project.unit<2>.dataChannel<17>=image_display_stage_i/vga_timing_generator_i/pixel_count_reg<13>
Project.unit<2>.dataChannel<18>=image_display_stage_i/dvi_gray_delay<0>
Project.unit<2>.dataChannel<19>=image_display_stage_i/dvi_gray_delay<1>
Project.unit<2>.dataChannel<1>=image_display_stage_i/vga_timing_generator_i/vsync_reg
Project.unit<2>.dataChannel<20>=image_display_stage_i/dvi_gray_delay<2>
Project.unit<2>.dataChannel<21>=image_display_stage_i/dvi_gray_delay<3>
Project.unit<2>.dataChannel<22>=image_display_stage_i/dvi_gray_delay<4>
Project.unit<2>.dataChannel<23>=image_display_stage_i/dvi_gray_delay<5>
Project.unit<2>.dataChannel<24>=image_display_stage_i/dvi_gray_delay<6>
Project.unit<2>.dataChannel<25>=image_display_stage_i/dvi_gray_delay<7>
Project.unit<2>.dataChannel<2>=image_display_stage_i/vga_timing_generator_i/data_valid_reg
Project.unit<2>.dataChannel<3>=image_display_mem_output_valid_cs
Project.unit<2>.dataChannel<4>=image_display_stage_i/vga_timing_generator_i/pixel_count_reg<0>
Project.unit<2>.dataChannel<5>=image_display_stage_i/vga_timing_generator_i/pixel_count_reg<1>
Project.unit<2>.dataChannel<6>=image_display_stage_i/vga_timing_generator_i/pixel_count_reg<2>
Project.unit<2>.dataChannel<7>=image_display_stage_i/vga_timing_generator_i/pixel_count_reg<3>
Project.unit<2>.dataChannel<8>=image_display_stage_i/vga_timing_generator_i/pixel_count_reg<4>
Project.unit<2>.dataChannel<9>=image_display_stage_i/vga_timing_generator_i/pixel_count_reg<5>
Project.unit<2>.dataDepth=4096
Project.unit<2>.dataEqualsTrigger=true
Project.unit<2>.dataPortWidth=26
Project.unit<2>.enableGaps=false
Project.unit<2>.enableStorageQualification=true
Project.unit<2>.enableTimestamps=false
Project.unit<2>.timestampDepth=0
Project.unit<2>.timestampWidth=0
Project.unit<2>.triggerChannel<0><0>=image_display_stage_i/vga_timing_generator_i/hsync_reg
Project.unit<2>.triggerChannel<0><10>=image_display_stage_i/vga_timing_generator_i/pixel_count_reg<6>
Project.unit<2>.triggerChannel<0><11>=image_display_stage_i/vga_timing_generator_i/pixel_count_reg<7>
Project.unit<2>.triggerChannel<0><12>=image_display_stage_i/vga_timing_generator_i/pixel_count_reg<8>
Project.unit<2>.triggerChannel<0><13>=image_display_stage_i/vga_timing_generator_i/pixel_count_reg<9>
Project.unit<2>.triggerChannel<0><14>=image_display_stage_i/vga_timing_generator_i/pixel_count_reg<10>
Project.unit<2>.triggerChannel<0><15>=image_display_stage_i/vga_timing_generator_i/pixel_count_reg<11>
Project.unit<2>.triggerChannel<0><16>=image_display_stage_i/vga_timing_generator_i/pixel_count_reg<12>
Project.unit<2>.triggerChannel<0><17>=image_display_stage_i/vga_timing_generator_i/pixel_count_reg<13>
Project.unit<2>.triggerChannel<0><18>=image_display_stage_i/dvi_gray_delay<0>
Project.unit<2>.triggerChannel<0><19>=image_display_stage_i/dvi_gray_delay<1>
Project.unit<2>.triggerChannel<0><1>=image_display_stage_i/vga_timing_generator_i/vsync_reg
Project.unit<2>.triggerChannel<0><20>=image_display_stage_i/dvi_gray_delay<2>
Project.unit<2>.triggerChannel<0><21>=image_display_stage_i/dvi_gray_delay<3>
Project.unit<2>.triggerChannel<0><22>=image_display_stage_i/dvi_gray_delay<4>
Project.unit<2>.triggerChannel<0><23>=image_display_stage_i/dvi_gray_delay<5>
Project.unit<2>.triggerChannel<0><24>=image_display_stage_i/dvi_gray_delay<6>
Project.unit<2>.triggerChannel<0><25>=image_display_stage_i/dvi_gray_delay<7>
Project.unit<2>.triggerChannel<0><2>=image_display_stage_i/vga_timing_generator_i/DATA_VALID_EXT
Project.unit<2>.triggerChannel<0><3>=image_display_mem_output_valid_cs
Project.unit<2>.triggerChannel<0><4>=image_display_stage_i/vga_timing_generator_i/pixel_count_reg<0>
Project.unit<2>.triggerChannel<0><5>=image_display_stage_i/vga_timing_generator_i/pixel_count_reg<1>
Project.unit<2>.triggerChannel<0><6>=image_display_stage_i/vga_timing_generator_i/pixel_count_reg<2>
Project.unit<2>.triggerChannel<0><7>=image_display_stage_i/vga_timing_generator_i/pixel_count_reg<3>
Project.unit<2>.triggerChannel<0><8>=image_display_stage_i/vga_timing_generator_i/pixel_count_reg<4>
Project.unit<2>.triggerChannel<0><9>=image_display_stage_i/vga_timing_generator_i/pixel_count_reg<5>
Project.unit<2>.triggerConditionCountWidth=0
Project.unit<2>.triggerMatchCount<0>=1
Project.unit<2>.triggerMatchCountWidth<0><0>=0
Project.unit<2>.triggerMatchType<0><0>=0
Project.unit<2>.triggerPortCount=1
Project.unit<2>.triggerPortIsData<0>=true
Project.unit<2>.triggerPortWidth<0>=26
Project.unit<2>.triggerSequencerLevels=16
Project.unit<2>.triggerSequencerType=1
Project.unit<2>.type=ilapro
