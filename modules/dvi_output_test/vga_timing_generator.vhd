-- Module Name:  vga_timing_generator.vhd
-- File Description:  Generates VGA timing signals.
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


ENTITY vga_timing_generator IS
  GENERIC (WIDTH       : integer := 1024;
           H_FP        : integer := 24;
           H_SYNC      : integer := 136;
           H_BP        : integer := 160;
           HEIGHT      : integer := 768;
           V_FP        : integer := 3;
           V_SYNC      : integer := 6;
           V_BP        : integer := 29;
           HEIGHT_BITS : integer := 10;
           WIDTH_BITS  : integer := 10;
           HCOUNT_BITS : integer := 11;
           VCOUNT_BITS : integer := 11;
           DATA_DELAY  : integer := 0


           );
  PORT (CLK            : IN  std_logic;
        RST            : IN  std_logic;
        HSYNC          : OUT std_logic;
        VSYNC          : OUT std_logic;
        X_COORD        : OUT std_logic_vector(WIDTH_BITS-1 DOWNTO 0);
        Y_COORD        : OUT std_logic_vector(HEIGHT_BITS-1 DOWNTO 0);
        PIXEL_COUNT    : OUT std_logic_vector(WIDTH_BITS+HEIGHT_BITS-1 DOWNTO 0);
        DATA_VALID     : OUT std_logic;
        DATA_VALID_EXT : OUT std_logic);
END vga_timing_generator;

ARCHITECTURE Behavioral OF vga_timing_generator IS
  CONSTANT H_TOTAL                  : integer                                     := WIDTH+H_FP+H_SYNC+H_BP;
  CONSTANT V_TOTAL                  : integer                                     := HEIGHT+V_FP+V_SYNC+V_BP;
  -- bit more than specified to cover the H_FP
  SIGNAL   hcount                   : unsigned(HCOUNT_BITS-1 DOWNTO 0)            := (OTHERS => '0');
  SIGNAL   vcount                   : unsigned(VCOUNT_BITS-1 DOWNTO 0)            := (OTHERS => '0');
  SIGNAL   vsync_reg, hsync_reg     : std_logic                                   := '0';  -- NOTE These are active high signals
  SIGNAL   pixel_count_reg          : unsigned(WIDTH_BITS+HEIGHT_BITS-1 DOWNTO 0) := (OTHERS => '0');  -- This is used to keep track of the number of valid pixels that have been output this frame.  Used to allow pixel selection to be made based on 1D memory addresses.
  SIGNAL   x_coord_reg              : unsigned(WIDTH_BITS-1 DOWNTO 0)             := (OTHERS => '0');
  SIGNAL   y_coord_reg              : unsigned(HEIGHT_BITS-1 DOWNTO 0)            := (OTHERS => '0');
  SIGNAL   data_valid_reg           : std_logic                                   := '0';
BEGIN
  HSYNC       <= hsync_reg;
  VSYNC       <= vsync_reg;
  X_COORD     <= std_logic_vector(x_coord_reg);
  Y_COORD     <= std_logic_vector(y_coord_reg);
  PIXEL_COUNT <= std_logic_vector(pixel_count_reg);
  DATA_VALID  <= data_valid_reg;
  PROCESS(CLK)
  BEGIN
    -----------------------------------------------------------------------
    -- Zones w.r.t. hcount
    -- 0<=X<H_BP-1                        -  Back Porch of H
    -- H_BP-1=<X<H_BP+WIDTH-1             -  Active horizontal data
    -- H_BP+WIDTH-1<=X<WIDTH+H_FP+H_BP-1  -  Front Porch/HSYNC
    -- WIDTH+H_FP+H_BP-1<=X<H_TOTAL-1     -  HSYNC

    -- Horizontal Pixel Count
    IF (CLK'event AND CLK = '1') THEN
      IF (RST = '1') THEN
        vcount          <= (OTHERS => '0');
        hcount          <= (OTHERS => '0');
        hsync_reg       <= '0';
        vsync_reg       <= '0';
        pixel_count_reg <= (OTHERS => '0');
        x_coord_reg     <= (OTHERS => '0');
        y_coord_reg     <= (OTHERS => '0');
      ELSE
        -- Data valid signal - This is corrected for the data delay by doing
        -- everything early by DATA_DELAY CTs.
        IF (H_BP-DATA_DELAY-1 <= hcount AND hcount < WIDTH+H_BP-DATA_DELAY-1 AND V_BP <= vcount AND vcount < HEIGHT+V_BP) THEN
          data_valid_reg <= '1';
          IF data_valid_reg = '1' THEN
            x_coord_reg <= x_coord_reg + 1;
          END IF;
          IF (data_valid_reg = '1' AND vcount = V_BP) OR vcount > V_BP THEN
            pixel_count_reg <= pixel_count_reg + 1;
          END IF;
        ELSE
          x_coord_reg    <= (OTHERS => '0');
          data_valid_reg <= '0';
        END IF;

        -- Data valid external signal (to be in line with HSYNC/VSYNC)
        IF (H_BP-1 <= hcount AND hcount < WIDTH+H_BP-1 AND V_BP <= vcount AND vcount < HEIGHT+V_BP) THEN
          DATA_VALID_EXT <= '1';
        ELSE
          DATA_VALID_EXT <= '0';
        END IF;

        -- Horizontal Line Counter
        IF hcount = (H_TOTAL-1) THEN    -- Reset hcount
          hcount <= (OTHERS => '0');
        ELSE
          hcount <= hcount + 1;
        END IF;

        -- Vertical Line Counter
        IF hcount = (H_TOTAL - 1) AND (vcount = (V_TOTAL - 1)) THEN  -- Reset
                                                                     -- vcount
          vcount          <= (OTHERS => '0');
          pixel_count_reg <= (OTHERS => '0');
          y_coord_reg     <= (OTHERS => '0');
        ELSIF hcount = (H_TOTAL - 1) THEN
          vcount  <= vcount + 1;
          IF V_BP <= vcount AND vcount < HEIGHT+V_BP-1 THEN
            y_coord_reg <= y_coord_reg + 1;
          END IF;
        END IF;

        -- Horizontal Sync Pulse
        IF hcount = (WIDTH+H_FP+H_BP-1) THEN
          hsync_reg <= '1';
        ELSIF hcount = (H_TOTAL-1) THEN
          hsync_reg <= '0';
        END IF;

        -- Vertical Sync Pulse
        IF hcount = (H_TOTAL-1) AND vcount = (HEIGHT+V_FP+V_BP-1) THEN
          vsync_reg <= '1';
        ELSIF hcount = (H_TOTAL-1) AND vcount = (V_TOTAL-1) THEN
          vsync_reg <= '0';
        END IF;
      END IF;
    END IF;
  END PROCESS;
END Behavioral;

