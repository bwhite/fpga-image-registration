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
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY zbt_controller IS
  PORT (CLK        : IN  std_logic;
        RST        : IN  std_logic;
        CLKEN      : IN  std_logic;
        BW_B       : IN  std_logic_vector (3 DOWNTO 0);
        WE_B       : IN  std_logic;
        ADDR       : IN  std_logic_vector (17 DOWNTO 0);
        DATA       : IN  std_logic_vector (35 DOWNTO 0);

        DATA_VALID : OUT std_logic;

        -- SRAM Outputs
        SRAM_CS_B  : OUT std_logic;
        SRAM_BW_B  : OUT std_logic_vector (3 DOWNTO 0);
        SRAM_OE_B  : OUT std_logic;
        SRAM_WE_B  : OUT std_logic;
        SRAM_ADDR  : OUT std_logic_vector (17 DOWNTO 0);
        SRAM_DATA  : OUT std_logic_vector (35 DOWNTO 0));
END zbt_controller;

ARCHITECTURE Behavioral OF zbt_controller IS

BEGIN
-- purpose: This is the SRAM manager body, it receives data and outputs it with the correct timing to the ZBT ram.  It signals when read data is available (not provided by this module, it is read directly from the RAM,  this module just says when it is valid for reading).
-- type   : sequential
-- inputs : CLK, RST, CLKEN, BW_B, WE_B, ADDR, DATA
-- outputs: SRAM_CS_B, SRAM_BW_B, SRAM_OE_B, SRAM_WE_B, SRAM_ADDR, SRAM_DATA, READ_DATA_VALID
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' AND CLKEN= '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)

      ELSE
        
    END IF;
  END IF;
END PROCESS;

END Behavioral;

