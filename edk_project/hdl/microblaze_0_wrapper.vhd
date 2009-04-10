-------------------------------------------------------------------------------
-- microblaze_0_wrapper.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

library microblaze_v7_10_d;
use microblaze_v7_10_d.all;

entity microblaze_0_wrapper is
  port (
    CLK : in std_logic;
    RESET : in std_logic;
    MB_RESET : in std_logic;
    INTERRUPT : in std_logic;
    EXT_BRK : in std_logic;
    EXT_NM_BRK : in std_logic;
    DBG_STOP : in std_logic;
    MB_Halted : out std_logic;
    INSTR : in std_logic_vector(0 to 31);
    I_ADDRTAG : out std_logic_vector(0 to 3);
    IREADY : in std_logic;
    IWAIT : in std_logic;
    INSTR_ADDR : out std_logic_vector(0 to 31);
    IFETCH : out std_logic;
    I_AS : out std_logic;
    IPLB_M_ABort : out std_logic;
    IPLB_M_ABus : out std_logic_vector(0 to 31);
    IPLB_M_UABus : out std_logic_vector(0 to 31);
    IPLB_M_BE : out std_logic_vector(0 to 3);
    IPLB_M_busLock : out std_logic;
    IPLB_M_lockErr : out std_logic;
    IPLB_M_MSize : out std_logic_vector(0 to 1);
    IPLB_M_priority : out std_logic_vector(0 to 1);
    IPLB_M_rdBurst : out std_logic;
    IPLB_M_request : out std_logic;
    IPLB_M_RNW : out std_logic;
    IPLB_M_size : out std_logic_vector(0 to 3);
    IPLB_M_TAttribute : out std_logic_vector(0 to 15);
    IPLB_M_type : out std_logic_vector(0 to 2);
    IPLB_M_wrBurst : out std_logic;
    IPLB_M_wrDBus : out std_logic_vector(0 to 31);
    IPLB_MBusy : in std_logic;
    IPLB_MRdErr : in std_logic;
    IPLB_MWrErr : in std_logic;
    IPLB_MIRQ : in std_logic;
    IPLB_MWrBTerm : in std_logic;
    IPLB_MWrDAck : in std_logic;
    IPLB_MAddrAck : in std_logic;
    IPLB_MRdBTerm : in std_logic;
    IPLB_MRdDAck : in std_logic;
    IPLB_MRdDBus : in std_logic_vector(0 to 31);
    IPLB_MRdWdAddr : in std_logic_vector(0 to 3);
    IPLB_MRearbitrate : in std_logic;
    IPLB_MSSize : in std_logic_vector(0 to 1);
    IPLB_MTimeout : in std_logic;
    DATA_READ : in std_logic_vector(0 to 31);
    DREADY : in std_logic;
    DWAIT : in std_logic;
    DATA_WRITE : out std_logic_vector(0 to 31);
    DATA_ADDR : out std_logic_vector(0 to 31);
    D_ADDRTAG : out std_logic_vector(0 to 3);
    D_AS : out std_logic;
    READ_STROBE : out std_logic;
    WRITE_STROBE : out std_logic;
    BYTE_ENABLE : out std_logic_vector(0 to 3);
    DM_ABUS : out std_logic_vector(0 to 31);
    DM_BE : out std_logic_vector(0 to 3);
    DM_BUSLOCK : out std_logic;
    DM_DBUS : out std_logic_vector(0 to 31);
    DM_REQUEST : out std_logic;
    DM_RNW : out std_logic;
    DM_SELECT : out std_logic;
    DM_SEQADDR : out std_logic;
    DOPB_DBUS : in std_logic_vector(0 to 31);
    DOPB_ERRACK : in std_logic;
    DOPB_MGRANT : in std_logic;
    DOPB_RETRY : in std_logic;
    DOPB_TIMEOUT : in std_logic;
    DOPB_XFERACK : in std_logic;
    DPLB_M_ABort : out std_logic;
    DPLB_M_ABus : out std_logic_vector(0 to 31);
    DPLB_M_UABus : out std_logic_vector(0 to 31);
    DPLB_M_BE : out std_logic_vector(0 to 3);
    DPLB_M_busLock : out std_logic;
    DPLB_M_lockErr : out std_logic;
    DPLB_M_MSize : out std_logic_vector(0 to 1);
    DPLB_M_priority : out std_logic_vector(0 to 1);
    DPLB_M_rdBurst : out std_logic;
    DPLB_M_request : out std_logic;
    DPLB_M_RNW : out std_logic;
    DPLB_M_size : out std_logic_vector(0 to 3);
    DPLB_M_TAttribute : out std_logic_vector(0 to 15);
    DPLB_M_type : out std_logic_vector(0 to 2);
    DPLB_M_wrBurst : out std_logic;
    DPLB_M_wrDBus : out std_logic_vector(0 to 31);
    DPLB_MBusy : in std_logic;
    DPLB_MRdErr : in std_logic;
    DPLB_MWrErr : in std_logic;
    DPLB_MIRQ : in std_logic;
    DPLB_MWrBTerm : in std_logic;
    DPLB_MWrDAck : in std_logic;
    DPLB_MAddrAck : in std_logic;
    DPLB_MRdBTerm : in std_logic;
    DPLB_MRdDAck : in std_logic;
    DPLB_MRdDBus : in std_logic_vector(0 to 31);
    DPLB_MRdWdAddr : in std_logic_vector(0 to 3);
    DPLB_MRearbitrate : in std_logic;
    DPLB_MSSize : in std_logic_vector(0 to 1);
    DPLB_MTimeout : in std_logic;
    IM_ABUS : out std_logic_vector(0 to 31);
    IM_BE : out std_logic_vector(0 to 3);
    IM_BUSLOCK : out std_logic;
    IM_DBUS : out std_logic_vector(0 to 31);
    IM_REQUEST : out std_logic;
    IM_RNW : out std_logic;
    IM_SELECT : out std_logic;
    IM_SEQADDR : out std_logic;
    IOPB_DBUS : in std_logic_vector(0 to 31);
    IOPB_ERRACK : in std_logic;
    IOPB_MGRANT : in std_logic;
    IOPB_RETRY : in std_logic;
    IOPB_TIMEOUT : in std_logic;
    IOPB_XFERACK : in std_logic;
    DBG_CLK : in std_logic;
    DBG_TDI : in std_logic;
    DBG_TDO : out std_logic;
    DBG_REG_EN : in std_logic_vector(0 to 4);
    DBG_SHIFT : in std_logic;
    DBG_CAPTURE : in std_logic;
    DBG_UPDATE : in std_logic;
    DEBUG_RST : in std_logic;
    Trace_Instruction : out std_logic_vector(0 to 31);
    Trace_Valid_Instr : out std_logic;
    Trace_PC : out std_logic_vector(0 to 31);
    Trace_Reg_Write : out std_logic;
    Trace_Reg_Addr : out std_logic_vector(0 to 4);
    Trace_MSR_Reg : out std_logic_vector(0 to 14);
    Trace_PID_Reg : out std_logic_vector(0 to 7);
    Trace_New_Reg_Value : out std_logic_vector(0 to 31);
    Trace_Exception_Taken : out std_logic;
    Trace_Exception_Kind : out std_logic_vector(0 to 4);
    Trace_Jump_Taken : out std_logic;
    Trace_Delay_Slot : out std_logic;
    Trace_Data_Address : out std_logic_vector(0 to 31);
    Trace_Data_Access : out std_logic;
    Trace_Data_Read : out std_logic;
    Trace_Data_Write : out std_logic;
    Trace_Data_Write_Value : out std_logic_vector(0 to 31);
    Trace_Data_Byte_Enable : out std_logic_vector(0 to 3);
    Trace_DCache_Req : out std_logic;
    Trace_DCache_Hit : out std_logic;
    Trace_ICache_Req : out std_logic;
    Trace_ICache_Hit : out std_logic;
    Trace_OF_PipeRun : out std_logic;
    Trace_EX_PipeRun : out std_logic;
    Trace_MEM_PipeRun : out std_logic;
    Trace_MB_Halted : out std_logic;
    FSL0_S_CLK : out std_logic;
    FSL0_S_READ : out std_logic;
    FSL0_S_DATA : in std_logic_vector(0 to 31);
    FSL0_S_CONTROL : in std_logic;
    FSL0_S_EXISTS : in std_logic;
    FSL0_M_CLK : out std_logic;
    FSL0_M_WRITE : out std_logic;
    FSL0_M_DATA : out std_logic_vector(0 to 31);
    FSL0_M_CONTROL : out std_logic;
    FSL0_M_FULL : in std_logic;
    FSL1_S_CLK : out std_logic;
    FSL1_S_READ : out std_logic;
    FSL1_S_DATA : in std_logic_vector(0 to 31);
    FSL1_S_CONTROL : in std_logic;
    FSL1_S_EXISTS : in std_logic;
    FSL1_M_CLK : out std_logic;
    FSL1_M_WRITE : out std_logic;
    FSL1_M_DATA : out std_logic_vector(0 to 31);
    FSL1_M_CONTROL : out std_logic;
    FSL1_M_FULL : in std_logic;
    FSL2_S_CLK : out std_logic;
    FSL2_S_READ : out std_logic;
    FSL2_S_DATA : in std_logic_vector(0 to 31);
    FSL2_S_CONTROL : in std_logic;
    FSL2_S_EXISTS : in std_logic;
    FSL2_M_CLK : out std_logic;
    FSL2_M_WRITE : out std_logic;
    FSL2_M_DATA : out std_logic_vector(0 to 31);
    FSL2_M_CONTROL : out std_logic;
    FSL2_M_FULL : in std_logic;
    FSL3_S_CLK : out std_logic;
    FSL3_S_READ : out std_logic;
    FSL3_S_DATA : in std_logic_vector(0 to 31);
    FSL3_S_CONTROL : in std_logic;
    FSL3_S_EXISTS : in std_logic;
    FSL3_M_CLK : out std_logic;
    FSL3_M_WRITE : out std_logic;
    FSL3_M_DATA : out std_logic_vector(0 to 31);
    FSL3_M_CONTROL : out std_logic;
    FSL3_M_FULL : in std_logic;
    FSL4_S_CLK : out std_logic;
    FSL4_S_READ : out std_logic;
    FSL4_S_DATA : in std_logic_vector(0 to 31);
    FSL4_S_CONTROL : in std_logic;
    FSL4_S_EXISTS : in std_logic;
    FSL4_M_CLK : out std_logic;
    FSL4_M_WRITE : out std_logic;
    FSL4_M_DATA : out std_logic_vector(0 to 31);
    FSL4_M_CONTROL : out std_logic;
    FSL4_M_FULL : in std_logic;
    FSL5_S_CLK : out std_logic;
    FSL5_S_READ : out std_logic;
    FSL5_S_DATA : in std_logic_vector(0 to 31);
    FSL5_S_CONTROL : in std_logic;
    FSL5_S_EXISTS : in std_logic;
    FSL5_M_CLK : out std_logic;
    FSL5_M_WRITE : out std_logic;
    FSL5_M_DATA : out std_logic_vector(0 to 31);
    FSL5_M_CONTROL : out std_logic;
    FSL5_M_FULL : in std_logic;
    FSL6_S_CLK : out std_logic;
    FSL6_S_READ : out std_logic;
    FSL6_S_DATA : in std_logic_vector(0 to 31);
    FSL6_S_CONTROL : in std_logic;
    FSL6_S_EXISTS : in std_logic;
    FSL6_M_CLK : out std_logic;
    FSL6_M_WRITE : out std_logic;
    FSL6_M_DATA : out std_logic_vector(0 to 31);
    FSL6_M_CONTROL : out std_logic;
    FSL6_M_FULL : in std_logic;
    FSL7_S_CLK : out std_logic;
    FSL7_S_READ : out std_logic;
    FSL7_S_DATA : in std_logic_vector(0 to 31);
    FSL7_S_CONTROL : in std_logic;
    FSL7_S_EXISTS : in std_logic;
    FSL7_M_CLK : out std_logic;
    FSL7_M_WRITE : out std_logic;
    FSL7_M_DATA : out std_logic_vector(0 to 31);
    FSL7_M_CONTROL : out std_logic;
    FSL7_M_FULL : in std_logic;
    FSL8_S_CLK : out std_logic;
    FSL8_S_READ : out std_logic;
    FSL8_S_DATA : in std_logic_vector(0 to 31);
    FSL8_S_CONTROL : in std_logic;
    FSL8_S_EXISTS : in std_logic;
    FSL8_M_CLK : out std_logic;
    FSL8_M_WRITE : out std_logic;
    FSL8_M_DATA : out std_logic_vector(0 to 31);
    FSL8_M_CONTROL : out std_logic;
    FSL8_M_FULL : in std_logic;
    FSL9_S_CLK : out std_logic;
    FSL9_S_READ : out std_logic;
    FSL9_S_DATA : in std_logic_vector(0 to 31);
    FSL9_S_CONTROL : in std_logic;
    FSL9_S_EXISTS : in std_logic;
    FSL9_M_CLK : out std_logic;
    FSL9_M_WRITE : out std_logic;
    FSL9_M_DATA : out std_logic_vector(0 to 31);
    FSL9_M_CONTROL : out std_logic;
    FSL9_M_FULL : in std_logic;
    FSL10_S_CLK : out std_logic;
    FSL10_S_READ : out std_logic;
    FSL10_S_DATA : in std_logic_vector(0 to 31);
    FSL10_S_CONTROL : in std_logic;
    FSL10_S_EXISTS : in std_logic;
    FSL10_M_CLK : out std_logic;
    FSL10_M_WRITE : out std_logic;
    FSL10_M_DATA : out std_logic_vector(0 to 31);
    FSL10_M_CONTROL : out std_logic;
    FSL10_M_FULL : in std_logic;
    FSL11_S_CLK : out std_logic;
    FSL11_S_READ : out std_logic;
    FSL11_S_DATA : in std_logic_vector(0 to 31);
    FSL11_S_CONTROL : in std_logic;
    FSL11_S_EXISTS : in std_logic;
    FSL11_M_CLK : out std_logic;
    FSL11_M_WRITE : out std_logic;
    FSL11_M_DATA : out std_logic_vector(0 to 31);
    FSL11_M_CONTROL : out std_logic;
    FSL11_M_FULL : in std_logic;
    FSL12_S_CLK : out std_logic;
    FSL12_S_READ : out std_logic;
    FSL12_S_DATA : in std_logic_vector(0 to 31);
    FSL12_S_CONTROL : in std_logic;
    FSL12_S_EXISTS : in std_logic;
    FSL12_M_CLK : out std_logic;
    FSL12_M_WRITE : out std_logic;
    FSL12_M_DATA : out std_logic_vector(0 to 31);
    FSL12_M_CONTROL : out std_logic;
    FSL12_M_FULL : in std_logic;
    FSL13_S_CLK : out std_logic;
    FSL13_S_READ : out std_logic;
    FSL13_S_DATA : in std_logic_vector(0 to 31);
    FSL13_S_CONTROL : in std_logic;
    FSL13_S_EXISTS : in std_logic;
    FSL13_M_CLK : out std_logic;
    FSL13_M_WRITE : out std_logic;
    FSL13_M_DATA : out std_logic_vector(0 to 31);
    FSL13_M_CONTROL : out std_logic;
    FSL13_M_FULL : in std_logic;
    FSL14_S_CLK : out std_logic;
    FSL14_S_READ : out std_logic;
    FSL14_S_DATA : in std_logic_vector(0 to 31);
    FSL14_S_CONTROL : in std_logic;
    FSL14_S_EXISTS : in std_logic;
    FSL14_M_CLK : out std_logic;
    FSL14_M_WRITE : out std_logic;
    FSL14_M_DATA : out std_logic_vector(0 to 31);
    FSL14_M_CONTROL : out std_logic;
    FSL14_M_FULL : in std_logic;
    FSL15_S_CLK : out std_logic;
    FSL15_S_READ : out std_logic;
    FSL15_S_DATA : in std_logic_vector(0 to 31);
    FSL15_S_CONTROL : in std_logic;
    FSL15_S_EXISTS : in std_logic;
    FSL15_M_CLK : out std_logic;
    FSL15_M_WRITE : out std_logic;
    FSL15_M_DATA : out std_logic_vector(0 to 31);
    FSL15_M_CONTROL : out std_logic;
    FSL15_M_FULL : in std_logic;
    ICACHE_FSL_IN_CLK : out std_logic;
    ICACHE_FSL_IN_READ : out std_logic;
    ICACHE_FSL_IN_DATA : in std_logic_vector(0 to 31);
    ICACHE_FSL_IN_CONTROL : in std_logic;
    ICACHE_FSL_IN_EXISTS : in std_logic;
    ICACHE_FSL_OUT_CLK : out std_logic;
    ICACHE_FSL_OUT_WRITE : out std_logic;
    ICACHE_FSL_OUT_DATA : out std_logic_vector(0 to 31);
    ICACHE_FSL_OUT_CONTROL : out std_logic;
    ICACHE_FSL_OUT_FULL : in std_logic;
    DCACHE_FSL_IN_CLK : out std_logic;
    DCACHE_FSL_IN_READ : out std_logic;
    DCACHE_FSL_IN_DATA : in std_logic_vector(0 to 31);
    DCACHE_FSL_IN_CONTROL : in std_logic;
    DCACHE_FSL_IN_EXISTS : in std_logic;
    DCACHE_FSL_OUT_CLK : out std_logic;
    DCACHE_FSL_OUT_WRITE : out std_logic;
    DCACHE_FSL_OUT_DATA : out std_logic_vector(0 to 31);
    DCACHE_FSL_OUT_CONTROL : out std_logic;
    DCACHE_FSL_OUT_FULL : in std_logic
  );

  attribute x_core_info : STRING;
  attribute x_core_info of microblaze_0_wrapper : entity is "microblaze_v7_10_d";

end microblaze_0_wrapper;

architecture STRUCTURE of microblaze_0_wrapper is

  component microblaze is
    generic (
      C_SCO : integer;
      C_DATA_SIZE : integer;
      C_DYNAMIC_BUS_SIZING : integer;
      C_FAMILY : string;
      C_INSTANCE : string;
      C_AREA_OPTIMIZED : integer;
      C_INTERCONNECT : integer;
      C_DPLB_DWIDTH : integer;
      C_DPLB_NATIVE_DWIDTH : integer;
      C_DPLB_BURST_EN : integer;
      C_DPLB_P2P : integer;
      C_IPLB_DWIDTH : integer;
      C_IPLB_NATIVE_DWIDTH : integer;
      C_IPLB_BURST_EN : integer;
      C_IPLB_P2P : integer;
      C_D_PLB : integer;
      C_D_OPB : integer;
      C_D_LMB : integer;
      C_I_PLB : integer;
      C_I_OPB : integer;
      C_I_LMB : integer;
      C_USE_MSR_INSTR : integer;
      C_USE_PCMP_INSTR : integer;
      C_USE_BARREL : integer;
      C_USE_DIV : integer;
      C_USE_HW_MUL : integer;
      C_USE_FPU : integer;
      C_UNALIGNED_EXCEPTIONS : integer;
      C_ILL_OPCODE_EXCEPTION : integer;
      C_IOPB_BUS_EXCEPTION : integer;
      C_DOPB_BUS_EXCEPTION : integer;
      C_IPLB_BUS_EXCEPTION : integer;
      C_DPLB_BUS_EXCEPTION : integer;
      C_DIV_ZERO_EXCEPTION : integer;
      C_FPU_EXCEPTION : integer;
      C_FSL_EXCEPTION : integer;
      C_PVR : integer;
      C_PVR_USER1 : std_logic_vector(0 to 7);
      C_PVR_USER2 : std_logic_vector(0 to 31);
      C_DEBUG_ENABLED : integer;
      C_NUMBER_OF_PC_BRK : integer;
      C_NUMBER_OF_RD_ADDR_BRK : integer;
      C_NUMBER_OF_WR_ADDR_BRK : integer;
      C_INTERRUPT_IS_EDGE : integer;
      C_EDGE_IS_POSITIVE : integer;
      C_RESET_MSR : std_logic_vector;
      C_OPCODE_0x0_ILLEGAL : integer;
      C_FSL_LINKS : integer;
      C_FSL_DATA_SIZE : integer;
      C_USE_EXTENDED_FSL_INSTR : integer;
      C_ICACHE_BASEADDR : std_logic_vector;
      C_ICACHE_HIGHADDR : std_logic_vector;
      C_USE_ICACHE : integer;
      C_ALLOW_ICACHE_WR : integer;
      C_ADDR_TAG_BITS : integer;
      C_CACHE_BYTE_SIZE : integer;
      C_ICACHE_USE_FSL : integer;
      C_ICACHE_LINE_LEN : integer;
      C_ICACHE_ALWAYS_USED : integer;
      C_DCACHE_BASEADDR : std_logic_vector;
      C_DCACHE_HIGHADDR : std_logic_vector;
      C_USE_DCACHE : integer;
      C_ALLOW_DCACHE_WR : integer;
      C_DCACHE_ADDR_TAG : integer;
      C_DCACHE_BYTE_SIZE : integer;
      C_DCACHE_USE_FSL : integer;
      C_DCACHE_LINE_LEN : integer;
      C_DCACHE_ALWAYS_USED : integer;
      C_USE_MMU : integer;
      C_MMU_DTLB_SIZE : integer;
      C_MMU_ITLB_SIZE : integer;
      C_MMU_TLB_ACCESS : integer;
      C_MMU_ZONES : integer;
      C_USE_INTERRUPT : integer;
      C_USE_EXT_BRK : integer;
      C_USE_EXT_NM_BRK : integer
    );
    port (
      CLK : in std_logic;
      RESET : in std_logic;
      MB_RESET : in std_logic;
      INTERRUPT : in std_logic;
      EXT_BRK : in std_logic;
      EXT_NM_BRK : in std_logic;
      DBG_STOP : in std_logic;
      MB_Halted : out std_logic;
      INSTR : in std_logic_vector(0 to 31);
      I_ADDRTAG : out std_logic_vector(0 to 3);
      IREADY : in std_logic;
      IWAIT : in std_logic;
      INSTR_ADDR : out std_logic_vector(0 to 31);
      IFETCH : out std_logic;
      I_AS : out std_logic;
      IPLB_M_ABort : out std_logic;
      IPLB_M_ABus : out std_logic_vector(0 to 31);
      IPLB_M_UABus : out std_logic_vector(0 to 31);
      IPLB_M_BE : out std_logic_vector(0 to (C_IPLB_DWIDTH-1)/8);
      IPLB_M_busLock : out std_logic;
      IPLB_M_lockErr : out std_logic;
      IPLB_M_MSize : out std_logic_vector(0 to 1);
      IPLB_M_priority : out std_logic_vector(0 to 1);
      IPLB_M_rdBurst : out std_logic;
      IPLB_M_request : out std_logic;
      IPLB_M_RNW : out std_logic;
      IPLB_M_size : out std_logic_vector(0 to 3);
      IPLB_M_TAttribute : out std_logic_vector(0 to 15);
      IPLB_M_type : out std_logic_vector(0 to 2);
      IPLB_M_wrBurst : out std_logic;
      IPLB_M_wrDBus : out std_logic_vector(0 to C_IPLB_DWIDTH-1);
      IPLB_MBusy : in std_logic;
      IPLB_MRdErr : in std_logic;
      IPLB_MWrErr : in std_logic;
      IPLB_MIRQ : in std_logic;
      IPLB_MWrBTerm : in std_logic;
      IPLB_MWrDAck : in std_logic;
      IPLB_MAddrAck : in std_logic;
      IPLB_MRdBTerm : in std_logic;
      IPLB_MRdDAck : in std_logic;
      IPLB_MRdDBus : in std_logic_vector(0 to C_IPLB_DWIDTH-1);
      IPLB_MRdWdAddr : in std_logic_vector(0 to 3);
      IPLB_MRearbitrate : in std_logic;
      IPLB_MSSize : in std_logic_vector(0 to 1);
      IPLB_MTimeout : in std_logic;
      DATA_READ : in std_logic_vector(0 to 31);
      DREADY : in std_logic;
      DWAIT : in std_logic;
      DATA_WRITE : out std_logic_vector(0 to 31);
      DATA_ADDR : out std_logic_vector(0 to 31);
      D_ADDRTAG : out std_logic_vector(0 to 3);
      D_AS : out std_logic;
      READ_STROBE : out std_logic;
      WRITE_STROBE : out std_logic;
      BYTE_ENABLE : out std_logic_vector(0 to 3);
      DM_ABUS : out std_logic_vector(0 to 31);
      DM_BE : out std_logic_vector(0 to 3);
      DM_BUSLOCK : out std_logic;
      DM_DBUS : out std_logic_vector(0 to 31);
      DM_REQUEST : out std_logic;
      DM_RNW : out std_logic;
      DM_SELECT : out std_logic;
      DM_SEQADDR : out std_logic;
      DOPB_DBUS : in std_logic_vector(0 to 31);
      DOPB_ERRACK : in std_logic;
      DOPB_MGRANT : in std_logic;
      DOPB_RETRY : in std_logic;
      DOPB_TIMEOUT : in std_logic;
      DOPB_XFERACK : in std_logic;
      DPLB_M_ABort : out std_logic;
      DPLB_M_ABus : out std_logic_vector(0 to 31);
      DPLB_M_UABus : out std_logic_vector(0 to 31);
      DPLB_M_BE : out std_logic_vector(0 to (C_DPLB_DWIDTH-1)/8);
      DPLB_M_busLock : out std_logic;
      DPLB_M_lockErr : out std_logic;
      DPLB_M_MSize : out std_logic_vector(0 to 1);
      DPLB_M_priority : out std_logic_vector(0 to 1);
      DPLB_M_rdBurst : out std_logic;
      DPLB_M_request : out std_logic;
      DPLB_M_RNW : out std_logic;
      DPLB_M_size : out std_logic_vector(0 to 3);
      DPLB_M_TAttribute : out std_logic_vector(0 to 15);
      DPLB_M_type : out std_logic_vector(0 to 2);
      DPLB_M_wrBurst : out std_logic;
      DPLB_M_wrDBus : out std_logic_vector(0 to C_DPLB_DWIDTH-1);
      DPLB_MBusy : in std_logic;
      DPLB_MRdErr : in std_logic;
      DPLB_MWrErr : in std_logic;
      DPLB_MIRQ : in std_logic;
      DPLB_MWrBTerm : in std_logic;
      DPLB_MWrDAck : in std_logic;
      DPLB_MAddrAck : in std_logic;
      DPLB_MRdBTerm : in std_logic;
      DPLB_MRdDAck : in std_logic;
      DPLB_MRdDBus : in std_logic_vector(0 to C_DPLB_DWIDTH-1);
      DPLB_MRdWdAddr : in std_logic_vector(0 to 3);
      DPLB_MRearbitrate : in std_logic;
      DPLB_MSSize : in std_logic_vector(0 to 1);
      DPLB_MTimeout : in std_logic;
      IM_ABUS : out std_logic_vector(0 to 31);
      IM_BE : out std_logic_vector(0 to 3);
      IM_BUSLOCK : out std_logic;
      IM_DBUS : out std_logic_vector(0 to 31);
      IM_REQUEST : out std_logic;
      IM_RNW : out std_logic;
      IM_SELECT : out std_logic;
      IM_SEQADDR : out std_logic;
      IOPB_DBUS : in std_logic_vector(0 to 31);
      IOPB_ERRACK : in std_logic;
      IOPB_MGRANT : in std_logic;
      IOPB_RETRY : in std_logic;
      IOPB_TIMEOUT : in std_logic;
      IOPB_XFERACK : in std_logic;
      DBG_CLK : in std_logic;
      DBG_TDI : in std_logic;
      DBG_TDO : out std_logic;
      DBG_REG_EN : in std_logic_vector(0 to 4);
      DBG_SHIFT : in std_logic;
      DBG_CAPTURE : in std_logic;
      DBG_UPDATE : in std_logic;
      DEBUG_RST : in std_logic;
      Trace_Instruction : out std_logic_vector(0 to 31);
      Trace_Valid_Instr : out std_logic;
      Trace_PC : out std_logic_vector(0 to 31);
      Trace_Reg_Write : out std_logic;
      Trace_Reg_Addr : out std_logic_vector(0 to 4);
      Trace_MSR_Reg : out std_logic_vector(0 to 14);
      Trace_PID_Reg : out std_logic_vector(0 to 7);
      Trace_New_Reg_Value : out std_logic_vector(0 to 31);
      Trace_Exception_Taken : out std_logic;
      Trace_Exception_Kind : out std_logic_vector(0 to 4);
      Trace_Jump_Taken : out std_logic;
      Trace_Delay_Slot : out std_logic;
      Trace_Data_Address : out std_logic_vector(0 to 31);
      Trace_Data_Access : out std_logic;
      Trace_Data_Read : out std_logic;
      Trace_Data_Write : out std_logic;
      Trace_Data_Write_Value : out std_logic_vector(0 to 31);
      Trace_Data_Byte_Enable : out std_logic_vector(0 to 3);
      Trace_DCache_Req : out std_logic;
      Trace_DCache_Hit : out std_logic;
      Trace_ICache_Req : out std_logic;
      Trace_ICache_Hit : out std_logic;
      Trace_OF_PipeRun : out std_logic;
      Trace_EX_PipeRun : out std_logic;
      Trace_MEM_PipeRun : out std_logic;
      Trace_MB_Halted : out std_logic;
      FSL0_S_CLK : out std_logic;
      FSL0_S_READ : out std_logic;
      FSL0_S_DATA : in std_logic_vector(0 to C_FSL_DATA_SIZE-1);
      FSL0_S_CONTROL : in std_logic;
      FSL0_S_EXISTS : in std_logic;
      FSL0_M_CLK : out std_logic;
      FSL0_M_WRITE : out std_logic;
      FSL0_M_DATA : out std_logic_vector(0 to C_FSL_DATA_SIZE-1);
      FSL0_M_CONTROL : out std_logic;
      FSL0_M_FULL : in std_logic;
      FSL1_S_CLK : out std_logic;
      FSL1_S_READ : out std_logic;
      FSL1_S_DATA : in std_logic_vector(0 to C_FSL_DATA_SIZE-1);
      FSL1_S_CONTROL : in std_logic;
      FSL1_S_EXISTS : in std_logic;
      FSL1_M_CLK : out std_logic;
      FSL1_M_WRITE : out std_logic;
      FSL1_M_DATA : out std_logic_vector(0 to C_FSL_DATA_SIZE-1);
      FSL1_M_CONTROL : out std_logic;
      FSL1_M_FULL : in std_logic;
      FSL2_S_CLK : out std_logic;
      FSL2_S_READ : out std_logic;
      FSL2_S_DATA : in std_logic_vector(0 to C_FSL_DATA_SIZE-1);
      FSL2_S_CONTROL : in std_logic;
      FSL2_S_EXISTS : in std_logic;
      FSL2_M_CLK : out std_logic;
      FSL2_M_WRITE : out std_logic;
      FSL2_M_DATA : out std_logic_vector(0 to C_FSL_DATA_SIZE-1);
      FSL2_M_CONTROL : out std_logic;
      FSL2_M_FULL : in std_logic;
      FSL3_S_CLK : out std_logic;
      FSL3_S_READ : out std_logic;
      FSL3_S_DATA : in std_logic_vector(0 to C_FSL_DATA_SIZE-1);
      FSL3_S_CONTROL : in std_logic;
      FSL3_S_EXISTS : in std_logic;
      FSL3_M_CLK : out std_logic;
      FSL3_M_WRITE : out std_logic;
      FSL3_M_DATA : out std_logic_vector(0 to C_FSL_DATA_SIZE-1);
      FSL3_M_CONTROL : out std_logic;
      FSL3_M_FULL : in std_logic;
      FSL4_S_CLK : out std_logic;
      FSL4_S_READ : out std_logic;
      FSL4_S_DATA : in std_logic_vector(0 to C_FSL_DATA_SIZE-1);
      FSL4_S_CONTROL : in std_logic;
      FSL4_S_EXISTS : in std_logic;
      FSL4_M_CLK : out std_logic;
      FSL4_M_WRITE : out std_logic;
      FSL4_M_DATA : out std_logic_vector(0 to C_FSL_DATA_SIZE-1);
      FSL4_M_CONTROL : out std_logic;
      FSL4_M_FULL : in std_logic;
      FSL5_S_CLK : out std_logic;
      FSL5_S_READ : out std_logic;
      FSL5_S_DATA : in std_logic_vector(0 to C_FSL_DATA_SIZE-1);
      FSL5_S_CONTROL : in std_logic;
      FSL5_S_EXISTS : in std_logic;
      FSL5_M_CLK : out std_logic;
      FSL5_M_WRITE : out std_logic;
      FSL5_M_DATA : out std_logic_vector(0 to C_FSL_DATA_SIZE-1);
      FSL5_M_CONTROL : out std_logic;
      FSL5_M_FULL : in std_logic;
      FSL6_S_CLK : out std_logic;
      FSL6_S_READ : out std_logic;
      FSL6_S_DATA : in std_logic_vector(0 to C_FSL_DATA_SIZE-1);
      FSL6_S_CONTROL : in std_logic;
      FSL6_S_EXISTS : in std_logic;
      FSL6_M_CLK : out std_logic;
      FSL6_M_WRITE : out std_logic;
      FSL6_M_DATA : out std_logic_vector(0 to C_FSL_DATA_SIZE-1);
      FSL6_M_CONTROL : out std_logic;
      FSL6_M_FULL : in std_logic;
      FSL7_S_CLK : out std_logic;
      FSL7_S_READ : out std_logic;
      FSL7_S_DATA : in std_logic_vector(0 to C_FSL_DATA_SIZE-1);
      FSL7_S_CONTROL : in std_logic;
      FSL7_S_EXISTS : in std_logic;
      FSL7_M_CLK : out std_logic;
      FSL7_M_WRITE : out std_logic;
      FSL7_M_DATA : out std_logic_vector(0 to C_FSL_DATA_SIZE-1);
      FSL7_M_CONTROL : out std_logic;
      FSL7_M_FULL : in std_logic;
      FSL8_S_CLK : out std_logic;
      FSL8_S_READ : out std_logic;
      FSL8_S_DATA : in std_logic_vector(0 to C_FSL_DATA_SIZE-1);
      FSL8_S_CONTROL : in std_logic;
      FSL8_S_EXISTS : in std_logic;
      FSL8_M_CLK : out std_logic;
      FSL8_M_WRITE : out std_logic;
      FSL8_M_DATA : out std_logic_vector(0 to C_FSL_DATA_SIZE-1);
      FSL8_M_CONTROL : out std_logic;
      FSL8_M_FULL : in std_logic;
      FSL9_S_CLK : out std_logic;
      FSL9_S_READ : out std_logic;
      FSL9_S_DATA : in std_logic_vector(0 to C_FSL_DATA_SIZE-1);
      FSL9_S_CONTROL : in std_logic;
      FSL9_S_EXISTS : in std_logic;
      FSL9_M_CLK : out std_logic;
      FSL9_M_WRITE : out std_logic;
      FSL9_M_DATA : out std_logic_vector(0 to C_FSL_DATA_SIZE-1);
      FSL9_M_CONTROL : out std_logic;
      FSL9_M_FULL : in std_logic;
      FSL10_S_CLK : out std_logic;
      FSL10_S_READ : out std_logic;
      FSL10_S_DATA : in std_logic_vector(0 to C_FSL_DATA_SIZE-1);
      FSL10_S_CONTROL : in std_logic;
      FSL10_S_EXISTS : in std_logic;
      FSL10_M_CLK : out std_logic;
      FSL10_M_WRITE : out std_logic;
      FSL10_M_DATA : out std_logic_vector(0 to C_FSL_DATA_SIZE-1);
      FSL10_M_CONTROL : out std_logic;
      FSL10_M_FULL : in std_logic;
      FSL11_S_CLK : out std_logic;
      FSL11_S_READ : out std_logic;
      FSL11_S_DATA : in std_logic_vector(0 to C_FSL_DATA_SIZE-1);
      FSL11_S_CONTROL : in std_logic;
      FSL11_S_EXISTS : in std_logic;
      FSL11_M_CLK : out std_logic;
      FSL11_M_WRITE : out std_logic;
      FSL11_M_DATA : out std_logic_vector(0 to C_FSL_DATA_SIZE-1);
      FSL11_M_CONTROL : out std_logic;
      FSL11_M_FULL : in std_logic;
      FSL12_S_CLK : out std_logic;
      FSL12_S_READ : out std_logic;
      FSL12_S_DATA : in std_logic_vector(0 to C_FSL_DATA_SIZE-1);
      FSL12_S_CONTROL : in std_logic;
      FSL12_S_EXISTS : in std_logic;
      FSL12_M_CLK : out std_logic;
      FSL12_M_WRITE : out std_logic;
      FSL12_M_DATA : out std_logic_vector(0 to C_FSL_DATA_SIZE-1);
      FSL12_M_CONTROL : out std_logic;
      FSL12_M_FULL : in std_logic;
      FSL13_S_CLK : out std_logic;
      FSL13_S_READ : out std_logic;
      FSL13_S_DATA : in std_logic_vector(0 to C_FSL_DATA_SIZE-1);
      FSL13_S_CONTROL : in std_logic;
      FSL13_S_EXISTS : in std_logic;
      FSL13_M_CLK : out std_logic;
      FSL13_M_WRITE : out std_logic;
      FSL13_M_DATA : out std_logic_vector(0 to C_FSL_DATA_SIZE-1);
      FSL13_M_CONTROL : out std_logic;
      FSL13_M_FULL : in std_logic;
      FSL14_S_CLK : out std_logic;
      FSL14_S_READ : out std_logic;
      FSL14_S_DATA : in std_logic_vector(0 to C_FSL_DATA_SIZE-1);
      FSL14_S_CONTROL : in std_logic;
      FSL14_S_EXISTS : in std_logic;
      FSL14_M_CLK : out std_logic;
      FSL14_M_WRITE : out std_logic;
      FSL14_M_DATA : out std_logic_vector(0 to C_FSL_DATA_SIZE-1);
      FSL14_M_CONTROL : out std_logic;
      FSL14_M_FULL : in std_logic;
      FSL15_S_CLK : out std_logic;
      FSL15_S_READ : out std_logic;
      FSL15_S_DATA : in std_logic_vector(0 to C_FSL_DATA_SIZE-1);
      FSL15_S_CONTROL : in std_logic;
      FSL15_S_EXISTS : in std_logic;
      FSL15_M_CLK : out std_logic;
      FSL15_M_WRITE : out std_logic;
      FSL15_M_DATA : out std_logic_vector(0 to C_FSL_DATA_SIZE-1);
      FSL15_M_CONTROL : out std_logic;
      FSL15_M_FULL : in std_logic;
      ICACHE_FSL_IN_CLK : out std_logic;
      ICACHE_FSL_IN_READ : out std_logic;
      ICACHE_FSL_IN_DATA : in std_logic_vector(0 to 31);
      ICACHE_FSL_IN_CONTROL : in std_logic;
      ICACHE_FSL_IN_EXISTS : in std_logic;
      ICACHE_FSL_OUT_CLK : out std_logic;
      ICACHE_FSL_OUT_WRITE : out std_logic;
      ICACHE_FSL_OUT_DATA : out std_logic_vector(0 to 31);
      ICACHE_FSL_OUT_CONTROL : out std_logic;
      ICACHE_FSL_OUT_FULL : in std_logic;
      DCACHE_FSL_IN_CLK : out std_logic;
      DCACHE_FSL_IN_READ : out std_logic;
      DCACHE_FSL_IN_DATA : in std_logic_vector(0 to 31);
      DCACHE_FSL_IN_CONTROL : in std_logic;
      DCACHE_FSL_IN_EXISTS : in std_logic;
      DCACHE_FSL_OUT_CLK : out std_logic;
      DCACHE_FSL_OUT_WRITE : out std_logic;
      DCACHE_FSL_OUT_DATA : out std_logic_vector(0 to 31);
      DCACHE_FSL_OUT_CONTROL : out std_logic;
      DCACHE_FSL_OUT_FULL : in std_logic
    );
  end component;

begin

  microblaze_0 : microblaze
    generic map (
      C_SCO => 0,
      C_DATA_SIZE => 32,
      C_DYNAMIC_BUS_SIZING => 1,
      C_FAMILY => "virtex5",
      C_INSTANCE => "microblaze_0",
      C_AREA_OPTIMIZED => 0,
      C_INTERCONNECT => 1,
      C_DPLB_DWIDTH => 32,
      C_DPLB_NATIVE_DWIDTH => 32,
      C_DPLB_BURST_EN => 0,
      C_DPLB_P2P => 0,
      C_IPLB_DWIDTH => 32,
      C_IPLB_NATIVE_DWIDTH => 32,
      C_IPLB_BURST_EN => 0,
      C_IPLB_P2P => 0,
      C_D_PLB => 1,
      C_D_OPB => 0,
      C_D_LMB => 1,
      C_I_PLB => 1,
      C_I_OPB => 0,
      C_I_LMB => 1,
      C_USE_MSR_INSTR => 1,
      C_USE_PCMP_INSTR => 1,
      C_USE_BARREL => 0,
      C_USE_DIV => 0,
      C_USE_HW_MUL => 1,
      C_USE_FPU => 0,
      C_UNALIGNED_EXCEPTIONS => 0,
      C_ILL_OPCODE_EXCEPTION => 0,
      C_IOPB_BUS_EXCEPTION => 0,
      C_DOPB_BUS_EXCEPTION => 0,
      C_IPLB_BUS_EXCEPTION => 0,
      C_DPLB_BUS_EXCEPTION => 0,
      C_DIV_ZERO_EXCEPTION => 0,
      C_FPU_EXCEPTION => 0,
      C_FSL_EXCEPTION => 0,
      C_PVR => 0,
      C_PVR_USER1 => X"00",
      C_PVR_USER2 => X"00000000",
      C_DEBUG_ENABLED => 1,
      C_NUMBER_OF_PC_BRK => 1,
      C_NUMBER_OF_RD_ADDR_BRK => 0,
      C_NUMBER_OF_WR_ADDR_BRK => 0,
      C_INTERRUPT_IS_EDGE => 0,
      C_EDGE_IS_POSITIVE => 1,
      C_RESET_MSR => X"00000000",
      C_OPCODE_0x0_ILLEGAL => 0,
      C_FSL_LINKS => 0,
      C_FSL_DATA_SIZE => 32,
      C_USE_EXTENDED_FSL_INSTR => 0,
      C_ICACHE_BASEADDR => X"00000000",
      C_ICACHE_HIGHADDR => X"3FFFFFFF",
      C_USE_ICACHE => 0,
      C_ALLOW_ICACHE_WR => 1,
      C_ADDR_TAG_BITS => 0,
      C_CACHE_BYTE_SIZE => 8192,
      C_ICACHE_USE_FSL => 1,
      C_ICACHE_LINE_LEN => 4,
      C_ICACHE_ALWAYS_USED => 0,
      C_DCACHE_BASEADDR => X"00000000",
      C_DCACHE_HIGHADDR => X"3FFFFFFF",
      C_USE_DCACHE => 0,
      C_ALLOW_DCACHE_WR => 1,
      C_DCACHE_ADDR_TAG => 0,
      C_DCACHE_BYTE_SIZE => 8192,
      C_DCACHE_USE_FSL => 1,
      C_DCACHE_LINE_LEN => 4,
      C_DCACHE_ALWAYS_USED => 0,
      C_USE_MMU => 0,
      C_MMU_DTLB_SIZE => 4,
      C_MMU_ITLB_SIZE => 2,
      C_MMU_TLB_ACCESS => 3,
      C_MMU_ZONES => 16,
      C_USE_INTERRUPT => 0,
      C_USE_EXT_BRK => 1,
      C_USE_EXT_NM_BRK => 1
    )
    port map (
      CLK => CLK,
      RESET => RESET,
      MB_RESET => MB_RESET,
      INTERRUPT => INTERRUPT,
      EXT_BRK => EXT_BRK,
      EXT_NM_BRK => EXT_NM_BRK,
      DBG_STOP => DBG_STOP,
      MB_Halted => MB_Halted,
      INSTR => INSTR,
      I_ADDRTAG => I_ADDRTAG,
      IREADY => IREADY,
      IWAIT => IWAIT,
      INSTR_ADDR => INSTR_ADDR,
      IFETCH => IFETCH,
      I_AS => I_AS,
      IPLB_M_ABort => IPLB_M_ABort,
      IPLB_M_ABus => IPLB_M_ABus,
      IPLB_M_UABus => IPLB_M_UABus,
      IPLB_M_BE => IPLB_M_BE,
      IPLB_M_busLock => IPLB_M_busLock,
      IPLB_M_lockErr => IPLB_M_lockErr,
      IPLB_M_MSize => IPLB_M_MSize,
      IPLB_M_priority => IPLB_M_priority,
      IPLB_M_rdBurst => IPLB_M_rdBurst,
      IPLB_M_request => IPLB_M_request,
      IPLB_M_RNW => IPLB_M_RNW,
      IPLB_M_size => IPLB_M_size,
      IPLB_M_TAttribute => IPLB_M_TAttribute,
      IPLB_M_type => IPLB_M_type,
      IPLB_M_wrBurst => IPLB_M_wrBurst,
      IPLB_M_wrDBus => IPLB_M_wrDBus,
      IPLB_MBusy => IPLB_MBusy,
      IPLB_MRdErr => IPLB_MRdErr,
      IPLB_MWrErr => IPLB_MWrErr,
      IPLB_MIRQ => IPLB_MIRQ,
      IPLB_MWrBTerm => IPLB_MWrBTerm,
      IPLB_MWrDAck => IPLB_MWrDAck,
      IPLB_MAddrAck => IPLB_MAddrAck,
      IPLB_MRdBTerm => IPLB_MRdBTerm,
      IPLB_MRdDAck => IPLB_MRdDAck,
      IPLB_MRdDBus => IPLB_MRdDBus,
      IPLB_MRdWdAddr => IPLB_MRdWdAddr,
      IPLB_MRearbitrate => IPLB_MRearbitrate,
      IPLB_MSSize => IPLB_MSSize,
      IPLB_MTimeout => IPLB_MTimeout,
      DATA_READ => DATA_READ,
      DREADY => DREADY,
      DWAIT => DWAIT,
      DATA_WRITE => DATA_WRITE,
      DATA_ADDR => DATA_ADDR,
      D_ADDRTAG => D_ADDRTAG,
      D_AS => D_AS,
      READ_STROBE => READ_STROBE,
      WRITE_STROBE => WRITE_STROBE,
      BYTE_ENABLE => BYTE_ENABLE,
      DM_ABUS => DM_ABUS,
      DM_BE => DM_BE,
      DM_BUSLOCK => DM_BUSLOCK,
      DM_DBUS => DM_DBUS,
      DM_REQUEST => DM_REQUEST,
      DM_RNW => DM_RNW,
      DM_SELECT => DM_SELECT,
      DM_SEQADDR => DM_SEQADDR,
      DOPB_DBUS => DOPB_DBUS,
      DOPB_ERRACK => DOPB_ERRACK,
      DOPB_MGRANT => DOPB_MGRANT,
      DOPB_RETRY => DOPB_RETRY,
      DOPB_TIMEOUT => DOPB_TIMEOUT,
      DOPB_XFERACK => DOPB_XFERACK,
      DPLB_M_ABort => DPLB_M_ABort,
      DPLB_M_ABus => DPLB_M_ABus,
      DPLB_M_UABus => DPLB_M_UABus,
      DPLB_M_BE => DPLB_M_BE,
      DPLB_M_busLock => DPLB_M_busLock,
      DPLB_M_lockErr => DPLB_M_lockErr,
      DPLB_M_MSize => DPLB_M_MSize,
      DPLB_M_priority => DPLB_M_priority,
      DPLB_M_rdBurst => DPLB_M_rdBurst,
      DPLB_M_request => DPLB_M_request,
      DPLB_M_RNW => DPLB_M_RNW,
      DPLB_M_size => DPLB_M_size,
      DPLB_M_TAttribute => DPLB_M_TAttribute,
      DPLB_M_type => DPLB_M_type,
      DPLB_M_wrBurst => DPLB_M_wrBurst,
      DPLB_M_wrDBus => DPLB_M_wrDBus,
      DPLB_MBusy => DPLB_MBusy,
      DPLB_MRdErr => DPLB_MRdErr,
      DPLB_MWrErr => DPLB_MWrErr,
      DPLB_MIRQ => DPLB_MIRQ,
      DPLB_MWrBTerm => DPLB_MWrBTerm,
      DPLB_MWrDAck => DPLB_MWrDAck,
      DPLB_MAddrAck => DPLB_MAddrAck,
      DPLB_MRdBTerm => DPLB_MRdBTerm,
      DPLB_MRdDAck => DPLB_MRdDAck,
      DPLB_MRdDBus => DPLB_MRdDBus,
      DPLB_MRdWdAddr => DPLB_MRdWdAddr,
      DPLB_MRearbitrate => DPLB_MRearbitrate,
      DPLB_MSSize => DPLB_MSSize,
      DPLB_MTimeout => DPLB_MTimeout,
      IM_ABUS => IM_ABUS,
      IM_BE => IM_BE,
      IM_BUSLOCK => IM_BUSLOCK,
      IM_DBUS => IM_DBUS,
      IM_REQUEST => IM_REQUEST,
      IM_RNW => IM_RNW,
      IM_SELECT => IM_SELECT,
      IM_SEQADDR => IM_SEQADDR,
      IOPB_DBUS => IOPB_DBUS,
      IOPB_ERRACK => IOPB_ERRACK,
      IOPB_MGRANT => IOPB_MGRANT,
      IOPB_RETRY => IOPB_RETRY,
      IOPB_TIMEOUT => IOPB_TIMEOUT,
      IOPB_XFERACK => IOPB_XFERACK,
      DBG_CLK => DBG_CLK,
      DBG_TDI => DBG_TDI,
      DBG_TDO => DBG_TDO,
      DBG_REG_EN => DBG_REG_EN,
      DBG_SHIFT => DBG_SHIFT,
      DBG_CAPTURE => DBG_CAPTURE,
      DBG_UPDATE => DBG_UPDATE,
      DEBUG_RST => DEBUG_RST,
      Trace_Instruction => Trace_Instruction,
      Trace_Valid_Instr => Trace_Valid_Instr,
      Trace_PC => Trace_PC,
      Trace_Reg_Write => Trace_Reg_Write,
      Trace_Reg_Addr => Trace_Reg_Addr,
      Trace_MSR_Reg => Trace_MSR_Reg,
      Trace_PID_Reg => Trace_PID_Reg,
      Trace_New_Reg_Value => Trace_New_Reg_Value,
      Trace_Exception_Taken => Trace_Exception_Taken,
      Trace_Exception_Kind => Trace_Exception_Kind,
      Trace_Jump_Taken => Trace_Jump_Taken,
      Trace_Delay_Slot => Trace_Delay_Slot,
      Trace_Data_Address => Trace_Data_Address,
      Trace_Data_Access => Trace_Data_Access,
      Trace_Data_Read => Trace_Data_Read,
      Trace_Data_Write => Trace_Data_Write,
      Trace_Data_Write_Value => Trace_Data_Write_Value,
      Trace_Data_Byte_Enable => Trace_Data_Byte_Enable,
      Trace_DCache_Req => Trace_DCache_Req,
      Trace_DCache_Hit => Trace_DCache_Hit,
      Trace_ICache_Req => Trace_ICache_Req,
      Trace_ICache_Hit => Trace_ICache_Hit,
      Trace_OF_PipeRun => Trace_OF_PipeRun,
      Trace_EX_PipeRun => Trace_EX_PipeRun,
      Trace_MEM_PipeRun => Trace_MEM_PipeRun,
      Trace_MB_Halted => Trace_MB_Halted,
      FSL0_S_CLK => FSL0_S_CLK,
      FSL0_S_READ => FSL0_S_READ,
      FSL0_S_DATA => FSL0_S_DATA,
      FSL0_S_CONTROL => FSL0_S_CONTROL,
      FSL0_S_EXISTS => FSL0_S_EXISTS,
      FSL0_M_CLK => FSL0_M_CLK,
      FSL0_M_WRITE => FSL0_M_WRITE,
      FSL0_M_DATA => FSL0_M_DATA,
      FSL0_M_CONTROL => FSL0_M_CONTROL,
      FSL0_M_FULL => FSL0_M_FULL,
      FSL1_S_CLK => FSL1_S_CLK,
      FSL1_S_READ => FSL1_S_READ,
      FSL1_S_DATA => FSL1_S_DATA,
      FSL1_S_CONTROL => FSL1_S_CONTROL,
      FSL1_S_EXISTS => FSL1_S_EXISTS,
      FSL1_M_CLK => FSL1_M_CLK,
      FSL1_M_WRITE => FSL1_M_WRITE,
      FSL1_M_DATA => FSL1_M_DATA,
      FSL1_M_CONTROL => FSL1_M_CONTROL,
      FSL1_M_FULL => FSL1_M_FULL,
      FSL2_S_CLK => FSL2_S_CLK,
      FSL2_S_READ => FSL2_S_READ,
      FSL2_S_DATA => FSL2_S_DATA,
      FSL2_S_CONTROL => FSL2_S_CONTROL,
      FSL2_S_EXISTS => FSL2_S_EXISTS,
      FSL2_M_CLK => FSL2_M_CLK,
      FSL2_M_WRITE => FSL2_M_WRITE,
      FSL2_M_DATA => FSL2_M_DATA,
      FSL2_M_CONTROL => FSL2_M_CONTROL,
      FSL2_M_FULL => FSL2_M_FULL,
      FSL3_S_CLK => FSL3_S_CLK,
      FSL3_S_READ => FSL3_S_READ,
      FSL3_S_DATA => FSL3_S_DATA,
      FSL3_S_CONTROL => FSL3_S_CONTROL,
      FSL3_S_EXISTS => FSL3_S_EXISTS,
      FSL3_M_CLK => FSL3_M_CLK,
      FSL3_M_WRITE => FSL3_M_WRITE,
      FSL3_M_DATA => FSL3_M_DATA,
      FSL3_M_CONTROL => FSL3_M_CONTROL,
      FSL3_M_FULL => FSL3_M_FULL,
      FSL4_S_CLK => FSL4_S_CLK,
      FSL4_S_READ => FSL4_S_READ,
      FSL4_S_DATA => FSL4_S_DATA,
      FSL4_S_CONTROL => FSL4_S_CONTROL,
      FSL4_S_EXISTS => FSL4_S_EXISTS,
      FSL4_M_CLK => FSL4_M_CLK,
      FSL4_M_WRITE => FSL4_M_WRITE,
      FSL4_M_DATA => FSL4_M_DATA,
      FSL4_M_CONTROL => FSL4_M_CONTROL,
      FSL4_M_FULL => FSL4_M_FULL,
      FSL5_S_CLK => FSL5_S_CLK,
      FSL5_S_READ => FSL5_S_READ,
      FSL5_S_DATA => FSL5_S_DATA,
      FSL5_S_CONTROL => FSL5_S_CONTROL,
      FSL5_S_EXISTS => FSL5_S_EXISTS,
      FSL5_M_CLK => FSL5_M_CLK,
      FSL5_M_WRITE => FSL5_M_WRITE,
      FSL5_M_DATA => FSL5_M_DATA,
      FSL5_M_CONTROL => FSL5_M_CONTROL,
      FSL5_M_FULL => FSL5_M_FULL,
      FSL6_S_CLK => FSL6_S_CLK,
      FSL6_S_READ => FSL6_S_READ,
      FSL6_S_DATA => FSL6_S_DATA,
      FSL6_S_CONTROL => FSL6_S_CONTROL,
      FSL6_S_EXISTS => FSL6_S_EXISTS,
      FSL6_M_CLK => FSL6_M_CLK,
      FSL6_M_WRITE => FSL6_M_WRITE,
      FSL6_M_DATA => FSL6_M_DATA,
      FSL6_M_CONTROL => FSL6_M_CONTROL,
      FSL6_M_FULL => FSL6_M_FULL,
      FSL7_S_CLK => FSL7_S_CLK,
      FSL7_S_READ => FSL7_S_READ,
      FSL7_S_DATA => FSL7_S_DATA,
      FSL7_S_CONTROL => FSL7_S_CONTROL,
      FSL7_S_EXISTS => FSL7_S_EXISTS,
      FSL7_M_CLK => FSL7_M_CLK,
      FSL7_M_WRITE => FSL7_M_WRITE,
      FSL7_M_DATA => FSL7_M_DATA,
      FSL7_M_CONTROL => FSL7_M_CONTROL,
      FSL7_M_FULL => FSL7_M_FULL,
      FSL8_S_CLK => FSL8_S_CLK,
      FSL8_S_READ => FSL8_S_READ,
      FSL8_S_DATA => FSL8_S_DATA,
      FSL8_S_CONTROL => FSL8_S_CONTROL,
      FSL8_S_EXISTS => FSL8_S_EXISTS,
      FSL8_M_CLK => FSL8_M_CLK,
      FSL8_M_WRITE => FSL8_M_WRITE,
      FSL8_M_DATA => FSL8_M_DATA,
      FSL8_M_CONTROL => FSL8_M_CONTROL,
      FSL8_M_FULL => FSL8_M_FULL,
      FSL9_S_CLK => FSL9_S_CLK,
      FSL9_S_READ => FSL9_S_READ,
      FSL9_S_DATA => FSL9_S_DATA,
      FSL9_S_CONTROL => FSL9_S_CONTROL,
      FSL9_S_EXISTS => FSL9_S_EXISTS,
      FSL9_M_CLK => FSL9_M_CLK,
      FSL9_M_WRITE => FSL9_M_WRITE,
      FSL9_M_DATA => FSL9_M_DATA,
      FSL9_M_CONTROL => FSL9_M_CONTROL,
      FSL9_M_FULL => FSL9_M_FULL,
      FSL10_S_CLK => FSL10_S_CLK,
      FSL10_S_READ => FSL10_S_READ,
      FSL10_S_DATA => FSL10_S_DATA,
      FSL10_S_CONTROL => FSL10_S_CONTROL,
      FSL10_S_EXISTS => FSL10_S_EXISTS,
      FSL10_M_CLK => FSL10_M_CLK,
      FSL10_M_WRITE => FSL10_M_WRITE,
      FSL10_M_DATA => FSL10_M_DATA,
      FSL10_M_CONTROL => FSL10_M_CONTROL,
      FSL10_M_FULL => FSL10_M_FULL,
      FSL11_S_CLK => FSL11_S_CLK,
      FSL11_S_READ => FSL11_S_READ,
      FSL11_S_DATA => FSL11_S_DATA,
      FSL11_S_CONTROL => FSL11_S_CONTROL,
      FSL11_S_EXISTS => FSL11_S_EXISTS,
      FSL11_M_CLK => FSL11_M_CLK,
      FSL11_M_WRITE => FSL11_M_WRITE,
      FSL11_M_DATA => FSL11_M_DATA,
      FSL11_M_CONTROL => FSL11_M_CONTROL,
      FSL11_M_FULL => FSL11_M_FULL,
      FSL12_S_CLK => FSL12_S_CLK,
      FSL12_S_READ => FSL12_S_READ,
      FSL12_S_DATA => FSL12_S_DATA,
      FSL12_S_CONTROL => FSL12_S_CONTROL,
      FSL12_S_EXISTS => FSL12_S_EXISTS,
      FSL12_M_CLK => FSL12_M_CLK,
      FSL12_M_WRITE => FSL12_M_WRITE,
      FSL12_M_DATA => FSL12_M_DATA,
      FSL12_M_CONTROL => FSL12_M_CONTROL,
      FSL12_M_FULL => FSL12_M_FULL,
      FSL13_S_CLK => FSL13_S_CLK,
      FSL13_S_READ => FSL13_S_READ,
      FSL13_S_DATA => FSL13_S_DATA,
      FSL13_S_CONTROL => FSL13_S_CONTROL,
      FSL13_S_EXISTS => FSL13_S_EXISTS,
      FSL13_M_CLK => FSL13_M_CLK,
      FSL13_M_WRITE => FSL13_M_WRITE,
      FSL13_M_DATA => FSL13_M_DATA,
      FSL13_M_CONTROL => FSL13_M_CONTROL,
      FSL13_M_FULL => FSL13_M_FULL,
      FSL14_S_CLK => FSL14_S_CLK,
      FSL14_S_READ => FSL14_S_READ,
      FSL14_S_DATA => FSL14_S_DATA,
      FSL14_S_CONTROL => FSL14_S_CONTROL,
      FSL14_S_EXISTS => FSL14_S_EXISTS,
      FSL14_M_CLK => FSL14_M_CLK,
      FSL14_M_WRITE => FSL14_M_WRITE,
      FSL14_M_DATA => FSL14_M_DATA,
      FSL14_M_CONTROL => FSL14_M_CONTROL,
      FSL14_M_FULL => FSL14_M_FULL,
      FSL15_S_CLK => FSL15_S_CLK,
      FSL15_S_READ => FSL15_S_READ,
      FSL15_S_DATA => FSL15_S_DATA,
      FSL15_S_CONTROL => FSL15_S_CONTROL,
      FSL15_S_EXISTS => FSL15_S_EXISTS,
      FSL15_M_CLK => FSL15_M_CLK,
      FSL15_M_WRITE => FSL15_M_WRITE,
      FSL15_M_DATA => FSL15_M_DATA,
      FSL15_M_CONTROL => FSL15_M_CONTROL,
      FSL15_M_FULL => FSL15_M_FULL,
      ICACHE_FSL_IN_CLK => ICACHE_FSL_IN_CLK,
      ICACHE_FSL_IN_READ => ICACHE_FSL_IN_READ,
      ICACHE_FSL_IN_DATA => ICACHE_FSL_IN_DATA,
      ICACHE_FSL_IN_CONTROL => ICACHE_FSL_IN_CONTROL,
      ICACHE_FSL_IN_EXISTS => ICACHE_FSL_IN_EXISTS,
      ICACHE_FSL_OUT_CLK => ICACHE_FSL_OUT_CLK,
      ICACHE_FSL_OUT_WRITE => ICACHE_FSL_OUT_WRITE,
      ICACHE_FSL_OUT_DATA => ICACHE_FSL_OUT_DATA,
      ICACHE_FSL_OUT_CONTROL => ICACHE_FSL_OUT_CONTROL,
      ICACHE_FSL_OUT_FULL => ICACHE_FSL_OUT_FULL,
      DCACHE_FSL_IN_CLK => DCACHE_FSL_IN_CLK,
      DCACHE_FSL_IN_READ => DCACHE_FSL_IN_READ,
      DCACHE_FSL_IN_DATA => DCACHE_FSL_IN_DATA,
      DCACHE_FSL_IN_CONTROL => DCACHE_FSL_IN_CONTROL,
      DCACHE_FSL_IN_EXISTS => DCACHE_FSL_IN_EXISTS,
      DCACHE_FSL_OUT_CLK => DCACHE_FSL_OUT_CLK,
      DCACHE_FSL_OUT_WRITE => DCACHE_FSL_OUT_WRITE,
      DCACHE_FSL_OUT_DATA => DCACHE_FSL_OUT_DATA,
      DCACHE_FSL_OUT_CONTROL => DCACHE_FSL_OUT_CONTROL,
      DCACHE_FSL_OUT_FULL => DCACHE_FSL_OUT_FULL
    );

end architecture STRUCTURE;

