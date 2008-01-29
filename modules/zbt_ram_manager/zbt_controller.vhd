----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:16:57 01/14/2008 
-- Design Name: 
-- Module Name:    zbt_controller - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
-------------------------------------------------------------------------------
-- DOESN'T SUPPORT:  ADV_LD_B=1, CKE_B=1, 
-- TODO
-- Fix ADV such that when bursting, it maintains it's mode (so that we still
-- can accurately say when data is ready)
-- Use generators to implement delays so that they can be parameterized

----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY zbt_controller IS
  PORT (CLK    : IN std_logic;
        CLK_3X : IN std_logic;
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
  SIGNAL data_write_delay       : std_logic_vector(35 DOWNTO 0);
  SIGNAL we_b_delay, cs_b_delay : std_logic := '0';
  SIGNAL data_read_valid_reg    : std_logic := '0';
BEGIN
  SRAM_ADV_LD_B   <= ADV_LD_B;
  SRAM_ADDR       <= ADDR;
  SRAM_WE_B       <= WE_B;
  SRAM_BW_B       <= BW_B;
  SRAM_CKE_B      <= CKE_B;
  SRAM_CS_B       <= CS_B;
  DATA_READ       <= SRAM_DATA;
  DATA_READ_VALID <= data_read_valid_reg;

-- purpose: This is used to control the data out register and the OE_B wire to avoid collisions and satisfy setup times.
-- type   : sequential
-- inputs : CLK_3X
  PROCESS (CLK_3X) IS
  BEGIN  -- PROCESS
    IF CLK_3X'event AND CLK_3X = '1' THEN  -- rising clock edge

      IF CLK = '0' THEN
        SRAM_OE_B <= NOT we_b_delay;
      END IF;
    END IF;
  END PROCESS;

-- purpose: This is the SRAM manager body, it receives data and outputs it with the correct timing to the ZBT ram.  It signals when read data is available (not provided by this module, it is read directly from the RAM,  this module just says when it is valid for reading).
-- type   : sequential
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      -- Control write data output
      IF we_b_delay = '0' AND cs_b_delay = '0' THEN
        SRAM_DATA <= data_write_delay;
      ELSE
        SRAM_DATA <= (OTHERS => 'Z');
      END IF;

      data_write_delay <= DATA_WRITE;

      IF RST = '1' THEN                 -- synchronous reset (active high)
        cs_b_delay          <= '1';
        we_b_delay          <= '1';
        data_read_valid_reg <= '0';

      ELSE
        -- Signify whether the data on the DATA_READ lines is valid
        IF we_b_delay = '1' AND cs_b_delay = '0' THEN
          data_read_valid_reg <= '1';
        ELSE
          data_read_valid_reg <= '0';
        END IF;
        cs_b_delay <= CS_B;
        we_b_delay <= WE_B;
      END IF;
    END IF;
  END PROCESS;
END Behavioral;

