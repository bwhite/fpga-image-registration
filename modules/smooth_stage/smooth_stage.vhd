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
  PORT (CLK   : IN std_logic;
        RST   : IN std_logic;
        LEVEL : IN std_logic_vector(2 DOWNTO 0);

        MEM_PIXEL_READ   : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        MEM_ADDR         : OUT std_logic_vector (2*IMGSIZE_BITS-1 DOWNTO 0);
        MEM_PIXEL_WRITE  : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        MEM_RE           : OUT std_logic;
        MEM_OUTPUT_VALID : OUT std_logic);
END smooth_stage;

ARCHITECTURE Behavioral OF smooth_stage IS
  FUNCTION int_to_stdlvec (a, b : integer)
    RETURN std_logic_vector IS
  BEGIN
    RETURN std_logic_vector(to_unsigned(a, b));
  END FUNCTION int_to_stdlvec;

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
          -- NOTE: The following 2 inputs are only used when ROW_SKIP /=0
          LAST_VALID_Y_POS : IN  std_logic_vector(HEIGHT_BITS-1 DOWNTO 0);  --HEIGHT-CONV_HEIGHT-BORDER_SIZE-(HEIGHT-2*BORDER_SIZE-CONV_HEIGHT)%(1+ROW_SKIP)
          NEW_ROW_OFFSET   : IN  std_logic_vector(WIDTH_BITS+HEIGHT_BITS-1 DOWNTO 0);  -- WIDTH_OFFSET-2*BORDER_SIZE-ROW_SKIP*WIDTH
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

  COMPONENT pipeline_bit_buffer IS
    GENERIC (
      STAGES : integer := 1);
    PORT (CLK   : IN  std_logic;
          RST   : IN  std_logic;
          SET   : IN  std_logic;
          CLKEN : IN  std_logic;
          DIN   : IN  std_logic;
          DOUT  : OUT std_logic);
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
          PIXGEN_CLKEN     : OUT std_logic);
  END COMPONENT;

  COMPONENT pixel_buffer_3x3 IS
    GENERIC (
      PIXEL_BITS : IN integer := 9);
    PORT (CLK          : IN  std_logic;
          RST          : IN  std_logic;
          CLKEN        : IN  std_logic;
          NEW_ROW      : IN  std_logic;
          MEM_VALUE    : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
          OUTPUT_VALID : OUT std_logic;
          IMG_0_0      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
          IMG_0_1      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
          IMG_0_2      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
          IMG_1_0      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
          IMG_1_1      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
          IMG_1_2      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
          IMG_2_0      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
          IMG_2_1      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
          IMG_2_2      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0));
  END COMPONENT;

  COMPONENT smooth_conv_3x3 IS
  GENERIC (
    PIXEL_BITS : IN integer := 9);
  PORT (CLK          : IN  std_logic;
        RST          : IN  std_logic;
        INPUT_VALID  : IN  std_logic;
        -- 0:0:9
        IMG_0_0      : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG_0_1      : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG_0_2      : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG_1_0      : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG_1_1      : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG_1_2      : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG_2_0      : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG_2_1      : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG_2_2      : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        OUTPUT_VALID : OUT std_logic;
        -- 0:0:9
        IMG_SMOOTH   : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0));
END COMPONENT;
  
  SIGNAL pixgen_clken, coord_gen_new_row, coord_gen_done, coord_gen_new_row_buf, img_addr_valid, smooth_output_valid, pixgen_clken_buf, pix_buf_output_valid : std_logic;
  SIGNAL img_height, img_width, x_coord, y_coord                                                                                                             : std_logic_vector(IMGSIZE_BITS-1 DOWNTO 0);
  SIGNAL img_width_offset, img0_mem_addr, img0_mem_addr_buf, initial_mem_offset                                                                              : std_logic_vector(2*IMGSIZE_BITS-1 DOWNTO 0);
  SIGNAL coord_gen_state                                                                                                                                     : std_logic_vector(1 DOWNTO 0);
  SIGNAL pattern_state, pattern_state_buf                                                                                                                    : std_logic_vector(2 DOWNTO 0);
  SIGNAL img_0_0, img_0_1, img_0_2, img_1_0, img_1_1, img_1_2, img_2_0, img_2_1, img_2_2                                                                     : std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
  SIGNAL initial_mem_addr, mem_addroff0, mem_addroff1, img_mem_addr                                                                                          : std_logic_vector(IMGSIZE_BITS*2-1 DOWNTO 0);
BEGIN
-------------------------------------------------------------------------------
-- Parameter ROM: Holds parameters that vary depending on the pyramid level.
-- (Maximum X/Y image coordinates, X/Y Offset Values (to produce a zero mean of
-- pixel coordinates)), level/img offsets, and width offset values(for conv.
-- coordinate generation).
-- NOTE: Care must be taken in selecting these values to prevent (over/under)flow
  PROCESS (LEVEL) IS
  BEGIN  -- PROCESS
    CASE LEVEL IS
      -- NOTE x/y_coord_trans is in 1:IMGSIZE_BITS:1 Format, thus constants
      -- are multiplied by 2
      WHEN "101" =>                     -- 5x5 TESTING ONLY!!!
        img_height       <= int_to_stdlvec(10#5#, IMGSIZE_BITS);    -- 5
        img_width        <= int_to_stdlvec(10#5#, IMGSIZE_BITS);    -- 5
        img_width_offset <= int_to_stdlvec(10#9#, 2*IMGSIZE_BITS);  -- 9
        initial_mem_addr <= int_to_stdlvec(10#6#, 2*IMGSIZE_BITS);  -- 6
        -- TODO Update
        mem_addroff0     <= int_to_stdlvec(10#0#, 2*IMGSIZE_BITS);
        mem_addroff1     <= int_to_stdlvec(10#0#, 2*IMGSIZE_BITS);

      WHEN OTHERS =>
        img_height       <= (OTHERS => '0');
        img_width        <= (OTHERS => '0');
        img_width_offset <= (OTHERS => '0');
        initial_mem_addr <= (OTHERS => '0');
        mem_addroff0     <= (OTHERS => '0');
        mem_addroff1     <= (OTHERS => '0');
    END CASE;
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
--              NEW_ROW_OFFSET   => ,
--              LAST_VALID_Y_POS => ,
              MEM_ADDR         => img_mem_addr,
              CONV_Y_POS       => coord_gen_state,  -- 0=above cur pixel, 1=
                                                    -- current pixel, 2=below cur pixel for
                                                    -- 3x3
              DATA_VALID       => img_addr_valid,
              NEW_ROW          => coord_gen_new_row,
              DONE             => coord_gen_done);

-------------------------------------------------------------------------------
-- New Row Buffer
  pipebuf_newrow : pipeline_bit_buffer
    GENERIC MAP (
      STAGES => 3)
    PORT MAP (
      CLK   => CLK,
      SET   => '0',
      RST   => RST,
      CLKEN => '1',
      DIN   => coord_gen_new_row,
      DOUT  => coord_gen_new_row_buf);

-------------------------------------------------------------------------------
-- Memory Address Selector:  Take in the coord gen state and the pixgen_clken
-- signal to select the correct address (for reading values to the buffer or
-- for writing the smoothed value back), control RAM signals,
  smooth_address_selector_i : smooth_address_selector
    PORT MAP (
      CLK              => CLK,
      RST              => RST,
      IMG_MEM_ADDR     => img_mem_addr,
      IMG_ADDR_VALID   => img_addr_valid,
      CONV_Y_POS       => coord_gen_state,
      SMOOTH_VALID     => smooth_output_valid,
      MEM_ADDROFF0     => mem_addroff0,
      MEM_ADDROFF1     => mem_addroff1,
      PIXGEN_CLKEN     => pixgen_clken,
      -- Memory Outputs
      MEM_ADDR         => MEM_ADDR,
      MEM_RE           => MEM_RE,
      MEM_OUTPUT_VALID => MEM_OUTPUT_VALID);

-------------------------------------------------------------------------------
-- State Buffer
  pipebuf_state : pipeline_bit_buffer
    GENERIC MAP (
      STAGES => 5)
    PORT MAP (
      CLK   => CLK,
      SET   => '0',
      RST   => RST,
      CLKEN => '1',
      DIN   => pixgen_clken,
      DOUT  => pixgen_clken_buf);

-------------------------------------------------------------------------------
-- 3x3 Convolution Buffer:  Buffer a 3x3 neighborhood, ignore values that
-- result from memory writes (use the stage generated in the address selector)
  pixel_buffer_3x3_i : pixel_buffer_3x3
    PORT MAP (
      CLK          => CLK,
      RST          => RST,
      CLKEN        => pixgen_clken_buf,
      NEW_ROW      => coord_gen_new_row_buf,
      MEM_VALUE    => MEM_PIXEL_READ,   -- From Memory
      OUTPUT_VALID => pix_buf_output_valid,
      IMG_0_0      => img_0_0,
      IMG_0_1      => img_0_1,
      IMG_0_2      => img_0_2,
      IMG_1_0      => img_1_0,
      IMG_1_1      => img_1_1,
      IMG_1_2      => img_1_2,
      IMG_2_0      => img_2_0,
      IMG_2_1      => img_2_1,
      IMG_2_2      => img_2_2);

-------------------------------------------------------------------------------
-- 3x3 Smooth: Take in a neighborhood and produce a smoothed pixel value
-- centered in that neighborhood.
  smooth_conv_3x3_i : smooth_conv_3x3
    PORT MAP (
      CLK             => CLK,
      RST             => RST,
      INPUT_VALID     => pix_buf_output_valid,
      IMG_0_0         => img_0_0,
      IMG_0_1         => img_0_1,
      IMG_0_2         => img_0_2,
      IMG_1_0         => img_1_0,
      IMG_1_1         => img_1_1,
      IMG_1_2         => img_1_2,
      IMG_2_0         => img_2_0,
      IMG_2_1         => img_2_1,
      IMG_2_2         => img_2_2,
      OUTPUT_VALID    => smooth_output_valid,
      IMG_SMOOTH => MEM_PIXEL_WRITE);
END Behavioral;
