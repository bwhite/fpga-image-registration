-- Module Name: convert_2d_to_1d_coord
-- File Description: Takes in X/Y image coordinates and width returning the result of Y*WIDTH+X
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
USE ieee.numeric_std.ALL;

ENTITY convert_2d_to_1d_coord IS
  GENERIC (
    IMGSIZE_BITS      :     integer := 10);
  PORT ( CLK          : IN  std_logic;
         RST          : IN  std_logic;
         INPUT_VALID  : IN  std_logic;
         -- 0:IMGSIZE_BITS:0
         WIDTH        : IN  std_logic_vector (IMGSIZE_BITS-1 DOWNTO 0);
         -- 0:IMGSIZE_BITS:0
         X_COORD      : IN  std_logic_vector (IMGSIZE_BITS-1 DOWNTO 0);
         -- 0:IMGSIZE_BITS:0
         Y_COORD      : IN  std_logic_vector (IMGSIZE_BITS-1 DOWNTO 0);
         -- 0:2*IMGSIZE_BITS:0
         MEM_ADDR     : OUT std_logic_vector (2*IMGSIZE_BITS-1 DOWNTO 0);
         OUTPUT_VALID : OUT std_logic);
END convert_2d_to_1d_coord;

ARCHITECTURE Behavioral OF convert_2d_to_1d_coord IS
  SIGNAL mem_addr_reg : unsigned(2*IMGSIZE_BITS-1 DOWNTO 0);
  SIGNAL valid_buf    : std_logic := '0';
BEGIN
  MEM_ADDR           <= std_logic_vector(mem_addr_reg);
  OUTPUT_VALID       <= valid_buf;
-- 2D to 1D Coord Conversion: Convert warped 2D coords to 1D memory locations
-- (Y*WIDTH+X)
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)
        mem_addr_reg <= (OTHERS => '0');
        valid_buf    <= '0';
      ELSE
        valid_buf    <= INPUT_VALID;
        -- 0:2*IMGSIZE_BITS:0
        mem_addr_reg <= unsigned(WIDTH)*unsigned(Y_COORD) + unsigned(X_COORD);
      END IF;
    END IF;
  END PROCESS;
END Behavioral;

