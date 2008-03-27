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
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY conv_pixel_ordering IS
  GENERIC (
    WIDTH            :     integer := 4;
    HEIGHT           :     integer := 4;
    CONV_HEIGHT      :     integer := 3;
    WIDTH_BITS       :     integer := 10;
    HEIGHT_BITS      :     integer := 10;
    CONV_HEIGHT_BITS :     integer := 3);
  PORT ( CLK         : IN  std_logic;
         CLKEN       : IN  std_logic;
         RST         : IN  std_logic;
         MEM_ADDR    : OUT std_logic_vector (WIDTH_BITS+HEIGHT_BITS-1 DOWNTO 0);
         X_COORD     : OUT std_logic_vector (WIDTH_BITS-1 DOWNTO 0);
         Y_COORD     : OUT std_logic_vector (HEIGHT_BITS-1 DOWNTO 0);
         DATA_VALID  : OUT std_logic;
         DONE        : OUT std_logic);
END conv_pixel_ordering;

ARCHITECTURE Behavioral OF conv_pixel_ordering IS
  SIGNAL x_coord_reg  : unsigned(WIDTH_BITS-1 DOWNTO 0)             := (OTHERS => '0');
  SIGNAL y_coord_reg  : unsigned(HEIGHT_BITS-1 DOWNTO 0)            := (OTHERS => '0');
  SIGNAL y_coord_pos  : unsigned(HEIGHT_BITS-1 DOWNTO 0)            := (OTHERS => '0');
  SIGNAL conv_y_pos   : unsigned(CONV_HEIGHT_BITS-1 DOWNTO 0)       := (OTHERS => '0');
  SIGNAL mem_addr_reg : unsigned(WIDTH_BITS+HEIGHT_BITS-1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL first_pixel  : std_logic                                   := '0';
BEGIN
  X_COORD  <= std_logic_vector(x_coord_reg);
  Y_COORD  <= std_logic_vector(y_coord_reg);
  MEM_ADDR <= std_logic_vector(mem_addr_reg);

  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)
        x_coord_reg         <= (OTHERS => '0');
        y_coord_reg         <= (OTHERS => '0');
        y_coord_pos         <= (OTHERS => '0');
        conv_y_pos          <= (OTHERS => '0');
        mem_addr_reg        <= (OTHERS => '0');
        first_pixel         <= '0';
      ELSE
        IF y_coord_pos/=(HEIGHT-CONV_HEIGHT+1) THEN
          -- This controls the innermost loop (the one that creates the vertical
          -- pixel motion the size of the CONV_HEIGHT)
          IF conv_y_pos = CONV_HEIGHT-1 THEN
            -- This moves our overal vertical position when we meet our max width
            IF x_coord_reg = (WIDTH-1) THEN
                x_coord_reg <= (OTHERS => '0');
                y_coord_reg <= y_coord_reg - (CONV_HEIGHT-1) + 1;
                y_coord_pos <= y_coord_pos + 1;
              ELSE
                y_coord_reg <= y_coord_reg - (CONV_HEIGHT-1);
                x_coord_reg <= x_coord_reg + 1;
              END IF;
                
              conv_y_pos       <= (OTHERS => '0');
              mem_addr_reg   <= mem_addr_reg - (CONV_HEIGHT-1)*WIDTH + 1;
              ELSE
                IF first_pixel = '1' THEN
                  y_coord_reg  <= y_coord_reg + 1;
                  mem_addr_reg <= mem_addr_reg + WIDTH;
                  conv_y_pos   <= conv_y_pos + 1;
                END IF;
                first_pixel    <= '1';
              END IF;
            END IF;
          END IF;
        END IF;
      END PROCESS;
    end Behavioral;
