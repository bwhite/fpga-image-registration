-- Module Name:  vhdl_controller_functional_test.vhd
-- File Description:  Playground for ZBT ram testing.
-- Project:  FPGA Image Registration
-- Target Device:  XC5VSX50T (Xilinx Virtex5 SXT)
-- Target Board:  ML506
-- Synthesis Tool:  Xilinx ISE 9.2
-- Copyright (C) 2008 Brandyn Allen White
-- Contact:  bwhite(at)cs.ucf.edu
-- Project Website:  http://code.google.com/p/fpga-image-registration/

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see <http://www.gnu.org/licenses/>.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

LIBRARY UNISIM;
USE UNISIM.VComponents.ALL;

ENTITY vhdl_controller_functional_test IS
  PORT (CLK_P : IN std_logic;
        CLK_N : IN std_logic;
        RST   : IN std_logic;           -- Active low reset

        -- SRAM Connections
        SRAM_CLK_FB : IN    std_logic;
        SRAM_CLK    : OUT   std_logic;
        SRAM_ADDR   : OUT   std_logic_vector (17 DOWNTO 0);
        SRAM_WE_B   : OUT   std_logic;
        SRAM_BW_B   : OUT   std_logic_vector (3 DOWNTO 0);
        SRAM_CS_B   : OUT   std_logic;
        SRAM_OE_B   : OUT   std_logic;
        SRAM_DATA   : INOUT std_logic_vector (35 DOWNTO 0));
END vhdl_controller_functional_test;

ARCHITECTURE Behavioral OF vhdl_controller_functional_test IS
  COMPONENT pipeline_buffer IS
    GENERIC (
      WIDTH         : integer := 1;
      STAGES        : integer := 1;
      DEFAULT_VALUE : integer := 2#0#);
    PORT (CLK   : IN  std_logic;
          RST   : IN  std_logic;
          CLKEN : IN  std_logic;
          DIN   : IN  std_logic_vector(WIDTH-1 DOWNTO 0);
          DOUT  : OUT std_logic_vector(WIDTH-1 DOWNTO 0));
  END COMPONENT;

  COMPONENT pipeline_bit_buffer IS
    GENERIC (
      STAGES : integer := 1);
    PORT (CLK   : IN  std_logic;
          RST   : IN  std_logic;
          SET   : IN  std_logic;
          CLKEN : IN  std_logic;
          DIN   : IN  std_logic;
          DOUT  : OUT std_logic);
  END COMPONENT;
  COMPONENT pixel_memory_controller IS
    PORT (CLK : IN std_logic;
          RST : IN std_logic;

          -- Control signals
          ADDR             : IN  std_logic_vector (19 DOWNTO 0);
          ADDR_OFF         : IN  std_logic_vector (19 DOWNTO 0);
          WE_B             : IN  std_logic;
          CS_B             : IN  std_logic;
          PIXEL_WRITE      : IN  std_logic_vector (8 DOWNTO 0);
          PIXEL_READ       : OUT std_logic_vector(8 DOWNTO 0);
          PIXEL_READ_VALID : OUT std_logic;

          -- SRAM Connections
          SRAM_ADDR : OUT   std_logic_vector (17 DOWNTO 0);
          SRAM_WE_B : OUT   std_logic;
          SRAM_BW_B : OUT   std_logic_vector (3 DOWNTO 0);
          SRAM_CS_B : OUT   std_logic;
          SRAM_OE_B : OUT   std_logic;
          SRAM_DATA : INOUT std_logic_vector (35 DOWNTO 0));
  END COMPONENT;

  SIGNAL clk, clk_predcm, clk_int, clk_intbuf, data_read_valid, sram_int_clk, cs_sram_ok, cs_data_read_valid : std_logic;
  SIGNAL data_write, data_read                                                                                                   : std_logic_vector (8 DOWNTO 0);
  SIGNAL we_b                                                                                                                    : std_logic;
  SIGNAL addr                                                                                                                    : std_logic_vector (19 DOWNTO 0);
  SIGNAL data_count                                                                                                              : std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');
  SIGNAL addr0, addr1, addr2, addr3                                                                                              : std_logic_vector(19 DOWNTO 0);
  SIGNAL data0, data1, data2, data3, data_expected_read, data_expected_read_buf, cs_data_read,cs_data_write, cs_data_expected_read_buf                                                  : std_logic_vector(8 DOWNTO 0);
  ATTRIBUTE KEEP                        : string;
  ATTRIBUTE KEEP OF cs_sram_ok, cs_data_read,cs_data_write,cs_data_expected_read_buf, cs_data_read_valid    : SIGNAL IS "TRUE";
BEGIN
  addr0 <= "00110011111011000100";
  addr1 <= "10010111011110010001";
  addr2 <= "00000000000000000010";
  addr3 <= "11111111111111111111";

  data0 <= "110000001";
  data1 <= "011101010";
  data2 <= "000000000";
  data3 <= "111111111";

-------------------------------------------------------------------------------
  --This is the differential input clock BUFFER
  IBUFGDS_inst : IBUFGDS
    GENERIC MAP (
      IOSTANDARD => "DEFAULT")
    PORT MAP (
      O  => clk_predcm,                 -- Clock buffer output
      I  => CLK_P,                      -- Diff_p clock buffer input
      IB => CLK_N                       -- Diff_n clock buffer input
      );

  DCM_BASE_freq : DCM_BASE
    GENERIC MAP (
      CLKIN_PERIOD          => 5.0,  -- Specify period of input clock in ns from 1.25 to 1000.00
      CLK_FEEDBACK          => "1X",    -- Specify clock feedback of NONE or 1X
      DCM_AUTOCALIBRATION   => true,   -- DCM calibrartion circuitry TRUE/FALSE
      DCM_PERFORMANCE_MODE  => "MAX_SPEED",  -- Can be MAX_SPEED or MAX_RANGE
      DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",  -- SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
                                        --   an integer from 0 to 15
      DFS_FREQUENCY_MODE    => "HIGH",  -- LOW or HIGH frequency mode for frequency synthesis
      DLL_FREQUENCY_MODE    => "HIGH",  -- LOW, HIGH, or HIGH_SER frequency mode for DLL
      DUTY_CYCLE_CORRECTION => true,    -- Duty cycle correction, TRUE or FALSE
      FACTORY_JF            => X"F0F0",  -- FACTORY JF Values Suggested to be set to X"F0F0"
      STARTUP_WAIT          => false)  -- Delay configuration DONE until DCM LOCK, TRUE/FALSE
    PORT MAP (
      CLK0  => clk,                 -- 0 degree DCM CLK ouptput
      CLKFB => clk,                 -- DCM clock feedback
      CLKIN => clk_predcm,        -- Clock input (from IBUFG, BUFG or DCM)
      RST   => '0'                  -- DCM asynchronous reset input
      );


  DCM_BASE_internal : DCM_BASE
    GENERIC MAP (
      CLKIN_PERIOD          => 5.0,  -- Specify period of input clock in ns from 1.25 to 1000.00
      CLK_FEEDBACK          => "1X",    -- Specify clock feedback of NONE or 1X
      DCM_AUTOCALIBRATION   => true,   -- DCM calibrartion circuitry TRUE/FALSE
      DCM_PERFORMANCE_MODE  => "MAX_SPEED",  -- Can be MAX_SPEED or MAX_RANGE
      DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",  -- SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
                                        --   an integer from 0 to 15
      DFS_FREQUENCY_MODE    => "HIGH",  -- LOW or HIGH frequency mode for frequency synthesis
      DLL_FREQUENCY_MODE    => "HIGH",  -- LOW, HIGH, or HIGH_SER frequency mode for DLL
      DUTY_CYCLE_CORRECTION => true,    -- Duty cycle correction, TRUE or FALSE
      FACTORY_JF            => X"F0F0",  -- FACTORY JF Values Suggested to be set to X"F0F0" 
      STARTUP_WAIT          => false)  -- Delay configuration DONE until DCM LOCK, TRUE/FALSE
    PORT MAP (
      CLK0  => clk_int,                 -- 0 degree DCM CLK ouptput
      CLKFB => clk_intbuf,              -- DCM clock feedback
      CLKIN => clk,           -- Clock input (from IBUFG, BUFG or DCM)
      RST   => '0'                      -- DCM asynchronous reset input
      );

  -- Buffer Internal Clock Signal
  BUFG_inst : BUFG
    PORT MAP (
      O => clk_intbuf,                  -- Clock buffer output
      I => clk_int                      -- Clock buffer input
      );

  -- Buffer and Deskew SRAM CLK
  DCM_BASE_sram : DCM_BASE
    GENERIC MAP (
      CLKIN_PERIOD          => 5.0,  -- Specify period of input clock in ns from 1.25 to 1000.00
      CLK_FEEDBACK          => "1X",    -- Specify clock feedback of NONE or 1X
      DCM_AUTOCALIBRATION   => true,   -- DCM calibrartion circuitry TRUE/FALSE
      DCM_PERFORMANCE_MODE  => "MAX_SPEED",  -- Can be MAX_SPEED or MAX_RANGE
      DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",  -- SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
                                        --   an integer from 0 to 15
      DFS_FREQUENCY_MODE    => "HIGH",  -- LOW or HIGH frequency mode for frequency synthesis
      DLL_FREQUENCY_MODE    => "HIGH",  -- LOW, HIGH, or HIGH_SER frequency mode for DLL
      DUTY_CYCLE_CORRECTION => true,    -- Duty cycle correction, TRUE or FALSE
      FACTORY_JF            => X"F0F0",  -- FACTORY JF Values Suggested to be set to X"F0F0" 
      STARTUP_WAIT          => false)  -- Delay configuration DONE until DCM LOCK, TRUE/FALSE
    PORT MAP (
      CLK0  => sram_int_clk,            -- 0 degree DCM CLK output
      CLKFB => SRAM_CLK_FB,             -- DCM clock feedback
      CLKIN => clk,           -- Clock input (from IBUFG, BUFG or DCM)
      RST   => '0'                      -- DCM asynchronous reset input
      );

  SRAM_CLK <= sram_int_clk;

  -------------------------------------------------------------------------------
-- Pixel Memory Controller  
  pixel_memory_controller_i : pixel_memory_controller
    PORT MAP (
      CLK              => clk_intbuf,
      RST              => '0',
      ADDR             => addr,
      ADDR_OFF         => "00000000000000000000",
      WE_B             => we_b,
      CS_B             => '0',
      PIXEL_WRITE      => data_write,
      PIXEL_READ       => data_read,
      PIXEL_READ_VALID => data_read_valid,

      -- SRAM Connections
      SRAM_ADDR => SRAM_ADDR,
      SRAM_WE_B => SRAM_WE_B,
      SRAM_BW_B => SRAM_BW_B,
      SRAM_CS_B => SRAM_CS_B,
      SRAM_OE_B => SRAM_OE_B,
      SRAM_DATA => SRAM_DATA); 

  byte_pipe : pipeline_buffer
    GENERIC MAP (
      WIDTH         => 9,
      STAGES        => 4,
      DEFAULT_VALUE => 0)
    PORT MAP (
      CLK   => clk_intbuf,
      RST   => '0',
      CLKEN => '1',
      DIN   => data_expected_read,
      DOUT  => data_expected_read_buf);

  -------------------------------------------------------------------------------
-- Test Suite States
-- State Observed State Observed Data State CMD Data Present
-- 0 W D0 A0
-- 1 W D1 A1
-- 2 W D2 A2
-- 3 W D3 A3
-- 4 R (D0) A0
-- 5 R (D1) A1
-- 6 W D2 A0
-- 7 R (D2) A2
-- 8 R (D3) A3
-- 9 R (D2) A0
-- A W D3 A0
-- B W D2 A1
-- C W D1 A2
-- D R (D3) A0
-- E R (D2) A1
-- F R (D1) A2
-------------------------------------------------------------------------------
  PROCESS (clk_intbuf) IS
  BEGIN  -- PROCESS
    IF clk_intbuf'event AND clk_intbuf = '1' THEN  -- rising clock edge
      cs_data_read_valid <= data_read_valid;
      cs_data_read <= data_read;
      cs_data_write <= data_write;
      cs_data_expected_read_buf <= data_expected_read_buf;
      IF data_read_valid = '0' OR data_expected_read_buf = data_read THEN
        cs_sram_ok <= '1';
      ELSE
        cs_sram_ok <= '0';
      END IF;
      IF RST = '0' THEN                 -- synchronous reset (active low)
        data_count <= (OTHERS => '0');
      ELSE
        data_count <= data_count + 1;
      END IF;
      CASE data_count IS
        WHEN "0000" =>
          addr               <= addr0;
          data_write         <= data0;
          we_b               <= '0';
          data_expected_read <= (OTHERS => '0');
        WHEN "0001" =>
          addr               <= addr1;
          data_write         <= data1;
          we_b               <= '0';
          data_expected_read <= (OTHERS => '0');
        WHEN "0010" =>
          addr               <= addr2;
          data_write         <= data2;
          we_b               <= '0';
          data_expected_read <= (OTHERS => '0');
        WHEN "0011" =>
          addr               <= addr3;
          data_write         <= data3;
          we_b               <= '0';
          data_expected_read <= (OTHERS => '0');
          
        WHEN "0100" =>
          addr               <= addr0;
          data_write         <= (OTHERS => '0');
          we_b               <= '1';
          data_expected_read <= data0;
        WHEN "0101" =>
          addr               <= addr1;
          data_write         <= (OTHERS => '0');
          we_b               <= '1';
          data_expected_read <= data1;
        WHEN "0110" =>
          addr               <= addr0;
          data_write         <= data2;
          we_b               <= '0';
          data_expected_read <= (OTHERS => '0');
        WHEN "0111" =>
          addr               <= addr2;
          data_write         <= (OTHERS => '0');
          we_b               <= '1';
          data_expected_read <= data2;
        WHEN "1000" =>
          addr               <= addr3;
          data_write         <= (OTHERS => '0');
          we_b               <= '1';
          data_expected_read <= data3;
        WHEN "1001" =>
          addr               <= addr0;
          data_write         <= (OTHERS => '0');
          we_b               <= '1';
          data_expected_read <= data2;
        WHEN "1010" =>
          addr               <= addr0;
          data_write         <= data3;
          we_b               <= '0';
          data_expected_read <= (OTHERS => '0');
        WHEN "1011" =>
          addr               <= addr1;
          data_write         <= data2;
          we_b               <= '0';
          data_expected_read <= (OTHERS => '0');
        WHEN "1100" =>
          addr               <= addr2;
          data_write         <= data1;
          we_b               <= '0';
          data_expected_read <= (OTHERS => '0');
        WHEN "1101" =>
          addr               <= addr0;
          data_write         <= (OTHERS => '0');
          we_b               <= '1';
          data_expected_read <= data3;
        WHEN "1110" =>
          addr               <= addr1;
          data_write         <= (OTHERS => '0');
          we_b               <= '1';
          data_expected_read <= data2;
        WHEN "1111" =>
          addr               <= addr2;
          data_write         <= (OTHERS => '0');
          we_b               <= '1';
          data_expected_read <= data1;
        WHEN OTHERS => NULL;
      END CASE;
    END IF;
  END PROCESS;

END Behavioral;

