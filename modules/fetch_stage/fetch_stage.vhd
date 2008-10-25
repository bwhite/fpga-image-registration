-- Module Name: fetch_stage 
-- File Description: Reads memory data to populate IMG0 convolution buffer and
-- corresponding middle pixel value of IMG1.  Produces all necessary valid data
-- signals.
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

ENTITY fetch_stage IS
  GENERIC (
    CONV_HEIGHT      : integer := 3;
    IMGSIZE_BITS     : integer := 10;
    PIXEL_BITS       : integer := 9;
    CONV_HEIGHT_BITS : integer := 2;
    MEM_DELAY : integer := 4);
  PORT (CLK              : IN  std_logic;  -- NOTE: The clock should not be gated
                                        -- as the timing in this module depends
                                        -- on the timing of an external RAM
        RST              : IN  std_logic;
        LEVEL            : IN  std_logic_vector(2 DOWNTO 0);
        -- Affine Homography elements IMG2_VEC=H*IMG1_VEC
        -- Rotation and Non-Isotropic Scale
        -- 1:6:11 Format
        H_0_0            : IN  std_logic_vector(17 DOWNTO 0);
        H_0_1            : IN  std_logic_vector(17 DOWNTO 0);
        H_1_0            : IN  std_logic_vector(17 DOWNTO 0);
        H_1_1            : IN  std_logic_vector(17 DOWNTO 0);
        -- Translation
        -- 1:10:11 Format 
        H_0_2            : IN  std_logic_vector(21 DOWNTO 0);
        H_1_2            : IN  std_logic_vector(21 DOWNTO 0);
        -- External Memory Connections
        -- 0:0:PIXEL_BITS Format
        MEM_VALUE        : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        MEM_INPUT_VALID  : IN  std_logic;
        MEM_ADDR         : OUT std_logic_vector(2*IMGSIZE_BITS-1 DOWNTO 0);
        MEM_OUTPUT_VALID : OUT std_logic;
        -- IMG0 Neighborhood for spatial derivative computation (only output
        -- the union of the middle row pixels and the middle column pixels)
        -- 0:0:PIXEL_BITS Format
        IMG0_0_1         : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG0_1_0         : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG0_1_1         : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG0_1_2         : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG0_2_1         : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        -- IMG1 Center pixel value for temporal derivative computation
        IMG1_1_1         : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        -- Offset pixel coordinates for A/b matrix computation (offset to
        -- increase numerical accuracy, corrected later in the pipeline)
        -- 1:IMGSIZE_BITS:1 Format
        TRANS_X_COORD    : OUT std_logic_vector(IMGSIZE_BITS+1 DOWNTO 0);
        TRANS_Y_COORD    : OUT std_logic_vector(IMGSIZE_BITS+1 DOWNTO 0);

        FSCS_VALID : OUT std_logic;
        DONE       : OUT std_logic);
END fetch_stage;

ARCHITECTURE Behavioral OF fetch_stage IS
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
          INITIAL_MEM_ADDR : IN  std_logic_vector(WIDTH_BITS+HEIGHT_BITS-1 DOWNTO 0);
          MEM_ADDR         : OUT std_logic_vector (WIDTH_BITS+HEIGHT_BITS-1 DOWNTO 0);
          X_COORD          : OUT std_logic_vector (WIDTH_BITS-1 DOWNTO 0);
          Y_COORD          : OUT std_logic_vector (HEIGHT_BITS-1 DOWNTO 0);
          CONV_Y_POS       : OUT std_logic_vector (CONV_HEIGHT_BITS-1 DOWNTO 0);
          DATA_VALID       : OUT std_logic;
          NEW_ROW          : OUT std_logic;
          DONE             : OUT std_logic);
  END COMPONENT;


  COMPONENT img1_compute_mem_addr IS
    GENERIC (
      IMGSIZE_BITS : integer := IMGSIZE_BITS);
    PORT (CLK         : IN std_logic;
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
  END COMPONENT;



  COMPONENT mem_addr_selector IS
    GENERIC (
      MEMADDR_BITS  : integer := 2*IMGSIZE_BITS;
      PIXSTATE_BITS : integer := 2);

    PORT (CLK           : IN  std_logic;
          RST           : IN  std_logic;
          INPUT_VALID0  : IN  std_logic;
          INPUT_VALID1  : IN  std_logic;
          PIXEL_STATE   : IN  std_logic_vector(PIXSTATE_BITS-1 DOWNTO 0);
          MEM_ADDR0     : IN  std_logic_vector(MEMADDR_BITS-1 DOWNTO 0);
          MEM_ADDR1     : IN  std_logic_vector(MEMADDR_BITS-1 DOWNTO 0);
          MEM_ADDROFF0  : IN  std_logic_vector(MEMADDR_BITS-1 DOWNTO 0);
          MEM_ADDROFF1  : IN  std_logic_vector(MEMADDR_BITS-1 DOWNTO 0);
          PATTERN_STATE : OUT std_logic_vector (PIXSTATE_BITS DOWNTO 0);
          MEM_ADDR      : OUT std_logic_vector(MEMADDR_BITS-1 DOWNTO 0);
          OUTPUT_VALID  : OUT std_logic;
          PIXGEN_CLKEN  : OUT std_logic);
  END COMPONENT;

  COMPONENT pixel_conv_buffer IS
    GENERIC (
      PIXEL_BITS : IN integer := PIXEL_BITS);
    PORT (CLK           : IN  std_logic;
          RST           : IN  std_logic;
          NEW_ROW       : IN  std_logic;
          MEM_VALUE     : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
          INPUT_VALID   : IN  std_logic;
          PATTERN_STATE : IN  std_logic_vector(2 DOWNTO 0);
          OUTPUT_VALID  : OUT std_logic;
          IMG0_0_1      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
          IMG0_1_0      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
          IMG0_1_1      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
          IMG0_1_2      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
          IMG0_2_1      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
          IMG1_1_1      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0));
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

  -- 0:IMGSIZE_BITS:1 Format
  SIGNAL x_coord_trans, y_coord_trans             : std_logic_vector(IMGSIZE_BITS DOWNTO 0);
  -- 1:IMGSIZE_BITS:1 Format
  SIGNAL x_coord_shifted, y_coord_shifted, x_coord_shifted_buf, y_coord_shifted_buf : std_logic_vector(IMGSIZE_BITS+1 DOWNTO 0);
  -- 0:IMGSIZE_BITS:0 Format
  SIGNAL img_height, img_width, x_coord, y_coord  : std_logic_vector(IMGSIZE_BITS-1 DOWNTO 0);
  SIGNAL coord_gen_state                          : std_logic_vector(CONV_HEIGHT_BITS-1 DOWNTO 0);
  SIGNAL pattern_state_wire, pattern_state_buf                       : std_logic_vector(CONV_HEIGHT_BITS DOWNTO 0);
  SIGNAL new_row_buf                              : std_logic_vector(4 DOWNTO 0)                := (OTHERS => '0');
  SIGNAL done_buf                                 : std_logic_vector(6 DOWNTO 0)                := (OTHERS => '0');

  -- 0:2*IMGSIZE_BITS:0 Format
  SIGNAL img0_mem_addr, img1_mem_addr, img0_offset, img1_offset, img_width_offset, img1_mem_addr_buf0, img1_mem_addr_buf1, initial_mem_addr : std_logic_vector(2*IMGSIZE_BITS-1 DOWNTO 0);

  SIGNAL img0_addr_valid, img1_addr_valid, img1_output_valid, oob_x, oob_y, pixgen_clken, coord_gen_done, center_pixel_active, conv_buf_output_valid, coord_gen_new_row, mem_output_valid_wire : std_logic;
  SIGNAL mem_output_valid_buf                                                                                                                                                                   : std_logic;
  SIGNAL img1_output_valid_buf                                                                                                                                          : std_logic_vector(1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL mem_value_buf                                                                                                                                                                         : std_logic_vector(8 DOWNTO 0) := (OTHERS => '0');  --
                                        --TODO REMOVE

BEGIN
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
            y_coord_trans    <= int_to_stdlvec(10#480#, IMGSIZE_BITS+1);  -- 240
            x_coord_trans    <= int_to_stdlvec(10#720#, IMGSIZE_BITS+1);  -- 360
            img0_offset      <= int_to_stdlvec(10#0#, 2*IMGSIZE_BITS);  -- 0
            img1_offset      <= int_to_stdlvec(10#345600#, 2*IMGSIZE_BITS);  -- 345,600
            img_height       <= int_to_stdlvec(10#480#, IMGSIZE_BITS);  -- 480
            img_width        <= int_to_stdlvec(10#720#, IMGSIZE_BITS);  -- 720
            img_width_offset <= int_to_stdlvec(10#1439#, 2*IMGSIZE_BITS);  -- 1439 (CONV_HEIGHT-1)*WIDTH-1
            initial_mem_addr <= int_to_stdlvec(10#721#, 2*IMGSIZE_BITS);  -- 721 WIDTH+1

          WHEN "001" =>                 -- 360x240
            y_coord_trans    <= int_to_stdlvec(10#240#, IMGSIZE_BITS+1);  -- 120
            x_coord_trans    <= int_to_stdlvec(10#360#, IMGSIZE_BITS+1);  -- 180
            img0_offset      <= int_to_stdlvec(10#691200#, 2*IMGSIZE_BITS);  -- 691,200
            img1_offset      <= int_to_stdlvec(10#777600#, 2*IMGSIZE_BITS);  -- 777,600
            img_height       <= int_to_stdlvec(10#240#, IMGSIZE_BITS);  -- 240
            img_width        <= int_to_stdlvec(10#360#, IMGSIZE_BITS);  -- 360
            img_width_offset <= int_to_stdlvec(10#719#, 2*IMGSIZE_BITS);  -- 719
            initial_mem_addr <= int_to_stdlvec(10#361#, 2*IMGSIZE_BITS);  -- 361

          WHEN "010" =>                 -- 180x120
            y_coord_trans    <= int_to_stdlvec(10#120#, IMGSIZE_BITS+1);  -- 60
            x_coord_trans    <= int_to_stdlvec(10#180#, IMGSIZE_BITS+1);  -- 90
            img0_offset      <= int_to_stdlvec(10#864000#, 2*IMGSIZE_BITS);  -- 864,000
            img1_offset      <= int_to_stdlvec(10#885600#, 2*IMGSIZE_BITS);  -- 885,600
            img_height       <= int_to_stdlvec(10#120#, IMGSIZE_BITS);  -- 120
            img_width        <= int_to_stdlvec(10#180#, IMGSIZE_BITS);  -- 180
            img_width_offset <= int_to_stdlvec(10#359#, 2*IMGSIZE_BITS);  -- 359
            initial_mem_addr <= int_to_stdlvec(10#181#, 2*IMGSIZE_BITS);  -- 181
            
          WHEN "011" =>                 -- 90x60
            y_coord_trans    <= int_to_stdlvec(10#60#, IMGSIZE_BITS+1);   -- 30
            x_coord_trans    <= int_to_stdlvec(10#90#, IMGSIZE_BITS+1);   -- 45
            img0_offset      <= int_to_stdlvec(10#907200#, 2*IMGSIZE_BITS);  -- 907,200
            img1_offset      <= int_to_stdlvec(10#912600#, 2*IMGSIZE_BITS);  -- 912,600
            img_height       <= int_to_stdlvec(10#60#, IMGSIZE_BITS);     -- 60
            img_width        <= int_to_stdlvec(10#90#, IMGSIZE_BITS);     -- 90
            img_width_offset <= int_to_stdlvec(10#179#, 2*IMGSIZE_BITS);  -- 179
            initial_mem_addr <= int_to_stdlvec(10#91#, 2*IMGSIZE_BITS);   -- 91
            
          WHEN "100" =>                 -- 45x30
            y_coord_trans    <= int_to_stdlvec(10#30#, IMGSIZE_BITS+1);  -- 15
            x_coord_trans    <= int_to_stdlvec(10#45#, IMGSIZE_BITS+1);  -- 22.5
            img0_offset      <= int_to_stdlvec(10#918000#, 2*IMGSIZE_BITS);  -- 918,000
            img1_offset      <= int_to_stdlvec(10#919350#, 2*IMGSIZE_BITS);  -- 919,350
            img_height       <= int_to_stdlvec(10#30#, IMGSIZE_BITS);    -- 30
            img_width        <= int_to_stdlvec(10#45#, IMGSIZE_BITS);    -- 45
            img_width_offset <= int_to_stdlvec(10#89#, 2*IMGSIZE_BITS);  -- 89
            initial_mem_addr <= int_to_stdlvec(10#46#, 2*IMGSIZE_BITS);  -- 46
            
          WHEN "101" =>                 -- 5x5 TESTING ONLY!!!
            y_coord_trans    <= int_to_stdlvec(10#5#, IMGSIZE_BITS+1);  -- 2.5
            x_coord_trans    <= int_to_stdlvec(10#5#, IMGSIZE_BITS+1);  -- 2.5
            img0_offset      <= int_to_stdlvec(10#918000#, 2*IMGSIZE_BITS);  -- 920,700
            img1_offset      <= int_to_stdlvec(10#919350#, 2*IMGSIZE_BITS);  -- 920,725
            img_height       <= int_to_stdlvec(10#5#, IMGSIZE_BITS);    -- 5
            img_width        <= int_to_stdlvec(10#5#, IMGSIZE_BITS);    -- 5
            img_width_offset <= int_to_stdlvec(10#9#, 2*IMGSIZE_BITS);  -- 9
            initial_mem_addr <= int_to_stdlvec(10#6#, 2*IMGSIZE_BITS);  -- 6
          WHEN "110" =>                 -- 6x6 TESTING ONLY!!!
            y_coord_trans    <= int_to_stdlvec(10#6#, IMGSIZE_BITS+1);  -- 3
            x_coord_trans    <= int_to_stdlvec(10#6#, IMGSIZE_BITS+1);  -- 3
            img0_offset      <= int_to_stdlvec(10#918000#, 2*IMGSIZE_BITS);  -- 920,700
            img1_offset      <= int_to_stdlvec(10#919350#, 2*IMGSIZE_BITS);  -- 920,725
            img_height       <= int_to_stdlvec(10#6#, IMGSIZE_BITS);    -- 6
            img_width        <= int_to_stdlvec(10#6#, IMGSIZE_BITS);    -- 6
            img_width_offset <= int_to_stdlvec(10#11#, 2*IMGSIZE_BITS);  -- 11
            initial_mem_addr <= int_to_stdlvec(10#7#, 2*IMGSIZE_BITS);  -- 7

          WHEN OTHERS =>
            y_coord_trans    <= (OTHERS => '0');
            x_coord_trans    <= (OTHERS => '0');
            img0_offset      <= (OTHERS => '0');
            img1_offset      <= (OTHERS => '0');
            img_height       <= (OTHERS => '0');
            img_width        <= (OTHERS => '0');
            img_width_offset <= (OTHERS => '0');
            initial_mem_addr <= (OTHERS => '0');
        END CASE;
      END IF;
    END IF;
  END PROCESS;

-- Convolution Pixel Stream: Stream pixel coordinates in a convolution pattern.
-- 1CT Delay
  conv_pixel_ordering_i : conv_pixel_ordering
    PORT MAP (CLK              => CLK,
              CLKEN            => pixgen_clken,
              RST              => RST,
              HEIGHT           => img_height,
              WIDTH            => img_width,
              WIDTH_OFFSET     => img_width_offset,
              INITIAL_MEM_ADDR => initial_mem_addr,
              MEM_ADDR         => img0_mem_addr,
              CONV_Y_POS       => coord_gen_state,  -- 0=above cur pixel, 1=
                                                    -- current pixel, 2=below cur pixel for
                                                    -- 3x3
              X_COORD          => x_coord,
              Y_COORD          => y_coord,
              DATA_VALID       => img0_addr_valid,
              NEW_ROW          => coord_gen_new_row,
              DONE             => coord_gen_done);

-- New Row Buffer: Buffer the NEW_ROW signal from the conv_pixel_ordering
  -- ?CT Delay
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)
        new_row_buf <= (OTHERS => '0');
      ELSE
        FOR i IN 3 DOWNTO 0 LOOP
          new_row_buf(i+1) <= new_row_buf(i);
        END LOOP;  -- i
        new_row_buf(0) <= coord_gen_new_row;
      END IF;
    END IF;
  END PROCESS;

-- Done Buffer: Buffer the DONE signal from the conv_pixel_ordering
  DONE <= done_buf(6);
                                        -- 5CT Delay
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)
        done_buf <= (OTHERS => '0');
      ELSE
        FOR i IN 5 DOWNTO 0 LOOP
          done_buf(i+1) <= done_buf(i);
        END LOOP;  -- i
        done_buf(0) <= coord_gen_done;
      END IF;
    END IF;
  END PROCESS;

-- Current Pixel Coord Check: Store current pixel coordinates (the center of the
-- convolution).
-- NOTE: This assumes that the pixel generator will never be halted (CLKEN='0') on the center pixel value.
  -- 0CT Delay
  PROCESS (img0_addr_valid, coord_gen_state) IS
  BEGIN  -- PROCESS
    IF img0_addr_valid = '1' AND coord_gen_state = "01" THEN
      center_pixel_active <= '1';
    ELSE
      center_pixel_active <= '0';
    END IF;
  END PROCESS;

-- Img1 Compute Memory Address: Computes the IMG1 memory address given IMG0 X,
-- Y coords, the image HEIGHT/WIDTH, and a homography H (such that H*IMG0_COORD=IMG1_COORD)
  -- 6CT Delay
  img1_compute_mem_addr_i : img1_compute_mem_addr
    PORT MAP (
      CLK          => CLK,
      RST          => RST,
      INPUT_VALID  => center_pixel_active,
      X_COORD      => x_coord,
      Y_COORD      => y_coord,
      IMG_HEIGHT   => img_height,
      IMG_WIDTH    => img_width,
      H_0_0        => H_0_0,
      H_1_0        => H_1_0,
      H_0_1        => H_0_1,
      H_1_1        => H_1_1,
      H_0_2        => H_0_2,
      H_1_2        => H_1_2,
      MEM_ADDR     => img1_mem_addr,
      OUTPUT_VALID => img1_output_valid,
      OOB_X        => oob_x,
      OOB_Y        => oob_y);

-- Translate Coords: Translate the image coordinates to make (0,0) the mean
-- value (for numeric stability)
  -- 10CT Delay
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      x_coord_shifted <= std_logic_vector(signed('0'&x_coord&'0')-signed('0'&x_coord_trans));
      y_coord_shifted <= std_logic_vector(signed('0'&y_coord&'0')-signed('0'&y_coord_trans));
    END IF;
  END PROCESS;
  
  x_coord_buffer : pipeline_buffer
    GENERIC MAP (
      WIDTH         => IMGSIZE_BITS+2,
      STAGES        => 11,-- TODO Fix
      DEFAULT_VALUE => 2#0#)
    PORT MAP (
      CLK   => CLK,
      RST   => RST,
      CLKEN => '1',
      DIN   => x_coord_shifted,
      DOUT  => x_coord_shifted_buf);

  y_coord_buffer : pipeline_buffer
    GENERIC MAP (
      WIDTH         => IMGSIZE_BITS+2,
      STAGES        => 11,-- TODO Fix
      DEFAULT_VALUE => 2#0#)
    PORT MAP (
      CLK   => CLK,
      RST   => RST,
      CLKEN => '1',
      DIN   => y_coord_shifted,
      DOUT  => y_coord_shifted_buf);
  
  TRANS_X_COORD <= x_coord_shifted_buf;
  TRANS_Y_COORD <= y_coord_shifted_buf;

-- Memory Address Selector: Read 3 pixels from IMG0 using the coord generator'
-- s memory address, pause the coord generator, read 1 pixel from IMG1 using
-- the warped coord address
  -- 0CT
  PROCESS (img1_output_valid, oob_x, oob_y) IS
  BEGIN  -- PROCESS
    IF img1_output_valid = '1' AND oob_x = '0' AND oob_y = '0' THEN
      img1_addr_valid <= '1';
    ELSE
      img1_addr_valid <= '0';
    END IF;
  END PROCESS;

                                        -- 1CT Delay
  mem_addr_selector_i : mem_addr_selector
    PORT MAP (CLK           => CLK,
              RST           => RST,
              INPUT_VALID0  => img0_addr_valid,
              INPUT_VALID1  => img1_addr_valid,
              PIXEL_STATE   => coord_gen_state,
              MEM_ADDR0     => img0_mem_addr,
              MEM_ADDR1     => img1_mem_addr,
              MEM_ADDROFF0  => img0_offset,
              MEM_ADDROFF1  => img1_offset,
              PATTERN_STATE => pattern_state_wire,
              MEM_ADDR      => MEM_ADDR,
              OUTPUT_VALID  => mem_output_valid_wire,
              PIXGEN_CLKEN  => pixgen_clken);
  MEM_OUTPUT_VALID <= mem_output_valid_wire;

-- Pattern State Buffer: Buffer the pattern_state_wire signal so that it
-- coincides with the resulting pixel value coming from the memory
  -- 2CT Delay
  pattern_state_buffer : pipeline_buffer
    GENERIC MAP (
      WIDTH         => CONV_HEIGHT_BITS+1,
      STAGES        => 2,-- TODO Fix
      DEFAULT_VALUE => 2#0#)
    PORT MAP (
      CLK   => CLK,
      RST   => RST,
      CLKEN => '1',
      DIN   => pattern_state_wire,
      DOUT  => pattern_state_buf);
  
-- Mem Input Valid Buffer: This is only intended for simulation when the
-- memory input buffer is not present.
  -- NOTE: For final use this will be removed
  -- 2CT Delay
    mem_valid_buffer : pipeline_bit_buffer
    GENERIC MAP (
      STAGES => 4)                      -- TODO Fix
    PORT MAP (
      CLK   => CLK,
      SET   => '0',
      RST   => RST,
      CLKEN => '1',
      DIN   => mem_output_valid_wire,
      DOUT  => mem_output_valid_buf);

-- Mem Value Register: Stores the incoming value into a register
-- NOTE: THIS ABSOLUTELY MUST BE REMOVED WHEN USING A REAL MEMORY CONTROLLER AS
-- IT WILL SKEW THE CTs BY 1. IT IS ONLY USED TO SIMPLIFY SIMULATION TIMING!!!
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)
        mem_value_buf <= (OTHERS => '0');
      ELSE
        mem_value_buf <= MEM_VALUE;
      END IF;
    END IF;
  END PROCESS;

-------------------------------------------------------------------------------
-- 3x3 Convolution Buffer:  Buffer a 3x3 neighborhood, ignore values that
-- result from memory writes (use the stage generated in the address selector)

-- Pixel Buffer : Store the kernel neighborhood and update it with incoming
-- pixel values. Note that since there is a delay between when the read
-- command is asserted and when the valid data is available, the cur pixel
-- state will be pipelined to align the valid data with the pixel state.
  pixel_buffer_3x3_i : pixel_buffer_3x3
    PORT MAP (
      CLK          => CLK,
      RST          => RST,
      CLKEN        => mem_output_valid_buf, 
      NEW_ROW      => new_row_buf(2),
      MEM_VALUE    => mem_value_buf,           --MEM_VALUE
      OUTPUT_VALID => conv_buf_output_valid,
      IMG_0_1      => IMG0_0_1,
      IMG_1_0      => IMG0_1_0,
      IMG_1_1      => IMG0_1_1,
      IMG_1_2      => IMG0_1_2,
      IMG_2_1      => IMG0_2_1);
  img1_1_1_buffer : pipeline_buffer
    GENERIC MAP (
      WIDTH         => PIXEL_BITS,
      STAGES        => 4,-- TODO Fix
      DEFAULT_VALUE => 2#0#)
    PORT MAP (
      CLK   => CLK,
      RST   => RST,
      CLKEN => '1',
      DIN   => mem_value_buf,           --MEM_VALUE,
      DOUT  => IMG1_1_1);

  FSCS_VALID <= conv_buf_output_valid;
END Behavioral;
