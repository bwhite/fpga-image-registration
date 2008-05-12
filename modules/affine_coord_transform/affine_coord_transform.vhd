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

-- TODO Round to the nearest coordinate, fix precisions
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY affine_coord_transform IS
  GENERIC (
    POSHALF           :     signed(21 DOWNTO 0) := "0000000000010000000000";
    NEGHALF           :     signed(21 DOWNTO 0) := "1111111111110000000000");
  PORT ( CLK          : IN  std_logic;
         RST          : IN  std_logic;
         INPUT_VALID  : IN  std_logic;
         -- 0:10:0
         X_COORD      : IN  std_logic_vector (9 DOWNTO 0);
         Y_COORD      : IN  std_logic_vector (9 DOWNTO 0);
         -- 1:6:11 Format
         H_0_0        : IN  std_logic_vector (17 DOWNTO 0);
         H_1_0        : IN  std_logic_vector (17 DOWNTO 0);
         H_0_1        : IN  std_logic_vector (17 DOWNTO 0);
         H_1_1        : IN  std_logic_vector (17 DOWNTO 0);
         -- 1:10:11 Format 
         H_0_2        : IN  std_logic_vector (21 DOWNTO 0);
         H_1_2        : IN  std_logic_vector (21 DOWNTO 0);
         -- 0:10:0 Format
         XP_COORD     : OUT std_logic_vector (9 DOWNTO 0);
         YP_COORD     : OUT std_logic_vector (9 DOWNTO 0);
         OVERFLOW     : OUT std_logic;
         OUTPUT_VALID : OUT std_logic);
END affine_coord_transform;

ARCHITECTURE Behavioral OF affine_coord_transform IS
  SIGNAL h_0_2_x_0, h_0_2_x_1, h_0_2_x_2    : signed(21 DOWNTO 0);
  SIGNAL h_1_2_y_0, h_1_2_y_1, h_1_2_y_2    : signed(21 DOWNTO 0);
  SIGNAL h_0_0_x_0, h_0_0_x_1               : signed(28 DOWNTO 0);
  SIGNAL h_1_0_x_0, h_1_0_x_1               : signed(28 DOWNTO 0);
  SIGNAL h_0_1_y_0, h_0_1_y_1               : signed(28 DOWNTO 0);
  SIGNAL h_1_1_y_0, h_1_1_y_1               : signed(28 DOWNTO 0);
  SIGNAL xsum_h_0_0_h_0_1, ysum_h_1_0_h_1_1 : signed(29 DOWNTO 0);
  SIGNAL xp_coord_reg, yp_coord_reg         : signed(30 DOWNTO 0);
  SIGNAL valid_buf                          : std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');
BEGIN
  XP_COORD     <= std_logic_vector(xp_coord_reg(20 DOWNTO 11));
  YP_COORD     <= std_logic_vector(yp_coord_reg(20 DOWNTO 11));
  OUTPUT_VALID <= valid_buf(3);
  PROCESS (xp_coord_reg, yp_coord_reg) IS
  BEGIN  -- PROCESS
    IF xp_coord_reg(30 DOWNTO 21) = (9 DOWNTO 0 => '0') AND yp_coord_reg(30 DOWNTO 21) = (9 DOWNTO 0 => '0') THEN
      OVERFLOW <= '0';
    ELSE
      OVERFLOW <= '1';
    END IF;
  END PROCESS;

  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN
        valid_buf        <= (OTHERS => '0');
      ELSE
        FOR i IN 2 DOWNTO 0 LOOP
          valid_buf(i+1) <= valid_buf(i);
        END LOOP;  -- i
        valid_buf(0)     <= INPUT_VALID;
      END IF;

      -- Rounding occurs in this stage (as we can add .5 here and it will
      -- be added to the result)
      -- H_0_2 1:10:11
      IF H_0_2(21) = '0' THEN
        h_0_2_x_0 <= signed(H_0_2)+POSHALF;  -- +.5
      ELSE
        h_0_2_x_0 <= signed(H_0_2)+NEGHALF;  -- -.5
      END IF;
      h_0_2_x_1   <= h_0_2_x_0;
      h_0_2_x_2   <= h_0_2_x_1;

      -- H_1_2 1:10:11
      IF H_1_2(21) = '0' THEN
        h_1_2_y_0 <= signed(H_1_2)+POSHALF;  -- +.5
      ELSE
        h_1_2_y_0 <= signed(H_1_2)+NEGHALF;  -- -.5
      END IF;
      h_1_2_y_1   <= h_1_2_y_0;
      h_1_2_y_2   <= h_1_2_y_1;

      -- H_0_0*X 1:17:11
      h_0_0_x_0 <= signed(H_0_0)*signed('0'&X_COORD);
      h_0_0_x_1 <= h_0_0_x_0;

      -- H_1_0*X 1:17:11
      h_1_0_x_0 <= signed(H_1_0)*signed('0'&X_COORD);
      h_1_0_x_1 <= h_1_0_x_0;

      -- H_0_1*Y 1:17:11
      h_0_1_y_0 <= signed(H_0_1)*signed('0'&Y_COORD);
      h_0_1_y_1 <= h_0_1_y_0;

      -- H_1_1*Y 1:17:11
      h_1_1_y_0 <= signed(H_1_1)*signed('0'&Y_COORD);
      h_1_1_y_1 <= h_1_1_y_0;

      -- 1:18:11
      xsum_h_0_0_h_0_1 <= (h_0_0_x_1(28)&h_0_0_x_1) + (h_0_1_y_1(28)&h_0_1_y_1);
      ysum_h_1_0_h_1_1 <= (h_1_0_x_1(28)&h_1_0_x_1) + (h_1_1_y_1(28)&h_1_1_y_1);
      -- 1:19:11
      xp_coord_reg     <= (xsum_h_0_0_h_0_1(29)&xsum_h_0_0_h_0_1)+h_0_2_x_2;
      yp_coord_reg     <= (ysum_h_1_0_h_1_1(29)&ysum_h_1_0_h_1_1)+h_1_2_y_2;
    END IF;
  END PROCESS;
END Behavioral;
