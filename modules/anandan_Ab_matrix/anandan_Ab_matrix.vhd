-- Module Name:  anandan_Ab_matrix
-- File Description:  Computes A,b where Ax=b to solve for x, the affine
-- parameters. The output of this must be summed, and then the linear system solved. 
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
---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see <http://www.gnu.org/licenses/>.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY anandan_Ab_matrix IS
  PORT ( CLK   : IN  std_logic;
         CLKEN : IN  std_logic;
         RST   : IN  std_logic;
         IX    : IN  std_logic_vector (0 DOWNTO 0);
         IY    : IN  std_logic_vector (0 DOWNTO 0);
         IT    : IN  std_logic_vector (0 DOWNTO 0);
         X     : IN  std_logic_vector (0 DOWNTO 0);
         Y     : IN  std_logic_vector (0 DOWNTO 0);
         A     : OUT std_logic_vector (0 DOWNTO 0);
         B     : OUT std_logic_vector (0 DOWNTO 0));
END anandan_Ab_matrix;

ARCHITECTURE Behavioral OF anandan_Ab_matrix IS

BEGIN


END Behavioral;

