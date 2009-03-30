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
  GENERIC (
    IMGSIZE_BITS      :     integer             := 10;
    POSHALF           :     signed(21 DOWNTO 0) := "0000000000010000000000";
    NEGHALF           :     signed(21 DOWNTO 0) := "1111111111110000000000");
  PORT ( CLK          : IN  std_logic;
         RST          : IN  std_logic;
         INPUT_VALID  : IN  std_logic;
         -- 0:IMGSIZE_BITS:0
         X_COORD      : IN  std_logic_vector (IMGSIZE_BITS-1 DOWNTO 0);
         Y_COORD      : IN  std_logic_vector (IMGSIZE_BITS-1 DOWNTO 0);
         -- 1:6:11 Format
         H_0_0        : IN  std_logic_vector (17 DOWNTO 0);
         H_1_0        : IN  std_logic_vector (17 DOWNTO 0);
         H_0_1        : IN  std_logic_vector (17 DOWNTO 0);
         H_1_1        : IN  std_logic_vector (17 DOWNTO 0);
         -- 1:10:11 Format 
         H_0_2        : IN  std_logic_vector (21 DOWNTO 0);
         H_1_2        : IN  std_logic_vector (21 DOWNTO 0);
         -- 0:IMGSIZE_BITS:0 Format
         XP_COORD     : OUT std_logic_vector (IMGSIZE_BITS-1 DOWNTO 0);
         YP_COORD     : OUT std_logic_vector (IMGSIZE_BITS-1 DOWNTO 0);
         OVERFLOW_X   : OUT std_logic;
         OVERFLOW_Y   : OUT std_logic;
         OUTPUT_VALID : OUT std_logic);
END affine_coord_transform;

ARCHITECTURE Behavioral OF affine_coord_transform IS
  SIGNAL h_0_0_x_0, h_1_0_x_0, h_0_1_y_0, h_1_1_y_0 : signed(18+IMGSIZE_BITS DOWNTO 0);
  SIGNAL h_0_0_x_1, h_1_0_x_1, h_0_1_y_1, h_1_1_y_1 : signed(18+IMGSIZE_BITS DOWNTO 0);
  SIGNAL xsum_h_0_0_h_0_1, ysum_h_1_0_h_1_1         : signed(19+IMGSIZE_BITS DOWNTO 0);
  SIGNAL xp_coord_reg, yp_coord_reg                 : signed(20+IMGSIZE_BITS DOWNTO 0);
  SIGNAL h_0_2_x_0, h_0_2_x_1,h_0_2_x_2                       : signed(21 DOWNTO 0);
  SIGNAL h_1_2_y_0, h_1_2_y_1,h_1_2_y_2                       : signed(21 DOWNTO 0);
  SIGNAL valid_buf                                  : std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');
BEGIN
  -- 0:IMGSIZE_BITS:0
  XP_COORD       <= std_logic_vector(xp_coord_reg(10+IMGSIZE_BITS DOWNTO 11));
  YP_COORD       <= std_logic_vector(yp_coord_reg(10+IMGSIZE_BITS DOWNTO 11));
  OUTPUT_VALID   <= valid_buf(3);
  PROCESS (xp_coord_reg, yp_coord_reg) IS
  BEGIN  -- PROCESS
    IF unsigned(xp_coord_reg(20+IMGSIZE_BITS DOWNTO 11+IMGSIZE_BITS)) = 0 THEN
      OVERFLOW_X <= '0';
    ELSE
      OVERFLOW_X <= '1';
    END IF;
    IF unsigned(yp_coord_reg(20+IMGSIZE_BITS DOWNTO 11+IMGSIZE_BITS)) = 0 THEN
      OVERFLOW_Y <= '0';
    ELSE
      OVERFLOW_Y <= '1';
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

      -- H_0_2 1:10:11      
      h_0_2_x_0 <= signed(H_0_2);      
      h_0_2_x_1   <= h_0_2_x_0;
      h_0_2_x_2   <= h_0_2_x_1;

      -- H_1_2 1:10:11
      h_1_2_y_0 <= signed(H_1_2);
      h_1_2_y_1   <= h_1_2_y_0;
      h_1_2_y_2   <= h_1_2_y_1;

      -- H_AFFINE 1:6:11 Format
      -- 1:IMGSIZE_BITS:0
      -- H_0_0*X 1:7+IMGSIZE_BITS:11
      h_0_0_x_0        <= signed(H_0_0)*signed('0'&X_COORD);
      h_0_0_x_1        <= h_0_0_x_0;
      -- H_1_0*X 1:7+IMGSIZE_BITS:11
      h_1_0_x_0        <= signed(H_1_0)*signed('0'&X_COORD);
      h_1_0_x_1        <= h_1_0_x_0;
      -- H_0_1*Y 1:7+IMGSIZE_BITS:11
      h_0_1_y_0        <= signed(H_0_1)*signed('0'&Y_COORD);
      h_0_1_y_1        <= h_0_1_y_0;
      -- H_1_1*Y 1:7+IMGSIZE_BITS:11
      h_1_1_y_0        <= signed(H_1_1)*signed('0'&Y_COORD);
      h_1_1_y_1        <= h_1_1_y_0;
      -- 1:8+IMGSIZE_BITS:11
      xsum_h_0_0_h_0_1 <= (h_0_0_x_1(18+IMGSIZE_BITS)&h_0_0_x_1) + (h_0_1_y_1(18+IMGSIZE_BITS)&h_0_1_y_1);
      ysum_h_1_0_h_1_1 <= (h_1_0_x_1(18+IMGSIZE_BITS)&h_1_0_x_1) + (h_1_1_y_1(18+IMGSIZE_BITS)&h_1_1_y_1);
      -- 1:9+IMGSIZE_BITS:11
      -- 1:10:11
      xp_coord_reg     <= (xsum_h_0_0_h_0_1(19+IMGSIZE_BITS)&xsum_h_0_0_h_0_1)+h_0_2_x_2;
      yp_coord_reg     <= (ysum_h_1_0_h_1_1(19+IMGSIZE_BITS)&ysum_h_1_0_h_1_1)+h_1_2_y_2;
    END IF;
  END PROCESS;
END Behavioral;
