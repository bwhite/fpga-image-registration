------------------------------------------------------------------------------
-- user_logic.vhd - entity/architecture pair
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
-- Filename:          user_logic.vhd
-- Version:           1.00.a
-- Description:       User logic.
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

-- DO NOT EDIT BELOW THIS LINE --------------------
LIBRARY ieee;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_1164.ALL;

LIBRARY proc_common_v2_00_a;
USE proc_common_v2_00_a.proc_common_pkg.ALL;

-- DO NOT EDIT ABOVE THIS LINE --------------------

--USER libraries added here

------------------------------------------------------------------------------
-- Entity section
------------------------------------------------------------------------------
-- Definition of Generics:
--   C_SLV_DWIDTH                 -- Slave interface data bus width
--   C_NUM_REG                    -- Number of software accessible registers
--
-- Definition of Ports:
--   Bus2IP_Clk                   -- Bus to IP clock
--   Bus2IP_Reset                 -- Bus to IP reset
--   Bus2IP_Data                  -- Bus to IP data bus
--   Bus2IP_BE                    -- Bus to IP byte enables
--   Bus2IP_RdCE                  -- Bus to IP read chip enable
--   Bus2IP_WrCE                  -- Bus to IP write chip enable
--   IP2Bus_Data                  -- IP to Bus data bus
--   IP2Bus_RdAck                 -- IP to Bus read transfer acknowledgement
--   IP2Bus_WrAck                 -- IP to Bus write transfer acknowledgement
--   IP2Bus_Error                 -- IP to Bus error response
------------------------------------------------------------------------------

ENTITY user_logic IS
  GENERIC
    (
      -- ADD USER GENERICS BELOW THIS LINE ---------------
      --USER generics added here
      -- ADD USER GENERICS ABOVE THIS LINE ---------------

      -- DO NOT EDIT BELOW THIS LINE ---------------------
      -- Bus protocol parameters, do not add to or delete
      C_SLV_DWIDTH : integer := 32;
      C_NUM_REG    : integer := 3
      -- DO NOT EDIT ABOVE THIS LINE ---------------------
      );
  PORT
    (
      -- ADD USER PORTS BELOW THIS LINE ------------------
      --USER ports added here
      -- ADD USER PORTS ABOVE THIS LINE ------------------
      GPIO_SW   : IN  std_logic_vector(4 DOWNTO 0);
      GPIO_DIP  : IN  std_logic_vector(7 DOWNTO 0);
      I2C_SDA_I : IN  std_logic;        -- NOT Used
      I2C_SDA_O : OUT std_logic;        -- Tied to 0
      I2C_SDA_T : OUT std_logic;        -- Actual data signal

      I2C_SCL_I : IN  std_logic;        -- NOT Used
      I2C_SCL_O : OUT std_logic;        -- Tied to 0
      I2C_SCL_T : OUT std_logic;        -- Actual data signal


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
      SRAM_CLK_FB  : IN  std_logic;
      SRAM_CLK     : OUT std_logic;
      SRAM_ADDR    : OUT std_logic_vector (17 DOWNTO 0);
      SRAM_WE_B    : OUT std_logic;
      SRAM_BW_B    : OUT std_logic_vector (3 DOWNTO 0);
      SRAM_CS_B    : OUT std_logic;
      SRAM_OE_B    : OUT std_logic;
      SRAM_DATA_I  : IN  std_logic_vector (35 DOWNTO 0);
      SRAM_DATA_O  : OUT std_logic_vector (35 DOWNTO 0);
      SRAM_DATA_T  : OUT std_logic;
      -- DO NOT EDIT BELOW THIS LINE ---------------------
      -- Bus protocol ports, do not add to or delete
      Bus2IP_Clk   : IN  std_logic;
      Bus2IP_Reset : IN  std_logic;
      Bus2IP_Data  : IN  std_logic_vector(0 TO C_SLV_DWIDTH-1);
      Bus2IP_BE    : IN  std_logic_vector(0 TO C_SLV_DWIDTH/8-1);
      Bus2IP_RdCE  : IN  std_logic_vector(0 TO C_NUM_REG-1);
      Bus2IP_WrCE  : IN  std_logic_vector(0 TO C_NUM_REG-1);
      IP2Bus_Data  : OUT std_logic_vector(0 TO C_SLV_DWIDTH-1);
      IP2Bus_RdAck : OUT std_logic;
      IP2Bus_WrAck : OUT std_logic;
      IP2Bus_Error : OUT std_logic
      -- DO NOT EDIT ABOVE THIS LINE ---------------------
      );

  ATTRIBUTE SIGIS                 : string;
  ATTRIBUTE SIGIS OF Bus2IP_Clk   : SIGNAL IS "CLK";
  ATTRIBUTE SIGIS OF Bus2IP_Reset : SIGNAL IS "RST";

END ENTITY user_logic;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

ARCHITECTURE IMP OF user_logic IS

  --USER signal declarations added here, as needed for user logic

  COMPONENT demo_low_level IS
    GENERIC (
      IMGSIZE_BITS : integer := 10;
      PIXEL_BITS   : integer := 9);
    PORT (CLK : IN std_logic;

          -- IO
          RST      : IN std_logic;
          GPIO_SW  : IN std_logic_vector(4 DOWNTO 0);
          GPIO_DIP : IN std_logic_vector(7 DOWNTO 0);

          -- I2C Signals
          I2C_SDA_I : IN  std_logic;    -- NOT Used
          I2C_SDA_O : OUT std_logic;    -- Tied to 0
          I2C_SDA_T : OUT std_logic;    -- Actual data signal

          I2C_SCL_I : IN  std_logic;    -- NOT Used
          I2C_SCL_O : OUT std_logic;    -- Tied to 0
          I2C_SCL_T : OUT std_logic;    -- Actual data signal

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
          --SRAM_DATA : INOUT std_logic_vector (35 DOWNTO 0)
          SRAM_DATA_I : IN  std_logic_vector (35 DOWNTO 0);
          SRAM_DATA_O : OUT std_logic_vector (35 DOWNTO 0);
          SRAM_DATA_T : OUT std_logic;
          H_0_0       : OUT std_logic_vector(29 DOWNTO 0);
          H_0_1       : OUT std_logic_vector(29 DOWNTO 0);
          H_0_2       : OUT std_logic_vector(29 DOWNTO 0);
          H_1_0       : OUT std_logic_vector(29 DOWNTO 0);
          H_1_1       : OUT std_logic_vector(29 DOWNTO 0);
          H_1_2       : OUT std_logic_vector(29 DOWNTO 0);
          BUSY        : OUT std_logic;
          OUT_STATE   : OUT std_logic_vector(2 DOWNTO 0));
  END COMPONENT;


  ------------------------------------------
  -- Signals for user logic slave model s/w accessible register example
  ------------------------------------------
  SIGNAL slv_reg0                                 : std_logic_vector(C_SLV_DWIDTH-1 DOWNTO 0);
  SIGNAL slv_reg1                                 : std_logic_vector(C_SLV_DWIDTH-1 DOWNTO 0);
  SIGNAL slv_reg2                                 : std_logic_vector(C_SLV_DWIDTH-1 DOWNTO 0);
  SIGNAL slv_reg_write_sel                        : std_logic_vector(0 TO 2);
  SIGNAL slv_reg_read_sel                         : std_logic_vector(0 TO 2);
  SIGNAL slv_ip2bus_data                          : std_logic_vector(0 TO C_SLV_DWIDTH-1);
  SIGNAL slv_read_ack                             : std_logic;
  SIGNAL slv_write_ack                            : std_logic;
  SIGNAL h_0_0, h_0_1, h_0_2, h_1_0, h_1_1, h_1_2 : std_logic_vector(29 DOWNTO 0);
  SIGNAL busy                                     : std_logic;
  SIGNAL OUT_STATE                                : std_logic_vector(31 DOWNTO 0);
  SIGNAL cur_h                                    : std_logic_vector(31 DOWNTO 0);
  signal rst_not : std_logic;
BEGIN
	rst_not <= not Bus2IP_Reset;
  --USER logic implementation added here
  demo_low_level_i : demo_low_level
    PORT MAP (
      CLK           => Bus2IP_Clk,
      RST           => rst_not,
      GPIO_SW       => slv_reg0(12 downto 8),  --slv_reg0(byte_index*8 TO byte_index*8+7)
      GPIO_DIP      => slv_reg0(7 downto 0),   --GPIO_DIP,
      I2C_SDA_I     => I2C_SDA_I,
      I2C_SDA_O     => I2C_SDA_O,
      I2C_SDA_T     => I2C_SDA_T,
      I2C_SCL_I     => I2C_SCL_I,
      I2C_SCL_O     => I2C_SCL_O,
      I2C_SCL_T     => I2C_SCL_T,
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
      H_0_0         => h_0_0,
      H_0_1         => h_0_1,
      H_0_2         => h_0_2,
      H_1_0         => h_1_0,
      H_1_1         => h_1_1,
      H_1_2         => h_1_2,
      BUSY          => busy,
      out_state     => out_state(2 DOWNTO 0)
      );

  PROCESS (slv_reg0) IS
  BEGIN  -- PROCESS
    CASE slv_reg0(18 downto 16) IS
      WHEN "000" =>
        cur_h <= (1 DOWNTO 0 => h_0_0(29))&h_0_0;
      WHEN "001" =>
        cur_h <= (1 DOWNTO 0 => h_1_0(29))&h_1_0;
      WHEN "010" =>
        cur_h <= (1 DOWNTO 0 => h_0_1(29))&h_0_1;
      WHEN "011" =>
        cur_h <= (1 DOWNTO 0 => h_1_1(29))&h_1_1;
      WHEN "100" =>
        cur_h <= (1 DOWNTO 0 => h_0_2(29))&h_0_2;
      WHEN "101" =>
        cur_h <= (1 DOWNTO 0 => h_1_2(29))&h_1_2;
      WHEN OTHERS =>
        cur_h <= (1 DOWNTO 0 => h_0_0(29))&h_0_0;
    END CASE;
  END PROCESS;


  --                     "0010"   C_BASEADDR + 0x8
  --                     "0001"   C_BASEADDR + 0xC
  -- 
  ------------------------------------------
  slv_reg_write_sel <= Bus2IP_WrCE(0 TO 2);
  slv_reg_read_sel  <= Bus2IP_RdCE(0 TO 2);
  slv_write_ack     <= Bus2IP_WrCE(0) OR Bus2IP_WrCE(1) OR Bus2IP_WrCE(2);
  slv_read_ack      <= Bus2IP_RdCE(0) OR Bus2IP_RdCE(1) OR Bus2IP_RdCE(2);

  -- implement slave model software accessible register(s)
  SLAVE_REG_WRITE_PROC : PROCESS(Bus2IP_Clk) IS
  BEGIN

    IF Bus2IP_Clk'event AND Bus2IP_Clk = '1' THEN
      IF Bus2IP_Reset = '1' THEN
        slv_reg0 <= (OTHERS => '0');
        slv_reg1 <= (OTHERS => '0');
        slv_reg2 <= (OTHERS => '0');
      ELSE
        CASE slv_reg_write_sel IS
          WHEN "100" =>
            FOR i IN 31 downto 0 LOOP
              slv_reg0(i) <= Bus2IP_Data(31-i);
            END LOOP;
          WHEN "010" =>
            FOR i IN 31 DOWNTO 0 LOOP
              slv_reg1(i) <= Bus2IP_Data(31-i);
            END LOOP;
          WHEN "001" =>
            FOR i IN 31 DOWNTO 0 LOOP
              slv_reg2(i) <= Bus2IP_Data(31-i);
            END LOOP;
          WHEN OTHERS => NULL;
        END CASE;
      END IF;
    END IF;
--          FOR byte_index IN 0 TO (C_SLV_DWIDTH/8)-1 LOOP
--                slv_reg1(byte_index*8 TO byte_index*8+7) <= Bus2IP_Data(byte_index*8 TO byte_index*8+7);
--          END LOOP;

  END PROCESS SLAVE_REG_WRITE_PROC;

  -- implement slave model software accessible register(s) read mux
  SLAVE_REG_READ_PROC : PROCESS(slv_reg_read_sel, slv_reg0, slv_reg1, slv_reg2) IS
  BEGIN

    CASE slv_reg_read_sel IS
      WHEN "100" =>
          --std_logic_vector(unsigned(slv_reg0)+1);
        FOR i IN 31 DOWNTO 0 LOOP
          slv_ip2bus_data(i) <= slv_reg0(31-i);
        END LOOP;
      WHEN "010" =>
        FOR i IN 31 DOWNTO 0 LOOP
          slv_ip2bus_data(i) <= out_state(31-i);  --std_logic_vector(unsigned(slv_reg1)+1);
        END LOOP;
      WHEN "001" =>
        FOR i IN 31 DOWNTO 0 LOOP
          slv_ip2bus_data(i) <= cur_h(31-i);
        END LOOP;
                                        --Sign extend
      WHEN OTHERS => slv_ip2bus_data <= (OTHERS => '0');
    END CASE;

  END PROCESS SLAVE_REG_READ_PROC;

  ------------------------------------------
  -- Example code to drive IP to Bus signals
  ------------------------------------------
  IP2Bus_Data <= slv_ip2bus_data WHEN slv_read_ack = '1' ELSE
                 (OTHERS => '0');

  IP2Bus_WrAck <= slv_write_ack;
  IP2Bus_RdAck <= slv_read_ack;
  IP2Bus_Error <= '0';

END IMP;
