------------------------------------------------------------------------------
-- registration_core.vhd - entity/architecture pair
------------------------------------------------------------------------------
-- IMPORTANT:
-- DO NOT MODIFY THIS FILE EXCEPT IN THE DESIGNATED SECTIONS.
--
-- SEARCH FOR --USER TO DETERMINE WHERE CHANGES ARE ALLOWED.
--
-- TYPICALLY, THE ONLY ACCEPTABLE CHANGES INVOLVE ADDING NEW
-- PORTS AND GENERICS THAT GET PASSED THROUGH TO THE INSTANTIATION
-- OF THE USER_LOGIC ENTITY.
------------------------------------------------------------------------------
--
-- ***************************************************************************
-- ** Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.            **
-- **                                                                       **
-- ** Xilinx, Inc.                                                          **
-- ** XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"         **
-- ** AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND       **
-- ** SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,        **
-- ** OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,        **
-- ** APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION           **
-- ** THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,     **
-- ** AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE      **
-- ** FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY              **
-- ** WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE               **
-- ** IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR        **
-- ** REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF       **
-- ** INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS       **
-- ** FOR A PARTICULAR PURPOSE.                                             **
-- **                                                                       **
-- ***************************************************************************
--
------------------------------------------------------------------------------
-- Filename:          registration_core.vhd
-- Version:           1.00.a
-- Description:       Top level design, instantiates library components and user logic.
-- Date:              Wed Mar 18 00:17:45 2009 (by Create and Import Peripheral Wizard)
-- VHDL Standard:     VHDL'93
------------------------------------------------------------------------------
-- Naming Conventions:
--   active low signals:                    "*_n"
--   clock signals:                         "clk", "clk_div#", "clk_#x"
--   reset signals:                         "rst", "rst_n"
--   generics:                              "C_*"
--   user defined types:                    "*_TYPE"
--   state machine next state:              "*_ns"
--   state machine current state:           "*_cs"
--   combinatorial signals:                 "*_com"
--   pipelined or register delay signals:   "*_d#"
--   counter signals:                       "*cnt*"
--   clock enable signals:                  "*_ce"
--   internal version of output port:       "*_i"
--   device pins:                           "*_pin"
--   ports:                                 "- Names begin with Uppercase"
--   processes:                             "*_PROCESS"
--   component instantiations:              "<ENTITY_>I_<#|FUNC>"
------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

LIBRARY proc_common_v2_00_a;
USE proc_common_v2_00_a.proc_common_pkg.ALL;
USE proc_common_v2_00_a.ipif_pkg.ALL;

LIBRARY plbv46_slave_single_v1_00_a;
USE plbv46_slave_single_v1_00_a.plbv46_slave_single;

LIBRARY registration_core_v1_00_a;
USE registration_core_v1_00_a.user_logic;

------------------------------------------------------------------------------
-- Entity section
------------------------------------------------------------------------------
-- Definition of Generics:
--   C_BASEADDR                   -- PLBv46 slave: base address
--   C_HIGHADDR                   -- PLBv46 slave: high address
--   C_SPLB_AWIDTH                -- PLBv46 slave: address bus width
--   C_SPLB_DWIDTH                -- PLBv46 slave: data bus width
--   C_SPLB_NUM_MASTERS           -- PLBv46 slave: Number of masters
--   C_SPLB_MID_WIDTH             -- PLBv46 slave: master ID bus width
--   C_SPLB_NATIVE_DWIDTH         -- PLBv46 slave: internal native data bus width
--   C_SPLB_P2P                   -- PLBv46 slave: point to point interconnect scheme
--   C_SPLB_SUPPORT_BURSTS        -- PLBv46 slave: support bursts
--   C_SPLB_SMALLEST_MASTER       -- PLBv46 slave: width of the smallest master
--   C_SPLB_CLK_PERIOD_PS         -- PLBv46 slave: bus clock in picoseconds
--   C_INCLUDE_DPHASE_TIMER       -- PLBv46 slave: Data Phase Timer configuration; 0 = exclude timer, 1 = include timer
--   C_FAMILY                     -- Xilinx FPGA family
--
-- Definition of Ports:
--   SPLB_Clk                     -- PLB main bus clock
--   SPLB_Rst                     -- PLB main bus reset
--   PLB_ABus                     -- PLB address bus
--   PLB_UABus                    -- PLB upper address bus
--   PLB_PAValid                  -- PLB primary address valid indicator
--   PLB_SAValid                  -- PLB secondary address valid indicator
--   PLB_rdPrim                   -- PLB secondary to primary read request indicator
--   PLB_wrPrim                   -- PLB secondary to primary write request indicator
--   PLB_masterID                 -- PLB current master identifier
--   PLB_abort                    -- PLB abort request indicator
--   PLB_busLock                  -- PLB bus lock
--   PLB_RNW                      -- PLB read/not write
--   PLB_BE                       -- PLB byte enables
--   PLB_MSize                    -- PLB master data bus size
--   PLB_size                     -- PLB transfer size
--   PLB_type                     -- PLB transfer type
--   PLB_lockErr                  -- PLB lock error indicator
--   PLB_wrDBus                   -- PLB write data bus
--   PLB_wrBurst                  -- PLB burst write transfer indicator
--   PLB_rdBurst                  -- PLB burst read transfer indicator
--   PLB_wrPendReq                -- PLB write pending bus request indicator
--   PLB_rdPendReq                -- PLB read pending bus request indicator
--   PLB_wrPendPri                -- PLB write pending request priority
--   PLB_rdPendPri                -- PLB read pending request priority
--   PLB_reqPri                   -- PLB current request priority
--   PLB_TAttribute               -- PLB transfer attribute
--   Sl_addrAck                   -- Slave address acknowledge
--   Sl_SSize                     -- Slave data bus size
--   Sl_wait                      -- Slave wait indicator
--   Sl_rearbitrate               -- Slave re-arbitrate bus indicator
--   Sl_wrDAck                    -- Slave write data acknowledge
--   Sl_wrComp                    -- Slave write transfer complete indicator
--   Sl_wrBTerm                   -- Slave terminate write burst transfer
--   Sl_rdDBus                    -- Slave read data bus
--   Sl_rdWdAddr                  -- Slave read word address
--   Sl_rdDAck                    -- Slave read data acknowledge
--   Sl_rdComp                    -- Slave read transfer complete indicator
--   Sl_rdBTerm                   -- Slave terminate read burst transfer
--   Sl_MBusy                     -- Slave busy indicator
--   Sl_MWrErr                    -- Slave write error indicator
--   Sl_MRdErr                    -- Slave read error indicator
--   Sl_MIRQ                      -- Slave interrupt indicator
------------------------------------------------------------------------------

ENTITY registration_core IS
  GENERIC
    (
      -- ADD USER GENERICS BELOW THIS LINE ---------------
      --USER generics added here
      -- ADD USER GENERICS ABOVE THIS LINE ---------------

      -- DO NOT EDIT BELOW THIS LINE ---------------------
      -- Bus protocol parameters, do not add to or delete
      C_BASEADDR             : std_logic_vector := X"FFFFFFFF";
      C_HIGHADDR             : std_logic_vector := X"00000000";
      C_SPLB_AWIDTH          : integer          := 32;
      C_SPLB_DWIDTH          : integer          := 128;
      C_SPLB_NUM_MASTERS     : integer          := 8;
      C_SPLB_MID_WIDTH       : integer          := 3;
      C_SPLB_NATIVE_DWIDTH   : integer          := 32;
      C_SPLB_P2P             : integer          := 0;
      C_SPLB_SUPPORT_BURSTS  : integer          := 0;
      C_SPLB_SMALLEST_MASTER : integer          := 32;
      C_SPLB_CLK_PERIOD_PS   : integer          := 10000;
      C_INCLUDE_DPHASE_TIMER : integer          := 1;
      C_FAMILY               : string           := "virtex5"
      -- DO NOT EDIT ABOVE THIS LINE ---------------------
      );
  PORT
    (
      -- ADD USER PORTS BELOW THIS LINE ------------------
      --USER ports added here
      -- ADD USER PORTS ABOVE THIS LINE ------------------

      -- DO NOT EDIT BELOW THIS LINE ---------------------
      -- Bus protocol ports, do not add to or delete
      SPLB_Clk       : IN  std_logic;
      SPLB_Rst       : IN  std_logic;
      PLB_ABus       : IN  std_logic_vector(0 TO 31);
      PLB_UABus      : IN  std_logic_vector(0 TO 31);
      PLB_PAValid    : IN  std_logic;
      PLB_SAValid    : IN  std_logic;
      PLB_rdPrim     : IN  std_logic;
      PLB_wrPrim     : IN  std_logic;
      PLB_masterID   : IN  std_logic_vector(0 TO C_SPLB_MID_WIDTH-1);
      PLB_abort      : IN  std_logic;
      PLB_busLock    : IN  std_logic;
      PLB_RNW        : IN  std_logic;
      PLB_BE         : IN  std_logic_vector(0 TO C_SPLB_DWIDTH/8-1);
      PLB_MSize      : IN  std_logic_vector(0 TO 1);
      PLB_size       : IN  std_logic_vector(0 TO 3);
      PLB_type       : IN  std_logic_vector(0 TO 2);
      PLB_lockErr    : IN  std_logic;
      PLB_wrDBus     : IN  std_logic_vector(0 TO C_SPLB_DWIDTH-1);
      PLB_wrBurst    : IN  std_logic;
      PLB_rdBurst    : IN  std_logic;
      PLB_wrPendReq  : IN  std_logic;
      PLB_rdPendReq  : IN  std_logic;
      PLB_wrPendPri  : IN  std_logic_vector(0 TO 1);
      PLB_rdPendPri  : IN  std_logic_vector(0 TO 1);
      PLB_reqPri     : IN  std_logic_vector(0 TO 1);
      PLB_TAttribute : IN  std_logic_vector(0 TO 15);
      Sl_addrAck     : OUT std_logic;
      Sl_SSize       : OUT std_logic_vector(0 TO 1);
      Sl_wait        : OUT std_logic;
      Sl_rearbitrate : OUT std_logic;
      Sl_wrDAck      : OUT std_logic;
      Sl_wrComp      : OUT std_logic;
      Sl_wrBTerm     : OUT std_logic;
      Sl_rdDBus      : OUT std_logic_vector(0 TO C_SPLB_DWIDTH-1);
      Sl_rdWdAddr    : OUT std_logic_vector(0 TO 3);
      Sl_rdDAck      : OUT std_logic;
      Sl_rdComp      : OUT std_logic;
      Sl_rdBTerm     : OUT std_logic;
      Sl_MBusy       : OUT std_logic_vector(0 TO C_SPLB_NUM_MASTERS-1);
      Sl_MWrErr      : OUT std_logic_vector(0 TO C_SPLB_NUM_MASTERS-1);
      Sl_MRdErr      : OUT std_logic_vector(0 TO C_SPLB_NUM_MASTERS-1);
      Sl_MIRQ        : OUT std_logic_vector(0 TO C_SPLB_NUM_MASTERS-1);
      -- DO NOT EDIT ABOVE THIS LINE ---------------------
      -- I2C Signals
        I2C_SDA_I : IN std_logic;       -- NOT Used
        I2C_SDA_O : OUT std_logic;      -- Tied to 0
        I2C_SDA_T : OUT std_logic;      -- Actual data signal
        
        I2C_SCL_I : IN std_logic;       -- NOT Used
        I2C_SCL_O : OUT std_logic;      -- Tied to 0
        I2C_SCL_T : OUT std_logic;      -- Actual data signal

      -- DVI Signals
      DVI_D       : OUT std_logic_vector (11 DOWNTO 0);
      DVI_H       : OUT std_logic;
      DVI_V       : OUT std_logic;
      DVI_DE      : OUT std_logic;
      DVI_XCLK_N  : OUT std_logic;
      DVI_XCLK_P  : OUT std_logic;
      DVI_RESET_B : OUT std_logic;

      -- VGA Chip connections
      VGA_PIXEL_CLK : IN std_logic;
      VGA_Y_GREEN   : IN std_logic_vector (7 DOWNTO 0);
      VGA_HSYNC     : IN std_logic;
      VGA_VSYNC     : IN std_logic;

      -- SRAM Connections
      SRAM_CLK_FB : IN  std_logic;
      SRAM_CLK    : OUT std_logic;
      SRAM_ADDR   : OUT std_logic_vector (17 DOWNTO 0);
      SRAM_WE_B   : OUT std_logic;
      SRAM_BW_B   : OUT std_logic_vector (3 DOWNTO 0);
      SRAM_CS_B   : OUT std_logic;
      SRAM_OE_B   : OUT std_logic;
      SRAM_DATA_I : IN  std_logic_vector (35 DOWNTO 0);
      SRAM_DATA_O : OUT std_logic_vector (35 DOWNTO 0);
      SRAM_DATA_T : OUT std_logic;
      GPIO_DIP    : IN  std_logic_vector(7 DOWNTO 0);
      GPIO_SW     : IN  std_logic_vector(4 DOWNTO 0)
      );

  ATTRIBUTE SIGIS             : string;
  ATTRIBUTE SIGIS OF SPLB_Clk : SIGNAL IS "CLK";
  ATTRIBUTE SIGIS OF SPLB_Rst : SIGNAL IS "RST";

END ENTITY registration_core;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

ARCHITECTURE IMP OF registration_core IS

  ------------------------------------------
  -- Array of base/high address pairs for each address range
  ------------------------------------------
  CONSTANT ZERO_ADDR_PAD     : std_logic_vector(0 TO 31) := (OTHERS => '0');
  CONSTANT USER_SLV_BASEADDR : std_logic_vector          := C_BASEADDR;
  CONSTANT USER_SLV_HIGHADDR : std_logic_vector          := C_HIGHADDR;

  CONSTANT IPIF_ARD_ADDR_RANGE_ARRAY : SLV64_ARRAY_TYPE :=
    (
      ZERO_ADDR_PAD & USER_SLV_BASEADDR,  -- user logic slave space base address
      ZERO_ADDR_PAD & USER_SLV_HIGHADDR  -- user logic slave space high address
      );

  ------------------------------------------
  -- Array of desired number of chip enables for each address range
  ------------------------------------------
  CONSTANT USER_SLV_NUM_REG : integer := 3;
  CONSTANT USER_NUM_REG     : integer := USER_SLV_NUM_REG;

  CONSTANT IPIF_ARD_NUM_CE_ARRAY : INTEGER_ARRAY_TYPE :=
    (
      0 => pad_power2(USER_SLV_NUM_REG)  -- number of ce for user logic slave space
      );

  ------------------------------------------
  -- Ratio of bus clock to core clock (for use in dual clock systems)
  -- 1 = ratio is 1:1
  -- 2 = ratio is 2:1
  ------------------------------------------
  CONSTANT IPIF_BUS2CORE_CLK_RATIO : integer := 1;

  ------------------------------------------
  -- Width of the slave data bus (32 only)
  ------------------------------------------
  CONSTANT USER_SLV_DWIDTH : integer := C_SPLB_NATIVE_DWIDTH;

  CONSTANT IPIF_SLV_DWIDTH : integer := C_SPLB_NATIVE_DWIDTH;

  ------------------------------------------
  -- Index for CS/CE
  ------------------------------------------
  CONSTANT USER_SLV_CS_INDEX : integer := 0;
  CONSTANT USER_SLV_CE_INDEX : integer := calc_start_ce_index(IPIF_ARD_NUM_CE_ARRAY, USER_SLV_CS_INDEX);

  CONSTANT USER_CE_INDEX : integer := USER_SLV_CE_INDEX;

  ------------------------------------------
  -- IP Interconnect (IPIC) signal declarations
  ------------------------------------------
  SIGNAL ipif_Bus2IP_Clk   : std_logic;
  SIGNAL ipif_Bus2IP_Reset : std_logic;
  SIGNAL ipif_IP2Bus_Data  : std_logic_vector(0 TO IPIF_SLV_DWIDTH-1);
  SIGNAL ipif_IP2Bus_WrAck : std_logic;
  SIGNAL ipif_IP2Bus_RdAck : std_logic;
  SIGNAL ipif_IP2Bus_Error : std_logic;
  SIGNAL ipif_Bus2IP_Addr  : std_logic_vector(0 TO C_SPLB_AWIDTH-1);
  SIGNAL ipif_Bus2IP_Data  : std_logic_vector(0 TO IPIF_SLV_DWIDTH-1);
  SIGNAL ipif_Bus2IP_RNW   : std_logic;
  SIGNAL ipif_Bus2IP_BE    : std_logic_vector(0 TO IPIF_SLV_DWIDTH/8-1);
  SIGNAL ipif_Bus2IP_CS    : std_logic_vector(0 TO ((IPIF_ARD_ADDR_RANGE_ARRAY'length)/2)-1);
  SIGNAL ipif_Bus2IP_RdCE  : std_logic_vector(0 TO calc_num_ce(IPIF_ARD_NUM_CE_ARRAY)-1);
  SIGNAL ipif_Bus2IP_WrCE  : std_logic_vector(0 TO calc_num_ce(IPIF_ARD_NUM_CE_ARRAY)-1);
  SIGNAL user_Bus2IP_RdCE  : std_logic_vector(0 TO USER_NUM_REG-1);
  SIGNAL user_Bus2IP_WrCE  : std_logic_vector(0 TO USER_NUM_REG-1);
  SIGNAL user_IP2Bus_Data  : std_logic_vector(0 TO USER_SLV_DWIDTH-1);
  SIGNAL user_IP2Bus_RdAck : std_logic;
  SIGNAL user_IP2Bus_WrAck : std_logic;
  SIGNAL user_IP2Bus_Error : std_logic;

BEGIN

  ------------------------------------------
  -- instantiate plbv46_slave_single
  ------------------------------------------
  PLBV46_SLAVE_SINGLE_I : ENTITY plbv46_slave_single_v1_00_a.plbv46_slave_single
    GENERIC MAP
    (
      C_ARD_ADDR_RANGE_ARRAY => IPIF_ARD_ADDR_RANGE_ARRAY,
      C_ARD_NUM_CE_ARRAY     => IPIF_ARD_NUM_CE_ARRAY,
      C_SPLB_P2P             => C_SPLB_P2P,
      C_BUS2CORE_CLK_RATIO   => IPIF_BUS2CORE_CLK_RATIO,
      C_SPLB_MID_WIDTH       => C_SPLB_MID_WIDTH,
      C_SPLB_NUM_MASTERS     => C_SPLB_NUM_MASTERS,
      C_SPLB_AWIDTH          => C_SPLB_AWIDTH,
      C_SPLB_DWIDTH          => C_SPLB_DWIDTH,
      C_SIPIF_DWIDTH         => IPIF_SLV_DWIDTH,
      C_INCLUDE_DPHASE_TIMER => C_INCLUDE_DPHASE_TIMER,
      C_FAMILY               => C_FAMILY
      )
    PORT MAP
    (
      SPLB_Clk       => SPLB_Clk,
      SPLB_Rst       => SPLB_Rst,
      PLB_ABus       => PLB_ABus,
      PLB_UABus      => PLB_UABus,
      PLB_PAValid    => PLB_PAValid,
      PLB_SAValid    => PLB_SAValid,
      PLB_rdPrim     => PLB_rdPrim,
      PLB_wrPrim     => PLB_wrPrim,
      PLB_masterID   => PLB_masterID,
      PLB_abort      => PLB_abort,
      PLB_busLock    => PLB_busLock,
      PLB_RNW        => PLB_RNW,
      PLB_BE         => PLB_BE,
      PLB_MSize      => PLB_MSize,
      PLB_size       => PLB_size,
      PLB_type       => PLB_type,
      PLB_lockErr    => PLB_lockErr,
      PLB_wrDBus     => PLB_wrDBus,
      PLB_wrBurst    => PLB_wrBurst,
      PLB_rdBurst    => PLB_rdBurst,
      PLB_wrPendReq  => PLB_wrPendReq,
      PLB_rdPendReq  => PLB_rdPendReq,
      PLB_wrPendPri  => PLB_wrPendPri,
      PLB_rdPendPri  => PLB_rdPendPri,
      PLB_reqPri     => PLB_reqPri,
      PLB_TAttribute => PLB_TAttribute,
      Sl_addrAck     => Sl_addrAck,
      Sl_SSize       => Sl_SSize,
      Sl_wait        => Sl_wait,
      Sl_rearbitrate => Sl_rearbitrate,
      Sl_wrDAck      => Sl_wrDAck,
      Sl_wrComp      => Sl_wrComp,
      Sl_wrBTerm     => Sl_wrBTerm,
      Sl_rdDBus      => Sl_rdDBus,
      Sl_rdWdAddr    => Sl_rdWdAddr,
      Sl_rdDAck      => Sl_rdDAck,
      Sl_rdComp      => Sl_rdComp,
      Sl_rdBTerm     => Sl_rdBTerm,
      Sl_MBusy       => Sl_MBusy,
      Sl_MWrErr      => Sl_MWrErr,
      Sl_MRdErr      => Sl_MRdErr,
      Sl_MIRQ        => Sl_MIRQ,
      Bus2IP_Clk     => ipif_Bus2IP_Clk,
      Bus2IP_Reset   => ipif_Bus2IP_Reset,
      IP2Bus_Data    => ipif_IP2Bus_Data,
      IP2Bus_WrAck   => ipif_IP2Bus_WrAck,
      IP2Bus_RdAck   => ipif_IP2Bus_RdAck,
      IP2Bus_Error   => ipif_IP2Bus_Error,
      Bus2IP_Addr    => ipif_Bus2IP_Addr,
      Bus2IP_Data    => ipif_Bus2IP_Data,
      Bus2IP_RNW     => ipif_Bus2IP_RNW,
      Bus2IP_BE      => ipif_Bus2IP_BE,
      Bus2IP_CS      => ipif_Bus2IP_CS,
      Bus2IP_RdCE    => ipif_Bus2IP_RdCE,
      Bus2IP_WrCE    => ipif_Bus2IP_WrCE
      );

  ------------------------------------------
  -- instantiate User Logic
  ------------------------------------------
  USER_LOGIC_I : ENTITY registration_core_v1_00_a.user_logic
    GENERIC MAP
    (
      -- MAP USER GENERICS BELOW THIS LINE ---------------
      --USER generics mapped here
      -- MAP USER GENERICS ABOVE THIS LINE ---------------

      C_SLV_DWIDTH => USER_SLV_DWIDTH,
      C_NUM_REG    => USER_NUM_REG
      )
    PORT MAP
    (
      -- MAP USER PORTS BELOW THIS LINE ------------------
      --USER ports mapped here

      GPIO_SW       => GPIO_SW,
      GPIO_DIP      => GPIO_DIP,
          I2C_SDA_I => i2c_sda_i,
    I2C_SDA_O => i2c_sda_o,
    I2C_SDA_T => i2c_sda_t,
    I2C_SCL_I => i2c_scl_i,
    I2C_SCL_O => i2c_scl_o,
    I2C_SCL_T => i2c_scl_t,
      DVI_D         => DVI_D,
      DVI_H         => DVI_H,
      DVI_V         => DVI_V,
      DVI_DE        => DVI_DE,
      DVI_XCLK_N    => DVI_XCLK_N,
      DVI_XCLK_P    => DVI_XCLK_P,
      DVI_RESET_B   => DVI_RESET_B,
      VGA_PIXEL_CLK => VGA_PIXEL_CLK,
      VGA_Y_GREEN   => VGA_Y_GREEN,
      VGA_HSYNC     => VGA_HSYNC,
      VGA_VSYNC     => VGA_VSYNC,
      SRAM_CLK_FB   => SRAM_CLK_FB,
      SRAM_CLK      => SRAM_CLK,
      SRAM_ADDR     => SRAM_ADDR,
      SRAM_WE_B     => SRAM_WE_B,
      SRAM_BW_B     => SRAM_BW_B,
      SRAM_CS_B     => SRAM_CS_B,
      SRAM_OE_B     => SRAM_OE_B,
      SRAM_DATA_I   => SRAM_DATA_I,
      SRAM_DATA_O   => SRAM_DATA_O,
      SRAM_DATA_T   => SRAM_DATA_T,
      -- MAP USER PORTS ABOVE THIS LINE ------------------

      Bus2IP_Clk   => ipif_Bus2IP_Clk,
      Bus2IP_Reset => ipif_Bus2IP_Reset,
      Bus2IP_Data  => ipif_Bus2IP_Data,
      Bus2IP_BE    => ipif_Bus2IP_BE,
      Bus2IP_RdCE  => user_Bus2IP_RdCE,
      Bus2IP_WrCE  => user_Bus2IP_WrCE,
      IP2Bus_Data  => user_IP2Bus_Data,
      IP2Bus_RdAck => user_IP2Bus_RdAck,
      IP2Bus_WrAck => user_IP2Bus_WrAck,
      IP2Bus_Error => user_IP2Bus_Error
      );

  ------------------------------------------
  -- connect internal signals
  ------------------------------------------
  ipif_IP2Bus_Data  <= user_IP2Bus_Data;
  ipif_IP2Bus_WrAck <= user_IP2Bus_WrAck;
  ipif_IP2Bus_RdAck <= user_IP2Bus_RdAck;
  ipif_IP2Bus_Error <= user_IP2Bus_Error;

  user_Bus2IP_RdCE <= ipif_Bus2IP_RdCE(USER_CE_INDEX TO USER_CE_INDEX+USER_NUM_REG-1);
  user_Bus2IP_WrCE <= ipif_Bus2IP_WrCE(USER_CE_INDEX TO USER_CE_INDEX+USER_NUM_REG-1);

END IMP;
