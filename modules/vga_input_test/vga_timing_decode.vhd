-- Module Name:  vga_timing_decode.vhd
-- File Description:  Takes in VGA timing signals, outputs pixel oriented signals.
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

ENTITY vga_timing_decode IS
  GENERIC (
    HEIGHT          :     integer := 480;
    WIDTH           :     integer := 640;
    H_BP            :     integer := 117;
    V_BP            :     integer := 34;
    HEIGHT_BITS     :     integer := 10;
    WIDTH_BITS      :     integer := 10;
    DATA_DELAY      :     integer := 0
    );
  PORT (CLK         : IN  std_logic;
        RST         : IN  std_logic;
        HSYNC       : IN  std_logic;
        VSYNC       : IN  std_logic;
        X_COORD     : OUT unsigned(WIDTH_BITS-1 DOWNTO 0);
        Y_COORD     : OUT unsigned(HEIGHT_BITS-1 DOWNTO 0);
        PIXEL_COUNT : OUT unsigned(HEIGHT_BITS+WIDTH_BITS-1 DOWNTO 0);
        DATA_VALID  : OUT std_logic);
END vga_timing_decode;

ARCHITECTURE Behavioral OF vga_timing_decode IS
  SIGNAL hcount          : unsigned(WIDTH_BITS-1 DOWNTO 0)             := (OTHERS => '0');
  SIGNAL vcount          : unsigned(HEIGHT_BITS-1 DOWNTO 0)            := (OTHERS => '0');
  SIGNAL pixel_count_reg : unsigned(HEIGHT_BITS+WIDTH_BITS-1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL x_coord_reg     : unsigned(WIDTH_BITS-1 DOWNTO 0)             := (OTHERS => '0');
  SIGNAL y_coord_reg     : unsigned(HEIGHT_BITS-1 DOWNTO 0)            := (OTHERS => '0');
  SIGNAL prev_hsync      : std_logic                                   := '0';
  SIGNAL data_valid_reg  : std_logic                                   := '0';
BEGIN
  X_COORD     <= x_coord_reg;
  Y_COORD     <= y_coord_reg;
  PIXEL_COUNT <= pixel_count_reg;
  DATA_VALID  <= data_valid_reg;

  PROCESS (CLK) IS
  BEGIN  -- PROCESS 
    IF CLK'event AND CLK = '1' THEN
      IF RST = '1' THEN
        hcount          <= (OTHERS => '0');
        vcount          <= (OTHERS => '0');
        pixel_count_reg <= (OTHERS => '0');
        x_coord_reg     <= (OTHERS => '0');
        y_coord_reg     <= (OTHERS => '0');
        prev_hsync      <= '0';
        data_valid_reg  <= '0';
      ELSE
        prev_hsync      <= HSYNC;
        -----------------------------------------------------------------------
        -- Zones w.r.t. hcount
        -- 0<=X<H_BP-1                  -       Back Porch of H
        -- H_BP-1=<X<H_BP+WIDTH-1       -       Active horizontal data
        -- H_BP+WIDTH-1<=X              -       Front Porch/HSYNC

        -- The backporch -1 is due to the register delay
        IF HSYNC = '0' AND VSYNC = '0' AND hcount >= H_BP-DATA_DELAY-1 AND hcount < H_BP+WIDTH-DATA_DELAY-1 AND vcount >= V_BP AND vcount < V_BP+HEIGHT THEN
          data_valid_reg <= '1';
          IF data_valid_reg = '1' THEN  -- This makes the first valid pixel 0,
                                        -- instead of 1
            x_coord_reg  <= x_coord_reg + 1;
          END IF;

          -- This makes the first valid pixel 0, and properly increments the
          -- first pixels of every other line
          IF (data_valid_reg = '1' AND vcount = V_BP) OR vcount > V_BP THEN
            pixel_count_reg <= pixel_count_reg + 1;
          END IF;
        ELSE
          data_valid_reg    <= '0';
          x_coord_reg       <= (OTHERS => '0');
        END IF;

        IF VSYNC = '0' THEN
          IF HSYNC = '1' AND prev_hsync = '0' AND vcount >= V_BP AND vcount < V_BP+HEIGHT-1 THEN
            y_coord_reg   <= y_coord_reg + 1;
          END IF;
        ELSE
          vcount          <= (OTHERS => '0');
          pixel_count_reg <= (OTHERS => '0');
          y_coord_reg     <= (OTHERS => '0');
        END IF;

        IF HSYNC = '0' THEN
          hcount   <= hcount + 1;
        ELSE
          hcount   <= (OTHERS => '0');
          IF prev_hsync = '0' THEN
            vcount <= vcount + 1;
          END IF;
        END IF;
      END IF;
    END IF;
  END PROCESS;
END Behavioral;

