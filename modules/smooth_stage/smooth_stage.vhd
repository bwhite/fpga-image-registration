-- Module Name: smooth_stage.vhd
-- File Description: This module streams a set of memory address values to an
-- external RAM that returns the value, these values are used to build a
-- convolution buffer.  The memory value reading will be halted for one CT so
-- that the result can be written back, then the process continues.  This takes
-- in a LEVEL parameter that specifies which of the internal configurations
-- should be used (which correspond to image resolutions).
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

ENTITY smooth_stage IS
  GENERIC (
    IMGSIZE_BITS : integer := 10;
    PIXEL_BITS   : integer := 9;
    MEM_DELAY    : integer := 4);
  PORT (CLK : IN std_logic;
        RST : IN std_logic;

        -- TODO Add memory output valid
        MEM_ADDR         : IN  std_logic_vector (2*IMGSIZE_BITS-1 DOWNTO 0);
        MEM_PIXEL_READ   : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        MEM_PIXEL_WRITE  : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        MEM_RE           : OUT std_logic;
        MEM_OUTPUT_VALID : OUT std_logic);
END smooth_stage;

ARCHITECTURE Behavioral OF smooth_stage IS
  COMPONENT conv_pixel_ordering IS
    GENERIC (
      CONV_HEIGHT      : integer := 3;
      BORDER_SIZE      : integer := 1;
      WIDTH_BITS       : integer := IMGSIZE_BITS;
      HEIGHT_BITS      : integer := IMGSIZE_BITS;
      CONV_HEIGHT_BITS : integer := 2);
    PORT (CLK              : IN  std_logic;
          CLKEN            : IN  std_logic;
          RST              : IN  std_logic;
          HEIGHT           : IN  std_logic_vector(HEIGHT_BITS-1 DOWNTO 0);
          WIDTH            : IN  std_logic_vector(WIDTH_BITS-1 DOWNTO 0);
          WIDTH_OFFSET     : IN  std_logic_vector(WIDTH_BITS+HEIGHT_BITS-1 DOWNTO 0);  -- (CONV_HEIGHT-1)*WIDTH-1
          INITIAL_MEM_ADDR : IN  std_logic_vector(WIDTH_BITS+HEIGHT_BITS-1 DOWNTO 0);
          MEM_ADDR         : OUT std_logic_vector (WIDTH_BITS+HEIGHT_BITS-1 DOWNTO 0);
          X_COORD          : OUT std_logic_vector (WIDTH_BITS-1 DOWNTO 0);
          Y_COORD          : OUT std_logic_vector (HEIGHT_BITS-1 DOWNTO 0);
          CONV_Y_POS       : OUT std_logic_vector (CONV_HEIGHT_BITS-1 DOWNTO 0);
          DATA_VALID       : OUT std_logic;
          NEW_ROW          : OUT std_logic;
          DONE             : OUT std_logic);
  END COMPONENT;

  COMPONENT pipeline_buffer IS
    GENERIC (
      WIDTH         : integer := 1;
      STAGES        : integer := 1;
      DEFAULT_VALUE : integer := 2#0#);
    PORT (CLK   : IN  std_logic;
          RST   : IN  std_logic;
          CLKEN : IN  std_logic;
          DIN   : IN  std_logic_vector(WIDTH-1 DOWNTO 0);
          DOUT  : OUT std_logic_vector(WIDTH-1 DOWNTO 0));
  END COMPONENT;

  COMPONENT smooth_address_selector IS
    GENERIC (
      IMGSIZE_BITS : integer := 10;
      PIXEL_BITS   : integer := 9;
      MEM_DELAY    : integer := 4);

    PORT (CLK              : IN  std_logic;
          RST              : IN  std_logic;
          IMG_MEM_ADDR     : IN  std_logic_vector(IMGSIZE_BITS*2-1 DOWNTO 0);
          IMG_ADDR_VALID   : IN  std_logic;
          CONV_Y_POS       : IN  std_logic_vector(1 DOWNTO 0);
          SMOOTH_VALID     : IN  std_logic;
          MEM_ADDROFF0     : IN  std_logic_vector(IMGSIZE_BITS*2-1 DOWNTO 0);
          MEM_ADDROFF1     : IN  std_logic_vector(IMGSIZE_BITS*2-1 DOWNTO 0);
          MEM_ADDR         : OUT std_logic_vector(IMGSIZE_BITS*2-1 DOWNTO 0);
          MEM_RE           : OUT std_logic;
          MEM_OUTPUT_VALID : OUT std_logic;
          PIXGEN_CLKEN     : OUT std_logic;
          PIXEL_STATE      : OUT std_logic_vector(2 DOWNTO 0));
  END COMPONENT;

  SIGNAL pixgen_clken, img0_addr_valid, coord_gen_new_row, coord_gen_done, coord_gen_new_row_buf : std_logic;
  SIGNAL img_height, img_width, x_coord, y_coord                                                 : std_logic_vector(IMGSIZE-1 DOWNTO 0);
  SIGNAL img_width_offset, img0_mem_addr, img0_mem_addr_buf, initial_mem_offset                  : std_logic_vector(2*IMGSIZE-1 DOWNTO 0);
  SIGNAL coord_gen_state                                                                         : std_logic_vector(1 DOWNTO 0);
  SIGNAL pattern_state, pattern_state_buf                                                        : std_logic_vector(2 DOWNTO 0);
BEGIN
-------------------------------------------------------------------------------
-- Parameter ROM: Holds parameters that vary depending on the pyramid level.
-- (Maximum X/Y image coordinates, X/Y Offset Values (to produce a zero mean of
-- pixel coordinates)), level/img offsets, and width offset values(for conv.
-- coordinate generation). This only loads the new value on RST.
-- NOTE: Care must be taken in selecting these values to prevent (over/under)flow
-- NOTE: This requires this entire stage to be RST for one CT to initialize the
-- registers, LEVEL value must be valid during this time.
-- 1CT Delay
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)
        CASE LEVEL IS
          -- NOTE x/y_coord_trans is in 1:IMGSIZE_BITS:1 Format, thus constants
          -- are multiplied by 2
          WHEN "000" =>                 -- 720x480
            -- TODO Make one for 640x480

          WHEN "101" =>                 -- 5x5 TESTING ONLY!!!
            img_height       <= int_to_stdlvec(10#5#, IMGSIZE_BITS);    -- 5
            img_width        <= int_to_stdlvec(10#5#, IMGSIZE_BITS);    -- 5
            img_width_offset <= int_to_stdlvec(10#9#, 2*IMGSIZE_BITS);  -- 9
            initial_mem_addr <= int_to_stdlvec(10#6#, 2*IMGSIZE_BITS);  -- 6

          WHEN OTHERS =>
            img_height       <= (OTHERS => '0');
            img_width        <= (OTHERS => '0');
            img_width_offset <= (OTHERS => '0');
            initial_mem_addr <= (OTHERS => '0');
        END CASE;
      END IF;
    END IF;
  END PROCESS;

-------------------------------------------------------------------------------
-- Coord Generator
-- 1CT Delay
  conv_pixel_ordering_i : conv_pixel_ordering
    PORT MAP (CLK              => CLK,
              CLKEN            => pixgen_clken,
              RST              => RST,
              HEIGHT           => img_height,
              WIDTH            => img_width,
              WIDTH_OFFSET     => img_width_offset,
              INITIAL_MEM_ADDR => initial_mem_addr,
              NEW_ROW_OFFSET   => (OTHERS => '0'),
              LAST_VALID_Y_POS => (OTHERS => '0'),
              MEM_ADDR         => img_mem_addr,
              CONV_Y_POS       => coord_gen_state,  -- 0=above cur pixel, 1=
                                                    -- current pixel, 2=below cur pixel for
                                                    -- 3x3
              DATA_VALID       => img_addr_valid,
              NEW_ROW          => coord_gen_new_row,
              DONE             => coord_gen_done);

-------------------------------------------------------------------------------
-- New Row Buffer
  pipebuf_newrow : pipeline_buffer
    GENERIC MAP (
      WIDTH         => 1,
      STAGES        => 3,
      DEFAULT_VALUE => 2#0#)
    PORT MAP (
      CLK   => CLK,
      RST   => '0',
      CLKEN => '1',
      DIN   => (0 DOWNTO 0 => coord_gen_new_row),
      DOUT  => (0 DOWNTO 0 => coord_gen_new_row_buf));

-------------------------------------------------------------------------------
-- Memory Address Selector:  Take in the coord gen state and the pixgen_clken
-- signal to select the correct address (for reading values to the buffer or
-- for writing the smoothed value back), control RAM signals,
  smooth_address_selector_i : smooth_address_selector
    PORT MAP (
      CLK              => CLK,
      RST              => RST,
      IMG_MEM_ADDR     => <actual > ,
      IMG_ADDR_VALID   => <actual > ,
      CONV_Y_POS       => <actual > ,
      SMOOTH_VALID     => <actual > ,
      MEM_ADDROFF0     => <actual > ,
      MEM_ADDROFF1     => <actual > ,
      MEM_ADDR         => <actual > ,
      MEM_RE           => <actual > ,
      MEM_OUTPUT_VALID => <actual > ,
      PIXGEN_CLKEN     => <actual > ,
      PIXEL_STATE      => <actual > );

-------------------------------------------------------------------------------
-- State Buffer
  pipebuf_state : pipeline_buffer
    GENERIC MAP (
      WIDTH         => 3,
      STAGES        => 5,
      DEFAULT_VALUE => 2#0#)
    PORT MAP (
      CLK   => CLK,
      RST   => '0',
      CLKEN => '1',
      DIN   => pattern_state,
      DOUT  => pattern_state_buf);

-------------------------------------------------------------------------------
-- 3x3 Convolution Buffer:  Buffer a 3x3 neighborhood, ignore values that
-- result from memory writes (use the stage generated in the address selector)
  pixel_conv_buffer_i : pixel_conv_buffer_3x3
    PORT MAP (
      CLK           => CLK,
      RST           => RST,
      NEW_ROW       => ,
      MEM_VALUE     => ,
      INPUT_VALID   => ,
      PATTERN_STATE => ,
      OUTPUT_VALID  => ,
      IMG0_0_0      => IMG0_0_0,
      IMG0_0_1      => IMG0_0_1,
      IMG0_0_2      => IMG0_0_2,
      IMG0_1_0      => IMG0_1_0,
      IMG0_1_1      => IMG0_1_1,
      IMG0_1_2      => IMG0_1_2,
      IMG0_2_0      => IMG0_2_0,
      IMG0_2_1      => IMG0_2_1,
      IMG0_2_2      => IMG0_2_2);      

-------------------------------------------------------------------------------
-- 3x3 Smooth: Take in a neighborhood and produce a smoothed pixel value
-- centered in that neighborhood.
  smooth_conv_3x3_i : smooth_conv_3x3
    PORT MAP (
      CLK          => CLK,
      RST          => RST,
      INPUT_VALID  => <actual > ,
      OUTPUT_VALID => <actual > ,
      IMG0_0_0     => img0_0_0,
      IMG0_0_1     => img0_0_1,
      IMG0_0_2     => img0_0_2,
      IMG0_1_0     => img0_1_0,
      IMG0_1_1     => img0_1_1,
      IMG0_1_2     => img0_1_2,
      IMG0_2_0     => img0_2_0,
      IMG0_2_1     => img0_2_1,
      IMG0_2_2     => img0_2_2); 

END Behavioral;
