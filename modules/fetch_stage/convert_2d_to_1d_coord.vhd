----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:01:31 04/21/2008 
-- Design Name: 
-- Module Name:    convert_2d_to_1d_coord - Behavioral 
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
USE ieee.numeric_std.ALL;

ENTITY convert_2d_to_1d_coord IS
  PORT ( CLK          : IN  std_logic;
         RST          : IN  std_logic;
         INPUT_VALID  : IN  std_logic;
         -- 0:10:0
         WIDTH        : IN  std_logic_vector (9 DOWNTO 0);
         -- 0:10:0
         X_COORD      : IN  std_logic_vector (9 DOWNTO 0);
         -- 0:10:0
         Y_COORD      : IN  std_logic_vector (9 DOWNTO 0);
         -- 0:20:0
         MEM_ADDR     : OUT std_logic_vector (19 DOWNTO 0);
         OUTPUT_VALID : OUT std_logic);
END convert_2d_to_1d_coord;

ARCHITECTURE Behavioral OF convert_2d_to_1d_coord IS
  SIGNAL mem_addr_reg, width_offset : unsigned(19 DOWNTO 0);
  SIGNAL valid_buf : std_logic_vector(1 DOWNTO 0) := (OTHERS => '0');
BEGIN
  MEM_ADDR           <= std_logic_vector(mem_addr_reg);
  OUTPUT_VALID <= valid_buf(0);
-- 2D to 1D Coord Conversion: Convert warped 2D coords to 1D memory locations
-- (Y*WIDTH+X)
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)
        width_offset <= (OTHERS => '0');
        mem_addr_reg <= (OTHERS => '0');
        valid_buf <= (OTHERS => '0');
      ELSE
        valid_buf(1) <= INPUT_VALID;
        valid_buf(0) <= valid_buf(1);
        -- 0:20:0
        width_offset <= unsigned(WIDTH)*unsigned(Y_COORD);
        -- 0:20:0
        mem_addr_reg <= width_offset + unsigned(X_COORD);
      END IF;
    END IF;
  END PROCESS;
END Behavioral;

