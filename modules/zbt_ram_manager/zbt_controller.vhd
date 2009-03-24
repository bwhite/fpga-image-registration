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

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY zbt_controller IS
  PORT (CLK : IN std_logic;
        RST : IN std_logic;

        -- Control signals
        ADDR            : IN  std_logic_vector (17 DOWNTO 0);
        WE_B            : IN  std_logic;
        BW_B            : IN  std_logic_vector (3 DOWNTO 0);
        CS_B            : IN  std_logic;
        DATA_WRITE      : IN  std_logic_vector (35 DOWNTO 0);
        DATA_READ       : OUT std_logic_vector(35 DOWNTO 0);
        DATA_READ_VALID : OUT std_logic;

        -- SRAM Connections
        SRAM_ADDR : OUT   std_logic_vector (17 DOWNTO 0);
        SRAM_WE_B : OUT   std_logic;
        SRAM_BW_B : OUT   std_logic_vector (3 DOWNTO 0);
        SRAM_CS_B : OUT   std_logic;
        SRAM_OE_B : OUT   std_logic;
        SRAM_DATA_I : IN std_logic_vector (35 DOWNTO 0);
        SRAM_DATA_O : OUT std_logic_vector (35 DOWNTO 0);
        SRAM_DATA_T : OUT std_logic);
END zbt_controller;

ARCHITECTURE Behavioral OF zbt_controller IS
  SIGNAL data_write_delay               : std_logic_vector(35 DOWNTO 0);
  SIGNAL we_delay, cs_b_delay           : std_logic := '0';
  SIGNAL data_read_valid_reg            : std_logic := '0';
  attribute IOB : string;
  attribute IOB of SRAM_DATA_I, SRAM_DATA_O: signal is "TRUE";
  
  ATTRIBUTE KEEP                        : string;
  ATTRIBUTE KEEP OF data_write_delay    : SIGNAL IS "TRUE";
  ATTRIBUTE KEEP OF data_read_valid_reg : SIGNAL IS "TRUE";
BEGIN
  SRAM_ADDR       <= ADDR;
  SRAM_WE_B       <= WE_B;
  SRAM_BW_B       <= BW_B;
  SRAM_CS_B       <= CS_B;
  DATA_READ       <= SRAM_DATA_I;
  DATA_READ_VALID <= data_read_valid_reg;

-- purpose: This is the SRAM manager body, it receives data and outputs it with the correct timing to the ZBT ram.  It signals when read data is available (not provided by this module, it is read directly from the RAM,  this module just says when it is valid for reading).
-- type   : sequential
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      -- Control write data output
      IF we_delay = '1' AND cs_b_delay = '0' THEN
        SRAM_DATA_T <= '0';
        SRAM_DATA_O <= data_write_delay;
      ELSE
        SRAM_DATA_T <= '1';
        SRAM_DATA_O <= (OTHERS => 'X');
      END IF;

      data_write_delay <= DATA_WRITE;
      SRAM_OE_B        <= NOT WE_B;--we_delay;
      IF RST = '1' THEN                 -- synchronous reset (active high)
        cs_b_delay          <= '1'; 
        we_delay            <= '0';
        data_read_valid_reg <= '0';
      ELSE
        -- Signify whether the data on the DATA_READ lines is valid
        IF we_delay = '0' AND cs_b_delay = '0' THEN
          data_read_valid_reg <= '1';
        ELSE
          data_read_valid_reg <= '0';
        END IF;
        cs_b_delay <= CS_B;
        we_delay   <= NOT WE_B;
      END IF;
    END IF;
  END PROCESS;
END Behavioral;
