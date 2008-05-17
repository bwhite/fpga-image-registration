-- Module Name: img1_compute_mem_addr 
-- File Description:  Takes in IMG0 X/Y coordinates, the image height/width,
-- and H (such that H*img0_coords=img1_coords) to produce a 1D memory address
-- and a set of valid signals that indicate overflows.
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

ENTITY img1_compute_mem_addr IS
  GENERIC (
    IMGSIZE_BITS     :    integer := 10);
  PORT ( CLK         : IN std_logic;
         RST         : IN std_logic;
         INPUT_VALID : IN std_logic;
         X_COORD     : IN std_logic_vector(IMGSIZE_BITS-1 DOWNTO 0);
         Y_COORD     : IN std_logic_vector(IMGSIZE_BITS-1 DOWNTO 0);
         IMG_HEIGHT  : IN std_logic_vector(IMGSIZE_BITS-1 DOWNTO 0);
         IMG_WIDTH   : IN std_logic_vector(IMGSIZE_BITS-1 DOWNTO 0);

         -- 1:6:11 Format
         H_0_0        : IN  std_logic_vector (17 DOWNTO 0);
         H_1_0        : IN  std_logic_vector (17 DOWNTO 0);
         H_0_1        : IN  std_logic_vector (17 DOWNTO 0);
         H_1_1        : IN  std_logic_vector (17 DOWNTO 0);
         -- 1:10:11 Format 
         H_0_2        : IN  std_logic_vector (21 DOWNTO 0);
         H_1_2        : IN  std_logic_vector (21 DOWNTO 0);
         MEM_ADDR     : OUT std_logic_vector (2*IMGSIZE_BITS-1 DOWNTO 0);
         OUTPUT_VALID : OUT std_logic;
         OOB_X        : OUT std_logic;
         OOB_Y        : OUT std_logic);
END img1_compute_mem_addr;

ARCHITECTURE Behavioral OF img1_compute_mem_addr IS
  COMPONENT affine_coord_transform IS
                                     GENERIC (
                                       IMGSIZE_BITS    :     integer             := IMGSIZE_BITS;
                                       POSHALF         :     signed(21 DOWNTO 0) := "0000000000010000000000";
                                       NEGHALF         :     signed(21 DOWNTO 0) := "1111111111110000000000");
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
  END COMPONENT;

  COMPONENT convert_2d_to_1d_coord IS
                                     GENERIC (
                                       IMGSIZE_BITS    :     integer := IMGSIZE_BITS);
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
  END COMPONENT;

  SIGNAL oob_x_reg, oob_y_reg                                     : std_logic := '0';
  SIGNAL affine_overflow_x, affine_overflow_y, affine_coord_valid : std_logic;
  SIGNAL xp_coord, yp_coord                                       : std_logic_vector(IMGSIZE_BITS-1 DOWNTO 0);

BEGIN
  OOB_X <= oob_x_reg;
  OOB_Y <= oob_y_reg;

-- Affine Transform: Warp current pixel coordinate using H.
-- NOTE: 'Current' refers to the center pixel in the pattern (for 3x3 it is
-- pixel (1,1).) All others will still be processed to allow for a uniform
-- pipeline; however, their results are not intended to be used in the current
-- system;however, they would be if bilinear interpolation was used.
  -- 3CT Delay
  affine_coord_transform_i : affine_coord_transform
    PORT MAP ( CLK          => CLK,
               RST          => RST,
               INPUT_VALID  => INPUT_VALID,
               X_COORD      => X_COORD,
               Y_COORD      => Y_COORD,
               H_0_0        => H_0_0,
               H_1_0        => H_1_0,
               H_0_1        => H_0_1,
               H_1_1        => H_1_1,
               H_0_2        => H_0_2,
               H_1_2        => H_1_2,
               XP_COORD     => xp_coord,
               YP_COORD     => yp_coord,
               OVERFLOW_X   => affine_overflow_x,
               OVERFLOW_Y   => affine_overflow_y,
               OUTPUT_VALID => affine_coord_valid);

-- Bounds check: Test the rounded X/Y Coordinate bounds to ensure they are
-- inside the image area and that they didn't overflow. Valid ranges are 0<=X<img_width and 0<=Y<IMG_HEIGHT
  -- 1CT Delay
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)
        oob_x_reg     <= '0';
        oob_y_reg     <= '0';
      ELSE
        IF affine_coord_valid = '1' THEN
          IF unsigned(xp_coord) < unsigned(IMG_WIDTH) AND affine_overflow_x = '0' THEN
            oob_x_reg <= '0';
          ELSE
            oob_x_reg <= '1';
          END IF;
          IF unsigned(yp_coord) < unsigned(IMG_HEIGHT) AND affine_overflow_y = '0' THEN
            oob_y_reg <= '0';
          ELSE
            oob_y_reg <= '1';
          END IF;
        ELSE
          oob_x_reg   <= '0';
          oob_y_reg   <= '0';
        END IF;
      END IF;
    END IF;
  END PROCESS;

-- 2D to 1D Coord Conversion: Convert warped 2D coords to 1D memory locations
-- (Y*WIDTH+X)
  -- 1CT Delay
  convert_2d_to_1d_coord_i : convert_2d_to_1d_coord
    PORT MAP (
      CLK          => CLK,
      RST          => RST,
      INPUT_VALID  => affine_coord_valid,
      WIDTH        => IMG_WIDTH,
      X_COORD      => xp_coord,
      Y_COORD      => yp_coord,
      MEM_ADDR     => MEM_ADDR,
      OUTPUT_VALID => OUTPUT_VALID);
END Behavioral;

