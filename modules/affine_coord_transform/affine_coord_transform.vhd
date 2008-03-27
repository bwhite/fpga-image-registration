-- Module Name:  affine_coord_transform.vhd
-- File Description:  Performs affine transformation on an x,y coordinate pair.
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

ENTITY affine_coord_transform IS
  PORT ( CLK      : IN  std_logic;
         RST      : IN  std_logic;
         -- 1:10:14
         X_COORD  : IN  std_logic_vector (24 DOWNTO 0);
         Y_COORD  : IN  std_logic_vector (24 DOWNTO 0);
         -- 1:5:12 Format
         H_0_0    : IN  std_logic_vector (17 DOWNTO 0);
         H_1_0    : IN  std_logic_vector (17 DOWNTO 0);
         H_0_1    : IN  std_logic_vector (17 DOWNTO 0);
         H_1_1    : IN  std_logic_vector (17 DOWNTO 0);
         -- 1:10:14 Format 
         H_0_2    : IN  std_logic_vector (24 DOWNTO 0);
         H_1_2    : IN  std_logic_vector (24 DOWNTO 0);
         -- 1:16:8 Format
         XP_COORD : OUT std_logic_vector (32 DOWNTO 0);
         YP_COORD : OUT std_logic_vector (32 DOWNTO 0);

         OUTPUT_VALID : OUT std_logic;
         INPUT_VALID  : IN  std_logic);
END affine_coord_transform;

ARCHITECTURE Behavioral OF affine_coord_transform IS
  SIGNAL h_0_0_reg, h_1_0_reg, h_0_1_reg, h_1_1_reg : signed(17 DOWNTO 0) := (OTHERS => '0');
  SIGNAL x_coord_reg, y_coord_reg                   : signed(24 DOWNTO 0) := (OTHERS => '0');
  SIGNAL h_0_2_reg, h_1_2_reg                       : signed(24 DOWNTO 0) := (OTHERS => '0');


  SIGNAL h_0_2_x_0, h_0_2_x_1, h_0_2_x_2 : signed(24 DOWNTO 0);
  SIGNAL h_1_2_y_0, h_1_2_y_1, h_1_2_y_2 : signed(24 DOWNTO 0);
  SIGNAL h_0_0_x_0, h_0_0_x_1            : signed(42 DOWNTO 0);
  SIGNAL h_1_0_x_0, h_1_0_x_1            : signed(42 DOWNTO 0);
  SIGNAL h_0_1_y_0, h_0_1_y_1            : signed(42 DOWNTO 0);
  SIGNAL h_1_1_y_0, h_1_1_y_1            : signed(42 DOWNTO 0);

  SIGNAL xsum_h_0_0_h_0_1_h_0_2, ysum_h_1_0_h_1_1_h_1_2 : signed(32 DOWNTO 0);
  SIGNAL xsum_h_0_0_h_0_1, ysum_h_1_0_h_1_1             : signed(43 DOWNTO 0);
  SIGNAL valid_buf                                      : std_logic_vector(5 DOWNTO 0) := (OTHERS => '0');
BEGIN
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    OUTPUT_VALID         <= valid_buf(5);
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN
        valid_buf        <= (OTHERS                                                               => '0');
      ELSE
        FOR i IN 4 DOWNTO 0 LOOP
          valid_buf(i+1) <= valid_buf(i);
        END LOOP;  -- i
        valid_buf(0)     <= INPUT_VALID;
      END IF;
      h_0_0_reg          <= signed(H_0_0);
      h_1_0_reg          <= signed(H_1_0);
      h_0_1_reg          <= signed(H_0_1);
      h_1_1_reg          <= signed(H_1_1);
      h_0_2_reg          <= signed(H_0_2);
      h_1_2_reg          <= signed(H_1_2);
      x_coord_reg        <= signed(X_COORD);
      y_coord_reg        <= signed(Y_COORD);

      -- H_0_2 1:10:14
      h_0_2_x_0 <= h_0_2_reg;
      h_0_2_x_1 <= h_0_2_x_0;
      h_0_2_x_2 <= h_0_2_x_1;

      -- H_1_2
      h_1_2_y_0 <= h_1_2_reg;
      h_1_2_y_1 <= h_1_2_y_0;
      h_1_2_y_2 <= h_1_2_y_1;

      -- H_0_0*X 1:16:26
      h_0_0_x_0 <= h_0_0_reg*x_coord_reg;
      h_0_0_x_1 <= h_0_0_x_0;

      -- H_1_0*X 1:16:26
      h_1_0_x_0 <= h_1_0_reg*x_coord_reg;
      h_1_0_x_1 <= h_1_0_x_0;

      -- H_0_1*Y 1:16:26
      h_0_1_y_0 <= h_0_1_reg*y_coord_reg;
      h_0_1_y_1 <= h_0_1_y_0;

      -- H_1_1*Y 1:16:26
      h_1_1_y_0 <= h_1_1_reg*y_coord_reg;
      h_1_1_y_1 <= h_1_1_y_0;

      -- 1:17:26
      xsum_h_0_0_h_0_1 <= (h_0_0_x_1(42)&h_0_0_x_1) + (h_0_1_y_1(42)&h_0_1_y_1);
      ysum_h_1_0_h_1_1 <= (h_1_0_x_1(42)&h_1_0_x_1) + (h_1_1_y_1(42)&h_1_1_y_1);

      -- 1:18:14
      xsum_h_0_0_h_0_1_h_0_2 <= (xsum_h_0_0_h_0_1(43)&xsum_h_0_0_h_0_1(43 DOWNTO 12))+((6 DOWNTO 0 => h_0_2_x_2(24))&h_0_2_x_2);
      XP_COORD               <= std_logic_vector(xsum_h_0_0_h_0_1_h_0_2);  -- 1:18:14
      ysum_h_1_0_h_1_1_h_1_2 <= (ysum_h_1_0_h_1_1(43)&ysum_h_1_0_h_1_1(43 DOWNTO 12))+((6 DOWNTO 0 => h_1_2_y_2(24))&h_1_2_y_2);
      YP_COORD               <= std_logic_vector(ysum_h_1_0_h_1_1_h_1_2);
    END IF;
  END PROCESS;
END Behavioral;

