LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY fetch_stage IS
  GENERIC (
    CONV_HEIGHT      :    integer := 3;
    IMGSIZE_BITS     :    integer := 10;
    PIXEL_BITS       :    integer := 9;
    CONV_HEIGHT_BITS :    integer := 2);
  PORT ( CLK         : IN std_logic;    -- NOTE: The clock should not be gated
                                        -- as the timing in this module depends
                                        -- on the timing of an external RAM
         RST         : IN std_logic;
         LEVEL       : IN std_logic_vector(2 DOWNTO 0);
         -- 0:0:PIXEL_BITS Format
         MEM_VALUE   : IN std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
         MEM_VALID   : IN std_logic;
         -- Affine Homography elements IMG2_VEC=H*IMG1_VEC
         -- Rotation and Non-Isotropic Scale
         -- 1:6:11 Format
         H_0_0       : IN std_logic_vector(17 DOWNTO 0);
         H_0_1       : IN std_logic_vector(17 DOWNTO 0);
         H_1_0       : IN std_logic_vector(17 DOWNTO 0);
         H_1_1       : IN std_logic_vector(17 DOWNTO 0);
         -- Translation
         -- 1:10:11 Format 
         H_0_2       : IN std_logic_vector(21 DOWNTO 0);
         H_1_2       : IN std_logic_vector(21 DOWNTO 0);

         MEM_ADDR      : OUT std_logic_vector(2*IMGSIZE_BITS-1 DOWNTO 0);
         -- IMG0 Neighborhood for spatial derivative computation (only output
         -- the union of the middle row pixels and the middle column pixels)
         -- 0:0:PIXEL_BITS Format
         IMG0_0_1      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
         IMG0_1_0      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
         IMG0_1_1      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
         IMG0_1_2      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
         IMG0_2_1      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
         -- IMG1 Center pixel value for temporal derivative computation
         IMG1_1_1      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
         -- Offset pixel coordinates for A/b matrix computation (offset to
         -- increase numerical accuracy, corrected later in the pipeline)
         -- 1:IMGSIZE_BITS:1 Format
         TRANS_X_COORD : OUT std_logic_vector(IMGSIZE_BITS+1 DOWNTO 0);
         TRANS_Y_COORD : OUT std_logic_vector(IMGSIZE_BITS+1 DOWNTO 0);

         FSCS_VALID : OUT std_logic);
END fetch_stage;

ARCHITECTURE Behavioral OF fetch_stage IS
  COMPONENT conv_pixel_ordering IS
                                  GENERIC (
                                    CONV_HEIGHT      :     integer := 3;
                                    WIDTH_BITS       :     integer := 10;
                                    HEIGHT_BITS      :     integer := 10;
                                    CONV_HEIGHT_BITS :     integer := 2);
                                PORT ( CLK           : IN  std_logic;
                                       CLKEN         : IN  std_logic;
                                       RST           : IN  std_logic;
                                       HEIGHT        : IN  std_logic_vector(HEIGHT_BITS-1 DOWNTO 0);
                                       WIDTH         : IN  std_logic_vector(WIDTH_BITS-1 DOWNTO 0);
                                       WIDTH_OFFSET  : IN  std_logic_vector(WIDTH_BITS+HEIGHT_BITS-1 DOWNTO 0);  -- (CONV_HEIGHT-1)*WIDTH-1
                                       MEM_ADDR      : OUT std_logic_vector (WIDTH_BITS+HEIGHT_BITS-1 DOWNTO 0);
                                       X_COORD       : OUT std_logic_vector (WIDTH_BITS-1 DOWNTO 0);
                                       Y_COORD       : OUT std_logic_vector (HEIGHT_BITS-1 DOWNTO 0);
                                       CONV_Y_POS    : OUT std_logic_vector (CONV_HEIGHT_BITS-1 DOWNTO 0);
                                       DATA_VALID    : OUT std_logic;
                                       DONE          : OUT std_logic);
  END COMPONENT;

  COMPONENT affine_coord_transform IS
                                     GENERIC (
                                       IMGSIZE_BITS    :     integer             := 10;
                                       POSHALF         :     signed(21 DOWNTO 0) := "0000000000010000000000";
                                       NEGHALF         :     signed(21 DOWNTO 0) := "1111111111110000000000");
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
                                          OVERFLOW_X   : OUT std_logic;
                                          OVERFLOW_Y   : OUT std_logic;
                                          OUTPUT_VALID : OUT std_logic);
  END COMPONENT;

  COMPONENT convert_2d_to_1d_coord IS
                                     PORT ( CLK                                : IN  std_logic;
                                            RST                                : IN  std_logic;
                                            INPUT_VALID                        : IN  std_logic
                                        -- 0:10:0
                                            WIDTH                              : IN  std_logic_vector (9 DOWNTO 0);
                                        -- 0:10:0
                                            X_COORD                            : IN  std_logic_vector (9 DOWNTO 0);
                                        -- 0:10:0
                                            Y_COORD                            : IN  std_logic_vector (9 DOWNTO 0);
                                        -- 0:20:0
                                            MEM_ADDR                           : OUT std_logic_vector (19 DOWNTO 0);
                                            OUTPUT_VALID                       : OUT std_logic);
  END COMPONENT;
  COMPONENT mem_addr_selector IS
                                PORT ( CLK                                     : IN  std_logic;
                                       RST                                     : IN  std_logic;
                                       PIXEL_STATE                             : IN  std_logic_vector(0 DOWNTO 0);
                                       MEM_ADDR0                               : IN  std_logic_vector(0 DOWNTO 0);
                                       MEM_ADDR1                               : IN  std_logic_vector(0 DOWNTO 0);
                                       MEM_ADDROFF0                            : IN  std_logic_vector(0 DOWNTO 0);
                                       MEM_ADDROFF1                            : IN  std_logic_vector(0 DOWNTO 0);
                                       MEM_ADDR                                : OUT std_logic_vector(0 DOWNTO 0);
                                       PIXGEN_CLKEN                            : OUT std_logic);
  END COMPONENT;
  SIGNAL x_coord_trans, y_coord_trans, img_height, img_width, img_width_offset :     std_logic_vector(9 DOWNTO 0);
  SIGNAL img0_offset, img1_offset                                              :     std_logic_vector(19 DOWNTO 0);
BEGIN
-- Parameter ROM: Holds parameters that vary depending on the pyramid level.
-- (Maximum X/Y image coordinates, X/Y Offset Values (to produce a zero mean of
-- pixel coordinates)), level/img offsets, and width offset values(for conv.
-- coordinate generation). This only loads the new value on RST.
-- NOTE: Care must be taken in selecting these values to prevent (over/under)flow
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)
        CASE LEVEL IS
          WHEN 0 =>                     -- 720x480
            x_coord_trans    <=;        -- TODO Compute ROM values
            y_coord_trans    <=;
            img0_offset      <=;
            img1_offset      <=;        -- 
            img_height       <=;        -- TODO Make these unsigned
            img_width        <=;
            img_width_offset <=;        -- TODO Make this unsigned

          WHEN 1 =>                     -- 360x240
            x_coord_trans    <=;
            y_coord_trans    <=;
            img0_offset      <=;
            img1_offset      <=;
            img_height       <=;
            img_width        <=;
            img_width_offset <=;

          WHEN 2 =>                     -- 180x120
            x_coord_trans    <=;
            y_coord_trans    <=;
            img0_offset      <=;
            img1_offset      <=;
            img_height       <=;
            img_width        <=;
            img_width_offset <=;

          WHEN 3 =>                     -- 90x60
            x_coord_trans    <=;
            y_coord_trans    <=;
            img0_offset      <=;
            img1_offset      <=;
            img_height       <=;
            img_width        <=;
            img_width_offset <=;

          WHEN 4 =>                     -- 45x30
            x_coord_trans    <=;
            y_coord_trans    <=;
            img0_offset      <=;
            img1_offset      <=;
            img_height       <=;
            img_width        <=;
            img_width_offset <=;

          WHEN OTHERS                   =>
            x_coord_trans    <= (OTHERS => '0');
            y_coord_trans    <= (OTHERS => '0');
            img0_offset      <= (OTHERS => '0');
            img1_offset      <= (OTHERS => '0');
            img_height       <= (OTHERS => '0');
            img_width        <= (OTHERS => '0');
            img_width_offset <= (OTHERS => '0');
        END CASE;
      END IF;
    END IF;
  END PROCESS;

-- Convolution Pixel Stream: Stream pixel coordinates in a convolution pattern.
  conv_pixel_ordering_i : conv_pixel_ordering
    PORT MAP ( CLK          => CLK,
               CLKEN        => pixgen_clken,
               RST          => RST,
               HEIGHT       => img_height,
               WIDTH        => img_width,
               WIDTH_OFFSET => img_width_offset,
               MEM_ADDR     => coord_gen_mem_addr,
               CONV_Y_POS   => coord_gen_state,  -- 0=above cur pixel, 1=
                                                 -- current pixel, 2=below cur pixel for
                                                 -- 3x3
               X_COORD      => x_coord,
               Y_COORD      => y_coord,
               DATA_VALID   => coord_valid,
               DONE         => coord_gen_done);

-- Current Pixel Coord Check: Store current pixel coordinates (the center of
-- the convolution).
-- NOTE: This assumes that the pixel generator will never be halted (CLKEN='0') on the center pixel value.
  PROCESS (coord_valid, coord_gen_state) IS
  BEGIN  -- PROCESS
    IF coord_valid = '1' AND coord_gen_state = "01" THEN
      center_pixel_active <= '1';
    ELSE
      center_pixel_active <= '0';
    END IF;
  END PROCESS;

-- Affine Transform: Warp current pixel coordinate using H.
-- NOTE: 'Current' refers to the center pixel in the pattern (for 3x3 it is
-- pixel (1,1).) All others will still be processed to allow for a uniform
-- pipeline; however, their results are not intended to be used.
  PROCESS (center_pixel_active, coord_valid) IS
  BEGIN  -- PROCESS
    IF center_pixel_active = '1' AND coord_valid = '1' THEN
      affine_input_valid <= '1';
    ELSE
      affine_input_valid <= '0';
    END IF;
  END PROCESS;

  affine_coord_transform_i : affine_coord_transform
    PORT MAP ( CLK         => CLK,
               RST         => RST,
               INPUT_VALID => affine_input_valid,
               X_COORD     => x_coord,
               Y_COORD     => y_coord,

               H_0_0 => h_0_0_reg,
               H_1_0 => h_1_0_reg,
               H_0_1 => h_0_1_reg,
               H_1_1 => h_1_1_reg,

               H_0_2 => h_0_2_reg,
               H_1_2 => h_1_2_reg,

               XP_COORD     => xp_coord,
               YP_COORD     => yp_coord,
               OVERFLOW_X   => affine_overflow_x,
               OVERFLOW_Y   => affine_overflow_y,
               OUTPUT_VALID => warp_coord_valid);

-- Bounds check: Test the rounded X/Y Coordinate bounds to ensure they are
-- inside the image area. Valid ranges are 0<=X<img_width and 0<=Y<IMG_HEIGHT
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)
        affine_oob_x   <= '0';
        affine_oob_y   <= '0';
      ELSE
        IF unsigned(xp_coord) < img_width THEN
          affine_oob_x <= '0';
        ELSE
          affine_oob_x <= '1';
        END IF;

        IF unsigned(yp_coord) < img_height THEN
          affine_oob_y <= '0';
        ELSE
          affine_oob_y <= '1';
        END IF;
      END IF;
    END IF;
  END PROCESS;

-- 2D to 1D Coord Conversion: Convert warped 2D coords to 1D memory locations
-- (Y*WIDTH+X)
  convert_2d_to_1d_coord_i : convert_2d_to_1d_coord
    PORT MAP (
      CLK          => CLK,
      RST          => RST,
      INPUT_VALID  => warp_coord_valid,
      WIDTH        => img_width,
      X_COORD      => xp_coord,
      Y_COORD      => yp_coord,
      MEM_ADDR     => warped_mem_addr,
      OUTPUT_VALID => coord_conv_valid);

-- Translate Coords: Translate the image coordinates to reduce the
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)
        x_coord_trans   <= (OTHERS => '0');
        y_coord_trans   <= (OTHERS => '0');
      ELSE
        IF center_pixel_active = '1' THEN
          x_coord_trans <= unsigned(x_coord)-unsigned(x_coord_trans);
          y_coord_trans <= unsigned(y_coord)-unsigned(y_coord_trans);
        END IF;
      END IF;
    END IF;
  END PROCESS;

-- Memory Address Selector: Read 3 pixels from IMG0 using the coord generator'
-- s memory address, pause the coord generator, read 1 pixel from IMG1 using
-- the warped coord address

-- TODO Test behavior with pixel generator
  mem_addr_selector_i : mem_addr_selector
    PORT MAP ( CLK          <= CLK,
               RST          <= RST,
               PIXEL_STATE  <= coord_gen_state,
               MEM_ADDR0    <= coord_gen_mem_addr,
               MEM_ADDR1    <= warped_mem_addr,
               MEM_ADDROFF0 <= img0_offset,
               MEM_ADDROFF1 <= img1_offset,
               MEM_ADDR     <= MEM_ADDR,
               PIXGEN_CLKEN <= pixgen_clken);

-- Pixel Buffer : Store the kernel neighborhood and update it with incoming
-- pixel values. Note that since there is a delay between when the read
-- command is asserted and when the valid data is available, the cur pixel
-- state will be pipelined to align the valid data with the pixel state.

-- TODO Create 3, 3 row shift registers to act as the local neighborhood of the
-- image.


  
-- Signal Pipeline:  Passes previously computed values through the pipeline to
-- allow the signals to be output simultaneously.  Signals:  coord_stage,translated_
-- coords, bounds checking OOB, affine transform OOB,  coord_valid
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)
        coord_gen_state_buf <= (OTHERS => '0');
      ELSE
                                        -- Pipeline pixel state  -- TODO Fix this to be the exact number
                                        -- of stages

        coord_gen_state_buf(2) <= coord_gen_state;
        coord_gen_state_buf(1) <= coord_gen_state_buf(2);
        coord_gen_state_buf(0) <= coord_gen_state_buf(1);
      END IF;
    END IF;
  END PROCESS;

-- Output Valid: Set FSCS_VALID='1' if the output is valid for this CT. 3x3
-- IMG0 buffer must be full/valid, IMG1 warped value must be valid, and the
-- translated coords must be valid.
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)

      ELSE

      END IF;
    END IF;
  END PROCESS;
END Behavioral;

