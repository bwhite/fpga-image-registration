-- Module Name:  conv_pixel_ordering.vhd
-- File Description:  Outputs pixel coordinates in a 'convolution friendly' manner.
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

ENTITY conv_pixel_ordering IS
  GENERIC (
    CONV_HEIGHT       :    integer := 3;
    WIDTH_BITS        :    integer := 10;
    HEIGHT_BITS       :    integer := 10;
    CONV_HEIGHT_BITS  :    integer := 2);
  PORT ( CLK          : IN std_logic;
         CLKEN        : IN std_logic;
         RST          : IN std_logic;
         -- HEIGHT/WIDTH/WIDTH_OFFSET entered externally
         -- NOTE:  HEIGHT/WIDTH/WIDTH_OFFSET MUST BE CONSTANT AFTER RST FOR
         -- CORRECT RESULTS!
         HEIGHT       : IN std_logic_vector(HEIGHT_BITS-1 DOWNTO 0);
         WIDTH        : IN std_logic_vector(WIDTH_BITS-1 DOWNTO 0);
         WIDTH_OFFSET : IN std_logic_vector(WIDTH_BITS+HEIGHT_BITS-1 DOWNTO 0);  -- (CONV_HEIGHT-1)*WIDTH-1

         MEM_ADDR   : OUT std_logic_vector (WIDTH_BITS+HEIGHT_BITS-1 DOWNTO 0);
         X_COORD    : OUT std_logic_vector (WIDTH_BITS-1 DOWNTO 0);
         Y_COORD    : OUT std_logic_vector (HEIGHT_BITS-1 DOWNTO 0);
         CONV_Y_POS : OUT std_logic_vector (CONV_HEIGHT_BITS-1 DOWNTO 0);
         DATA_VALID : OUT std_logic;
         DONE       : OUT std_logic);
END conv_pixel_ordering;

ARCHITECTURE Behavioral OF conv_pixel_ordering IS
  SIGNAL x_coord_reg, width_minus_one : unsigned(WIDTH_BITS-1 DOWNTO 0)             := (OTHERS => '0');
  SIGNAL y_coord_reg, y_coord_pos     : unsigned(HEIGHT_BITS-1 DOWNTO 0)            := (OTHERS => '0');
  SIGNAL max_y_val, height_conv_diff  : unsigned(HEIGHT_BITS-1 DOWNTO 0)            := (OTHERS => '0');
  SIGNAL conv_y_pos_reg               : unsigned(CONV_HEIGHT_BITS-1 DOWNTO 0)       := (OTHERS => '0');
  SIGNAL mem_addr_reg                 : unsigned(WIDTH_BITS+HEIGHT_BITS-1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL first_pixel                  : std_logic                                   := '1';
  SIGNAL data_valid_reg               : std_logic                                   := '0';
  SIGNAL done_reg                     : std_logic                                   := '0';
BEGIN
  X_COORD                        <= std_logic_vector(x_coord_reg);
  Y_COORD                        <= std_logic_vector(y_coord_reg);
  MEM_ADDR                       <= std_logic_vector(mem_addr_reg);
  CONV_Y_POS                     <= std_logic_vector(conv_y_pos_reg);
  DONE                           <= done_reg;
  DATA_VALID                     <= data_valid_reg;
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      -- NOTE: These must be constant throughout the operation, after changing
      -- them assert RST before using any output from this module.  They must be
      -- valid upon the first posedge of the CLK.
      max_y_val                  <= unsigned(HEIGHT)-CONV_HEIGHT+1;
      height_conv_diff           <= unsigned(HEIGHT)-CONV_HEIGHT;
      width_minus_one            <= unsigned(WIDTH)-1;
      IF RST = '1' THEN                 -- synchronous reset (active high)
        x_coord_reg              <= (OTHERS                                                    => '0');
        y_coord_reg              <= (OTHERS                                                    => '0');
        y_coord_pos              <= (OTHERS                                                    => '0');
        conv_y_pos_reg           <= (OTHERS                                                    => '0');
        mem_addr_reg             <= (OTHERS                                                    => '0');
        first_pixel              <= '1';
        data_valid_reg           <= '0';
        done_reg                 <= '0';
      ELSE
        IF CLKEN = '1' THEN             -- NOTE: DATA_VALID signal stays the same
          IF y_coord_pos/=max_y_val THEN  -- End of entire stream
            -- This controls the innermost loop (the one that creates the vertical
            -- pixel motion the size of the CONV_HEIGHT)
            IF conv_y_pos_reg = CONV_HEIGHT-1 THEN  -- End of Y pattern
              -- This moves our overall vertical position when we meet our max width
              IF x_coord_reg = width_minus_one THEN  -- End of row
                x_coord_reg      <= (OTHERS                                                    => '0');
                y_coord_reg      <= y_coord_reg - (CONV_HEIGHT-1) + 1;
                IF y_coord_pos = height_conv_diff THEN  -- End of entire stream
                  done_reg       <= '1';
                  data_valid_reg <= '0';
                ELSE
                  data_valid_reg <= '1';
                END IF;
                y_coord_pos      <= y_coord_pos + 1;
              ELSE
                data_valid_reg   <= '1';
                y_coord_reg      <= y_coord_reg - (CONV_HEIGHT-1);
                x_coord_reg      <= x_coord_reg + 1;
              END IF;
              conv_y_pos_reg     <= (OTHERS                                                    => '0');
              mem_addr_reg       <= mem_addr_reg - unsigned(WIDTH_OFFSET);
            ELSE
              IF first_pixel = '0' THEN  -- If it isn't the first pixel
                y_coord_reg      <= y_coord_reg + 1;
                mem_addr_reg     <= mem_addr_reg + unsigned(WIDTH);
                conv_y_pos_reg   <= conv_y_pos_reg + 1;
              END IF;
              data_valid_reg     <= '1';
              first_pixel        <= '0';
            END IF;
          ELSE
            done_reg             <= '0';
            data_valid_reg       <= '0';
          END IF;
        END IF;
      END IF;
    END IF;
  END PROCESS;
END Behavioral;
