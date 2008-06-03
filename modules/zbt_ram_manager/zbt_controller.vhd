-- Module Name:  zbt_controller.vhd
-- File Description:  Controls IS61NLP25636A ZBT RAM chip.
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
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

-------------------------------------------------------------------------------
-- DOESN'T SUPPORT:  ADV_LD_B=1, CKE_B=1, 
-- TODO
-- Fix ADV such that when bursting, it maintains it's mode (so that we still
-- can accurately say when data is ready)
-- Use generators to implement delays so that they can be parameterized

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY zbt_controller IS
  PORT (CLK    : IN std_logic;
        CLK_OE : IN std_logic;
        RST    : IN std_logic;

        -- Control signals
        ADV_LD_B        : IN  std_logic;
        ADDR            : IN  std_logic_vector (17 DOWNTO 0);
        WE_B            : IN  std_logic;
        BW_B            : IN  std_logic_vector (3 DOWNTO 0);
        CKE_B           : IN  std_logic;
        CS_B            : IN  std_logic;
        DATA_WRITE      : IN  std_logic_vector (35 DOWNTO 0);
        DATA_READ       : OUT std_logic_vector(35 DOWNTO 0);
        DATA_READ_VALID : OUT std_logic;

        -- SRAM Connections
        SRAM_ADV_LD_B : OUT   std_logic;
        SRAM_ADDR     : OUT   std_logic_vector (17 DOWNTO 0);
        SRAM_WE_B     : OUT   std_logic;
        SRAM_BW_B     : OUT   std_logic_vector (3 DOWNTO 0);
        SRAM_CKE_B    : OUT   std_logic;
        SRAM_CS_B     : OUT   std_logic;
        SRAM_OE_B     : OUT   std_logic;
        SRAM_DATA     : INOUT std_logic_vector (35 DOWNTO 0));
END zbt_controller;

ARCHITECTURE Behavioral OF zbt_controller IS
  SIGNAL data_write_buf0, data_write_buf1, data_read_buf : std_logic_vector(35 DOWNTO 0);
  SIGNAL we_b_buf, cs_b_buf                              : std_logic_vector(1 DOWNTO 0)   := (OTHERS => '1');
  SIGNAL data_read_valid_reg                             : std_logic_vector(1 DOWNTO 0)   := (OTHERS => '0');
  SIGNAL adv_ld_b_buf                                    : std_logic                      := '0';
  SIGNAL cke_b_buf                                       : std_logic                      := '0';
  SIGNAL addr_buf                                        : std_logic_vector (17 DOWNTO 0) := (OTHERS => '0');
  SIGNAL bw_b_buf                                        : std_logic_vector(3 DOWNTO 0)   := (OTHERS => '1');
BEGIN
  SRAM_ADV_LD_B <= adv_ld_b_buf;
  SRAM_ADDR     <= addr_buf;
  SRAM_WE_B     <= we_b_buf(0);
  SRAM_BW_B     <= bw_b_buf;
  SRAM_CKE_B    <= cke_b_buf;
  SRAM_CS_B     <= cs_b_buf(0);

  DATA_READ       <= data_read_buf;
  DATA_READ_VALID <= data_read_valid_reg(1);

-- purpose: This is the SRAM manager body, it receives data and outputs it with the correct timing to the ZBT ram.  It signals when read data is available (not provided by this module, it is read directly from the RAM,  this module just says when it is valid for reading).
-- type   : sequential
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      -- Buffer input/output signals (makes it easier to meet timing regardless
      -- of what is using the RAM)
      data_read_buf   <= SRAM_DATA;
      adv_ld_b_buf    <= ADV_LD_B;
      we_b_buf(0)     <= WE_B;
      we_b_buf(1)     <= we_b_buf(0);
      addr_buf        <= ADDR;
      bw_b_buf        <= BW_B;
      cke_b_buf       <= CKE_B;
      cs_b_buf(0)     <= CS_B;
      cs_b_buf(1)     <= cs_b_buf(0);
      data_write_buf0 <= DATA_WRITE;
      data_write_buf1 <= data_write_buf0;

      -- Control write data output
      IF we_b_buf(1) = '0' AND cs_b_buf(1) = '0' THEN
        SRAM_DATA <= data_write_buf1;
      ELSE
        SRAM_DATA <= (OTHERS => 'Z');
      END IF;

      IF RST = '1' THEN                 -- synchronous reset (active high)
        cs_b_buf            <= (OTHERS => '1');
        we_b_buf            <= (OTHERS => '1');
        data_read_valid_reg <= (OTHERS => '0');
      ELSE
        -- Signify whether the data on the DATA_READ lines is valid
        IF we_b_buf(1) = '1' AND cs_b_buf(1) = '0' THEN
          data_read_valid_reg(0) <= '1';
        ELSE
          data_read_valid_reg(0) <= '0';
        END IF;
        data_read_valid_reg(1) <= data_read_valid_reg(0);

        SRAM_OE_B <= NOT we_b_buf(0);
      END IF;
    END IF;
  END PROCESS;
END Behavioral;
